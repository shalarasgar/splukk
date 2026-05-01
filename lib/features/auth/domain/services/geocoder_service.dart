/// Domain-слой: абстракция для геокодирования адресов.
/// AuthBloc/UseCases зависят только от этого интерфейса,
/// а не от конкретной реализации (geocoding/nominatim).
abstract class GeocoderService {
  /// Возвращает координаты по адресным компонентам.
  /// Возвращает null, если адрес не найден.
  Future<GeoPoint?> resolveCoordinates({
    required String street,
    required String streetNumber,
    required String postalCode,
    required String city,
    required String state,
    required String country,
  });
}

class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
}
