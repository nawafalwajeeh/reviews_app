// utils/notification_service.dart

import '../../../features/review/controllers/notification_controller.dart';

class NotificationService {
  static Future<void> sendNewReviewNotification({
    required String placeOwnerId,
    required String reviewerId,
    required String reviewerName,
    required String reviewerAvatar,
    required String placeId,
    required String placeName,
    required double rating,
    required String reviewText,
  }) async {
    try {
      await NotificationController.instance.sendNotification(
        toUserId: placeOwnerId,
        type: 'new_review',
        title: 'New Review on Your Place',
        body: '$reviewerName reviewed "$placeName"',
        senderName: reviewerName,
        senderAvatar: reviewerAvatar,
        targetId: placeId,
        targetType: 'place',
        extraData: {
          'senderId': reviewerId,
          'placeId': placeId,
          'placeName': placeName,
          'rating': rating.toString(),
          'reviewText': reviewText,
        },
      );
    } catch (e) {
      print('Error sending new review notification: $e');
    }
  }

  static Future<void> sendReviewLikedNotification({
    required String reviewAuthorId,
    required String likerId,
    required String likerName,
    required String likerAvatar,
    required String reviewId,
    required String placeId,
    required int likeCount,
  }) async {
    try {
      await NotificationController.instance.sendNotification(
        toUserId: reviewAuthorId,
        type: 'review_liked',
        title: 'Your Review Got Liked',
        body: '$likerName liked your review',
        senderName: likerName,
        senderAvatar: likerAvatar,
        targetId: reviewId,
        targetType: 'review',
        extraData: {
          'senderId': likerId,
          'placeId': placeId,
          'reviewId': reviewId,
          'likeCount': likeCount.toString(),
        },
      );
    } catch (e) {
      print('Error sending review liked notification: $e');
    }
  }

  static Future<void> sendNewCommentNotification({
    required String reviewAuthorId,
    required String commenterId,
    required String commenterName,
    required String commenterAvatar,
    required String reviewId,
    required String placeId,
    required String commentId,
    required String commentText,
  }) async {
    try {
      await NotificationController.instance.sendNotification(
        toUserId: reviewAuthorId,
        type: 'new_comment',
        title: 'New Comment on Your Review',
        body: '$commenterName commented on your review',
        senderName: commenterName,
        senderAvatar: commenterAvatar,
        targetId: reviewId,
        targetType: 'review',
        extraData: {
          'senderId': commenterId,
          'placeId': placeId,
          'reviewId': reviewId,
          'commentId': commentId,
          'commentText': commentText,
        },
      );
    } catch (e) {
      print('Error sending new comment notification: $e');
    }
  }

  static Future<void> sendCommentReplyNotification({
    required String parentCommentAuthorId,
    required String replierId,
    required String replierName,
    required String replierAvatar,
    required String commentId,
    required String parentCommentId,
    required String placeId,
    required String replyText,
  }) async {
    try {
      await NotificationController.instance.sendNotification(
        toUserId: parentCommentAuthorId,
        type: 'comment_replied',
        title: 'New Reply to Your Comment',
        body: '$replierName replied to your comment',
        senderName: replierName,
        senderAvatar: replierAvatar,
        targetId: parentCommentId,
        targetType: 'comment',
        extraData: {
          'senderId': replierId,
          'placeId': placeId,
          'commentId': commentId,
          'parentCommentId': parentCommentId,
          'replyText': replyText,
        },
      );
    } catch (e) {
      print('Error sending comment reply notification: $e');
    }
  }

  static Future<void> sendNewFollowerNotification({
    required String followedUserId,
    required String followerId,
    required String followerName,
    required String followerAvatar,
  }) async {
    try {
      await NotificationController.instance.sendNotification(
        toUserId: followedUserId,
        type: 'new_follower',
        title: 'New Follower',
        body: '$followerName started following you',
        senderName: followerName,
        senderAvatar: followerAvatar,
        targetId: followerId,
        targetType: 'user',
        extraData: {'senderId': followerId},
      );
    } catch (e) {
      print('Error sending new follower notification: $e');
    }
  }

  static Future<void> sendPlaceFeaturedNotification({
    required String placeOwnerId,
    required String placeId,
    required String placeName,
  }) async {
    try {
      await NotificationController.instance.sendNotification(
        toUserId: placeOwnerId,
        type: 'place_featured',
        title: 'Your Place is Featured!',
        body: '"$placeName" is now featured on the homepage',
        senderName: 'Reviews App',
        senderAvatar: '',
        targetId: placeId,
        targetType: 'place',
        extraData: {'placeId': placeId, 'placeName': placeName},
      );
    } catch (e) {
      print('Error sending place featured notification: $e');
    }
  }
}
