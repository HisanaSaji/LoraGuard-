import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingResult {
  final String localArea;
  final String city;
  
  GeocodingResult({
    required this.localArea,
    required this.city,
  });
}

class GeocodingService {
  // Using OpenStreetMap Nominatim API for reverse geocoding
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/reverse';
  
  Future<GeocodingResult> reverseGeocode(double latitude, double longitude) async {
    try {
      // Build the API URL with parameters
      final url = Uri.parse('$_baseUrl?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1');
      
      // Add a user agent as required by Nominatim's usage policy
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'LoRaGuard_App/1.0',
          'Accept-Language': 'en-US,en;q=0.9',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extract address components
        final address = data['address'];
        
        // Try to get the most specific local area name
        String localArea = address['suburb'] ?? 
                          address['neighbourhood'] ?? 
                          address['residential'] ??
                          address['quarter'] ??
                          address['hamlet'] ??
                          'Unknown Area';
        
        // Try to get the city name
        String city = address['city'] ?? 
                     address['town'] ?? 
                     address['village'] ?? 
                     address['county'] ??
                     address['state'] ??
                     'Unknown City';
        
        print('Reverse geocoded: $localArea, $city');
        
        return GeocodingResult(
          localArea: localArea,
          city: city,
        );
      } else {
        print('Geocoding API error: ${response.statusCode}');
        return GeocodingResult(
          localArea: 'Unknown Area',
          city: 'Unknown City',
        );
      }
    } catch (e) {
      print('Error during reverse geocoding: $e');
      return GeocodingResult(
        localArea: 'Unknown Area',
        city: 'Unknown City',
      );
    }
  }
} 