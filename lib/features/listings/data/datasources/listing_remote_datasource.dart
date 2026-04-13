import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_file/cross_file.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/listings_domain.dart';
import '../models/farm_listing_model.dart';

class ListingRemoteDataSource {
  ListingRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const _collection = 'farm_listings';

  Stream<List<FarmListing>> watchAllListings() {
    return _firestore
        .collection(_collection)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => FarmListingModel.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  Stream<List<FarmListing>> watchListingsForFarmer(String farmerUid) {
    return _firestore
        .collection(_collection)
        .where('farmerUid', isEqualTo: farmerUid)
        .snapshots()
        .map(
          (snap) {
            final list = snap.docs
                .map((d) => FarmListingModel.fromFirestore(d.id, d.data()))
                .toList();
            list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            return list;
          },
        );
  }

  Future<FarmListing?> getListing(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return FarmListingModel.fromFirestore(doc.id, data);
  }

  Future<List<String>> _uploadImages(String listingId, List<String> paths) async {
    final urls = <String>[];
    var i = 0;
    for (final path in paths) {
      if (path.isEmpty) continue;
      final bytes = await XFile(path).readAsBytes();
      if (bytes.isEmpty) continue;
      final ref = _storage
          .ref()
          .child('farm_listings/$listingId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      urls.add(await ref.getDownloadURL());
      i++;
    }
    return urls;
  }

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
  }) async {
    final doc = _firestore.collection(_collection).doc();
    final id = doc.id;
    final imageUrls = await _uploadImages(id, newImageLocalPaths);
    final now = FieldValue.serverTimestamp();
    final payload = FarmListingModel.toFirestoreMap(
      farmerUid: farmerUid,
      farmName: farmName,
      city: city,
      imageUrls: imageUrls,
      pickingType: pickingType,
      availabilityPercent: availabilityPercent,
      availabilityMessageIndex: availabilityMessageIndex,
      manualClosed: manualClosed,
      description: description,
      latitude: latitude,
      longitude: longitude,
      products: products,
      schedule: schedule,
      timestamp: now,
    );
    payload['createdAt'] = now;
    await doc.set(payload);
    return id;
  }

  Future<void> updateListing({
    required FarmListing listing,
    required List<String> newImageLocalPaths,
    required List<DayTimeSlot> mergedSchedule,
  }) async {
    final extraUrls =
        await _uploadImages(listing.id, newImageLocalPaths);
    final imageUrls = [...listing.imageUrls, ...extraUrls];
    final ref = _firestore.collection(_collection).doc(listing.id);
    final now = FieldValue.serverTimestamp();
    final payload = FarmListingModel.toFirestoreMap(
      farmerUid: listing.farmerUid,
      farmName: listing.farmName,
      city: listing.city,
      imageUrls: imageUrls,
      pickingType: listing.pickingType,
      availabilityPercent: listing.availabilityPercent,
      availabilityMessageIndex: listing.availabilityMessageIndex,
      manualClosed: listing.manualClosed,
      description: listing.description,
      latitude: listing.latitude,
      longitude: listing.longitude,
      products: listing.products,
      schedule: mergedSchedule,
      timestamp: now,
    );
    await ref.update(payload);
  }
}
