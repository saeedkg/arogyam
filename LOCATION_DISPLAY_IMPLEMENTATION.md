# Location Display Implementation

## Overview
Implemented automatic location detection and city display in the dashboard header.

## What Was Done

### 1. Created Reverse Geocode Service
**File**: `lib/common_services/services/reverse_geocode_service.dart`
- Calls the API: `{{base_url}}/reverse-geocode?lat={lat}&lng={lng}`
- Parses the response to extract city name
- Returns city name or null if failed

### 2. Updated HomeController
**File**: `lib/landing/controller/home_controller.dart`
- Added `userCity` observable property
- Added `LocationService` and `ReverseGeocodeService` dependencies
- Implemented `_loadUserLocation()` method that:
  1. Gets current GPS coordinates using `LocationService`
  2. Calls reverse geocode API to get city name
  3. Updates `userCity` with the result
- Automatically loads location on controller initialization

### 3. Updated Dashboard UI
**File**: `lib/landing/ui/pages/dashboard_screen.dart`
- Added location display below "Doctor in minutes" text
- Shows location pin icon (14px) + city name (12px)
- White color with transparency to match header style
- Only displays when city data is available

## How It Works

1. When dashboard loads, `HomeController.onInit()` is called
2. `_loadUserLocation()` runs in background
3. Gets device GPS coordinates (with permission handling)
4. Calls reverse geocode API with coordinates
5. Extracts city name from response
6. Updates UI automatically via observable

## API Response Format
```json
{
  "success": true,
  "message": "Coordinates reverse geocoded successfully",
  "data": {
    "address": "Full address...",
    "city": "Kalpetta",
    "state": "Kerala",
    "country": "India",
    "postal_code": "673121",
    "country_code": "in"
  },
  "coordinates": {
    "latitude": 11.609209995338558,
    "longitude": 76.08317872948597
  }
}
```

## UI Display
```
Ask It
Doctor in minutes
📍 Kalpetta
```

## Error Handling
- Gracefully handles location permission denials
- Falls back silently if GPS is disabled
- Hides location display if city cannot be determined
- Logs errors for debugging

## Testing
To test manually, you can set a city directly:
```dart
final controller = Get.find<HomeController>();
controller.setUserCity('Kalpetta');
```
