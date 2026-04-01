import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
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
    var locationsTemp = pref.getString('locations_list'); // JSON list

    print('locationsTemp-----------${locationsTemp}');

    allowedDistanceInKm = double.parse(attDistanceTemp.toString()) / 1000;

    print(' allowedDistanceInKm----$allowedDistanceInKm  : ${locationsTemp}');

    // Decode JSON list
    //  List<dynamic> locations = jsonDecode(locationsTemp ?? '[]');

    String raw = locationsTemp ?? '[]';

// Convert invalid string → valid JSON
    String fixedJson =
        raw.replaceAll('lat:', '"lat":').replaceAll('long:', '"long":');

    print('fixedJson-----------$fixedJson');

    List<OfficeLocation> locations = (jsonDecode(fixedJson) as List)
        .map((e) => OfficeLocation.fromJson(e))
        .toList();

    // List<OfficeLocation> locations = (jsonDecode(locationsTemp ?? '[]') as List)
    //     .map((e) => OfficeLocation.fromJson(e))
    //     .toList();

    print('locations-----------${locations.length}');

    // Get user current location
    Position userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

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

      print('Checking location: $lat, $lng => $distanceInKm km');

      if (distanceInKm <= allowedDistanceInKm) {
        return true; // ✅ Found a valid location
      }
    }

    return false; // ❌ No matching location
  }

  Future<bool> _checkLocationPermission() async {
    if (await Permission.location.isGranted) {
      return true;
    } else {
      var status = await Permission.location.request();
      return status.isGranted;
    }
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
