import 'package:flutter/material.dart';
import '../../../../../data/services/tag/tag_translation_service.dart';
import 'amenity_chip.dart';

class AmenitiesSection extends StatelessWidget {
  const AmenitiesSection({super.key, required this.tags});

  final List<String> tags; // These are English tags from database

  @override
  Widget build(BuildContext context) {
    // Convert English tags to localized tags for display
    final displayedTags = tags
        .map(
          (tag) =>
              TagTranslationService().getTranslatedNameInContext(tag, context),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            // Pass the localized tags to AmenityChip, not the original English ones
            children: displayedTags
                .map((localizedTag) => AmenityChip(amenity: localizedTag))
                .toList(),
          ),
        ],
      ),
    );
  }
}






//--------------------------
// import 'package:flutter/material.dart';

// import '../../../../../data/services/tag/tag_translation_service.dart';
// import 'amenity_chip.dart';

// class AmenitiesSection extends StatelessWidget {
//   const AmenitiesSection({super.key, required this.tags});

//   final List<String> tags;

//   @override
//   Widget build(BuildContext context) {
//      final displayedTags = tags
//         .map((tag) => TagTranslationService().getTranslatedNameInContext(tag, context))
//         .toList();
    
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: tags.map((tag) => AmenityChip(amenity: tag)).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }
