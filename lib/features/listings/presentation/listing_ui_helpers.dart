import '../../../core/constants/availability_presets.dart';
import '../domain/listings_domain.dart';

String weekdayNameTr(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Pazartesi';
    case DateTime.tuesday:
      return 'Salı';
    case DateTime.wednesday:
      return 'Çarşamba';
    case DateTime.thursday:
      return 'Perşembe';
    case DateTime.friday:
      return 'Cuma';
    case DateTime.saturday:
      return 'Cumartesi';
    case DateTime.sunday:
      return 'Pazar';
    default:
      return '';
  }
}

String formatDayMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

/// Bugün için bu ilanın programından özet aralık (yoksa null).
String? todayHoursSummary(FarmListing listing, DateTime now) {
  final wd = now.weekday;
  final slots =
      listing.schedule.where((s) => s.weekday == wd).toList()..sort(
            (a, b) => a.startMinutes.compareTo(b.startMinutes),
          );
  if (slots.isEmpty) return null;
  final start = slots.first.startMinutes;
  final end = slots.map((s) => s.endMinutes).reduce((a, b) => a > b ? a : b);
  return '${formatDayMinutes(start)} – ${formatDayMinutes(end)}';
}

bool isListingOpenNow(FarmListing listing, DateTime now) {
  if (listing.manualClosed) return false;
  final wd = now.weekday;
  final minutes = now.hour * 60 + now.minute;
  for (final s in listing.schedule) {
    if (s.weekday != wd) continue;
    if (minutes >= s.startMinutes && minutes < s.endMinutes) return true;
  }
  return false;
}

String availabilityHeadlineForListing(FarmListing listing) {
  return resolvedAvailabilityMessage(
    percent: listing.availabilityPercent,
    selectedIndexInBand: listing.availabilityMessageIndex,
  );
}

int bandIndexForListing(FarmListing listing) =>
    availabilityBandIndexForPercent(listing.availabilityPercent);
