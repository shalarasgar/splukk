import 'package:flutter/material.dart';
import 'package:splukk/features/listings/domain/entities/farm_listing.dart';
import 'package:splukk/features/listings/presentation/listing_ui_helpers.dart';

/// Параметры фильтрации объявлений.
class ListingFilterParams {
  const ListingFilterParams({
    this.searchQuery = '',
    this.selectedCategory = 'all',
    this.selectedDate,
  });

  final String searchQuery;
  final String selectedCategory;
  final DateTime? selectedDate;
}

/// Domain UseCase: фильтрация и проверка активности объявлений.
/// Бизнес-логика вынесена из Presentation (MarketplaceCubit).
class FilterListingsUseCase {
  /// Применяет фильтры и возвращает только активные объявления.
  List<FarmListing> call({
    required List<FarmListing> allListings,
    required ListingFilterParams params,
  }) {
    final valid = allListings.where((l) {
      final isExpired = _isExpired(l);
      final hasValidCoords = l.latitude.isFinite && l.longitude.isFinite;
      return !isExpired && hasValidCoords;
    });

    final query = params.searchQuery.toLowerCase();

    return valid.where((listing) {
      final matchesSearch = query.isEmpty ||
          listing.farmName.toLowerCase().contains(query) ||
          listing.city.toLowerCase().contains(query) ||
          listing.products.any(
            (p) => p.productId.toLowerCase().contains(query),
          );

      final matchesCategory = params.selectedCategory == 'all' ||
          listing.products.any((p) => p.categoryId == params.selectedCategory);

      final matchesDate = params.selectedDate == null ||
          isListingAvailableOnDate(listing, params.selectedDate!);

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();
  }

  bool _isExpired(FarmListing listing) {
    if (listing.schedule.isEmpty) return true;
    if (listing.schedule.any((s) => s.specificDate == null)) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return !listing.schedule.any((s) {
      final slotDate = DateTime(
        s.specificDate!.year,
        s.specificDate!.month,
        s.specificDate!.day,
      );
      return DateUtils.isSameDay(slotDate, today) || slotDate.isAfter(today);
    });
  }
}
