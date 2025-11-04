import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/images_controller.dart';
import 'package:reviews_app/features/review/models/place_category_model.dart';
import 'package:reviews_app/utils/popups/full_screen_loader.dart';

import '../../../data/repositories/place/place_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/loaders.dart';
import '../models/category_model.dart';
import '../models/place_model.dart';

class PlaceController extends GetxController {
  static PlaceController get instance => Get.find();

  /// Variables
  final isLoading = false.obs;
  final placeRepository = Get.put(PlaceRepository());
  RxList<PlaceModel> featuredPlaces = <PlaceModel>[].obs;

  // Text editing controllers for input fields
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController salePrice = TextEditingController();
  TextEditingController brandTextField = TextEditingController();
  GlobalKey<FormState> placeFormKey = GlobalKey<FormState>();

  // Rx observable for selected categories
  final RxList<CategoryModel> selectedCategories = <CategoryModel>[].obs;

  // Flags for tracking different tasks
  RxBool thumbnailUploader = false.obs;
  RxBool additionalImagesUploader = false.obs;
  RxBool placeDataUploader = false.obs;
  RxBool categoriesRelationshipUploader = false.obs;

  final places = [
    PlaceModel(
      id: '1',
      userId: '1',
      thumbnail:
          'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      images: [
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      ],
      title: 'Tropical Paradise Resort',
      location: 'Maldives, Indian Ocean',
      categoryId: 'Resort',
      description:
          'Experience the serene beauty of the Maldives with our overwater bungalows and crystal-clear lagoon access. Perfect for honeymooners and families looking for a luxury escape. This detailed description helps guests understand the unique offerings and atmosphere of the destination.',
      rating: 4.8,
      isFavorite: true,
      amenities: [
        'Free Wi-Fi',
        'Swimming Pool',
        'Beach Access',
        'Restaurant',
        'Spa',
        'Gym',
      ],
    ),
    PlaceModel(
      id: '2',
      userId: '2',
      thumbnail:
          'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      images: [
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464979681340-bdd28a61699e?auto=format&fit=crop&w=800&q=80',
      ],
      title: 'Tropical Paradise Resort',
      location: 'Maldives, Indian Ocean',
      categoryId: 'Resort',
      description:
          'Experience the serene beauty of the Maldives with our overwater bungalows and crystal-clear lagoon access. Perfect for honeymooners and families looking for a luxury escape. This detailed description helps guests understand the unique offerings and atmosphere of the destination.',
      rating: 4.8,
      isFavorite: true,
      amenities: [
        'Free Wi-Fi',
        'Swimming Pool',
        'Beach Access',
        'Restaurant',
        'Spa',
        'Gym',
      ],
    ),
  ];

  final List<String> categories = const [
    'All',
    'Restaurant',
    'Hotel',
    'School',
    'Cafe',
    'Park',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedPlaces();
  }

  Future<void> fetchFeaturedPlaces() async {
    try {
      // Show loader while loading products
      isLoading.value = true;

      // Fetch Places
      final places = await placeRepository.getFeaturedPlaces();

      // Assign Products to the list
      featuredPlaces.assignAll(places);
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<PlaceModel>> fetchAllFeaturedPlaces() async {
    try {
      // Fetch Places
      final places = await placeRepository.getAllFeaturedPlaces();
      return places;
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  // // Function to create a new product
  // Future<void> createPlace() async {
  //   try {
  //     // Show progress dialog
  //     AppFullScreenLoader.openLoadingDialog(
  //       'Create your place...',
  //       AppImages.docerAnimation,
  //     );

  //     // Check Internet Connectivity
  //     final isConnected = await AppNetworkManager.instance.isConnected();
  //     if (!isConnected) {
  //       AppFullScreenLoader.stopLoading();
  //       return;
  //     }

  //     // Validate title and description form
  //     if (!placeFormKey.currentState!.validate()) {
  //       AppFullScreenLoader.stopLoading();
  //       return;
  //     }

  //     // Upload Product Thumbnail Image
  //     thumbnailUploader.value = true;
  //     final imagesController = ImagesController.instance;

  //     // Additional Product Images
  //     additionalImagesUploader.value = true;

  //     // Map Product Data to ProductModel
  //     final newRecord = PlaceModel(
  //       id: '',
  //       isFeatured: true,
  //       title: title.text.trim(),
  //       description: description.text.trim(),
  //       location: location.text.trim(),
  //       userId: placeRepository.getCurrentUserId,
  //       // images: imagesController.additionalProductImagesUrls,
  //       thumbnail: imagesController.selectedPlaceImage.value ?? '',
  //       // amenities:
  //       //     ProductAttributesController.instance.productAttributes,
  //       // date: DateTime.now(),
  //        categoryId: '', rating: 0.0,
  //     );

  //     // Call Repository to Create New Product
  //     placeDataUploader.value = true;
  //     newRecord.id = await placeRepository.createPlace(newRecord);

  //     // Register product categories if any
  //     if (selectedCategories.isNotEmpty) {
  //       if (newRecord.id.isEmpty) throw 'Error storing data. Try again';

  //       // Loop through selected Product Categories
  //       categoriesRelationshipUploader.value = true;
  //       for (var category in selectedCategories) {
  //         // Map Data
  //         final placeCategory = PlaceCategoryModel(
  //           placeId: newRecord.id,
  //           categoryId: category.id,
  //         );
  //         await placeRepository.createPlaceCategory(
  //           placeCategory as CategoryModel

  //         );
  //       }
  //     }

  //     // Update Product List
  //     ProductController.instance.addItemToLists(newRecord);

  //     // Close the Progress Loader
  //     TFullScreenLoader.stopLoading();

  //     // Show Success Message Loader
  //     showCompletionDialog();
  //   } catch (e) {
  //     TFullScreenLoader.stopLoading();
  //     TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
  //   }
  // }

  // // Reset form values and flags
  // void resetValues() {
  //   isLoading.value = false;
  //   productType.value = ProductType.single;
  //   productVisibility.value = ProductVisibility.hidden;
  //   stockPriceFormKey.currentState?.reset();
  //   titleDescriptionFormKey.currentState?.reset();
  //   title.clear();
  //   description.clear();
  //   stock.clear();
  //   price.clear();
  //   salePrice.clear();
  //   brandTextField.clear();
  //   selectedBrand.value = null;
  //   selectedCategories.clear();
  //   ProductVariationController.instance.resetAllValues();
  //   ProductAttributesController.instance.resetProductAttributes();

  //   // Reset Upload Flags
  //   thumbnailUploader.value = false;
  //   additionalImagesUploader.value = false;
  //   productDataUploader.value = false;
  //   categoriesRelationshipUploader.value = false;
  // }
}
