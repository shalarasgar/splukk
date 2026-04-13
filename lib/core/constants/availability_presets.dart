// Müsaitlik yüzdesi 0–100; dört bölge. Slider değerine göre metin önerileri.

class AvailabilityBand {
  const AvailabilityBand({
    required this.minInclusive,
    required this.maxInclusive,
    required this.suggestions,
  });

  final int minInclusive;
  final int maxInclusive;
  final List<String> suggestions;

  String get defaultMessage =>
      suggestions.isNotEmpty ? suggestions.first : '';
}

const List<AvailabilityBand> availabilityBands = [
  AvailabilityBand(
    minInclusive: 0,
    maxInclusive: 24,
    suggestions: [
      'Çok az kaldı, acele edin!',
      'Son ürünler, stok kritik seviyede',
      'Az kaldı — kaçırmayın',
    ],
  ),
  AvailabilityBand(
    minInclusive: 25,
    maxInclusive: 49,
    suggestions: [
      'Sınırlı stok, erken gelin',
      'Müsaitlik orta — planlı gelmek iyi olur',
      'Hâlâ mevcut ama bitmek üzere',
    ],
  ),
  AvailabilityBand(
    minInclusive: 50,
    maxInclusive: 74,
    suggestions: [
      'İyi müsaitlik',
      'Rahat seçebilirsiniz',
      'Stok yeterli görünüyor',
    ],
  ),
  AvailabilityBand(
    minInclusive: 75,
    maxInclusive: 100,
    suggestions: [
      'Bol müsaitlik',
      'Harika stok — dilediğiniz zaman',
      'Ürün bol, keyifli toplama',
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
}) {
  final band = bandForPercent(percent);
  if (band.suggestions.isEmpty) return '';
  final idx = (selectedIndexInBand ?? 0).clamp(0, band.suggestions.length - 1);
  return band.suggestions[idx];
}
