// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'reply_model.dart';

// /// Model for a single place review.
// class ReviewModel {
//   String id;
//   String placeId; // Foreign key to the place being reviewed
//   String userId;
//   String userName;
//   String userAvatar;
//   double rating; // 1.0 to 5.0
//   String reviewText;
//   DateTime timestamp;
//   List<String> likes; // List of User IDs who liked the review
//   List<String> dislikes; // List of User IDs who disliked the review
//   List<ReplyModel> replies; // Nested replies

//   ReviewModel({
//     required this.id,
//     required this.placeId,
//     required this.userId,
//     required this.userName,
//     required this.userAvatar,
//     required this.rating,
//     required this.reviewText,
//     required this.timestamp,
//     this.likes = const [],
//     this.dislikes = const [],
//     this.replies = const [],
//   });

//   /// Factory constructor to create a ReviewModel from a Firestore DocumentSnapshot
//   factory ReviewModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
//     final data = document.data()!;
//     // Replies are typically sub-collections, but for simplicity here we assume they are fetched separately or structured in a way that includes them.
//     // For this implementation, we will fetch replies dynamically in the controller or assume a flat structure initially.
//     return ReviewModel(
//       id: document.id,
//       placeId: data['placeId'] ?? 'unknown',
//       userId: data['userId'] ?? '',
//       userName: data['userName'] ?? 'Anonymous User',
//       userAvatar: data['userAvatar'] ?? 'assets/images/user.png', // Default
//       rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
//       reviewText: data['reviewText'] ?? '',
//       timestamp: (data['timestamp'] as Timestamp).toDate(),
//       likes: List<String>.from(data['likes'] ?? []),
//       dislikes: List<String>.from(data['dislikes'] ?? []),
//       replies: [], // Replies are handled in the controller by fetching separately
//     );
//   }

//   /// Convert ReviewModel to a map for Firestore storage
//   Map<String, dynamic> toJson() {
//     return {
//       'placeId': placeId,
//       'userId': userId,
//       'userName': userName,
//       'userAvatar': userAvatar,
//       'rating': rating,
//       'reviewText': reviewText,
//       'timestamp': Timestamp.fromDate(timestamp),
//       'likes': likes,
//       'dislikes': dislikes,
//       // Replies are stored in a sub-collection, not in the parent document
//     };
//   }
// }

// ================== Data Model ==================
class ReviewModel {
  final String userName;
  final String avatarUrl;
  final int rating;
  final String comment;
  final String timeAgo;
  final int likes;

  const ReviewModel({
    required this.userName,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.timeAgo,
    required this.likes,
  });
}
