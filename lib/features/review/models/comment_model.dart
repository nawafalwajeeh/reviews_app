
// models/comment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String id;
  String placeId; // The place being commented on
  String userId;
  String userName;
  String userAvatar;
  String commentText;
  DateTime timestamp;
  DateTime updatedAt;
  List<String> likes;
  List<String> dislikes;
  int repliesCount;
  String? parentCommentId; // For nested comments (replies to comments)

  CommentModel({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.commentText,
    required this.timestamp,
    required this.updatedAt,
    this.likes = const [],
    this.dislikes = const [],
    this.repliesCount = 0,
    this.parentCommentId,
  });

  factory CommentModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return CommentModel(
      id: document.id,
      placeId: data['placeId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous User',
      userAvatar: data['userAvatar'] ?? 'assets/images/user.png',
      commentText: data['commentText'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
      dislikes: List<String>.from(data['dislikes'] ?? []),
      repliesCount: data['repliesCount'] as int? ?? 0,
      parentCommentId: data['parentCommentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'commentText': commentText,
      'timestamp': Timestamp.fromDate(timestamp),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'likes': likes,
      'dislikes': dislikes,
      'repliesCount': repliesCount,
      'parentCommentId': parentCommentId,
    };
  }

  CommentModel copyWith({
    String? commentText,
    List<String>? likes,
    List<String>? dislikes,
    int? repliesCount,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: id,
      placeId: placeId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      commentText: commentText ?? this.commentText,
      timestamp: timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      repliesCount: repliesCount ?? this.repliesCount,
      parentCommentId: parentCommentId,
    );
  }
}