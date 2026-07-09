import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'dart:convert';

import '../../data/models/office_locations.dart';

class AttendanceChecker {
  Future<bool> checkAttendancePermission() async {
    bool isLocationEnabled = await _checkLocationPermission();

    if (!isLocationEnabled) {
      return false;
    }

    var pref = await SharedPreferences.getInstance();

    var attDistanceTemp = pref.getString('attendanceDistance');

    // Global fallback distance (meters), employee override already resolved
    // by the backend into 'map_distance'.
    double globalDistanceMeters =
        double.tryParse(attDistanceTemp.toString()) ?? 0;

    List<OfficeLocation> locations = [];

    // Preferred source: /api/get/attendance_setting locations[] — each entry
    // carries its own effective_distance resolved server-side.
    var settingLocationsTemp = pref.getString('attendance_locations');
    if (settingLocationsTemp != null && settingLocationsTemp.isNotEmpty) {
      locations = (jsonDecode(settingLocationsTemp) as List)
          .map((e) => OfficeLocation.fromJson(e))
          .toList();
    }

    // Fallback: legacy locations_list cached by the employee API
    // ({lat, long} without radius) for older backends.
    if (locations.isEmpty) {
      String raw = pref.getString('locations_list') ?? '[]';
      String fixedJson =
          raw.replaceAll('lat:', '"lat":').replaceAll('long:', '"long":');
      locations = (jsonDecode(fixedJson) as List)
          .map((e) => OfficeLocation.fromJson(e))
          .toList();
    }


    // Use best accuracy — medium/network-based location can be off by 100-500m.
    // getLastKnownPosition() is NOT used as fallback: stale cached coordinates
    // from a previous session could be from a completely different location.
    Position? userPosition = await _getAccuratePosition();

    if (userPosition == null) {
      return false;
    }


    // Loop through all office locations — each uses its own
    // effective_distance from the backend (no local priority math).
    for (var loc in locations) {
      double lat = loc.lat;
      double lng = loc.long;
      double allowedMeters = loc.effectiveDistance ?? globalDistanceMeters;

      double distanceInMeters = Geolocator.distanceBetween(
        lat,
        lng,
        userPosition.latitude,
        userPosition.longitude,
      );


      if (distanceInMeters <= allowedMeters) {
        return true; // ✅ Found a valid location
      }
    }

    return false; // ❌ No matching location
  }

  /// iOS/Android-compatible accurate position.
  ///
  /// Uses a position STREAM instead of getCurrentPosition() so iOS never hits
  /// a timeout trying to warm up the GPS chip.  We collect readings for up to
  /// [timeout] seconds and return the BEST (lowest accuracy value) one we see.
  /// If any reading beats [targetAccuracyMeters] we return early — no need to
  /// wait the full timeout.
  ///
  /// This replaces the old LocationAccuracy.medium approach (network-based,
  /// ±100-500 m) while staying safe on iOS.
  Future<Position?> _getAccuratePosition({
    double targetAccuracyMeters = 50,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final completer = Completer<Position?>();
    Position? bestSoFar;

    final sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    ).listen((pos) {
      // Keep the reading with the smallest accuracy radius
      if (bestSoFar == null || pos.accuracy < bestSoFar!.accuracy) {
        bestSoFar = pos;
      }
      // Return early once we're accurate enough
      if (pos.accuracy <= targetAccuracyMeters && !completer.isCompleted) {
        completer.complete(pos);
      }
    }, onError: (_) {
      if (!completer.isCompleted) completer.complete(bestSoFar);
    });

    // Hard timeout — return best available even if target not reached
    Future.delayed(timeout, () {
      if (!completer.isCompleted) completer.complete(bestSoFar);
    });

    final result = await completer.future;
    await sub.cancel();
    return result;
  }

  /// iOS-compatible location permission check using Geolocator's own API
  Future<bool> _checkLocationPermission() async {
    // Step 1: Check device-level location services
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Step 2: Check app-level permission using Geolocator (works correctly on iOS)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
}


// class AttendanceChecker {
//   double allowedDistanceInKm = 1.0; // You can adjust this value
//   double targetLatitude = 37.4219983; // Set your target latitude
//   double targetLongitude = -122.084; // Set your target longitude


  

//   // Function to check permission and location
//   Future<bool> checkAttendancePermission2() async {
//     // Request location permission

//     bool isLocationEnabled = await _checkLocationPermission();
//     print('isLocationEnabled----$isLocationEnabled');
//     var pref = await SharedPreferences.getInstance();

//     var attDistanceTemp = await pref.getString('attendanceDistance');
//     var officeLatTemp = await pref.getString('emp_lat');
//     var officeLongTemp = await pref.getString('emp_long');

//     allowedDistanceInKm = double.parse(attDistanceTemp.toString()) / 1000;
//     targetLatitude = double.parse(officeLatTemp.toString());
//     targetLongitude = double.parse(officeLongTemp.toString());

//     print(
//         ' allowedDistanceInKm----$allowedDistanceInKm $targetLatitude $targetLongitude');
//     print('isLocationEnabled----------$isLocationEnabled');
//     if (!isLocationEnabled) {
//       print('isLocationEnabled2----------$isLocationEnabled');
//       return false;
//     }

//     print(
//         'target----${targetLatitude} ${targetLongitude}  : ${allowedDistanceInKm}');
//     // Get user's current position
//     Position userPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);

//     double distanceInKm = Geolocator.distanceBetween(
//       targetLatitude,
//       targetLongitude,
//       userPosition.latitude,
//       userPosition.longitude,
//     );

//     if (distanceInKm / 1000 <= allowedDistanceInKm) {
//       return true; // Attendance permission granted
//     } else {
//       return false; // Attendance permission denied
//     }
//   }

//   // Function to check location permission
//   Future<bool> _checkLocationPermission2() async {
//     if (await Permission.location.isGranted) {
//       return true;
//     } else {
//       var status = await Permission.location.request();
//       return status.isGranted;
//     }
//   }
// }
