import 'package:get/get.dart';

import '../../features/auth/data/auth_data.dart';
import '../../features/auth/domain/auth_domain.dart';
import '../../features/auth/presentation/auth_bloc.dart';
import '../../features/bookings/data/booking_remote_datasource.dart';
import '../../features/bookings/data/booking_repository.dart';
import '../../features/listings/data/listings_data.dart';
import '../../features/listings/domain/listings_domain.dart';

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
}
