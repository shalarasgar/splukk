import '../entities/farm_listing.dart';

abstract class ListingRepository {
  Stream<List<FarmListing>> watchAllListings();

  Stream<List<FarmListing>> watchListingsForFarmer(String farmerUid);

  Future<FarmListing?> getListing(String id);

  Future<String> createListing({
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

  Future<void> updateListing({
    required FarmListing listing,
    required List<String> newImageLocalPaths,
  });
}
