import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/products.dart';
import '../../../core/utils/nok_money.dart';
import '../../auth/domain/auth_domain.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../domain/listings_domain.dart';
import 'listing_ui_helpers.dart';

@RoutePage()
class ListingDetailPage extends StatelessWidget {
  const ListingDetailPage({
    super.key,
    required this.listingId,
  });

  final String listingId;

  String _unitLabel(ListingPriceUnit u) {
    switch (u) {
      case ListingPriceUnit.kg:
        return 'kg';
      case ListingPriceUnit.package:
        return 'paket';
    }
  }

  String _pickingLabel(PickingType t) {
    switch (t) {
      case PickingType.selfPicking:
        return 'Kendi toplama';
      case PickingType.prePicked:
        return 'Toplanmış satış';
    }
  }

  Future<void> _openMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<ListingRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan detayı'),
      ),
      body: FutureBuilder<FarmListing?>(
        future: repo.getListing(listingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final listing = snapshot.data;
          if (listing == null) {
            return const Center(child: Text('İlan bulunamadı'));
          }

          final now = DateTime.now();
          final open = isListingOpenNow(listing, now);
          final headline = availabilityHeadlineForListing(listing);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (listing.imageUrls.isNotEmpty)
                  SizedBox(
                    height: 240,
                    child: PageView.builder(
                      itemCount: listing.imageUrls.length,
                      itemBuilder: (context, i) {
                        return Image.network(
                          listing.imageUrls[i],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.farmName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        listing.city,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            open ? Icons.check_circle : Icons.cancel_outlined,
                            color: open ? const Color(0xFF2B8C5F) : null,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(open ? 'Şu an açık' : 'Şu an kapalı'),
                          if (listing.manualClosed) ...[
                            const SizedBox(width: 8),
                            const Text('(Çiftçi manuel kapalı)'),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Müsaitlik: ${listing.availabilityPercent}% — $headline',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(_pickingLabel(listing.pickingType)),
                      const SizedBox(height: 24),
                      Text(
                        'Ürünler ve fiyatlar (NOK)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...listing.products.map(
                        (p) {
                          final name = products[p.categoryId]?[p.productId] ??
                              p.productId;
                          final line =
                              '1 ${_unitLabel(p.unit)} = ${formatOreAsNokKr(p.priceOre)}';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(line),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Çalışma programı',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...listing.schedule.map(
                        (s) {
                          final line =
                              '${weekdayNameTr(s.weekday)} ${formatDayMinutes(s.startMinutes)}–${formatDayMinutes(s.endMinutes)} · Kapasite ${s.maxPeople} · Rezervasyon ${s.bookedCount}';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(line),
                          );
                        },
                      ),
                      if (listing.description != null &&
                          listing.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Açıklama',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(listing.description!.trim()),
                      ],
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () =>
                            _openMaps(listing.latitude, listing.longitude),
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Haritada aç'),
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final role = state.profile?.role;
                          if (role != UserRole.consumer) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Rezervasyon akışı bir sonraki adımda eklenecek.',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Rezervasyon (yakında)'),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
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
