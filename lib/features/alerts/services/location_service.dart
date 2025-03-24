import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Converts latitude and longitude to a human-readable address
  static Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return "Unknown Location";

      Placemark place = placemarks[0];
      // Format the address to include only relevant parts
      List<String> addressParts = [
        if (place.street?.isNotEmpty == true) place.street!,
        if (place.subLocality?.isNotEmpty == true) place.subLocality!,
        if (place.locality?.isNotEmpty == true) place.locality!,
        if (place.administrativeArea?.isNotEmpty == true) place.administrativeArea!,
      ];

      return addressParts.isNotEmpty 
          ? addressParts.join(", ")
          : "Unknown Location";
    } catch (e) {
      print('Error getting address: $e');
      return "Location Not Available";
    }
  }
} 