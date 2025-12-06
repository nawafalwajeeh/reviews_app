# Script to add new localization keys to all language files

$languages = @('de', 'es', 'fr', 'hi', 'it', 'ja', 'ko', 'pt', 'ru', 'zh')

$newKeys = '  "away": "away",
  "meters": "m",
  "kilometers": "km",
  "distance": "Distance",
  "defaultMap": "Default",
  "searchFilters": "Search Filters",
  "searchInThisArea": "Search in this area",
  "redoSearchInArea": "Redo search in this area",
  "distanceRadius": "Distance Radius",
  "selectArea": "Select Area",
  "selectCity": "Select City",
  "selectCountry": "Select Country",
  "filterByArea": "Filter by Area",
  "clearFilters": "Clear Filters",
  "activeFilters": "Active Filters",
  "nof iltersActive": "No filters active",
  "resultsFound": "{count} results found",
  "within1km": "Within 1 km",
  "within5km": "Within 5 km",
  "within10km": "Within 10 km",
  "within25km": "Within 25 km",
  "within50km": "Within 50 km",
  "customRadius": "Custom Radius",
  "anyDistance": "Any Distance",
  "allAreas": "All Areas",
  "popularAreas": "Popular Areas",
  "recentAreas": "Recent Areas",
  "searchCity": "Search city...",
  "quickFilters": "Quick Filters",
  "nearbyOnly": "Nearby Only",
  "mostPopular": "Most Popular",
  "recentlyAdded": "Recently Added",
  "mapControls": "Map Controls",
  "searchHistory": "Search History",
  "savedLocations": "Saved Locations",
  "clusterView": "Cluster View",
  "listView": "List View",
  "exploreThisArea": "Explore This Area",
  "showingResults": "Showing {count} results",
  "filterPresets": "Filter Presets",
  "cityWide": "City-wide",
  "searchRadius": "Search Radius"'

foreach ($lang in $languages) {
    $filePath = "assets\l10n\intl_$lang.arb"
    
    if (Test-Path $filePath) {
        Write-Host "Updating $filePath..."
        
        $content = Get-Content -Path $filePath -Raw
        $content = $content.TrimEnd("}").TrimEnd()
        
        if (-not $content.EndsWith(",")) {
            $content += ","
        }
        
        $content += "`r`n$newKeys`r`n}"
        
        Set-Content -Path $filePath -Value $content -NoNewline
        
        Write-Host "Updated $filePath"
    } else {
        Write-Host "File not found: $filePath"
    }
}

Write-Host "Done! Updated all language files."
