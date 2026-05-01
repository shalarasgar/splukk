import 'package:splukk/features/auth/domain/auth_domain.dart';

class GetPublicProfile {
  final UserProfileRepository _repository;

  GetPublicProfile(this._repository);

  Future<UserProfile?> execute(String uid) {
    return _repository.getProfile(uid);
  }
}
