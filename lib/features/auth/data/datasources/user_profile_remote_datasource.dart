import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/storage_service.dart';

import '../../domain/auth_domain.dart';

class UserProfileRemoteDataSource {
  UserProfileRemoteDataSource({
    FirebaseFirestore? firestore,
    required StorageService storageService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storageService = storageService;

  final FirebaseFirestore _firestore;
  final StorageService _storageService;

  static const _usersCollection = 'users';

  Future<Map<String, dynamic>?> getUserDocument(String uid) async {
    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Future<void> writeConsumer({
    required String uid,
    required String phone,
    required String fullName,
  }) async {
    await _firestore.collection(_usersCollection).doc(uid).set({
      'documentId': uid,
      'role': UserRole.consumer.name,
      'phone': phone,
      'fullName': fullName.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> writeFarmer({
    required String uid,
    required String phone,
    required String farmName,
    required String farmCountry,
    required String farmState,
    required String farmCity,
    required String farmPostalCode,
    required String farmStreet,
    required String farmStreetNumber,
    required double farmLatitude,
    required double farmLongitude,
    String? localLogoPath,
  }) async {
    String? logoUrl;
    if (localLogoPath != null && localLogoPath.isNotEmpty) {
      logoUrl = await _storageService.uploadFile(
        localPath: localLogoPath,
        destinationPath: 'farm_logos/$uid.jpg',
      );
    }

    final country = farmCountry.trim();
    final state = farmState.trim();
    final city = farmCity.trim();
    final postal = farmPostalCode.trim();
    final street = farmStreet.trim();
    final streetNo = farmStreetNumber.trim();
    final farmAddressLine =
        '$street $streetNo, $postal, $city, $state, $country';

    await _firestore.collection(_usersCollection).doc(uid).set({
      'documentId': uid,
      'role': UserRole.farmer.name,
      'phone': phone,
      'farmName': farmName.trim(),
      'farmCountry': country,
      'farmState': state,
      'farmCity': city,
      'farmPostalCode': postal,
      'farmStreet': street,
      'farmStreetNumber': streetNo,
      'farmLatitude': farmLatitude,
      'farmLongitude': farmLongitude,
      'farmAddress': farmAddressLine,
      'createdAt': FieldValue.serverTimestamp(),
      'logoUrl': logoUrl,
    });
  }

  Future<void> updateUser(UserProfile profile, {String? localLogoPath}) async {
    String? logoUrl = profile.logoUrl;
    if (localLogoPath != null && localLogoPath.isNotEmpty) {
      final newUrl = await _storageService.uploadFile(
        localPath: localLogoPath,
        destinationPath: 'farm_logos/${profile.uid}.jpg',
      );
      if (newUrl != null) logoUrl = newUrl;
    }

    // We don't want to use ServerTimestamp here because we might want to preserve the original createdAt
    // and models use Timestamp from Firestore anyway.
    final data = {
      'fullName': profile.fullName?.trim(),
      'farmName': profile.farmName?.trim(),
      'farmCountry': profile.farmCountry?.trim(),
      'farmState': profile.farmState?.trim(),
      'farmCity': profile.farmCity?.trim(),
      'farmPostalCode': profile.farmPostalCode?.trim(),
      'farmStreet': profile.farmStreet?.trim(),
      'farmStreetNumber': profile.farmStreetNumber?.trim(),
      'farmLatitude': profile.farmLatitude,
      'farmLongitude': profile.farmLongitude,
      'logoUrl': logoUrl,
      'bio': profile.bio?.trim(),
      'alternativePhone': profile.alternativePhone?.trim(),
      'socialInstagram': profile.socialInstagram?.trim(),
      'socialFacebook': profile.socialFacebook?.trim(),
      'bankIban': profile.bankIban?.trim(),
    };

    // Remove null values to avoid overwriting with null in Firestore if field was not provided
    data.removeWhere((key, value) => value == null);

    await _firestore
        .collection(_usersCollection)
        .doc(profile.uid)
        .update(data);
  }
}
