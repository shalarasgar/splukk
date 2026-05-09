import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/farm_listing.dart';

abstract class ListingRepository {
  Stream<List<FarmListing>> watchAllListings();

  Stream<List<FarmListing>> watchListingsForFarmer(String farmerUid);

  Future<Either<Failure, FarmListing?>> getListing(String id);

  Future<Either<Failure, String>> createListing({
    required String farmerUid,
    required String farmName,
    required String city,
    required List<String> newImageLocalPaths,
    required PickingType pickingType,
    required int availabilityPercent,
    int? availabilityMessageIndex,
    required bool manualClosed,
    String? description,
    required double latitude,
    required double longitude,
    required List<ListingProductLine> products,
    required List<DayTimeSlot> schedule,
  });

  Future<Either<Failure, void>> updateListing({
    required FarmListing listing,
    required List<String> newImageLocalPaths,
  });

  Future<Either<Failure, void>> deleteListing(String id);

  Future<Either<Failure, void>> bookSlot({required String listingId, required DayTimeSlot slot});
}
