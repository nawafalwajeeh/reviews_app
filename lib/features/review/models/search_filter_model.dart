import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Model class for managing search filters on the map
class SearchFilterModel {
  // Distance filter
  final double? radiusInMeters;
  final bool enableDistanceFilter;

  // Area filter
  final LatLngBounds? areaBounds;
  final bool enableAreaFilter;

  // Country/Region filter
  final String? selectedCountry;
  final String? selectedCity;
  final bool enableLocationFilter;

  // Quick filters
  final bool nearbyOnly;
  final bool highestRatedOnly;
  final bool mostPopularOnly;
  final bool recentlyAddedOnly;

  // Filter state
  final bool hasActiveFilters;

  const SearchFilterModel({
    this.radiusInMeters,
    this.enableDistanceFilter = false,
    this.areaBounds,
    this.enableAreaFilter = false,
    this.selectedCountry,
    this.selectedCity,
    this.enableLocationFilter = false,
    this.nearbyOnly = false,
    this.highestRatedOnly = false,
    this.mostPopularOnly = false,
    this.recentlyAddedOnly = false,
    this.hasActiveFilters = false,
  });

  /// Create empty filter
  factory SearchFilterModel.empty() {
    return const SearchFilterModel();
  }

  /// Create filter with distance radius
  factory SearchFilterModel.withRadius(double radiusInMeters) {
    return SearchFilterModel(
      radiusInMeters: radiusInMeters,
      enableDistanceFilter: true,
      hasActiveFilters: true,
    );
  }

  /// Create filter with area bounds
  factory SearchFilterModel.withAreaBounds(LatLngBounds bounds) {
    return SearchFilterModel(
      areaBounds: bounds,
      enableAreaFilter: true,
      hasActiveFilters: true,
    );
  }

  /// Create filter with location (country/city)
  factory SearchFilterModel.withLocation({String? country, String? city}) {
    return SearchFilterModel(
      selectedCountry: country,
      selectedCity: city,
      enableLocationFilter: true,
      hasActiveFilters: (country != null || city != null),
    );
  }

  /// Copy with method for immutability
  SearchFilterModel copyWith({
    double? radiusInMeters,
    bool? enableDistanceFilter,
    LatLngBounds? areaBounds,
    bool? enableAreaFilter,
    String? selectedCountry,
    String? selectedCity,
    bool? enableLocationFilter,
    bool? nearbyOnly,
    bool? highestRatedOnly,
    bool? mostPopularOnly,
    bool? recentlyAddedOnly,
  }) {
    final newModel = SearchFilterModel(
      radiusInMeters: radiusInMeters ?? this.radiusInMeters,
      enableDistanceFilter: enableDistanceFilter ?? this.enableDistanceFilter,
      areaBounds: areaBounds ?? this.areaBounds,
      enableAreaFilter: enableAreaFilter ?? this.enableAreaFilter,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedCity: selectedCity ?? this.selectedCity,
      enableLocationFilter: enableLocationFilter ?? this.enableLocationFilter,
      nearbyOnly: nearbyOnly ?? this.nearbyOnly,
      highestRatedOnly: highestRatedOnly ?? this.highestRatedOnly,
      mostPopularOnly: mostPopularOnly ?? this.mostPopularOnly,
      recentlyAddedOnly: recentlyAddedOnly ?? this.recentlyAddedOnly,
    );

    return newModel._updateActiveStatus();
  }

  /// Update active filters status
  SearchFilterModel _updateActiveStatus() {
    final hasFilters =
        enableDistanceFilter ||
        enableAreaFilter ||
        enableLocationFilter ||
        nearbyOnly ||
        highestRatedOnly ||
        mostPopularOnly ||
        recentlyAddedOnly;

    return SearchFilterModel(
      radiusInMeters: radiusInMeters,
      enableDistanceFilter: enableDistanceFilter,
      areaBounds: areaBounds,
      enableAreaFilter: enableAreaFilter,
      selectedCountry: selectedCountry,
      selectedCity: selectedCity,
      enableLocationFilter: enableLocationFilter,
      nearbyOnly: nearbyOnly,
      highestRatedOnly: highestRatedOnly,
      mostPopularOnly: mostPopularOnly,
      recentlyAddedOnly: recentlyAddedOnly,
      hasActiveFilters: hasFilters,
    );
  }

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (enableDistanceFilter) count++;
    if (enableAreaFilter) count++;
    if (enableLocationFilter) count++;
    if (nearbyOnly) count++;
    if (highestRatedOnly) count++;
    if (mostPopularOnly) count++;
    if (recentlyAddedOnly) count++;
    return count;
  }

  /// Get filter description for UI
  String getFilterDescription() {
    final List<String> descriptions = [];

    if (enableDistanceFilter && radiusInMeters != null) {
      final km = radiusInMeters! / 1000;
      descriptions.add('Within ${km.toStringAsFixed(km < 1 ? 0 : 1)}km');
    }

    if (enableAreaFilter) {
      descriptions.add('This Area');
    }

    if (enableLocationFilter) {
      if (selectedCity != null) {
        descriptions.add(selectedCity!);
      } else if (selectedCountry != null) {
        descriptions.add(selectedCountry!);
      }
    }

    if (nearbyOnly) descriptions.add('Nearby');
    if (highestRatedOnly) descriptions.add('Top Rated');
    if (mostPopularOnly) descriptions.add('Popular');
    if (recentlyAddedOnly) descriptions.add('Recent');

    return descriptions.isEmpty ? 'All Places' : descriptions.join(' • ');
  }

  /// Clear all filters
  SearchFilterModel clearAll() {
    return SearchFilterModel.empty();
  }

  @override
  String toString() {
    return 'SearchFilterModel(activeFilters: $activeFilterCount, description: ${getFilterDescription()})';
  }
}
