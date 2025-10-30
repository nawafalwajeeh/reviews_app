import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class ImagesController extends GetxController {
  static ImagesController get instance => Get.find();

  /// Variables
  final RxString selectedPlaceImage = ''.obs;

  /// -- Get All Images from place.
  // List<String> getAllPlaceImages(PlaceModel place) {
  //   // use set to add unique images only
  //   Set<String> images = {};

  //   // Load thumbnail image
  //   images.add(place.thumbnail);

  // Assign Thumbnail as Selected Images
  //   selectedPlaceImage.value = place.thumbnail;

  // Get all images from the PlaceModel if not null.
  //   if (place.images != null) {
  //     images.addAll(place.images!);
  //   }
  //
  //
  //   return images.toList();
  // }

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
}
