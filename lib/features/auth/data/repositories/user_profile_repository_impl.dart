import '../../domain/auth_domain.dart';
import '../datasources/user_profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl(this._remote);

  final UserProfileRemoteDataSource _remote;

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final data = await _remote.getUserDocument(uid);
    if (data == null) return null;
    return UserProfileModel.fromFirestore(uid, data);
  }

  @override
  Future<void> createConsumer({
    required String uid,
    required String phone,
    required String fullName,
  }) {
    return _remote.writeConsumer(
      uid: uid,
      phone: phone,
      fullName: fullName,
    );
  }

  @override
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
  }) {
    return _remote.writeFarmer(
      uid: uid,
      phone: phone,
      farmName: farmName,
      farmCountry: farmCountry,
      farmState: farmState,
      farmCity: farmCity,
      farmPostalCode: farmPostalCode,
      farmStreet: farmStreet,
      farmStreetNumber: farmStreetNumber,
      farmLatitude: farmLatitude,
      farmLongitude: farmLongitude,
      localLogoPath: localLogoPath,
    );
  }

  @override
  Future<void> updateProfile(UserProfile profile, {String? localLogoPath}) {
    return _remote.updateUser(profile, localLogoPath: localLogoPath);
  }
}
