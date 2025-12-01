// repositories/comment_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import '../../../features/review/models/comment_model.dart';

class CommentRepository extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _commentsCollection = 'Comments';

  // === COMMENT OPERATIONS ===

  // Add a new comment
  Future<CommentModel> addComment(CommentModel comment) async {
    try {
      final commentRef = _firestore
          .collection(_commentsCollection)
          .doc(comment.id);
      await commentRef.set(comment.toJson());
      return comment;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Get comments for a place (top-level comments only)
  Stream<List<CommentModel>> getCommentsForPlace(String placeId) {
    return _firestore
        .collection(_commentsCollection)
        .where('placeId', isEqualTo: placeId)
        .where('parentCommentId', isNull: true) // Only top-level comments
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromSnapshot(doc))
              .toList(),
        );
  }

  // Get replies for a comment
  Stream<List<CommentModel>> getRepliesForComment(String commentId) {
    return _firestore
        .collection(_commentsCollection)
        .where('parentCommentId', isEqualTo: commentId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromSnapshot(doc))
              .toList(),
        );
  }

  // Update a comment
  Future<void> updateComment(CommentModel comment) async {
    try {
      await _firestore
          .collection(_commentsCollection)
          .doc(comment.id)
          .update(comment.toJson());
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  }

  // Delete a comment
  Future<void> deleteComment(String commentId) async {
    try {
      await _firestore.collection(_commentsCollection).doc(commentId).delete();
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  // Like/Dislike a comment
  Future<void> likeComment(String commentId, String userId, bool isLike) async {
    try {
      final docRef = _firestore.collection(_commentsCollection).doc(commentId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        // if (!doc.exists) throw Exception('Comment not found');
        if (!doc.exists) throw Exception(txt.noDataFound);

        final comment = CommentModel.fromSnapshot(doc);
        final likedBy = List<String>.from(comment.likes);
        final dislikedBy = List<String>.from(comment.dislikes);

        if (isLike) {
          if (likedBy.contains(userId)) {
            likedBy.remove(userId); // Unlike
          } else {
            likedBy.add(userId); // Like
            dislikedBy.remove(userId); // Remove dislike if exists
          }
        } else {
          if (dislikedBy.contains(userId)) {
            dislikedBy.remove(userId); // Remove dislike
          } else {
            dislikedBy.add(userId); // Dislike
            likedBy.remove(userId); // Remove like if exists
          }
        }

        final updatedComment = comment.copyWith(
          likes: likedBy,
          dislikes: dislikedBy,
          updatedAt: DateTime.now(),
        );

        transaction.update(docRef, updatedComment.toJson());
      });
    } catch (e) {
      // throw Exception('Failed to like/dislike comment: $e');
      throw txt.somethingWentWrong;
    }
  }

  // Get user reaction for a comment
  Future<Map<String, bool>> getUserCommentReaction(
    String commentId,
    String userId,
  ) async {
    try {
      final doc = await _firestore
          .collection(_commentsCollection)
          .doc(commentId)
          .get();
      if (!doc.exists) return {'liked': false, 'disliked': false};

      final comment = CommentModel.fromSnapshot(doc);
      return {
        'liked': comment.likes.contains(userId),
        'disliked': comment.dislikes.contains(userId),
      };
    } catch (e) {
      // throw Exception('Failed to get user reaction: $e');
      throw txt.somethingWentWrong;
    }
  }

  // Increment/Decrement reply count
  Future<void> updateReplyCount(String commentId, int change) async {
    try {
      final commentRef = _firestore
          .collection(_commentsCollection)
          .doc(commentId);
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(commentRef);
        if (doc.exists) {
          final currentCount = doc.data()?['repliesCount'] as int? ?? 0;
          final newCount = currentCount + change;
          transaction.update(commentRef, {
            'repliesCount': newCount >= 0 ? newCount : 0,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
        }
      });
    } catch (e) {
      // print('Error updating reply count: $e');
      throw txt.somethingWentWrong;
    }
  }

  // Check if user owns the comment
  Future<bool> isCommentOwner(String commentId, String userId) async {
    try {
      final doc = await _firestore
          .collection(_commentsCollection)
          .doc(commentId)
          .get();
      if (!doc.exists) return false;

      final comment = CommentModel.fromSnapshot(doc);
      return comment.userId == userId;
    } catch (e) {
      return false;
    }
  }
}
