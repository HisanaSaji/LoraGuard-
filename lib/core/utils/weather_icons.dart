import 'package:flutter/material.dart';

class WeatherIcons {
  static IconData getIconForCondition(String condition) {
    // Convert condition to lowercase for case-insensitive matching
    final lowerCondition = condition.toLowerCase();
    
    // Map weather conditions to appropriate icons
    if (lowerCondition.contains('clear') || lowerCondition.contains('sunny')) {
      return Icons.wb_sunny;
    } else if (lowerCondition.contains('cloud')) {
      return Icons.cloud;
    } else if (lowerCondition.contains('rain') || lowerCondition.contains('drizzle')) {
      return Icons.grain;
    } else if (lowerCondition.contains('thunderstorm')) {
      return Icons.flash_on;
    } else if (lowerCondition.contains('snow')) {
      return Icons.ac_unit;
    } else if (lowerCondition.contains('mist') || 
               lowerCondition.contains('fog') || 
               lowerCondition.contains('haze')) {
      return Icons.cloud_queue;
    } else {
      // Default icon for unknown conditions
      return Icons.wb_sunny;
    }
  }
  
  static Color getColorForCondition(String condition) {
    // Convert condition to lowercase for case-insensitive matching
    final lowerCondition = condition.toLowerCase();
    
    // Map weather conditions to appropriate colors
    if (lowerCondition.contains('clear') || lowerCondition.contains('sunny')) {
      return Colors.amber;
    } else if (lowerCondition.contains('cloud')) {
      return Colors.grey.shade300;
    } else if (lowerCondition.contains('rain') || lowerCondition.contains('drizzle')) {
      return Colors.lightBlue;
    } else if (lowerCondition.contains('thunderstorm')) {
      return Colors.deepPurple;
    } else if (lowerCondition.contains('snow')) {
      return Colors.white;
    } else if (lowerCondition.contains('mist') || 
               lowerCondition.contains('fog') || 
               lowerCondition.contains('haze')) {
      return Colors.blueGrey;
    } else {
      // Default color for unknown conditions
      return Colors.amber;
    }
  }
} 