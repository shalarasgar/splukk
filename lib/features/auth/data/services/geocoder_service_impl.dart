import '../../domain/services/geocoder_service.dart';
import '../farm_address_geocoder.dart';

/// Data-слой: реализация GeocoderService, которая использует
/// устройственный геокодер и Nominatim как fallback.
class GeocoderServiceImpl implements GeocoderService {
  @override
  Future<GeoPoint?> resolveCoordinates({
    required String street,
    required String streetNumber,
    required String postalCode,
    required String city,
    required String state,
    required String country,
  }) async {
    final loc = await resolveFarmCoordinates(
      street: street,
      streetNumber: streetNumber,
      postalCode: postalCode,
      city: city,
      state: state,
      country: country,
    );
    if (loc == null) return null;
    return GeoPoint(latitude: loc.latitude, longitude: loc.longitude);
  }
}
