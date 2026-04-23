import 'package:get/get.dart';
import 'package:splukk/features/listings/data/datasources/listing_remote_datasource.dart';
import 'package:splukk/features/listings/data/repositories/listing_repository_impl.dart';

import 'package:splukk/features/auth/data/auth_data.dart';
import 'package:splukk/features/auth/domain/auth_domain.dart';
import 'package:splukk/features/auth/presentation/auth_bloc.dart';
import 'package:splukk/features/bookings/data/booking_remote_datasource.dart';
import 'package:splukk/features/bookings/data/booking_repository.dart';
import 'package:splukk/features/listings/domain/listings_domain.dart';
import 'package:splukk/features/my_picks/domain/usecases/get_my_picks_usecase.dart';
import 'package:splukk/features/my_picks/presentation/my_picks_controller.dart';

void initDependencies() {
  Get.put<UserProfileRemoteDataSource>(
    UserProfileRemoteDataSource(),
    permanent: true,
  );
  Get.put<UserProfileRepository>(
    UserProfileRepositoryImpl(Get.find<UserProfileRemoteDataSource>()),
    permanent: true,
  );
  Get.put<ListingRemoteDataSource>(
    ListingRemoteDataSource(),
    permanent: true,
  );
  Get.put<ListingRepository>(
    ListingRepositoryImpl(Get.find<ListingRemoteDataSource>()),
    permanent: true,
  );
  Get.put<BookingRemoteDataSource>(
    BookingRemoteDataSource(),
    permanent: true,
  );
  Get.put<BookingRepository>(
    BookingRepository(Get.find<BookingRemoteDataSource>()),
    permanent: true,
  );
  Get.put<PhoneAuthRepository>(
    PhoneAuthRepositoryImpl(),
    permanent: true,
  );
  Get.put<AuthBloc>(
    AuthBloc(
      phoneAuthRepository: Get.find<PhoneAuthRepository>(),
      userProfileRepository: Get.find<UserProfileRepository>(),
    ),
    permanent: true,
  );
  Get.put<GetMyPicksUseCase>(
    GetMyPicksUseCase(
      bookingRepository: Get.find<BookingRepository>(),
      listingRepository: Get.find<ListingRepository>(),
    ),
    permanent: true,
  );
  Get.lazyPut<MyPicksController>(
    () => MyPicksController(
      getMyPicksUseCase: Get.find<GetMyPicksUseCase>(),
      authBloc: Get.find<AuthBloc>(),
    ),
  );
}
