# Appointments Pagination & Pull-to-Refresh ✅

## Implementation Complete

Following the same pattern as `DoctorsApiService`, `DoctorsController`, and `SpecialityDoctorsScreen`.

## Changes Made

### 1. AppointmentsUrls (URL Builder)
```dart
static String getAppointmentsUrl({
  int page = 1,
  int perPage = 10,
  String? patientId,
}) {
  String url = '${NetworkConfig.baseUrl}/patient/appointments?page=$page&per_page=$perPage';
  if (patientId != null && patientId.isNotEmpty) {
    url += '&patient_id=$patientId';
  }
  return url;
}
```
- Pagination parameters appended directly to URL (not as query params)
- Matches DoctorUrls pattern exactly

### 2. AppointmentsService (API Layer)
- Added pagination state management (`_pageNumber`, `_didReachListEnd`)
- Implemented `reset()` method for fresh data fetch
- Added `_updatePaginationRelatedData()` for automatic page tracking
- Stores `_currentPatientId` for filtering by patient
- Uses URL builder with pagination parameters

### 3. AppointmentsController
- Renamed `service` to `api` (matching DoctorsController pattern)
- Simplified loading states (single `isLoading` instead of separate states)
- Added `_setLoading()`, `_clearError()`, `_setError()` helper methods
- Implemented `fetchInitialAppointments()` with `reset: true`
- Implemented `fetchMoreAppointments()` for pagination
- Added `setPatientId()` to reload appointments when patient changes
- Uses `api.didReachListEnd` to prevent unnecessary API calls

### 4. AppointmentsScreen (UI Layer)
- Added `ScrollController` with listener for pagination trigger
- Extracted `_buildAppointmentsList()` method (matching SpecialityDoctorsScreen)
- Added proper loading, error, and empty states
- Implemented `RefreshIndicator` for pull-to-refresh
- Patient card triggers `setPatientId()` on change
- Loading indicator shows at bottom during pagination

## API URL Format
```
/patient/appointments?page=1&per_page=10&patient_id=123
```

## Features
✅ Pagination (loads 10 items per page)
✅ Pull-to-refresh
✅ Patient filtering (reloads when patient changes)
✅ Scroll-based pagination trigger (200px before end)
✅ Loading states (initial, pagination, refresh)
✅ Error handling with retry
✅ Empty state
✅ Network failure detection
✅ URL parameters appended (not query params)

## Usage
- Scroll down to load more appointments
- Pull down to refresh
- Change patient to reload appointments for that patient
