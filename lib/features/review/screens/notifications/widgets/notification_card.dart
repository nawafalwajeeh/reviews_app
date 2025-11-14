
import 'package:flutter/material.dart';

import 'milestone_badge.dart';
import 'notification_action_button.dart';
import 'notification_content.dart';
import 'notification_icon.dart';

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String timeAgo;
  final String description;
  final List<Color> gradientColors;
  final NotificationActionButton? actionButton;
  final List<String>? userAvatars;
  final MilestoneBadge? milestoneBadge;
  final String? followingText;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.timeAgo,
    required this.description,
    required this.gradientColors,
    this.actionButton,
    this.userAvatars,
    this.milestoneBadge,
    this.followingText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NotificationIcon(icon: icon, gradientColors: gradientColors),
            const SizedBox(width: 12),
            Expanded(
              child: NotificationContent(
                title: title,
                timeAgo: timeAgo,
                description: description,
                actionButton: actionButton,
                userAvatars: userAvatars,
                milestoneBadge: milestoneBadge,
                followingText: followingText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
