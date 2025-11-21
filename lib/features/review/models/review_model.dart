import 'package:cloud_firestore/cloud_firestore.dart';
import 'question_answer_model.dart';
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
    List<QuestionAnswer> questionAnswers; // Add this field

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
        this.questionAnswers = const [], // Initialize with empty list

  });

  /// Factory constructor to create a ReviewModel from a Firestore DocumentSnapshot
  factory ReviewModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
      // Parse question answers
    final questionAnswersData = data['questionAnswers'] as List<dynamic>?;
    final List<QuestionAnswer> questionAnswers = questionAnswersData != null
        ? questionAnswersData.map((qa) => QuestionAnswer.fromJson(qa)).toList()
        : [];
  

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
          questionAnswers: questionAnswers,

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
       'questionAnswers': questionAnswers.map((qa) => qa.toJson()).toList(),
      // Replies are stored in a sub-collection, not in the parent document
    };
  }
}
