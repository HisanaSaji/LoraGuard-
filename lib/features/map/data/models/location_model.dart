class LocationModel {
  final String id;
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final DateTime timestamp;
  final String? status;
  final String? description;
  
  LocationModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.timestamp,
    this.status,
    this.description,
  });
  
  factory LocationModel.fromJson(Map<dynamic, dynamic> json) {
    // Parse timestamp - could be milliseconds since epoch or ISO string
    DateTime parsedTimestamp;
    if (json['timestamp'] is int) {
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp']);
    } else if (json['timestamp'] is String) {
      try {
        parsedTimestamp = DateTime.parse(json['timestamp']);
      } catch (e) {
        // If parse fails, use current time
        parsedTimestamp = DateTime.now();
      }
    } else {
      // Default to current time if timestamp is missing or invalid
      parsedTimestamp = DateTime.now();
    }
    
    return LocationModel(
      id: json['id'] ?? 'unknown',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      altitude: _parseDouble(json['altitude'] ?? 0.0),
      speed: _parseDouble(json['speed'] ?? 0.0),
      timestamp: parsedTimestamp,
      status: json['status'],
      description: json['description'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'description': description,
    };
  }
  
  // Helper method to safely parse doubles from various types
  static double _parseDouble(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }
  
  // Create a copy with modified fields
  LocationModel copyWith({
    String? id,
    double? latitude,
    double? longitude,
    double? altitude,
    double? speed,
    DateTime? timestamp,
    String? status,
    String? description,
  }) {
    return LocationModel(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }
  
  @override
  String toString() {
    return 'LocationModel(id: $id, lat: $latitude, lng: $longitude, time: $timestamp, status: $status)';
  }
} 