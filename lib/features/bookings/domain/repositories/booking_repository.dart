import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';

/// Domain-слой: абстракция для работы с бронированиями.
/// Presentation и UseCases зависят только от этого интерфейса, а не от реализации.
abstract class BookingRepository {
  Future<Either<Failure, Booking?>> getUserBookingForListing({
    required String userUid,
    required String listingId,
  });

  Future<Either<Failure, List<Booking>>> getUserBookings({required String userUid});

  Future<Either<Failure, void>> createBooking({
    required String userUid,
    required String listingId,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
    required int guestCount,
    int? specificDateMs,
  });

  Future<Either<Failure, void>> updateBooking({
    required Booking existing,
    required int newGuestCount,
  });

  Future<Either<Failure, void>> cancelBooking({required Booking booking});
}
