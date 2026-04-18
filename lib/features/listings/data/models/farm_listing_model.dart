import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/listings_domain.dart';

class FarmListingModel {
  static FarmListing fromFirestore(String id, Map<String, dynamic> data) {
    return FarmListing(
      id: id,
      farmerUid: data['farmerUid'] as String? ?? '',
      farmName: data['farmName'] as String? ?? '',
      city: data['city'] as String? ?? '',
      imageUrls: _readStringList(data['imageUrls']),
      pickingType: _readPickingType(data['pickingType']),
      availabilityPercent: _readInt(data['availabilityPercent']) ?? 0,
      availabilityMessageIndex: _readInt(data['availabilityMessageIndex']),
      manualClosed: data['manualClosed'] as bool? ?? false,
      description: data['description'] as String?,
      latitude: _readDouble(data['latitude']) ?? 0,
      longitude: _readDouble(data['longitude']) ?? 0,
      products: _readProducts(data['products']),
      schedule: _readSchedule(data['schedule']),
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDate(data['updatedAt']),
    );
  }

  static Map<String, dynamic> toFirestoreMap({
    required String farmerUid,
    required String farmName,
    required String city,
    required List<String> imageUrls,
    required PickingType pickingType,
    required int availabilityPercent,
    int? availabilityMessageIndex,
    required bool manualClosed,
    String? description,
    required double latitude,
    required double longitude,
    required List<ListingProductLine> products,
    required List<DayTimeSlot> schedule,
    required FieldValue timestamp,
  }) {
    return {
      'farmerUid': farmerUid,
      'farmName': farmName.trim(),
      'city': city.trim(),
      'imageUrls': imageUrls,
      'pickingType': pickingType.name,
      'availabilityPercent': availabilityPercent.clamp(0, 100),
      'availabilityMessageIndex': availabilityMessageIndex,
      'manualClosed': manualClosed,
      'description': description?.trim().isEmpty == true ? null : description?.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'products': products
          .map(
            (e) => {
              'categoryId': e.categoryId,
              'productId': e.productId,
              'priceOre': e.priceOre,
              'unit': e.unit.name,
            },
          )
          .toList(),
      'schedule': schedule
          .map(
            (e) => {
              'weekday': e.weekday,
              'startMinutes': e.startMinutes,
              'endMinutes': e.endMinutes,
              'maxPeople': e.maxPeople,
              'bookedCount': e.bookedCount,
              if (e.specificDate != null) 'specificDate': e.specificDate!.millisecondsSinceEpoch,
            },
          )
          .toList(),
      'updatedAt': timestamp,
    };
  }

  static List<String> _readStringList(dynamic v) {
    if (v is! List) return [];
    return v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
  }

  static PickingType _readPickingType(dynamic v) {
    final s = v as String?;
    return PickingType.values.firstWhere(
      (e) => e.name == s,
      orElse: () => PickingType.selfPicking,
    );
  }

  static int? _readInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  static double? _readDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return null;
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static List<ListingProductLine> _readProducts(dynamic v) {
    if (v is! List) return [];
    final out = <ListingProductLine>[];
    for (final item in v) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final cat = map['categoryId'] as String? ?? '';
      final pid = map['productId'] as String? ?? '';
      final ore = _readInt(map['priceOre']) ?? 0;
      final unitStr = map['unit'] as String?;
      final unit = ListingPriceUnit.values.firstWhere(
        (u) => u.name == unitStr,
        orElse: () => ListingPriceUnit.kg,
      );
      if (cat.isEmpty || pid.isEmpty) continue;
      out.add(
        ListingProductLine(
          categoryId: cat,
          productId: pid,
          priceOre: ore,
          unit: unit,
        ),
      );
    }
    return out;
  }

  static List<DayTimeSlot> _readSchedule(dynamic v) {
    if (v is! List) return [];
    final out = <DayTimeSlot>[];
    for (final item in v) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final wd = _readInt(map['weekday']);
      final sm = _readInt(map['startMinutes']);
      final em = _readInt(map['endMinutes']);
      final cap = _readInt(map['maxPeople']);
      final booked = _readInt(map['bookedCount']) ?? 0;
      final specificDateMs = _readInt(map['specificDate']);
      final specificDate = specificDateMs != null
          ? DateTime.fromMillisecondsSinceEpoch(specificDateMs)
          : null;
      if (wd == null || sm == null || em == null || cap == null) continue;
      out.add(
        DayTimeSlot(
          weekday: wd,
          startMinutes: sm,
          endMinutes: em,
          maxPeople: cap,
          bookedCount: booked,
          specificDate: specificDate,
        ),
      );
    }
    return out;
  }
}
