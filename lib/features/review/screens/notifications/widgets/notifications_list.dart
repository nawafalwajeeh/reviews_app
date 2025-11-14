
import 'package:flutter/material.dart';

import '../../../controllers/notification_controller.dart';
import 'milestone_badge.dart';
import 'notification_action_button.dart';
import 'notification_card.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({super.key});

  static const IconData defaultIcon = Icons.notifications_rounded;

  @override
  Widget build(BuildContext context) {
    // Access the mock data list
    final controller = NotificationController.instance;
    final notifications = controller.mockNotifications;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final model = notifications[index];

          // Determine the icon: Use the model's icon, or the default icon if null
          final IconData notificationIcon = model.icon ?? defaultIcon;

          // Determine the action button widget
          final NotificationActionButton? actionButton =
              model.actionText != null
              ? NotificationActionButton(
                  text: model.actionText!,
                  backgroundColor:
                      model.actionBgColor ?? const Color(0xFFE7FFE7),
                  textColor: model.actionTextColor ?? Colors.black87,
                )
              : null;

          // Determine the milestone badge widget
          final MilestoneBadge? milestoneBadge = model.milestoneText != null
              ? MilestoneBadge(
                  icon: model.milestoneIcon ?? Icons.emoji_events_rounded,
                  text: model.milestoneText!,
                )
              : null;

          return NotificationCard(
            icon: notificationIcon,
            title: model.title,
            timeAgo: model.timeAgo,
            description: model.description,
            gradientColors: model.gradientColors,
            actionButton: actionButton,
            milestoneBadge: milestoneBadge,
            userAvatars: model.userAvatars,
            followingText: model.followingText,
          );
        },
      ),
    );
  }
}
