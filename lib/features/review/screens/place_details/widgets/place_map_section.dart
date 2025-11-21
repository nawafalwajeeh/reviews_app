// Create a new file: widgets/place_map_section.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class PlaceMapSection extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String placeName;

  const PlaceMapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.placeName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeading(
          title: 'Location on Map',
          showActionButton: false,
        ),
        const SizedBox(height: AppSizes.spaceBtwItems),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(placeName),
                  position: LatLng(latitude, longitude),
                  infoWindow: InfoWindow(title: placeName),
                ),
              },
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
          ),
        ),
      ],
    );
  }
}