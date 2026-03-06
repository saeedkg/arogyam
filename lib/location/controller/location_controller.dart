import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../service/location_service.dart';
import '../service/reverse_geocode_service.dart';

/// Location Controller for managing location data and city name resolution
/// 
/// Coordinates between LocationService (GPS) and ReverseGeocodeService (city name)
/// to provide a centralized, reactive interface for location data throughout the app.
class LocationController extends GetxController {
  // Dependencies
  final LocationService _locationService;
  final ReverseGeocodeService _reverseGeocodeService;
  
  // Observable state
  final Rxn<double> latitude = Rxn<double>();
  final Rxn<double> longitude = Rxn<double>();
  final Rxn<String> city = Rxn<String>();
  final RxBool isLoading = false.obs;
  
  /// Constructor with dependency injection
  LocationController({
    LocationService? locationService,
    ReverseGeocodeService? reverseGeocodeService,
  })  : _locationService = locationService ?? LocationService(),
        _reverseGeocodeService = reverseGeocodeService ?? ReverseGeocodeService();
  
  /// Get current location coordinates and automatically resolve city name
  /// Returns a map with 'latitude' and 'longitude' keys, or null if unavailable
  Future<Map<String, double>?> getCurrentLocation() async {
    try {
      developer.log(
        '🌍 LocationController: Fetching current location...',
        name: 'LocationController',
      );
      
      isLoading.value = true;
      
      // Fetch GPS coordinates
      final coordinates = await _locationService.getCurrentLocation();
      
      if (coordinates != null) {
        final lat = coordinates['latitude']!;
        final lng = coordinates['longitude']!;
        
        // Update observables
        latitude.value = lat;
        longitude.value = lng;
        
        developer.log(
          '✅ LocationController: Coordinates fetched - lat=$lat, lng=$lng',
          name: 'LocationController',
        );
        
        // Automatically fetch city name
        await getCityFromCoordinates(lat, lng);
        
        return coordinates;
      } else {
        developer.log(
          '⚠️ LocationController: Failed to get coordinates',
          name: 'LocationController',
        );
        return null;
      }
    } catch (e) {
      developer.log(
        '❌ LocationController: Error fetching location: $e',
        name: 'LocationController',
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Get city name from coordinates (placeholder for task 3)
  Future<String?> getCityFromCoordinates(double lat, double lng) async {
    try {
      developer.log(
        '🌍 LocationController: Fetching city name for lat=$lat, lng=$lng',
        name: 'LocationController',
      );
      
      // Validate coordinates
      if (lat < -90 || lat > 90) {
        developer.log(
          '❌ LocationController: Invalid latitude: $lat (must be between -90 and 90)',
          name: 'LocationController',
        );
        return null;
      }
      
      if (lng < -180 || lng > 180) {
        developer.log(
          '❌ LocationController: Invalid longitude: $lng (must be between -180 and 180)',
          name: 'LocationController',
        );
        return null;
      }
      
      // Call reverse geocode service
      final cityName = await _reverseGeocodeService.getCityFromCoordinates(lat, lng);
      
      if (cityName != null) {
        city.value = cityName;
        developer.log(
          '✅ LocationController: City name resolved: $cityName',
          name: 'LocationController',
        );
        return cityName;
      } else {
        city.value = null;
        developer.log(
          '⚠️ LocationController: Failed to resolve city name',
          name: 'LocationController',
        );
        return null;
      }
    } catch (e) {
      developer.log(
        '❌ LocationController: Error fetching city name: $e',
        name: 'LocationController',
      );
      city.value = null;
      return null;
    }
  }
  
  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    try {
      developer.log(
        '🔐 LocationController: Checking location permission...',
        name: 'LocationController',
      );
      
      final hasPermission = await _locationService.hasLocationPermission();
      
      developer.log(
        hasPermission 
          ? '✅ LocationController: Location permission granted'
          : '⚠️ LocationController: Location permission not granted',
        name: 'LocationController',
      );
      
      return hasPermission;
    } catch (e) {
      developer.log(
        '❌ LocationController: Error checking permission: $e',
        name: 'LocationController',
      );
      return false;
    }
  }
  
  /// Request location permission from user
  Future<bool> requestLocationPermission() async {
    try {
      developer.log(
        '🔐 LocationController: Requesting location permission...',
        name: 'LocationController',
      );
      
      final granted = await _locationService.requestLocationPermission();
      
      developer.log(
        granted 
          ? '✅ LocationController: Location permission granted by user'
          : '⚠️ LocationController: Location permission denied by user',
        name: 'LocationController',
      );
      
      return granted;
    } catch (e) {
      developer.log(
        '❌ LocationController: Error requesting permission: $e',
        name: 'LocationController',
      );
      return false;
    }
  }
  
  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    try {
      developer.log(
        '🌍 LocationController: Checking if location services are enabled...',
        name: 'LocationController',
      );
      
      final enabled = await _locationService.isLocationServiceEnabled();
      
      developer.log(
        enabled 
          ? '✅ LocationController: Location services are enabled'
          : '⚠️ LocationController: Location services are disabled',
        name: 'LocationController',
      );
      
      return enabled;
    } catch (e) {
      developer.log(
        '❌ LocationController: Error checking location services: $e',
        name: 'LocationController',
      );
      return false;
    }
  }
  
  /// Open device location settings
  Future<bool> openLocationSettings() async {
    try {
      developer.log(
        '⚙️ LocationController: Opening location settings...',
        name: 'LocationController',
      );
      
      final opened = await _locationService.openLocationSettings();
      
      developer.log(
        opened 
          ? '✅ LocationController: Location settings opened successfully'
          : '⚠️ LocationController: Failed to open location settings',
        name: 'LocationController',
      );
      
      return opened;
    } catch (e) {
      developer.log(
        '❌ LocationController: Error opening location settings: $e',
        name: 'LocationController',
      );
      return false;
    }
  }
}
