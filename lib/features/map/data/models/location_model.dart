class LocationModel {
  final double latitude;
  final double longitude;
  final String localArea;
  final String city;
  final bool disasterDetected;
  
  LocationModel({
    required this.latitude,
    required this.longitude,
    this.localArea = "Unknown Area",
    this.city = "Unknown City",
    this.disasterDetected = false,
  });

  factory LocationModel.fromJson(Map<dynamic, dynamic> json) {
    return LocationModel(
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
    );
  }
} 