import 'package:equatable/equatable.dart';
import '../../listings/domain/listings_domain.dart';

class MarketplaceState extends Equatable {
  final List<FarmListing> allListings;
  final List<FarmListing> filteredListings;
  final String searchQuery;
  final String selectedCategory;
  final DateTime? selectedDate;
  final bool isLoading;
  final bool isMapView;
  final FarmListing? selectedListing;

  const MarketplaceState({
    this.allListings = const [],
    this.filteredListings = const [],
    this.searchQuery = '',
    this.selectedCategory = 'all',
    this.selectedDate,
    this.isLoading = true,
    this.isMapView = false,
    this.selectedListing,
  });

  MarketplaceState copyWith({
    List<FarmListing>? allListings,
    List<FarmListing>? filteredListings,
    String? searchQuery,
    String? selectedCategory,
    DateTime? selectedDate,
    bool? isLoading,
    bool? isMapView,
    FarmListing? selectedListing,
    bool clearDate = false,
    bool clearSelectedListing = false,
  }) {
    return MarketplaceState(
      allListings: allListings ?? this.allListings,
      filteredListings: filteredListings ?? this.filteredListings,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
      isLoading: isLoading ?? this.isLoading,
      isMapView: isMapView ?? this.isMapView,
      selectedListing: clearSelectedListing ? null : (selectedListing ?? this.selectedListing),
    );
  }

  @override
  List<Object?> get props => [
    allListings,
    filteredListings,
    searchQuery,
    selectedCategory,
    selectedDate,
    isLoading,
    isMapView,
    selectedListing,
  ];
}
