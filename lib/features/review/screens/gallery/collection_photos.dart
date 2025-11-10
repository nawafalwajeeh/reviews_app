import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/gallery_controller.dart';
import 'package:reviews_app/features/review/models/gallery_image_model.dart'; // REQUIRED MODEL
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart';

class CollectionPhotosScreen extends StatelessWidget {
  final String collectionId;

  const CollectionPhotosScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    final controller = GalleryController.instance;

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.newCollectionTitle.value.isEmpty
                ? 'Collection Photos'
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
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: AppSizes.spaceBtwSections),
                  child: Text('No photos found in this collection.'),
                ),
              );
            }

            //  Group the photos by placeName
            final Map<String, List<GalleryImageModel>> groupedPhotos = {};
            for (var photo in photos) {
              // Use PlaceName for grouping, defaulting to 'Uncategorized' if empty
              final name = photo.placeName.isNotEmpty
                  ? photo.placeName
                  : 'Uncategorized';
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
                    Wrap(
                      spacing: AppSizes.sm, // Horizontal spacing
                      runSpacing: AppSizes.sm, // Vertical spacing
                      children: images.map((imageModel) {
                        return CollectionPhotoItem(
                          imageUrl: imageModel.imageUrl,
                        );
                      }).toList(),
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

/// Separate component for a single image tile within the Collection screen.
class CollectionPhotoItem extends StatelessWidget {
  const CollectionPhotoItem({super.key, required this.imageUrl});

  final String imageUrl;
  // Adjusted size definition for a better flowing grid look
  static const double itemHeight = 120.0;
  static const double itemWidth = 80.0;

  @override
  Widget build(BuildContext context) {
    // Ensure URL is clean
    final cleanImageUrl = imageUrl.replaceAll('[', '').replaceAll(']', '');

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
      child: Container(
        width: itemWidth,
        height: itemHeight,
        decoration: BoxDecoration(
          color: Colors.grey[200], // Placeholder color while loading
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.network(
          cleanImageUrl,
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
    );
  }
}
