import 'package:flutter/material.dart';

import 'amenity_chip.dart';

class AmenitiesSection extends StatelessWidget {
  const AmenitiesSection({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => AmenityChip(amenity: tag)).toList(),
          ),
        ],
      ),
    );
  }
}
