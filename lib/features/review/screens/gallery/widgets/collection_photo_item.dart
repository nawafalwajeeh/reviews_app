import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../../models/gallery_image_model.dart';
import 'gallery_image_viewer_helper.dart';

/// Separate component for a single image tile within the Collection screen.
// class CollectionPhotoItem extends StatelessWidget {
//   const CollectionPhotoItem({super.key, required this.imageUrl});

//   final String imageUrl;
//   // Adjusted size definition for a better flowing grid look
//   static const double itemHeight = 120.0;
//   static const double itemWidth = 80.0;

//   @override
//   Widget build(BuildContext context) {
//     // Ensure URL is clean
//     final cleanImageUrl = imageUrl.replaceAll('[', '').replaceAll(']', '');

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
//       child: Container(
//         width: itemWidth,
//         height: itemHeight,
//         decoration: BoxDecoration(
//           color: Colors.grey[200], // Placeholder color while loading
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 5,
//               color: Colors.black.withValues(alpha: 0.05),
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Image.network(
//           cleanImageUrl,
//           fit: BoxFit.cover,
//           loadingBuilder: (context, child, loadingProgress) {
//             if (loadingProgress == null) return child;
//             return Container(
//               color: Colors.grey[200],
//               child: const Center(
//                 child: SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               ),
//             );
//           },
//           errorBuilder: (context, error, stackTrace) => Container(
//             color: Colors.red.shade100,
//             child: const Center(
//               child: Icon(Icons.broken_image, color: Colors.red),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// In CollectionPhotoItem class
class CollectionPhotoItem extends StatelessWidget {
  const CollectionPhotoItem({
    super.key, 
    required this.imageUrl,
    required this.galleryImages,
    required this.index,
  });

  final String imageUrl;
  final List<GalleryImageModel> galleryImages;
  final int index;
  static const double itemHeight = 120.0;
  static const double itemWidth = 80.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GalleryImageViewerHelper.openGalleryImageViewer(
          galleryImages: galleryImages,
          initialIndex: index,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        child: Container(
          width: itemWidth,
          height: itemHeight,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.red.shade100,
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/*
// In CollectionPhotosScreen, update the CollectionPhotoItem usage:
Wrap(
  spacing: AppSizes.sm,
  runSpacing: AppSizes.sm,
  children: List.generate(images.length, (imageIndex) {
    final imageModel = images[imageIndex];
    // Calculate the overall index
    int overallIndex = 0;
    for (int i = 0; i < index; i++) {
      overallIndex += groupedPhotos[placeNames[i]]!.length;
    }
    overallIndex += imageIndex;
    
    return CollectionPhotoItem(
      imageUrl: imageModel.imageUrl,
      galleryImages: photos, // Pass all photos
      index: overallIndex, // Pass the overall index
    );
  }),
),
*/