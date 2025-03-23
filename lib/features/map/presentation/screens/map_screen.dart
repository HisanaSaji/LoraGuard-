import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lora2/features/map/data/models/location_model.dart';
import 'package:lora2/features/map/data/repositories/firebase_location_repository.dart';
import 'package:lora2/features/alerts/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lora2/core/theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Repository
  late FirebaseLocationRepository _locationRepository;
  
  // State variables
  bool _isLoading = true;
  bool _showErrorMessage = false;
  String _errorMessage = '';
  List<LocationModel> _locations = [];
  bool _initialLoad = true;
  
  // Controller
  late MapController _mapController;
  
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
  void initState() {
    super.initState();
    print('MapScreen: initState called');
    
    // Initialize the map controller
    _mapController = MapController();
    
    // Initialize the repository
    _locationRepository = FirebaseLocationRepository();
    
    // Check for notification data
    _checkForNotificationData();
    
    // Set up Firebase listeners immediately without delay
    _setupFirebaseListeners();
    
    // Set a timeout to prevent indefinite loading
    _initTimeoutTimer();
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
    // Set a strict timeout (5 seconds) to prevent indefinite loading
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isLoading) {
        print('MapScreen: Loading timed out, using fallback location');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load location data. Showing default view.';
          _showErrorMessage = true;
        });
      }
    });
  }

  void _setupFirebaseListeners() {
    print('MapScreen: Setting up Firebase listeners');
    
    // Listen for location updates
    _locationSubscription = _locationRepository.locationStream.listen(
      (locations) {
        print('MapScreen: Received ${locations.length} locations from Firebase');
        
        if (mounted) {
          setState(() {
            _locations = locations;
            _isLoading = false;
            _showErrorMessage = false;
            
            // First check if we have a notification target location
            if (_notificationTargetLocation != null) {
              print('MapScreen: Centering on notification target location');
              
              // Center on the notification target location
              _mapController.move(_notificationTargetLocation!, 13.0);
              
              // If we have a target disaster ID, show details for that disaster
              if (_notificationTargetDisasterId != null && _notificationTargetDisasterId!.isNotEmpty) {
                final targetDisaster = locations.firstWhere(
                  (loc) => loc.id == _notificationTargetDisasterId,
                  orElse: () => locations.first,
                );
                
                _showDisasterDetails(targetDisaster);
              }
              
              // Clear the notification target so we don't keep centering on it
              _notificationTargetLocation = null;
              _notificationTargetDisasterId = null;
            }
            // Otherwise, if there's a current disaster or we're in initial load, center the map
            else if (_currentDisaster != null || _initialLoad) {
              _centerMapOnDisaster();
              _initialLoad = false;
            }
          });
          
          // Auto-show details for the most recent location if we're not showing details for notification target
          if (locations.isNotEmpty && _shouldShowDisasterDetails && _currentDisaster == null) {
            _showDisasterDetails(locations.first);
          }
          
          // Show notification for the most recent disaster if it's new
          if (locations.isNotEmpty && !_initialLoad && _lastKnownDisasterId != locations.first.id) {
            _lastKnownDisasterId = locations.first.id;
            _showDisasterNotification(locations.first);
          }
        }
        },
        onError: (error) {
        print('MapScreen: Error from location stream: $error');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Error loading locations: ${error.toString()}';
            _showErrorMessage = true;
          });
        }
      },
    );
    
    // Listen for location deletions
    _locationRepository.listenForLocationDeletions((deletedId) {
      print('MapScreen: Location deleted: $deletedId');
      
      if (mounted) {
        // If the current disaster was deleted, clear it
        if (_currentDisaster?.id == deletedId) {
      setState(() {
            _currentDisaster = null;
            _shouldShowDisasterDetails = false;
      });
    }
  }
    });
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
    // Cancel all subscriptions
    _locationSubscription?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMap,
            tooltip: 'Refresh Map',
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerMapOnDisaster,
            tooltip: 'Center Map',
          ),
        ],
      ),
      body: Stack(
        children: [
          // The map
          _buildMapView(),
          
          // Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          
          // Error message
          if (_showErrorMessage)
            _buildErrorView(),
          
          // Disaster details panel
          if (_shouldShowDisasterDetails && _currentDisaster != null)
            _buildDisasterDetailsPanel(),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Connection'),
                  onPressed: _refreshMap,
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('Show Map Anyway'),
                  onPressed: () {
                    setState(() {
                      _showErrorMessage = false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    // If we're still loading and have no locations, show a placeholder
    if (_isLoading && _locations.isEmpty) {
      return const Center(
        child: Text('Loading map...'),
      );
    }
    
    // Default location (Philippines) if no locations are available
    final defaultLocation = LatLng(14.5995, 120.9842);
    
    // Use the first location from our list, or fall back to default
    final initialLocation = _locations.isNotEmpty
        ? LatLng(_locations.first.latitude, _locations.first.longitude)
        : defaultLocation;
    
    return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
        initialCenter: initialLocation,
        initialZoom: 10.0,
        onTap: (_, __) {
          // Hide disaster details when tapping on the map
          if (_shouldShowDisasterDetails) {
                  setState(() {
              _shouldShowDisasterDetails = false;
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
          markers: _buildMarkers(),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    
    for (final location in _locations) {
      final marker = Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(location.latitude, location.longitude),
        child: GestureDetector(
          onTap: () {
            // Show disaster details when tapping on a marker
            _showDisasterDetails(location);
          },
                    child: Icon(
                      Icons.location_on,
            color: _getMarkerColorForStatus(location.status),
                      size: 40,
          ),
        ),
      );
      
      markers.add(marker);
    }
    
    return markers;
  }

  Color _getMarkerColorForStatus(String? status) {
    switch (status?.toLowerCase() ?? 'default') {
      case 'active':
      case 'disaster':
        return Colors.red;
      case 'resolved':
        return Colors.green;
      case 'pending':
        return Colors.yellow;
      case 'default':
        return Colors.blue;
      default:
        return Colors.red;
    }
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
                      // Share disaster information
                      final shareText = 'Disaster alert at ${_currentDisaster!.latitude}, ${_currentDisaster!.longitude}: ${_currentDisaster!.description}';
                      Share.share(shareText);
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
  
  void _refreshMap() {
    print('MapScreen: Refreshing map');
    
    if (mounted) {
      setState(() {
        _isLoading = true;
        _showErrorMessage = false;
        
        // Clear the timeout timer and create a new one
        _timeoutTimer?.cancel();
        _initTimeoutTimer();
      });
      
      // Stop and restart Firebase listeners
    _locationSubscription?.cancel();
      _setupFirebaseListeners();
    }
  }
}