import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/features/review/controllers/map_controller.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../utils/constants/enums.dart';
import '../../../personalization/models/address_model.dart';
import 'widgets/map_search_container.dart';
import 'widgets/voice_search_overlay.dart';
import 'widgets/loading_overlay.dart';

class MapScreen extends StatelessWidget {
  final bool isPickerMode;
  const MapScreen({super.key, this.isPickerMode = false});

  // Static method to open as picker
  static Future<AddressModel?> openLocationPicker() async {
    return await Get.to<AddressModel?>(
      () => const MapScreen(isPickerMode: true),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MapController());

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          /// Google Map
          _buildMap(controller),

          /// Top Search & Controls
          _buildTopControls(context, controller),

          /// Search Suggestions
          _buildSearchSuggestions(context, controller),

          /// Voice Search Overlay
          _buildVoiceSearchOverlay(controller),

          /// Map Type Controls
          _buildMapTypeControls(context, controller),

          /// Current Location FAB
          // _buildCurrentLocationFAB(controller),

          /// Picker Bottom Sheet
          if (isPickerMode) _buildPickerBottomSheet(context, controller),

          /// Loading Overlay
          _buildLoadingOverlay(controller),

          /// Picker Mode Back Button
          if (isPickerMode) _buildPickerAppBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'location_fab_${isPickerMode ? 'picker' : 'explore'}',
        onPressed: () => controller.moveToCurrentLocation(),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryColor,
        elevation: 4,
        child: const Icon(Iconsax.location, size: AppSizes.iconMd),
      ),
    );
  }

  Widget _buildMap(MapController controller) {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.currentLocation.value == null) {
        return _buildLoadingState();
      }

      final initialLocation = controller.currentLocation.value;
      final initialPosition = CameraPosition(
        target:
            initialLocation != null &&
                initialLocation.latitude != null &&
                initialLocation.longitude != null
            ? LatLng(initialLocation.latitude!, initialLocation.longitude!)
            : const LatLng(51.5074, 0.1278), // London fallback
        zoom: isPickerMode ? 16.0 : 13.5, // Higher zoom for picker mode
      );

      return GoogleMap(
        initialCameraPosition: initialPosition,
        onMapCreated: controller.onMapCreated,
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
      );
    });
  }

  Widget _buildLoadingState() {
    return const LoadingOverlay();
  }

  Widget _buildPickerAppBar() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.defaultSpace,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Iconsax.arrow_left),
                onPressed: () {
                  Get.back(result: null);
                },
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                'Choose Location',
                style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls(BuildContext context, MapController controller) {
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
                      ? 'Search for an address...'
                      : 'Search for places, addresses...',
                  onChanged: controller.onSearchQueryChanged,
                  onVoiceSearch: () => controller.startListening(),
                  isListening: controller.isListening.value,
                  onClear: controller.clearSearch,
                ),
              ),
            ],
          ),

          /// Current Location Chip
          if (!isPickerMode)
            Obx(() => _buildQuickAccessChips(context, controller)),
        ],
      ),
    );
  }

  Widget _buildQuickAccessChips(
    BuildContext context,
    MapController controller,
  ) {
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
              'Current Location',
              Iconsax.location,
              () => controller.onSuggestionSelected(
                SearchSuggestion(
                  id: 'current_location',
                  title: 'Your Current Location',
                  type: 'current_location',
                  icon: 'my_location',
                ),
              ),
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
                color: AppColors.darkGrey.withOpacity(0.1),
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
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

  void _handleRecentSearchTap(MapController controller, RecentSearch recent) {
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
    MapController controller,
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
                          'Search results for "${controller.searchQuery.value}"',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.darkGrey),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Iconsax.close_circle,
                          size: 20,
                          color: AppColors.darkGrey,
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
    MapController controller,
    SearchSuggestion suggestion,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getSuggestionColor(suggestion.type).withOpacity(0.1),
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
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: suggestion.subtitle != null
          ? Text(
              suggestion.subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.darkGrey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: suggestion.type == 'current_location'
          ? null
          : Icon(Iconsax.arrow_right_3, size: 16, color: AppColors.darkGrey),
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

  Widget _buildVoiceSearchOverlay(MapController controller) {
    return Obx(() {
      if (!controller.isListening.value) return const SizedBox();

      return VoiceSearchOverlay(
        speechText: controller.speechText.value,
        onStop: controller.stopListening,
      );
    });
  }

  Widget _buildMapTypeControls(BuildContext context, MapController controller) {
    return Positioned(
      right: AppSizes.defaultSpace,
      bottom: isPickerMode ? 200 : 150,
      child: Column(
        children: [
          _buildMapControlButton(
            Iconsax.layer,
            'Map Type',
            () => _showMapTypeDialog(context, controller),
          ),
          const SizedBox(height: AppSizes.sm),
          _buildMapControlButton(
            Iconsax.filter,
            'Map Details',
            () => _showMapDetailsDialog(context, controller),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: AppSizes.iconLg, color: AppColors.primaryColor),
        onPressed: onTap,
      ),
    );
  }

  void _showMapTypeDialog(BuildContext context, MapController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
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
                'Map Type',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildMapTypeOption(
              context,
              controller,
              MapType.normal,
              'Default',
              Icons.map,
            ),
            _buildMapTypeOption(
              context,
              controller,
              MapType.satellite,
              'Satellite',
              Icons.satellite,
            ),
            _buildMapTypeOption(
              context,
              controller,
              MapType.terrain,
              'Terrain',
              Icons.terrain,
            ),
            _buildMapTypeOption(
              context,
              controller,
              MapType.hybrid,
              'Hybrid',
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
    MapController controller,
    MapType type,
    String label,
    IconData icon,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        ),
        child: Icon(icon, color: AppColors.primaryColor),
      ),
      title: Text(label),
      trailing: controller.currentMapType.value == type
          ? Icon(Icons.check, color: AppColors.primaryColor)
          : null,
      onTap: () {
        controller.changeMapType(type);
        Get.back();
      },
    );
  }

  void _showMapDetailsDialog(BuildContext context, MapController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
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
                'Map Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildMapDetailOption(
              context,
              controller,
              MapDetail.transit,
              'Transit',
              Icons.directions_transit,
            ),
            _buildMapDetailOption(
              context,
              controller,
              MapDetail.traffic,
              'Traffic',
              Icons.traffic,
            ),
            _buildMapDetailOption(
              context,
              controller,
              MapDetail.bicycling,
              'Bicycling',
              Icons.pedal_bike,
            ),
            _buildMapDetailOption(
              context,
              controller,
              MapDetail.map3D,
              '3D Buildings',
              Icons.architecture,
            ),
            const SizedBox(height: AppSizes.defaultSpace),
          ],
        ),
      ),
    );
  }

  Widget _buildMapDetailOption(
    BuildContext context,
    MapController controller,
    MapDetail detail,
    String label,
    IconData icon,
  ) {
    return Obx(
      () => ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
          ),
          child: Icon(icon, color: AppColors.primaryColor),
        ),
        title: Text(label),
        trailing: Switch(
          value: controller.enabledMapDetails.contains(detail),
          onChanged: (value) => controller.toggleMapDetail(detail),
          activeThumbColor: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildPickerBottomSheet(
    BuildContext context,
    MapController controller,
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
                color: Colors.black.withOpacity(0.2),
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
                  color: AppColors.darkGrey.withOpacity(0.3),
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
                            color: AppColors.primaryColor.withOpacity(0.1),
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
                                'Selected Location',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkGrey,
                                    ),
                              ),
                              Text(
                                'Tap on the map to select a location',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.darkGrey.withOpacity(
                                        0.7,
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
                        color: AppColors.light.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardRadiusMd,
                        ),
                        border: Border.all(
                          color: AppColors.grey.withOpacity(0.3),
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
                                'Location Address',
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
                              color: AppColors.grey.withOpacity(0.3),
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Row(
                              children: [
                                Icon(
                                  Iconsax.gps,
                                  size: 14,
                                  color: AppColors.darkGrey.withOpacity(0.6),
                                ),
                                const SizedBox(width: AppSizes.xs),
                                Expanded(
                                  child: Text(
                                    'Lat: ${controller.pickedLocation.value!.latitude.toStringAsFixed(6)}, Lng: ${controller.pickedLocation.value!.longitude.toStringAsFixed(6)}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.darkGrey.withOpacity(
                                            0.6,
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
                                color: AppColors.primaryColor.withOpacity(0.3),
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
                                  'Current Location',
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
                                        'Confirm Location',
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

  Widget _buildLoadingOverlay(MapController controller) {
    return Obx(() {
      if (!controller.isLoading.value) return const SizedBox();

      return const LoadingOverlay();
    });
  }
}
