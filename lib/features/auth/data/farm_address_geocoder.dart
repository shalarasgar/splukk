import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

/// Önce cihaz geocoder; sonuç yoksa OpenStreetMap Nominatim (Norveç vb. için daha güvenilir).
Future<Location?> resolveFarmCoordinates({
  required String street,
  required String streetNumber,
  required String postalCode,
  required String city,
  required String state,
  required String country,
}) async {
  final line1 = '$street $streetNumber'.trim();
  if (line1.isEmpty) return null;

  final p = postalCode.trim();
  final c = city.trim();
  final s = state.trim();
  final co = country.trim();

  final queries = <String>[];
  void addDistinct(String q) {
    final t = q.trim();
    if (t.isEmpty) return;
    if (!queries.contains(t)) queries.add(t);
  }

  // Norveç / İskandinav tipi: "Gate 31, 0159 Oslo, Norway"
  if (p.isNotEmpty && c.isNotEmpty && co.isNotEmpty) {
    addDistinct('$line1, $p $c, $co');
    if (s.isNotEmpty && s.toLowerCase() != c.toLowerCase()) {
      addDistinct('$line1, $p $c, $s, $co');
    }
  }
  if (c.isNotEmpty && co.isNotEmpty) {
    addDistinct('$line1, $c, $co');
  }
  // Eyalet ile ülke (şehir tekrarı olmadan)
  if (s.isNotEmpty && co.isNotEmpty && c.isNotEmpty) {
    addDistinct('$line1, $s, $co');
  }
  if (p.isNotEmpty && c.isNotEmpty && co.isNotEmpty) {
    addDistinct('$p $c, $co');
  }

  for (final q in queries) {
    try {
      final results = await locationFromAddress(q);
      if (results.isNotEmpty) return results.first;
    } on Object {
      continue;
    }
  }

  for (final q in queries) {
    final loc = await _nominatimSearch(q);
    if (loc != null) return loc;
  }

  return null;
}

/// https://operations.osmfoundation.org/policies/nominatim/ — tanımlı User-Agent ve makul hız.
Future<Location?> _nominatimSearch(String q) async {
  final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
    'q': q,
    'format': 'json',
    'limit': '1',
  });
  try {
    final res = await http
        .get(
          uri,
          headers: {
            'User-Agent': 'Splukk/1.0 (farmer registration)',
            'Accept-Language': 'nb,en',
          },
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) return null;
    final decoded = jsonDecode(res.body);
    if (decoded is! List<dynamic> || decoded.isEmpty) return null;
    final first = decoded.first;
    if (first is! Map<String, dynamic>) return null;
    final lat = double.tryParse('${first['lat']}');
    final lon = double.tryParse('${first['lon']}');
    if (lat == null || lon == null || !lat.isFinite || !lon.isFinite) {
      return null;
    }
    return Location(
      latitude: lat,
      longitude: lon,
      timestamp: DateTime.now().toUtc(),
    );
  } on Object {
    return null;
  }
}
