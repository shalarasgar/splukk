import 'package:get_it/get_it.dart';
import 'package:splukk/features/listings/data/datasources/listing_remote_datasource.dart';
import 'package:splukk/features/listings/data/repositories/listing_repository_impl.dart';

import 'package:splukk/features/auth/data/auth_data.dart';
import 'package:splukk/features/auth/domain/auth_domain.dart';
import 'package:splukk/features/auth/presentation/auth_bloc.dart';
import 'package:splukk/features/bookings/data/booking_remote_datasource.dart';
import 'package:splukk/features/auth/domain/services/geocoder_service.dart';
import 'package:splukk/features/auth/data/services/geocoder_service_impl.dart';
import 'package:splukk/features/listings/domain/repositories/listing_repository.dart';
import 'package:splukk/features/marketplace/domain/usecases/filter_listings_usecase.dart';
import 'package:splukk/features/auth/domain/usecases/get_public_profile.dart';
import 'package:splukk/features/bookings/domain/repositories/booking_repository.dart';
import 'package:splukk/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:splukk/features/marketplace/presentation/marketplace_cubit.dart';
import 'package:splukk/features/my_picks/domain/usecases/get_my_picks_usecase.dart';
import 'package:splukk/features/my_picks/presentation/my_picks_cubit.dart';
import 'package:splukk/features/profile/presentation/public_profile/public_profile_bloc.dart';
import 'package:splukk/core/services/link_launcher_service.dart';

final sl = GetIt.instance;

void initDependencies() {
  // Data Sources
  sl.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileRemoteDataSource(),
  );
  sl.registerLazySingleton<ListingRemoteDataSource>(
    () => ListingRemoteDataSource(),
  );
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSource(),
  );

  // Repositories
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ListingRepository>(
    () => ListingRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PhoneAuthRepository>(
    () => PhoneAuthRepositoryImpl(),
  );

  // Services
  sl.registerLazySingleton<GeocoderService>(() => GeocoderServiceImpl());
  sl.registerLazySingleton<VippsAuthService>(() => VippsAuthService());
  sl.registerLazySingleton<SocialAuthRepository>(
    () => SocialAuthRepositoryImpl(vippsAuthService: sl()),
  );
  sl.registerLazySingleton<LinkLauncherService>(() => LinkLauncherServiceImpl());

  // UseCases
  sl.registerLazySingleton<GetMyPicksUseCase>(
    () => GetMyPicksUseCase(bookingRepository: sl(), listingRepository: sl()),
  );
  sl.registerLazySingleton<FilterListingsUseCase>(() => FilterListingsUseCase());
  sl.registerLazySingleton<GetPublicProfile>(() => GetPublicProfile(sl()));

  // BLoCs / Cubits
  sl.registerFactory<MarketplaceCubit>(
    () => MarketplaceCubit(repo: sl(), filterUseCase: sl()),
  );

  sl.registerFactory<MyPicksCubit>(
    () => MyPicksCubit(getMyPicksUseCase: sl()),
  );
  sl.registerFactory<PublicProfileBloc>(
    () => PublicProfileBloc(getPublicProfile: sl()),
  );

  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      phoneAuthRepository: sl(),
      userProfileRepository: sl(),
      socialAuthRepository: sl(),
      geocoderService: sl(),
    ),
  );
}
