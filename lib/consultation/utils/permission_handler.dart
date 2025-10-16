import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  /// Request camera and microphone permissions
  static Future<bool> requestCameraAndMicrophonePermissions() async {
    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      
      // Request microphone permission
      final microphoneStatus = await Permission.microphone.request();
      
      // Check if both permissions are granted
      return cameraStatus.isGranted && microphoneStatus.isGranted;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  /// Check if camera and microphone permissions are granted
  static Future<bool> arePermissionsGranted() async {
    try {
      final cameraStatus = await Permission.camera.status;
      final microphoneStatus = await Permission.microphone.status;
      
      return cameraStatus.isGranted && microphoneStatus.isGranted;
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  /// Show permission denied dialog
  static void showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'Camera and microphone permissions are required for video consultations. Please enable them in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Request permissions with user-friendly dialog
  static Future<bool> requestPermissionsWithDialog(BuildContext context) async {
    // First check if permissions are already granted
    if (await arePermissionsGranted()) {
      return true;
    }

    // Show dialog explaining why permissions are needed
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera & Microphone Access'),
          content: const Text(
            'To join the video consultation, we need access to your camera and microphone. This will allow you to see and talk to the doctor.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Allow'),
            ),
          ],
        );
      },
    );

    if (shouldProceed == true) {
      // Request permissions
      final granted = await requestCameraAndMicrophonePermissions();
      
      if (!granted) {
        // Show permission denied dialog
        showPermissionDeniedDialog(context);
        return false;
      }
      
      return true;
    }
    
    return false;
  }
}
