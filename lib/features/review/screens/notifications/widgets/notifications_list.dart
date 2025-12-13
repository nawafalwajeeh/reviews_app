// import 'package:flutter/material.dart';
// features/review/screens/notifications/widgets/notifications_list.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/notification_controller.dart';
import '../../../models/notification_model.dart';
import 'milestone_badge.dart';
import 'notification_action_button.dart';
import 'notification_card.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = NotificationController.instance;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final notifications = controller.notifications;

      if (notifications.isEmpty) {
        return const _EmptyNotifications();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ListView.separated(
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notification = notifications[index];
           
            return _NotificationItem(notification: notification);
          },
        ),
      );
    });
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData(notification.type);
    final gradientColors = _getGradientColors(notification.type);
    final actionButton = _getActionButton(notification);
    final milestoneBadge = _getMilestoneBadge(notification);

    return NotificationCard(
      icon: iconData,
      title: notification.title,
      timeAgo: notification.timeAgo,
      description: notification.body,
      gradientColors: gradientColors,
      actionButton: actionButton,
      milestoneBadge: milestoneBadge,
      userAvatars: [notification.senderAvatar],
      isRead: notification.isRead,
      onTap: () => _handleNotificationTap(notification),
    );
  }

  IconData _getIconData(String type) {
    switch (type) {
      case 'new_review':
        return Icons.rate_review_rounded;
      case 'review_liked':
      case 'comment_liked':
        return Icons.thumb_up_rounded;
      case 'new_comment':
      case 'comment_replied':
        return Icons.comment_rounded;
      case 'new_follower':
        return Icons.person_add_rounded;
      case 'place_featured':
        return Icons.star_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  List<Color> _getGradientColors(String type) {
    switch (type) {
      case 'new_review':
        return [Color(0xFF0066CC), Color(0xFF004499)];
      case 'review_liked':
      case 'comment_liked':
        return [Color(0xFFCC0000), Color(0xFF990000)];
      case 'new_comment':
      case 'comment_replied':
        return [Color(0xFF00AA00), Color(0xFF008800)];
      case 'new_follower':
        return [Color(0xFFFF6600), Color(0xFFCC4400)];
      case 'place_featured':
        return [Color(0xFFFFD700), Color(0xFFFFAA00)];
      default:
        return [Color(0xFF666666), Color(0xFF444444)];
    }
  }

  NotificationActionButton? _getActionButton(NotificationModel notification) {
    switch (notification.type) {
      case 'new_review':
        return NotificationActionButton(
          text: 'View Review',
          backgroundColor: Color(0xFFE7F3FF),
          textColor: Color(0xFF0066CC),
        );
      case 'new_follower':
        return NotificationActionButton(
          text: 'Follow Back',
          backgroundColor: Color(0xFFE7FFE7),
          textColor: Color(0xFF00AA00),
        );
      default:
        return null;
    }
  }

  MilestoneBadge? _getMilestoneBadge(NotificationModel notification) {
    if (notification.type == 'place_featured') {
      return MilestoneBadge(icon: Icons.emoji_events_rounded, text: 'Featured');
    }
    return null;
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      NotificationController.instance.markAsRead(notification.id);
    }

    // Navigate based on notification type
    final controller = NotificationController.instance;
    controller.navigateToNotificationTarget(
      notification.type,
      notification.extraData,
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'When you get notifications, they\'ll appear here',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

//----------------------------
// import '../../../controllers/notification_controller.dart';
// import 'milestone_badge.dart';
// import 'notification_action_button.dart';
// import 'notification_card.dart';

// class NotificationList extends StatelessWidget {
//   const NotificationList({super.key});

//   static const IconData defaultIcon = Icons.notifications_rounded;

//   @override
//   Widget build(BuildContext context) {
//     // Access the mock data list
//     final controller = NotificationController.instance;
//     final notifications = controller.mockNotifications;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: ListView.separated(
//         itemCount: notifications.length,
//         separatorBuilder: (context, index) => const SizedBox(height: 12),
//         itemBuilder: (context, index) {
//           final model = notifications[index];

//           // Determine the icon: Use the model's icon, or the default icon if null
//           final IconData notificationIcon = model.icon ?? defaultIcon;

//           // Determine the action button widget
//           final NotificationActionButton? actionButton =
//               model.actionText != null
//               ? NotificationActionButton(
//                   text: model.actionText!,
//                   backgroundColor:
//                       model.actionBgColor ?? const Color(0xFFE7FFE7),
//                   textColor: model.actionTextColor ?? Colors.black87,
//                 )
//               : null;

//           // Determine the milestone badge widget
//           final MilestoneBadge? milestoneBadge = model.milestoneText != null
//               ? MilestoneBadge(
//                   icon: model.milestoneIcon ?? Icons.emoji_events_rounded,
//                   text: model.milestoneText!,
//                 )
//               : null;

//           return NotificationCard(
//             icon: notificationIcon,
//             title: model.title,
//             timeAgo: model.timeAgo,
//             description: model.description,
//             gradientColors: model.gradientColors,
//             actionButton: actionButton,
//             milestoneBadge: milestoneBadge,
//             userAvatars: model.userAvatars,
//             followingText: model.followingText,
//           );
//         },
//       ),
//     );
//   }
// }
