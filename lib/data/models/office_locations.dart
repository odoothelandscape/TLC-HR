class OfficeLocation {
  final double lat;
  final double long;

  OfficeLocation({required this.lat, required this.long});

  factory OfficeLocation.fromJson(Map<String, dynamic> json) {
    return OfficeLocation(
      lat: (json['lat'] as num).toDouble(),
      long: (json['long'] as num).toDouble(), // backend uses 'long'
    );
  }
}
