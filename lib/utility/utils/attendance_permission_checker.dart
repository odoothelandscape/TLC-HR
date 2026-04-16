import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import '../../data/models/office_locations.dart';

class AttendanceChecker {
  double allowedDistanceInKm = 1.0;

  Future<bool> checkAttendancePermission() async {
    bool isLocationEnabled = await _checkLocationPermission();

    if (!isLocationEnabled) {
      return false;
    }

    var pref = await SharedPreferences.getInstance();

    var attDistanceTemp = pref.getString('attendanceDistance');
    var locationsTemp = pref.getString('locations_list');

    print('locationsTemp-----------${locationsTemp}');

    allowedDistanceInKm = double.parse(attDistanceTemp.toString()) / 1000;

    print(' allowedDistanceInKm----$allowedDistanceInKm  : ${locationsTemp}');

    String raw = locationsTemp ?? '[]';

    // Convert invalid string → valid JSON
    String fixedJson =
        raw.replaceAll('lat:', '"lat":').replaceAll('long:', '"long":');

    print('fixedJson-----------$fixedJson');

    List<OfficeLocation> locations = (jsonDecode(fixedJson) as List)
        .map((e) => OfficeLocation.fromJson(e))
        .toList();

    print('locations-----------${locations.length}');

    // Get user current location — use medium accuracy with timeout for iOS
    Position? userPosition;
    try {
      userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      print('getCurrentPosition failed: $e — trying last known position');
      userPosition = await Geolocator.getLastKnownPosition();
    }

    if (userPosition == null) {
      print('Could not obtain location');
      return false;
    }

    print('userPosition: ${userPosition.latitude}, ${userPosition.longitude}');

    // Loop through all office locations
    for (var loc in locations) {
      double lat = loc.lat;
      double lng = loc.long;

      double distanceInMeters = Geolocator.distanceBetween(
        lat,
        lng,
        userPosition.latitude,
        userPosition.longitude,
      );

      double distanceInKm = distanceInMeters / 1000;

      print('Checking location: $lat, $lng => ${distanceInMeters.toStringAsFixed(0)}m (allowed: ${allowedDistanceInKm * 1000}m)');

      if (distanceInKm <= allowedDistanceInKm) {
        return true; // ✅ Found a valid location
      }
    }

    return false; // ❌ No matching location
  }

  /// iOS-compatible location permission check using Geolocator's own API
  Future<bool> _checkLocationPermission() async {
    // Step 1: Check device-level location services
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled on device');
      return false;
    }

    // Step 2: Check app-level permission using Geolocator (works correctly on iOS)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied by user');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permission permanently denied — user must enable in Settings');
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
