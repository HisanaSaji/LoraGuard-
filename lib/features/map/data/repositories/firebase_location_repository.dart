import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:lora2/features/map/data/models/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lora2/features/alerts/services/notification_service.dart';

class FirebaseLocationRepository {
  static final FirebaseLocationRepository _instance = FirebaseLocationRepository._internal();
  factory FirebaseLocationRepository() => _instance;

  // Key for storing cached location
  static const String _locationCacheKey = 'last_known_location';
  static const String _lastNotifiedLocationKey = 'last_notified_location';
  
  // Time threshold for sleep state (10 minutes)
  static const Duration _sleepStateThreshold = Duration(minutes: 10);
  
  // Stream controllers
  final _locationController = StreamController<List<LocationModel>>.broadcast();
  final _locationDeletedController = StreamController<String>.broadcast();
  
  // For tracking location updates
  List<LocationModel> _locationsList = [];
  LocationModel? _lastKnownLocation;
  bool _hasEmittedLocation = false;
  bool _isInSleepState = false;
  Timer? _sleepStateTimer;
  DateTime _lastActivityTime = DateTime.now();
  
  // Reference to Firebase
  late DatabaseReference _disasterLocationRef;
  
  // Notification service
  final NotificationService _notificationService = NotificationService();

  FirebaseLocationRepository._internal() {
    print('FirebaseLocationRepository: Constructor called');
    _initDatabase();
  }

  Stream<List<LocationModel>> get locationStream => _locationController.stream;
  Stream<String> get locationDeletedStream => _locationDeletedController.stream;
  LocationModel? get lastKnownLocation => _lastKnownLocation;
  bool get isInSleepState => _isInSleepState;

  Future<void> _initDatabase() async {
    try {
      print('FirebaseLocationRepository: Starting database initialization');
      
      // Log Firebase instance details
      final app = FirebaseDatabase.instance.app;
      print('FirebaseLocationRepository: Firebase App name: ${app.name}');
      print('FirebaseLocationRepository: Firebase App options: ${app.options.asMap}');
      print('FirebaseLocationRepository: Firebase Database URL: ${FirebaseDatabase.instance.databaseURL}');
      
      // Set up the reference
      _disasterLocationRef = FirebaseDatabase.instance.ref().child('disaster/location');
      print('FirebaseLocationRepository: Database reference path: ${_disasterLocationRef.path}');
      
      // Test database connectivity
      try {
        print('FirebaseLocationRepository: Testing database connectivity...');
        final connectedRef = FirebaseDatabase.instance.ref('.info/connected');
        connectedRef.onValue.listen((event) {
          print('FirebaseLocationRepository: Connection state: ${event.snapshot.value}');
        });
      } catch (e) {
        print('FirebaseLocationRepository: Connectivity test failed: $e');
      }
      
      // Get initial data
      try {
        print('FirebaseLocationRepository: Attempting to read data...');
        final snapshot = await _disasterLocationRef.get();
        print('FirebaseLocationRepository: Data exists: ${snapshot.exists}');
        print('FirebaseLocationRepository: Raw data: ${snapshot.value}');
        
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          print('FirebaseLocationRepository: Data type: ${data.runtimeType}');
          print('FirebaseLocationRepository: Data keys: ${data.keys.toList()}');
          
          // Try to parse and emit initial location
          await _handleLocationData(data);
        }
      } catch (e, stackTrace) {
        print('FirebaseLocationRepository: Data read error: $e');
        print('FirebaseLocationRepository: Stack trace: $stackTrace');
      }
      
      // Set up the main listener for future updates
      await _setupFirebaseListener();
      
    } catch (e, stackTrace) {
      print('FirebaseLocationRepository: Initialization error: $e');
      print('FirebaseLocationRepository: Stack trace: $stackTrace');
    }
  }
  
  void _initSleepStateTimer() {
    print('FirebaseLocationRepository: Initializing sleep state timer');
    _sleepStateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      final timeSinceLastActivity = now.difference(_lastActivityTime);
      
      if (timeSinceLastActivity > _sleepStateThreshold && !_isInSleepState) {
        print('FirebaseLocationRepository: Entering sleep state');
        _isInSleepState = true;
        
        // Emit locations in sleep state (last known locations without updates)
        if (_locationsList.isNotEmpty) {
          _locationController.add(_locationsList);
        }
      } else if (timeSinceLastActivity <= _sleepStateThreshold && _isInSleepState) {
        print('FirebaseLocationRepository: Exiting sleep state');
        _isInSleepState = false;
      }
    });
  }

  Future<void> _loadCachedLocation() async {
    try {
      print('FirebaseLocationRepository: Loading cached location');
      final prefs = await SharedPreferences.getInstance();
      final cachedLocationJson = prefs.getString(_locationCacheKey);
      
      if (cachedLocationJson != null) {
        final locationMap = jsonDecode(cachedLocationJson);
        _lastKnownLocation = LocationModel.fromJson(locationMap);
        print('FirebaseLocationRepository: Loaded cached location: ${_lastKnownLocation!.latitude}, ${_lastKnownLocation!.longitude}');
        
        // Add the cached location to the list if we have nothing else
        if (_locationsList.isEmpty) {
          _locationsList = [_lastKnownLocation!];
          
          // Only emit if we haven't already
          if (!_hasEmittedLocation) {
            _locationController.add(_locationsList);
            _hasEmittedLocation = true;
          }
        }
      } else {
        print('FirebaseLocationRepository: No cached location found');
      }
    } catch (e) {
      print('FirebaseLocationRepository: Error loading cached location: $e');
    }
  }
  
  Future<void> _cacheLocation(LocationModel location) async {
    try {
      print('FirebaseLocationRepository: Caching location');
      final prefs = await SharedPreferences.getInstance();
      final locationJson = jsonEncode(location.toJson());
      await prefs.setString(_locationCacheKey, locationJson);
      print('FirebaseLocationRepository: Location cached successfully');
    } catch (e) {
      print('FirebaseLocationRepository: Error caching location: $e');
    }
  }

  Future<void> _handleLocationData(Map<dynamic, dynamic> data) async {
    try {
      final latitude = data['latitude'];
      final longitude = data['longitude'];
      
      if (latitude == null || longitude == null) {
        print('FirebaseLocationRepository: Missing latitude or longitude in data');
        return;
      }
      
      print('FirebaseLocationRepository: Raw latitude: $latitude (${latitude.runtimeType})');
      print('FirebaseLocationRepository: Raw longitude: $longitude (${longitude.runtimeType})');
      
      // Extract latitude and longitude directly from the data
      final parsedLatitude = (latitude is String) ? 
          double.parse(latitude.toString()) : 
          (latitude as num).toDouble();
      
      final parsedLongitude = (longitude is String) ? 
          double.parse(longitude.toString()) : 
          (longitude as num).toDouble();

      print('FirebaseLocationRepository: Parsed location - lat: $parsedLatitude, lng: $parsedLongitude');

      // Create location model
      final location = LocationModel(
        id: 'current',
        latitude: parsedLatitude,
        longitude: parsedLongitude,
        altitude: 0.0,
        speed: 0.0,
        timestamp: DateTime.now(),
        status: 'active',
        description: 'Current disaster location'
      );

      // Update locations list with single location
      _locationsList = [location];
      _lastKnownLocation = location;
      
      // Cache the location
      await _cacheLocation(location);
      
      // Emit the new location
      print('FirebaseLocationRepository: Emitting location update');
      _locationController.add(_locationsList);
      _hasEmittedLocation = true;

    } catch (e, stackTrace) {
      print('FirebaseLocationRepository: Data parsing error: $e');
      print('FirebaseLocationRepository: Stack trace: $stackTrace');
      if (_locationsList.isEmpty) {
        _locationController.add([]);
      }
    }
  }

  Future<void> _setupFirebaseListener() async {
    try {
      print('FirebaseLocationRepository: Setting up data listener');
      
      _disasterLocationRef.onValue.listen(
        (event) {
          print('FirebaseLocationRepository: Received data event');
          print('FirebaseLocationRepository: Event type: ${event.type}');
          print('FirebaseLocationRepository: Raw data: ${event.snapshot.value}');
          
          final data = event.snapshot.value;
          if (data != null && data is Map) {
            _handleLocationData(data);
          } else {
            print('FirebaseLocationRepository: Invalid data format: ${data?.runtimeType ?? 'null'}');
            if (_locationsList.isEmpty) {
              _locationController.add([]);
            }
          }
        },
        onError: (error, stackTrace) {
          print('FirebaseLocationRepository: Stream error: $error');
          print('FirebaseLocationRepository: Stack trace: $stackTrace');
          if (_locationsList.isEmpty) {
            _locationController.add([]);
          }
        },
        cancelOnError: false,
      );
    } catch (e, stackTrace) {
      print('FirebaseLocationRepository: Listener setup error: $e');
      print('FirebaseLocationRepository: Stack trace: $stackTrace');
      if (_locationsList.isEmpty) {
        _locationController.add([]);
      }
    }
  }

  Future<void> _checkAndNotifyLocationChange(LocationModel newLocation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastNotifiedLocationJson = prefs.getString(_lastNotifiedLocationKey);
      
      bool shouldNotify = true;
      
      if (lastNotifiedLocationJson != null) {
        final lastNotifiedLocation = LocationModel.fromJson(jsonDecode(lastNotifiedLocationJson));
        
        // Check if location has changed significantly (e.g., more than 10 meters)
        final hasSignificantChange = _calculateDistance(
          lastNotifiedLocation.latitude,
          lastNotifiedLocation.longitude,
          newLocation.latitude,
          newLocation.longitude
        ) > 10; // 10 meters threshold
        
        shouldNotify = hasSignificantChange;
      }
      
      if (shouldNotify) {
        // Create notification payload
        final Map<String, dynamic> payload = {
          'type': 'disaster',
          'id': newLocation.id,
          'latitude': newLocation.latitude.toString(),
          'longitude': newLocation.longitude.toString(),
        };
        
        // Show notification
        await _notificationService.showNotification(
          title: 'Disaster Alert!',
          body: 'Disaster detected at new location. Tap to view on map.',
          payload: jsonEncode(payload),
        );
        
        // Save this location as last notified
        await prefs.setString(_lastNotifiedLocationKey, jsonEncode(newLocation.toJson()));
      }
    } catch (e) {
      print('FirebaseLocationRepository: Error handling location notification: $e');
    }
  }
  
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simple Euclidean distance for demo - in real app, use Haversine formula
    return ((lat2 - lat1) * (lat2 - lat1) + (lon2 - lon1) * (lon2 - lon1)) * 111000;
  }

  void _setFallbackLocation() {
    if (!_hasEmittedLocation && _lastKnownLocation != null) {
      _locationsList = [_lastKnownLocation!];
      _locationController.add(_locationsList);
      _hasEmittedLocation = true;
    }
  }
  
  Future<void> listenForLocationDeletions(Function(String) onLocationDeleted) async {
    _locationDeletedController.stream.listen(onLocationDeleted);
  }
  
  void _updateLastActivityTime() {
    _lastActivityTime = DateTime.now();
  }

  void dispose() {
    _locationController.close();
    _locationDeletedController.close();
    _sleepStateTimer?.cancel();
  }
}