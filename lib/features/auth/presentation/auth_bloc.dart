import 'dart:developer' as developer;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/farm_address_geocoder.dart';
import '../domain/auth_domain.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required PhoneAuthRepository phoneAuthRepository,
    required UserProfileRepository userProfileRepository,
    required SocialAuthRepository socialAuthRepository,
  }) : _phoneAuthRepository = phoneAuthRepository,
       _userProfileRepository = userProfileRepository,
       _socialAuthRepository = socialAuthRepository,
       super(const AuthState.unauthenticated()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthPhoneRequested>(_onPhoneRequested);
    on<AuthSmsCodeSubmitted>(_onSmsCodeSubmitted);
    on<AuthAfterPhoneVerified>(_onAfterPhoneVerified);
    on<AuthFlowCancelled>(_onFlowCancelled);
    on<AuthVerificationCodeSent>(_onVerificationCodeSent);
    on<AuthVerificationFailed>(_onVerificationFailed);
    on<AuthVippsLoginRequested>(_onVippsLoginRequested);
    on<AuthGoogleLoginRequested>(_onGoogleLoginRequested);
    add(const AuthStarted());
  }

  final PhoneAuthRepository _phoneAuthRepository;
  final UserProfileRepository _userProfileRepository;
  final SocialAuthRepository _socialAuthRepository;

  String? _verificationId;
  AuthFlowIntent _intent = AuthFlowIntent.login;
  String _pendingPhone = '';
  String? _pendingFullName;
  String? _pendingFarmName;
  String? _pendingFarmCountry;
  String? _pendingFarmState;
  String? _pendingFarmCity;
  String? _pendingFarmPostalCode;
  String? _pendingFarmStreet;
  String? _pendingFarmStreetNumber;
  double? _pendingFarmLatitude;
  double? _pendingFarmLongitude;
  String? _pendingLogoPath;

  void _clearPending() {
    _verificationId = null;
    _intent = AuthFlowIntent.login;
    _pendingPhone = '';
    _pendingFullName = null;
    _pendingFarmName = null;
    _pendingFarmCountry = null;
    _pendingFarmState = null;
    _pendingFarmCity = null;
    _pendingFarmPostalCode = null;
    _pendingFarmStreet = null;
    _pendingFarmStreetNumber = null;
    _pendingFarmLatitude = null;
    _pendingFarmLongitude = null;
    _pendingLogoPath = null;
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final user = _phoneAuthRepository.currentUser;
    if (user == null) return;

    final profile = await _userProfileRepository.getProfile(user.uid);
    if (profile == null) {
      await _phoneAuthRepository.signOut();
      emit(const AuthState.unauthenticated());
      return;
    }

    emit(AuthState.authenticated(user: user, profile: profile));
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _phoneAuthRepository.signOut();
    _clearPending();
    emit(const AuthState.unauthenticated());
  }

  void _onFlowCancelled(AuthFlowCancelled event, Emitter<AuthState> emit) {
    _clearPending();
    emit(const AuthState.unauthenticated());
  }

  void _onVerificationCodeSent(
    AuthVerificationCodeSent event,
    Emitter<AuthState> emit,
  ) {
    _verificationId = event.verificationId;
    emit(AuthState.codeSent(verificationId: event.verificationId));
  }

  void _onVerificationFailed(
    AuthVerificationFailed event,
    Emitter<AuthState> emit,
  ) {
    developer.log(
      'AuthBloc verificationFailed → UI: ${event.message}',
      name: 'splukk.phone_auth',
    );
    emit(AuthState.failure(event.message));
    emit(const AuthState.unauthenticated());
    _clearPending();
  }

  Future<void> _onVippsLoginRequested(
    AuthVippsLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.verifyingPhone());

    try {
      final result = await _socialAuthRepository.signInWithVipps();

      if (result == null) {
        emit(const AuthState.failure('Vipps login cancelled'));
        emit(const AuthState.unauthenticated());
        return;
      }

      // TODO: Exchange authorization code for tokens on backend
      // TODO: Fetch user info from Vipps using access token
      // TODO: Check if user exists in Firestore
      // TODO: If new user, show role selection (consumer/farmer)
      // TODO: If existing user, authenticate automatically

      emit(
        const AuthState.failure(
          'Vipps integration requires backend implementation. '
          'Please configure client_id and implement token exchange.',
        ),
      );
      emit(const AuthState.unauthenticated());
    } catch (e) {
      developer.log(
        'AuthBloc Vipps login failed',
        name: 'splukk.vipps_auth',
        error: e,
      );
      emit(AuthState.failure('Vipps login failed: $e'));
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.verifyingPhone());

    try {
      final account = await _socialAuthRepository.signInWithGoogle();

      if (account == null) {
        emit(const AuthState.failure('Google login cancelled'));
        emit(const AuthState.unauthenticated());
        return;
      }

      // TODO: Verify ID token on backend
      // TODO: Check if user exists in Firestore
      // TODO: If new user, show role selection (consumer/farmer)
      // TODO: If existing user, authenticate automatically

      emit(
        const AuthState.failure(
          'Google integration requires backend implementation. '
          'Please configure client_id and implement token verification.',
        ),
      );
      emit(const AuthState.unauthenticated());
    } catch (e) {
      developer.log(
        'AuthBloc Google login failed',
        name: 'splukk.google_auth',
        error: e,
      );
      emit(AuthState.failure('Google login failed: $e'));
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onPhoneRequested(
    AuthPhoneRequested event,
    Emitter<AuthState> emit,
  ) async {
    _verificationId = null;
    _intent = event.intent;
    _pendingPhone = event.phoneNumber.trim();
    _pendingFullName = event.fullName?.trim();
    _pendingFarmName = event.farmName?.trim();
    _pendingFarmCountry = event.farmCountry?.trim();
    _pendingFarmState = event.farmState?.trim();
    _pendingFarmCity = event.farmCity?.trim();
    _pendingFarmPostalCode = event.farmPostalCode?.trim();
    _pendingFarmStreet = event.farmStreet?.trim();
    _pendingFarmStreetNumber = event.farmStreetNumber?.trim();
    _pendingFarmLatitude = null;
    _pendingFarmLongitude = null;
    _pendingLogoPath = event.logoLocalPath;

    if (event.intent == AuthFlowIntent.registerFarmer) {
      final farmName = (_pendingFarmName ?? '').trim();
      if (farmName.isEmpty) {
        emit(const AuthState.failure('Çiftlik adı zorunludur'));
        emit(const AuthState.unauthenticated());
        _clearPending();
        return;
      }
      final street = _pendingFarmStreet ?? '';
      final streetNo = _pendingFarmStreetNumber ?? '';
      final farmCountry = _pendingFarmCountry ?? '';
      final farmState = _pendingFarmState ?? '';
      final farmCity = _pendingFarmCity ?? '';
      final farmPostalCode = _pendingFarmPostalCode ?? '';
      if (street.isEmpty || streetNo.isEmpty) {
        emit(const AuthState.failure('Cadde ve bina/kapı numarası zorunludur'));
        emit(const AuthState.unauthenticated());
        _clearPending();
        return;
      }
      if (farmCountry.isEmpty ||
          farmState.isEmpty ||
          farmCity.isEmpty ||
          farmPostalCode.isEmpty) {
        emit(
          const AuthState.failure(
            'Çiftlik adı, ülke, eyalet, şehir ve posta kodu zorunludur',
          ),
        );
        emit(const AuthState.unauthenticated());
        _clearPending();
        return;
      }
      final loc = await resolveFarmCoordinates(
        street: street,
        streetNumber: streetNo,
        postalCode: farmPostalCode,
        city: farmCity,
        state: farmState,
        country: farmCountry,
      );
      if (loc == null) {
        emit(const AuthState.failure('Adres bulunamadı'));
        emit(const AuthState.unauthenticated());
        _clearPending();
        return;
      }
      _pendingFarmLatitude = loc.latitude;
      _pendingFarmLongitude = loc.longitude;
    }

    emit(const AuthState.verifyingPhone());

    try {
      await _phoneAuthRepository.startVerifyPhoneNumber(
        _pendingPhone,
        verificationCompleted: (user) async {
          add(AuthAfterPhoneVerified(user));
        },
        verificationFailed: (message) {
          add(AuthVerificationFailed(message));
        },
        codeSent: (verificationId) {
          add(AuthVerificationCodeSent(verificationId));
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e, st) {
      developer.log(
        'AuthBloc startVerifyPhoneNumber Future threw',
        name: 'splukk.phone_auth',
        error: e,
        stackTrace: st,
      );
      add(AuthVerificationFailed(e.toString()));
    }
  }

  Future<void> _onSmsCodeSubmitted(
    AuthSmsCodeSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final verId = _verificationId ?? state.verificationId;
      if (verId == null) {
        emit(const AuthState.failure('Doğrulama ID bulunamadı'));
        emit(const AuthState.unauthenticated());
        return;
      }

      final user = await _phoneAuthRepository.signInWithSmsCode(
        verificationId: verId,
        smsCode: event.smsCode,
      );
      await _finishPhoneAuth(user, emit);
    } on PhoneAuthException catch (e) {
      developer.log(
        'AuthBloc SMS submit: PhoneAuthException — ${e.message}',
        name: 'splukk.phone_auth',
        error: e,
      );
      emit(AuthState.failure(e.message));
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onAfterPhoneVerified(
    AuthAfterPhoneVerified event,
    Emitter<AuthState> emit,
  ) async {
    await _finishPhoneAuth(event.user, emit);
  }

  Future<void> _finishPhoneAuth(
    SessionUser user,
    Emitter<AuthState> emit,
  ) async {
    final phone = user.phoneNumber ?? _pendingPhone;

    try {
      switch (_intent) {
        case AuthFlowIntent.login:
          final profile = await _userProfileRepository.getProfile(user.uid);
          if (profile == null) {
            await _phoneAuthRepository.signOut();
            emit(
              const AuthState.failure(
                'Bu numara ile kayıtlı hesap bulunamadı. Önce kayıt olun.',
              ),
            );
            emit(const AuthState.unauthenticated());
            return;
          }
          emit(AuthState.authenticated(user: user, profile: profile));
        case AuthFlowIntent.registerConsumer:
          final name = _pendingFullName?.trim();
          if (name == null || name.isEmpty) {
            await _phoneAuthRepository.signOut();
            emit(const AuthState.failure('Ad soyad gerekli'));
            emit(const AuthState.unauthenticated());
            return;
          }
          final existing = await _userProfileRepository.getProfile(user.uid);
          if (existing != null) {
            emit(AuthState.authenticated(user: user, profile: existing));
            return;
          }
          await _userProfileRepository.createConsumer(
            uid: user.uid,
            phone: phone,
            fullName: name,
          );
          final created = await _userProfileRepository.getProfile(user.uid);
          emit(AuthState.authenticated(user: user, profile: created!));
        case AuthFlowIntent.registerFarmer:
          final farmName = _pendingFarmName?.trim();
          final farmCountry = _pendingFarmCountry?.trim();
          final farmState = _pendingFarmState?.trim();
          final farmCity = _pendingFarmCity?.trim();
          final farmPostalCode = _pendingFarmPostalCode?.trim();
          final farmStreet = _pendingFarmStreet?.trim();
          final farmStreetNumber = _pendingFarmStreetNumber?.trim();
          final farmLat = _pendingFarmLatitude;
          final farmLng = _pendingFarmLongitude;
          if (farmName == null ||
              farmName.isEmpty ||
              farmCountry == null ||
              farmCountry.isEmpty ||
              farmState == null ||
              farmState.isEmpty ||
              farmCity == null ||
              farmCity.isEmpty ||
              farmPostalCode == null ||
              farmPostalCode.isEmpty ||
              farmStreet == null ||
              farmStreet.isEmpty ||
              farmStreetNumber == null ||
              farmStreetNumber.isEmpty ||
              farmLat == null ||
              farmLng == null) {
            await _phoneAuthRepository.signOut();
            emit(
              const AuthState.failure(
                'Çiftlik kaydı için gerekli adres bilgileri eksik',
              ),
            );
            emit(const AuthState.unauthenticated());
            return;
          }
          final existingFarmer = await _userProfileRepository.getProfile(
            user.uid,
          );
          if (existingFarmer != null) {
            emit(AuthState.authenticated(user: user, profile: existingFarmer));
            return;
          }
          await _userProfileRepository.createFarmer(
            uid: user.uid,
            phone: phone,
            farmName: farmName,
            farmCountry: farmCountry,
            farmState: farmState,
            farmCity: farmCity,
            farmPostalCode: farmPostalCode,
            farmStreet: farmStreet,
            farmStreetNumber: farmStreetNumber,
            farmLatitude: farmLat,
            farmLongitude: farmLng,
            localLogoPath: _pendingLogoPath,
          );
          final createdFarmer = await _userProfileRepository.getProfile(
            user.uid,
          );
          emit(AuthState.authenticated(user: user, profile: createdFarmer!));
      }
    } catch (e, st) {
      developer.log(
        'AuthBloc _finishPhoneAuth failed',
        name: 'splukk.phone_auth',
        error: e,
        stackTrace: st,
      );
      await _phoneAuthRepository.signOut();
      emit(AuthState.failure(e.toString()));
      emit(const AuthState.unauthenticated());
    } finally {
      _clearPending();
    }
  }
}
