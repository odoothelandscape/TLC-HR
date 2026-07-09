import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Reverse geocoding via the free OpenStreetMap Nominatim service.
/// No API key and no native plugin needed (the `geocoding` package was
/// removed on purpose because of its Google Maps dependency).
class ReverseGeocode {
  /// Returns a human-readable address for [lat]/[long], or '' on any
  /// failure — the backend accepts an empty address (field is optional,
  /// max 512 chars).
  static Future<String> fromLatLong(double lat, double long) async {
    if (lat == 0 && long == 0) return '';
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$long&accept-language=en');
      final res = await http.get(uri, headers: {
        'User-Agent': 'TLC-HR-App/1.0 (attendance address lookup)',
      }).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return '';
      final body = json.decode(res.body);
      final display = (body['display_name'] ?? '').toString();
      return display.length > 512 ? display.substring(0, 512) : display;
    } catch (_) {
      return '';
    }
  }
}
