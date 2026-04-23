import 'package:get/get.dart';
import '../../listings/domain/listings_domain.dart';
import '../../listings/presentation/listing_ui_helpers.dart';

class MarketplaceController extends GetxController {
  final ListingRepository _repo = Get.find<ListingRepository>();

  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'all'.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(DateTime.now());
  final RxList<FarmListing> _allListings = <FarmListing>[].obs;

  bool _isListingExpired(FarmListing listing) {
    if (listing.schedule.isEmpty) return true;

    // Если есть хотя бы одно расписание без specificDate (т.е. постоянное каждую неделю),
    // оно не истекает
    if (listing.schedule.any((s) => s.specificDate == null)) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Проверяем, есть ли в расписании хотя бы один день, который равен или больше сегодняшнего
    final hasFutureOrTodaySlots = listing.schedule.any((s) {
      if (s.specificDate == null) return true;
      final slotDate = DateTime(
        s.specificDate!.year,
        s.specificDate!.month,
        s.specificDate!.day,
      );
      return slotDate.isAfter(today) || slotDate.isAtSameMomentAs(today);
    });
    // Если будущих слотов нет, значит объявление полностью истекло
    return !hasFutureOrTodaySlots;
  }

  /// Отфильтрованный список объявлений на основе поиска и выбранной категории
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

  bool get isLoading =>
      _allListings.isEmpty &&
      searchQuery.isEmpty; // Упрощенное состояние загрузки

  @override
  void onInit() {
    super.onInit();
    // Привязываем поток данных из репозитория к нашему списку
    _allListings.bindStream(_repo.watchAllListings());
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void selectCategory(String categoryId) {
    if (selectedCategory.value == categoryId) {
      selectedCategory.value = 'all'; // Сброс при повторном нажатии
    } else {
      selectedCategory.value = categoryId;
    }
  }

  void updateSelectedDate(DateTime? date) {
    if (selectedDate.value == date) {
      selectedDate.value =
          null; // Toggles off if same date clicked? Or maybe user just wants a "Tümü" button.
    } else {
      selectedDate.value = date;
    }
  }
}
