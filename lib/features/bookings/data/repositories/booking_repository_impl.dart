import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../booking_remote_datasource.dart';

/// Data-слой: реализация абстрактного BookingRepository.
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._remote);
  final BookingRemoteDataSource _remote;

  @override
  Future<Either<Failure, Booking?>> getUserBookingForListing({
    required String userUid,
    required String listingId,
  }) async {
    try {
      final res = await _remote.getUserBookingForListing(
        userUid: userUid,
        listingId: listingId,
      );
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getUserBookings({required String userUid}) async {
    try {
      final res = await _remote.getUserBookings(userUid: userUid);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createBooking({
    required String userUid,
    required String listingId,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
    required int guestCount,
    int? specificDateMs,
  }) async {
    try {
      await _remote.createBooking(
        userUid: userUid,
        listingId: listingId,
        weekday: weekday,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        guestCount: guestCount,
        specificDateMs: specificDateMs,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBooking({
    required Booking existing,
    required int newGuestCount,
  }) async {
    try {
      await _remote.updateBooking(existing: existing, newGuestCount: newGuestCount);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking({required Booking booking}) async {
    try {
      await _remote.cancelBooking(booking: booking);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
