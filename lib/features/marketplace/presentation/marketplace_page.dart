import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../listings/domain/listings_domain.dart';
import '../../listings/presentation/widgets/listing_card.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<ListingRepository>();
    final screenWidth = MediaQuery.of(context).size.width;
    final backgroundPictureHeight = screenWidth * .75;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey,
              width: double.infinity,
              height: backgroundPictureHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      child: Image.asset(
                        fit: BoxFit.cover,
                        // 'assets/1.jpg'
                        'assets/2.png',
                        // 'assets/3.png'
                        // 'assets/4.png'
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 85,
                    left: 20,
                    right: 20,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentGeometry.centerLeft,
                      child: Text(
                        'Çiftliğini bul',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(152, 0, 0, 0),
                              fontSize: (screenWidth * .08).clamp(22.0, 32.0),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  //Textfield
                  Positioned(
                    bottom: 20,
                    right: 20,
                    left: 20,
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(5),
                        hintText: 'Çiftlik, ürün, meyve ara…',
                        hintStyle: TextStyle(
                          fontSize: (screenWidth * .08).clamp(12.0, 22.0),
                        ),
                        suffixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
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
                  ),
                  //icon
                  Positioned(
                    top: backgroundPictureHeight / 4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        // color: Colors.grey,
                        // height: 70,
                        // width: 200,
                        child: Image.asset(
                          fit: BoxFit.contain,
                          'assets/icon.png',
                          width: 200,
                          color: const Color.fromARGB(188, 5, 82, 7),
                          // colorBlendMode: BlendMode.color,
                        ),
                      ),
                    ),
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return ListingCard(listing: list[index]);
                  }, childCount: list.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
