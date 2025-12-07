import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/shimmers/gallery_shimmer.dart';
import 'package:reviews_app/features/review/controllers/gallery_controller.dart';
import 'package:reviews_app/features/review/models/gallery_image_model.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart';

import '../../../../../localization/app_localizations.dart';
import 'gallery_image_viewer_helper.dart';
import 'gallery_widgets.dart';

class AllPhotosSection extends StatelessWidget {
  const AllPhotosSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // This top-level header is now more descriptive
          // SectionHeader(title: 'All Place Photos'),
          SectionHeader(title: AppLocalizations.of(context).allPlacePhotos),
          SizedBox(height: AppSizes.spaceBtwItems),
          // The new widget to handle fetching and grouping
          GroupedPhotoList(),
        ],
      ),
    );
  }
}

/// Fetches all images and groups them by their associated place name
class GroupedPhotoList extends StatelessWidget {
  const GroupedPhotoList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GalleryController.instance;

    return FutureBuilder<List<GalleryImageModel>>(
      future: controller.getAllGalleryImages(), // Fetch all images from DB
      builder: (context, snapshot) {
        /// --- Handle Loader, Empty, Error Message
        const loader = GalleryShimmer(
          count: 9,
          aspectRatio: 0.7,
          crossAxisCount: 3,
        );

        final widget = AppCloudHelperFunctions.checkMultiRecordState(
          snapshot: snapshot,
          loader: loader,
        );

        if (widget != null) return widget;

        /// --- Record Found!
        final photos = snapshot.data!;

        // 1. Group the photos by placeName
        final Map<String, List<GalleryImageModel>> groupedPhotos = {};
        for (var photo in photos) {
          final name = photo.placeName;
          if (!groupedPhotos.containsKey(name)) {
            groupedPhotos[name] = [];
          }
          groupedPhotos[name]!.add(photo);
        }

        // 2. Build the UI by iterating through the grouped map
        final List<String> placeNames = groupedPhotos.keys.toList();

        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: placeNames.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSizes.spaceBtwSections),
          itemBuilder: (context, index) {
            final placeName = placeNames[index];
            final images = groupedPhotos[placeName]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the place name as a section header
                Text(
                  placeName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.spaceBtwItems),

                // Display the images for this place in a flowing grid layout (Wrap)
                // Wrap(
                //   spacing: AppSizes.sm, // Horizontal spacing
                //   runSpacing: AppSizes.sm, // Vertical spacing
                //   children: images.map((imageModel) {
                //     // Calculate a reasonable size for the images within the flow layout
                //     const imageSize = 100.0;
                //     return PhotoGridItem(
                //       imageUrl: imageModel.imageUrl,
                //       size: imageSize,
                //     );
                //   }).toList(),
                // ),

                // In GroupedPhotoList class, update the PhotoGridItem usage:
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: List.generate(images.length, (imageIndex) {
                    final imageModel = images[imageIndex];
                    // Calculate the overall index in the grouped list
                    int overallIndex = 0;
                    for (int i = 0; i < index; i++) {
                      overallIndex += groupedPhotos[placeNames[i]]!.length;
                    }
                    overallIndex += imageIndex;

                    return PhotoGridItem(
                      imageUrl: imageModel.imageUrl,
                      galleryImages: photos, // Pass all photos
                      index: overallIndex, // Pass the overall index
                      size: 100.0,
                    );
                  }),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Separate component for a single image tile (was previously in the GridView itemBuilder)
// class PhotoGridItem extends StatelessWidget {
//   const PhotoGridItem({super.key, required this.imageUrl, this.size = 100.0});

//   final String imageUrl;
//   final double size;

//   @override
//   Widget build(BuildContext context) {
//     // We use ClipRRect and a Container to maintain the current visual style
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
//       child: Container(
//         width: size,
//         height:
//             size * 0.7, // Using the 0.7 aspect ratio from your previous code
//         decoration: BoxDecoration(
//           color: Colors.grey[200], // Placeholder color while loading
//           image: DecorationImage(
//             fit: BoxFit.cover,
//             image: NetworkImage(imageUrl), // Guaranteed clean URL
//           ),
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 8,
//               color: Colors.black.withValues(alpha: 0.1),
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// In PhotoGridItem class
class PhotoGridItem extends StatelessWidget {
  const PhotoGridItem({
    super.key,
    required this.imageUrl,
    required this.galleryImages, // Pass the list of gallery images
    required this.index, // Index of this image in the list
    this.size = 100.0,
  });

  final String imageUrl;
  final List<GalleryImageModel> galleryImages;
  final int index;
  final double size;

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
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        child: Container(
          width: size,
          height: size * 0.7,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(imageUrl),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
