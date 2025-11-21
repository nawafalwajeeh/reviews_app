

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/features/review/controllers/map_controller.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import 'widgets/map_search_container.dart';

class MapScreen extends StatelessWidget {
  final bool isPickerMode;
  const MapScreen({super.key, this.isPickerMode = false});

  @override
  Widget build(BuildContext context) {
    final controller = MapController.instance;
    final searchController = TextEditingController();
    final searchFocusNode = FocusNode();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          /// Google Map
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryColor),
                    SizedBox(height: AppSizes.md),
                    Text('Loading map...'),
                  ],
                ),
              );
            }

            final initialLocation = controller.currentLocation.value;
            final initialPosition = CameraPosition(
              target:
                  initialLocation != null &&
                      initialLocation.latitude != null &&
                      initialLocation.longitude != null
                  ? LatLng(
                      initialLocation.latitude!,
                      initialLocation.longitude!,
                    )
                  : MapController.defaultLocation,
              zoom: 13.5,
            );

            return GoogleMap(
              initialCameraPosition: initialPosition,
              onMapCreated: controller.onMapCreated,
              onTap: isPickerMode ? controller.onMapTap : null,
              markers: controller.markers.toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              compassEnabled: true,
              mapType: MapType.normal,
            );
          }),

          /// Search Header
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSizes.sm,
            left: AppSizes.defaultSpace,
            right: AppSizes.defaultSpace,
            child: isPickerMode
                ? _buildPickerHeader(context, controller)
                : _buildSearchHeader(
                    context,
                    controller,
                    searchController,
                    searchFocusNode,
                  ),
          ),

          /// Search Suggestions
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: AppSizes.defaultSpace,
            right: AppSizes.defaultSpace,
            child: _buildSearchSuggestions(context, controller),
          ),

          /// Location Info Card (for picker mode)
          if (isPickerMode) _buildLocationInfoCard(context, controller),

          /// Confirmation Button (for picker mode)
          if (isPickerMode) _buildConfirmationButton(context, controller),

          /// Location Details Bottom Sheet
          _buildLocationDetailsSheet(context, controller),
        ],
      ),
    );
  }

  /// Build search header with dynamic search
  Widget _buildSearchHeader(
    BuildContext context,
    MapController controller,
    TextEditingController searchController,
    FocusNode searchFocusNode,
  ) {
    return Column(
      children: [
        /// Search Container
        MapSearchContainer(
          text: 'Search for places...',
          controller: searchController,
          focusNode: searchFocusNode,
          onChanged: controller.onSearchQueryChanged,
          onTap: () {
            searchFocusNode.requestFocus();
          },
        ),

        /// Current Location Chip
        Obx(() {
          if (controller.searchQuery.value.isEmpty) {
            return GestureDetector(
              onTap: () {
                controller.onSuggestionSelected(
                  SearchSuggestion(
                    id: 'current_location',
                    title: 'Your Current Location',
                    type: 'current_location',
                    icon: 'my_location',
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(top: AppSizes.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGrey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.location,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      'Current Location',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        }),
      ],
    );
  }

  /// Build search suggestions list
  Widget _buildSearchSuggestions(
    BuildContext context,
    MapController controller,
  ) {
    return Obx(() {
      if (controller.searchSuggestions.isEmpty ||
          controller.searchQuery.value.isEmpty) {
        return const SizedBox();
      }

      return Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          ),
          child: Column(
            children: [
              /// Loading indicator
              if (controller.isSearching.value)
                const Padding(
                  padding: EdgeInsets.all(AppSizes.md),
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              else
                /// Suggestions list
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
      );
    });
  }

  /// Build individual suggestion item
  Widget _buildSuggestionItem(
    BuildContext context,
    MapController controller,
    SearchSuggestion suggestion,
  ) {
    return ListTile(
      leading: _getSuggestionIcon(suggestion),
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
        vertical: AppSizes.xs,
      ),
    );
  }

  /// Get appropriate icon for suggestion type
  Widget _getSuggestionIcon(SearchSuggestion suggestion) {
    IconData icon;
    Color color = AppColors.primaryColor;

    switch (suggestion.type) {
      case 'current_location':
        icon = Iconsax.location;
        color = AppColors.success;
        break;
      case 'place':
        icon = _getPlaceIcon(suggestion.icon);
        break;
      case 'address':
        icon = Iconsax.location;
        break;
      default:
        icon = Iconsax.location;
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  /// Map icon names to Material Icons
  IconData _getPlaceIcon(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Iconsax.cup;
      case 'local_bar':
        return Iconsax.cup;
      case 'hotel':
        return Iconsax.building;
      case 'store':
        return Iconsax.shop;
      case 'park':
        return Iconsax.cup;
      case 'museum':
        return Iconsax.building_3;
      case 'local_hospital':
        return Iconsax.hospital;
      case 'school':
        return Iconsax.teacher;
      case 'local_gas_station':
        return Iconsax.gas_station;
      case 'account_balance':
        return Iconsax.bank;
      default:
        return Iconsax.location;
    }
  }

  /// Build location details bottom sheet
  Widget _buildLocationDetailsSheet(
    BuildContext context,
    MapController controller,
  ) {
    return Obx(() {
      if (!controller.showLocationDetails.value ||
          controller.selectedPlaceDetails.value == null) {
        return const SizedBox();
      }

      final details = controller.selectedPlaceDetails.value!;

      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Material(
            elevation: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.cardRadiusLg),
              topRight: Radius.circular(AppSizes.cardRadiusLg),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header with close button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          details.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: controller.hideLocationDetails,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),

                  /// Address
                  if (details.address != null)
                    Row(
                      children: [
                        Icon(
                          Iconsax.location,
                          size: 16,
                          color: AppColors.darkGrey,
                        ),
                        const SizedBox(width: AppSizes.xs),
                        Expanded(
                          child: Text(
                            details.address!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.darkGrey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  /// Rating (if available)
                  if (details.rating != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.sm),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.star1,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Text(
                            '${details.rating}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (details.totalRatings != null) ...[
                            const SizedBox(width: AppSizes.xs),
                            Text(
                              '(${details.totalRatings} reviews)',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.darkGrey),
                            ),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: AppSizes.md),

                  /// Action Buttons
                  Row(
                    children: [
                      if (isPickerMode)
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                controller.selectCurrentLocationForPicking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.md,
                              ),
                            ),
                            child: const Text('Select This Location'),
                          ),
                        ),
                      if (!isPickerMode) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Add to favorites or other action
                            },
                            child: const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Get directions
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.white,
                            ),
                            child: const Text('Directions'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Build picker mode header
  Widget _buildPickerHeader(BuildContext context, MapController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGrey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkGrey),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pick Location',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Obx(
                  () => Text(
                    controller.locationName.value,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.darkGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // In _buildLocationInfoCard, make it more prominent:
  Widget _buildLocationInfoCard(
    BuildContext context,
    MapController controller,
  ) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: AppSizes.defaultSpace,
      right: AppSizes.defaultSpace,
      child: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(
            0,
            controller.pickedLocation.value != null ? 0 : -100,
            0,
          ),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            ),
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_pin,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        'Selected Location',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    controller.locationName.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (controller.pickedLocation.value != null) ...[
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      'Lat: ${controller.pickedLocation.value!.latitude.toStringAsFixed(6)}\n'
                      'Lng: ${controller.pickedLocation.value!.longitude.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.darkGrey,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build confirmation button
  Widget _buildConfirmationButton(
    BuildContext context,
    MapController controller,
  ) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + AppSizes.defaultSpace,
      left: AppSizes.defaultSpace,
      right: AppSizes.defaultSpace,
      child: Obx(
        () => AnimatedOpacity(
          opacity: controller.pickedLocation.value != null ? 1.0 : 0.6,
          duration: const Duration(milliseconds: 300),
          child: ElevatedButton(
            onPressed: controller.pickedLocation.value != null
                ? controller.savePickedLocation
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Confirm Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
