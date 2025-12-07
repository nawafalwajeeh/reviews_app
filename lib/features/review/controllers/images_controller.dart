import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/popups/loaders.dart';
import '../models/image_model.dart';
import '../models/place_model.dart';
import 'media_controller.dart';

class ImagesController extends GetxController {
  static ImagesController get instance => Get.find();

  /// Variables
  final RxString selectedPlaceImage = ''.obs;

  // List to store additional images
  final RxList<String> additionalPlaceImagesUrls = <String>[].obs;

  // List to store local File objects before upload
  final RxList<File> selectedLocalImageFiles = <File>[].obs;

  /// Function to remove LOCAL image before submission
  void removeLocalImage(int index) {
    if (index >= 0 && index < selectedLocalImageFiles.length) {
      selectedLocalImageFiles.removeAt(index);
    }
  }

  /// Function to remove Place image
  Future<void> removeImage(int index) async {
    additionalPlaceImagesUrls.removeAt(index);
    AppLoaders.successSnackBar(
      // title: 'Image Removed',
      title: txt.imageDeleted,
      // message: 'Image URL removed from list.',
      message: txt.imageDeletedMessage,
    );
  }

  /// -- Get All Images from place.
  List<String> getAllPlaceImages(PlaceModel place) {
    // use set to add unique images only
    Set<String> images = {};

    // Load thumbnail image
    images.add(place.thumbnail);

    // Assign Thumbnail as Selected Images
    selectedPlaceImage.value = place.thumbnail;

    // Get all images from the PlaceModel if not null.
    if (place.images != null) {
      images.addAll(place.images!);
    }

    return images.toList();
  }

  /// -- show image popup
  void showEnlargedImage(String image, {bool isNetworkImage = true}) {
    debugPrint('Executed');
    Get.to(
      fullscreenDialog: true,
      () => Dialog.fullscreen(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppSizes.defaultSpace * 2,
                  horizontal: AppSizes.defaultSpace,
                ),

                child:
                    // isNetworkImage
                    //     ?
                    CachedNetworkImage(
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
                // : Image.asset(image),
              ),
              SizedBox(height: AppSizes.spaceBtwSections),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 150,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    // child: const Text('Close'),
                    child: Text(txt.close),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick Thumbnail Image from Gallery
  void selectMultiplePlaceImages() async {
    final controller = Get.put(MediaController());
    List<ImageModel>? selectedImages = await controller.selectImagesFromMedia(
      allowMultipleSelection: true,
      alreadySelectedUrls: additionalPlaceImagesUrls,
    );

    // Handle the selected images
    if (selectedImages!.isNotEmpty) {
      additionalPlaceImagesUrls.assignAll(selectedImages.map((e) => e.url));
    }
  }
}
