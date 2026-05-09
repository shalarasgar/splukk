import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.userUid,
    required super.listingId,
    required super.weekday,
    required super.startMinutes,
    required super.endMinutes,
    required super.guestCount,
    required super.createdAt,
    super.specificDateMs,
  });

  factory BookingModel.fromFirestore(String id, Map<String, dynamic> data) {
    final ts = data['createdAt'];
    final createdAt =
        ts is Timestamp ? ts.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
    return BookingModel(
      id: id,
      userUid: data['userUid'] as String,
      listingId: data['listingId'] as String,
      weekday: data['weekday'] as int,
      startMinutes: data['startMinutes'] as int,
      endMinutes: data['endMinutes'] as int,
      guestCount: data['guestCount'] as int,
      createdAt: createdAt,
      specificDateMs: data['specificDateMs'] as int?,
    );
  }
}
