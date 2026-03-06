# LocationController Usage Examples

## Setup

### 1. Register the Controller

Add to your main.dart or where you initialize GetX controllers:

```dart
// Option 1: Eager initialization (loads immediately)
Get.put(LocationController());

// Option 2: Lazy initialization (loads when first accessed)
Get.lazyPut(() => LocationController());
```

## Basic Usage

### Get Current Location and City

```dart
final locationController = Get.find<LocationController>();

// Fetch location (automatically fetches city too)
final coordinates = await locationController.getCurrentLocation();

if (coordinates != null) {
  print('Lat: ${coordinates['latitude']}, Lng: ${coordinates['longitude']}');
  print('City: ${locationController.city.value}');
}
```

### Get City from Specific Coordinates

```dart
final locationController = Get.find<LocationController>();

final city = await locationController.getCityFromCoordinates(11.609, 76.083);
print('City: $city');
```

### Check Permissions

```dart
final locationController = Get.find<LocationController>();

// Check if permission is granted
final hasPermission = await locationController.hasLocationPermission();

if (!hasPermission) {
  // Request permission
  final granted = await locationController.requestLocationPermission();
  
  if (granted) {
    // Permission granted, fetch location
    await locationController.getCurrentLocation();
  }
}
```

### Check Location Services

```dart
final locationController = Get.find<LocationController>();

// Check if location services are enabled
final enabled = await locationController.isLocationServiceEnabled();

if (!enabled) {
  // Open settings to enable
  await locationController.openLocationSettings();
}
```

## UI Integration

### Display City in UI (Reactive)

```dart
class DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();
    
    return Column(
      children: [
        Text('Ask It', style: TextStyle(fontSize: 24)),
        Text('Doctor in minutes', style: TextStyle(fontSize: 14)),
        
        // Reactive location display
        Obx(() {
          final city = locationController.city.value;
          
          if (city != null) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.white70),
                SizedBox(width: 4),
                Text(
                  city,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            );
          }
          
          return SizedBox.shrink();
        }),
      ],
    );
  }
}
```

### Show Loading State

```dart
Obx(() {
  final locationController = Get.find<LocationController>();
  
  if (locationController.isLoading.value) {
    return CircularProgressIndicator();
  }
  
  return Text('Location: ${locationController.city.value ?? "Unknown"}');
})
```

## Controller Integration

### Use in Another Controller

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
    // City is automatically available in locationController.city
  }
  
  void displayUserLocation() {
    final city = locationController.city.value;
    if (city != null) {
      print('User is in: $city');
    }
  }
}
```

## Observable Properties

Access these reactive properties anywhere:

```dart
final locationController = Get.find<LocationController>();

// Coordinates
locationController.latitude.value  // double?
locationController.longitude.value // double?

// City name
locationController.city.value      // String?

// Loading state
locationController.isLoading.value // bool
```

## Error Handling

The controller handles all errors gracefully:
- Returns null on failure
- Logs errors for debugging
- Never throws unhandled exceptions
- Updates observables appropriately

```dart
final coordinates = await locationController.getCurrentLocation();

if (coordinates == null) {
  // Handle failure (permission denied, services disabled, etc.)
  print('Failed to get location');
} else {
  // Success
  print('Location: ${coordinates['latitude']}, ${coordinates['longitude']}');
}
```

## Complete Example

```dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LocationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();
    
    return Scaffold(
      appBar: AppBar(title: Text('Location Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              if (locationController.isLoading.value) {
                return CircularProgressIndicator();
              }
              
              return Column(
                children: [
                  Text('Latitude: ${locationController.latitude.value ?? "N/A"}'),
                  Text('Longitude: ${locationController.longitude.value ?? "N/A"}'),
                  Text('City: ${locationController.city.value ?? "N/A"}'),
                ],
              );
            }),
            
            SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () async {
                await locationController.getCurrentLocation();
              },
              child: Text('Get Location'),
            ),
            
            ElevatedButton(
              onPressed: () async {
                final hasPermission = await locationController.hasLocationPermission();
                Get.snackbar(
                  'Permission Status',
                  hasPermission ? 'Granted' : 'Not Granted',
                );
              },
              child: Text('Check Permission'),
            ),
            
            ElevatedButton(
              onPressed: () async {
                await locationController.openLocationSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
```
