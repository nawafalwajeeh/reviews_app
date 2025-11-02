

import 'package:flutter/material.dart';

import 'user_avatar.dart';

class UserAvatarsList extends StatelessWidget {
  final List<String> avatars;
  final String? followingText;

  const UserAvatarsList({super.key, required this.avatars, this.followingText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...avatars.map(
          (avatar) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: UserAvatar(imageUrl: avatar),
          ),
        ),
        if (followingText != null) ...[
          const SizedBox(width: 8),
          Text(
            followingText!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}


