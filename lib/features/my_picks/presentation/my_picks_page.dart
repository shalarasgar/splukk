import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/services/link_launcher_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:splukk/core/l10n/locale_keys.dart';

import 'package:flutter/services.dart';
import 'package:splukk/core/constants/products.dart';
import 'package:splukk/core/router/app_router.gr.dart';
import 'package:splukk/core/utils/exit_dialog.dart';
import 'package:splukk/features/listings/presentation/listing_ui_helpers.dart';
import 'package:splukk/features/shell/presentation/main_shell_page.dart';
import '../../../core/di/dependencies.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../domain/entities/my_pick_item.dart';
import 'my_picks_cubit.dart';
import 'my_picks_state.dart';

@RoutePage()
class MyPicksPage extends StatelessWidget {
  const MyPicksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final uid = context.read<AuthBloc>().state.profile?.uid;
        return sl<MyPicksCubit>()..loadMyPicks(uid);
      },
      child: const _MyPicksView(),
    );
  }
}

class _MyPicksView extends StatelessWidget {
  const _MyPicksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final isActive = ActiveTabProvider.of(context) == 1;
        return PopScope(
          canPop: !isActive,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop || !isActive) return;
        final shouldExit = await showExitConfirmationDialog(context);
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Stack(
          children: [
            // Background Decorative Elements
            Positioned(
              top: -100,
              right: -100,
              child: _CircleBlur(
                color: const Color(0xFF2B8C5F).withOpacity(0.1),
                size: 300,
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: _CircleBlur(
                color: Colors.orange.withOpacity(0.05),
                size: 250,
              ),
            ),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: BlocBuilder<MyPicksCubit, MyPicksState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2B8C5F),
                            ),
                          );
                        }

                        if (state.errorMessage != null) {
                          return _buildErrorState(context, state.errorMessage!);
                        }

                        if (state.items.isEmpty) {
                          return _buildEmptyState(context);
                        }

                        return RefreshIndicator(
                          color: const Color(0xFF2B8C5F),
                          onRefresh: () => context
                              .read<MyPicksCubit>()
                              .loadMyPicks(
                                context.read<AuthBloc>().state.profile?.uid,
                              ),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              return MyPickTicketCard(item: state.items[index]);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.nav_my_picks.tr(context: context),
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleKeys.my_picks_planned_visits.tr(context: context),
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _EmptyIllustration(),
          const SizedBox(height: 24),
          Text(
            LocaleKeys.my_picks_empty.tr(context: context),
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              LocaleKeys.my_picks_empty_subtitle.tr(context: context),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            error == 'AUTH_REQUIRED'
                ? LocaleKeys.auth_login_required.tr(context: context)
                : LocaleKeys.common_error_generic.tr(context: context),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey[800]),
          ),
          TextButton(
            onPressed: () => context.read<MyPicksCubit>().loadMyPicks(
              context.read<AuthBloc>().state.profile?.uid,
            ),
            child: Text(
              LocaleKeys.my_picks_retry.tr(context: context),
              style: const TextStyle(color: Color(0xFF2B8C5F)),
            ),
          ),
        ],
      ),
    );
  }
}

class MyPickTicketCard extends StatelessWidget {
  const MyPickTicketCard({super.key, required this.item});

  final MyPickItem item;

  String _formatDate(BuildContext context) {
    final date = item.bookingDate;
    final locale = context.locale.languageCode;
    return '${date.day} ${monthName(date.month, locale)} ${weekdayName(date.weekday, locale)}';
  }

  String _formatTime() {
    return '${formatDayMinutes(item.booking.startMinutes)} - ${formatDayMinutes(item.booking.endMinutes)}';
  }

  Future<void> _openMaps(BuildContext context) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${item.listing.latitude},${item.listing.longitude}';
    await sl<LinkLauncherService>().openExternalUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final bool upcoming = item.isUpcoming;
    final accentColor = upcoming ? const Color(0xFF2B8C5F) : Colors.grey[600]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.white.withOpacity(0.9),
            child: Column(
              children: [
                // Top Part (Farm Info & Products)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Thumbnail
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: item.listing.imageUrls.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(
                                    item.listing.imageUrls.first,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.grey[200],
                        ),
                        child: item.listing.imageUrls.isEmpty
                            ? const Icon(Icons.eco_outlined, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.listing.farmName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _StatusBadge(upcoming: upcoming),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.mapPin,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.listing.city,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Products row
                            _buildProductsRow(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Perforated Line
                _PerforatedLine(),

                // Bottom Part (Booking Details)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _DetailColumn(
                            icon: LucideIcons.calendar,
                            label: LocaleKeys.my_picks_date.tr(context: context),
                            value: _formatDate(context),
                          ),
                          const Spacer(),
                          _DetailColumn(
                            icon: LucideIcons.users,
                            label: LocaleKeys.my_picks_guests_count.tr(context: context),
                            value: LocaleKeys.listings_guests.plural(item.booking.guestCount, context: context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _DetailColumn(
                            icon: LucideIcons.clock,
                            label: LocaleKeys.my_picks_time.tr(context: context),
                            value: _formatTime(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _openMaps(context),
                              icon: const Icon(LucideIcons.map, size: 18),
                              label: Text(LocaleKeys.listings_map.tr(context: context)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: accentColor,
                                side: BorderSide(
                                  color: accentColor.withOpacity(0.3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.router.push(
                                  ListingDetailRoute(
                                    listingId: item.listing.id,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: Text(LocaleKeys.listings_details.tr(context: context)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsRow() {
    if (item.listing.products.isEmpty) return const SizedBox.shrink();

    // Show first 3 products
    final displayed = item.listing.products.take(3).toList();

    return Wrap(
      spacing: 6,
      children: displayed.map((p) {
        final label = products[p.categoryId]?[p.productId] ?? p.productId;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF2B8C5F),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.upcoming});
  final bool upcoming;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: upcoming ? const Color(0xFFE8F5E9) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        upcoming ? LocaleKeys.my_picks_upcoming.tr(context: context) : LocaleKeys.my_picks_past.tr(context: context),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: upcoming ? const Color(0xFF2E7D32) : Colors.grey[600],
        ),
      ),
    );
  }
}

class _DetailColumn extends StatelessWidget {
  const _DetailColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PerforatedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _Hole(isLeft: true),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final boxWidth = constraints.constrainWidth();
              const dashWidth = 5.0;
              const dashSpace = 4.0;
              final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
              return Flex(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                direction: Axis.horizontal,
                children: List.generate(dashCount, (_) {
                  return SizedBox(
                    width: dashWidth,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.grey[300]),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        const _Hole(isLeft: false),
      ],
    );
  }
}

class _Hole extends StatelessWidget {
  const _Hole({required this.isLeft});
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 10,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Matches page background
        borderRadius: BorderRadius.only(
          topRight: isLeft ? const Radius.circular(10) : Radius.zero,
          bottomRight: isLeft ? const Radius.circular(10) : Radius.zero,
          topLeft: !isLeft ? const Radius.circular(10) : Radius.zero,
          bottomLeft: !isLeft ? const Radius.circular(10) : Radius.zero,
        ),
      ),
    );
  }
}

class _EmptyIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF2B8C5F).withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            LucideIcons.heart,
            size: 64,
            color: const Color(0xFF2B8C5F).withOpacity(0.2),
          ),
          Transform.translate(
            offset: const Offset(20, -20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.search,
                size: 24,
                color: Color(0xFF2B8C5F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBlur extends StatelessWidget {
  const _CircleBlur({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
