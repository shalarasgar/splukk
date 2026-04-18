import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../listings/domain/listings_domain.dart';
import '../../listings/presentation/listing_ui_helpers.dart';

import '../../listings/presentation/widgets/listing_card.dart';
import 'marketplace_controller.dart';

class MarketplacePage extends GetView<MarketplaceController> {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Инициализируем контроллер, если он еще не создан
    Get.put(MarketplaceController());

    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenWidth * 0.7;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Динамическая шапка с параллаксом
          SliverAppBar(
            expandedHeight: headerHeight,
            collapsedHeight: 5,
            toolbarHeight: 5,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF2B8C5F),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/4.png', fit: BoxFit.cover),
                  // Градиентное наложение для читаемости текста
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 90,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Çiftliğini bul',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Taze ve doğal ürünler kapınızda',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Кастомный поиск в "bottom" (будет прилипать к верху)
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: _SearchHeader(headerHeight: headerHeight),
            ),
          ),

          // 2. Горизонтальные категории
          SliverToBoxAdapter(child: _CategoryList()),

          // 3. Планирование даты
          SliverToBoxAdapter(child: _DateSelector()),

          // 4. Список объявлений
          Obx(() {
            final list = controller.filteredListings;

            if (controller.isLoading) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2B8C5F)),
                ),
              );
            }

            if (list.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Sonuç bulunamadı',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return ListingCard(
                    listing: list[index],
                    now: controller.selectedDate.value,
                  );
                }, childCount: list.length),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final double headerHeight;
  const _SearchHeader({required this.headerHeight});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MarketplaceController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: TextField(
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Çiftlik, ürün, meyve ara...',
                hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2B8C5F)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MarketplaceController>();

    final categories = [
      {'id': 'all', 'label': 'Tümü', 'icon': LucideIcons.layoutGrid},
      {'id': 'berries', 'label': 'Orman meyveleri', 'icon': LucideIcons.cherry},
      {'id': 'fruits', 'label': 'Meyveler', 'icon': LucideIcons.apple},
      {'id': 'vegetables', 'label': 'Sebzeler', 'icon': LucideIcons.carrot},
      {'id': 'herbs', 'label': 'Yeşillikler', 'icon': LucideIcons.leaf},
      {'id': 'flowers', 'label': 'Çiçekler', 'icon': LucideIcons.flower},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == cat['id'];
            return GestureDetector(
              onTap: () => controller.selectCategory(cat['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2B8C5F) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey[200]!,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2B8C5F).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 20,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _DateSelector extends GetView<MarketplaceController> {
  const _DateSelector();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Генерируем список дат на ближайшие 2 недели
    final dates = List.generate(14, (i) => today.add(Duration(days: i)));

    return Container(
      height: 85,
      // color: Colors.grey,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Ziyaret Planla',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: dates.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Obx(() {
                    final isSelected = controller.selectedDate.value == null;
                    return GestureDetector(
                      onTap: () => controller.updateSelectedDate(null),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2B8C5F) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Colors.grey[200]!,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2B8C5F).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Tümü',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    );
                  });
                }

                final date = dates[index - 1];
                return Obx(() {
                  final isSelected = DateUtils.isSameDay(
                    date,
                    controller.selectedDate.value,
                  );

                  return GestureDetector(
                    onTap: () => controller.updateSelectedDate(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2B8C5F) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.grey[200]!,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2B8C5F).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _weekdayAbbr(date.weekday),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey[500],
                            ),
                          ),
                          Text(
                            '${date.day}',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayAbbr(int wd) {
    switch (wd) {
      case DateTime.monday:
        return 'Pzt';
      case DateTime.tuesday:
        return 'Sal';
      case DateTime.wednesday:
        return 'Çrş';
      case DateTime.thursday:
        return 'Prş';
      case DateTime.friday:
        return 'Cum';
      case DateTime.saturday:
        return 'Cmt';
      case DateTime.sunday:
        return 'Paz';
      default:
        return '';
    }
  }
}
