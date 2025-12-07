import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/gallery_controller.dart';
import 'package:reviews_app/features/review/models/gallery_image_model.dart'; // REQUIRED MODEL
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../localization/app_localizations.dart';
import 'widgets/collection_photo_item.dart';

class CollectionPhotosScreen extends StatelessWidget {
  final String collectionId;

  const CollectionPhotosScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    final controller = GalleryController.instance;
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Obx(
          () => Text(
            controller.newCollectionTitle.value.isEmpty
                // ? 'Collection Photos'
                ? locale.collectionPhotos
                : controller.newCollectionTitle.value,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: FutureBuilder<List<GalleryImageModel>>(
          future: controller.getPhotosByCollectionId(collectionId),
          builder: (context, snapshot) {
            /// -- Handle Loader, Empty, Error Message
            final widget = AppCloudHelperFunctions.checkMultiRecordState(
              snapshot: snapshot,
              loader: const Center(child: CircularProgressIndicator()),
            );

            if (widget != null) return Center(child: widget);

            /// -- Record Found!
            final photos = snapshot.data!;

            if (photos.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(top: AppSizes.spaceBtwSections),
                  // child: Text('No photos found in this collection.'),
                  child: Text(locale.noPhotosFound),
                ),
              );
            }

            //  Group the photos by placeName
            final Map<String, List<GalleryImageModel>> groupedPhotos = {};
            for (var photo in photos) {
              // Use PlaceName for grouping, defaulting to 'Uncategorized' if empty
              final name = photo.placeName.isNotEmpty
                  ? photo.placeName
                  // : 'Uncategorized';
                  : locale.uncategorized;
              if (!groupedPhotos.containsKey(name)) {
                groupedPhotos[name] = [];
              }
              groupedPhotos[name]!.add(photo);
            }

            // Build the UI by iterating through the grouped map keys (place names)
            final List<String> placeNames = groupedPhotos.keys.toList();

            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: placeNames.length,
              // Separate each place section clearly
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSizes.spaceBtwSections),
              itemBuilder: (context, index) {
                final placeName = placeNames[index];
                final images = groupedPhotos[placeName]!;

                // This is the separate row for each place
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
                    //     return CollectionPhotoItem(
                    //       imageUrl: imageModel.imageUrl,
                    //     );
                    //   }).toList(),
                    // ),

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
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
