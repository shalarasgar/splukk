import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/products.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../domain/listings_domain.dart';
import '../listing_ui_helpers.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({super.key, required this.listing, this.now});

  final FarmListing listing;
  final DateTime? now;

  String _productNamesLine() {
    if (listing.products.isEmpty) return '';
    return listing.products
        .map((p) {
          final label = products[p.categoryId]?[p.productId] ?? p.productId;
          return label;
        })
        .join(', ');
  }

  String _pickingLabel() {
    switch (listing.pickingType) {
      case PickingType.selfPicking:
        return 'Kendi toplama';
      case PickingType.prePicked:
        return 'Toplanmış satış';
    }
  }

  Future<void> _openMaps(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${listing.latitude},${listing.longitude}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harita açılamadı')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = now ?? DateTime.now();
    final open = isListingOpenNow(listing, t);
    final hours = todayHoursSummary(listing, t);
    final pct = listing.availabilityPercent.clamp(0, 100);
    final headline = availabilityHeadlineForListing(listing);
    final bandIdx = bandIndexForListing(listing);

    // Используем наш "премиальный" зеленый для хороших состояний
    final accentGreen = const Color(0xFF2B8C5F);
    final warningRed = const Color(0xFFC62828);
    final barColor = bandIdx <= 1 ? warningRed : accentGreen;

    final imageUrl = listing.imageUrls.isNotEmpty
        ? listing.imageUrls.first
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.router.push(ListingDetailRoute(listingId: listing.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Image & Details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with Badge
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey[200],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageUrl != null
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Icon(
                                Icons.image_not_supported_outlined,
                                size: 32,
                                color: Colors.grey[400],
                              ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$pct%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                // LucideIcons.shoppingCart,
                                Icons.shopping_basket,
                                size: 12,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Details Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${listing.farmName} • ${listing.city}',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _productNamesLine(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        _buildInfoRow(
                          Icons.back_hand_outlined,
                          // LucideIcons.hand,
                          _pickingLabel(),
                        ),
                        if (hours != null)
                          _buildInfoRow(
                            // Icons.access_time,
                            LucideIcons.clock,
                            hours,
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: open
                                    ? accentGreen.withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                open ? 'AÇIK' : 'KAPALI',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: open ? accentGreen : Colors.grey[600],
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Builder(builder: (context) {
                              final d = getListingNextAvailableDate(listing, t);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 8),
                                  Text(
                                    '${d.day} ${monthNameTr(d.month)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bottom Progress & Action
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey[100],
                            color: barColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          headline,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: barColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _openMaps(context),
                    icon: const Icon(LucideIcons.navigation, size: 18),
                    label: const Text('Tarif'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: warningRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
