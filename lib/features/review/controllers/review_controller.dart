import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/data/repositories/review/review_repository.dart'
    show ReviewRepository;
import 'package:reviews_app/features/personalization/controllers/user_controller.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/utils/constants/image_strings.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/place/place_repository.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../authentication/screens/signup/signup_screen.dart';
import '../models/question_answer_model.dart';
import '../models/reply_model.dart';
import '../models/review_model.dart';

class ReviewController extends GetxController {
  final String placeId;
  ReviewController({required this.placeId});

  static ReviewController get instance => Get.find();

  final _authRepo = AuthenticationRepository.instance;
  final reviewRepo = Get.put(ReviewRepository());
  final _placeRepo = PlaceRepository.instance;

  // Non-reactive controller for input field
  final reviewTextController = TextEditingController();
  final replyTextController = TextEditingController();

  final RxMap<String, QuestionAnswer> questionAnswers =
      <String, QuestionAnswer>{}.obs;

  // Reactive states for UI updates
  final rating = 0.0.obs;
  final originalRating =
      0.0.obs; // NEW: Stores the rating before editing starts
  final isLoading = false.obs;
  final existingReviewId = ''.obs;
  final isEditing = false.obs; // Start as false, will be set properly

  // reply/edit targets
  final replyingTo = Rxn<ReplyModel>();
  final editingReply = Rxn<ReplyModel>();

  final formKey = GlobalKey<FormState>();
  String get currentUserId => _authRepo.getUserID;

  // REACTIVE VARIABLES FOR RATING UPDATES
  final currentPlaceRating = 0.0.obs;
  final currentPlaceRatingDistribution = <String, int>{}.obs;
  final currentPlaceReviewsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch and initialize state
    fetchExistingReview();
    _initializeRatingData();
  }

  void setQuestionAnswer(
    String questionId,
    String question,
    QuestionType type,
    dynamic answer,
  ) {
    questionAnswers[questionId] = QuestionAnswer(
      questionId: questionId,
      question: question,
      type: type,
      answer: answer,
    );
  }

  dynamic getQuestionAnswer(String questionId) {
    return questionAnswers[questionId]?.answer;
  }

  Future<void> fetchExistingReview() async {
    final userId = _authRepo.getUserID;
    debugPrint('UserId: $userId');
    if (userId.isEmpty) return;
    try {
      final existing = await reviewRepo.getExistingReview(userId, placeId);
      debugPrint('reviewUserId: ${existing?.userId}');
      if (existing != null) {
        // Update reactive states
        existingReviewId.value = existing.id;
        rating.value = existing.rating;
        originalRating.value =
            existing.rating; // CRITICAL: Store the original rating
        isEditing.value = false; // Start in read-only mode when review exists
        // Update non-reactive controller text
        reviewTextController.text = existing.reviewText;
        // Load existing question answers
        questionAnswers.clear();
        for (final qa in existing.questionAnswers) {
          questionAnswers[qa.questionId] = qa;
        }
      } else {
        // Reset states for a new review
        existingReviewId.value = '';
        isEditing.value = true; // Enable editing for new reviews
        rating.value = 0.0;
        originalRating.value = 0.0;
        reviewTextController.clear();
        questionAnswers.clear();
      }

      // CRUCIAL FIX: Call update() here to refresh the entire GetBuilder/GetX tree,
      // ensuring the TextFormField picks up the initial/updated text.
      update();
    } catch (e) {
      AppLoaders.warningSnackBar(
        // title: 'Oh Snap!',
        title: txt.ohSnap,
        // message: 'Error fetching existing review: $e',
        message: txt.errorLoadingReviews,
      );
    }
  }

  void enableEditing() {
    isEditing.value = true;
    update(); // Important: notify listeners
  }

  void setRating(double newRating) {
    // Allow rating changes when editing OR when creating new review
    if (isEditing.value || existingReviewId.value.isEmpty) {
      rating.value = newRating;
    }
  }

  Future<void> submitReview() async {
    final userId = _authRepo.getUserID;
    try {
      if (AuthenticationRepository.instance.isGuestUser) {
        AppLoaders.warningSnackBar(
          // title: 'Authentication Required',
          title: txt.authenticationRequired,
          // message: 'Please sign in or create an account to add your review.',
          message: txt.pleaseSignInToAddReview,
        );

        Get.to(() => const SignupScreen());

        return;
      }

      // Start Loading
      isLoading.value = true;
      AppFullScreenLoader.openLoadingDialog(
        // 'Submitting Review...',
        txt.submittingReview,
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
          // title: 'Rating Required',
          title: txt.ratingRequired,
          // message: 'Please select a star rating for your experience.',
          message: txt.pleaseSelectStarRating,
        );
        AppFullScreenLoader.stopLoading();
        return;
      }

      final newRating = rating.value;
      final oldRating = originalRating.value;

      final userName = UserController.instance.user.value.fullName;
      final userAvatar = UserController.instance.user.value.profilePicture;

      // 3. Create ReviewModel
      final reviewToSubmit = ReviewModel(
        id: existingReviewId.value,
        placeId: placeId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        rating: newRating,
        reviewText: reviewTextController.text.trim(),
        timestamp: DateTime.now(),
        questionAnswers: questionAnswers.values.toList(),
      );

      // 4. Submit or Update
      bool isUpdating = existingReviewId.value.isNotEmpty;

      if (isUpdating) {
        // A. Update the review document
        await reviewRepo.updateReview(reviewToSubmit);

        // B. Update the Place's statistics if the rating has changed
        if (newRating.round() != oldRating.round()) {
          // : We need a dedicated PlaceRepository method for changing ratings
          await _placeRepo.updateRatingChange(
            placeId: placeId,
            oldRating: oldRating.round(),
            newRating: newRating.round(),
          );
        }
      } else {
        // A. Add the review document (Fix: removed duplicate call)
        await reviewRepo.addReview(reviewToSubmit);

        // B. Update the Place's statistics for a NEW review
        // This method must now perform: ReviewCount + 1 AND RatingDistribution[newRating] + 1
        await _placeRepo.updatePlaceRatingStatistics(placeId, newRating);
      }

      // 5. Success feedback
      AppLoaders.successSnackBar(
        // title: isUpdating ? 'Update Success!' : 'Submission Success!',
        title: isUpdating ? txt.updateSuccess : txt.submissionSuccess,
        message: isUpdating
            // ? 'Your review has been successfully updated.'
            // : 'Your review has been submitted.',
            ? txt.reviewUpdatedSuccess
            : txt.reviewSubmittedSuccess,
      );
      await _refreshRatingData();

      // 6. Transition back to read-only view after successful submission/update
      await fetchExistingReview(); // Refetch to reset state, update ID (for new review), and update originalRating

      update(); // Refresh UI
    } catch (e) {
      AppLoaders.errorSnackBar(
        // title: 'Submission Failed',
        title: txt.submissionFailed,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
      AppFullScreenLoader.stopLoading();
    }
  }

  Future<void> _initializeRatingData() async {
    try {
      final place = await PlaceController.instance.placeRepository.getPlaceById(
        placeId,
      );
      if (place != null) {
        currentPlaceRating.value = place.averageRating;
        currentPlaceRatingDistribution.value = place.ratingDistribution;
        currentPlaceReviewsCount.value = place.reviewsCount;
      }
    } catch (e) {
      print('Error initializing rating data: $e');
    }
  }

  Future<void> _refreshRatingData() async {
    try {
      final place = await PlaceController.instance.placeRepository.getPlaceById(
        placeId,
      );
      if (place != null) {
        currentPlaceRating.value = place.averageRating;
        currentPlaceRatingDistribution.value = place.ratingDistribution;
        currentPlaceReviewsCount.value = place.reviewsCount;

        // This will update the GetBuilder
        update();
      }
    } catch (e) {
      print('Error refreshing rating data: $e');
    }
  }

  // NEW: Submit review with questions
  Future<void> submitReviewWithQuestions() async {
    try {
      // Validate mandatory rating
      if (rating.value == 0.0) {
        AppLoaders.warningSnackBar(
          // title: 'Rating Required',
          title: txt.ratingRequired,
          // message: 'Please select a star rating for your experience.',
          message: txt.pleaseSelectStarRating,
        );
        return;
      }

      // Validate mandatory review text
      // if (reviewTextController.text.trim().isEmpty) {
      //   AppLoaders.warningSnackBar(
      //     title: 'Review Required',
      //     message: 'Please write your review text.',
      //   );
      //   return;
      // }

      // Validate required custom questions
      final place = await PlaceController.instance.placeRepository.getPlaceById(
        placeId,
      );
      if (place != null && place.customQuestions != null) {
        for (final question in place.customQuestions!) {
          if (question.isRequired &&
              !questionAnswers.containsKey(question.id)) {
            AppLoaders.warningSnackBar(
              // title: 'Answer Required',
              title: txt.answerRequired,
              // message:
              //     'Please answer the required question: ${question.question}',
              message: txt.pleaseAnswerRequiredQuestion(question.question),
            );
            return;
          }
        }
      }

      // Proceed with submission
      await submitReview();
    } catch (e) {
      AppLoaders.errorSnackBar(
        // title: 'Submission Failed',
        title: txt.submissionFailed,
        message: e.toString(),
      );
    }
  }

  Future<void> deleteReview() async {
    try {
      if (existingReviewId.value.isEmpty) return;

      isLoading.value = true;

      // Show loading dialog
      AppFullScreenLoader.openLoadingDialog(
        // 'Deleting Review...',
        txt.deletingReview,
        AppImages.docerAnimation,
      );

      // Before deleting the review, we must decrement the distribution count
      // in the Place document.
      await _placeRepo.removeReviewRating(placeId, rating.value.round());

      await reviewRepo.deleteReview(existingReviewId.value);
      // ADD THIS LINE: Refresh rating data after deletion
      await _refreshRatingData();
      // Reset state
      existingReviewId.value = '';
      rating.value = 0.0;
      originalRating.value = 0.0;
      reviewTextController.clear();
      isEditing.value = true; // Enable editing after deletion

      AppFullScreenLoader.stopLoading();
      AppLoaders.successSnackBar(
        // title: 'Success!',
        title: txt.success,
        // message: 'Review deleted successfully.',
        message: txt.reviewDeletedSuccess,
      );

      update(); // Refresh the UI
    } catch (e) {
      AppFullScreenLoader.stopLoading();
      // AppLoaders.errorSnackBar(title: 'Delete Failed', message: e.toString());
      AppLoaders.errorSnackBar(title: txt.deleteFailed, message: e.toString());
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
