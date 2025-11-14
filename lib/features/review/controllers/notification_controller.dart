import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/notification_model.dart';

class NotificationController extends GetxController {
  static NotificationController instance = Get.find();

  final List<NotificationModel> mockNotifications = [
    NotificationModel(
      icon: Icons.star_rounded,
      title: 'New 5-star review!',
      timeAgo: '2m ago',
      description:
          'Sarah M. left an amazing review for Sunset Café. Check it out!',
      gradientColors: const [Color(0xFFFFE7E7), Color(0xFFA8EDEA)],
      actionText: 'View Review',
      actionBgColor: const Color(0xFFFFE7E7),
      actionTextColor: const Color(0xFFFF6B6B),
    ),
    NotificationModel(
      icon: Icons.thumb_up_rounded,
      title: 'Review liked!',
      timeAgo: '15m ago',
      description:
          '3 people found your review of Ocean View Restaurant helpful.',
      gradientColors: const [Color(0xFFE7F4FF), Color(0xFF4DA8FF)],
      userAvatars: const [
        'https://images.unsplash.com/photo-1693641059840-b2ba454dc248',
        'https://images.unsplash.com/photo-1713720178558-5ea3c4ce79e0',
        'https://images.unsplash.com/photo-1713720178558-5ea3c4ce79e0',
      ],
    ),
    NotificationModel(
      icon: Icons.location_on_rounded,
      title: 'New place nearby',
      timeAgo: '1h ago',
      description:
          'Mountain Peak Brewery just opened 0.5 miles from you. Be the first to review!',
      gradientColors: const [Color(0xFFE7FFE7), Color(0xFF1C59A4)],
      actionText: 'Explore',
      actionBgColor: const Color(0xFFE7FFE7),
      actionTextColor: Colors.black87,
    ),
    NotificationModel(
      // icon is deliberately omitted here, so the default icon will be used
      title: 'Reply to your review',
      timeAgo: '3h ago',
      description:
          'The owner of Artisan Coffee House replied to your review. Thanks for the feedback!',
      gradientColors: const [Color(0xFFFFF7E7), Color(0xFF6495ED)],
      actionText: 'Read Reply',
      actionBgColor: const Color(0xFFFFF7E7),
      actionTextColor: Colors.black87,
    ),
    NotificationModel(
      icon: Icons.trending_up_rounded,
      title: 'Review milestone!',
      timeAgo: '1d ago',
      description:
          'Congratulations! You\'ve written 50 reviews and helped the community discover great places.',
      gradientColors: const [Color(0xFFF3E7FF), Color(0xFFADD8E6)],
      milestoneText: 'Local Guide Badge Earned',
      milestoneIcon: Icons.emoji_events_rounded,
    ),
    NotificationModel(
      icon: Icons.group_rounded,
      title: 'Friend activity',
      timeAgo: '2d ago',
      description:
          'Alex reviewed 2 new places this week. Check out their latest discoveries!',
      gradientColors: const [Color(0xFFB0E0FF), Color(0xFF5D6EA0)],
      userAvatars: const [
        'https://images.unsplash.com/photo-1740657252845-b4ccbaa65d84',
      ],
      followingText: 'Following',
    ),
  ];
}
