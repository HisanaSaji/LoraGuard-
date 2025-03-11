import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lora2/core/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lora2/core/models/alert_model.dart';
import 'package:lora2/core/services/geocoding_service.dart';
import 'package:lora2/features/alerts/presentation/cubit/alert_cubit.dart';
import '../../data/models/location_model.dart';
import '../../data/repositories/location_repository.dart';
import 'dart:async';
import 'package:lora2/features/alerts/services/notification_service.dart';
import 'package:lora2/features/map/presentation/widgets/location_pin.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Use Firebase for real-time location updates
  final LocationRepository _locationRepository = LocationRepository();
  final GeocodingService _geocodingService = GeocodingService();
  StreamSubscription? _locationSubscription;
  LocationModel? _currentLocation = LocationModel(latitude: 8.5241, longitude: 76.9366, city: "Thiruvananthapuram"); // Default location
  final MapController _mapController = MapController();
  String? _errorMessage;
  bool _isMapCentered = true; // Track if map is centered on user's location
  bool _previousDisasterState = false; // Track previous disaster state to avoid duplicate alerts
  final NotificationService _notificationService = NotificationService();
  StreamSubscription? _alertDeletedSubscription;
  
  @override
  void initState() {
    super.initState();
    print('MapScreen initialized');
    _setupLocationListener(); // Connect to Firebase for location updates
    _listenForAlertDeletions();
  }
  
  void _listenForAlertDeletions() {
    final alertCubit = context.read<AlertCubit>();
    _alertDeletedSubscription = alertCubit.onDisasterDeleted.listen((_) {
      // When a disaster alert is deleted, clear the disaster state
      setState(() {
        _previousDisasterState = false;
      });
    });
  }

  // Set up listener for location updates from Firebase
  void _setupLocationListener() {
    try {
      print('Setting up location listener...');
      _locationSubscription = _locationRepository.getLocationUpdates().listen(
        (locationData) async {
          print('Received location update: ${locationData.latitude}, ${locationData.longitude}');
          
          // Perform reverse geocoding to get place names
          GeocodingResult placeInfo;
          try {
            placeInfo = await _geocodingService.reverseGeocode(
              locationData.latitude, 
              locationData.longitude
            );
          } catch (e) {
            print('Error during geocoding: $e');
            placeInfo = GeocodingResult(
              localArea: "Unknown Area",
              city: "Unknown City"
            );
          }
          
          // Create updated location model with place information
          final updatedLocation = LocationModel(
            latitude: locationData.latitude,
            longitude: locationData.longitude,
            localArea: placeInfo.localArea,
            city: placeInfo.city,
            // For demo purposes, simulate disaster detection
            // In a real app, this would come from the server
            disasterDetected: locationData.latitude > 8.52 && locationData.longitude > 76.93
          );
          
          // Check if this is a new disaster (wasn't detected before)
          bool isNewDisaster = updatedLocation.disasterDetected && !_previousDisasterState;
          
          if (isNewDisaster) {
            // Show notification based on user preferences
            _showDisasterNotification(updatedLocation.localArea, updatedLocation.city);
            
            // Add to alerts (regardless of notification settings)
            _addDisasterAlert(updatedLocation.localArea, updatedLocation.city);
          }
          
          setState(() {
            _currentLocation = updatedLocation;
            _errorMessage = null;
            _previousDisasterState = updatedLocation.disasterDetected;
            
            // If map is centered, update the map view to follow the new location
            if (_isMapCentered) {
              _recenterMap();
            }
          });
        },
        onError: (error) {
          print('Error receiving location updates: $error');
          setState(() {
            _errorMessage = 'Failed to get location updates: $error';
          });
        },
      );
    } catch (e) {
      print('Exception setting up location listener: $e');
      setState(() {
        _errorMessage = 'Failed to initialize location tracking: $e';
      });
    }
  }
  
  // Show notification for disaster
  void _showDisasterNotification(String localArea, String cityName) {
    _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Alert',
      body: 'DISASTER DETECTED in $localArea, $cityName',
    );
  }
  
  // Add disaster to alerts
  void _addDisasterAlert(String localArea, String cityName) {
    final alertCubit = context.read<AlertCubit>();
    alertCubit.addAlert(
      location: cityName,
      description: 'DISASTER DETECTED in $localArea, $cityName',
    );
  }

  // Method to recenter the map to user's location
  void _recenterMap() {
    if (_currentLocation != null) {
      _mapController.move(
        LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        15.0, // Increased zoom level for better detail
      );
      setState(() {
        _isMapCentered = true;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Show the map with real-time data from Firebase
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Location'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
              zoom: 15.0, // Increased initial zoom level
              onPositionChanged: (MapPosition position, bool hasGesture) {
                if (hasGesture) {
                  // User has moved the map
                  setState(() {
                    _isMapCentered = false;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      _currentLocation!.latitude,
                      _currentLocation!.longitude,
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: _previousDisasterState ? Colors.red : Colors.blue,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Recenter button
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: _recenterMap,
              backgroundColor: _isMapCentered ? Colors.grey : AppTheme.primaryOrange,
              child: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
          // Error message display if there's an issue with Firebase
          if (_errorMessage != null)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.withOpacity(0.8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          // Disaster warning banner
          if (_previousDisasterState && _currentLocation != null)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Dismissible(
                key: const Key('disaster_banner'),
                direction: DismissDirection.horizontal,
                onDismissed: (_) {
                  setState(() {
                    _previousDisasterState = false;
                  });
                },
                background: Container(
                  color: Colors.red.withOpacity(0.5),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.red.withOpacity(0.8),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'DISASTER DETECTED in ${_currentLocation!.localArea}, ${_currentLocation!.city}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _locationSubscription?.cancel();
    _alertDeletedSubscription?.cancel();
    super.dispose();
  }
}