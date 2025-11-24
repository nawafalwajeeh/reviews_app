import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
import 'package:reviews_app/data/repositories/review/review_repository.dart';
import 'package:reviews_app/data/repositories/user/user_repository.dart';
import 'package:reviews_app/data/services/cloud_storage/supabase_storage_service.dart';
import 'package:reviews_app/features/personalization/controllers/user_controller.dart';
import 'package:reviews_app/features/personalization/models/address_model.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import 'package:reviews_app/features/review/controllers/notification_controller.dart';
import 'package:reviews_app/features/review/models/place_category_model.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/place/place_repository.dart';
import '../../../data/services/barcode/barcode_service.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/logging/logger.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../authentication/screens/signup/signup_screen.dart';
import '../models/category_model.dart';
import '../models/custom_questions_model.dart';
import '../models/place_model.dart';

class PlaceController extends GetxController {
  static PlaceController get instance => Get.find();

  /// Variables
  final isLoading = false.obs;
  final placeRepository = Get.put(PlaceRepository());
  final userRepository = Get.put(UserRepository());
  final notificationController = NotificationController.instance;
  final reviewRepository = Get.put(ReviewRepository());

  // --- REAL-TIME OBSERVABLE LISTS ---
  RxList<PlaceModel> featuredPlaces = <PlaceModel>[].obs;
  RxList<PlaceModel> places = <PlaceModel>[].obs;
  RxList<PlaceModel> categoryPlaces =
      <PlaceModel>[].obs; // NEW: For PlaceListTab

  // --- STREAM SUBSCRIPTIONS ---
  StreamSubscription<List<PlaceModel>>? _featuredPlacesSubscription;
  StreamSubscription<List<PlaceModel>>?
  _categoryPlacesSubscription; // NEW: For PlaceListTab

  // Rx observable for selected categories
  final RxList<CategoryModel> selectedCategories = <CategoryModel>[].obs;

  // Text Editing Controllers & Form Key
  RxBool thumbnailUploader = false.obs;
  RxBool additionalImagesUploader = false.obs;
  RxBool placeDataUploader = false.obs;
  RxBool categoriesRelationshipUploader = false.obs;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  // locationController is now primarily for displaying the address string
  TextEditingController locationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController websiteUrlController = TextEditingController();

  // New controllers for custom questions
  final RxList<CustomQuestion> customQuestions = <CustomQuestion>[].obs;
  final List<TextEditingController> questionControllers = [];
  final List<Rx<QuestionType>> questionTypes = [];
  final List<RxBool> questionRequired = [];

  // Central state for the place's location, ensuring coordinates are initialized to 0.0
  final Rx<AddressModel> selectedAddress = AddressModel.empty().obs;

  GlobalKey<FormState> placeFormKey = GlobalKey<FormState>();
  final userController = UserController.instance;

  // --- SELECTION & STATE VARIABLES ---
  final ImagePicker _picker = ImagePicker();
  final RxList<File> selectedLocalImageFiles = <File>[].obs;
  final int maxImages = 15;

  final RxString selectedCategoryId =
      ''.obs; // Store the ID of the selected category
  final RxList<String> selectedTags = <String>[].obs;
  final RxString selectedCategoryName =
      CategoryController.instance.selectedCategoryName;

  final RxBool isFeatured = true.obs;
  final RxString editingPlaceId = ''.obs;
  final RxList<String> existingImageUrls = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize the real-time stream for featured places (used on Home screen)
    streamFeaturedPlaces();
  }

  @override
  void onClose() {
    // Crucial: Cancel all active stream subscriptions when the controller is closed
    _featuredPlacesSubscription?.cancel();
    _categoryPlacesSubscription?.cancel();
    super.onClose();
  }

  /// Formats the count (e.g., 128000 -> 128K)

  String formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
    } else {
      return count.toString();
    }
  }

  /// Sets up a real-time stream to listen for places belonging to a specific category.
  void streamPlacesForCategory(String categoryId) {
    // 1. Cancel any previous subscription if the user switches tabs/categories
    _categoryPlacesSubscription?.cancel();

    if (categoryId.isEmpty) return; // Guard clause if ID is missing

    // 2. Set loading state and clear old data immediately
    isLoading.value = true;
    categoryPlaces.clear();

    // NOTE: This assumes 'placeRepository.getPlacesForCategoryStream(categoryId)'
    // is implemented in your repository to return a Stream<List<PlaceModel>>.
    _categoryPlacesSubscription = placeRepository
        .getPlacesForCategoryStream(categoryId)
        .listen(
          (placesList) {
            // Update the observable list, triggering the Obx rebuild in PlaceListTab
            categoryPlaces.assignAll(placesList);
            isLoading.value = false;
            AppLoggerHelper.info(
              'Category Places Stream: ${placesList.length} places received for ID $categoryId.',
            );
          },
          onError: (e) {
            AppLoaders.errorSnackBar(
              title: 'Stream Error',
              message: e.toString(),
            );
            AppLoggerHelper.error(
              'Error listening to category places stream: $e',
            );
            isLoading.value = false;
            categoryPlaces.clear();
          },
        );
  }

  /// Sets up a real-time stream to listen for featured places.
  void streamFeaturedPlaces() {
    _featuredPlacesSubscription?.cancel();

    isLoading.value = true;

    // NOTE: This assumes 'placeRepository.getFeaturedPlacesStream()'
    // is implemented in your repository to return a Stream<List<PlaceModel>>.
    _featuredPlacesSubscription = placeRepository
        .getFeaturedPlacesStream()
        .listen(
          (placesList) {
            featuredPlaces.assignAll(placesList);
            places.assignAll(placesList);
            isLoading.value = false;
            AppLoggerHelper.info(
              'Featured Places Stream: ${placesList.length} places received.',
            );
          },
          onError: (e) {
            AppLoaders.errorSnackBar(
              title: 'Stream Error',
              message: e.toString(),
            );
            AppLoggerHelper.error(
              'Error listening to featured places stream: $e',
            );
            isLoading.value = false;
          },
        );
  }

  // --- OLD FUTURE METHODS (Kept as is, but primary updates use streams) ---

  // Renamed old fetchFeaturedPlaces to streamFeaturedPlaces()
  // Old fetchFeaturedPlaces implementation is removed as streaming is preferred for real-time lists.

  Future<List<PlaceModel>> fetchAllFeaturedPlaces() async {
    // ... existing implementation ...
    try {
      final places = await placeRepository.getAllFeaturedPlaces();
      featuredPlaces.assignAll(places);
      return places;
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  /// Fetch Places By Query
  Future<List<PlaceModel>> fetchPlacesByQuery(Query? query) async {
    // ... existing implementation ...
    try {
      if (query == null) return [];

      final places = await placeRepository.fetchPlacesByQuery(query);
      featuredPlaces.assignAll(places);
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
    // ... existing implementation ...
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
    // ... existing implementation ...
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

  void addCustomQuestion() {
    // Limit to 4 questions
    if (customQuestions.length >= 4) {
      AppLoaders.warningSnackBar(
        title: 'Limit Reached',
        message: 'You can only add up to 4 custom questions.',
      );
      return;
    }

    final id = const Uuid().v4();
    customQuestions.add(
      CustomQuestion(id: id, question: '', type: QuestionType.yesOrNo),
    );
    questionControllers.add(TextEditingController());
    questionTypes.add(QuestionType.yesOrNo.obs);
    questionRequired.add(false.obs);
  }

  void removeCustomQuestion(int index) {
    if (index < customQuestions.length) {
      customQuestions.removeAt(index);

      // Dispose and remove controllers safely
      if (index < questionControllers.length) {
        questionControllers[index].dispose();
        questionControllers.removeAt(index);
      }
      if (index < questionTypes.length) {
        questionTypes.removeAt(index);
      }
      if (index < questionRequired.length) {
        questionRequired.removeAt(index);
      }
    }
  }

  void updateQuestion(
    int index,
    String question,
    QuestionType type,
    bool isRequired,
  ) {
    if (index < customQuestions.length) {
      customQuestions[index] = CustomQuestion(
        id: customQuestions[index].id,
        question: question,
        type: type,
        isRequired: isRequired,
      );
    }
  }

  /// -- Create new place
  Future<void> createPlace() async {
    try {
      if (AuthenticationRepository.instance.isGuestUser) {
        AppLoaders.warningSnackBar(
          title: 'Authentication Required',
          message:
              'Please sign in or create an account to save your favorite places.',
        );
        Get.to(() => const SignupScreen());
        return;
      }

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

      // if (selectedAddress.value == AddressModel.empty()) {
      //   AppFullScreenLoader.stopLoading();
      //   AppLoaders.warningSnackBar(
      //     title: 'Location Missing',
      //     message:
      //         'Please use the map picker or select a saved address to set the place location.',
      //   );
      //   return;
      // }

      if (selectedAddress.value == AddressModel.empty() ||
          selectedAddress.value.latitude == 0.0 ||
          selectedAddress.value.longitude == 0.0) {
        AppFullScreenLoader.stopLoading();
        AppLoaders.warningSnackBar(
          title: 'Location Missing',
          message:
              'Please use the map picker to select a valid location with coordinates.',
        );
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

      // 1. Generate a unique ID for the new place
      final userId = AuthenticationRepository.instance.getUserID;
      // final userName = AuthenticationRepository.instance.getDisplayName;
      // final userAvatar = AuthenticationRepository.instance.getPhotoUrl;
      final userName = UserController.instance.user.value.fullName;
      final userAvatar = UserController.instance.user.value.profilePicture;
      const Uuid uuid = Uuid();
      final String placeId = uuid.v4();

      // 2. Upload Images to Storage
      final List<String> imageUrls = await uploadPlaceImages(userId, placeId);

      // 3. Prepare Place Model - Using selectedAddress for location
      final AddressModel placeLocation = selectedAddress.value;

      // Generate barcode data
      final barcodeService = BarcodeService();
      final barcodeData = barcodeService.generateBarcodeData(placeId);

      final newPlace = PlaceModel(
        id: placeId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        address: placeLocation,

        // Image URLs
        thumbnail: imageUrls.first,
        images: imageUrls.length > 1 ? imageUrls.sublist(1) : null,

        // Selected IDs and Lists
        categoryId: selectedCategoryId.value,
        tags: selectedTags.toList(),

        // Coordinates (sourced directly from the selectedAddress)
        // latitude: placeLocation.latitude,
        // longitude: placeLocation.longitude,
        websiteUrl: websiteUrlController.text.trim().isEmpty
            ? null
            : websiteUrlController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        // Metadata
        userId: userId,
        averageRating: 0.0,
        isFeatured: isFeatured.value,
        dateAdded: DateTime.now(),
        isFavorite: false,
        creatorName: userName,
        creatorAvatarUrl: userAvatar,
        likeCount: 0,
        customQuestions: customQuestions.toList(),
        barcodeData: barcodeData,
        uniqueBarcode: 'QR_$placeId', // or generate actual barcode image URL
      );

      // 4. Save Place Data to Firestore
      await placeRepository.createPlace(newPlace);

      // 5. Save Place-Category Link
      final linkModel = PlaceCategoryModel(
        placeId: newPlace.id,
        categoryId: newPlace.categoryId,
      );
      await placeRepository.createPlaceCategory(linkModel);

      AppFullScreenLoader.stopLoading();
      AppLoaders.successSnackBar(
        title: 'Success!',
        message: 'Your new place "${newPlace.title}" has been created!',
      );

      final allUserIds = await UserRepository.instance.getAllUserIds();
      // final senderName = newPlace.userId.substring(
      //   0,
      //   8,
      // ); // Simplified sender name
      final placeTitle = newPlace.title;

      for (final userId in allUserIds) {
        if (userId != newPlace.userId) {
          // Don't notify the sender (creator)
          await notificationController.sendNotification(
            toUserId: userId,
            type: 'new_place',
            title: 'Exciting New Place Added!',
            body: 'A new location, "$placeTitle", has just been added.',
            senderName: 'System Broadcast',
            senderAvatar: newPlace.thumbnail,
            targetId: newPlace.id,
            targetType: 'place',
            extraData: {'categoryId': newPlace.categoryId},
          );
        }
      }

      _resetForm();
      update();
      Get.back();
    } catch (e) {
      AppFullScreenLoader.stopLoading();
      AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Helper to reset form and image selection state
  void _resetForm() {
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    phoneController.clear();
    websiteUrlController.clear();
    selectedCategoryId.value = '';
    selectedTags.clear();
    isFeatured.value = false;
    placeFormKey.currentState?.reset();
    selectedLocalImageFiles.clear();
    selectedAddress.value = AddressModel.empty(); // Reset location
    // Clear custom questions
    customQuestions.clear();
    for (var controller in questionControllers) {
      controller.dispose();
    }
    questionControllers.clear();
    questionTypes.clear();
    questionRequired.clear();
  }

  void removeLocalImage(int index) {
    if (index >= 0 && index < selectedLocalImageFiles.length) {
      selectedLocalImageFiles.removeAt(index);
    }
  }

  /// Get top rated/trending places (simple sort by rating)
  List<PlaceModel> get trendingPlaces {
    // Use featuredPlaces for trending, since it's already a real-time list
    final copy = [...featuredPlaces];
    copy.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return copy.take(10).toList();
  }

  /// Refresh data
  Future<void> refreshAll() async {
    await fetchAllFeaturedPlaces();
  }

  /// Initialize form with existing place data for editing
  void initializeEditForm(PlaceModel place) {
    editingPlaceId.value = place.id;

    // Set existing image URLs
    existingImageUrls.clear();
    if (place.images != null) {
      existingImageUrls.addAll(place.images!);
    }
    // Add thumbnail as the first existing image URL
    if (place.thumbnail.isNotEmpty) {
      existingImageUrls.insert(0, place.thumbnail);
    }

    // Populate form fields
    titleController.text = place.title;
    descriptionController.text = place.description;

    // Set Address Model and Controller Text
    selectedAddress.value = place.address;
    locationController.text = place.address
        .toString(); // Populate text field for display

    phoneController.text = place.phoneNumber ?? '';
    websiteUrlController.text = place.websiteUrl ?? '';
    selectedCategoryId.value = place.categoryId;

    // Set tags
    selectedTags.clear();
    if (place.tags != null) {
      selectedTags.addAll(place.tags!);
    }

    // Clear any previously selected local images
    selectedLocalImageFiles.clear();
  }

  /// Clear edit form data
  void clearEditForm() {
    editingPlaceId.value = '';
    existingImageUrls.clear();
    selectedLocalImageFiles.clear();
    _resetForm();
  }

  /// Update existing place
  Future<void> updatePlace(String placeId) async {
    try {
      // Start Loading & Form Validation
      AppFullScreenLoader.openLoadingDialog(
        'Updating place...',
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

      // --- CRITICAL LOCATION CHECK ---
      if (selectedAddress.value == AddressModel.empty()) {
        AppFullScreenLoader.stopLoading();
        AppLoaders.warningSnackBar(
          title: 'Location Missing',
          message: 'Please select a location for the place.',
        );
        return;
      }

      // Upload new images if any
      List<String> allImageUrls = [...existingImageUrls];
      if (selectedLocalImageFiles.isNotEmpty) {
        final userId = AuthenticationRepository.instance.getUserID;
        final newImageUrls = await uploadPlaceImages(userId, placeId);
        allImageUrls.addAll(newImageUrls);
      }

      // Separate thumbnail and remaining images
      final String finalThumbnail = allImageUrls.isNotEmpty
          ? allImageUrls.first
          : '';
      final List<String>? finalImages = allImageUrls.length > 1
          ? allImageUrls.sublist(1)
          : null;

      // Prepare updated Place Model
      final AddressModel placeLocation = selectedAddress.value;
      final userName = UserController.instance.user.value.fullName;
      final userAvatar = UserController.instance.user.value.profilePicture;

      final updatedPlace = PlaceModel(
        id: placeId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        address: placeLocation,

        // Image URLs - combine existing and new
        thumbnail: finalThumbnail,
        images: finalImages,

        // Selected IDs and Lists
        categoryId: selectedCategoryId.value,
        tags: selectedTags.toList(),

        // Coordinates (sourced directly from the selectedAddress)
        // latitude: placeLocation.latitude,
        // longitude: placeLocation.longitude,
        websiteUrl: websiteUrlController.text.trim().isEmpty
            ? null
            : websiteUrlController.text.trim(),
        phoneNumber: phoneController.text.trim(),

        // Retain existing metadata (note: you might fetch and merge existing data here)
        userId: AuthenticationRepository.instance.getUserID,
        averageRating: 0.0,
        isFeatured: isFeatured.value,
        dateAdded: DateTime.now(),
        isFavorite: false,
        creatorName: userName,
        creatorAvatarUrl: userAvatar,
      );

      // Update place in Firestore
      await placeRepository.updatePlace(updatedPlace);

      AppLoaders.successSnackBar(
        title: 'Success!',
        message: 'Place "${updatedPlace.title}" has been updated!',
      );

      clearEditForm();
      update();
      Get.back();
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Update Failed', message: e.toString());
    } finally {
      AppFullScreenLoader.stopLoading();
    }
  }

  /// Delete place with confirmation
  Future<void> deletePlaceWithConfirmation(PlaceModel place) async {
    // ... existing implementation ...
    Get.defaultDialog(
      title: 'Delete Place?',
      middleText:
          'Are you sure you want to delete "${place.title}"? This action cannot be undone.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: AppColors.white,
      onConfirm: () async {
        Navigator.of(Get.context!).pop();
        await _deletePlace(place);
      },
      onCancel: () => Navigator.of(Get.context!).pop(),
    );
  }

  /// Actual delete implementation
  Future<void> _deletePlace(PlaceModel place) async {
    // ... existing implementation ...
    try {
      AppFullScreenLoader.openLoadingDialog(
        'Deleting place...',
        AppImages.docerAnimation,
      );

      await placeRepository.deletePlace(place);

      // Remove from local lists (Note: Stream listeners will handle this, but
      // manual removal ensures immediate UI update for robustness)
      featuredPlaces.removeWhere((p) => p.id == place.id);
      places.removeWhere((p) => p.id == place.id);
      categoryPlaces.removeWhere(
        (p) => p.id == place.id,
      ); // NEW: Remove from category list

      AppLoaders.successSnackBar(
        title: 'Success!',
        message: 'Place "${place.title}" has been deleted',
      );
      update();
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Delete Failed', message: e.toString());
    } finally {
      AppFullScreenLoader.stopLoading();
    }
  }
}
