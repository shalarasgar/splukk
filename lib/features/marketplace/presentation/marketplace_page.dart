import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../listings/domain/listings_domain.dart';
import '../../listings/presentation/widgets/listing_card.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<ListingRepository>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Çiftliğini bul',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Çiftlik, ürün, meyve ara…',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        filled: true,
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Arama yakında eklenecek.'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder<List<FarmListing>>(
              stream: repo.watchAllListings(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'İlanlar yüklenemedi.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final list = snapshot.data!;
                if (list.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('Henüz ilan yok. Çiftçi panelinden ekleyin.'),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ListingCard(listing: list[index]);
  },
                      childCount: list.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
