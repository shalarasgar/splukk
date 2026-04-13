import 'package:equatable/equatable.dart';

enum PickingType { selfPicking, prePicked }

enum ListingPriceUnit { kg, package }

class ListingProductLine extends Equatable {
  const ListingProductLine({
    required this.categoryId,
    required this.productId,
    required this.priceOre,
    required this.unit,
  });

  final String categoryId;
  final String productId;
  final int priceOre;
  final ListingPriceUnit unit;

  @override
  List<Object?> get props => [categoryId, productId, priceOre, unit];
}

class DayTimeSlot extends Equatable {
  const DayTimeSlot({
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
    required this.maxPeople,
    this.bookedCount = 0,
  });

  /// [DateTime.monday] … [DateTime.sunday] (ISO, Dart default).
  final int weekday;
  final int startMinutes;
  final int endMinutes;
  final int maxPeople;
  final int bookedCount;

  @override
  List<Object?> get props =>
      [weekday, startMinutes, endMinutes, maxPeople, bookedCount];
}

class FarmListing extends Equatable {
  const FarmListing({
    required this.id,
    required this.farmerUid,
    required this.farmName,
    required this.city,
    required this.imageUrls,
    required this.pickingType,
    required this.availabilityPercent,
    this.availabilityMessageIndex,
    required this.manualClosed,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.products,
    required this.schedule,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String farmerUid;
  final String farmName;
  final String city;
  final List<String> imageUrls;
  final PickingType pickingType;
  final int availabilityPercent;
  /// Seçilen öneri indeksi (o bölgedeki [AvailabilityBand.suggestions] listesi içinde).
  final int? availabilityMessageIndex;
  final bool manualClosed;
  final String? description;
  final double latitude;
  final double longitude;
  final List<ListingProductLine> products;
  final List<DayTimeSlot> schedule;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        farmerUid,
        farmName,
        city,
        imageUrls,
        pickingType,
        availabilityPercent,
        availabilityMessageIndex,
        manualClosed,
        description,
        latitude,
        longitude,
        products,
        schedule,
        createdAt,
        updatedAt,
      ];
}
