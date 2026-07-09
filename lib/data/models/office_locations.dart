class OfficeLocation {
  final double lat;
  final double long;

  /// Per-location allowed radius in meters, already resolved by the backend
  /// (employee override > location allowed_area > global setting).
  /// Null when the backend didn't send it (older contract) — caller falls
  /// back to the single global 'attendanceDistance' value.
  final double? effectiveDistance;
  final String? remark;

  OfficeLocation({
    required this.lat,
    required this.long,
    this.effectiveDistance,
    this.remark,
  });

  factory OfficeLocation.fromJson(Map<String, dynamic> json) {
    return OfficeLocation(
      // new contract uses latitude/longitude, old prefs cache used lat/long
      lat: ((json['latitude'] ?? json['lat']) as num).toDouble(),
      long: ((json['longitude'] ?? json['long']) as num).toDouble(),
      effectiveDistance: json['effective_distance'] == null
          ? null
          : (json['effective_distance'] as num).toDouble(),
      remark: json['remark']?.toString(),
    );
  }
}
