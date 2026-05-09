import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfile?>> getProfile(String uid);

  Future<Either<Failure, void>> createConsumer({
    required String uid,
    required String phone,
    required String fullName,
  });

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
  });

  Future<Either<Failure, void>> updateProfile(UserProfile profile, {String? localLogoPath});
}
