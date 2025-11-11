import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/data/repositories/review/review_repository.dart'
    show ReviewRepository;
import 'package:reviews_app/utils/constants/image_strings.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/place/place_repository.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../models/reply_model.dart';
import '../models/review_model.dart';

class ReviewController extends GetxController {
  final String placeId;
  ReviewController({required this.placeId});

   final _authRepo = AuthenticationRepository.instance;
   final _reviewRepo = Get.put(ReviewRepository());
   final  _placeRepo = PlaceRepository.instance;

  // Non-reactive controller for input field
  final reviewTextController = TextEditingController();
  final replyTextController = TextEditingController();

  // Reactive states for UI updates
  final rating = 0.0.obs;
  final isLoading = false.obs;
  final existingReviewId = ''.obs;
  final isEditing = true.obs;

  
  // reply/edit targets
  final replyingTo = Rxn<ReplyModel>();
  final editingReply = Rxn<ReplyModel>();


  final formKey = GlobalKey<FormState>();
  String get currentUserId => _authRepo.getUserID;

  @override
  void onInit() {
    super.onInit();
    // Fetch and initialize state
    fetchExistingReview();
  }

  Future<void> fetchExistingReview() async {
    final userId = _authRepo.getUserID;
    if (userId.isEmpty) return;
    try {
      final existing = await _reviewRepo.getExistingReview(userId, placeId);
      if (existing != null) {
        // Update reactive states
        existingReviewId.value = existing.id;
        rating.value = existing.rating;
        isEditing.value = false; // Start in read-only mode

        // Update non-reactive controller text
        reviewTextController.text = existing.reviewText;
      } else {
        // Reset states for a new review
        existingReviewId.value = '';
        isEditing.value = true;
        rating.value = 0.0;
        reviewTextController.clear();
      }

      // CRUCIAL FIX: Call update() here to refresh the entire GetBuilder/GetX tree,
      // ensuring the TextFormField picks up the initial/updated text.
      update();
    } catch (e) {
      print('Error fetching existing review: $e');
    }
  }

  void enableEditing() {
    isEditing.value = true;
  }

  void setRating(double newRating) {
    if (isEditing.value) {
      rating.value = newRating;
    }
  }

  Future<void> submitReview() async {
    try {
      // Start Loading
      isLoading.value = true;
      AppFullScreenLoader.openLoadingDialog(
        'Submitting Review...',
        AppImages.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await AppNetworkManager.instance.isConnected();
      if (!isConnected) {
        AppFullScreenLoader.stopLoading();
        return;
      }

      // 1. Validation Check
      if (!formKey.currentState!.validate()) return;
      if (rating.value == 0.0) {
        AppLoaders.warningSnackBar(
          title: 'Rating Required',
          message: 'Please select a star rating for your experience.',
        );
        AppFullScreenLoader.stopLoading();
        return;
      }

      // 2. Get current user data
      final userId = _authRepo.getUserID;

      if (userId.isEmpty) {
        AppFullScreenLoader.stopLoading();
        AppLoaders.errorSnackBar(
          title: 'Authentication Error',
          message: 'You must be logged in to post a review.',
        );
        AppFullScreenLoader.stopLoading();
        return;
      }

      final userName = 'Current User (ID: ${userId.substring(0, 8)}...)';
      final userAvatar = 'https://placehold.co/40x40/007AFF/FFFFFF?text=U';

      // 3. Create ReviewModel
      final reviewToSubmit = ReviewModel(
        id: existingReviewId.value,
        placeId: placeId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        rating: rating.value,
        reviewText: reviewTextController.text.trim(),
        timestamp: DateTime.now(),
      );

      // 4. Submit or Update
      bool isUpdating = existingReviewId.value.isNotEmpty;

      if (isUpdating) {
        await _reviewRepo.updateReview(reviewToSubmit);
      } else {
        await _reviewRepo.addReview(reviewToSubmit);
        // After adding, re-fetch to capture the new mock ID
        // await fetchExistingReview();
      }

      // 5. Update the Place's overall rating statistics
      await _placeRepo.updatePlaceRatingStatistics(placeId, rating.value);

      // 6. Success feedback
      // AppLoaders.stopLoading();
      AppLoaders.successSnackBar(
        title: isUpdating ? 'Update Success!' : 'Submission Success!',
        message: isUpdating
            ? 'Your review has been successfully updated.'
            : 'Your review has been submitted.',
      );

      // 7. Transition back to read-only view after successful submission/update
      isEditing.value = false;

      AppLoaders.successSnackBar(
        title: 'Success!',
        message: 'Your review has been submitted and the place rating updated.',
      );

      await fetchExistingReview();
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: 'Submission Failed',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
      AppFullScreenLoader.stopLoading();
    }
  }
}

//----------------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:reviews_app/utils/popups/full_screen_loader.dart';
// import '../../../data/repositories/authentication/authentication_repository.dart';
// import '../../../data/repositories/place/place_repository.dart';
// import '../../../data/repositories/review/review_repository.dart';
// import '../../../utils/constants/image_strings.dart';
// import '../../../utils/helpers/network_manager.dart' show AppNetworkManager;
// import '../../../utils/popups/loaders.dart';
// import '../models/review_model.dart';

// class ReviewController extends GetxController {
//   final String placeId;

//   ReviewController({required this.placeId});

//   // Dependencies
//   late final AuthenticationRepository _authRepo;
//   late final ReviewRepository _reviewRepo;
//   late final PlaceRepository _placeRepo;

//   // Reactive State
//   final reviewTextController = TextEditingController();
//   final rating = 0.0.obs;
//   final isLoading = false.obs;
//   final formKey = GlobalKey<FormState>();

//   // State to hold the ID of an existing review if found (Resolves 'existsReviewId not found')
//   final existingReviewId = ''.obs;

//   // State to control whether the user is actively editing the form (Resolves 'isEditing not found')
//   final isEditing = true.obs;

//   @override
//   void onInit() {
//     // Register mock dependencies if they aren't already registered
//     if (!Get.isRegistered<AuthenticationRepository>()) {
//       Get.put(AuthenticationRepository());
//     }
//     if (!Get.isRegistered<ReviewRepository>()) Get.put(ReviewRepository());
//     if (!Get.isRegistered<PlaceRepository>()) Get.put(PlaceRepository());

//     _authRepo = AuthenticationRepository.instance;
//     _reviewRepo = ReviewRepository.instance;
//     _placeRepo = PlaceRepository.instance;

//     super.onInit();
//     // Load existing review and set the initial editing state
//     fetchExistingReview();
//   }

//   /// Fetches the user's previously submitted review for this place (if one exists)
//   Future<void> fetchExistingReview() async {
//     final userId = _authRepo.getUserID;
//     if (userId.isEmpty) return;

//     try {
//       final existing = await _reviewRepo.getExistingReview(userId, placeId);

//       if (existing != null) {
//         // If an existing review is found, set the state to READ-ONLY (disabled form)
//         existingReviewId.value = existing.id;
//         rating.value = existing.rating;
//         reviewTextController.text = existing.reviewText;
//         isEditing.value = false; // Disable editing mode initially
//       } else {
//         // If no existing review, keep editing mode enabled for writing a new one
//         isEditing.value = true;
//         rating.value = 0.0;
//         reviewTextController.clear();
//       }
//     } catch (e) {
//       print('Error fetching existing review: $e');
//     }
//   }

//   /// Toggles the editing mode (called by the 'Edit' button). (Resolves 'enableEditing not found')
//   void enableEditing() {
//     isEditing.value = true;
//   }

//   /// Updates the reactive rating value when the user interacts with the stars.
//   void setRating(double newRating) {
//     if (isEditing.value) {
//       // Only allow rating change if in editing mode
//       rating.value = newRating;
//     }
//   }

//   Future<void> submitReview() async {
//     try {
//       // Start Loading
//       isLoading.value = true;
//       AppFullScreenLoader.openLoadingDialog(
//         'Submitting Review...',
//         AppImages.docerAnimation,
//       );

//       // Check Internet Connectivity
//       final isConnected = await AppNetworkManager.instance.isConnected();
//       if (!isConnected) {
//         AppFullScreenLoader.stopLoading();
//         return;
//       }

//       // 1. Validation Check
//       if (!formKey.currentState!.validate()) return;
//       if (rating.value == 0.0) {
//         AppLoaders.warningSnackBar(
//           title: 'Rating Required',
//           message: 'Please select a star rating for your experience.',
//         );
//         AppFullScreenLoader.stopLoading();
//         return;
//       }

//       // 2. Get current user data
//       final userId = _authRepo.getUserID;

//       if (userId.isEmpty) {
//         AppFullScreenLoader.stopLoading();
//         AppLoaders.errorSnackBar(
//           title: 'Authentication Error',
//           message: 'You must be logged in to post a review.',
//         );
//         AppFullScreenLoader.stopLoading();
//         return;
//       }

//       final userName = 'Current User (ID: ${userId.substring(0, 8)}...)';
//       final userAvatar = 'https://placehold.co/40x40/007AFF/FFFFFF?text=U';

//       // 3. Create ReviewModel
//       final reviewToSubmit = ReviewModel(
//         id: existingReviewId.value,
//         placeId: placeId,
//         userId: userId,
//         userName: userName,
//         userAvatar: userAvatar,
//         rating: rating.value,
//         reviewText: reviewTextController.text.trim(),
//         timestamp: DateTime.now(),
//       );

//       // 4. Submit or Update
//       bool isUpdating = existingReviewId.value.isNotEmpty;

//       if (isUpdating) {
//         await _reviewRepo.updateReview(reviewToSubmit);
//       } else {
//         await _reviewRepo.addReview(reviewToSubmit);
//         // After adding, re-fetch to capture the new mock ID
//         await fetchExistingReview();
//       }

//       // 5. Update the Place's overall rating statistics
//       await _placeRepo.updatePlaceRatingStatistics(placeId, rating.value);

//       // 6. Success feedback
//       // AppLoaders.stopLoading();
//       AppLoaders.successSnackBar(
//         title: isUpdating ? 'Update Success!' : 'Submission Success!',
//         message: isUpdating
//             ? 'Your review has been successfully updated.'
//             : 'Your review has been submitted.',
//       );

//       // 7. Transition back to read-only view after successful submission/update
//       isEditing.value = false;

//       AppLoaders.successSnackBar(
//         title: 'Success!',
//         message: 'Your review has been submitted and the place rating updated.',
//       );

//       // // Reset UI state
//       // reviewTextController.clear();
//       // rating.value = 0.0;
//       // formKey.currentState?.reset();
//     } catch (e) {
//       AppLoaders.errorSnackBar(
//         title: 'Submission Failed',
//         message: e.toString(),
//       );
//     } finally {
//       isLoading.value = false;
//       AppFullScreenLoader.stopLoading();
//     }
//   }
// }

//---------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:reviews_app/data/repositories/authentication/authentication_repository.dart';
// import 'package:reviews_app/data/repositories/place/place_repository.dart';
// import 'package:reviews_app/features/review/models/review_model.dart';
// import 'package:reviews_app/utils/constants/image_strings.dart';
// import 'package:reviews_app/utils/popups/full_screen_loader.dart';

// import '../../../data/repositories/review/review_repository.dart';
// import '../../../utils/helpers/network_manager.dart';
// import '../../../utils/popups/loaders.dart'; // Assuming AppLoader utility is here

// class ReviewController extends GetxController {
//   final String placeId;

//   // Constructor to inject the required placeId
//   ReviewController({required this.placeId});

//   final reviewRepository = Get.put(ReviewRepository());
//   final _authRepo = AuthenticationRepository.instance;
//   final _placeRepo = PlaceRepository.instance;

//   // Reactive State
//   final reviewTextController = TextEditingController();
//   final rating = 0.0.obs;
//   final isLoading = false.obs;
//   final formKey = GlobalKey<FormState>();

//   /// Updates the reactive rating value when the user interacts with the stars.
//   void setRating(double newRating) {
//     rating.value = newRating;
//   }

//   /// Handles the submission of a new review, including data validation and updating place statistics.
//   Future<void> submitReview() async {
//     try {
//       // Start Loading
//       isLoading.value = true;
//       AppFullScreenLoader.openLoadingDialog(
//         'Submitting Review...',
//         AppImages.docerAnimation,
//       );

//       // Check Internet Connectivity
//       final isConnected = await AppNetworkManager.instance.isConnected();
//       if (!isConnected) {
//         AppFullScreenLoader.stopLoading();
//         return;
//       }

//       // 1. Validation Check
//       if (!formKey.currentState!.validate()) return;
//       if (rating.value == 0.0) {
//         AppLoaders.warningSnackBar(
//           title: 'Rating Required',
//           message: 'Please select a star rating for your experience.',
//         );
//         AppFullScreenLoader.stopLoading();
//         return;
//       }

//       // 2. Get current user data
//       final userId = _authRepo.getUserID;

//       if (userId.isEmpty) {
//         AppFullScreenLoader.stopLoading();
//         AppLoaders.errorSnackBar(
//           title: 'Authentication Error',
//           message: 'You must be logged in to post a review.',
//         );
//         AppFullScreenLoader.stopLoading();
//         return;
//       }

//       final userName = 'Current User (ID: ${userId.substring(0, 8)}...)';
//       final userAvatar = 'https://placehold.co/40x40/007AFF/FFFFFF?text=U';

//       // 3. Create ReviewModel
//       final newReview = ReviewModel(
//         id: '', // Firestore will generate this
//         placeId: placeId,
//         userId: userId,
//         userName: userName,
//         userAvatar: userAvatar,
//         rating: rating.value,
//         reviewText: reviewTextController.text.trim(),
//         timestamp: DateTime.now(),
//       );

//       // Submit review to the Review Service (adds to 'Reviews' collection)
//       await reviewRepository.addReview(newReview);

//       await _placeRepo.updatePlaceRatingStatistics(placeId, rating.value);

//       // Success feedback and reset

//       AppLoaders.successSnackBar(
//         title: 'Success!',
//         message: 'Your review has been submitted and the place rating updated.',
//       );

//       // Reset UI state
//       reviewTextController.clear();
//       rating.value = 0.0;
//       formKey.currentState?.reset();
//     } catch (e) {
//       AppLoaders.errorSnackBar(
//         title: 'Submission Failed',
//         message: e.toString(),
//       );
//     } finally {
//       isLoading.value = false;
//       AppFullScreenLoader.stopLoading();
//     }
//   }
// }
