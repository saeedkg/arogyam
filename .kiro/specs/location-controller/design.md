# Design Document

## Overview

The LocationController is a centralized GetX controller that manages all location-related operations in the app. It coordinates between the existing LocationService (GPS coordinates) and ReverseGeocodeService (city name resolution), providing a clean, reactive interface for accessing location data throughout the application. This design follows the existing controller pattern used in the app and leverages GetX for state management.

## Architecture

### Component Structure

```
lib/location/
├── controller/
│   └── location_controller.dart    (NEW - Main controller)
├── service/
│   ├── location_service.dart       (EXISTING - GPS coordinates)
│   └── reverse_geocode_service.dart (EXISTING - City name from coords)
```

### Dependencies

- **GetX**: For reactive state management and dependency injection
- **LocationService**: Existing service for GPS coordinate retrieval
- **ReverseGeocodeService**: Existing service for reverse geocoding
- **dart:developer**: For logging

### Design Pattern

The controller follows the **Repository Pattern** where:
- Services handle data fetching (LocationService, ReverseGeocodeService)
- Controller orchestrates service calls and manages state
- UI components observe controller state reactively

## Components and Interfaces

### LocationController

**File**: `lib/location/controller/location_controller.dart`

```dart
class LocationController extends GetxController {
  // Dependencies
  final LocationService _locationService;
  final ReverseGeocodeService _reverseGeocodeService;
  
  // Observable state
  final Rxn<double> latitude = Rxn<double>();
  final Rxn<double> longitude = Rxn<double>();
  final Rxn<String> city = Rxn<String>();
  final RxBool isLoading = false.obs;
  
  // Constructor with dependency injection
  LocationController({
    LocationService? locationService,
    ReverseGeocodeService? reverseGeocodeService,
  }) : _locationService = locationService ?? LocationService(),
       _reverseGeocodeService = reverseGeocodeService ?? ReverseGeocodeService();
  
  // Public methods
  Future<Map<String, double>?> getCurrentLocation();
  Future<String?> getCityFromCoordinates(double lat, double lng);
  Future<bool> hasLocationPermission();
  Future<bool> requestLocationPermission();
  Future<bool> isLocationServiceEnabled();
  Future<bool> openLocationSettings();
}
```

### Method Specifications

#### getCurrentLocation()

**Purpose**: Fetch current GPS coordinates and automatically resolve city name

**Flow**:
1. Set `isLoading = true`
2. Call `_locationService.getCurrentLocation()`
3. If successful:
   - Update `latitude` and `longitude` observables
   - Automatically call `getCityFromCoordinates()` with fetched coordinates
   - Return coordinate map
4. If failed:
   - Log error
   - Return null
5. Set `isLoading = false`

**Returns**: `Map<String, double>?` with keys 'latitude' and 'longitude', or null on failure

**Error Handling**: 
- Catches all exceptions
- Logs errors using developer.log
- Returns null gracefully

#### getCityFromCoordinates(lat, lng)

**Purpose**: Fetch city name from coordinates and update state

**Flow**:
1. Validate coordinates (not null, valid range)
2. Call `_reverseGeocodeService.getCityFromCoordinates(lat, lng)`
3. If successful:
   - Update `city` observable
   - Return city name
4. If failed:
   - Log error
   - Set `city = null`
   - Return null

**Returns**: `String?` city name or null on failure

**Error Handling**:
- Validates input coordinates
- Catches all exceptions
- Logs errors
- Returns null gracefully

#### hasLocationPermission()

**Purpose**: Check if location permission is granted

**Flow**:
1. Call `_locationService.hasLocationPermission()`
2. Return boolean result

**Returns**: `bool` - true if permission granted (whileInUse or always)

#### requestLocationPermission()

**Purpose**: Request location permission from user

**Flow**:
1. Call `_locationService.requestLocationPermission()`
2. Return boolean result

**Returns**: `bool` - true if permission granted after request

#### isLocationServiceEnabled()

**Purpose**: Check if device location services are enabled

**Flow**:
1. Call `_locationService.isLocationServiceEnabled()`
2. Return boolean result

**Returns**: `bool` - true if location services enabled

#### openLocationSettings()

**Purpose**: Open device location settings

**Flow**:
1. Call `_locationService.openLocationSettings()`
2. Return boolean result

**Returns**: `bool` - true if settings opened successfully

## Data Models

### Observable State Properties

| Property | Type | Description | Initial Value |
|----------|------|-------------|---------------|
| latitude | Rxn<double> | Current latitude coordinate | null |
| longitude | Rxn<double> | Current longitude coordinate | null |
| city | Rxn<String> | Current city name | null |
| isLoading | RxBool | Loading state for location operations | false |

### Coordinate Map Structure

```dart
{
  'latitude': double,
  'longitude': double
}
```

## Error Handling

### Error Categories

1. **Permission Errors**
   - User denies permission
   - Permission permanently denied
   - Handled by returning null and logging

2. **Service Errors**
   - Location services disabled
   - GPS unavailable
   - Handled by returning null and logging

3. **Network Errors**
   - Reverse geocode API fails
   - Timeout errors
   - Handled by returning null, keeping coordinates, logging

4. **Invalid Input**
   - Invalid coordinates passed to getCityFromCoordinates
   - Handled by validation and returning null

### Logging Strategy

All operations log using `developer.log` with:
- Operation start: 🌍 emoji
- Success: ✅ emoji
- Warning: ⚠️ emoji
- Error: ❌ emoji
- Log name: 'LocationController'

Example:
```dart
developer.log(
  '🌍 LocationController: Fetching current location...',
  name: 'LocationController',
);
```

## Integration Points

### Usage in Other Controllers

```dart
class HomeController extends GetxController {
  final LocationController locationController;
  
  HomeController({
    LocationController? locationController,
  }) : locationController = locationController ?? Get.find<LocationController>();
  
  @override
  void onInit() {
    super.onInit();
    _loadUserLocation();
  }
  
  Future<void> _loadUserLocation() async {
    await locationController.getCurrentLocation();
    // City is automatically updated in locationController.city
  }
}
```

### Usage in UI

```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();
    
    return Obx(() {
      final city = locationController.city.value;
      
      if (city != null) {
        return Row(
          children: [
            Icon(Icons.location_on, size: 14),
            SizedBox(width: 4),
            Text(city, style: TextStyle(fontSize: 12)),
          ],
        );
      }
      
      return SizedBox.shrink();
    });
  }
}
```

### Dependency Injection

Register the controller globally in main.dart or lazily when first needed:

```dart
// Option 1: Global registration (main.dart)
Get.put(LocationController());

// Option 2: Lazy registration (first use)
Get.lazyPut(() => LocationController());

// Option 3: Find or create
final controller = Get.find<LocationController>();
```

## Testing Strategy

### Unit Tests

1. **Controller Initialization**
   - Verify services are initialized
   - Verify observables have correct initial values

2. **getCurrentLocation()**
   - Mock LocationService to return coordinates
   - Verify latitude/longitude are updated
   - Verify getCityFromCoordinates is called automatically
   - Verify null handling when service fails

3. **getCityFromCoordinates()**
   - Mock ReverseGeocodeService to return city
   - Verify city observable is updated
   - Verify null handling when service fails
   - Verify invalid coordinate handling

4. **Permission Methods**
   - Mock LocationService permission methods
   - Verify correct boolean returns

5. **Error Handling**
   - Verify exceptions are caught
   - Verify logging occurs
   - Verify null returns on errors

### Integration Tests

1. **Full Location Flow**
   - Request permission → Get location → Get city
   - Verify all observables update correctly

2. **UI Integration**
   - Verify Obx widgets react to state changes
   - Verify loading states display correctly

### Manual Testing

1. **Permission Scenarios**
   - First time permission request
   - Permission denied
   - Permission granted

2. **Location Service States**
   - Location services enabled
   - Location services disabled
   - GPS unavailable

3. **Network Scenarios**
   - Reverse geocode API success
   - Reverse geocode API failure
   - Network timeout

## Performance Considerations

1. **Lazy Loading**: Controller should be lazily initialized to avoid unnecessary GPS calls
2. **Caching**: Consider caching city name for a session to avoid repeated API calls
3. **Debouncing**: If location updates frequently, consider debouncing city name updates
4. **Timeout**: Both services already have timeout handling (10 seconds)

## Security Considerations

1. **Permission Handling**: Always check permission before accessing location
2. **Data Privacy**: Location data stays in memory, not persisted
3. **API Security**: ReverseGeocodeService uses NetworkConfig.baseUrl with proper headers
4. **Error Messages**: Don't expose sensitive information in error logs

## Future Enhancements

1. **Location Caching**: Cache last known location for offline scenarios
2. **Location Updates**: Support continuous location updates with streams
3. **Distance Calculations**: Add utility methods for distance between coordinates
4. **Address Details**: Extend to support full address, not just city
5. **Location History**: Track location history for analytics
