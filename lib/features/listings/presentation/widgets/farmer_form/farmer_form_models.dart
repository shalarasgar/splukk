import 'package:flutter/material.dart';
import '../../../domain/listings_domain.dart';

class ProductLineDraft {
  ProductLineDraft({
    required this.categoryId,
    required this.productId,
    required this.priceController,
    required this.unit,
  });

  String categoryId;
  String productId;
  final TextEditingController priceController;
  ListingPriceUnit unit;
}

class ScheduleDraft {
  ScheduleDraft({
    required this.weekday,
    required this.start,
    required this.end,
    required this.capacityController,
    this.calendarAnchor,
  });

  int weekday;

  /// Takvimden seçilen tarih (yalnızca form gösterimi; kayıtta yine haftanın günü kullanılır).
  DateTime? calendarAnchor;
  TimeOfDay start;
  TimeOfDay end;
  final TextEditingController capacityController;
}
