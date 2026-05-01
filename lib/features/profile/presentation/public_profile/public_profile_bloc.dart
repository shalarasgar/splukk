import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/auth_domain.dart';
import '../../../auth/domain/usecases/get_public_profile.dart';

// Events
abstract class PublicProfileEvent extends Equatable {
  const PublicProfileEvent();
  @override
  List<Object?> get props => [];
}

class PublicProfileLoaded extends PublicProfileEvent {
  final String uid;
  const PublicProfileLoaded(this.uid);
  @override
  List<Object?> get props => [uid];
}

// States
enum PublicProfileStatus { initial, loading, success, failure }

class PublicProfileState extends Equatable {
  final PublicProfileStatus status;
  final UserProfile? profile;
  final String? errorMessage;

  const PublicProfileState({
    this.status = PublicProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, profile, errorMessage];

  PublicProfileState copyWith({
    PublicProfileStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return PublicProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Bloc
class PublicProfileBloc extends Bloc<PublicProfileEvent, PublicProfileState> {
  final GetPublicProfile _getPublicProfile;

  PublicProfileBloc({required GetPublicProfile getPublicProfile})
      : _getPublicProfile = getPublicProfile,
        super(const PublicProfileState()) {
    on<PublicProfileLoaded>(_onLoaded);
  }

  Future<void> _onLoaded(
    PublicProfileLoaded event,
    Emitter<PublicProfileState> emit,
  ) async {
    emit(state.copyWith(status: PublicProfileStatus.loading));
    try {
      final profile = await _getPublicProfile.execute(event.uid);
      if (profile != null) {
        emit(state.copyWith(status: PublicProfileStatus.success, profile: profile));
      } else {
        emit(state.copyWith(status: PublicProfileStatus.failure, errorMessage: 'Profil bulunamadı'));
      }
    } catch (e) {
      emit(state.copyWith(status: PublicProfileStatus.failure, errorMessage: e.toString()));
    }
  }
}
