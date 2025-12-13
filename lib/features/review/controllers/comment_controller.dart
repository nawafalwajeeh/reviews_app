// controllers/comment_controller.dart
import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/notification_controller.dart';
import '../../../data/repositories/comment/comment_repository.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/popups/loaders.dart';
import '../../authentication/screens/signup/signup_screen.dart';
import '../../personalization/controllers/user_controller.dart';
import '../models/comment_model.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';

class CommentController extends GetxController {
  static CommentController get instance => Get.find();

  final _commentRepository = Get.put(CommentRepository());
  final authRepo = AuthenticationRepository.instance;
  final notificationController = Get.put(NotificationController());

  // Reactive state
  final RxList<CommentModel> _comments = <CommentModel>[].obs;
  final RxMap<String, List<CommentModel>> _replies =
      <String, List<CommentModel>>{}.obs;
  final RxMap<String, Map<String, bool>> _commentReactions =
      <String, Map<String, bool>>{}.obs;
  final RxMap<String, bool> _showRepliesMap = <String, bool>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxString _currentPlaceId = ''.obs;

  // Getters
  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading.value;
  String get currentPlaceId => _currentPlaceId.value;
  Map<String, bool> get showRepliesMap => _showRepliesMap;

  List<CommentModel> getRepliesForComment(String commentId) =>
      _replies[commentId] ?? [];

  Map<String, bool> getCommentReaction(String commentId) =>
      _commentReactions[commentId] ?? {'liked': false, 'disliked': false};

  // NEW: Get nested replies for any comment (supports unlimited nesting)
  List<CommentModel> getNestedReplies(String commentId) {
    return _replies[commentId] ?? [];
  }

  // Check if a comment has any replies
  bool hasReplies(String commentId) {
    return _replies.containsKey(commentId) && _replies[commentId]!.isNotEmpty;
  }

  // NEW: Get the total nested reply count for a comment (including nested replies)
  int getTotalReplyCount(String commentId) {
    final directReplies = _replies[commentId] ?? [];
    int totalCount = directReplies.length;

    // Recursively count nested replies
    for (final reply in directReplies) {
      totalCount += getTotalReplyCount(reply.id);
    }

    return totalCount;
  }

  // Toggle show/hide replies for a comment
  void toggleShowReplies(String commentId) {
    final currentState = _showRepliesMap[commentId] ?? false;
    _showRepliesMap[commentId] = !currentState;
  }

  // Initialize comments for a place
  void initializeComments(String placeId) {
    _currentPlaceId.value = placeId;
    _loadComments();
  }

  void _loadComments() {
    _commentRepository.getCommentsForPlace(_currentPlaceId.value).listen((
      comments,
    ) {
      _comments.assignAll(comments);

      // Load user reactions and replies for each comment
      for (final comment in comments) {
        _loadUserReaction(comment.id);
        _loadReplies(comment.id);
      }
    });
  }

  void _loadReplies(String commentId) {
    _commentRepository.getRepliesForComment(commentId).listen((replies) {
      _replies[commentId] = replies;

      // Load user reactions for replies
      for (final reply in replies) {
        _loadUserReaction(reply.id);
        // NEW: Load nested replies recursively
        _loadReplies(reply.id);
      }
    });
  }

  Future<void> _loadUserReaction(String commentId) async {
    try {
      final userId = authRepo.getUserID;
      if (userId.isEmpty) return;

      final reaction = await _commentRepository.getUserCommentReaction(
        commentId,
        userId,
      );
      _commentReactions[commentId] = reaction;
    } catch (e) {
      AppLoaders.errorSnackBar(
        // title: 'Oh Snap!',
        title: txt.ohSnap,
        // message: 'Error loading user reaction: $e',
        message: txt.errorLoading,
      );
    }
  }

  // Add comment with proper nested reply handling
  Future<void> addComment(String commentText, {String? parentCommentId}) async {
    try {
      _isLoading.value = true;

      final userId = authRepo.getUserID;

      if (userId.isEmpty || AuthenticationRepository.instance.isGuestUser) {
        AppLoaders.warningSnackBar(
          // title: 'Authentication Required',
          title: txt.authenticationRequired,
          // message: 'Please sign in or create an account to comment.',
          message: txt.pleaseLogInToUseFeature,
        );
        Get.to(() => const SignupScreen());
        return;
      }

      final userName = UserController.instance.user.value.fullName;
      final userAvatar = UserController.instance.user.value.profilePicture;

      final comment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        placeId: _currentPlaceId.value,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        commentText: commentText,
        timestamp: DateTime.now(),
        updatedAt: DateTime.now(),
        parentCommentId: parentCommentId,
      );

      await _commentRepository.addComment(comment);

      // If it's a reply, update ALL parent comment reply counts recursively
      if (parentCommentId != null) {
        await _updateParentReplyCounts(parentCommentId, 1);
      }

      _isLoading.value = false;
      AppLoaders.successSnackBar(
        // title: 'Success',
        title: txt.success,
        // message: 'Comment added successfully',
        message: txt.commentAddedSuccessfully,
        // message: txt
      );
    } catch (e) {
      _isLoading.value = false;
      AppLoaders.errorSnackBar(
        // title: 'Oh Snap!',
        title: txt.ohSnap,
        // message: 'Failed to add comment: $e',
        message: txt.failedToAddComment,
      );
    }
  }

  // Recursively update parent comment reply counts
  Future<void> _updateParentReplyCounts(String commentId, int change) async {
    String currentCommentId = commentId;

    while (currentCommentId.isNotEmpty) {
      await _commentRepository.updateReplyCount(currentCommentId, change);

      // Get the parent of current comment to continue up the chain
      final currentComment = _getCommentById(currentCommentId);
      if (currentComment?.parentCommentId != null) {
        currentCommentId = currentComment!.parentCommentId!;
      } else {
        break; // Reached top-level comment
      }
    }
  }

  // Update comment
  Future<void> updateComment(String commentId, String newText) async {
    try {
      final comment = _getCommentById(commentId);
      if (comment != null) {
        final updatedComment = comment.copyWith(
          commentText: newText,
          updatedAt: DateTime.now(),
        );
        await _commentRepository.updateComment(updatedComment);
        // AppLoaders.successSnackBar(
        //   // title: 'Success',
        //   title: txt.success,
        //   message: 'Comment updated successfully',
        // );
        AppLoaders.successSnackBar(
          title: txt.success,
          message: txt.commentUpdatedSuccess,
        );
      }
    } catch (e) {
      // AppLoaders.errorSnackBar(
      //   title: 'Oh Snap!',
      //   message: 'Failed to update comment: $e',
      // );
      AppLoaders.errorSnackBar(
        title: txt.commentUpdateError,
        message: txt.failedToUpdateComment(e.toString()),
      );
    }
  }

  // UPDATED: Delete comment with proper nested reply handling
  Future<void> deleteComment(String commentId) async {
    try {
      final comment = _getCommentById(commentId);
      if (comment != null) {
        // Get the total number of nested replies to delete (for count update)
        final totalRepliesToDelete = _countAllNestedReplies(commentId) + 1;

        // Delete all nested replies recursively
        await _deleteNestedReplies(commentId);

        // If it's a reply, update ALL parent comment reply counts recursively
        if (comment.parentCommentId != null) {
          await _updateParentReplyCounts(
            comment.parentCommentId!,
            -totalRepliesToDelete,
          );
        }

        await _commentRepository.deleteComment(commentId);

        // Remove from local state
        _removeCommentFromState(commentId, comment.parentCommentId);

        // AppLoaders.successSnackBar(
        //   title: 'Success',
        //   message: 'Comment deleted successfully',
        // );
        AppLoaders.successSnackBar(
          title: txt.success,
          message: txt.commentDeletedSuccess,
        );
      }
    } catch (e) {
      // AppLoaders.errorSnackBar(
      //   title: 'Oh Snap!',
      //   message: 'Failed to delete comment: $e',
      // );
      AppLoaders.errorSnackBar(
        title: txt.commentDeleteError,
        message: txt.failedToDeleteComment(e.toString()),
      );
    }
  }

  // Count all nested replies recursively
  int _countAllNestedReplies(String commentId) {
    int count = 0;
    final directReplies = _replies[commentId] ?? [];

    for (final reply in directReplies) {
      count += 1 + _countAllNestedReplies(reply.id);
    }

    return count;
  }

  // NEW: Delete all nested replies recursively
  Future<void> _deleteNestedReplies(String commentId) async {
    final replies = _replies[commentId] ?? [];

    for (final reply in replies) {
      // Recursively delete nested replies
      await _deleteNestedReplies(reply.id);
      await _commentRepository.deleteComment(reply.id);
    }

    // Clear the replies from local state
    _replies.remove(commentId);
  }

  // NEW: Remove comment from local state properly
  void _removeCommentFromState(String commentId, String? parentCommentId) {
    if (parentCommentId != null) {
      // Remove from parent's replies
      _replies[parentCommentId]?.removeWhere((c) => c.id == commentId);
    } else {
      // Remove from main comments
      _comments.removeWhere((c) => c.id == commentId);
    }

    // Remove from show replies map
    _showRepliesMap.remove(commentId);
    // Remove from reactions
    _commentReactions.remove(commentId);
  }

  // Like/Dislike comment
  Future<void> reactToComment(String commentId, bool isLike) async {
    try {
      final userId = authRepo.getUserID;

      if (userId.isEmpty || AuthenticationRepository.instance.isGuestUser) {
        // AppLoaders.warningSnackBar(
        //   title: 'Authentication Required',
        //   message: 'Please sign in or create an account to react.',
        // );
        AppLoaders.warningSnackBar(
          title: txt.authenticationRequired,
          message: txt.pleaseSignIn,
        );

        Get.to(() => const SignupScreen());

        return;
      }

      await _commentRepository.likeComment(commentId, userId, isLike);
      _loadUserReaction(commentId); // Reload reaction
    } catch (e) {
      // AppLoaders.errorSnackBar(
      //   title: 'Oh Snap!',
      //   message: 'Failed to react to comment: $e',
      // );
      AppLoaders.errorSnackBar(
        title: txt.commentReactError,
        message: txt.failedToReact(e.toString()),
      );
    }
  }

  // Alias method for consistency
  Future<void> likeComment(String commentId, bool isLike) async {
    await reactToComment(commentId, isLike);
  }

  // Separate method for liking replies if needed
  Future<void> likeReply(String commentId, String replyId, bool isLike) async {
    try {
      final userId = authRepo.getUserID;
      if (userId.isEmpty) {
        // AppLoaders.errorSnackBar(
        //   title: 'Oh Snap!',
        //   message: 'You must be logged in to react',
        // );
        AppLoaders.errorSnackBar(
          title: txt.commentReactError,
          message: txt.youMustBeLoggedIn,
        );
        return;
      }

      // Use the same likeComment method since replies are also comments
      await _commentRepository.likeComment(replyId, userId, isLike);
      _loadUserReaction(replyId); // Reload reaction for this specific reply
    } catch (e) {
      // AppLoaders.errorSnackBar(
      //   title: 'Oh Snap!',
      //   message: 'Failed to react to reply: $e',
      // );
      AppLoaders.errorSnackBar(
        title: txt.commentReactError,
        message: txt.failedToReactToReply(e.toString()),
      );
    }
  }

  // Check if user owns the comment
  Future<bool> isCommentOwner(String commentId) async {
    try {
      final userId = authRepo.getUserID;
      if (userId.isEmpty) return false;

      return await _commentRepository.isCommentOwner(commentId, userId);
    } catch (e) {
      return false;
    }
  }

  // Alias method for checkCommentOwnership
  Future<bool> checkCommentOwnership(String commentId) async {
    return await isCommentOwner(commentId);
  }

  // === HELPER METHODS ===

  CommentModel? _getCommentById(String commentId) {
    // Search in main comments
    final mainComment = _comments.firstWhereOrNull(
      (comment) => comment.id == commentId,
    );
    if (mainComment != null) return mainComment;

    // Search in replies
    for (final replyList in _replies.values) {
      final reply = replyList.firstWhereOrNull(
        (comment) => comment.id == commentId,
      );
      if (reply != null) return reply;
    }

    return null;
  }

  @override
  void onClose() {
    _comments.clear();
    _replies.clear();
    _commentReactions.clear();
    _showRepliesMap.clear();
    super.onClose();
  }
}
