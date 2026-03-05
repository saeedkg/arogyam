# Design Document

## Overview

This design document outlines the architecture and implementation approach for enhancing the existing SearchScreen with advanced search capabilities. The solution integrates three new API endpoints (`/api/v1/search`, `/api/v1/search/autocomplete`, `/api/v1/search/popular`) to provide autocomplete suggestions, fuzzy matching with "Did you mean?" functionality, popular searches, and symptom-based search.

The design follows the existing Flutter/GetX architecture pattern used in the application, maintaining consistency with the current codebase structure while introducing new entities, services, and UI components.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      SearchScreen (UI)                       │
│  - Search TextField with debouncing                          │
│  - Autocomplete Dropdown                                     │
│  - Popular Searches Display                                  │
│  - Search Results List                                       │
│  - "Did You Mean?" Suggestions                               │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              EnhancedSearchController (GetX)                 │
│  - Search state management                                   │
│  - Debouncing logic (300ms)                                  │
│  - Autocomplete state                                        │
│  - Popular searches state                                    │
│  - Fuzzy matching suggestions state                          │
│  - Request cancellation                                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              EnhancedSearchService (API Layer)               │
│  - Universal search API                                      │
│  - Autocomplete API                                          │
│  - Popular searches API                                      │
│  - Response parsing and mapping                              │
│  - Error handling                                            │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   NetworkAdapter (HTTP)                      │
│  - GET requests with query parameters                        │
│  - Request cancellation support                              │
│  - Error handling and exceptions                             │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Initial Load**: SearchScreen → Controller → Service → Popular Searches API → Display popular searches
2. **User Types**: TextField → Debounce (300ms) → Controller → Service → Autocomplete API → Display suggestions
3. **User Selects Suggestion**: Tap → Controller → Navigate or Execute Search
4. **Search Execution**: Controller → Service → Universal Search API → Parse Results → Display
5. **No Results**: Universal Search API → Fuzzy Suggestions → Display "Did You Mean?"

## Components and Interfaces

### 1. New Entities

#### SearchSuggestion
```dart
class SearchSuggestion {
  final String type;              // 'specialization', 'symptom', 'doctor'
  final String text;              // Display text
  final String? subtitle;         // Additional info
  final String category;          // 'Specializations', 'Symptoms', 'Doctors'
  final String icon;              // Icon identifier
  final int? id;                  // Entity ID (for specialization/doctor)
  final String? slug;             // Doctor slug for navigation
  final List<String>? relatedSpecializations; // For symptoms
  final double? similarity;       // For fuzzy matching
}
```

#### PopularSearches
```dart
class PopularSearches {
  final List<String> popularSearches;
  final List<TrendingSpecialization> trendingSpecializations;
  final int instantAvailableCount;
}
```

#### TrendingSpecialization
```dart
class TrendingSpecialization {
  final int id;
  final String name;
  final String? svgIcon;
  final int doctorCount;
}
```

#### SearchResult
```dart
class SearchResult {
  final List<SearchResultItem> results;
  final SearchPagination pagination;
  final SearchMetadata? metadata;
  final FuzzySuggestions? suggestions;
}
```

#### SearchResultItem
```dart
class SearchResultItem {
  final String id;
  final String name;
  final String entityType;        // 'doctor', 'hospital', 'clinic'
  final List<Specialization> specializations;
  final double? averageRating;
  final int? consultationFee;
  final double? distanceKm;
  final NearestLocation? nearestLocation;
  final bool? isOnline;
  final bool? availableToday;
  final List<String>? consultationTypes;
  final String? imageUrl;
}
```

#### FuzzySuggestions
```dart
class FuzzySuggestions {
  final List<SearchSuggestion> didYouMean;
  final List<SearchSuggestion> relatedSearches;
  final String message;
}
```

#### NearestLocation
```dart
class NearestLocation {
  final String type;              // 'clinic', 'hospital'
  final String name;
  final double latitude;
  final double longitude;
}
```

### 2. Enhanced Search Service

#### EnhancedSearchService
```dart
class EnhancedSearchService {
  final NetworkAdapter _networkAdapter;
  
  // API Methods
  Future<List<SearchSuggestion>> getAutocomplete(String query, {int limit = 10});
  Future<PopularSearches> getPopularSearches();
  Future<SearchResult> universalSearch({
    required String query,
    String entityType = 'all',
    int? specializationId,
    String? city,
    double? latitude,
    double? longitude,
    List<String>? consultationTypes,
    bool? availableNow,
    double? minRating,
    int? minFee,
    int? maxFee,
    String sortBy = 'relevance',
    int page = 1,
    int perPage = 20,
  });
  
  // Helper Methods
  String _buildSearchUrl(Map<String, dynamic> params);
  SearchResult _parseSearchResponse(Map<String, dynamic> json);
  List<SearchSuggestion> _parseAutocompleteResponse(Map<String, dynamic> json);
  PopularSearches _parsePopularSearchesResponse(Map<String, dynamic> json);
}
```

### 3. Enhanced Search Controller

#### EnhancedSearchController (extends GetxController)
```dart
class EnhancedSearchController extends GetxController {
  // Dependencies
  final EnhancedSearchService _searchService;
  
  // Observable State
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingAutocomplete = false.obs;
  final RxString searchQuery = ''.obs;
  final RxList<SearchSuggestion> autocompleteSuggestions = <SearchSuggestion>[].obs;
  final Rx<PopularSearches?> popularSearches = Rx<PopularSearches?>(null);
  final RxList<SearchResultItem> searchResults = <SearchResultItem>[].obs;
  final Rx<FuzzySuggestions?> fuzzySuggestions = Rx<FuzzySuggestions?>(null);
  final RxBool hasSearched = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Debouncing
  Timer? _debounceTimer;
  CancelToken? _searchCancelToken;
  CancelToken? _autocompleteCancelToken;
  
  // Methods
  @override
  void onInit();
  Future<void> loadPopularSearches();
  void onSearchTextChanged(String query);
  Future<void> performSearch(String query, {Map<String, dynamic>? filters});
  Future<void> _fetchAutocomplete(String query);
  void onSuggestionTapped(SearchSuggestion suggestion);
  void onPopularSearchTapped(String searchTerm);
  void onDidYouMeanTapped(SearchSuggestion suggestion);
  void clearSearch();
  void _cancelPreviousRequests();
  
  // Getters
  bool get showPopularSearches;
  bool get showAutocomplete;
  bool get showSearchResults;
  bool get showNoResults;
  bool get showFuzzySuggestions;
}
```

### 4. UI Components

#### AutocompleteDropdown
A custom widget that displays categorized autocomplete suggestions below the search field.

**Features:**
- Grouped by category (Specializations, Symptoms, Doctors)
- Category headers with icons
- Suggestion items with icon, text, and subtitle
- Smooth animations
- Tap handling

#### PopularSearchesWidget
Displays popular searches, trending specializations, and instant available count.

**Features:**
- Horizontal scrollable chips for popular searches
- Grid of trending specializations with doctor counts
- Instant available doctors badge
- Tap handling for navigation

#### FuzzySuggestionsWidget
Displays "Did you mean?" and related searches when no results found.

**Features:**
- "Did you mean?" section with similarity indicators
- Related searches section
- Helpful message
- Tap handling to retry search

#### SearchResultCard
Enhanced result card for doctors with comprehensive information.

**Features:**
- Doctor avatar with online status indicator
- Name, specialization, and fee
- Rating and reviews
- Distance (if location-based)
- Availability badges
- Consultation type indicators

## Data Models

### API Request Models

#### UniversalSearchRequest
```dart
class UniversalSearchRequest {
  final String query;
  final String entityType;
  final int? specializationId;
  final String? city;
  final double? latitude;
  final double? longitude;
  final List<String>? consultationTypes;
  final bool? availableNow;
  final double? minRating;
  final int? minFee;
  final int? maxFee;
  final String sortBy;
  final int page;
  final int perPage;
  
  String toQueryString();
}
```

### API Response Models

All response models follow the standard API response structure:
```dart
{
  "success": true,
  "data": { ... }
}
```

Error responses:
```dart
{
  "success": false,
  "message": "Error message",
  "errors": { ... }
}
```

## Error Handling

### Error Types

1. **Network Errors**
   - No internet connection
   - Timeout
   - Server unreachable
   - Action: Show cached data if available, display retry button

2. **API Errors**
   - 400 Bad Request: Invalid parameters
   - 401 Unauthorized: Token expired
   - 404 Not Found: Endpoint not found
   - 422 Validation Error: Invalid input
   - 503 Service Unavailable: Search service down
   - Action: Display user-friendly error message, log error

3. **Parsing Errors**
   - Invalid JSON structure
   - Missing required fields
   - Type mismatch
   - Action: Log error, return empty results

### Error Handling Strategy

```dart
try {
  final result = await _searchService.universalSearch(query: query);
  searchResults.assignAll(result.results);
  fuzzySuggestions.value = result.suggestions;
} on NetworkFailureException {
  errorMessage.value = 'No internet connection. Please check your network.';
  _showCachedResults();
} on ServerSentException catch (e) {
  if (e.errorCode == 503) {
    errorMessage.value = 'Search service is temporarily unavailable. Please try again.';
  } else {
    errorMessage.value = e.message;
  }
} catch (e) {
  errorMessage.value = 'An unexpected error occurred. Please try again.';
  _logError(e);
}
```

## Testing Strategy

### Unit Tests

1. **Entity Tests**
   - Test JSON parsing for all entities
   - Test edge cases (null values, missing fields)
   - Test entity methods and getters

2. **Service Tests**
   - Mock NetworkAdapter
   - Test successful API responses
   - Test error scenarios
   - Test URL building with various parameters
   - Test response parsing

3. **Controller Tests**
   - Mock EnhancedSearchService
   - Test search flow
   - Test debouncing logic
   - Test state transitions
   - Test error handling
   - Test request cancellation

### Widget Tests

1. **SearchScreen Tests**
   - Test initial state (popular searches)
   - Test search input and debouncing
   - Test autocomplete display
   - Test search results display
   - Test "Did you mean?" display
   - Test navigation on taps

2. **Component Tests**
   - Test AutocompleteDropdown rendering
   - Test PopularSearchesWidget rendering
   - Test FuzzySuggestionsWidget rendering
   - Test SearchResultCard rendering

### Integration Tests

1. **End-to-End Search Flow**
   - Open search screen
   - Type query
   - See autocomplete
   - Select suggestion
   - View results

2. **Popular Searches Flow**
   - Open search screen
   - See popular searches
   - Tap popular search
   - View results

3. **Fuzzy Matching Flow**
   - Search with typo
   - See "Did you mean?"
   - Tap suggestion
   - View corrected results

## Performance Considerations

### 1. Debouncing
- Implement 300ms debounce for autocomplete to reduce API calls
- Cancel previous requests when new search is initiated

### 2. Caching
- Cache popular searches for 1 hour
- Cache search results for 5 minutes
- Cache autocomplete suggestions for 1 hour
- Use in-memory cache with LRU eviction

### 3. Lazy Loading
- Implement pagination for search results
- Load more results on scroll
- Show loading indicator at bottom

### 4. Request Cancellation
- Cancel autocomplete requests when user continues typing
- Cancel search requests when new search is initiated
- Use CancelToken or similar mechanism

### 5. UI Optimization
- Use ListView.builder for search results
- Implement const constructors where possible
- Avoid unnecessary rebuilds with Obx
- Use cached network images

## Security Considerations

1. **Input Validation**
   - Sanitize search queries before sending to API
   - Validate minimum query length (2 characters)
   - Limit maximum query length (100 characters)

2. **API Security**
   - Include authentication token in headers
   - Use HTTPS for all API calls
   - Handle token expiration gracefully

3. **Data Privacy**
   - Don't log sensitive search queries
   - Clear search history on logout
   - Respect user privacy preferences

## Migration Strategy

### Phase 1: Add New Components (Non-Breaking)
- Create new entities (SearchSuggestion, PopularSearches, etc.)
- Create EnhancedSearchService
- Add new API endpoints to CommonUrls

### Phase 2: Update Controller (Backward Compatible)
- Extend existing CareSearchController or create new EnhancedSearchController
- Keep existing methods functional
- Add new methods for enhanced features

### Phase 3: Update UI (Gradual)
- Add autocomplete dropdown (hidden by default)
- Add popular searches section
- Add fuzzy suggestions section
- Update search results display

### Phase 4: Enable Features
- Enable autocomplete
- Enable popular searches
- Enable fuzzy matching
- Test thoroughly

### Phase 5: Cleanup (Optional)
- Remove old search logic if no longer needed
- Consolidate controllers if using separate one
- Remove deprecated code

## API Integration Details

### Base URL
```dart
static const String baseUrl = "https://arogyam.focus-its.com/api/v1";
```

### Endpoints

1. **Universal Search**
   - URL: `GET /api/v1/search`
   - Query Parameters: q, entity_type, specialization_id, city, latitude, longitude, consultation_types[], available_now, min_rating, min_fee, max_fee, sort_by, per_page, page

2. **Autocomplete**
   - URL: `GET /api/v1/search/autocomplete`
   - Query Parameters: q, limit

3. **Popular Searches**
   - URL: `GET /api/v1/search/popular`
   - No parameters required

### Authentication
All endpoints require Bearer token authentication:
```dart
headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
}
```

### Rate Limiting
- Search: 60 requests per minute
- Autocomplete: 10 requests per second
- Popular: No limit (cached)

## Accessibility Considerations

1. **Screen Reader Support**
   - Add semantic labels to all interactive elements
   - Announce search results count
   - Announce autocomplete suggestions

2. **Keyboard Navigation**
   - Support tab navigation through suggestions
   - Support enter key to select suggestion

3. **Visual Accessibility**
   - Maintain sufficient color contrast
   - Support dynamic text sizing
   - Provide visual feedback for interactions

## Localization

1. **Localizable Strings**
   - All UI text should be externalized
   - Support multiple languages
   - Handle RTL languages

2. **Search Localization**
   - Support local language search queries
   - Display results in user's preferred language
   - Handle language-specific sorting

## Future Enhancements

1. **Voice Search**
   - Integrate speech-to-text
   - Display voice input indicator

2. **Search History**
   - Store recent searches locally
   - Display in popular searches section
   - Allow clearing history

3. **Advanced Filters**
   - Add filter UI for consultation types
   - Add price range slider
   - Add rating filter
   - Add distance filter

4. **Search Analytics**
   - Track popular searches
   - Track conversion rates
   - Track "Did you mean?" effectiveness

5. **Offline Support**
   - Cache search results
   - Support offline browsing of cached results
   - Sync when online

6. **Smart Suggestions**
   - Machine learning-based suggestions
   - Personalized suggestions based on history
   - Context-aware suggestions
