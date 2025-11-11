import 'package:cloud_firestore/cloud_firestore.dart';

import 'reply_model.dart';

/// Model for a single place review.
class ReviewModel {
  String id;
  String placeId; // Foreign key to the place being reviewed
  String userId;
  String userName;
  String userAvatar;
  double rating; // 1.0 to 5.0
  String reviewText;
  DateTime timestamp;
  List<String> likes; // List of User IDs who liked the review
  List<String> dislikes; // List of User IDs who disliked the review
  int repliesCount;
  List<ReplyModel> replies; // Nested replies

  ReviewModel({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.reviewText,
    required this.timestamp,
    this.likes = const [],
    this.dislikes = const [],
    this.replies = const [],
    this.repliesCount = 0, // Initialize the new field
  });

  /// Factory constructor to create a ReviewModel from a Firestore DocumentSnapshot
  factory ReviewModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return ReviewModel(
      id: document.id,
      placeId: data['placeId'] ?? 'unknown',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous User',
      userAvatar: data['userAvatar'] ?? 'assets/images/user.png', // Default
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewText: data['reviewText'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
      dislikes: List<String>.from(data['dislikes'] ?? []),
       repliesCount: data['repliesCount'] as int? ?? 0, 
      replies:
          [], // Replies are handled in the controller by fetching separately
    );
  }

  /// Convert ReviewModel to a map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'reviewText': reviewText,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'dislikes': dislikes,
       'repliesCount': repliesCount,
      // Replies are stored in a sub-collection, not in the parent document
    };
  }
}


/*
 will try

 import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating; // Only for top-level reviews
  final String text;
  final DateTime date;
  final int likesCount;
  final int repliesCount;
  final String? parentReviewId; // Null for top-level comments
  final List<String> likedBy;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.date,
    required this.likesCount,
    required this.repliesCount,
    required this.likedBy,
    this.rating = 0.0,
    this.parentReviewId,
  });

  /// Factory constructor to create a ReviewModel from a Firestore document.
  factory ReviewModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userAvatar: data['userAvatar'] ?? 'assets/images/users/user.png',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      text: data['text'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      likesCount: (data['likesCount'] as int?) ?? 0,
      repliesCount: (data['repliesCount'] as int?) ?? 0,
      parentReviewId: data['parentReviewId'],
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  /// Convert model to Firestore JSON structure.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'text': text,
      'date': Timestamp.fromDate(date),
      'likesCount': likesCount,
      'repliesCount': repliesCount,
      'parentReviewId': parentReviewId,
      'likedBy': likedBy,
    };
  }
}

/// Helper class for calculating overall rating statistics.
class OverallRatingModel {
  final double averageRating;
  final int totalReviews;
  final Map<int, double> starBreakdown; // {5: 0.75, 4: 0.15, ...}

  OverallRatingModel({
    required this.averageRating,
    required this.totalReviews,
    required this.starBreakdown,
  });
}
 */