import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:splukk/features/marketplace/presentation/marketplace_state.dart';
import '../marketplace_cubit.dart';

class SearchHeader extends StatelessWidget {
  final double headerHeight;
  const SearchHeader({super.key, required this.headerHeight});

  @override
  Widget build(BuildContext context) {
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    onChanged: context.read<MarketplaceCubit>().updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Çiftlik, ürün, meyve ara...',
                      hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF2B8C5F)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.read<MarketplaceCubit>().toggleMapView();
                  },
                  icon: BlocBuilder<MarketplaceCubit, MarketplaceState>(
                    builder: (context, state) {
                      return Icon(
                        state.isMapView ? LucideIcons.list : LucideIcons.map,
                        color: const Color(0xFF2B8C5F),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
