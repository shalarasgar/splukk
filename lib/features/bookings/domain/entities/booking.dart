import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.userUid,
    required this.listingId,
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
    required this.guestCount,
    required this.createdAt,
    this.specificDateMs,
  });

  final String id;
  final String userUid;
  final String listingId;
  final int weekday;
  final int startMinutes;
  final int endMinutes;
  final int guestCount;
  final DateTime createdAt;
  final int? specificDateMs;

  @override
  List<Object?> get props => [
        id,
        userUid,
        listingId,
        weekday,
        startMinutes,
        endMinutes,
        guestCount,
        createdAt,
        specificDateMs,
      ];
}
