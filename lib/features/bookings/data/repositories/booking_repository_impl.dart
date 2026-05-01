import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../booking_remote_datasource.dart';

/// Data-слой: реализация абстрактного BookingRepository.
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._remote);
  final BookingRemoteDataSource _remote;

  @override
  Future<Booking?> getUserBookingForListing({
    required String userUid,
    required String listingId,
  }) =>
      _remote.getUserBookingForListing(
        userUid: userUid,
        listingId: listingId,
      );

  @override
  Future<List<Booking>> getUserBookings({required String userUid}) =>
      _remote.getUserBookings(userUid: userUid);

  @override
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

  @override
  Future<void> updateBooking({
    required Booking existing,
    required int newGuestCount,
  }) =>
      _remote.updateBooking(existing: existing, newGuestCount: newGuestCount);

  @override
  Future<void> cancelBooking({required Booking booking}) =>
      _remote.cancelBooking(booking: booking);
}
