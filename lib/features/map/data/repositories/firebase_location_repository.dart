import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:lora2/features/map/data/models/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseLocationRepository {
  static final FirebaseLocationRepository _instance = FirebaseLocationRepository._internal();
  factory FirebaseLocationRepository() => _instance;

  // Key for storing cached location
  static const String _locationCacheKey = 'last_known_location';
  
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

  FirebaseLocationRepository._internal() {
    print('FirebaseLocationRepository: Initializing');
    _initDatabase();
  }

  Stream<List<LocationModel>> get locationStream => _locationController.stream;
  Stream<String> get locationDeletedStream => _locationDeletedController.stream;
  LocationModel? get lastKnownLocation => _lastKnownLocation;
  bool get isInSleepState => _isInSleepState;

  Future<void> _initDatabase() async {
    try {
      print('FirebaseLocationRepository: Initializing Firebase Database');
      
      // Test database connection first
      final testRef = FirebaseDatabase.instance.ref('.info/connected');
      testRef.onValue.listen((event) {
        final connected = event.snapshot.value as bool? ?? false;
        print('FirebaseLocationRepository: Database connection status: ${connected ? 'connected' : 'disconnected'}');
      });
      
      // Fix the typo in the reference path and try both paths
      _disasterLocationRef = FirebaseDatabase.instance.ref().child('disaster-location');
      
      // Add a test read to verify connection
      final snapshot = await _disasterLocationRef.get();
      print('FirebaseLocationRepository: Initial data snapshot exists: ${snapshot.exists}');
      if (snapshot.exists) {
        print('FirebaseLocationRepository: Initial data: ${snapshot.value}');
      } else {
        print('FirebaseLocationRepository: No data found at disaster-location, trying alternate path...');
        // Try alternate path if first one has no data
        _disasterLocationRef = FirebaseDatabase.instance.ref().child('locations');
        final altSnapshot = await _disasterLocationRef.get();
        print('FirebaseLocationRepository: Alternate path data exists: ${altSnapshot.exists}');
        
        // Try a test write to verify permissions
        try {
          await _disasterLocationRef.child('test').set({
            'timestamp': ServerValue.timestamp,
            'test': true
          });
          print('FirebaseLocationRepository: Test write successful');
          // Clean up test data
          await _disasterLocationRef.child('test').remove();
        } catch (e) {
          print('FirebaseLocationRepository: Test write failed: $e');
        }
      }
      
      // Load cached location first
      await _loadCachedLocation();
      
      // Set up Firebase listener
      await _setupFirebaseListener();
      
      // Set a fallback timeout for web
      if (kIsWeb) {
        print('FirebaseLocationRepository: Setting web fallback timer');
        Timer(const Duration(seconds: 5), () {
          if (!_hasEmittedLocation) {
            print('FirebaseLocationRepository: Web fallback timer triggered, using cached location');
            _setFallbackLocation();
          }
        });
      }
      
      // Initialize sleep state timer
      _initSleepStateTimer();
      
    } catch (e, stackTrace) {
      print('FirebaseLocationRepository: Error initializing database: $e');
      print('FirebaseLocationRepository: Stack trace: $stackTrace');
      
      // If Firebase fails, try to use cached location
      await _loadCachedLocation();
      _setFallbackLocation();
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

  Future<void> _setupFirebaseListener() async {
    try {
      print('FirebaseLocationRepository: Setting up Firebase listener');
      
      // Listen for location updates
      _disasterLocationRef.onValue.listen((event) {
        _updateLastActivityTime();
        
        if (event.snapshot.value != null) {
          print('FirebaseLocationRepository: Received Firebase data: ${event.snapshot.value}');
          try {
            final dynamic locationData = event.snapshot.value;
            _locationsList = [];
            
            // Handle the format "disaster-location-latitude:-longitude"
            if (locationData is String) {
              // Parse the single string format
              _parseDisasterLocationString(locationData);
            } else if (locationData is Map) {
              // If it's a map, process each entry
              locationData.forEach((key, value) {
                try {
                  if (value is String && key.toString().contains('-')) {
                    // It's likely in the format "latitude:-longitude"
                    _parseDisasterLocationEntry(key.toString(), value.toString());
                  } else if (value is Map) {
                    // It might be a regular JSON structure
                    final location = LocationModel.fromJson(
                      Map<String, dynamic>.from(value)..putIfAbsent('id', () => key.toString()),
                    );
                    
                    print('FirebaseLocationRepository: Parsed location: $location');
                    _locationsList.add(location);
                    
                    // Update last known location with the most recent
                    if (_lastKnownLocation == null || 
                        location.timestamp.isAfter(_lastKnownLocation!.timestamp)) {
                      _lastKnownLocation = location;
                      _cacheLocation(location);
                    }
                  }
                } catch (e, stackTrace) {
                  print('FirebaseLocationRepository: Error parsing location entry: $e');
                  print('FirebaseLocationRepository: Stack trace: $stackTrace');
                }
              });
              
              // Sort by timestamp (newest first)
              _locationsList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            }
            
            print('FirebaseLocationRepository: Processed ${_locationsList.length} locations');
            
            if (_locationsList.isNotEmpty) {
              _locationController.add(_locationsList);
              _hasEmittedLocation = true;
            } else {
              print('FirebaseLocationRepository: No valid locations found in data');
              _setFallbackLocation();
            }
          } catch (e, stackTrace) {
            print('FirebaseLocationRepository: Error processing Firebase data: $e');
            print('FirebaseLocationRepository: Stack trace: $stackTrace');
            _setFallbackLocation();
          }
        } else {
          print('FirebaseLocationRepository: Firebase returned null data');
          _setFallbackLocation();
        }
      }, onError: (error, stackTrace) {
        print('FirebaseLocationRepository: Firebase listener error: $error');
        print('FirebaseLocationRepository: Stack trace: $stackTrace');
        _setFallbackLocation();
      });
      
      // Listen for location removals
      _disasterLocationRef.onChildRemoved.listen((event) {
        _updateLastActivityTime();
        
        final String deletedId = event.snapshot.key ?? '';
        print('FirebaseLocationRepository: Location removed: $deletedId');
        
        if (deletedId.isNotEmpty) {
          _locationDeletedController.add(deletedId);
          
          // Remove from our local list
          _locationsList.removeWhere((location) => location.id == deletedId);
          
          // Emit updated list
          if (_locationsList.isNotEmpty) {
            _locationController.add(_locationsList);
          } else {
            print('FirebaseLocationRepository: No locations left after removal');
            _setFallbackLocation();
          }
        }
      }, onError: (error, stackTrace) {
        print('FirebaseLocationRepository: Error in removal listener: $error');
        print('FirebaseLocationRepository: Stack trace: $stackTrace');
      });
      
    } catch (e, stackTrace) {
      print('FirebaseLocationRepository: Error setting up Firebase listener: $e');
      print('FirebaseLocationRepository: Stack trace: $stackTrace');
      _setFallbackLocation();
    }
  }

  // Parse a disaster location in the format "latitude:-longitude"
  void _parseDisasterLocationEntry(String key, String value) {
    try {
      print('FirebaseLocationRepository: Parsing disaster location entry: $key, $value');
      
      // Extract latitude and longitude from key format "latitude:-longitude"
      final parts = key.split('-');
      if (parts.length >= 2) {
        // The last part should contain "latitude:longitude"
        final coordParts = parts.last.split(':');
        if (coordParts.length == 2) {
          final latitude = double.tryParse(coordParts[0]);
          final longitude = double.tryParse(coordParts[1]);
          
          if (latitude != null && longitude != null) {
            final location = LocationModel(
              id: key,
              latitude: latitude,
              longitude: longitude,
              altitude: 0.0,
              speed: 0.0,
              timestamp: DateTime.now(),
              status: 'Disaster',
              description: value,
            );
            
            _locationsList.add(location);
            
            // Update last known location
            if (_lastKnownLocation == null) {
              _lastKnownLocation = location;
              _cacheLocation(location);
            }
          }
        }
      }
    } catch (e) {
      print('FirebaseLocationRepository: Error parsing disaster location entry: $e');
    }
  }
  
  // Parse a disaster location in the format "diaster-location-latitude:-longitude"
  void _parseDisasterLocationString(String locationString) {
    try {
      print('FirebaseLocationRepository: Parsing disaster location string: $locationString');
      
      // Split the string to extract the coordinates
      final parts = locationString.split('-');
      if (parts.length >= 3 && parts[0] == 'diaster' && parts[1] == 'location') {
        // The last part should be "latitude:longitude"
        final coordPart = parts[2];
        final coordParts = coordPart.split(':');
        
        if (coordParts.length == 2) {
          final latitude = double.tryParse(coordParts[0]);
          final longitude = double.tryParse(coordParts[1]);
          
          if (latitude != null && longitude != null) {
            final location = LocationModel(
              id: locationString,
              latitude: latitude,
              longitude: longitude,
              altitude: 0.0,
              speed: 0.0,
              timestamp: DateTime.now(),
              status: 'Disaster',
              description: 'Disaster at location',
            );
            
            _locationsList.add(location);
            
            // Update last known location
            if (_lastKnownLocation == null) {
              _lastKnownLocation = location;
              _cacheLocation(location);
            }
          }
        }
      }
    } catch (e) {
      print('FirebaseLocationRepository: Error parsing disaster location string: $e');
    }
  }

  void _setFallbackLocation() {
    // Only set fallback if we haven't emitted a location yet
    if (!_hasEmittedLocation) {
      print('FirebaseLocationRepository: Setting fallback location');
      
      // If we have a cached location, use it
      if (_lastKnownLocation != null) {
        print('FirebaseLocationRepository: Using cached location as fallback');
        _locationsList = [_lastKnownLocation!];
      } else {
        // Otherwise use a default location (centered on Philippines)
        print('FirebaseLocationRepository: Using default location as fallback');
        final defaultLocation = LocationModel(
          id: 'default',
          latitude: 14.5995,
          longitude: 120.9842,
          altitude: 0.0,
          speed: 0.0,
          timestamp: DateTime.now(),
          status: 'Default',
          description: 'Default location when no data is available',
        );
        
        _lastKnownLocation = defaultLocation;
        _locationsList = [defaultLocation];
        
        // Cache this default location
        _cacheLocation(defaultLocation);
      }
      
      // Emit the fallback location
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