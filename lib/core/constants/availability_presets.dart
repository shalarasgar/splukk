import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../l10n/locale_keys.dart';

// Müsaitlik yüzdesi 0–100; dört bölge. Slider değerine göre metin önerileri.

class AvailabilityBand {
  const AvailabilityBand({
    required this.minInclusive,
    required this.maxInclusive,
    required this.suggestionKeys,
  });

  final int minInclusive;
  final int maxInclusive;
  final List<String> suggestionKeys;

  List<String> getSuggestions(BuildContext context) =>
      suggestionKeys.map((key) => key.tr(context: context)).toList();

  String getDefaultMessage(BuildContext context) => suggestionKeys.isNotEmpty
      ? suggestionKeys.first.tr(context: context)
      : '';
}

const List<AvailabilityBand> availabilityBands = [
  AvailabilityBand(
    minInclusive: 0,
    maxInclusive: 24,
    suggestionKeys: [
      LocaleKeys.availability_low,
      LocaleKeys.availability_low_stock,
      LocaleKeys.availability_low_miss,
    ],
  ),
  AvailabilityBand(
    minInclusive: 25,
    maxInclusive: 49,
    suggestionKeys: [
      LocaleKeys.availability_medium_limited,
      LocaleKeys.availability_medium_plan,
      LocaleKeys.availability_medium_soon,
    ],
  ),
  AvailabilityBand(
    minInclusive: 50,
    maxInclusive: 74,
    suggestionKeys: [
      LocaleKeys.availability_high_good,
      LocaleKeys.availability_high_easy,
      LocaleKeys.availability_high_sufficient,
    ],
  ),
  AvailabilityBand(
    minInclusive: 75,
    maxInclusive: 100,
    suggestionKeys: [
      LocaleKeys.availability_full_abundant,
      LocaleKeys.availability_full_great,
      LocaleKeys.availability_full_pleasant,
    ],
  ),
];

int availabilityBandIndexForPercent(int percent) {
  final p = percent.clamp(0, 100);
  for (var i = 0; i < availabilityBands.length; i++) {
    final b = availabilityBands[i];
    if (p >= b.minInclusive && p <= b.maxInclusive) return i;
  }
  return availabilityBands.length - 1;
}

AvailabilityBand bandForPercent(int percent) =>
    availabilityBands[availabilityBandIndexForPercent(percent)];

String resolvedAvailabilityMessage({
  required int percent,
  int? selectedIndexInBand,
  BuildContext? context,
}) {
  final band = bandForPercent(percent);
  if (band.suggestionKeys.isEmpty) return '';
  final idx = (selectedIndexInBand ?? 0).clamp(
    0,
    band.suggestionKeys.length - 1,
  );
  return band.suggestionKeys[idx].tr(context: context);
}
