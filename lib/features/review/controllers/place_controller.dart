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
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../../../data/services/barcode/barcode_service.dart';
import '../../review/screens/map/place_map.dart';
import '../../../data/repositories/place/place_repository.dart';
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
import 'subscription_controller.dart';

class PlaceController extends GetxController {
  static PlaceController get instance => Get.find();

  /// Variables
  final isLoading = false.obs;
  final placeRepository = Get.put(PlaceRepository());
  final userRepository = Get.put(UserRepository());
  final notificationController = NotificationController.instance;
  final reviewRepository = Get.put(ReviewRepository());
  final subscriptionController = Get.put(SubscriptionController()); // ADD THIS

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
  final Rx<PlaceModel?> _editingPlace = Rx<PlaceModel?>(
    null,
  ); // Store original place for editing

  final allTags = const [
    // General
    'Family Friendly',
    'Pet Friendly',
    'Budget Friendly',
    'Luxury',
    'Romantic',
    'Business',
    'Student Friendly',

    // Location Types
    'Outdoor',
    'Indoor',
    'Beachfront',
    'Mountain View',
    'City Center',
    'Suburban',
    'Rural',

    // Amenities
    'Free WiFi',
    'Parking Available',
    'Wheelchair Accessible',
    'Air Conditioned',
    'Heating',
    'Swimming Pool',
    'Gym',
    'Spa',

    // Activities
    'Live Music',
    'Sports Bar',
    'Gaming',
    'Karaoke',
    'Dance Floor',
    'Quiet Atmosphere',

    // Food & Drink
    'Vegetarian Options',
    'Vegan Options',
    'Gluten-Free Options',
    'Halal',
    'Alcohol Served',
    'Coffee Shop',
    'Fine Dining',
    'Fast Food',
    'Buffet',

    // Accommodation
    'Hotel',
    'Hostel',
    'Resort',
    'Vacation Rental',
    'Camping',

    // Entertainment
    'Cinema',
    'Theater',
    'Museum',
    'Art Gallery',
    'Shopping',
    'Amusement Park',

    // Services
    '24/7',
    'Delivery',
    'Takeaway',
    'Reservations',
    'Catering',
    'Event Space',

    // Special Features
    'Historic',
    'Modern',
    'Traditional',
    'Eco-Friendly',
    'LGBTQ+ Friendly',
    'Kid Friendly',
  ];

  @override
  void onInit() {
    super.onInit();
    // Initialize the real-time stream for featured places (used on Home screen)
    streamFeaturedPlaces();

    // Auto-Repair Data (Fix missing links/flags from previous bugs)
    // Run this briefly then can be removed
    Future.delayed(const Duration(seconds: 2), () {
      placeRepository.repairData();
    });
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

    // NOTE: This assumes 'placeRepository.streamPlacesForCategory(categoryId)'
    // is implemented in your repository to return a Stream<List<PlaceModel>>.
    _categoryPlacesSubscription = placeRepository
        .streamPlacesForCategory(categoryId: categoryId)
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
              // title: 'Stream Error',
              title: txt.streamError,
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
              // title: 'Stream Error',
              title: txt.streamError,
              message: e.toString(),
            );
            AppLoggerHelper.error(
              'Error listening to featured places stream: $e',
            );
            isLoading.value = false;
          },
        );
  }

  Future<List<PlaceModel>> fetchAllFeaturedPlaces() async {
    try {
      final places = await placeRepository.getAllFeaturedPlaces();
      featuredPlaces.assignAll(places);
      return places;
    } catch (e) {
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
      return [];
    }
  }

  /// Fetch Places By Query
  Future<List<PlaceModel>> fetchPlacesByQuery(Query? query) async {
    try {
      if (query == null) return [];

      final places = await placeRepository.fetchPlacesByQuery(query);
      featuredPlaces.assignAll(places);
      return places;
    } catch (e) {
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
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
            // AppLoaders.warningSnackBar(
            //   title: 'Image Limit Reached',
            //   message: 'You can only upload a maximum of $maxImages images.',
            // );

            AppLoaders.warningSnackBar(
              title: txt.imageLimitReached,
              message: txt.imageLimitMessage(maxImages),
            );

            break;
          }
        }
      }
    } catch (e) {
      // AppLoaders.errorSnackBar(
      //   title: 'Image Selection Failed',
      //   message: 'Could not select images: $e',
      // );
      AppLoaders.errorSnackBar(
        title: txt.imageSelectionFailed,
        message: txt.couldNotSelectImages(e.toString()),
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
        // 'Uploading ${selectedLocalImageFiles.length} photos for Place ID: $placeId...',
        txt.uploadingPhotosWithParams(selectedLocalImageFiles.length, placeId),
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
        // title: 'Upload Failed!',
        title: txt.uploadFailed,
        // message: 'Could not upload place images: ${e.toString()}',
        message: txt.couldNotUploadPlaceImages(e.toString()),
      );
      rethrow;
    }
  }

  void addCustomQuestion() {
    // Limit to 4 questions
    if (customQuestions.length >= 4) {
      AppLoaders.warningSnackBar(
        // title: 'Limit Reached',
        title: txt.limitReached,
        // message: 'You can only add up to 4 custom questions.',
        message: txt.youCanOnlyAddUpTo4Questions,
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
      /*
      // Check subscription first
      final canCreate = await subscriptionController.canCreatePlace();
      if (!canCreate) {
        subscriptionController.showSubscriptionRequired(Get.context!);
        return;
      }
      */

      if (AuthenticationRepository.instance.isGuestUser) {
        AppLoaders.warningSnackBar(
          // title: 'Authentication Required',
          title: txt.authenticationRequired,
          // message:
          //     'Please sign in or create an account to save your favorite places.',
          message: txt.pleaseSignInToSavePlaces,
        );
        Get.to(() => const SignupScreen());
        return;
      }

      // Start Loading & Form Validation
      AppFullScreenLoader.openLoadingDialog(
        // 'Creating new place...',
        txt.creatingNewPlace,
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

      if (selectedAddress.value == AddressModel.empty() ||
          selectedAddress.value.latitude == 0.0 ||
          selectedAddress.value.longitude == 0.0) {
        AppFullScreenLoader.stopLoading();
        AppLoaders.warningSnackBar(
          // title: 'Location Missing',
          title: txt.locationMissing,
          // message:
          //     'Please use the map picker to select a valid location with coordinates.',
          message: txt.pleaseUseMapPicker,
        );
        return;
      }

      // Additional Checks
      if (selectedLocalImageFiles.isEmpty) {
        AppFullScreenLoader.stopLoading();
        AppLoaders.warningSnackBar(
          // title: 'No Images',
          title: txt.noImages,
          // message: 'Please select at least one image.',
          message: txt.pleaseSelectAtLeastOneImage,
        );
        return;
      }

      if (selectedCategoryId.isEmpty) {
        AppFullScreenLoader.stopLoading();
        AppLoaders.warningSnackBar(
          // title: 'Category Missing',
          title: txt.categoryMissing,
          // message: 'Please select a valid category.',
          message: txt.pleaseSelectValidCategory,
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
        // images: imageUrls.length > 1 ? imageUrls.sublist(1) : null,
        images: imageUrls,

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
      await placeRepository.createPlaceCategory(
        PlaceCategoryModel(placeId: placeId, categoryId: newPlace.categoryId),
      );

      AppFullScreenLoader.stopLoading();

      // Update UI
      update();

      // Close screen FIRST (so we return to previous screen)
      Get.back();

      // Then show success message
      AppLoaders.successSnackBar(
        // title: 'Success!',
        title: txt.success,
        // message: 'Your new place "${newPlace.title}" has been created!',
        message: txt.yourNewPlaceHasBeenCreatedWithTitle(newPlace.title),
      );
    } catch (e) {
      AppFullScreenLoader.stopLoading();
      // AppLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.ohSnap, message: e.toString());
    }
  }

  /// Pick address directly from map
  Future<void> pickAddressFromMap() async {
    try {
      final AddressModel? pickedAddress =
          await PlacesMapScreen.openLocationPicker();

      if (pickedAddress != null) {
        selectedAddress.value = pickedAddress;

        // Auto-fill form fields based on the picked address
        if (locationController.text.isEmpty) {
          locationController.text = pickedAddress.toString();
        }
      }
    } catch (e) {
      AppLoaders.errorSnackBar(title: txt.error, message: e.toString());
    }
  }

  /// Helper to reset form and image selection state
  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    phoneController.clear();
    selectedAddress.value = AddressModel.empty();
    selectedLocalImageFiles.clear();
    existingImageUrls.clear();
    websiteUrlController.clear();
    selectedCategoryId.value = '';
    selectedTags.clear();
    isFeatured.value = true; // Default to true
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

  void removeExistingImage(int index) {
    if (index >= 0 && index < existingImageUrls.length) {
      existingImageUrls.removeAt(index);
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
    // Force a fresh fetch from the server (not from cache)
    await fetchAllFeaturedPlaces();
    // Then restart the stream to ensure it picks up the latest data
    streamFeaturedPlaces();
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

    // Capture original place for update merging
    _editingPlace.value = place;
    // Force isFeatured to true to satisfy "make full places isFeatured: true" requirement
    isFeatured.value = true;

    // Clear any previously selected local images
    selectedLocalImageFiles.clear();

    // Initialize custom questions
    customQuestions.clear();
    for (var controller in questionControllers) {
      controller.dispose();
    }
    questionControllers.clear();
    questionTypes.clear();
    questionRequired.clear();

    if (place.customQuestions != null) {
      for (var question in place.customQuestions!) {
        customQuestions.add(question);
        questionControllers.add(TextEditingController(text: question.question));
        questionTypes.add(question.type.obs);
        questionRequired.add(question.isRequired.obs);
      }
    }
  }

  /// Clear edit form data
  void clearEditForm() {
    editingPlaceId.value = '';
    existingImageUrls.clear();
    selectedLocalImageFiles.clear();
    resetForm();
  }

  /// Update existing place
  Future<void> updatePlace(String placeId) async {
    try {
      // Start Loading & Form Validation
      AppFullScreenLoader.openLoadingDialog(
        // 'Updating place...',
        txt.updatingPlace,
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
          // title: 'Location Missing',
          title: txt.locationMissing,
          // message: 'Please select a location for the place.',
          message: txt.pleaseSelectLocation, // Use the new getter
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
        customQuestions: customQuestions
            .toList(), // Ensure custom questions are saved
      );

      // Update place in Firestore
      await placeRepository.updatePlace(updatedPlace);
      // clearEditForm();
      update();
      Get.back();
      AppLoaders.successSnackBar(
        // title: 'Success!',
        title: txt.success,
        // message: 'Place "${updatedPlace.title}" has been updated!',
        message: txt.placeHasBeenUpdated,
        // message: txt.uploadingPhotosWithCount(place.images.length, placeId)
      );
    } catch (e) {
      // AppLoaders.errorSnackBar(title: 'Update Failed', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.updateFailed, message: e.toString());
    } finally {
      AppFullScreenLoader.stopLoading();
    }
  }

  /// Delete place with confirmation
  Future<void> deletePlaceWithConfirmation(PlaceModel place) async {
    // ... existing implementation ...
    Get.defaultDialog(
      // title: 'Delete Place?',
      title: txt.deletePlace, // Use localized title
      middleText: txt.deletePlaceMessage(
        place.title,
      ), // Use localized message with parameter
      // middleText:
      //     'Are you sure you want to delete "${place.title}"? This action cannot be undone.',
      // middleText:
      //     'Are you sure you want to delete "${place.title}"? This action cannot be undone.',
      // textConfirm: 'Delete',
      textConfirm: txt.delete,
      // textCancel: 'Cancel',
      textCancel: txt.cancel,
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
    try {
      AppFullScreenLoader.openLoadingDialog(
        // 'Deleting place...',
        txt.deletingPlace,
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
        // title: 'Success!',
        title: txt.success,
        // message: 'Place "${place.title}" has been deleted',
        message: txt.placeHasBeenDeleted,
      );
      update();
    } catch (e) {
      // AppLoaders.errorSnackBar(title: 'Delete Failed', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.deleteFailed, message: e.toString());
    } finally {
      AppFullScreenLoader.stopLoading();
    }
  }
}
