import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyCallService {
  static const String _emergencyNumber = '112';
  
  /// Attempts to make an emergency call to the specified number
  static Future<void> callEmergency(BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: _emergencyNumber);
    
    try {
      // Check if the device can make phone calls
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Show error if calls are not supported
        _showCallErrorDialog(context, 'Your device cannot make phone calls.');
      }
    } catch (e) {
      print('Error making emergency call: $e');
      _showCallErrorDialog(
        context, 
        'Could not initiate emergency call. Please dial $_emergencyNumber manually.'
      );
    }
  }
  
  /// Shows an error dialog when call cannot be placed
  static void _showCallErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Emergency Call Failed'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
} 