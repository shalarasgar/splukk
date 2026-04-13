import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/auth_domain.dart';

class UserProfileModel {
  static UserProfile fromFirestore(String uid, Map<String, dynamic> data) {
    final roleStr = data['role'] as String? ?? UserRole.consumer.name;
    final role = UserRole.values.firstWhere(
      (e) => e.name == roleStr,
      orElse: () => UserRole.consumer,
    );
    return UserProfile(
      uid: uid,
      documentId: data['documentId'] as String? ?? uid,
      role: role,
      phone: data['phone'] as String? ?? '',
      fullName: data['fullName'] as String?,
      farmName: data['farmName'] as String?,
      farmAddress: data['farmAddress'] as String?,
      farmCountry: data['farmCountry'] as String?,
      farmState: data['farmState'] as String?,
      farmCity: data['farmCity'] as String?,
      farmPostalCode: data['farmPostalCode'] as String?,
      farmStreet: data['farmStreet'] as String?,
      farmStreetNumber: data['farmStreetNumber'] as String?,
      farmLatitude: _readDouble(data['farmLatitude']),
      farmLongitude: _readDouble(data['farmLongitude']),
      logoUrl: data['logoUrl'] as String?,
      createdAt: _readDate(data['createdAt']),
    );
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static double? _readDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return null;
  }
}
