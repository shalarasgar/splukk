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
      bio: data['bio'] as String?,
      alternativePhone: data['alternativePhone'] as String?,
      socialInstagram: data['socialInstagram'] as String?,
      socialFacebook: data['socialFacebook'] as String?,
      bankIban: data['bankIban'] as String?,
      createdAt: _readDate(data['createdAt']),
    );
  }

  static Map<String, dynamic> toFirestore(UserProfile profile) {
    return {
      'role': profile.role.name,
      'phone': profile.phone,
      'fullName': profile.fullName,
      'farmName': profile.farmName,
      'farmAddress': profile.farmAddress,
      'farmCountry': profile.farmCountry,
      'farmState': profile.farmState,
      'farmCity': profile.farmCity,
      'farmPostalCode': profile.farmPostalCode,
      'farmStreet': profile.farmStreet,
      'farmStreetNumber': profile.farmStreetNumber,
      'farmLatitude': profile.farmLatitude,
      'farmLongitude': profile.farmLongitude,
      'logoUrl': profile.logoUrl,
      'bio': profile.bio,
      'alternativePhone': profile.alternativePhone,
      'socialInstagram': profile.socialInstagram,
      'socialFacebook': profile.socialFacebook,
      'bankIban': profile.bankIban,
      'createdAt': Timestamp.fromDate(profile.createdAt),
    };
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static double? _readDouble(dynamic value) {
    if (value == null) return null;
    double? d;
    if (value is double) {
      d = value;
    } else if (value is int) {
      d = value.toDouble();
    } else if (value is num) {
      d = value.toDouble();
    }
    return (d != null && d.isFinite) ? d : null;
  }
}
