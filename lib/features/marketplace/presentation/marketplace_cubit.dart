import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../listings/domain/listings_domain.dart';
import '../../listings/presentation/listing_ui_helpers.dart';
import '../domain/usecases/filter_listings_usecase.dart';
import 'marketplace_state.dart';

class MarketplaceCubit extends Cubit<MarketplaceState> {
  final ListingRepository _repo;
  final FilterListingsUseCase _filterUseCase;
  StreamSubscription<List<FarmListing>>? _subscription;

  MarketplaceCubit({
    required ListingRepository repo,
    required FilterListingsUseCase filterUseCase,
  })  : _repo = repo,
        _filterUseCase = filterUseCase,
      super(MarketplaceState(selectedDate: DateTime.now())) {
    _init();
  }

  void _init() {
    emit(state.copyWith(isLoading: true));
    _subscription = _repo.watchAllListings().listen((listings) {
      // FilterListingsUseCase will handle both expiration and invalid coordinates
      // when we call _applyFilters, but here we just store raw valid listings if needed,
      // or we can just store allListings and let _applyFilters do everything.
      emit(state.copyWith(allListings: listings, isLoading: false));
      _applyFilters();
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void selectCategory(String categoryId) {
    if (state.selectedCategory == categoryId) {
      emit(state.copyWith(selectedCategory: 'all'));
    } else {
      emit(state.copyWith(selectedCategory: categoryId));
    }
    _applyFilters();
  }

  void updateSelectedDate(DateTime? date) {
    if (date == null) {
      emit(state.copyWith(clearDate: true));
    } else if (state.selectedDate != null &&
        DateUtils.isSameDay(state.selectedDate, date)) {
      emit(state.copyWith(clearDate: true));
    } else {
      emit(state.copyWith(selectedDate: date));
    }
    _applyFilters();
  }

  void toggleMapView() {
    emit(state.copyWith(isMapView: !state.isMapView));
  }

  void selectListing(FarmListing? listing) {
    emit(state.copyWith(selectedListing: listing));
  }

  void toggleListingSelection(FarmListing listing) {
    if (state.selectedListing?.id == listing.id) {
      clearSelection();
    } else {
      selectListing(listing);
    }
  }

  void clearSelection() {
    emit(state.copyWith(clearSelectedListing: true));
  }

  void _applyFilters() {
    final filtered = _filterUseCase(
      allListings: state.allListings,
      params: ListingFilterParams(
        searchQuery: state.searchQuery,
        selectedCategory: state.selectedCategory,
        selectedDate: state.selectedDate,
      ),
    );
    emit(state.copyWith(filteredListings: filtered));
  }
}
