import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

/// Location Service for getting user's current location
/// 
/// Uses the geolocator package to fetch device location with proper permission handling.
/// Falls back gracefully when location is unavailable or permissions are denied.
class LocationService {
  /// Get current location coordinates
  /// Returns a map with 'latitude' and 'longitude' keys, or null if unavailable
  Future<Map<String, double>?> getCurrentLocation() async {
    try {
      developer.log('🌍 LocationService: Checking location services...', name: 'LocationService');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log('❌ LocationService: Location services are disabled', name: 'LocationService');
        print('❌ Location services are disabled on device');
        return null;
      }
      
      developer.log('✅ LocationService: Location services enabled', name: 'LocationService');
      
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      developer.log('🔐 LocationService: Current permission: $permission', name: 'LocationService');
      
      if (permission == LocationPermission.denied) {
        developer.log('⚠️ LocationService: Permission denied, requesting...', name: 'LocationService');
        // Request permission
        permission = await Geolocator.requestPermission();
        developer.log('🔐 LocationService: Permission after request: $permission', name: 'LocationService');
        
        if (permission == LocationPermission.denied) {
          developer.log('❌ LocationService: Permission denied by user', name: 'LocationService');
          print('❌ Location permission denied by user');
          return null;
        }
      }
      
      // Check if permission is permanently denied
      if (permission == LocationPermission.deniedForever) {
        developer.log('❌ LocationService: Permission permanently denied', name: 'LocationService');
        print('❌ Location permission permanently denied');
        return null;
      }
      
      developer.log('📍 LocationService: Fetching current position...', name: 'LocationService');
      
      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      
      final locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
      
      developer.log('✅ LocationService: Location fetched successfully', name: 'LocationService');
      developer.log('📍 Latitude: ${position.latitude}', name: 'LocationService');
      developer.log('📍 Longitude: ${position.longitude}', name: 'LocationService');
      
      print('✅ Location fetched: Lat=${position.latitude}, Lng=${position.longitude}');
      
      return locationData;
    } catch (e) {
      developer.log('❌ LocationService: Error fetching location: $e', name: 'LocationService');
      print('❌ Error fetching location: $e');
      return null;
    }
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }
  
  /// Open location settings to allow user to enable location services
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      return false;
    }
  }
}

