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

  static ReviewController get instance => Get.find();

  final _authRepo = AuthenticationRepository.instance;
  final _reviewRepo = Get.put(ReviewRepository());
  final _placeRepo = PlaceRepository.instance;

  // Non-reactive controller for input field
  final reviewTextController = TextEditingController();
  final replyTextController = TextEditingController();

  // Reactive states for UI updates
  final rating = 0.0.obs;
  final isLoading = false.obs;
  final existingReviewId = ''.obs;
  final isEditing = false.obs; // Start as false, will be set properly

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
        
        // FIX: Set isEditing based on whether we have an existing review
        isEditing.value = false; // Start in read-only mode when review exists

        // Update non-reactive controller text
        reviewTextController.text = existing.reviewText;
      } else {
        // Reset states for a new review
        existingReviewId.value = '';
        isEditing.value = true; // Enable editing for new reviews
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
    update(); // Important: notify listeners
  }

  void setRating(double newRating) {
    // FIX: Allow rating changes when editing OR when creating new review
    if (isEditing.value || existingReviewId.value.isEmpty) {
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
        await _reviewRepo.addReview(reviewToSubmit);

        // NEW: Update rating distribution for NEW reviews only
        await _reviewRepo.updateRatingDistribution(
          placeId,
          rating.value.round(), // Convert double to int (5.0 -> 5)
        );
      }

      // 5. Update the Place's overall rating statistics
      await _placeRepo.updatePlaceRatingStatistics(placeId, rating.value);

      // 6. Success feedback
      AppLoaders.successSnackBar(
        title: isUpdating ? 'Update Success!' : 'Submission Success!',
        message: isUpdating
            ? 'Your review has been successfully updated.'
            : 'Your review has been submitted.',
      );

      // 7. Transition back to read-only view after successful submission/update
      if (isUpdating) {
        isEditing.value = false; // Go back to read-only mode after update
      } else {
        // For new reviews, fetch the newly created review to get its ID
        await fetchExistingReview();
      }

      update(); // Refresh UI

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

  Future<void> deleteReview() async {
    try {
      if (existingReviewId.value.isEmpty) return;

      isLoading.value = true;

      // Show loading dialog
      AppFullScreenLoader.openLoadingDialog(
        'Deleting Review...',
        AppImages.docerAnimation,
      );

      await _reviewRepo.deleteReview(existingReviewId.value);

      // Reset state
      existingReviewId.value = '';
      rating.value = 0.0;
      reviewTextController.clear();
      isEditing.value = true; // Enable editing after deletion

      AppFullScreenLoader.stopLoading();
      AppLoaders.successSnackBar(
        title: 'Success!',
        message: 'Review deleted successfully.',
      );

      update(); // Refresh the UI
    } catch (e) {
      AppFullScreenLoader.stopLoading();
      AppLoaders.errorSnackBar(title: 'Delete Failed', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to check if text field should be enabled
  bool get isTextFieldEnabled {
    return isEditing.value || existingReviewId.value.isEmpty;
  }

  // Helper method to check if rating should be enabled
  bool get isRatingEnabled {
    return isEditing.value || existingReviewId.value.isEmpty;
  }
}

//----------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:reviews_app/data/repositories/review/review_repository.dart'
//     show ReviewRepository;
// import 'package:reviews_app/utils/constants/image_strings.dart';

// import '../../../data/repositories/authentication/authentication_repository.dart';
// import '../../../data/repositories/place/place_repository.dart';
// import '../../../utils/helpers/network_manager.dart';
// import '../../../utils/popups/full_screen_loader.dart';
// import '../../../utils/popups/loaders.dart';
// import '../models/reply_model.dart';
// import '../models/review_model.dart';

// class ReviewController extends GetxController {
//   final String placeId;
//   ReviewController({required this.placeId});

//   static ReviewController get instance => Get.find();

//   final _authRepo = AuthenticationRepository.instance;
//   final _reviewRepo = Get.put(ReviewRepository());
//   final _placeRepo = PlaceRepository.instance;

//   // Non-reactive controller for input field
//   final reviewTextController = TextEditingController();
//   final replyTextController = TextEditingController();

//   // Reactive states for UI updates
//   final rating = 0.0.obs;
//   final isLoading = false.obs;
//   final existingReviewId = ''.obs;
//   final isEditing = true.obs;

//   // reply/edit targets
//   final replyingTo = Rxn<ReplyModel>();
//   final editingReply = Rxn<ReplyModel>();

//   final formKey = GlobalKey<FormState>();
//   String get currentUserId => _authRepo.getUserID;

//   @override
//   void onInit() {
//     super.onInit();
//     // Fetch and initialize state
//     fetchExistingReview();
//   }

//   Future<void> fetchExistingReview() async {
//     final userId = _authRepo.getUserID;
//     if (userId.isEmpty) return;
//     try {
//       final existing = await _reviewRepo.getExistingReview(userId, placeId);
//       if (existing != null) {
//         // Update reactive states
//         existingReviewId.value = existing.id;
//         rating.value = existing.rating;
//         isEditing.value = false; // Start in read-only mode

//         // Update non-reactive controller text
//         reviewTextController.text = existing.reviewText;
//       } else {
//         // Reset states for a new review
//         existingReviewId.value = '';
//         isEditing.value = true;
//         rating.value = 0.0;
//         reviewTextController.clear();
//       }

//       // CRUCIAL FIX: Call update() here to refresh the entire GetBuilder/GetX tree,
//       // ensuring the TextFormField picks up the initial/updated text.
//       update();
//     } catch (e) {
//       print('Error fetching existing review: $e');
//     }
//   }

//   void enableEditing() {
//     isEditing.value = true;
//   }

//   void setRating(double newRating) {
//     if (isEditing.value) {
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
//         await _reviewRepo.addReview(reviewToSubmit);

//         // NEW: Update rating distribution for NEW reviews only
//         await _reviewRepo.updateRatingDistribution(
//           placeId,
//           rating.value.round(), // Convert double to int (5.0 -> 5)
//         );
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

//       await fetchExistingReview();
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

//   // In ReviewController
//   Future<void> deleteReview() async {
//     try {
//       if (existingReviewId.value.isEmpty) return;

//       isLoading.value = true;

//       // Show loading dialog
//       AppFullScreenLoader.openLoadingDialog(
//         'Deleting Review...',
//         AppImages.docerAnimation,
//       );

//       await _reviewRepo.deleteReview(existingReviewId.value);

//       // Reset state
//       existingReviewId.value = '';
//       rating.value = 0.0;
//       reviewTextController.clear();
//       isEditing.value = true;

//       AppFullScreenLoader.stopLoading();
//       AppLoaders.successSnackBar(
//         title: 'Success!',
//         message: 'Review deleted successfully.',
//       );

//       update(); // Refresh the UI
//     } catch (e) {
//       AppFullScreenLoader.stopLoading();
//       AppLoaders.errorSnackBar(title: 'Delete Failed', message: e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
