import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/location_model.dart';

class LocationRepository {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('locations');
  
  Future<void> initializeDefaultLocation() async {
    try {
      // Check if data exists
      final snapshot = await _database.get();
      if (!snapshot.exists) {
        // No data exists, set default data
        await updateLocation(LocationModel(
          latitude: 8.5241,
          longitude: 76.9366,
          localArea: 'Unknown Area',
          city: 'Unknown City',
          disasterDetected: false,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ));
        print('Initialized default location data');
      }
    } catch (e) {
      print('Error initializing default location: $e');
      throw Exception('Failed to initialize default location');
    }
  }

  Stream<LocationModel> getLocationUpdates() {
    print('Starting location updates stream...');
    return _database.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      print('Received Firebase data: $data');
      
      if (data == null) {
        print('No location data available in Firebase');
        return LocationModel(
          latitude: 8.5241,
          longitude: 76.9366,
          localArea: 'Unknown Area',
          city: 'Unknown City',
          disasterDetected: false,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
      }

      return LocationModel.fromJson(data);
    });
  }

  Future<void> updateLocation(LocationModel location) async {
    try {
      await _database.set(location.toJson());
      print('Updated location in Firebase: lat=${location.latitude}, lon=${location.longitude}');
    } catch (e) {
      print('Error updating location: $e');
      throw Exception('Failed to update location');
    }
  }
} 