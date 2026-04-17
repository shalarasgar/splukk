import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
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
    final barColor = bandIdx <= 1
        ? const Color(0xFFC62828)
        : const Color(0xFF2B8C5F);

    final imageUrl = listing.imageUrls.isNotEmpty
        ? listing.imageUrls.first
        : null;

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.router.push(ListingDetailRoute(listingId: listing.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Image & Details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image & Badge
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: imageUrl != null
                                ? Image.network(imageUrl, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 32,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),
                        // Top-left percentage badge
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$pct%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.shopping_basket,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${listing.farmName} - ${listing.city}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _productNamesLine(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _pickingLabel(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        if (hours != null)
                          Text(
                            hours,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: open
                                ? const Color(0xFF66BB6A)
                                : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Text(
                            open ? 'Açık' : 'Kapalı',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Bottom Row: Progress & Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Progress line & Status text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            color: barColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          headline,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: barColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 'Get Route' button
                  SizedBox(
                    height: 32,
                    child: FilledButton(
                      onPressed: () => _openMaps(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Yol tarifi',
                        style: TextStyle(fontSize: 16),
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
}
