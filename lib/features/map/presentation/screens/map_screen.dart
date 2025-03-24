import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lora2/features/map/data/models/location_model.dart';
import 'package:lora2/features/map/data/repositories/firebase_location_repository.dart';
import 'package:lora2/features/alerts/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lora2/core/theme/app_theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lora2/features/alerts/cubit/alert_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with AutomaticKeepAliveClientMixin {
  // Repository
  late FirebaseLocationRepository _locationRepository;
  
  // State variables
  bool _isLoading = true;
  bool _showErrorMessage = false;
  String _errorMessage = '';
  List<LocationModel> _locations = [];
  bool _initialLoad = true;
  
  // Controller
  late final MapController _mapController;
  bool _isMapReady = false;
  
  // Subscriptions
  StreamSubscription<List<LocationModel>>? _locationSubscription;
  Timer? _timeoutTimer;
  
  // Disaster details
  LocationModel? _currentDisaster;
  bool _shouldShowDisasterDetails = false;
  String? _lastKnownDisasterId;
  
  // Notification handling
  LatLng? _notificationTargetLocation;
  String? _notificationTargetDisasterId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('MapScreen: initState called');
    
    // Initialize controllers
    _mapController = MapController();
    
    // Initialize the repository
    _locationRepository = FirebaseLocationRepository();
    
    // Set up Firebase listeners immediately
    _setupFirebaseListeners();
  }
  
  Future<void> _checkForNotificationData() async {
    try {
      print('MapScreen: Checking for notification data');
      final prefs = await SharedPreferences.getInstance();
      
      // Check if we have notification location data
      final String? locationString = prefs.getString('disaster_notification_location');
      final String? disasterId = prefs.getString('disaster_notification_id');
      
      if (locationString != null && locationString.isNotEmpty) {
        print('MapScreen: Found notification location data: $locationString');
        
        // Parse the location string (format: "latitude,longitude")
        final parts = locationString.split(',');
        if (parts.length == 2) {
          final double? latitude = double.tryParse(parts[0]);
          final double? longitude = double.tryParse(parts[1]);
          
          if (latitude != null && longitude != null) {
            print('MapScreen: Setting notification target location: $latitude, $longitude');
            _notificationTargetLocation = LatLng(latitude, longitude);
            
            // Create a special target disaster to center on
            if (disasterId != null && disasterId.isNotEmpty) {
              _notificationTargetDisasterId = disasterId;
            }
          }
        }
        
        // Clear the notification data after using it
        await prefs.remove('disaster_notification_location');
        await prefs.remove('disaster_notification_id');
      }
    } catch (e) {
      print('MapScreen: Error checking for notification data: $e');
    }
  }

  void _initTimeoutTimer() {
    // Set a longer timeout (15 seconds) to give Firebase more time to connect
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && _isLoading) {
        print('MapScreen: Loading timed out, using fallback location');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load location data within 15 seconds. Please check your internet connection and try refreshing.';
          _showErrorMessage = true;
        });
      }
    });
  }

  Future<String> _getPlaceNameFromCoordinates(double latitude, double longitude) async {
    print('Attempting to get place name for coordinates: $latitude, $longitude');
    
    // Validate coordinates
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      print('Invalid coordinates detected: lat=$latitude, lng=$longitude');
      return 'Invalid Location';
    }

    // Maximum number of retries
    int maxRetries = 3;
    int currentTry = 0;
    
    while (currentTry < maxRetries) {
      try {
        currentTry++;
        print('Geocoding attempt $currentTry of $maxRetries');
        
        // Add timeout to geocoding request
        List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude,
          longitude,
          localeIdentifier: 'en_US', // Force English locale
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('Geocoding request timed out');
            throw TimeoutException('Geocoding request timed out');
          },
        );

        print('Received ${placemarks.length} placemarks from geocoding service');
        
        if (placemarks.isEmpty) {
          print('No placemarks returned from geocoding service');
          if (currentTry < maxRetries) {
            print('Retrying...');
            await Future.delayed(Duration(seconds: 1)); // Wait before retry
            continue;
          }
          return 'Coordinates: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
        }

        Placemark place = placemarks[0];
        
        // Debug print all available fields
        print('''Detailed placemark data:
          name: ${place.name}
          street: ${place.street}
          locality (city): ${place.locality}
          subLocality: ${place.subLocality}
          subAdministrativeArea (district): ${place.subAdministrativeArea}
          administrativeArea (state): ${place.administrativeArea}
          postalCode: ${place.postalCode}
          country: ${place.country}
          isoCountryCode: ${place.isoCountryCode}
        ''');

        // Build location name with all available components
        List<String> locationParts = [];
        
        // Try district first as it's often most reliable
        if (place.subAdministrativeArea?.isNotEmpty == true) {
          locationParts.add(place.subAdministrativeArea!);
        }
        // Then try city
        else if (place.locality?.isNotEmpty == true) {
          locationParts.add(place.locality!);
        }
        // Then try subLocality
        else if (place.subLocality?.isNotEmpty == true) {
          locationParts.add(place.subLocality!);
        }
        
        // Add state/region if available and not already included
        if (place.administrativeArea?.isNotEmpty == true && 
            !locationParts.contains(place.administrativeArea)) {
          locationParts.add(place.administrativeArea!);
        }
        
        // Add country as last resort if we have nothing else
        if (locationParts.isEmpty && place.country?.isNotEmpty == true) {
          locationParts.add(place.country!);
        }

        // If we have location parts, join them
        if (locationParts.isNotEmpty) {
          String locationName = locationParts.join(", ");
          print('Successfully generated location name: $locationName');
          return locationName;
        }

        // If we get here with no location parts, return coordinates
        return 'Coordinates: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

      } catch (e, stackTrace) {
        print('Error during geocoding attempt $currentTry:');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        
        if (currentTry < maxRetries) {
          print('Retrying after error...');
          await Future.delayed(Duration(seconds: 1)); // Wait before retry
          continue;
        }
        
        if (e is TimeoutException) {
          return 'Coordinates: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
        }
        
        return 'Coordinates: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
      }
    }
    
    // If we get here, all retries failed
    return 'Coordinates: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  void _setupFirebaseListeners() {
    print('MapScreen: Setting up Firebase listeners');
    _locationSubscription = _locationRepository.getLocationsStream().listen(
      (locations) async {
        print('MapScreen: Received ${locations.length} locations');
        
        if (locations.isEmpty) {
          setState(() {
            _isLoading = false;
            _locations = [];
          });
          return;
        }

        // Get the most recent location
        final latestLocation = locations.first;
        
        setState(() {
          _isLoading = false;
          _showErrorMessage = false;
          _locations = locations;
        });

        // Move map to new location if we have a controller
        if (_mapController != null && _isMapReady) {
          print('MapScreen: Moving map to new location: ${latestLocation.latitude}, ${latestLocation.longitude}');
          _mapController.move(
            LatLng(latestLocation.latitude, latestLocation.longitude),
            13.0
          );
        }

        // Get place name from coordinates for notification
        try {
          final placeName = await _getPlaceNameFromCoordinates(
            latestLocation.latitude,
            latestLocation.longitude
          );
          
          if (!_initialLoad) {
            print('MapScreen: New location detected at $placeName');
            
            // Create description based on whether we got a place name or coordinates
            String description;
            if (placeName.startsWith('Coordinates:')) {
              description = 'DISASTER DETECTED at $placeName';
            } else {
              description = 'DISASTER DETECTED in $placeName';
            }
            
            // Add alert with place name and description
            if (mounted) {
              context.read<AlertCubit>().addAlert(
                location: placeName,
                description: description,
              );
              
              // Show notification
              NotificationService().showNotification(
                title: 'Location Update',
                body: description,
              );
            }
          }
        } catch (e) {
          print('MapScreen: Error processing new location: $e');
          // Add alert with error state
          if (mounted && !_initialLoad) {
            context.read<AlertCubit>().addAlert(
              location: 'Error',
              description: 'DISASTER DETECTED - Location Error',
            );
          }
        }

        _initialLoad = false;
      },
      onError: (error) {
        print('MapScreen: Error in location stream: $error');
        setState(() {
          _isLoading = false;
          _showErrorMessage = true;
          _errorMessage = 'Failed to load locations: $error';
        });
      },
    );

    // Initialize timeout timer
    _initTimeoutTimer();
  }

  void _showDisasterNotification(LocationModel disaster) {
    print('MapScreen: Showing notification for disaster: ${disaster.id}');
    
    // Create notification payload for navigation
    final Map<String, dynamic> payload = {
      'type': 'disaster',
      'id': disaster.id,
      'latitude': disaster.latitude.toString(),
      'longitude': disaster.longitude.toString(),
    };
    
    // Show the notification
    NotificationService().showNotification(
      title: 'New Disaster Alert!',
      body: 'A disaster has been reported at: ${disaster.latitude}, ${disaster.longitude}',
      payload: jsonEncode(payload),
    );
  }

  void _centerMapOnDisaster() {
    print('MapScreen: Centering map on disaster');
    
    // If we have a current disaster, center on that
    if (_currentDisaster != null) {
      _mapController.move(
        LatLng(_currentDisaster!.latitude, _currentDisaster!.longitude),
        13.0,
      );
    } 
    // Otherwise center on the most recent location
    else if (_locations.isNotEmpty) {
      _mapController.move(
        LatLng(_locations.first.latitude, _locations.first.longitude),
        13.0,
      );
    }
  }

  @override
  void dispose() {
    print('MapScreen: dispose called');
    _locationSubscription?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Map'),
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_showErrorMessage)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_locations.isEmpty)
            const Center(
              child: Text('No location data available'),
            )
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(_locations.first.latitude, _locations.first.longitude),
                initialZoom: 13.0,
                onMapReady: () {
                  setState(() {
                    _isMapReady = true;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: _locations.map((location) => Marker(
                    point: LatLng(location.latitude, location.longitude),
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  )).toList(),
                ),
              ],
            ),
          if (!_isLoading && _locations.isNotEmpty && _isMapReady)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () {
                  if (_locations.isNotEmpty) {
                    try {
                      _mapController.move(
                        LatLng(_locations.first.latitude, _locations.first.longitude),
                        13.0
                      );
                    } catch (e) {
                      print('MapScreen: Error moving map: $e');
                    }
                  }
                },
                child: const Icon(Icons.my_location),
                tooltip: 'Recenter Map',
              ),
            ),
        ],
      ),
    );
  }

  void _showDisasterDetails(LocationModel disaster) {
    if (mounted) {
      setState(() {
        _currentDisaster = disaster;
        _shouldShowDisasterDetails = true;
      });
    }
  }

  Widget _buildDisasterDetailsPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _currentDisaster?.status ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _shouldShowDisasterDetails = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _currentDisaster?.description ?? 'No description available',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Location: ${_currentDisaster!.latitude}, ${_currentDisaster!.longitude}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                'Reported: ${DateFormat.yMMMd().add_jm().format(_currentDisaster!.timestamp)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.navigation),
                    label: const Text('Navigate'),
                    onPressed: () {
                      // Open navigation in Google Maps
                      final url = 'https://www.google.com/maps/dir/?api=1&destination=${_currentDisaster!.latitude},${_currentDisaster!.longitude}';
                      launchUrl(Uri.parse(url));
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    onPressed: () {
                      // Debug logging
                      print('DEBUG: Attempting to share disaster information');
                      print('DEBUG: Current disaster data: ${_currentDisaster?.toString()}');
                      
                      // Share disaster information
                      final shareText = 'Disaster alert at ${_currentDisaster!.latitude}, ${_currentDisaster!.longitude}: ${_currentDisaster!.description}';
                      print('DEBUG: Generated share text: $shareText');
                      
                      try {
                        Share.share(
                          shareText,
                          subject: 'Disaster Alert Information',
                        ).then((_) {
                          print('DEBUG: Share.share completed successfully');
                        }).catchError((e) {
                          print('DEBUG: Error while sharing: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to share: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        });
                      } catch (e) {
                        print('DEBUG: Error while sharing: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to share: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}