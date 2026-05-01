import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getProfile(String uid);

  Future<void> createConsumer({
    required String uid,
    required String phone,
    required String fullName,
  });

  Future<void> createFarmer({
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
  });

  Future<void> updateProfile(UserProfile profile, {String? localLogoPath});
}
