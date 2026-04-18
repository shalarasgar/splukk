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

/// Belirli bir tarih için bu ilanın programından özet aralık (yoksa null).
String? todayHoursSummary(FarmListing listing, DateTime now) {
  final dateOnly = DateTime(now.year, now.month, now.day);
  
  // 1. Önce bu tarih için özel bir slot var mı bak
  var slots = listing.schedule
      .where((s) => s.specificDate != null && 
                    DateTime(s.specificDate!.year, s.specificDate!.month, s.specificDate!.day) == dateOnly)
      .toList();
  
  // 2. Yoksa normal hafta içi programına bak
  if (slots.isEmpty) {
    slots = listing.schedule.where((s) => s.weekday == now.weekday && s.specificDate == null).toList();
  }

  if (slots.isEmpty) return null;

  slots.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  final start = slots.first.startMinutes;
  final end = slots.map((s) => s.endMinutes).reduce((a, b) => a > b ? a : b);
  return '${formatDayMinutes(start)} – ${formatDayMinutes(end)}';
}

bool isListingOpenNow(FarmListing listing, DateTime now) {
  if (listing.manualClosed) return false;
  
  final dateOnly = DateTime(now.year, now.month, now.day);
  final minutes = now.hour * 60 + now.minute;

  // 1. Önce özel tarih slotlarına bak
  final specificSlots = listing.schedule.where((s) => 
    s.specificDate != null && 
    DateTime(s.specificDate!.year, s.specificDate!.month, s.specificDate!.day) == dateOnly
  );

  if (specificSlots.isNotEmpty) {
    for (final s in specificSlots) {
      if (minutes >= s.startMinutes && minutes < s.endMinutes) return true;
    }
    return false;
  }

  // 2. Yoksa normal hafta içi programına bak
  for (final s in listing.schedule) {
    if (s.specificDate != null) continue; // Özel tarihli slotları atla
    if (s.weekday != now.weekday) continue;
    if (minutes >= s.startMinutes && minutes < s.endMinutes) return true;
  }
  return false;
}

bool isListingAvailableOnDate(FarmListing listing, DateTime date) {
  if (listing.manualClosed) return false;
  final dateOnly = DateTime(date.year, date.month, date.day);

  // Özel tarih var mı?
  final hasSpecific = listing.schedule.any((s) => 
    s.specificDate != null && 
    DateTime(s.specificDate!.year, s.specificDate!.month, s.specificDate!.day) == dateOnly
  );
  if (hasSpecific) return true;

  // Normal hafta içi programı var mı?
  return listing.schedule.any((s) => s.specificDate == null && s.weekday == date.weekday);
}

String availabilityHeadlineForListing(FarmListing listing) {
  return resolvedAvailabilityMessage(
    percent: listing.availabilityPercent,
    selectedIndexInBand: listing.availabilityMessageIndex,
  );
}

int bandIndexForListing(FarmListing listing) =>
    availabilityBandIndexForPercent(listing.availabilityPercent);

String monthNameTr(int month) {
  switch (month) {
    case 1: return 'Ock';
    case 2: return 'Şub';
    case 3: return 'Mar';
    case 4: return 'Nis';
    case 5: return 'May';
    case 6: return 'Haz';
    case 7: return 'Tem';
    case 8: return 'Ağu';
    case 9: return 'Eyl';
    case 10: return 'Eki';
    case 11: return 'Kas';
    case 12: return 'Ara';
    default: return '';
  }
}

DateTime getListingNextAvailableDate(FarmListing listing, DateTime from) {
  if (listing.manualClosed) return from;

  final startFrom = DateTime(from.year, from.month, from.day);
  
  // Мы ищем на ближайшие 2 недели
  for (int i = 0; i < 14; i++) {
    final candidate = startFrom.add(Duration(days: i));
    if (isListingAvailableOnDate(listing, candidate)) {
      return candidate;
    }
  }

  // Если ничего не нашли, возвращаем исходную дату
  return from;
}

