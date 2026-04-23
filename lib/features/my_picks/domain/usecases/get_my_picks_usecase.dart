import 'package:splukk/features/bookings/data/booking_repository.dart';
import 'package:splukk/features/listings/domain/repositories/listing_repository.dart';

import '../entities/my_pick_item.dart';

class GetMyPicksUseCase {
  GetMyPicksUseCase({
    required this.bookingRepository,
    required this.listingRepository,
  });

  final BookingRepository bookingRepository;
  final ListingRepository listingRepository;

  Future<List<MyPickItem>> call(String userUid) async {
    final bookings = await bookingRepository.getUserBookings(userUid: userUid);

    final List<MyPickItem> items = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final booking in bookings) {
      final listing = await listingRepository.getListing(booking.listingId);
      if (listing == null) continue; // Skip if listing is deleted

      DateTime bookingDate;
      if (booking.specificDateMs != null) {
        bookingDate = DateTime.fromMillisecondsSinceEpoch(
          booking.specificDateMs!,
        );
      } else {
        // If it's a recurring weekday, we try to find the next occurrence or use createdAt as a fallback.
        // For simplicity, let's treat recurring without specific date as upcoming if it's generally active.
        // But usually splukk has specificDateMs. Let's just use a default or calculate next weekday.
        bookingDate = _getNextWeekday(booking.weekday);
      }

      final dateOnly = DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
      );
      final isUpcoming =
          dateOnly.isAfter(today) || dateOnly.isAtSameMomentAs(today);

      items.add(
        MyPickItem(
          booking: booking,
          listing: listing,
          isUpcoming: isUpcoming,
          bookingDate: bookingDate,
        ),
      );
    }

    // Sort: Upcoming first, then past.
    // Within upcoming: closest date first.
    // Within past: most recent first.
    items.sort((a, b) {
      if (a.isUpcoming && !b.isUpcoming) return -1;
      if (!a.isUpcoming && b.isUpcoming) return 1;

      if (a.isUpcoming) {
        return a.bookingDate.compareTo(b.bookingDate);
      } else {
        return b.bookingDate.compareTo(a.bookingDate);
      }
    });

    return items;
  }

  DateTime _getNextWeekday(int weekday) {
    final now = DateTime.now();
    int daysToAdd = (weekday - now.weekday) % 7;
    if (daysToAdd < 0) daysToAdd += 7;
    return now.add(Duration(days: daysToAdd));
  }
}
