import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splukk/core/router/app_router.gr.dart';
import '../../../core/di/dependencies.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/services/link_launcher_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:splukk/core/l10n/locale_keys.dart';

import '../../../core/utils/nok_money.dart';
import '../../auth/domain/auth_domain.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../../bookings/domain/repositories/booking_repository.dart';
import '../../bookings/domain/entities/booking.dart';
import '../domain/listings_domain.dart';
import 'listing_ui_helpers.dart';

@RoutePage()
class ListingDetailPage extends StatefulWidget {
  const ListingDetailPage({super.key, required this.listingId});

  final String listingId;

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  final _repo = sl<ListingRepository>();
  final _bookingRepo = sl<BookingRepository>();
  final _userProfileRepo = sl<UserProfileRepository>();

  FarmListing? _listing;
  UserProfile? _farmerProfile;
  Booking? _myBooking; // existing booking for this user+listing
  bool _isLoading = true;
  bool _isBusy = false;
  DayTimeSlot? _selectedSlot;
  int _guestCount = 1;

  @override
  void initState() {
    super.initState();
    // userUid resolved after first frame when BlocBuilder is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthBloc>().state.profile?.uid;
      _loadData(userUid: uid);
    });
  }

  Future<void> _loadData({String? userUid}) async {
    setState(() => _isLoading = true);
    try {
      final listingResult = await _repo.getListing(widget.listingId);
      final listing = listingResult.fold((l) => null, (r) => r);
      if (listing != null) {
        final profileResult = await _userProfileRepo.getProfile(
          listing.farmerUid,
        );
        Booking? myBooking;
        if (userUid != null) {
          final bookingResult = await _bookingRepo.getUserBookingForListing(
            userUid: userUid,
            listingId: widget.listingId,
          );
          myBooking = bookingResult.fold((l) => null, (r) => r);
        }
        if (mounted) {
          setState(() {
            _listing = listing;
            _farmerProfile = profileResult.fold((l) => null, (r) => r);
            _myBooking = myBooking;
            if (myBooking != null) _guestCount = myBooking.guestCount;
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(msg, style: GoogleFonts.inter())),
          ],
        ),
        backgroundColor: error ? Colors.redAccent : const Color(0xFF2B8C5F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _saveBooking(String userUid) async {
    if (_selectedSlot == null || _listing == null) return;
    setState(() => _isBusy = true);
    final slot = _selectedSlot!;
    if (_myBooking != null) {
      // UPDATE existing booking
      final result = await _bookingRepo.updateBooking(
        existing: _myBooking!,
        newGuestCount: _guestCount,
      );
      result.fold(
        (failure) => _showSnack(
            '${LocaleKeys.farmer_profile_error.tr(context: context)}: ${failure.message}',
            error: true),
        (_) => _showSnack(LocaleKeys.listings_booking_updated.tr(context: context)),
      );
    } else {
      // CREATE new booking
      final result = await _bookingRepo.createBooking(
        userUid: userUid,
        listingId: _listing!.id,
        weekday: slot.weekday,
        startMinutes: slot.startMinutes,
        endMinutes: slot.endMinutes,
        guestCount: _guestCount,
        specificDateMs: slot.specificDate?.millisecondsSinceEpoch,
      );
      result.fold(
        (failure) => _showSnack(
            '${LocaleKeys.farmer_profile_error.tr(context: context)}: ${failure.message}',
            error: true),
        (_) => _showSnack(LocaleKeys.listings_booking_success.tr(context: context)),
      );
    }
    await _loadData(userUid: userUid);
    setState(() {
      _selectedSlot = null;
      _guestCount = 1;
      _isBusy = false;
    });
  }

  Future<void> _cancelBooking(String userUid) async {
    if (_myBooking == null) return;
    setState(() => _isBusy = true);
    final result = await _bookingRepo.cancelBooking(booking: _myBooking!);
    await result.fold(
      (failure) async {
        _showSnack(
            '${LocaleKeys.farmer_profile_error.tr(context: context)}: ${failure.message}',
            error: true);
      },
      (_) async {
        _showSnack(LocaleKeys.listings_booking_cancelled.tr(context: context));
        await _loadData(userUid: userUid);
      },
    );
    if (mounted) {
      setState(() {
        _selectedSlot = null;
        _guestCount = 1;
        _isBusy = false;
      });
    }
  }

  Future<void> _openMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    await sl<LinkLauncherService>().openExternalUrl(url);
  }

  String _unitLabel(ListingPriceUnit u) {
    if (u == ListingPriceUnit.kg) return LocaleKeys.farmer_listing_form_unit_kg.tr(context: context);
    return LocaleKeys.farmer_listing_form_unit_package.tr(context: context);
  }

  String _pickingLabel(PickingType t) {
    if (t == PickingType.selfPicking) return LocaleKeys.listings_picking_self.tr(context: context);
    return LocaleKeys.listings_picking_prepicked.tr(context: context);
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFBFBFB),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2B8C5F)),
        ),
      );
    }

    if (_listing == null) {
      return Scaffold(
        appBar: AppBar(title: Text(LocaleKeys.listings_details.tr(context: context), style: GoogleFonts.outfit())),
        body: Center(
          child: Text(LocaleKeys.farmer_dashboard_no_listings.tr(context: context), style: GoogleFonts.inter()),
        ),
      );
    }

    final listing = _listing!;
    final now = DateTime.now();
    final open = isListingOpenNow(listing, now);
    final headline = availabilityHeadlineForListing(listing, context);
    final farmerAddress = _farmerProfile?.farmAddress ?? _farmerProfile?.farmLocationSummary;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF2B8C5F),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (listing.imageUrls.isNotEmpty)
                    PageView.builder(
                      itemCount: listing.imageUrls.length,
                      itemBuilder: (context, i) {
                        return Image.network(
                          listing.imageUrls[i],
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        LucideIcons.image,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  // Gradient over image
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                listing.farmName,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4),
                  ],
                ),
              ),
              titlePadding: const EdgeInsets.only(
                left: 20,
                bottom: 16,
                right: 20,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.city,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: open
                              ? const Color(0xFF2B8C5F).withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              open ? Icons.check_circle : Icons.cancel,
                              color: open
                                  ? const Color(0xFF2B8C5F)
                                  : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              open ? LocaleKeys.listings_open.tr(context: context) : LocaleKeys.listings_closed.tr(context: context),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: open
                                    ? const Color(0xFF2B8C5F)
                                    : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Müsaitlik ve Tip Kartı
                  _buildGlassCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2B8C5F).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.leaf,
                                color: Color(0xFF2B8C5F),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LocaleKeys.listings_status.tr(context: context),
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Text(
                                    headline,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '%${listing.availabilityPercent}',
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2B8C5F),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.shoppingBag,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LocaleKeys.listings_picking_type.tr(context: context),
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Text(
                                    _pickingLabel(listing.pickingType),
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    LocaleKeys.listings_products.tr(context: context),
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...listing.products.map((p) {
                    final name = 'products.${p.productId}'.tr(context: context);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildGlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2B8C5F).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${formatOreAsNokKr(p.priceOre)} / ${_unitLabel(p.unit)}',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF2B8C5F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  if (listing.description != null &&
                      listing.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      LocaleKeys.farmer_listing_form_description.tr(context: context),
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGlassCard(
                      child: Text(
                        listing.description!.trim(),
                        style: GoogleFonts.inter(
                          color: Colors.grey[800],
                          height: 1.6,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  Text(
                    LocaleKeys.location_city.tr(context: context), // Or some key for "Location"
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (farmerAddress != null &&
                            farmerAddress.isNotEmpty) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  LucideIcons.mapPin,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  farmerAddress,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: Colors.grey[800],
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () =>
                                _openMaps(listing.latitude, listing.longitude),
                            icon: const Icon(LucideIcons.navigation, size: 18),
                            label: Text(
                              LocaleKeys.listings_directions.tr(context: context),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2B8C5F),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    LocaleKeys.listings_schedule_booking.tr(context: context),
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final userUid = authState.profile?.uid;
                      final role = authState.profile?.role;
                      final isConsumer = role == UserRole.consumer;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Slot list ──────────────────────────────────
                          ...listing.schedule.map((s) {
                            final isFull = s.bookedCount >= s.maxPeople;
                            final isSelected = _selectedSlot == s;
                            final isMySlot =
                                _myBooking != null &&
                                _myBooking!.weekday == s.weekday &&
                                _myBooking!.startMinutes == s.startMinutes &&
                                _myBooking!.endMinutes == s.endMinutes;
                            final dateStr = s.specificDate != null
                                ? '${s.specificDate!.day}.${s.specificDate!.month}.${s.specificDate!.year}'
                                : weekdayName(s.weekday, context.locale.languageCode);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: (!isConsumer || (isFull && !isMySlot))
                                    ? null
                                    : () => setState(() {
                                        _selectedSlot = _selectedSlot == s
                                            ? null
                                            : s;
                                        if (_selectedSlot == null) {
                                          _guestCount =
                                              _myBooking?.guestCount ?? 1;
                                        }
                                      }),
                                borderRadius: BorderRadius.circular(16),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isMySlot
                                        ? const Color(
                                            0xFF2B8C5F,
                                          ).withOpacity(0.07)
                                        : isSelected
                                        ? const Color(
                                            0xFF2B8C5F,
                                          ).withOpacity(0.04)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isMySlot
                                          ? const Color(0xFF2B8C5F)
                                          : isSelected
                                          ? const Color(0xFF2B8C5F)
                                          : Colors.grey[300]!,
                                      width: (isMySlot || isSelected) ? 2 : 1,
                                    ),
                                    boxShadow: (isMySlot || isSelected)
                                        ? [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF2B8C5F,
                                              ).withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isFull && !isMySlot
                                              ? Colors.grey[100]
                                              : const Color(
                                                  0xFF2B8C5F,
                                                ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          isMySlot
                                              ? LucideIcons.checkCircle2
                                              : LucideIcons.calendarClock,
                                          color: isFull && !isMySlot
                                              ? Colors.grey[400]
                                              : const Color(0xFF2B8C5F),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$dateStr • ${formatDayMinutes(s.startMinutes)}–${formatDayMinutes(s.endMinutes)}',
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color: isFull && !isMySlot
                                                    ? Colors.grey[500]
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              isFull
                                                  ? LocaleKeys.listings_full.tr(context: context)
                                                  : '${LocaleKeys.listings_free.tr(context: context)}: ${s.maxPeople - s.bookedCount} ${LocaleKeys.listings_guests.plural(s.maxPeople - s.bookedCount, context: context)}',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: isMySlot
                                                    ? const Color(0xFF2B8C5F)
                                                    : isFull
                                                    ? Colors.red
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            if (isConsumer &&
                                                _myBooking != null &&
                                                _selectedSlot == null) ...[
                                              Text(
                                                'Aktif rezervasyonunuz var:\n${_myBooking!.guestCount} kişi',
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      // if (isConsumer && (!isFull || isMySlot))
                                      //   Radio<DayTimeSlot>(
                                      //     value: s,
                                      //     groupValue: _selectedSlot,
                                      //     activeColor: const Color(0xFF2B8C5F),
                                      //     onChanged: (val) => setState(
                                      //       () => _selectedSlot = val,
                                      //     ),
                                      //   ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),

                          // ── Guest count picker (shown when slot selected) ──
                          if (isConsumer && _selectedSlot != null) ...[
                            const SizedBox(height: 8),
                            _buildGlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LocaleKeys.listings_how_many_guests.tr(context: context),
                                    style: GoogleFonts.outfit(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Builder(
                                    builder: (_) {
                                      final freeSpots =
                                          _selectedSlot!.maxPeople -
                                          _selectedSlot!.bookedCount +
                                          (_myBooking != null &&
                                                  _myBooking!.weekday ==
                                                      _selectedSlot!.weekday
                                              ? _myBooking!.guestCount
                                              : 0);
                                      final maxGuests = freeSpots.clamp(1, 3);
                                      return Column(
                                        children: [
                                          SizedBox(
                                            height: 130,
                                            child: CupertinoPicker(
                                              scrollController:
                                                  FixedExtentScrollController(
                                                    initialItem:
                                                        (_guestCount - 1).clamp(
                                                          0,
                                                          maxGuests - 1,
                                                        ),
                                                  ),
                                              itemExtent: 42,
                                              onSelectedItemChanged: (i) =>
                                                  setState(
                                                    () => _guestCount = i + 1,
                                                  ),
                                              children: List.generate(
                                                maxGuests,
                                                (i) {
                                                  return Center(
                                                    child: Text(
                                                      LocaleKeys.listings_guests.plural(i + 1, context: context),
                                                      style: GoogleFonts.inter(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          if (freeSpots < 3)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: Text(
                                                LocaleKeys.listings_max_guests.plural(freeSpots, namedArgs: {'count': freeSpots.toString()}, context: context),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: Colors.orange[700],
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    context.router.push(
                                      ChatRoute(
                                        listingId: listing.id,
                                        farmerName: listing.farmName,
                                        farmerUid: listing.farmerUid,
                                      ),
                                    );
                                  },
                                  icon: const Icon(LucideIcons.messageCircle, color: Color(0xFF2B8C5F)),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFF2B8C5F).withOpacity(0.1),
                                    padding: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: _isBusy || userUid == null
                                        ? null
                                        : () => _saveBooking(userUid),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF2B8C5F),
                                      disabledBackgroundColor: Colors.grey[300],
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: _isBusy
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            _myBooking != null
                                                ? LocaleKeys.bookings_update.tr(context: context)
                                                : LocaleKeys.listings_book_now.tr(context: context),
                                            style: GoogleFonts.outfit(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // ── Cancel booking button ───────────────────────
                          if (isConsumer &&
                              _myBooking != null &&
                              _selectedSlot == null) ...[
                            const SizedBox(height: 8),
                            // _buildGlassCard(
                            //   child: Row(
                            //     children: [
                            //       Container(
                            //         padding: const EdgeInsets.all(10),
                            //         decoration: BoxDecoration(
                            //           color: const Color(
                            //             0xFF2B8C5F,
                            //           ).withOpacity(0.1),
                            //           borderRadius: BorderRadius.circular(12),
                            //         ),
                            //         child: const Icon(
                            //           LucideIcons.checkCircle2,
                            //           color: Color(0xFF2B8C5F),
                            //         ),
                            //       ),
                            //       const SizedBox(width: 14),
                            //       Expanded(
                            //         child: Text(
                            //           'Aktif rezervasyonunuz var:\n${_myBooking!.guestCount} kişi',
                            //           style: GoogleFonts.inter(
                            //             fontWeight: FontWeight.w600,
                            //             fontSize: 14,
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: _isBusy || userUid == null
                                  ? null
                                  : () => _cancelBooking(userUid),
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                              ),
                              label: Text(
                                LocaleKeys.bookings_cancel.tr(context: context),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
