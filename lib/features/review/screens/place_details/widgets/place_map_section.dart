// widgets/place_map_section.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/constants/marker_icons.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

import '../../../../../localization/app_localizations.dart';

class PlaceMapSection extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String placeName;
  final double rating;
  final String? categoryId;

  const PlaceMapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.placeName,
    this.rating = 0.0,
    this.categoryId,
  });

  @override
  State<PlaceMapSection> createState() => _PlaceMapSectionState();
}

class _PlaceMapSectionState extends State<PlaceMapSection> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  BitmapDescriptor? _customMarker;

  @override
  void initState() {
    super.initState();
    _createCustomMarker();
  }

  Future<void> _createCustomMarker() async {
    try {
      final marker = await CustomMarkerGenerator.createPlaceMarker(
        title: widget.placeName,
        rating: widget.rating,
        isSelected: true, // Always show as selected in detail view
        categoryId: widget.categoryId,
      );

      setState(() {
        _customMarker = marker;
      });

      _addMarkerToMap();
    } catch (e) {
      print('Error creating custom marker: $e');
      // Fallback - add default marker
      _addDefaultMarker();
    }
  }

  void _addMarkerToMap() {
    if (_customMarker == null) return;

    final marker = Marker(
      markerId: MarkerId(widget.placeName),
      position: LatLng(widget.latitude, widget.longitude),
      icon: _customMarker!,
      infoWindow: InfoWindow(
        title: widget.placeName,
        snippet: widget.rating > 0 ? '${widget.rating} ⭐' : widget.placeName,
      ),
      anchor: const Offset(0.5, 1.0), // Anchor at bottom center for the pointer
      consumeTapEvents: true,
      onTap: () {
        // Optional: Add tap functionality
        print('Marker tapped: ${widget.placeName}');
      },
    );

    setState(() {
      _markers.add(marker);
    });
  }

  void _addDefaultMarker() {
    final marker = Marker(
      markerId: MarkerId(widget.placeName),
      position: LatLng(widget.latitude, widget.longitude),
      infoWindow: InfoWindow(title: widget.placeName),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Zoom to the marker position with nice animation
    Future.delayed(const Duration(milliseconds: 300), () {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(widget.latitude, widget.longitude),
            zoom: 16.0, // Closer zoom for detail view
            bearing: 0,
            tilt: 30, // Slight tilt for better perspective
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeading(
          // title: 'Location on Map',
          title: AppLocalizations.of(context).locationOnMap,
          showActionButton: false,
        ),
        const SizedBox(height: AppSizes.spaceBtwItems),

        // Map Container
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
            child: Stack(
              children: [
                // Google Map
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.latitude, widget.longitude),
                    zoom: 14,
                  ),
                  markers: _markers,
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: true, // Allow exploring around
                  zoomGesturesEnabled: false, // Allow zooming
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  mapType: MapType.normal,
                  buildingsEnabled: true,
                  compassEnabled: false,
                  myLocationButtonEnabled: false,
                ),

                // Loading indicator while marker is being created
                if (_customMarker == null && _markers.isEmpty)
                  Container(
                    color: Colors.black.withValues(alpha: 0.05),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppSizes.cardRadiusMd,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: AppSizes.sm),
                            // Text('Loading location...'),
                            Text(AppLocalizations.of(context).loading),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Location coordinates display
        const SizedBox(height: AppSizes.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // 'Location Coordinates',
                      AppLocalizations.of(context).locationCoordinates,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.darkerGrey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lat: ${widget.latitude.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                        color: AppHelperFunctions.isDarkMode(context)
                            ? AppColors.dark
                            : AppColors.darkerGrey,
                      ),
                    ),
                    Text(
                      'Lng: ${widget.longitude.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                        color: AppHelperFunctions.isDarkMode(context)
                            ? AppColors.dark
                            : AppColors.darkerGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
