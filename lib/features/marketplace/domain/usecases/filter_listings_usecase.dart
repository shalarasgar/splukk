import 'package:splukk/features/listings/domain/entities/farm_listing.dart';

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
/// Зависит только от Domain — нет импортов Flutter или Presentation.
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
          _isAvailableOnDate(listing, params.selectedDate!);

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
      return _isSameDay(slotDate, today) || slotDate.isAfter(today);
    });
  }

  /// Проверяет доступность объявления на указанную дату.
  /// Чистая Dart-функция, без зависимости от Flutter или Presentation.
  bool _isAvailableOnDate(FarmListing listing, DateTime date) {
    if (listing.manualClosed) return false;
    final dateOnly = DateTime(date.year, date.month, date.day);

    // Ищем слот с конкретной датой
    final hasSpecific = listing.schedule.any((s) =>
        s.specificDate != null &&
        _isSameDay(
          DateTime(s.specificDate!.year, s.specificDate!.month, s.specificDate!.day),
          dateOnly,
        ));
    if (hasSpecific) return true;

    // Ищем слот по дню недели
    return listing.schedule.any(
      (s) => s.specificDate == null && s.weekday == date.weekday,
    );
  }

  /// Сравнивает даты без учёта времени. Заменяет Flutter-зависимый DateUtils.isSameDay.
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
