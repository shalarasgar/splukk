import 'package:splukk/features/bookings/domain/repositories/booking_repository.dart';
import 'package:splukk/features/listings/domain/repositories/listing_repository.dart';

import '../entities/my_pick_item.dart';

/// Domain UseCase: получить список бронирований текущего пользователя.
/// Зависит ТОЛЬКО от Domain-интерфейсов (BookingRepository, ListingRepository).
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
      if (listing == null) continue;

      DateTime bookingDate;
      if (booking.specificDateMs != null) {
        bookingDate = DateTime.fromMillisecondsSinceEpoch(
          booking.specificDateMs!,
        );
      } else {
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
