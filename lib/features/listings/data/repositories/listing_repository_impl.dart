import '../../domain/listings_domain.dart';
import '../datasources/listing_remote_datasource.dart';

class ListingRepositoryImpl implements ListingRepository {
  ListingRepositoryImpl(this._remote);

  final ListingRemoteDataSource _remote;

  static String _slotKey(DayTimeSlot s) =>
      '${s.weekday}_${s.startMinutes}_${s.endMinutes}';

  @override
  Stream<List<FarmListing>> watchAllListings() => _remote.watchAllListings();

  @override
  Stream<List<FarmListing>> watchListingsForFarmer(String farmerUid) =>
      _remote.watchListingsForFarmer(farmerUid);

  @override
  Future<FarmListing?> getListing(String id) => _remote.getListing(id);

  @override
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
  }) {
    return _remote.createListing(
      farmerUid: farmerUid,
      farmName: farmName,
      city: city,
      newImageLocalPaths: newImageLocalPaths,
      pickingType: pickingType,
      availabilityPercent: availabilityPercent,
      availabilityMessageIndex: availabilityMessageIndex,
      manualClosed: manualClosed,
      description: description,
      latitude: latitude,
      longitude: longitude,
      products: products,
      schedule: schedule,
    );
  }

  @override
  Future<void> updateListing({
    required FarmListing listing,
    required List<String> newImageLocalPaths,
  }) async {
    final existing = await _remote.getListing(listing.id);
    final oldBookings = <String, int>{};
    if (existing != null) {
      for (final s in existing.schedule) {
        oldBookings[_slotKey(s)] = s.bookedCount;
      }
    }

    final merged = listing.schedule.map((s) {
      var booked = oldBookings[_slotKey(s)] ?? s.bookedCount;
      if (booked > s.maxPeople) booked = s.maxPeople;
      return DayTimeSlot(
        weekday: s.weekday,
        startMinutes: s.startMinutes,
        endMinutes: s.endMinutes,
        maxPeople: s.maxPeople,
        bookedCount: booked,
        specificDate: s.specificDate
      );
    }).toList();

    return _remote.updateListing(
      listing: listing,
      newImageLocalPaths: newImageLocalPaths,
      mergedSchedule: merged,
    );
  }

  @override
  Future<void> deleteListing(String id) => _remote.deleteListing(id);

  @override
  Future<void> bookSlot({
    required String listingId,
    required DayTimeSlot slot,
  }) {
    return _remote.bookSlot(
      listingId: listingId,
      weekday: slot.weekday,
      startMinutes: slot.startMinutes,
      endMinutes: slot.endMinutes,
      specificDateMs: slot.specificDate?.millisecondsSinceEpoch,
    );
  }
}
