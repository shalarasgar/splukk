import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/auth_domain.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.documentId,
    required super.role,
    required super.phone,
    super.fullName,
    super.farmName,
    super.farmAddress,
    super.farmCountry,
    super.farmState,
    super.farmCity,
    super.farmPostalCode,
    super.farmStreet,
    super.farmStreetNumber,
    super.farmLatitude,
    super.farmLongitude,
    super.logoUrl,
    super.bio,
    super.alternativePhone,
    super.socialInstagram,
    super.socialFacebook,
    super.bankIban,
    required super.createdAt,
  });

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      uid: entity.uid,
      documentId: entity.documentId,
      role: entity.role,
      phone: entity.phone,
      fullName: entity.fullName,
      farmName: entity.farmName,
      farmAddress: entity.farmAddress,
      farmCountry: entity.farmCountry,
      farmState: entity.farmState,
      farmCity: entity.farmCity,
      farmPostalCode: entity.farmPostalCode,
      farmStreet: entity.farmStreet,
      farmStreetNumber: entity.farmStreetNumber,
      farmLatitude: entity.farmLatitude,
      farmLongitude: entity.farmLongitude,
      logoUrl: entity.logoUrl,
      bio: entity.bio,
      alternativePhone: entity.alternativePhone,
      socialInstagram: entity.socialInstagram,
      socialFacebook: entity.socialFacebook,
      bankIban: entity.bankIban,
      createdAt: entity.createdAt,
    );
  }

  factory UserProfileModel.fromFirestore(String uid, Map<String, dynamic> data) {
    final roleStr = data['role'] as String? ?? UserRole.consumer.name;
    final role = UserRole.values.firstWhere(
      (e) => e.name == roleStr,
      orElse: () => UserRole.consumer,
    );
    return UserProfileModel(
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

  Map<String, dynamic> toFirestore() {
    return {
      'role': role.name,
      'phone': phone,
      'fullName': fullName,
      'farmName': farmName,
      'farmAddress': farmAddress,
      'farmCountry': farmCountry,
      'farmState': farmState,
      'farmCity': farmCity,
      'farmPostalCode': farmPostalCode,
      'farmStreet': farmStreet,
      'farmStreetNumber': farmStreetNumber,
      'farmLatitude': farmLatitude,
      'farmLongitude': farmLongitude,
      'logoUrl': logoUrl,
      'bio': bio,
      'alternativePhone': alternativePhone,
      'socialInstagram': socialInstagram,
      'socialFacebook': socialFacebook,
      'bankIban': bankIban,
      'createdAt': Timestamp.fromDate(createdAt),
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
