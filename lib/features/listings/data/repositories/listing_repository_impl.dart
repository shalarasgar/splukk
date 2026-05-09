import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
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
  Future<Either<Failure, FarmListing?>> getListing(String id) async {
    try {
      final res = await _remote.getListing(id);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final id = await _remote.createListing(
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
      return Right(id);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateListing({
    required FarmListing listing,
    required List<String> newImageLocalPaths,
  }) async {
    try {
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
          specificDate: s.specificDate,
        );
      }).toList();

      await _remote.updateListing(
        listing: listing,
        newImageLocalPaths: newImageLocalPaths,
        mergedSchedule: merged,
        expiresAt: listing.expiresAt,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteListing(String id) async {
    try {
      await _remote.deleteListing(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> bookSlot({
    required String listingId,
    required DayTimeSlot slot,
  }) async {
    try {
      await _remote.bookSlot(
        listingId: listingId,
        weekday: slot.weekday,
        startMinutes: slot.startMinutes,
        endMinutes: slot.endMinutes,
        specificDateMs: slot.specificDate?.millisecondsSinceEpoch,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
