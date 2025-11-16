// models/notification_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String type; // new_review, review_liked, new_comment, comment_liked, new_follower, place_featured
  final String title;
  final String body;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String targetId; // placeId, reviewId, userId, commentId
  final String targetType; // place, review, user, comment
  final bool isRead;
  final DateTime timestamp;
  final Map<String, dynamic> extraData;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.targetId,
    required this.targetType,
    required this.isRead,
    required this.timestamp,
    this.extraData = const {},
  });

  // Convert to map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'body': body,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'targetId': targetId,
      'targetType': targetType,
      'isRead': isRead,
      'timestamp': timestamp,
      'extraData': extraData,
    };
  }

  // Create from Firestore document
  factory NotificationModel.fromFirestore(String id, Map<String, dynamic> data) {
    return NotificationModel(
      id: id,
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderAvatar: data['senderAvatar'] ?? '',
      targetId: data['targetId'] ?? '',
      targetType: data['targetType'] ?? '',
      isRead: data['isRead'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      extraData: Map<String, dynamic>.from(data['extraData'] ?? {}),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? targetId,
    String? targetType,
    bool? isRead,
    DateTime? timestamp,
    Map<String, dynamic>? extraData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      extraData: extraData ?? this.extraData,
    );
  }

  // Helper methods
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    return '${(difference.inDays / 30).floor()}mo ago';
  }

  // Get appropriate icon for notification type
  String get iconAsset {
    switch (type) {
      case 'new_review':
        return 'assets/icons/review_icon.png';
      case 'review_liked':
      case 'comment_liked':
        return 'assets/icons/like_icon.png';
      case 'new_comment':
      case 'comment_replied':
        return 'assets/icons/comment_icon.png';
      case 'new_follower':
        return 'assets/icons/follower_icon.png';
      case 'place_featured':
        return 'assets/icons/featured_icon.png';
      default:
        return 'assets/icons/notification_icon.png';
    }
  }
}

//-------------------------
// import 'package:flutter/material.dart';

// class NotificationModel {
//   // If icon is null, the widget will use the default icon.
//   final IconData? icon; 
//   final String title;
//   final String timeAgo;
//   final String description;
//   final List<Color> gradientColors;
  
//   // Action Button Fields
//   final String? actionText;
//   final Color? actionBgColor;
//   final Color? actionTextColor;
  
//   // User Avatars (for likes/friend activity)
//   final List<String>? userAvatars;
  
//   // Milestone Badge Fields
//   final String? milestoneText;
//   final IconData? milestoneIcon;
  
//   // Following text (for friend activity)
//   final String? followingText;

//   NotificationModel({
//     this.icon, 
//     required this.title,
//     required this.timeAgo,
//     required this.description,
//     required this.gradientColors,
//     this.actionText,
//     this.actionBgColor,
//     this.actionTextColor,
//     this.userAvatars,
//     this.milestoneText,
//     this.milestoneIcon,
//     this.followingText,
//   });
// }
