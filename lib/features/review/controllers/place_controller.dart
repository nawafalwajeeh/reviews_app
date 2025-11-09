import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
import 'package:reviews_app/data/services/cloud_storage/supabase_storage_service.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import 'package:reviews_app/features/review/models/place_category_model.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/place/place_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../models/category_model.dart';
import '../models/place_model.dart';

class PlaceController extends GetxController {
  static PlaceController get instance => Get.find();

  /// Variables
  final isLoading = false.obs;
  final placeRepository = Get.put(PlaceRepository());
  RxList<PlaceModel> featuredPlaces = <PlaceModel>[].obs;
  RxList<PlaceModel> places = <PlaceModel>[].obs;

  // Rx observable for selected categories
  final RxList<CategoryModel> selectedCategories = <CategoryModel>[].obs;

  // Text Editing Controllers & Form Key
  RxBool thumbnailUploader = false.obs;
  RxBool additionalImagesUploader = false.obs;
  RxBool placeDataUploader = false.obs;
  RxBool categoriesRelationshipUploader = false.obs;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController websiteUrlController = TextEditingController();
  GlobalKey<FormState> placeFormKey = GlobalKey<FormState>();

  final RxString selectedLocationName = ''.obs;
  // --- SELECTION & STATE VARIABLES ---
  // Image Handling (for thumbnail and images list)
  final ImagePicker _picker = ImagePicker();
  final RxList<File> selectedLocalImageFiles = <File>[].obs;
  final int maxImages = 15;

  // Category Selection (for the required 'categoryId')
  final RxString selectedCategoryId =
      ''.obs; // Store the ID of the selected category

  // Amenities (for the optional 'amenities' list)
  final RxList<String> selectedTags = <String>[].obs;
  final RxString selectedCategoryName =
      CategoryController.instance.selectedCategoryName;

  final RxBool isFeatured = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedPlaces();
  }

  Future<void> fetchFeaturedPlaces() async {
    try {
      isLoading.value = true;
      final places = await placeRepository.getFeaturedPlaces();
      featuredPlaces.assignAll(places);
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<PlaceModel>> fetchAllFeaturedPlaces() async {
    try {
      final places = await placeRepository.getAllFeaturedPlaces();
      return places;
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  /// Fetch Places By Query
  Future<List<PlaceModel>> fetchPlacesByQuery(Query? query) async {
    try {
      if (query == null) return [];

      final places = await placeRepository.fetchPlacesByQuery(query);
      return places;
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  /// Toggles selection for the amenity chips (multi-select).
  void toggleTag(String tag) {
    if (selectedTags.contains(tag.toString())) {
      selectedTags.remove(tag.toString());
    } else {
      selectedTags.add(tag);
    }
  }

  /// Function to pick multiple images locally
  Future<void> pickAndHandleLocalImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (images.isNotEmpty) {
        for (var xFile in images) {
          if (selectedLocalImageFiles.length < maxImages) {
            selectedLocalImageFiles.add(File(xFile.path));
          } else {
            AppLoaders.warningSnackBar(
              title: 'Image Limit Reached',
              message: 'You can only upload a maximum of $maxImages images.',
            );
            break;
          }
        }
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: 'Image Selection Failed',
        message: 'Could not select images: $e',
      );
    }
  }

  /// Function to upload place images to Supabase Storage
  Future<List<String>> uploadPlaceImages(String userId, String placeId) async {
    try {
      final storage = Get.put(AppSupabaseStorageService());

      if (selectedLocalImageFiles.isEmpty) return [];

      AppFullScreenLoader.openLoadingDialog(
        'Uploading ${selectedLocalImageFiles.length} photos for Place ID: $placeId...',
        AppImages.docerAnimation,
      );

      final List<String> uploadedUrls = [];

      final String storagePath = 'Places/$userId/$placeId';

      for (int i = 0; i < selectedLocalImageFiles.length; i++) {
        final file = selectedLocalImageFiles[i];
        final xFile = XFile(file.path);

        final url = await storage.uploadImageFile(
          storagePath,
          xFile,
          createUniqueName: true, // Generate a UUID filename
        );

        uploadedUrls.add(url);
      }

      AppFullScreenLoader.stopLoading();
      return uploadedUrls;
    } catch (e) {
      AppFullScreenLoader.stopLoading();
      AppLoaders.errorSnackBar(
        title: 'Upload Failed!',
        message: 'Could not upload place images: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Function to open map picker and get location
  void openLocationPicker() {
    // In a real application, this would:
    // 1. Navigate to a map screen (e.g., Get.to(MapPickerScreen())).
    // 2. Allow the user to tap on the map.
    // 3. Reverse-geocode the coordinates to get an address string.
    // 4. Update selectedLocationName.value with the result.

    debugPrint('Opening map picker...');
    Future.delayed(const Duration(milliseconds: 500), () {
      selectedLocationName.value = 'The Colosseum, Rome, Italy';
      debugPrint('Location set from map: ${selectedLocationName.value}');
    });
  }

  /// Helper function to convert an address string to coordinates
  Future<({double latitude, double longitude})> _geocodeAddress(
    String address,
  ) async {
    try {
      // final locations = await locationFromAddress(address);
      // if (locations.isEmpty) throw 'Could not find coordinates for this address.';
      // final location = locations.first;
      // return (latitude: location.latitude, longitude: location.longitude);
      // Simulates a successful geocoding call
      AppFullScreenLoader.openLoadingDialog(
        'Geocoding location...',
        AppImages.docerAnimation,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      return (latitude: 37.7749, longitude: -122.4194); // Mock: San Francisco
    } catch (e) {
      AppLoaders.warningSnackBar(
        title: 'Location Error',
        message:
            'Could not automatically find coordinates for the address provided. Using default (0,0).',
      );
      return (latitude: 0.0, longitude: 0.0);
    }
  }

  /// -- Create new place
  Future<void> createPlace() async {
    try {
      // Start Loading & Form Validation
      AppFullScreenLoader.openLoadingDialog(
        'Creating new place...',
        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!placeFormKey.currentState!.validate()) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // Additional Checks
      if (selectedLocalImageFiles.isEmpty) {
        AppFullScreenLoader.stopLoading();
        AppLoaders.warningSnackBar(
          title: 'No Images',
          message: 'Please select at least one image.',
        );
        return;
      }

      if (selectedCategoryId.isEmpty) {
        AppFullScreenLoader.stopLoading();
        AppLoaders.warningSnackBar(
          title: 'Category Missing',
          message: 'Please select a valid category.',
        );
        return;
      }

      // 2. Geocode the address from the text field
      final coordinates = await _geocodeAddress(locationController.text.trim());

      // 3. Generate a unique ID for the new place
      final userId = AuthenticationRepository.instance.getUserID;
      const Uuid uuid = Uuid();
      final String placeId = uuid.v4();

      // 4. Upload Images to Storage
      final List<String> imageUrls = await uploadPlaceImages(userId, placeId);

      // 5. Prepare Place Model - MAPPING ALL FIELDS
      final newPlace = PlaceModel(
        id: placeId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        location: locationController.text.trim(),
        // Image URLs
        thumbnail: imageUrls.first,
        images: imageUrls.length > 1 ? imageUrls.sublist(1) : null,
        // Selected IDs and Lists
        categoryId: selectedCategoryId.value,
        tags: selectedTags.toList(),
        // Coordinates (Obtained from Geocoding)
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        websiteUrl: websiteUrlController.text.trim().isEmpty
            ? null
            : websiteUrlController.text.trim(),
        userId: userId,
        rating: 0.0,
        isFeatured: isFeatured.value,
        dateAdded: DateTime.now(),
        isFavorite: false,
        phoneNumber: phoneController.text.trim(),
      );

      // 6. Save Place Data to Firestore
      await placeRepository.createPlace(newPlace);
      final linkModel = PlaceCategoryModel(
        placeId: newPlace.id,
        categoryId: newPlace.categoryId,
      );

      // Call the repository function to create the link document
      final linkId = await placeRepository.createPlaceCategory(linkModel);
      debugPrint(
        'Place-Category link created with ID: $linkId, CategoryId: ${linkModel.categoryId}',
      );
      // 7. Success Handling and Cleanup
      AppFullScreenLoader.stopLoading();
      AppLoaders.successSnackBar(
        title: 'Success!',
        message: 'Your new place "${newPlace.title}" has been created!',
      );
      _resetForm();
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      AppFullScreenLoader.stopLoading();
      Get.back();
    }
  }

  /// Helper to reset form and image selection state
  void _resetForm() {
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    websiteUrlController.clear();
    selectedCategoryId.value = '';
    selectedTags.clear();
    isFeatured.value = false;
    placeFormKey.currentState?.reset();
    selectedLocalImageFiles.clear();
  }

  void removeLocalImage(int index) {
    if (index >= 0 && index < selectedLocalImageFiles.length) {
      selectedLocalImageFiles.removeAt(index);
    }
  }

  /// Get top rated/trending places (simple sort by rating)
  List<PlaceModel> get trendingPlaces {
    final copy = [...places];
    copy.sort((a, b) => b.rating.compareTo(a.rating));
    return copy.take(10).toList();
  }

  /// Refresh data
  Future<void> refreshAll() async {
    await fetchAllFeaturedPlaces();
  }
}
