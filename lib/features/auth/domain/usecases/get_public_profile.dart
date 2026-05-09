import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import 'package:splukk/features/auth/domain/auth_domain.dart';

class GetPublicProfile {
  final UserProfileRepository _repository;

  GetPublicProfile(this._repository);

  Future<Either<Failure, UserProfile?>> execute(String uid) {
    return _repository.getProfile(uid);
  }
}
