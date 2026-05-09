import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/auth_domain.dart';
import '../datasources/user_profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl(this._remote);

  final UserProfileRemoteDataSource _remote;

  @override
  Future<Either<Failure, UserProfile?>> getProfile(String uid) async {
    try {
      final data = await _remote.getUserDocument(uid);
      if (data == null) return const Right(null);
      return Right(UserProfileModel.fromFirestore(uid, data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createConsumer({
    required String uid,
    required String phone,
    required String fullName,
  }) async {
    try {
      await _remote.writeConsumer(
        uid: uid,
        phone: phone,
        fullName: fullName,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createFarmer({
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
    try {
      await _remote.writeFarmer(
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
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(UserProfile profile, {String? localLogoPath}) async {
    try {
      await _remote.updateUser(profile, localLogoPath: localLogoPath);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
