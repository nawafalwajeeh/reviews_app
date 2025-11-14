


import 'package:flutter/material.dart';

class NotificationModel {
  // If icon is null, the widget will use the default icon.
  final IconData? icon; 
  final String title;
  final String timeAgo;
  final String description;
  final List<Color> gradientColors;
  
  // Action Button Fields
  final String? actionText;
  final Color? actionBgColor;
  final Color? actionTextColor;
  
  // User Avatars (for likes/friend activity)
  final List<String>? userAvatars;
  
  // Milestone Badge Fields
  final String? milestoneText;
  final IconData? milestoneIcon;
  
  // Following text (for friend activity)
  final String? followingText;

  NotificationModel({
    this.icon, 
    required this.title,
    required this.timeAgo,
    required this.description,
    required this.gradientColors,
    this.actionText,
    this.actionBgColor,
    this.actionTextColor,
    this.userAvatars,
    this.milestoneText,
    this.milestoneIcon,
    this.followingText,
  });
}
