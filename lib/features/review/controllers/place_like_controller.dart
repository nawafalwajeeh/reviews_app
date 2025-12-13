import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/popups/loaders.dart';
import '../../personalization/controllers/user_controller.dart';
import 'notification_controller.dart';
import 'place_controller.dart';

class PlaceLikeController extends GetxController {
  final PlaceController placeController = PlaceController.instance;

  final String userId = AuthenticationRepository.instance.getUserID;
  final String placeId;

  final notificationController = NotificationController.instance;
  final userController = UserController.instance;

  // Observables for UI state
  final Rx<bool> isLiked = false.obs;
  final Rx<int> likeCount = 0.obs;

  // Concurrency guard to prevent multiple taps during DB operation
  final Rx<bool> isToggling = false.obs;

  // Stream subscriptions
  StreamSubscription<bool>? _likeStatusSubscription;
  StreamSubscription<int>? _likeCountSubscription;

  PlaceLikeController({required this.placeId}) {
    _startListening();
  }

  @override
  void onClose() {
    _likeStatusSubscription?.cancel();
    _likeCountSubscription?.cancel();
    super.onClose();
  }

  void _startListening() {
    if (userId.isEmpty) return;

    // 1. Listen for current user's like status
    _likeStatusSubscription = placeController.placeRepository
        .getPlaceLikeStatusStream(placeId, userId)
        .listen(
          (status) {
            isLiked.value = status;
          },
          onError: (e) {
            debugPrint('Like Status Stream Error: $e');
          },
        );

    // 2. Listen for total like count
    _likeCountSubscription = placeController.placeRepository
        .getPlaceLikeCountStream(placeId)
        .listen(
          (count) {
            likeCount.value = count;
          },
          onError: (e) {
            debugPrint('Like Count Stream Error: $e');
          },
        );
  }

  /// Toggles the like status in the database, guarded against concurrent calls.
  Future<void> toggleLike() async {
    // Prevent re-entry if a transaction is already running
    if (isToggling.value) return;

    if (userId.isEmpty) {
      AppLoaders.warningSnackBar(
        // title: 'Sign In Required',
        title: txt.signInRequired,
        // message: 'Please sign in to like this place.',
        message: txt.signInRequiredMessage,
      );
      return;
    }

    // Set flag to true to block further taps
    isToggling.value = true;

    // Optimistic UI update setup
    final newStatus = !isLiked.value;
    final oldStatus = isLiked.value;
    final int oldLikeCount = likeCount.value;

    // Immediately update UI to feel responsive
    isLiked.value = newStatus;
    if (newStatus) {
      likeCount.value++;
    } else if (likeCount.value > 0) {
      likeCount.value--;
    }

    try {
      // Call repository to update database (The slow part)
      await placeController.placeRepository.togglePlaceLikeStatus(
        placeId,
        userId,
        newStatus,
      );

      // ✅ Use helper class
      if (newStatus) {
        sendPlaceLikedNotification(placeId: placeId, likerId: userId);
      }
    } catch (e) {
      // Revert UI change and show error if DB update fails
      isLiked.value = oldStatus;
      likeCount.value = oldLikeCount;

      AppLoaders.errorSnackBar(
        // title: 'Failed to Toggle Like',
        title: txt.failedToToggleLike,
        message: e.toString(),
      );

      // Re-throw the error for external handling if necessary, but importantly,
      // the finally block will still execute.
      // rethrow;
    } finally {
      // Reset flag to allow future taps, even if an error occurred.
      isToggling.value = false;
    }
  }

  Future<void> sendPlaceLikedNotification({
    required String placeId,
    required String likerId,
  }) async {
    try {
      // Get place details
      final place = await placeController.placeRepository.getPlaceById(placeId);
      if (place == null) return;

      // Don't notify self
      if (place.userId == likerId) return;

      // Get liker name
      final likerName = userController.user.value.fullName;

      // Send notification
      await notificationController.sendNotification(
        toUserId: place.userId,
        type: 'place_liked',
        title: 'Your Place Got Liked',
        body: '$likerName liked your place "${place.title}"',
        targetId: placeId,
        targetType: 'place',
        extraData: {
          'placeId': placeId,
          'placeName': place.title,
          'likerId': likerId,
          'likerName': likerName,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('✅ Place liked notification sent successfully');
    } catch (e) {
      debugPrint('❌ Error sending place liked notification: $e');
    }
  }
}
