import 'package:flutter/material.dart';

import 'amenity_chip.dart';

class AmenitiesSection extends StatelessWidget {
  const AmenitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> amenities = [
      'WiFi',
      'Parking',
      'Outdoor Seating',
      'Wheelchair Accessible',
      'Pet Friendly',
      'Takeout',
      'Delivery',
      'Full Bar',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenities
                .map((amenity) => AmenityChip(amenity: amenity))
                .toList(),
          ),
        ],
      ),
    );
  }
}
