import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/auth_domain.dart';
import '../../domain/services/geocoder_service.dart';
import 'phone_auth_state.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../auth_bloc.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthState> {
  final PhoneAuthRepository _phoneAuthRepository;
  final UserProfileRepository _userProfileRepository;
  final GeocoderService _geocoderService;
  final AuthBloc _authBloc;

  PhoneAuthCubit({
    required PhoneAuthRepository phoneAuthRepository,
    required UserProfileRepository userProfileRepository,
    required GeocoderService geocoderService,
    required AuthBloc authBloc,
  }) : _phoneAuthRepository = phoneAuthRepository,
       _userProfileRepository = userProfileRepository,
       _geocoderService = geocoderService,
       _authBloc = authBloc,
       super(const PhoneAuthState.initial());

  AuthFlowIntent? _intent;
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
    _intent = null;
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

  Future<void> submitPhoneNumber({
    required String phoneNumber,
    required AuthFlowIntent intent,
    String? fullName,
    String? farmName,
    String? farmCountry,
    String? farmState,
    String? farmCity,
    String? farmPostalCode,
    String? farmStreet,
    String? farmStreetNumber,
    String? logoLocalPath,
  }) async {
    emit(
      state.copyWith(status: PhoneAuthStatus.loading, phoneNumber: phoneNumber),
    );
    _clearPending();
    _intent = intent;
    _pendingFullName = fullName?.trim();
    _pendingFarmName = farmName?.trim();
    _pendingFarmCountry = farmCountry?.trim();
    _pendingFarmState = farmState?.trim();
    _pendingFarmCity = farmCity?.trim();
    _pendingFarmPostalCode = farmPostalCode?.trim();
    _pendingFarmStreet = farmStreet?.trim();
    _pendingFarmStreetNumber = farmStreetNumber?.trim();
    _pendingLogoPath = logoLocalPath;

    if (intent == AuthFlowIntent.registerFarmer) {
      final fname = (_pendingFarmName ?? '').trim();
      if (fname.isEmpty) {
        emit(
          state.copyWith(
            status: PhoneAuthStatus.failure,
            errorMessage: 'AUTH_FARM_REQUIRED',
          ),
        );
        return;
      }
      final street = _pendingFarmStreet ?? '';
      final streetNo = _pendingFarmStreetNumber ?? '';
      final country = _pendingFarmCountry ?? '';
      final city = _pendingFarmCity ?? '';
      if (street.isEmpty || streetNo.isEmpty) {
        emit(
          state.copyWith(
            status: PhoneAuthStatus.failure,
            errorMessage: 'AUTH_STREET_REQUIRED',
          ),
        );
        return;
      }
      if (country.isEmpty || city.isEmpty) {
        emit(
          state.copyWith(
            status: PhoneAuthStatus.failure,
            errorMessage: 'AUTH_CITY_REQUIRED',
          ),
        );
        return;
      }

      try {
        final coords = await _geocoderService.resolveCoordinates(
          street: street,
          streetNumber: streetNo,
          postalCode: _pendingFarmPostalCode ?? '',
          city: city,
          state: _pendingFarmState ?? '',
          country: country,
        );
        if (coords != null) {
          _pendingFarmLatitude = coords.latitude;
          _pendingFarmLongitude = coords.longitude;
        } else {
          developer.log(
            'PhoneAuthCubit: Address could not be resolved',
            name: 'splukk.phone_auth',
          );
          emit(
            state.copyWith(
              status: PhoneAuthStatus.failure,
              errorMessage: 'AUTH_LOCATION_RESOLUTION_FAILED',
            ),
          );
          return;
        }
      } catch (e) {
        developer.log(
          'PhoneAuthCubit Geocoding exception',
          error: e,
          name: 'splukk.phone_auth',
        );
        emit(
          state.copyWith(
            status: PhoneAuthStatus.failure,
            errorMessage: 'AUTH_LOCATION_RESOLUTION_ERROR',
          ),
        );
        return;
      }
    }

    final result = await _phoneAuthRepository.startVerifyPhoneNumber(
      phoneNumber.trim(),
      codeSent: (verificationId) {
        if (!isClosed) {
          emit(
            state.copyWith(
              status: PhoneAuthStatus.codeSent,
              verificationId: verificationId,
            ),
          );
        }
      },
      verificationCompleted: (user) async {
        // Handled directly or triggers success
        if (!isClosed) {
          await _finishPhoneAuth(user);
        }
      },
      verificationFailed: (message) {
        if (!isClosed) {
          emit(
            state.copyWith(
              status: PhoneAuthStatus.failure,
              errorMessage: message,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!isClosed) {
          emit(state.copyWith(verificationId: verificationId));
        }
      },
    );

    result.fold(
      (failure) {
        if (!isClosed) {
          emit(
            state.copyWith(
              status: PhoneAuthStatus.failure,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (_) {}, // do nothing on right, callbacks handle it
    );
  }

  Future<void> submitSmsCode(String smsCode) async {
    final vid = state.verificationId;
    if (vid == null) {
      emit(
        state.copyWith(
          status: PhoneAuthStatus.failure,
          errorMessage: 'Missing verification ID',
        ),
      );
      return;
    }
    emit(state.copyWith(status: PhoneAuthStatus.loading));
    final result = await _phoneAuthRepository.signInWithSmsCode(
      verificationId: vid,
      smsCode: smsCode.trim(),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: PhoneAuthStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (user) async {
        await _finishPhoneAuth(user);
      },
    );
  }

  Future<void> _finishPhoneAuth(SessionUser user) async {
    final profileResult = await _userProfileRepository.getProfile(user.uid);
    await profileResult.fold(
      (failure) async {
        developer.log(
          'PhoneAuthCubit _finishPhoneAuth failed',
          name: 'splukk.phone_auth',
          error: failure.message,
        );
        emit(
          state.copyWith(
            status: PhoneAuthStatus.failure,
            errorMessage: failure.message,
          ),
        );
        await _phoneAuthRepository.signOut();
      },
      (existingProfile) async {
        final isNewUser = (existingProfile == null);

        if (_intent == AuthFlowIntent.login) {
          if (isNewUser) {
            emit(
              state.copyWith(
                status: PhoneAuthStatus.failure,
                errorMessage: 'AUTH_NO_ACCOUNT',
              ),
            );
            await _phoneAuthRepository.signOut();
            return;
          }
          
          _clearPending();
          emit(state.copyWith(status: PhoneAuthStatus.success));
          _authBloc.add(const AuthStarted());
        } else {
          if (!isNewUser) {
            emit(
              state.copyWith(
                status: PhoneAuthStatus.failure,
                errorMessage: 'AUTH_ACCOUNT_EXISTS',
              ),
            );
            await _phoneAuthRepository.signOut();
            return;
          }
          final role = _intent == AuthFlowIntent.registerFarmer
              ? UserRole.farmer
              : UserRole.consumer;
          
          Either<Failure, void> createResult;
          if (role == UserRole.farmer) {
            createResult = await _userProfileRepository.createFarmer(
              uid: user.uid,
              phone: user.phoneNumber ?? '',
              farmName: _pendingFarmName ?? '',
              farmCountry: _pendingFarmCountry ?? '',
              farmState: _pendingFarmState ?? '',
              farmCity: _pendingFarmCity ?? '',
              farmPostalCode: _pendingFarmPostalCode ?? '',
              farmStreet: _pendingFarmStreet ?? '',
              farmStreetNumber: _pendingFarmStreetNumber ?? '',
              farmLatitude: _pendingFarmLatitude ?? 0.0,
              farmLongitude: _pendingFarmLongitude ?? 0.0,
              localLogoPath: _pendingLogoPath,
            );
          } else {
            createResult = await _userProfileRepository.createConsumer(
              uid: user.uid,
              phone: user.phoneNumber ?? '',
              fullName: _pendingFullName ?? '',
            );
          }

          await createResult.fold(
            (failure) async {
              emit(
                state.copyWith(
                  status: PhoneAuthStatus.failure,
                  errorMessage: failure.message,
                ),
              );
              await _phoneAuthRepository.signOut();
            },
            (_) async {
              _clearPending();
              emit(state.copyWith(status: PhoneAuthStatus.success));
              // Notify AuthBloc to refresh session
              _authBloc.add(const AuthStarted());
            },
          );
        }
      },
    );
  }

  void reset() {
    _clearPending();
    emit(const PhoneAuthState.initial());
  }
}
