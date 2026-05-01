import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../marketplace_cubit.dart';
import '../marketplace_state.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
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
          return BlocBuilder<MarketplaceCubit, MarketplaceState>(
            builder: (context, state) {
              final isSelected = state.selectedCategory == cat['id'];
              return GestureDetector(
                onTap: () => context.read<MarketplaceCubit>().selectCategory(
                  cat['id'] as String,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2B8C5F) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey[200]!,
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
            },
          );
        },
      ),
    );
  }
}
