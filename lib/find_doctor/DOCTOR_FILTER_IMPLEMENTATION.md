# Doctor Filter Implementation

## Overview
Implemented a professional filter system for doctor search and listing using a dedicated `DoctorFilter` entity. This provides a clean, maintainable, and extensible approach to handling multiple filter options.

## Architecture

### 1. Filter Entity (`lib/find_doctor/entities/doctor_filter.dart`)

A comprehensive filter entity with type-safe enums:

```dart
enum DoctorSortBy {
  recommended, experience, rating, availability, price
}

enum DoctorQuickFilter {
  availableToday, nearMe, topRated, videoConsult
}

class DoctorFilter {
  final String? searchQuery;
  final String? specialization;
  final DoctorSortBy? sortBy;
  final Set<DoctorQuickFilter> quickFilters;
  final double? minRating;
  final double? maxPrice;
  final String? location;
}
```

**Key Features:**
- Type-safe enums for sort and quick filters
- Immutable design with `const` constructor
- `copyWith()` method for easy updates
- `toggleQuickFilter()` for easy filter toggling
- `toQueryParams()` converts filter to API parameters
- `isEmpty`, `hasActiveFilters`, and `activeFilterCount` getters
- Proper `==` and `hashCode` implementation

### 2. Service Layer (`lib/find_doctor/service/doctors_get_detail_service.dart`)

Updated to accept `DoctorFilter` instead of individual parameters:

**Before:**
```dart
fetchDoctorsList({
  bool reset = false,
  String? searchQuery,
  String? specialization,
})
```

**After:**
```dart
fetchDoctorsList({
  bool reset = false,
  DoctorFilter? filter,
  // Legacy parameters kept for backward compatibility
  String? searchQuery,
  String? specialization,
})
```

**Benefits:**
- Single parameter instead of multiple
- Backward compatible with legacy code
- Automatic conversion of filter to query parameters
- Maintains filter state across pagination

### 3. Controller Layer (`lib/find_doctor/controller/doctors_controller.dart`)

Added filter management methods:

```dart
// Core filter state
final Rx<DoctorFilter> currentFilter = const DoctorFilter().obs;

// Filter update methods
void updateFilter(DoctorFilter filter)
void updateSortBy(DoctorSortBy sortBy)
void toggleQuickFilter(DoctorQuickFilter filter)
void clearQuickFilters()
```

**Features:**
- Reactive filter state with GetX
- Dedicated methods for each filter type
- Automatic refetch on filter change
- Maintains filter across pagination

### 4. UI Layer (`lib/find_doctor/ui/speciality_doctors_screen.dart`)

Interactive filter chips with state management:

**Features:**
- Toggle-able filter chips
- Visual feedback (selected state)
- "All" chip to clear all filters
- Sort options modal
- Real-time filter application

## Filter Options

### Current Filters

1. **Search Query** - Text search across doctors, specializations, clinics
2. **Specialization** - Filter by medical specialization
3. **Sort By** (Enum: `DoctorSortBy`) - Sort results by:
   - `recommended` (default)
   - `experience`
   - `rating`
   - `availability`
   - `price`
4. **Quick Filters** (Enum: `DoctorQuickFilter`) - Toggle filters:
   - `availableToday` - Show only doctors available today
   - `nearMe` - Show doctors near user's location
   - `topRated` - Show only highly-rated doctors
   - `videoConsult` - Show doctors offering video consultations

### Future Filters (Ready to implement)

5. **Min Rating** - Minimum rating threshold
6. **Max Price** - Maximum consultation fee
7. **Location** - Specific location/area

## API Integration

### Query Parameters

The filter automatically converts to API query parameters:

```dart
// Example filter
DoctorFilter(
  searchQuery: "cardio",
  specialization: "Cardiology",
  sortBy: DoctorSortBy.rating,
  quickFilters: {
    DoctorQuickFilter.availableToday,
    DoctorQuickFilter.topRated,
  },
)

// Converts to:
{
  "search": "cardio",
  "specialization": "Cardiology",
  "sort_by": "rating",
  "available_today": "1",
  "top_rated": "1"
}
```

### API Endpoints

**All Doctors:**
```
GET /doctors?page=1&per_page=10&search=cardio&sort_by=rating&available_today=1
```

**By Specialization:**
```
GET /specializations/{name}/doctors?page=1&per_page=10&search=cardio&sort_by=rating
```

## Usage Examples

### Basic Usage

```dart
// Create filter
final filter = DoctorFilter(
  specialization: 'Cardiology',
  sortBy: DoctorSortBy.rating,
  quickFilters: {DoctorQuickFilter.topRated},
);

// Apply filter
controller.updateFilter(filter);
```

### Update Specific Filter

```dart
// Update sort option
controller.updateSortBy(DoctorSortBy.experience);

// Toggle quick filter
controller.toggleQuickFilter(DoctorQuickFilter.availableToday);

// Clear all quick filters
controller.clearQuickFilters();

// Update with copyWith
final newFilter = currentFilter.copyWith(
  searchQuery: 'heart specialist',
  minRating: 4.5,
);
controller.updateFilter(newFilter);

// Toggle filter in entity
final updatedFilter = filter.toggleQuickFilter(DoctorQuickFilter.nearMe);
```

### Check Filter State

```dart
// Check if any filters are active
if (filter.hasActiveFilters) {
  // Show clear filters button
}

// Check if filter is empty
if (filter.isEmpty) {
  // Show default state
}
```

## Enum-Based Design Benefits

### Why Enums?

Using enums instead of booleans or strings provides several advantages:

1. **Type Safety** - Compile-time checking prevents typos and invalid values
2. **IDE Support** - Autocomplete and refactoring work seamlessly
3. **Exhaustive Checking** - Switch statements ensure all cases are handled
4. **Self-Documenting** - Clear, readable code with meaningful names
5. **Easy Extension** - Add new options without breaking existing code
6. **No Magic Strings** - Eliminates string comparison errors

### Enum Features

**DoctorSortBy Enum:**
```dart
enum DoctorSortBy {
  recommended, experience, rating, availability, price;
  
  String get displayName => 'Recommended'; // UI display
  String get apiValue => 'recommended';     // API parameter
  static DoctorSortBy? fromString(String value); // Parse from string
}
```

**DoctorQuickFilter Enum:**
```dart
enum DoctorQuickFilter {
  availableToday, nearMe, topRated, videoConsult;
  
  String get displayName => 'Available Today'; // UI display
  String get apiKey => 'available_today';      // API parameter
}
```

**Set-Based Quick Filters:**
- Multiple filters can be active simultaneously
- Easy toggle on/off with `toggleQuickFilter()`
- Check active state with `hasQuickFilter()`
- Clear all with `clearQuickFilters()`

## Benefits

### 1. Maintainability
- Single source of truth for filter state
- Easy to add new filter options
- Clear separation of concerns

### 2. Type Safety
- Compile-time checking of filter properties
- No magic strings or loose parameters
- IDE autocomplete support

### 3. Testability
- Easy to create test filters
- Immutable design prevents side effects
- Clear input/output for testing

### 4. Extensibility
- Add new filters without changing method signatures
- Backward compatible with legacy code
- Easy to add complex filter logic

### 5. Performance
- Efficient state management with GetX
- Automatic pagination with filter persistence
- Debounced search queries

## Migration Guide

### For Existing Code

Old approach:
```dart
await api.fetchDoctorsList(
  reset: true,
  searchQuery: 'cardio',
  specialization: 'Cardiology',
);
```

New approach:
```dart
final filter = DoctorFilter(
  searchQuery: 'cardio',
  specialization: 'Cardiology',
);
await api.fetchDoctorsList(
  reset: true,
  filter: filter,
);
```

### Backward Compatibility

Legacy parameters still work:
```dart
// This still works
await api.fetchDoctorsList(
  reset: true,
  searchQuery: 'cardio',
  specialization: 'Cardiology',
);
```

## Testing

### Unit Tests

```dart
test('DoctorFilter converts to query params correctly', () {
  final filter = DoctorFilter(
    searchQuery: 'test',
    specialization: 'Cardiology',
    sortBy: DoctorSortBy.rating,
    quickFilters: {DoctorQuickFilter.availableToday},
  );
  
  final params = filter.toQueryParams();
  
  expect(params['search'], 'test');
  expect(params['specialization'], 'Cardiology');
  expect(params['sort_by'], 'rating');
  expect(params['available_today'], '1');
});

test('DoctorFilter copyWith works correctly', () {
  final filter1 = DoctorFilter(searchQuery: 'test');
  final filter2 = filter1.copyWith(sortBy: DoctorSortBy.rating);
  
  expect(filter2.searchQuery, 'test');
  expect(filter2.sortBy, DoctorSortBy.rating);
});

test('DoctorFilter toggleQuickFilter works correctly', () {
  final filter1 = DoctorFilter();
  final filter2 = filter1.toggleQuickFilter(DoctorQuickFilter.topRated);
  final filter3 = filter2.toggleQuickFilter(DoctorQuickFilter.topRated);
  
  expect(filter1.quickFilters.isEmpty, true);
  expect(filter2.hasQuickFilter(DoctorQuickFilter.topRated), true);
  expect(filter3.quickFilters.isEmpty, true);
});
```

### Integration Tests

```dart
testWidgets('Filter chips update correctly', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Tap "Available Today" chip
  await tester.tap(find.text('Available Today'));
  await tester.pump();
  
  // Verify filter is applied
  final controller = Get.find<DoctorsController>();
  expect(
    controller.currentFilter.value.hasQuickFilter(DoctorQuickFilter.availableToday),
    true,
  );
});
```

## Future Enhancements

### 1. Filter Presets
```dart
class DoctorFilter {
  static const emergency = DoctorFilter(
    availableToday: true,
    sortBy: 'Availability',
  );
  
  static const topRated = DoctorFilter(
    topRated: true,
    minRating: 4.5,
    sortBy: 'Rating',
  );
}
```

### 2. Filter Persistence
```dart
// Save filter to local storage
await filterStorage.save(currentFilter);

// Load filter on app start
final savedFilter = await filterStorage.load();
controller.updateFilter(savedFilter);
```

### 3. Advanced Filters
- Date range for availability
- Insurance provider
- Languages spoken
- Gender preference
- Years of experience range
- Hospital/clinic affiliation

### 4. Filter Analytics
```dart
// Track filter usage
analytics.logFilterApplied(
  filterType: 'specialization',
  value: 'Cardiology',
);
```

## Best Practices

1. **Always use copyWith() for updates** - Maintains immutability
2. **Check isEmpty before showing clear button** - Better UX
3. **Debounce search queries** - Reduces API calls
4. **Show loading state during filter changes** - User feedback
5. **Persist filters across navigation** - Better UX
6. **Clear filters when appropriate** - Fresh start for new searches
7. **Validate filter combinations** - Prevent invalid states

## Troubleshooting

### Filter not applying
- Check if `fetchInitialDoctors()` is called after filter update
- Verify filter is not empty
- Check API response for errors

### Pagination issues
- Ensure filter is maintained in service layer
- Verify `reset: true` is used when filter changes
- Check `_currentFilter` is updated correctly

### UI not updating
- Verify GetX reactive variables are used
- Check if `setState()` is called in StatefulWidget
- Ensure filter chips have correct `isSelected` state

## Summary

The filter implementation provides:
- ✅ Clean, maintainable code
- ✅ Type-safe filter management
- ✅ Easy to extend with new filters
- ✅ Backward compatible
- ✅ Reactive UI updates
- ✅ Professional user experience
- ✅ Ready for production use
