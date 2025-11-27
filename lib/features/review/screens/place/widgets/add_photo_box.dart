import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

import '../../../../../localization/app_localizations.dart';
import '../../../../../utils/constants/sizes.dart';

class AddPhotoBox extends StatelessWidget {
  const AddPhotoBox({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PlaceController.instance;
    final dark = AppHelperFunctions.isDarkMode(context);

    return Obx(() {
      final selectedImages = controller.selectedLocalImageFiles;
      final bool hasImages = selectedImages.isNotEmpty;

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
          child: hasImages
              ? _buildImagePreview(context, controller, selectedImages)
              : _buildEmptyState(context),
        ),
      );
    });
  }

  /// Widget for the empty state (The original prompt)
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
              // 'Upload up to ${PlaceController.instance.maxImages} photos of this place', // Use the constant maxImages
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

  /// Widget to display the selected images and the "Add More" tile
  Widget _buildImagePreview(
    BuildContext context,
    PlaceController controller,
    List<File> images,
  ) {
    // Calculate the size of each image tile
    const double imageSize = 100.0;

    // We use Padding around the Wrap to maintain spacing like the empty container
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: [
            // 1. Display the selected images
            ...List.generate(images.length, (index) {
              return SizedBox(
                width: imageSize,
                height: imageSize,
                child: Stack(
                  children: [
                    // Image Preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusSm,
                      ),
                      child: Image.file(
                        images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),

                    // Remove Button (Top Right)
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

            // 2. Add More Button (if image limit not reached)
            if (images.length < PlaceController.instance.maxImages)
              SizedBox(
                width: imageSize,
                height: imageSize,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.light,
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadiusSm,
                    ),
                    border: Border.all(color: AppColors.darkerGrey),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_a_photo,
                      color: AppColors.darkerGrey,
                      size: 30,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
