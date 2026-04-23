import '../domain/entities/booking.dart';
import 'booking_remote_datasource.dart';

class BookingRepository {
  BookingRepository(this._remote);
  final BookingRemoteDataSource _remote;

  Future<Booking?> getUserBookingForListing({
    required String userUid,
    required String listingId,
  }) =>
      _remote.getUserBookingForListing(
        userUid: userUid,
        listingId: listingId,
      );

  Future<List<Booking>> getUserBookings({required String userUid}) =>
      _remote.getUserBookings(userUid: userUid);

  Future<void> createBooking({
    required String userUid,
    required String listingId,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
    required int guestCount,
    int? specificDateMs,
  }) =>
      _remote.createBooking(
        userUid: userUid,
        listingId: listingId,
        weekday: weekday,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        guestCount: guestCount,
        specificDateMs: specificDateMs,
      );

  Future<void> updateBooking({
    required Booking existing,
    required int newGuestCount,
  }) =>
      _remote.updateBooking(existing: existing, newGuestCount: newGuestCount);

  Future<void> cancelBooking({required Booking booking}) =>
      _remote.cancelBooking(booking: booking);
}
