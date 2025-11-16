import 'package:flutter/material.dart';
import 'package:reviews_app/features/review/screens/notifications/widgets/user_avatars_list.dart';

import 'milestone_badge.dart';
import 'notification_action_button.dart';

class NotificationContent extends StatelessWidget {
  final String title;
  final String timeAgo;
  final String description;
  final NotificationActionButton? actionButton;
  final List<String>? userAvatars;
  final MilestoneBadge? milestoneBadge;
  final String? followingText;

  const NotificationContent({
    super.key,
    required this.title,
    required this.timeAgo,
    required this.description,
    this.actionButton,
    this.userAvatars,
    this.milestoneBadge,
    this.followingText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Flexible(
              child: Text(
                timeAgo,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        if (actionButton != null) actionButton!,
        if (userAvatars != null && userAvatars!.isNotEmpty) ...[
          const SizedBox(height: 8),
          UserAvatarsList(avatars: userAvatars!, followingText: followingText),
        ],
        if (milestoneBadge != null) ...[
          const SizedBox(height: 8),
          milestoneBadge!,
        ],
      ],
    );
  }
}
