/// Sort options for doctor listing
enum DoctorSortBy {
  recommended,
  experience,
  rating,
  availability,
  price;

  String get displayName {
    switch (this) {
      case DoctorSortBy.recommended:
        return 'Recommended';
      case DoctorSortBy.experience:
        return 'Experience';
      case DoctorSortBy.rating:
        return 'Rating';
      case DoctorSortBy.availability:
        return 'Availability';
      case DoctorSortBy.price:
        return 'Price';
    }
  }

  String get apiValue {
    switch (this) {
      case DoctorSortBy.recommended:
        return 'recommended';
      case DoctorSortBy.experience:
        return 'experience';
      case DoctorSortBy.rating:
        return 'rating';
      case DoctorSortBy.availability:
        return 'availability';
      case DoctorSortBy.price:
        return 'price';
    }
  }
}

/// Quick filter options for doctor search
enum DoctorQuickFilter {
  availableToday,
  nearMe,
  topRated,
  videoConsult;

  String get displayName {
    switch (this) {
      case DoctorQuickFilter.availableToday:
        return 'Available Today';
      case DoctorQuickFilter.nearMe:
        return 'Near Me';
      case DoctorQuickFilter.topRated:
        return 'Top Rated';
      case DoctorQuickFilter.videoConsult:
        return 'Video Consult';
    }
  }

  String get apiKey {
    switch (this) {
      case DoctorQuickFilter.availableToday:
        return 'available_today';
      case DoctorQuickFilter.nearMe:
        return 'near_me';
      case DoctorQuickFilter.topRated:
        return 'top_rated';
      case DoctorQuickFilter.videoConsult:
        return 'video_consult';
    }
  }
}

/// Simple filter entity for doctor search and listing
/// Just holds filter data - URL mapping is done in DoctorUrls class
class DoctorFilter {
  final String? searchQuery;
  final String? specialization;
  final DoctorSortBy? sortBy;
  final Set<DoctorQuickFilter> quickFilters;

  const DoctorFilter({
    this.searchQuery,
    this.specialization,
    this.sortBy,
    this.quickFilters = const {},
  });

  /// Create a copy with updated fields
  DoctorFilter copyWith({
    String? searchQuery,
    String? specialization,
    DoctorSortBy? sortBy,
    Set<DoctorQuickFilter>? quickFilters,
  }) {
    return DoctorFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      specialization: specialization ?? this.specialization,
      sortBy: sortBy ?? this.sortBy,
      quickFilters: quickFilters ?? this.quickFilters,
    );
  }

  /// Toggle a quick filter on/off
  DoctorFilter toggleQuickFilter(DoctorQuickFilter filter) {
    final newFilters = Set<DoctorQuickFilter>.from(quickFilters);
    if (newFilters.contains(filter)) {
      newFilters.remove(filter);
    } else {
      newFilters.add(filter);
    }
    return copyWith(quickFilters: newFilters);
  }

  /// Check if a quick filter is active
  bool hasQuickFilter(DoctorQuickFilter filter) {
    return quickFilters.contains(filter);
  }

  /// Clear all quick filters
  DoctorFilter clearQuickFilters() {
    return copyWith(quickFilters: {});
  }

  /// Check if filter is empty (no filters applied)
  bool get isEmpty {
    return searchQuery == null &&
        (specialization == null || specialization == 'All') &&
        sortBy == null &&
        quickFilters.isEmpty;
  }

  /// Check if filter has any active filters
  bool get hasActiveFilters => !isEmpty;

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (specialization != null && specialization != 'All') count++;
    if (sortBy != null) count++;
    count += quickFilters.length;
    return count;
  }

  @override
  String toString() {
    return 'DoctorFilter(search: $searchQuery, specialization: $specialization, sortBy: ${sortBy?.displayName}, quickFilters: ${quickFilters.map((f) => f.displayName).join(", ")})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctorFilter &&
        other.searchQuery == searchQuery &&
        other.specialization == specialization &&
        other.sortBy == sortBy &&
        other.quickFilters.length == quickFilters.length &&
        other.quickFilters.every((f) => quickFilters.contains(f));
  }

  @override
  int get hashCode {
    return Object.hash(
      searchQuery,
      specialization,
      sortBy,
      Object.hashAll(quickFilters),
    );
  }
}
