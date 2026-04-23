import 'package:equatable/equatable.dart';
import 'package:splukk/features/bookings/domain/entities/booking.dart';
import 'package:splukk/features/listings/domain/entities/farm_listing.dart';

class MyPickItem extends Equatable {
  const MyPickItem({
    required this.booking,
    required this.listing,
    required this.isUpcoming,
    required this.bookingDate,
  });

  final Booking booking;
  final FarmListing listing;
  final bool isUpcoming;
  final DateTime bookingDate;

  @override
  List<Object?> get props => [booking, listing, isUpcoming, bookingDate];
}
