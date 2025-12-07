import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/place_model.dart';

class EditPhotoBox extends StatelessWidget {
  final PlaceModel place;

  const EditPhotoBox({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final controller = PlaceController.instance;
    final dark = AppHelperFunctions.isDarkMode(context);

    return Obx(() {
      final selectedImages = controller.selectedLocalImageFiles;
      final bool hasNewImages = selectedImages.isNotEmpty;
      final bool hasExistingImages =
          place.images != null && place.images!.isNotEmpty;

      return GestureDetector(
        onTap: controller.pickAndHandleLocalImages,
        child: Container(
          decoration: BoxDecoration(
            color: dark ? AppColors.dark : AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.spaceBtwItems),
            border: Border.all(
              color: dark ? AppColors.darkGrey : AppColors.grey,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                color: Color(0x1A000000),
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: hasNewImages || hasExistingImages
              ? _buildImagePreview(context, controller, selectedImages, place)
              : _buildEmptyState(context),
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.primaryColor,
              size: 48,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              // 'Add Photos',
              AppLocalizations.of(context).addPhotos,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.primaryColor),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              // 'Upload up to ${PlaceController.instance.maxImages} photos of this place',
              AppLocalizations.of(
                context,
              ).uploadPhotos(PlaceController.instance.maxImages),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppHelperFunctions.isDarkMode(context)
                    ? AppColors.white
                    : AppColors.dark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(
    BuildContext context,
    PlaceController controller,
    List<File> newImages,
    PlaceModel place,
  ) {
    const double imageSize = 100.0;
    // Use the observable list from the controller directly
    final existingImages = controller.existingImageUrls;
    final allImages = [...existingImages];

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use Obx to listen to changes in existingImages
            Obx(() {
              if (existingImages.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // 'Existing Photos',
                      AppLocalizations.of(context).existingPhotos,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Wrap(
                      spacing: AppSizes.sm,
                      runSpacing: AppSizes.sm,
                      children: [
                        ...List.generate(existingImages.length, (index) {
                          return SizedBox(
                            width: imageSize,
                            height: imageSize,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.borderRadiusSm,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: existingImages[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () =>
                                        controller.removeExistingImage(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            if (newImages.isNotEmpty ||
                allImages.length < PlaceController.instance.maxImages) ...[
              if (newImages.isNotEmpty) ...[
                Text(
                  // 'New Photos',
                  AppLocalizations.of(context).newPhotos,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSizes.sm),
              ],
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: [
                  ...List.generate(newImages.length, (index) {
                    return SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadiusSm,
                            ),
                            child: Image.file(
                              newImages[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => controller.removeLocalImage(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  if (allImages.length + newImages.length <
                      PlaceController.instance.maxImages)
                    GestureDetector(
                      onTap: controller.pickAndHandleLocalImages,
                      child: SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: Container(
                          decoration: BoxDecoration(
                            // color: AppColors.light,
                            color: AppHelperFunctions.isDarkMode(context)
                                ? AppColors.darkerGrey
                                : AppColors.light,
                            borderRadius: BorderRadius.circular(
                              AppSizes.borderRadiusSm,
                            ),
                            border: Border.all(
                              color: AppHelperFunctions.isDarkMode(context)
                                  ? AppColors.grey
                                  : AppColors.darkerGrey,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add_a_photo,
                              // color: AppColors.darkerGrey,
                              color: AppHelperFunctions.isDarkMode(context)
                                  ? AppColors.white
                                  : AppColors.darkerGrey,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
