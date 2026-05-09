import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/listings_domain.dart';
import 'listing_form_state.dart';

class ListingFormCubit extends Cubit<ListingFormState> {
  final ListingRepository _repository;

  ListingFormCubit({required ListingRepository repository})
      : _repository = repository,
        super(ListingFormInitial());

  Future<void> submitForm({
    required String? existingListingId,
    required FarmListing? existingListing,
    required String farmerUid,
    required String farmName,
    required String city,
    required List<String> localImagePaths,
    required List<String> existingImageUrls,
    required PickingType pickingType,
    required int availabilityPercent,
    required int availabilityMessageIndex,
    required bool manualClosed,
    required String? description,
    required double latitude,
    required double longitude,
    required List<ListingProductLine> products,
    required List<DayTimeSlot> schedule,
  }) async {
    emit(ListingFormSaving());

    if (existingListingId == null) {
      final result = await _repository.createListing(
        farmerUid: farmerUid,
        farmName: farmName,
        city: city,
        newImageLocalPaths: localImagePaths,
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
      result.fold(
        (failure) => emit(ListingFormFailure(failure.message ?? 'Hata oluştu')),
        (_) => emit(ListingFormSuccess()),
      );
    } else {
      if (existingListing == null) {
        emit(const ListingFormFailure('Existing listing data is missing'));
        return;
      }

      final updated = FarmListing(
        id: existingListing.id,
        farmerUid: existingListing.farmerUid,
        farmName: farmName,
        city: city,
        imageUrls: List<String>.from(existingImageUrls),
        pickingType: pickingType,
        availabilityPercent: availabilityPercent,
        availabilityMessageIndex: availabilityMessageIndex,
        manualClosed: manualClosed,
        description: description,
        latitude: latitude,
        longitude: longitude,
        products: products,
        schedule: schedule,
        createdAt: existingListing.createdAt,
        updatedAt: existingListing.updatedAt,
        expiresAt: existingListing.expiresAt,
      );

      final result = await _repository.updateListing(
        listing: updated,
        newImageLocalPaths: localImagePaths,
      );
      result.fold(
        (failure) => emit(ListingFormFailure(failure.message ?? 'Hata oluştu')),
        (_) => emit(ListingFormSuccess()),
      );
    }
  }
}
