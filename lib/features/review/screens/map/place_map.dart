import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/features/review/screens/place_details/place_details.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../../utils/constants/enums.dart';
import '../../../personalization/models/address_model.dart';
import '../../controllers/place_map_controller.dart';
import '../../models/place_model.dart';
import '../../models/recent_search.dart';
import '../../models/search_suggestion.dart';
import 'widgets/map_search_container.dart';
import 'widgets/search_filter_bottom_sheet.dart';
import 'widgets/voice_search_overlay.dart';
import 'widgets/place_bottom_sheet.dart';
import 'widgets/category_filter_sheet.dart';

class PlacesMapScreen extends StatelessWidget {
  final bool isPickerMode;
  final bool showBackButton;
  final PlaceModel? initialPlace;
  const PlacesMapScreen({
    super.key,
    this.isPickerMode = false,
    this.showBackButton = false,
    this.initialPlace,
  });

  // Static method to open as picker
  static Future<AddressModel?> openLocationPicker() async {
    return await Get.to<AddressModel?>(
      () => const PlacesMapScreen(isPickerMode: true),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = PlacesMapController.instance;
    // final dark = AppHelperFunctions.isDarkMode(context);

    // Set map style immediately (before map is created)
    // controller.isDarkMode.value = dark;
    // controller.currentMapStyle = dark
    //     ? MapStyles.darkMapStyle
    //     : MapStyles.lightMapStyle;

    // Set map style to light mode always
    // controller.isDarkMode.value = false;
    // controller.currentMapStyle.value = MapStyles.lightMapStyle;

    // Set initial place if provided (after build completes)
    if (initialPlace != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setInitialPlace(initialPlace!);
      });
    }

    return Scaffold(
      // backgroundColor: dark ? AppColors.dark : AppColors.white,
      body: Stack(
        children: [
          /// Google Map
          _buildMap(controller, context),

          /// Top Search & Controls
          _buildTopControls(context, controller),

          /// Search Suggestions
          _buildSearchSuggestions(context, controller),

          /// Voice Search Overlay
          _buildVoiceSearchOverlay(controller),

          /// Map Type Controls
          _buildMapTypeControls(context, controller),

          /// Places Bottom Sheet
          _buildPlacesBottomSheet(context, controller),

          /// Picker Bottom Sheet
          if (isPickerMode) _buildPickerBottomSheet(context, controller),

          /// Loading Overlay
          _buildLoadingOverlay(controller, context),

          /// Back Button (only when navigating from place details)
          if (showBackButton) _buildBackButton(),

          /// Category Filter Button
          if (!isPickerMode) _buildCategoryFilterButton(context, controller),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(controller, context),
    );
  }

  Widget _buildMap(PlacesMapController controller, BuildContext context) {
    return Obx(() {
      // Show loading until we have current location
      if (controller.isLoading.value &&
          controller.currentLocation.value == null) {
        return _buildLoadingState(context);
      }

      final initialLocation = controller.currentLocation.value;

      // Show loading overlay while map is initializing
      return Stack(
        children: [
          GoogleMap(
            // style: controller.currentMapStyle.value,
            initialCameraPosition: CameraPosition(
              target:
                  initialLocation != null &&
                      initialLocation.latitude != null &&
                      initialLocation.longitude != null
                  ? LatLng(
                      initialLocation.latitude!,
                      initialLocation.longitude!,
                    )
                  : const LatLng(13.562703, 44.021232), // Default Yemen Taiz
              zoom: isPickerMode ? 16.0 : 13.5,
            ),
            onMapCreated: (mapController) {
              controller.onMapCreated(mapController);
              // Hide loading after map is created
              Future.delayed(const Duration(milliseconds: 2000), () {
                if (controller.isLoading.value) {
                  controller.isLoading.value = false;
                }
              });
            },
            onTap: isPickerMode ? controller.onMapTap : null,
            markers: controller.markers.toSet(),
            polylines: controller.polylines.toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapType: controller.googleMapType,
            buildingsEnabled: true,
            indoorViewEnabled: true,
            trafficEnabled: controller.enabledMapDetails.contains(
              MapDetail.traffic,
            ),
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            tiltGesturesEnabled: true,
            onCameraMove: controller.onCameraMove,
            onCameraMoveStarted: () {
              // Show loading when camera moves (optional)
            },
            onCameraIdle: () {
              // Load places for current viewport (optional)
            },
          ),

          // Loading overlay for initial load
          if (controller.isLoading.value &&
              controller.currentLocation.value == null)
            _buildLoadingState(context),
        ],
      );
    });
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryColor),
            const SizedBox(height: AppSizes.lg),
            Text(
              // 'Loading your location...',
              AppLocalizations.of(Get.context!).loadingYourLocation,
              style: Theme.of(
                Get.context!,
              ).textTheme.titleMedium?.copyWith(color: AppColors.darkGrey),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              // 'Please wait while we set up your map',
              txt.settingUpYourMap,
              // AppLocalizations.of(context).while
              // AppLocalizations.of(Get.context!).pleaseWait,
              style: Theme.of(
                Get.context!,
              ).textTheme.bodySmall?.copyWith(color: AppColors.darkGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls(
    BuildContext context,
    PlacesMapController controller,
  ) {
    final locale = AppLocalizations.of(context);
    return Positioned(
      top:
          MediaQuery.of(context).padding.top +
          (isPickerMode ? 60 : AppSizes.sm),
      left: AppSizes.defaultSpace,
      right: AppSizes.defaultSpace,
      child: Column(
        children: [
          /// Search Bar with Voice Search
          Row(
            children: [
              Expanded(
                child: MapSearchContainer(
                  text: isPickerMode
                      // ? 'Search for an address...'
                      // : 'Search for places, addresses...',
                      ? locale.searchForAddress
                      : locale.searchForPlaces,
                  onChanged: controller.onSearchQueryChanged,
                  onVoiceSearch: () => controller.startListening(),
                  isListening: controller.isListening.value,
                  onClear: controller.clearSearch,
                  controller: controller.searchController,
                ),
              ),
              if (!isPickerMode) ...[
                const SizedBox(width: AppSizes.sm),
                // Filter Button with Badge
                Obx(() {
                  final filterCount =
                      controller.searchFilters.value.activeFilterCount;
                  final dark = AppHelperFunctions.isDarkMode(context);

                  return Stack(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: dark ? AppColors.darkerGrey : AppColors.white,
                          borderRadius: BorderRadius.circular(
                            AppSizes.cardRadiusLg,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: dark
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : AppColors.darkGrey.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Iconsax.filter,
                            color: filterCount > 0
                                ? AppColors.primaryColor
                                : (dark
                                      ? AppColors.lightGrey
                                      : AppColors.darkerGrey),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (context) =>
                                  const SearchFilterBottomSheet(),
                            );
                          },
                        ),
                      ),
                      if (filterCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              filterCount.toString(),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ],
          ),

          /// Quick Access Chips
          if (!isPickerMode)
            Obx(() => _buildQuickAccessChips(context, controller)),

          /// Coordinate Display (Premium Feature)
          if (!isPickerMode)
            Obx(() => _buildCoordinateDisplay(context, controller)),

          /// Results Counter (when filters are active)
          if (!isPickerMode)
            Obx(() => _buildResultsCounter(context, controller)),
        ],
      ),
    );
  }

  /// Premium Coordinate Display Widget
  Widget _buildCoordinateDisplay(
    BuildContext context,
    PlacesMapController controller,
  ) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final center = controller.currentMapCenter.value;

    if (center == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: AppSizes.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: dark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.location,
            size: 16,
            color: dark ? AppColors.light : AppColors.dark,
          ),
          const SizedBox(width: AppSizes.xs),
          Text(
            '${center.latitude.toStringAsFixed(4)}°, ${center.longitude.toStringAsFixed(4)}°',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: dark ? AppColors.light : AppColors.dark,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Zoom ${controller.currentZoomLevel.value.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Results Counter Widget
  Widget _buildResultsCounter(
    BuildContext context,
    PlacesMapController controller,
  ) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final locale = AppLocalizations.of(context);
    final hasFilters = controller.searchFilters.value.hasActiveFilters;
    final count = controller.displayedPlaces.length;

    if (!hasFilters || count == 0) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: AppSizes.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: dark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.location_tick, size: 16, color: AppColors.primaryColor),
          const SizedBox(width: AppSizes.xs),
          Text(
            locale.showingResults.replaceAll('{count}', count.toString()),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: dark ? AppColors.light : AppColors.dark,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessChips(
    BuildContext context,
    PlacesMapController controller,
  ) {
    final locale = AppLocalizations.of(context);
    if (controller.searchQuery.value.isNotEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: AppSizes.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            /// Current Location Chip
            _buildChip(
              context,
              // 'Current Location',
              locale.currentLocation,
              Iconsax.location,
              () => controller.moveToCurrentLocation(),
            ),

            /// Nearby Places Chip
            _buildChip(
              context,
              // 'Nearby Places',
              locale.nearbyPlaces,
              Iconsax.note,
              () => controller.loadNearbyPlaces(),
            ),

            /// Recent Searches Chips
            ...controller.recentSearches
                .take(2)
                .map(
                  (recent) => _buildChip(
                    context,
                    recent.query,
                    _getRecentSearchIcon(recent.type),
                    () => _handleRecentSearchTap(controller, recent),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: AppSizes.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkGrey.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.primaryColor),
              const SizedBox(width: AppSizes.xs),
              Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterButton(
    BuildContext context,
    PlacesMapController controller,
  ) {
    return Positioned(
      left: 18,
      bottom: 130,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Iconsax.filter,
            size: AppSizes.iconMd,
            color: AppColors.primaryColor,
          ),
          onPressed: () => _showCategoryFilterSheet(context, controller),
        ),
      ),
    );
  }

  void _showCategoryFilterSheet(
    BuildContext context,
    PlacesMapController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CategoryFilterSheet(
        onCategorySelected: controller.filterByCategory,
        selectedCategoryId: controller.selectedCategoryId.value,
      ),
    );
  }

  Widget _buildPlacesBottomSheet(
    BuildContext context,
    PlacesMapController controller,
  ) {
    return Obx(() {
      if (!controller.showBottomSheet.value ||
          controller.selectedPlace.value == null) {
        return const SizedBox();
      }

      return PlaceBottomSheet(
        place: controller.selectedPlace.value!,
        onTap: () {
          Get.to(
            () => PlaceDetailsScreen(place: controller.selectedPlace.value!),
          );
        },
        onClose: () {
          controller.showBottomSheet.value = false;
          controller.selectedPlace.value = null;
        },
      );
    });
  }

  Widget _buildFloatingActionButtons(
    PlacesMapController controller,
    BuildContext context,
  ) {
    AppLocalizations.of(context);

    if (isPickerMode) {
      return FloatingActionButton(
        heroTag: 'location_fab_picker',
        // heroTag: locale.pickLocationFromMap,
        onPressed: () => controller.moveToCurrentLocation(),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryColor,
        elevation: 4,
        child: const Icon(Iconsax.location, size: AppSizes.iconMd),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current Location FAB
        FloatingActionButton(
          heroTag: 'location_fab_explore',
          // heroTag: locale.location,
          onPressed: () => controller.moveToCurrentLocation(),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primaryColor,
          elevation: 4,
          mini: true,
          child: const Icon(Iconsax.location, size: AppSizes.iconMd),
        ),
        const SizedBox(height: AppSizes.sm),
        // Nearby Places FAB
        FloatingActionButton(
          heroTag: 'nearby_fab',
          // heroTag: locale,
          onPressed: () => controller.loadNearbyPlaces(),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.white,
          elevation: 4,
          mini: true,
          child: const Icon(Iconsax.note, size: AppSizes.iconMd),
        ),
      ],
    );
  }

  IconData _getRecentSearchIcon(String type) {
    switch (type) {
      case 'place':
        return Iconsax.building;
      case 'direction':
        return Iconsax.direct;
      default:
        return Iconsax.search_normal;
    }
  }

  void _handleRecentSearchTap(
    PlacesMapController controller,
    RecentSearch recent,
  ) {
    if (recent.placeId != null) {
      controller.onSuggestionSelected(
        SearchSuggestion(
          id: recent.id,
          title: recent.query,
          subtitle: recent.address,
          type: 'place',
          placeId: recent.placeId,
          icon: 'history',
        ),
      );
    } else {
      controller.onSearchQueryChanged(recent.query);
    }
  }

  Widget _buildSearchSuggestions(
    BuildContext context,
    PlacesMapController controller,
  ) {
    return Obx(() {
      if (controller.searchSuggestions.isEmpty ||
          controller.searchQuery.value.isEmpty) {
        return const SizedBox();
      }

      return Positioned(
        top: MediaQuery.of(context).padding.top + (isPickerMode ? 120 : 120),
        left: AppSizes.defaultSpace,
        right: AppSizes.defaultSpace,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            ),
            child: Column(
              children: [
                /// Search Header
                Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.search_normal,
                        size: 20,
                        color: AppColors.darkGrey,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          // 'Search results for "${controller.searchQuery.value}"',
                          '${AppLocalizations.of(context).searchResultsFor} ${controller.searchQuery.value}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.dark),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Iconsax.close_circle,
                          size: 20,
                          color: AppColors.dark,
                        ),
                        onPressed: controller.clearSearch,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                /// Loading Indicator or Suggestions List
                if (controller.isSearching.value)
                  const Padding(
                    padding: EdgeInsets.all(AppSizes.lg),
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: controller.searchSuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = controller.searchSuggestions[index];
                        return _buildSuggestionItem(
                          context,
                          controller,
                          suggestion,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    PlacesMapController controller,
    SearchSuggestion suggestion,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getSuggestionColor(suggestion.type).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        ),
        child: Icon(
          _getSuggestionIcon(suggestion.type),
          color: _getSuggestionColor(suggestion.type),
          size: 20,
        ),
      ),
      title: Text(
        suggestion.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.dark,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: suggestion.subtitle != null
          ? Text(
              suggestion.subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.dark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: suggestion.type == 'current_location'
          ? null
          : Icon(Iconsax.arrow_right_3, size: 16, color: AppColors.darkerGrey),
      onTap: () => controller.onSuggestionSelected(suggestion),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
    );
  }

  Color _getSuggestionColor(String type) {
    switch (type) {
      case 'current_location':
        return AppColors.success;
      case 'recent':
        return AppColors.info;
      case 'place':
        return AppColors.primaryColor;
      default:
        return AppColors.primaryColor;
    }
  }

  IconData _getSuggestionIcon(String type) {
    switch (type) {
      case 'current_location':
        return Iconsax.location;
      case 'recent':
        return Iconsax.clock;
      case 'place':
        return Iconsax.building;
      default:
        return Iconsax.location;
    }
  }

  Widget _buildVoiceSearchOverlay(PlacesMapController controller) {
    return Obx(() {
      if (!controller.isListening.value) return const SizedBox();

      return VoiceSearchOverlay(
        speechText: controller.speechText.value,
        onStop: controller.stopListening,
      );
    });
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top + AppSizes.sm,
      left: AppSizes.defaultSpace,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          // borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            Get.back(result: isPickerMode ? null : null);
          },
          color: AppColors.dark,
        ),
      ),
    );
  }

  Widget _buildPickerBottomSheet(
    BuildContext context,
    PlacesMapController controller,
  ) {
    return Obx(() {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.cardRadiusLg),
              topRight: Radius.circular(AppSizes.cardRadiusLg),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: AppSizes.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(AppSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSizes.cardRadiusMd,
                            ),
                          ),
                          child: Icon(
                            Iconsax.location,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // 'Selected Location',
                                AppLocalizations.of(context).selectedLocation,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkGrey,
                                    ),
                              ),
                              Text(
                                // 'Tap on the map to select a location',
                                AppLocalizations.of(
                                  context,
                                ).tapToSelectLocation,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.darkGrey.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.md),

                    // Location details card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.light.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardRadiusMd,
                        ),
                        border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Iconsax.location,
                                size: 16,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: AppSizes.xs),
                              Text(
                                // 'Location Address',
                                AppLocalizations.of(context).locationAddress,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkGrey,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            controller.locationName.value,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.darkGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (controller.pickedLocation.value != null) ...[
                            const SizedBox(height: AppSizes.sm),
                            Divider(
                              height: 1,
                              color: AppColors.grey.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Row(
                              children: [
                                Icon(
                                  Iconsax.gps,
                                  size: 14,
                                  color: AppColors.darkGrey.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.xs),
                                Expanded(
                                  child: Text(
                                    'Lat: ${controller.pickedLocation.value!.latitude.toStringAsFixed(6)}, Lng: ${controller.pickedLocation.value!.longitude.toStringAsFixed(6)}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.darkGrey.withValues(
                                            alpha: 0.6,
                                          ),
                                          fontFamily: 'monospace',
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (controller.currentLocation.value?.latitude !=
                                  null) {
                                final latLng = LatLng(
                                  controller.currentLocation.value!.latitude!,
                                  controller.currentLocation.value!.longitude!,
                                );
                                controller.onMapTap(latLng);
                                controller.moveCameraToLatLng(latLng);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.lg,
                              ),
                              side: BorderSide(
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.cardRadiusMd,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.gps,
                                  size: 20,
                                  color: AppColors.primaryColor,
                                ),
                                const SizedBox(width: AppSizes.xs),
                                Text(
                                  // 'Current Location',
                                  AppLocalizations.of(context).currentLocation,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controller.pickedLocation.value != null
                                ? controller.savePickedLocation
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.lg,
                              ),
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.cardRadiusMd,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Iconsax.tick_circle,
                                        size: 20,
                                        color: AppColors.white,
                                      ),
                                      const SizedBox(width: AppSizes.xs),
                                      Text(
                                        // 'Confirm Location',
                                        AppLocalizations.of(
                                          context,
                                        ).confirmLocation,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.md),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMapTypeControls(
    BuildContext context,
    PlacesMapController controller,
  ) {
    return Positioned(
      right: 10,
      bottom: isPickerMode ? 200 : 150,
      child: Column(
        children: [
          _buildMapControlButton(
            Iconsax.layer,
            // 'Map Type',
            AppLocalizations.of(context).mapType,
            () => _showMapTypeDialog(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton(
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    final dark = AppHelperFunctions.isDarkMode(Get.context!);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: dark ? AppColors.darkerGrey : AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: AppSizes.iconMd, color: AppColors.primaryColor),
        onPressed: onTap,
      ),
    );
  }

  void _showMapTypeDialog(
    BuildContext context,
    PlacesMapController controller,
  ) {
    final locale = AppLocalizations.of(context);
    final dark = AppHelperFunctions.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: dark ? AppColors.dark : AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSizes.cardRadiusLg),
            topRight: Radius.circular(AppSizes.cardRadiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Text(
                // 'Map Type',
                locale.mapType,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dark ? AppColors.white : AppColors.black,
                ),
              ),
            ),
            _buildMapTypeOption(
              context,
              controller,
              MapType.normal,
              // 'Default',
              locale.defaultMap,
              Icons.map,
            ),
            _buildMapTypeOption(
              context,
              controller,
              MapType.satellite,
              // 'Satellite',
              locale.satellite,
              Icons.satellite,
            ),
            _buildMapTypeOption(
              context,
              controller,
              MapType.terrain,
              // 'Terrain',
              locale.terrain,
              Icons.terrain,
            ),
            _buildMapTypeOption(
              context,
              controller,
              MapType.hybrid,
              // 'Hybrid',
              locale.hybrid,
              Icons.layers,
            ),
            const SizedBox(height: AppSizes.defaultSpace),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTypeOption(
    BuildContext context,
    PlacesMapController controller,
    MapType type,
    String label,
    IconData icon,
  ) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        ),
        child: Icon(icon, color: AppColors.primaryColor),
      ),
      title: Text(
        label,
        style: TextStyle(color: dark ? AppColors.white : AppColors.dark),
      ),
      trailing: controller.currentMapType.value == type
          ? Icon(Icons.check, color: AppColors.primaryColor)
          : null,
      onTap: () {
        controller.changeMapType(type);
        Get.back();
      },
    );
  }

  Widget _buildLoadingOverlay(
    PlacesMapController controller,
    BuildContext context,
  ) {
    final locale = AppLocalizations.of(context);
    return Obx(() {
      if (!controller.isLoading.value) return const SizedBox();

      return Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSizes.xl),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.primaryColor,
                  strokeWidth: 3,
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  // 'Loading Places...',
                  locale.loadingPlaces,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  // 'Finding the best places around you',
                  locale.findingBestPlaces,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.darkGrey),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
