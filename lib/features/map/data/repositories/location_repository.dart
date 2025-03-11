import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/location_model.dart';

class LocationRepository {
  // Update reference to match the actual database structure
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref().child('disaster/location');
  
  Future<void> initializeDefaultLocation() async {
    try {
      // Check if data exists
      final snapshot = await _databaseReference.get();
      if (!snapshot.exists) {
        // No data exists, set default data
        await updateLocation(8.5241, 76.9366);
        print('Initialized default location data');
      }
    } catch (e) {
      print('Error initializing default location: $e');
      throw Exception('Failed to initialize default location');
    }
  }

  Stream<LocationModel> getLocationUpdates() {
    print('Starting location updates stream...');
    return _databaseReference.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      print('Received Firebase data: $data');
      
      if (data != null) {
        try {
          // Extract only latitude and longitude
          final latitude = double.parse(data['latitude']?.toString() ?? '0.0');
          final longitude = double.parse(data['longitude']?.toString() ?? '0.0');
          
          final location = LocationModel(
            latitude: latitude,
            longitude: longitude,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            disasterDetected: false,
            localArea: 'Unknown Area',
            city: 'Unknown City',
          );
          
          print('Created LocationModel: ${location.toString()}');
          return location;
        } catch (e) {
          print('Error parsing location data: $e');
          rethrow;
        }
      } else {
        print('No location data available in Firebase');
        throw Exception('No location data available');
      }
    });
  }

  // Method to update location data
  Future<void> updateLocation(double latitude, double longitude) async {
    try {
      await _databaseReference.set({
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      });
      
      print('Updated location in Firebase: lat=$latitude, lon=$longitude');
    } catch (e) {
      print('Error updating location: $e');
      throw Exception('Failed to update location');
    }
  }
} 