import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for a single reply to a review.
class ReplyModel {
  String id;
  String userId;
  String userName;
  String userAvatar;
  String replyText;
  DateTime timestamp;

  ReplyModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.replyText,
    required this.timestamp,
  });

  /// Factory constructor to create a ReplyModel from a Firestore DocumentSnapshot
  factory ReplyModel.fromSnapshot(Map<String, dynamic> data, String id) {
    return ReplyModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userAvatar: data['userAvatar'] ?? 'assets/images/user.png', // Default
      replyText: data['replyText'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Convert ReplyModel to a map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'replyText': replyText,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}