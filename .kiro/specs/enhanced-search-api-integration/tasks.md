# Implementation Plan

- [x] 1. Create new entity models for enhanced search



  - Create SearchSuggestion entity with fromJson factory
  - Create PopularSearches and TrendingSpecialization entities
  - Create SearchResult, SearchResultItem, and SearchPagination entities
  - Create FuzzySuggestions and NearestLocation entities

  - _Requirements: 1.2, 2.1, 3.1, 4.4_

- [x] 2. Implement EnhancedSearchService with API integration


  - Create EnhancedSearchService class with NetworkAdapter dependency
  - Implement getAutocomplete() method with query parameter
  - Implement getPopularSearches() method
  - Implement universalSearch() method with all filter parameters
  - Add URL building helper methods for query string construction
  - Add response parsing methods for each API endpoint
  - Implement error handling for network and API exceptions
  - _Requirements: 1.1, 2.1, 3.1, 4.1, 7.1, 7.2_

- [x] 3. Update CommonUrls with new search endpoints



  - Add getUniversalSearchUrl() method with query parameters
  - Add getAutocompleteUrl() method
  - Add getPopularSearchesUrl() method
  - _Requirements: 1.1, 2.1, 3.1_

- [x] 4. Create EnhancedSearchController with state management



  - Create EnhancedSearchController extending GetxController
  - Add observable state variables (isLoading, searchQuery, autocompleteSuggestions, etc.)
  - Implement onInit() to load popular searches on initialization
  - Implement loadPopularSearches() method
  - Implement onSearchTextChanged() with 300ms debouncing logic
  - Implement performSearch() method with request cancellation
  - Implement _fetchAutocomplete() method with request cancellation
  - Add tap handlers (onSuggestionTapped, onPopularSearchTapped, onDidYouMeanTapped)
  - Implement clearSearch() method
  - Add computed getters for UI state (showPopularSearches, showAutocomplete, etc.)
  - _Requirements: 1.1, 1.4, 2.1, 3.3, 7.5, 8.1_

- [x] 5. Create AutocompleteDropdown UI component



  - Create AutocompleteDropdown stateless widget
  - Implement categorized suggestion list with headers
  - Add category icons (Specializations, Symptoms, Doctors)
  - Implement suggestion item layout with icon, text, and subtitle
  - Add tap handling for suggestion selection
  - Add smooth show/hide animations
  - Style with app colors and design system
  - _Requirements: 1.2, 1.3, 4.4_

- [x] 6. Create PopularSearchesWidget UI component



  - Create PopularSearchesWidget stateless widget
  - Implement horizontal scrollable chips for popular searches
  - Create trending specializations grid with doctor counts
  - Add instant available doctors badge
  - Implement tap handling for popular searches and trending items
  - Style with app colors and design system
  - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 7. Create FuzzySuggestionsWidget UI component



  - Create FuzzySuggestionsWidget stateless widget
  - Implement "Did you mean?" section with similarity indicators
  - Implement related searches section
  - Add helpful message display
  - Implement tap handling for suggestion retry
  - Style with app colors and design system
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 8. Create enhanced SearchResultCard component



  - Create SearchResultCard stateless widget
  - Add doctor avatar with online status indicator
  - Display name, specialization, and consultation fee
  - Add rating and reviews display
  - Add distance display for location-based results
  - Add availability badges (Available Today, Online)
  - Add consultation type indicators
  - Implement tap handling for navigation to doctor detail
  - Style with app colors and design system
  - _Requirements: 5.2, 5.3, 6.2_

- [x] 9. Update SearchScreen with enhanced features



  - Integrate EnhancedSearchController (replace or extend CareSearchController)
  - Update TextField with onChanged callback to trigger debounced autocomplete
  - Add AutocompleteDropdown below search field with conditional display
  - Replace empty state with PopularSearchesWidget
  - Add FuzzySuggestionsWidget for no results state
  - Update search results list to use enhanced SearchResultCard
  - Add loading states for autocomplete and search
  - Implement error handling UI with retry button
  - Add result count badges for categories
  - _Requirements: 1.1, 1.5, 2.1, 2.6, 3.6, 5.1, 5.6, 7.1, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_

- [x] 10. Implement location-based search integration



  - Add location permission request logic
  - Integrate device location service
  - Pass latitude/longitude to search API when available
  - Display distance information in search results
  - Add fallback for denied location permission
  - Handle location errors gracefully
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 11. Implement caching mechanism
  - Create in-memory cache service for search data
  - Implement cache for popular searches (1 hour TTL)
  - Implement cache for search results (5 minutes TTL)
  - Implement cache for autocomplete suggestions (1 hour TTL)
  - Add cache invalidation logic
  - Implement LRU eviction policy
  - _Requirements: 2.6, 7.3, 7.6_

- [ ] 12. Add navigation handlers for search suggestions
  - Implement navigation to SpecialityDoctorsScreen for specialization suggestions
  - Implement navigation to DoctorDetailInfoScreen for doctor suggestions
  - Implement search execution for symptom suggestions
  - Handle consultation type selection flow
  - Preserve navigation stack properly
  - _Requirements: 1.3, 2.4_

- [ ] 13. Implement error handling and retry logic
  - Add error state UI with user-friendly messages
  - Implement retry button for failed requests
  - Add offline indicator when network is unavailable
  - Display cached results when offline
  - Log errors for debugging without exposing to user
  - Handle token expiration and force logout if needed
  - _Requirements: 7.2, 7.3, 7.4_

- [ ] 14. Add accessibility features
  - Add semantic labels to all interactive elements
  - Implement screen reader announcements for search results count
  - Add keyboard navigation support for suggestions
  - Ensure sufficient color contrast for all text
  - Support dynamic text sizing
  - Add visual feedback for all interactions
  - _Requirements: 5.5, 8.1_

- [ ]* 15. Write unit tests for entities
  - Test SearchSuggestion.fromJson() with valid and invalid data
  - Test PopularSearches.fromJson() with edge cases
  - Test SearchResult.fromJson() with nested structures
  - Test FuzzySuggestions.fromJson() with optional fields
  - _Requirements: All_

- [ ]* 16. Write unit tests for EnhancedSearchService
  - Mock NetworkAdapter for isolated testing
  - Test getAutocomplete() with successful response
  - Test getPopularSearches() with successful response
  - Test universalSearch() with various filter combinations
  - Test error handling for network failures
  - Test error handling for API errors (400, 401, 503)
  - Test response parsing with malformed JSON
  - _Requirements: 7.2, 7.4_

- [ ]* 17. Write unit tests for EnhancedSearchController
  - Mock EnhancedSearchService
  - Test onInit() loads popular searches
  - Test onSearchTextChanged() debounces correctly (300ms)
  - Test performSearch() updates state correctly
  - Test request cancellation when new search initiated
  - Test error handling updates errorMessage
  - Test computed getters return correct UI states
  - _Requirements: 1.4, 7.5, 8.1_

- [ ]* 18. Write widget tests for UI components
  - Test AutocompleteDropdown renders suggestions correctly
  - Test PopularSearchesWidget displays popular searches and trending items
  - Test FuzzySuggestionsWidget shows "Did you mean?" suggestions
  - Test SearchResultCard displays doctor information correctly
  - Test tap handlers trigger correct callbacks
  - _Requirements: 1.2, 2.2, 3.3, 5.2_

- [ ]* 19. Write integration tests for search flows
  - Test end-to-end search flow (type → autocomplete → select → results)
  - Test popular searches flow (tap → execute search → results)
  - Test fuzzy matching flow (typo → "Did you mean?" → corrected results)
  - Test location-based search flow
  - Test error recovery flow (error → retry → success)
  - _Requirements: All_

- [ ] 20. Performance optimization and final polish
  - Verify debouncing reduces API calls
  - Verify caching improves load times
  - Verify lazy loading works for large result sets
  - Verify request cancellation prevents race conditions
  - Optimize image loading with cached network images
  - Profile and optimize any performance bottlenecks
  - _Requirements: 5.5, 7.1, 7.5_
