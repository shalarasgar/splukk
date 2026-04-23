import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../listings/domain/listings_domain.dart';
import '../../listings/presentation/listing_ui_helpers.dart';

class MarketplaceController extends GetxController {
  final ListingRepository _repo = Get.find<ListingRepository>();

  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'all'.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(DateTime.now());
  RxList<FarmListing> _allListings = <FarmListing>[].obs;

  /// Возвращает true, если у объявления нет ни одного активного (сегодня или будущего) слота.
  bool _isListingExpired(FarmListing listing) {
    // Нет расписания → считаем истёкшим
    if (listing.schedule.isEmpty) return true;

    // Если есть хотя бы одна запись без конкретной даты (повторяется каждую неделю) → не истекает
    if (listing.schedule.any((s) => s.specificDate == null)) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Есть хотя бы один слот с датой == сегодня или в будущем → не истёк
    final hasFutureOrTodaySlot = listing.schedule.any((s) {
      final slotDate = DateTime(
        s.specificDate!.year,
        s.specificDate!.month,
        s.specificDate!.day,
      );
      return slotDate.isAtSameMomentAs(today) || slotDate.isAfter(today);
    });

    return !hasFutureOrTodaySlot;
  }

  /// Отфильтрованный список объявлений на основе поиска, категории, даты и активности
  List<FarmListing> get filteredListings {
    return _allListings.where((listing) {
      final query = searchQuery.value.toLowerCase();

      // Поиск по названию фермы, городу или продуктам
      final matchesSearch =
          query.isEmpty ||
          listing.farmName.toLowerCase().contains(query) ||
          listing.city.toLowerCase().contains(query) ||
          listing.products.any(
            (p) => p.productId.toLowerCase().contains(query),
          );

      // Фильтрация по категории
      final matchesCategory =
          selectedCategory.value == 'all' ||
          listing.products.any((p) => p.categoryId == selectedCategory.value);

      // Фильтрация по дате (показываем только открытых в этот день)
      final matchesDate =
          selectedDate.value == null ||
          isListingAvailableOnDate(listing, selectedDate.value!);

      final isActive = !_isListingExpired(listing);

      return matchesSearch && matchesCategory && matchesDate && isActive;
    }).toList();
  }

  bool get isLoading => _allListings.isEmpty && searchQuery.isEmpty;

  @override
  void onInit() {
    super.onInit();
    // Привязываем поток данных и фильтруем истекшие объявления
    _allListings.bindStream(
      _repo.watchAllListings().map((listings) {
        return listings
            .where((listing) => !_isListingExpired(listing))
            .toList();
      }),
    );
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void selectCategory(String categoryId) {
    if (selectedCategory.value == categoryId) {
      selectedCategory.value = 'all';
    } else {
      selectedCategory.value = categoryId;
    }
  }

  void updateSelectedDate(DateTime? date) {
    if (selectedDate.value != null &&
        date != null &&
        DateUtils.isSameDay(selectedDate.value, date)) {
      selectedDate.value = null; // Отмена выбора при повторном нажатии
    } else {
      selectedDate.value = date;
    }
  }
}
