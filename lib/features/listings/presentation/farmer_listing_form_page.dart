import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splukk/core/router/app_router.gr.dart';
import '../../../core/di/dependencies.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splukk/core/services/media_picker_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:splukk/core/l10n/locale_keys.dart';

import '../../../core/app_messages.dart';
import '../../../core/constants/availability_presets.dart';
import '../../../core/constants/products.dart';
import '../../../core/utils/nok_money.dart';
import '../../auth/domain/auth_domain.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../domain/listings_domain.dart';
import 'widgets/listing_card.dart';
import 'widgets/farmer_form/farmer_form_models.dart';
import 'widgets/farmer_form/image_thumbs.dart';
import 'widgets/farmer_form/product_row_editor.dart';
import 'widgets/farmer_form/schedule_row_editor.dart';
import 'widgets/farmer_form/form_dialogs.dart';
import 'bloc/listing_form_cubit.dart';
import 'bloc/listing_form_state.dart';

@RoutePage()
class FarmerListingFormPage extends StatefulWidget {
  const FarmerListingFormPage({super.key, this.listingId});

  final String? listingId;

  @override
  State<FarmerListingFormPage> createState() => _FarmerListingFormPageState();
}

class _FarmerListingFormPageState extends State<FarmerListingFormPage> {
  final _farmName = TextEditingController();
  final _city = TextEditingController();
  final _description = TextEditingController();

  final _productRows = <ProductLineDraft>[];
  final _scheduleRows = <ScheduleDraft>[];
  final _localImagePaths = <String>[];
  final _existingImageUrls = <String>[];

  double _availability = 75;
  int? _messageIndexInBand;
  PickingType _picking = PickingType.selfPicking;
  bool _manualClosed = false;
  bool _loading = false;
  FarmListing? _existing;

  static DateTime _nextOccurrenceOfWeekday(int weekday, DateTime from) {
    var d = DateTime(from.year, from.month, from.day);
    for (var i = 0; i < 8; i++) {
      if (d.weekday == weekday) return d;
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final id = widget.listingId;
    if (id != null) {
      await _loadListing(id);
    } else {
      _prefillFromAuthProfile();
    }
  }

  void _prefillFromAuthProfile() {
    final profile = context.read<AuthBloc>().state.profile;
    if (profile == null || profile.role != UserRole.farmer) return;
    _farmName.text = profile.farmName ?? '';
    _city.text = profile.farmCity ?? '';
    if (_productRows.isEmpty && products.isNotEmpty) {
      final firstCat = products.keys.first;
      final firstProd = products[firstCat]!.keys.first;
      _productRows.add(
        ProductLineDraft(
          categoryId: firstCat,
          productId: firstProd,
          priceController: TextEditingController(),
          unit: ListingPriceUnit.kg,
        ),
      );
    }
    if (_scheduleRows.isEmpty) {
      final mon = _nextOccurrenceOfWeekday(DateTime.monday, DateTime.now());
      _scheduleRows.add(
        ScheduleDraft(
          weekday: DateTime.monday,
          calendarAnchor: mon,
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 18, minute: 0),
          capacityController: TextEditingController(text: '10'),
        ),
      );
    }
    setState(() {});
  }

  Future<void> _loadListing(String id) async {
    setState(() => _loading = true);
    final repo = sl<ListingRepository>();
    final result = await repo.getListing(id);
    final listing = result.fold((l) => null, (r) => r);
    if (!mounted) return;
    if (listing == null) {
      setState(() => _loading = false);
      showAppSnackBar(
        context,
        LocaleKeys.farmer_dashboard_no_listings.tr(context: context),
        isError: true,
      );
      return;
    }
    _existing = listing;
    _farmName.text = listing.farmName;
    _city.text = listing.city;
    _description.text = listing.description ?? '';
    for (final p in _productRows) {
      p.priceController.dispose();
    }
    _productRows.clear();
    for (final s in _scheduleRows) {
      s.capacityController.dispose();
    }
    _scheduleRows.clear();
    _availability = listing.availabilityPercent.toDouble();
    _messageIndexInBand = listing.availabilityMessageIndex;
    _picking = listing.pickingType;
    _manualClosed = listing.manualClosed;
    _existingImageUrls
      ..clear()
      ..addAll(listing.imageUrls);
    if (listing.products.isNotEmpty) {
      final p = listing.products.first;
      _productRows.add(
        ProductLineDraft(
          categoryId: p.categoryId,
          productId: p.productId,
          priceController: TextEditingController(
            text: formatOreAsNokKr(p.priceOre),
          ),
          unit: p.unit,
        ),
      );
    } else if (products.isNotEmpty) {
      final firstCat = products.keys.first;
      final firstProd = products[firstCat]!.keys.first;
      _productRows.add(
        ProductLineDraft(
          categoryId: firstCat,
          productId: firstProd,
          priceController: TextEditingController(),
          unit: ListingPriceUnit.kg,
        ),
      );
    }
    for (final s in listing.schedule) {
      _scheduleRows.add(
        ScheduleDraft(
          weekday: s.weekday,
          start: TimeOfDay(
            hour: s.startMinutes ~/ 60,
            minute: s.startMinutes % 60,
          ),
          end: TimeOfDay(hour: s.endMinutes ~/ 60, minute: s.endMinutes % 60),
          calendarAnchor: s.specificDate,
          capacityController: TextEditingController(
            text: s.maxPeople.toString(),
          ),
        ),
      );
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _farmName.dispose();
    _city.dispose();
    _description.dispose();
    for (final p in _productRows) {
      p.priceController.dispose();
    }
    for (final s in _scheduleRows) {
      s.capacityController.dispose();
    }
    super.dispose();
  }

  int get _bandIndex => availabilityBandIndexForPercent(_availability.round());

  List<String> _currentBandSuggestions(BuildContext context) =>
      availabilityBands[_bandIndex].getSuggestions(context);

  void _onAvailabilityChanged(double v) {
    final oldBand = availabilityBandIndexForPercent(_availability.round());
    final newBand = availabilityBandIndexForPercent(v.round());
    setState(() {
      _availability = v;
      if (oldBand != newBand) {
        _messageIndexInBand = 0;
      }
    });
  }

  void _addScheduleRow() {
    setState(() {
      _scheduleRows.add(
        ScheduleDraft(
          weekday: DateTime.monday,
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 18, minute: 0),
          capacityController: TextEditingController(text: '10'),
        ),
      );
    });
  }

  Future<void> _confirmRemoveScheduleRow(BuildContext context, int i) async {
    final ok = await FarmerFormDialogs.showConfirmDeleteSchedule(context);
    if (ok && mounted) {
      setState(() {
        _scheduleRows.removeAt(i).capacityController.dispose();
      });
    }
  }

  Future<void> _pickImages() async {
    final paths = await sl<MediaPickerService>().pickMultipleImages();
    if (paths.isEmpty) return;
    setState(() {
      for (final p in paths) {
        _localImagePaths.add(p);
      }
    });
  }

  void _removeLocalImage(int i) {
    setState(() => _localImagePaths.removeAt(i));
  }

  void _removeExistingImage(int i) {
    setState(() => _existingImageUrls.removeAt(i));
  }

  Future<void> _save(BuildContext ctx) async {
    final uid = ctx.read<AuthBloc>().state.profile?.uid;
    if (uid == null) {
      showAppSnackBar(
        context,
        LocaleKeys.farmer_dashboard_auth_required.tr(context: context),
        isError: true,
      );
      return;
    }
    if (_farmName.text.trim().isEmpty || _city.text.trim().isEmpty) {
      showAppSnackBar(
        context,
        LocaleKeys.farmer_listing_form_error_farm_required.tr(context: context),
        isError: true,
      );
      return;
    }
    double? lat;
    double? lng;
    if (widget.listingId == null) {
      final profile = context.read<AuthBloc>().state.profile;
      lat = profile?.farmLatitude;
      lng = profile?.farmLongitude;
      if (lat == null || lng == null) {
        if (!mounted) return;
        final go = await FarmerFormDialogs.showLocationRequired(context);
        if (go && mounted) {
          context.router.replaceAll([MainShellRoute(initialTabIndex: 2)]);
        }
        return;
      }
    } else {
      final ex = _existing;
      if (ex == null) {
        showAppSnackBar(
          context,
          LocaleKeys.farmer_listing_form_save_failure.tr(context: context),
          isError: true,
        );
        return;
      }
      lat = ex.latitude;
      lng = ex.longitude;
    }
    if (_productRows.isEmpty) {
      showAppSnackBar(
        context,
        LocaleKeys.farmer_listing_form_error_no_products.tr(context: context),
        isError: true,
      );
      return;
    }
    final lines = <ListingProductLine>[];
    for (final row in _productRows) {
      final ore = parseNokToOre(row.priceController.text);
      if (ore == null || ore <= 0) {
        showAppSnackBar(
          context,
          LocaleKeys.farmer_listing_form_error_invalid_price.tr(
            context: context,
          ),
          isError: true,
        );
        return;
      }
      lines.add(
        ListingProductLine(
          categoryId: row.categoryId,
          productId: row.productId,
          priceOre: ore,
          unit: row.unit,
        ),
      );
    }
    if (_scheduleRows.isEmpty) {
      showAppSnackBar(
        context,
        LocaleKeys.farmer_listing_form_error_no_schedule.tr(context: context),
        isError: true,
      );
      return;
    }
    final slots = <DayTimeSlot>[];
    for (final row in _scheduleRows) {
      final cap = int.tryParse(row.capacityController.text.trim());
      if (cap == null || cap < 1) {
        showAppSnackBar(
          context,
          LocaleKeys.farmer_listing_form_error_capacity_min.tr(
            context: context,
          ),
          isError: true,
        );
        return;
      }
      final sm = row.start.hour * 60 + row.start.minute;
      final em = row.end.hour * 60 + row.end.minute;
      if (em <= sm) {
        showAppSnackBar(
          context,
          LocaleKeys.farmer_listing_form_error_end_time.tr(context: context),
          isError: true,
        );
        return;
      }
      slots.add(
        DayTimeSlot(
          weekday: row.weekday,
          startMinutes: sm,
          endMinutes: em,
          maxPeople: cap,
        ),
      );
    }
    final pct = _availability.round().clamp(0, 100);
    final band = availabilityBands[availabilityBandIndexForPercent(pct)];
    final rawMsg = _messageIndexInBand ?? 0;
    final msgIdx = rawMsg.clamp(0, band.suggestionKeys.length - 1);
    final desc = _description.text.trim();

    ctx.read<ListingFormCubit>().submitForm(
      existingListingId: widget.listingId,
      existingListing: _existing,
      farmerUid: uid,
      farmName: _farmName.text.trim(),
      city: _city.text.trim(),
      localImagePaths: _localImagePaths,
      existingImageUrls: _existingImageUrls,
      pickingType: _picking,
      availabilityPercent: pct,
      availabilityMessageIndex: msgIdx,
      manualClosed: _manualClosed,
      description: desc.isEmpty ? null : desc,
      latitude: lat,
      longitude: lng,
      products: lines,
      schedule: slots,
    );
  }

  FarmListing _buildMockListing() {
    final pct = _availability.round().clamp(0, 100);
    final band = availabilityBands[availabilityBandIndexForPercent(pct)];
    final msgIdx = (_messageIndexInBand ?? 0).clamp(
      0,
      band.suggestionKeys.length - 1,
    );
    return FarmListing(
      id: widget.listingId ?? 'mock',
      farmerUid: 'mock_farmer',
      farmName: _farmName.text.isNotEmpty
          ? _farmName.text
          : LocaleKeys.farmer_listing_form_mock_farm_name.tr(context: context),
      city: _city.text.isNotEmpty
          ? _city.text
          : LocaleKeys.farmer_listing_form_mock_city.tr(context: context),
      imageUrls: _existingImageUrls,
      pickingType: _picking,
      availabilityPercent: pct,
      availabilityMessageIndex: msgIdx,
      manualClosed: _manualClosed,
      description: _description.text,
      latitude: _existing?.latitude ?? 0,
      longitude: _existing?.longitude ?? 0,
      products: _productRows.map((r) {
        final ore = parseNokToOre(r.priceController.text) ?? 0;
        return ListingProductLine(
          categoryId: r.categoryId,
          productId: r.productId,
          priceOre: ore,
          unit: r.unit,
        );
      }).toList(),
      schedule: _scheduleRows.map((s) {
        final cap = int.tryParse(s.capacityController.text.trim()) ?? 10;
        return DayTimeSlot(
          weekday: s.weekday,
          startMinutes: s.start.hour * 60 + s.start.minute,
          endMinutes: s.end.hour * 60 + s.end.minute,
          maxPeople: cap,
          specificDate: s.calendarAnchor,
        );
      }).toList(),
      createdAt: _existing?.createdAt ?? DateTime.now(),
      updatedAt: _existing?.updatedAt ?? DateTime.now(),
      expiresAt: _existing?.expiresAt ?? DateTime.now(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label, {
    String? hintText,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      helperText: helperText,
      labelStyle: GoogleFonts.inter(color: Colors.grey[600]),
      hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
      helperStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2B8C5F), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFBFBFB),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2B8C5F)),
        ),
      );
    }

    final bandSuggestions = _currentBandSuggestions(context);
    final selectedMsgIdx = (_messageIndexInBand ?? 0).clamp(
      0,
      bandSuggestions.length - 1,
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenWidth * 0.6;

    return BlocProvider(
      create: (context) => sl<ListingFormCubit>(),
      child: BlocConsumer<ListingFormCubit, ListingFormState>(
        listener: (context, state) {
          if (state is ListingFormSuccess) {
            showAppSnackBar(
              context,
              LocaleKeys.farmer_listing_form_save_success.tr(context: context),
            );
            context.router.maybePop();
          } else if (state is ListingFormFailure) {
            showAppSnackBar(
              context,
              '${LocaleKeys.farmer_listing_form_save_failure.tr(context: context)}: ${state.errorMessage}',
              isError: true,
            );
          }
        },
        builder: (context, state) {
          final isSaving = state is ListingFormSaving;
          return Scaffold(
            backgroundColor: const Color(0xFFFBFBFB),
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: headerHeight,
                  collapsedHeight: kToolbarHeight + 20,
                  toolbarHeight: kToolbarHeight + 20,
                  pinned: true,
                  stretch: true,
                  backgroundColor: const Color(0xFF2B8C5F),
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 16,
                        top: 8,
                        bottom: 8,
                      ),
                      child: FilledButton(
                        onPressed: isSaving ? null : () => _save(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2B8C5F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF2B8C5F),
                                ),
                              )
                            : Text(
                                LocaleKeys.common_save.tr(context: context),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset('assets/4.png', fit: BoxFit.cover),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          left: 20,
                          right: 20,
                          child: Text(
                            widget.listingId == null
                                ? LocaleKeys.farmer_listing_form_new_title.tr(
                                    context: context,
                                  )
                                : LocaleKeys.farmer_listing_form_edit_title.tr(
                                    context: context,
                                  ),
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),
                      Text(
                        LocaleKeys.farmer_listing_form_preview_title.tr(
                          context: context,
                        ),
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2B8C5F),
                        ),
                      ),
                      Text(
                        LocaleKeys.farmer_listing_form_preview_subtitle.tr(
                          context: context,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      ///////////////////////////// Card
                      const SizedBox(height: 12),
                      ListingCard(listing: _buildMockListing()),

                      _buildSectionHeader(
                        LocaleKeys.farmer_listing_form_images_label.tr(
                          context: context,
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < _existingImageUrls.length; i++)
                            NetworkThumb(
                              url: _existingImageUrls[i],
                              onRemove: () => _removeExistingImage(i),
                            ),
                          for (var i = 0; i < _localImagePaths.length; i++)
                            LocalThumb(
                              path: _localImagePaths[i],
                              onRemove: () => _removeLocalImage(i),
                            ),
                          ActionChip(
                            avatar: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            label: Text(
                              LocaleKeys.farmer_listing_form_add.tr(
                                context: context,
                              ),
                              style: GoogleFonts.inter(),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onPressed: _pickImages,
                          ),
                        ],
                      ),

                      _buildSectionHeader(
                        LocaleKeys.farmer_listing_form_section_farm_info.tr(
                          context: context,
                        ),
                      ),
                      TextField(
                        controller: _farmName,
                        readOnly: true,
                        enableInteractiveSelection: false,
                        decoration: _buildInputDecoration(
                          LocaleKeys.auth_farm_name.tr(context: context),
                          helperText: LocaleKeys
                              .farmer_listing_form_read_only_hint
                              .tr(context: context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _city,
                        readOnly: true,
                        enableInteractiveSelection: false,
                        decoration: _buildInputDecoration(
                          LocaleKeys.location_city.tr(context: context),
                          helperText: LocaleKeys
                              .farmer_listing_form_read_only_hint
                              .tr(context: context),
                        ),
                      ),

                      _buildSectionHeader(
                        LocaleKeys.farmer_listing_form_product.tr(
                          context: context,
                        ),
                      ),
                      for (var i = 0; i < _productRows.length; i++) ...[
                        ProductRowEditor(
                          row: _productRows[i],
                          onChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 8),
                      ],

                      _buildSectionHeader(
                        LocaleKeys.farmer_listing_form_picking_type.tr(
                          context: context,
                        ),
                      ),
                      SegmentedButton<PickingType>(
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        segments: [
                          ButtonSegment(
                            value: PickingType.selfPicking,
                            label: Text(
                              LocaleKeys.listings_picking_self.tr(
                                context: context,
                              ),
                            ),
                          ),
                          ButtonSegment(
                            value: PickingType.prePicked,
                            label: Text(
                              LocaleKeys.listings_picking_prepicked.tr(
                                context: context,
                              ),
                            ),
                          ),
                        ],
                        selected: {_picking},
                        onSelectionChanged: (s) =>
                            setState(() => _picking = s.first),
                      ),

                      _buildSectionHeader(
                        '${LocaleKeys.farmer_listing_form_remaining_stock.tr(context: context)} — ${_availability.round()}',
                      ),
                      Slider(
                        value: _availability,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        activeColor: const Color(0xFF2B8C5F),
                        label: '${_availability.round()}%',
                        onChanged: _onAvailabilityChanged,
                      ),
                      Text(
                        '${LocaleKeys.farmer_listing_form_availability_msg.tr(context: context)} (${availabilityBands[_bandIndex].minInclusive}–${availabilityBands[_bandIndex].maxInclusive}%)',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: selectedMsgIdx,
                        items: [
                          for (var i = 0; i < bandSuggestions.length; i++)
                            DropdownMenuItem(
                              value: i,
                              child: Text(
                                bandSuggestions[i],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(),
                              ),
                            ),
                        ],
                        onChanged: (v) =>
                            setState(() => _messageIndexInBand = v),
                        decoration: _buildInputDecoration(
                          LocaleKeys.farmer_listing_form_suggested_text.tr(
                            context: context,
                          ),
                        ),
                      ),

                      _buildSectionHeader(
                        LocaleKeys.farmer_listing_form_visibility.tr(
                          context: context,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            LocaleKeys.farmer_listing_form_activate.tr(
                              context: context,
                            ),
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            LocaleKeys.farmer_listing_form_visibility_hint.tr(
                              context: context,
                            ),
                            style: GoogleFonts.inter(fontSize: 13),
                          ),
                          activeColor: const Color(0xFF2B8C5F),
                          value: _manualClosed,
                          onChanged: (v) => setState(() => _manualClosed = v),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _description,
                        minLines: 3,
                        maxLines: 6,
                        decoration: _buildInputDecoration(
                          LocaleKeys.farmer_listing_form_description.tr(
                            context: context,
                          ),
                          hintText: LocaleKeys
                              .farmer_listing_form_description_hint
                              .tr(context: context),
                        ),
                      ),

                      _buildSectionHeader(
                        LocaleKeys.farmer_listing_form_calendar.tr(
                          context: context,
                        ),
                      ),
                      for (var i = 0; i < _scheduleRows.length; i++) ...[
                        ScheduleRowEditor(
                          row: _scheduleRows[i],
                          onRemove: () => _confirmRemoveScheduleRow(context, i),
                          onChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 8),
                      ],
                      OutlinedButton.icon(
                        onPressed: _addScheduleRow,
                        icon: const Icon(Icons.schedule),
                        label: Text(
                          LocaleKeys.farmer_listing_form_add.tr(
                            context: context,
                          ),
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2B8C5F),
                          side: const BorderSide(color: Color(0xFF2B8C5F)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
