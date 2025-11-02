import 'package:flutter/material.dart';

import 'milestone_badge.dart';
import 'notification_action_button.dart';
import 'notification_card.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ListView(
        children: const [
          NotificationCard(
            icon: Icons.star_rounded,
            title: 'New 5-star review!',
            timeAgo: '2m ago',
            description:
                'Sarah M. left an amazing review for Sunset Café. Check it out!',
            gradientColors: [Color(0xFFFFE7E7), Color(0xFFA8EDEA)],
            actionButton: NotificationActionButton(
              text: 'View Review',
              backgroundColor: Color(0xFFFFE7E7),
              textColor: Color(0xFFFF6B6B),
            ),
          ),
          SizedBox(height: 12),
          NotificationCard(
            icon: Icons.thumb_up_rounded,
            title: 'Review liked!',
            timeAgo: '15m ago',
            description:
                '3 people found your review of Ocean View Restaurant helpful.',
            gradientColors: [Color(0xFFE7F4FF), Color(0xFF4DA8FF)],
            userAvatars: [
              'https://images.unsplash.com/photo-1693641059840-b2ba454dc248',
              'https://images.unsplash.com/photo-1713720178558-5ea3c4ce79e0',
              'https://images.unsplash.com/photo-1713720178558-5ea3c4ce79e0',
            ],
          ),
          SizedBox(height: 12),
          NotificationCard(
            icon: Icons.location_on_rounded,
            title: 'New place nearby',
            timeAgo: '1h ago',
            description:
                'Mountain Peak Brewery just opened 0.5 miles from you. Be the first to review!',
            gradientColors: [Color(0xFFE7FFE7), Color(0xFF1C59A4)],
            actionButton: NotificationActionButton(
              text: 'Explore',
              backgroundColor: Color(0xFFE7FFE7),
              textColor: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          NotificationCard(
            icon: Icons.comment_rounded,
            title: 'Reply to your review',
            timeAgo: '3h ago',
            description:
                'The owner of Artisan Coffee House replied to your review. Thanks for the feedback!',
            gradientColors: [Color(0xFFFFF7E7), Color(0xFF6495ED)],
            actionButton: NotificationActionButton(
              text: 'Read Reply',
              backgroundColor: Color(0xFFFFF7E7),
              textColor: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          NotificationCard(
            icon: Icons.trending_up_rounded,
            title: 'Review milestone!',
            timeAgo: '1d ago',
            description:
                'Congratulations! You\'ve written 50 reviews and helped the community discover great places.',
            gradientColors: [Color(0xFFF3E7FF), Color(0xFFADD8E6)],
            milestoneBadge: MilestoneBadge(
              icon: Icons.emoji_events_rounded,
              text: 'Local Guide Badge Earned',
            ),
          ),
          SizedBox(height: 12),
          NotificationCard(
            icon: Icons.group_rounded,
            title: 'Friend activity',
            timeAgo: '2d ago',
            description:
                'Alex reviewed 2 new places this week. Check out their latest discoveries!',
            gradientColors: [Color(0xFFB0E0FF), Color(0xFF5D6EA0)],
            userAvatars: [
              'https://images.unsplash.com/photo-1740657252845-b4ccbaa65d84',
            ],
            followingText: 'Following',
          ),
        ],
      ),
    );
  }
}
