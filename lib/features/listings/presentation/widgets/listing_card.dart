import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/products.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../domain/listings_domain.dart';
import '../listing_ui_helpers.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    this.now,
  });

  final FarmListing listing;
  final DateTime? now;

  String _productNamesLine() {
    if (listing.products.isEmpty) return '';
    return listing.products
        .map((p) {
          final label =
              products[p.categoryId]?[p.productId] ?? p.productId;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harita açılamadı')),
      );
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
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    final imageUrl =
        listing.imageUrls.isNotEmpty ? listing.imageUrls.first : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.router.push(ListingDetailRoute(listingId: listing.id));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.1,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Icon(Icons.image_not_supported_outlined,
                              size: 48),
                        ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shopping_basket_outlined,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '$pct%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                '${listing.farmName} • ${listing.city}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _productNamesLine(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text(_pickingLabel(),
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(width: 12),
                  if (hours != null)
                    Text(
                      hours,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonal(
                  onPressed: null,
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    backgroundColor: open
                        ? const Color(0xFF2B8C5F).withValues(alpha: 0.2)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Text(
                    open ? 'Açık' : 'Kapalı',
                    style: TextStyle(
                      color: open ? const Color(0xFF2B8C5F) : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 6,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  color: barColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                headline,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton(
                onPressed: () => _openMaps(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Yol tarifi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
