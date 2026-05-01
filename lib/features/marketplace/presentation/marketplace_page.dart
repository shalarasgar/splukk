import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:splukk/core/utils/exit_dialog.dart';
import 'package:splukk/features/listings/presentation/widgets/listing_card.dart';
import 'package:splukk/features/marketplace/presentation/marketplace_cubit.dart';
import 'package:splukk/features/marketplace/presentation/marketplace_state.dart';
import 'package:splukk/features/shell/presentation/main_shell_page.dart';

import '../../../core/di/dependencies.dart';

import 'widgets/category_list.dart';
import 'widgets/date_selector.dart';
import 'widgets/listing_bottom_sheet.dart';
import 'widgets/marketplace_map_widget.dart';
import 'widgets/search_header.dart';

@RoutePage()
class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MarketplaceCubit>(),
      child: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final headerHeight = screenWidth * 0.7;

          final isActive = ActiveTabProvider.of(context) == 0;
          
          return PopScope(
            canPop: !isActive,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop || !isActive) return;

              final cubit = context.read<MarketplaceCubit>();
              if (cubit.state.selectedListing != null) {
                // Если выбран маркер — сбрасываем выбор (вложенная навигация)
                cubit.clearSelection();
              } else {
                // Если ничего не выбрано — спрашиваем о выходе
                final shouldExit = await showExitConfirmationDialog(context);
                if (shouldExit && context.mounted) {
                  SystemNavigator.pop();
                }
              }
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFFBFBFB),
              body: CustomScrollView(
                controller: _scrollController,
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
                      preferredSize: const Size.fromHeight(85),
                      child: SearchHeader(headerHeight: headerHeight),
                    ),
                  ),

                  // 2. Горизонтальные категории
                  const SliverToBoxAdapter(child: CategoryList()),

                  // 3. Планирование даты
                  const SliverToBoxAdapter(child: DateSelector()),

                  // 4. Список объявлений или Карта
                  BlocBuilder<MarketplaceCubit, MarketplaceState>(
                    builder: (context, state) {
                      if (state.isMapView) {
                        return SliverToBoxAdapter(
                          child: Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 510,
                                child: const MarketplaceMapWidget(),
                              ),
                              ListingBottomSheet(
                                scrollController: _scrollController,
                              ),
                            ],
                          ),
                        );
                      }

                      final list = state.filteredListings;

                      // Отладочный лог: проверяем все координаты
                      for (var elements in list) {
                        final isLatOk = elements.latitude.isFinite;
                        final isLngOk = elements.longitude.isFinite;
                        log(
                          'Farm: ${elements.farmName} | City: ${elements.city} | Lat: ${elements.latitude} (Ok: $isLatOk) | Lng: ${elements.longitude} (Ok: $isLngOk)',
                        );
                      }

                      if (state.isLoading) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2B8C5F),
                            ),
                          ),
                        );
                      }

                      if (list.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return ListingCard(
                              listing: list[index],
                              now: state.selectedDate,
                            );
                          }, childCount: list.length),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
