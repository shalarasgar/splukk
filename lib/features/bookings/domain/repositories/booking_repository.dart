import '../entities/booking.dart';

/// Domain-слой: абстракция для работы с бронированиями.
/// Presentation и UseCases зависят только от этого интерфейса, а не от реализации.
abstract class BookingRepository {
  Future<Booking?> getUserBookingForListing({
    required String userUid,
    required String listingId,
  });

  Future<List<Booking>> getUserBookings({required String userUid});

  Future<void> createBooking({
    required String userUid,
    required String listingId,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
    required int guestCount,
    int? specificDateMs,
  });

  Future<void> updateBooking({
    required Booking existing,
    required int newGuestCount,
  });

  Future<void> cancelBooking({required Booking booking});
}
