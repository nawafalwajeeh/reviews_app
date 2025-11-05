import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/popups/full_screen_loader.dart'
    show AppFullScreenLoader;

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
  final ImagePicker _picker = ImagePicker();
  final int maxImages = 10;

  // /// -- METHOD: Select Multiple Images from Gallery --
  // Future<void> pickAndHandleLocalImages() async {
  //   try {
  //     final List<XFile> images = await _picker.pickMultiImage();

  //     if (images.isNotEmpty) {
  //       // Filter and add files up to the max limit
  //       for (var xFile in images) {
  //         if (selectedLocalImageFiles.length < maxImages) {
  //           selectedLocalImageFiles.add(File(xFile.path));
  //         } else {
  //           AppLoaders.warningSnackBar(
  //             title: 'Image Limit Reached',
  //             message: 'You can only upload a maximum of $maxImages images.',
  //           );
  //           break;
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     AppLoaders.errorSnackBar(
  //       title: 'Image Selection Failed',
  //       message: 'Could not select images: $e',
  //     );
  //   }
  // }

  // /// -- METHOD: Upload Local Files to Storage and Get URLs --
  // Future<List<String>> uploadPlaceImagesToStorage(String placeId) async {
  //   try {
  //     if (selectedLocalImageFiles.isEmpty) return [];

  //     AppFullScreenLoader.openLoadingDialog(
  //       text: 'Uploading ${selectedLocalImageFiles.length} photos...',
  //       animation: AppImages.docerAnimation,
  //     );

  //     final List<String> uploadedUrls = await
  //         .uploadPlaceImages(placeId, selectedLocalImageFiles.toList());

  //     // Clear local files after successful upload
  //     selectedLocalImageFiles.clear();

  //     return uploadedUrls;
  //   } catch (e) {
  //     AppLoaders.errorSnackBar(
  //       title: 'Image Upload Error',
  //       message: 'Failed to upload images: ${e.toString()}',
  //     );
  //     return [];
  //   }
  // }

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
      title: 'Image Removed',
      message: 'Image URL removed from list.',
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

                child: isNetworkImage
                    ? CachedNetworkImage(
                        imageUrl: image,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : Image.asset(image),
              ),
              SizedBox(height: AppSizes.spaceBtwSections),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 150,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Close'),
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
    if (selectedImages != null && selectedImages.isNotEmpty) {
      additionalPlaceImagesUrls.assignAll(selectedImages.map((e) => e.url));
    }
  }
}
