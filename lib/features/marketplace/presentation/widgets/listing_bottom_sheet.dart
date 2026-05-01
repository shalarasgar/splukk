import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../listings/domain/listings_domain.dart';
import '../../../listings/presentation/widgets/listing_card.dart';
import '../marketplace_cubit.dart';
import '../marketplace_state.dart';

class ListingBottomSheet extends StatefulWidget {
  final ScrollController? scrollController;
  const ListingBottomSheet({super.key, this.scrollController});

  @override
  State<ListingBottomSheet> createState() => _ListingBottomSheetState();
}

class _ListingBottomSheetState extends State<ListingBottomSheet> {
  FarmListing? _previousListing;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketplaceCubit, MarketplaceState>(
      builder: (context, state) {
        final listing = state.selectedListing;

        // Auto-scroll when a new listing is selected
        if (listing != null &&
            listing != _previousListing &&
            widget.scrollController != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.scrollController!.animateTo(
              widget.scrollController!.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          });
          _previousListing = listing;
        } else if (listing == null) {
          _previousListing = null;
        }

        if (listing == null) return const SizedBox.shrink();

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle для drag
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // ListingCard
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListingCard(listing: listing, now: state.selectedDate),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
