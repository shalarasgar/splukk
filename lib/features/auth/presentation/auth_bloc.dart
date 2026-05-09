import 'dart:developer' as developer;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/auth_domain.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required PhoneAuthRepository phoneAuthRepository,
    required UserProfileRepository userProfileRepository,
  }) : _phoneAuthRepository = phoneAuthRepository,
       _userProfileRepository = userProfileRepository,
       super(const AuthState.unauthenticated()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthVippsLoginRequested>(_onVippsLoginRequested);
    on<AuthProfileUpdated>(_onProfileUpdated);
    add(const AuthStarted());
  }

  final PhoneAuthRepository _phoneAuthRepository;
  final UserProfileRepository _userProfileRepository;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final user = _phoneAuthRepository.currentUser;
    if (user == null) {
      emit(const AuthState.unauthenticated());
      return;
    }

    final profileResult = await _userProfileRepository.getProfile(user.uid);
    await profileResult.fold(
      (failure) async {
        await _phoneAuthRepository.signOut();
        emit(const AuthState.unauthenticated());
      },
      (profile) async {
        if (profile == null) {
          await _phoneAuthRepository.signOut();
          emit(const AuthState.unauthenticated());
        } else {
          emit(AuthState.authenticated(user: user, profile: profile));
        }
      },
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _phoneAuthRepository.signOut();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onVippsLoginRequested(
    AuthVippsLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.failure('Vipps login requires backend implementation.'));
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onProfileUpdated(
    AuthProfileUpdated event,
    Emitter<AuthState> emit,
  ) async {
    final s = state;
    if (s.status != AuthStatus.authenticated || s.user == null) return;

    emit(s.copyWith(status: AuthStatus.updating));

    final updateResult = await _userProfileRepository.updateProfile(
      event.profile,
      localLogoPath: event.logoLocalPath,
    );

    await updateResult.fold(
      (failure) async {
        emit(AuthState.failure(failure.message ?? 'Hata oluştu'));
        emit(s); // revert to previous authenticated state
      },
      (_) async {
        final profileResult = await _userProfileRepository.getProfile(s.user!.uid);
        profileResult.fold(
          (f) => emit(s),
          (updated) => emit(AuthState.authenticated(user: s.user!, profile: updated!)),
        );
      },
    );
  }
}
