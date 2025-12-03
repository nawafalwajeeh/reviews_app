import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import 'package:reviews_app/common/widgets/images/rounded_image.dart';
import 'package:reviews_app/common/widgets/place/favourite_icon/favourite_icon.dart';
import 'package:reviews_app/common/widgets/texts/place_title_text.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/enums.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/images_controller.dart';
import '../../../controllers/review_controller.dart';
import '../../../models/place_model.dart';
import '../../gallery/image_viewer_screen.dart';
// import '../../../controllers/images_controller.dart';

class PlaceImageSlider extends StatelessWidget {
  final PlaceModel place;

  const PlaceImageSlider({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final controller = ImagesController.instance;
    final images = controller.getAllPlaceImages(place);
    final dark = AppHelperFunctions.isDarkMode(context);
    // Get the ReviewController for this place
    final reviewController = Get.find<ReviewController>(tag: place.id);

    return Column(
      // Use Column to stack the header and the slider vertically
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCurvedEdgesWidget(
          child: Container(
            height: 400, // Fixed height for the main image area
            color: dark ? AppColors.darkerGrey : AppColors.light,
            child: Stack(
              // Use Stack for the overlaying elements
              children: [
                /// Main Large Image
                Positioned.fill(
                  child: Obx(() {
                    final image = controller.selectedPlaceImage.value;
                    return InkWell(
                      onTap: () => controller.showEnlargedImage(image),
                      child: CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, size: 60),
                        progressIndicatorBuilder: (_, _, progress) =>
                            CircularProgressIndicator(
                              value: progress.progress,
                              color: AppColors.primaryColor,
                            ),
                      ),
                    );
                  }),
                ),

                /// Gradient Overlay (for text readability)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.5),
                        ],
                        stops: const [0.6, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),

                /// AppBar Icons
                CustomAppBar(
                  showBackArrow: true,
                  actions: [AppFavouriteIcon(placeId: place.id)],
                ),

                /// Title and Rating - Use Obx for reactive updates
                Positioned(
                  left: AppSizes.defaultSpace,
                  bottom: AppSizes.defaultSpace,
                  right: AppSizes.defaultSpace,
                  child: Obx(() {
                    // Use reactive data from ReviewController if available, otherwise use initial place data
                    final currentRating =
                        reviewController.currentPlaceRating.value > 0
                        ? reviewController.currentPlaceRating.value
                        : place.averageRating;

                    final currentReviewsCount =
                        reviewController.currentPlaceReviewsCount.value > 0
                        ? reviewController.currentPlaceReviewsCount.value
                        : place.reviewsCount;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PlaceTitleText(
                          title: place.title,
                          location: place.address.toString(),
                          isVerified: true,
                          isDarkBackground: true,
                          placeTitleSize: TextSizes.large,
                          maxLines: 2,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: AppSizes.xs),
                            Text(
                              // '${currentRating.toStringAsFixed(1)} ($currentReviewsCount reviews)',
                              '${currentRating.toStringAsFixed(1)} ($currentReviewsCount ${AppLocalizations.of(context).reviews})',
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),

                /// Add this at the end (so it's on top):
                Positioned(
                  // left: AppSizes.defaultSpace,
                  left: 10,
                  bottom: AppSizes.defaultSpace,
                  child: Obx(() {
                    final image = controller.selectedPlaceImage.value;
                    return FloatingActionButton.small(
                      heroTag: 'enlarge-image-fab',
                      backgroundColor: Colors.transparent,
                      // onPressed: () => controller.showEnlargedImage(image),
                      onPressed: () => _showEnlargedImage(context, image),
                      child: const Icon(Icons.fullscreen, color: Colors.white),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),

        /// -- Image slider
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          child: SizedBox(
            height: 120, // Slider height
            child: ListView.separated(
              // itemCount: place.images.length, // Use actual image count
              itemCount: images.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSizes.spaceBtwItems),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.defaultSpace,
              ), // Horizontal spacing
              itemBuilder: (_, index) {
                // final imageUrl = place.images[index];
                final imageUrl = images[index];
                return Obx(() {
                  final imageSelected =
                      controller.selectedPlaceImage.value == imageUrl;
                  return GestureDetector(
                    onTap: () => controller.selectedPlaceImage.value = imageUrl,
                    child: AppRoundedImage(
                      width: 160,
                      height: 120,
                      backgroundColor: dark ? AppColors.dark : AppColors.white,
                      border: Border.all(
                        color: imageSelected
                            ? AppColors.primaryColor
                            : Colors.transparent,
                      ),
                      padding: const EdgeInsets.all(AppSizes.xs),
                      isNetworkImage: true,
                      fit: BoxFit.cover,
                      imageUrl: imageUrl,
                    ),
                  );
                });
              },
            ),
          ),
        ),
      ],
    );
  }

void _showEnlargedImage(BuildContext context, String imageUrl) {
  final controller = ImagesController.instance;
  final images = controller.getAllPlaceImages(place);
  final currentIndex = images.indexOf(imageUrl);

  Get.to(
    () => ImageViewerScreen(
      imageUrls: images,
      initialIndex: currentIndex,
      title: place.title,
      subtitle: place.address.toString(),
      rating: place.averageRating,
    ),
  );
}
}
