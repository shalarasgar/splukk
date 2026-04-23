import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/booking.dart';

class BookingRemoteDataSource {
  BookingRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _bookings = 'bookings';
  static const _listings = 'farm_listings';

  /// Найти активную бронь пользователя на конкретное объявление
  Future<Booking?> getUserBookingForListing({
    required String userUid,
    required String listingId,
  }) async {
    final snap = await _firestore
        .collection(_bookings)
        .where('userUid', isEqualTo: userUid)
        .where('listingId', isEqualTo: listingId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return _fromDoc(doc.id, doc.data());
  }

  /// Получить все активные бронирования пользователя
  Future<List<Booking>> getUserBookings({required String userUid}) async {
    final snap = await _firestore
        .collection(_bookings)
        .where('userUid', isEqualTo: userUid)
        .get();

    if (snap.docs.isEmpty) return [];

    return snap.docs.map((doc) => _fromDoc(doc.id, doc.data())).toList();
  }

  /// Создать новую бронь и увеличить bookedCount в объявлении
  Future<void> createBooking({
    required String userUid,
    required String listingId,
    required int weekday,
    required int startMinutes,
    required int endMinutes,
    required int guestCount,
    int? specificDateMs,
  }) async {
    final listingRef = _firestore.collection(_listings).doc(listingId);
    final bookingRef = _firestore.collection(_bookings).doc();

    await _firestore.runTransaction((tx) async {
      final listingSnap = await tx.get(listingRef);
      if (!listingSnap.exists) throw Exception('İlan bulunamadı');

      final scheduleRaw = listingSnap.data()!['schedule'] as List?;
      if (scheduleRaw == null) throw Exception('Geçersiz çalışma programı');

      final idx = _findSlotIndex(
        scheduleRaw,
        weekday: weekday,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        specificDateMs: specificDateMs,
      );
      if (idx == -1) throw Exception('Slot bulunamadı');

      final slot = Map<String, dynamic>.from(scheduleRaw[idx]);
      final maxPeople = slot['maxPeople'] as int? ?? 0;
      final booked = slot['bookedCount'] as int? ?? 0;

      if (booked + guestCount > maxPeople) {
        throw Exception('Yeterli yer yok (boş: ${maxPeople - booked})');
      }

      slot['bookedCount'] = booked + guestCount;
      final newSchedule = List<dynamic>.from(scheduleRaw);
      newSchedule[idx] = slot;

      tx.update(listingRef, {'schedule': newSchedule});
      tx.set(bookingRef, {
        'userUid': userUid,
        'listingId': listingId,
        'weekday': weekday,
        'startMinutes': startMinutes,
        'endMinutes': endMinutes,
        'guestCount': guestCount,
        'specificDateMs': specificDateMs,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Обновить количество гостей в существующей брони
  Future<void> updateBooking({
    required Booking existing,
    required int newGuestCount,
  }) async {
    final listingRef = _firestore.collection(_listings).doc(existing.listingId);
    final bookingRef = _firestore.collection(_bookings).doc(existing.id);

    await _firestore.runTransaction((tx) async {
      final listingSnap = await tx.get(listingRef);
      if (!listingSnap.exists) throw Exception('İlan bulunamadı');

      final scheduleRaw = listingSnap.data()!['schedule'] as List?;
      if (scheduleRaw == null) throw Exception('Geçersiz çalışma programı');

      final idx = _findSlotIndex(
        scheduleRaw,
        weekday: existing.weekday,
        startMinutes: existing.startMinutes,
        endMinutes: existing.endMinutes,
        specificDateMs: existing.specificDateMs,
      );
      if (idx == -1) throw Exception('Slot bulunamadı');

      final slot = Map<String, dynamic>.from(scheduleRaw[idx]);
      final maxPeople = slot['maxPeople'] as int? ?? 0;
      final booked = slot['bookedCount'] as int? ?? 0;

      final delta = newGuestCount - existing.guestCount;
      if (delta > 0 && booked + delta > maxPeople) {
        throw Exception('Yeterli yer yok (boş: ${maxPeople - booked})');
      }

      slot['bookedCount'] = booked + delta;
      final newSchedule = List<dynamic>.from(scheduleRaw);
      newSchedule[idx] = slot;

      tx.update(listingRef, {'schedule': newSchedule});
      tx.update(bookingRef, {'guestCount': newGuestCount});
    });
  }

  /// Полная отмена: удалить бронь и вернуть места
  Future<void> cancelBooking({required Booking booking}) async {
    final listingRef = _firestore.collection(_listings).doc(booking.listingId);
    final bookingRef = _firestore.collection(_bookings).doc(booking.id);

    await _firestore.runTransaction((tx) async {
      final listingSnap = await tx.get(listingRef);
      if (!listingSnap.exists) throw Exception('İlan bulunamadı');

      final scheduleRaw = listingSnap.data()!['schedule'] as List?;
      if (scheduleRaw == null) throw Exception('Geçersiz çalışma programı');

      final idx = _findSlotIndex(
        scheduleRaw,
        weekday: booking.weekday,
        startMinutes: booking.startMinutes,
        endMinutes: booking.endMinutes,
        specificDateMs: booking.specificDateMs,
      );

      if (idx != -1) {
        final slot = Map<String, dynamic>.from(scheduleRaw[idx]);
        final booked = slot['bookedCount'] as int? ?? 0;
        slot['bookedCount'] = (booked - booking.guestCount).clamp(0, 9999);
        final newSchedule = List<dynamic>.from(scheduleRaw);
        newSchedule[idx] = slot;
        tx.update(listingRef, {'schedule': newSchedule});
      }

      tx.delete(bookingRef);
    });
  }

  int _findSlotIndex(
    List scheduleRaw, {
    required int weekday,
    required int startMinutes,
    required int endMinutes,
    int? specificDateMs,
  }) {
    for (int i = 0; i < scheduleRaw.length; i++) {
      final item = scheduleRaw[i];
      if (item is! Map) continue;
      if (item['weekday'] == weekday &&
          item['startMinutes'] == startMinutes &&
          item['endMinutes'] == endMinutes &&
          item['specificDate'] == specificDateMs) {
        return i;
      }
    }
    return -1;
  }

  Booking _fromDoc(String id, Map<String, dynamic> data) {
    final ts = data['createdAt'];
    final createdAt =
        ts is Timestamp ? ts.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
    return Booking(
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
