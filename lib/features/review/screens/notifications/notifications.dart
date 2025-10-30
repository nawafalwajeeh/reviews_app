import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            AppPrimaryHeaderContainer(
              child: Column(
                children: [
                  CustomAppBar(
                    leadingIcon: Iconsax.direct_left,
                    leadingOnPressed: () => Get.back(),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spaceBtwItems,
                        ),
                        child: Row(
                          children: [
                            _AppBarIconButton(
                              icon: Icons.settings_rounded,
                              onPressed: () => _handleSettingsPressed(),
                            ),
                            const SizedBox(width: 8),
                            _AppBarIconButton(
                              icon: Icons.mark_email_read_rounded,
                              onPressed: () => _handleMarkAllReadPressed(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Text(
                    'Notifications',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.apply(color: AppColors.white),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      'Stay updated with reviews and recommendations',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.apply(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
            // _HeaderSection()
            Expanded(child: _NotificationList()),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _AppBarIconButton(
                icon: Icons.settings_rounded,
                onPressed: () => _handleSettingsPressed(),
              ),
              const SizedBox(width: 8),
              _AppBarIconButton(
                icon: Icons.mark_email_read_rounded,
                onPressed: () => _handleMarkAllReadPressed(),
              ),
            ],
          ),
        ),
      ],
      elevation: 0,
    );
  }

  void _handleSettingsPressed() {
    debugPrint('Settings button pressed');
  }

  void _handleMarkAllReadPressed() {
    debugPrint('Mark all as read button pressed');
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          stops: const [0.8, 1],
          begin: const AlignmentDirectional(1, 1),
          end: const AlignmentDirectional(-1, -1),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_HeaderTitle(), SizedBox(height: 4), _HeaderSubtitle()],
        ),
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Notifications',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: Theme.of(context).colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _HeaderSubtitle extends StatelessWidget {
  const _HeaderSubtitle();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.8,
      child: Text(
        'Stay updated with reviews and recommendations',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList();

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
            _NotificationIcon(icon: icon, gradientColors: gradientColors),
            const SizedBox(width: 12),
            Expanded(
              child: _NotificationContent(
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

class _NotificationIcon extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;

  const _NotificationIcon({required this.icon, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          stops: const [0, 1],
          begin: const AlignmentDirectional(1, -1),
          end: const AlignmentDirectional(-1, 1),
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

class _NotificationContent extends StatelessWidget {
  final String title;
  final String timeAgo;
  final String description;
  final NotificationActionButton? actionButton;
  final List<String>? userAvatars;
  final MilestoneBadge? milestoneBadge;
  final String? followingText;

  const _NotificationContent({
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
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              timeAgo,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
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
          _UserAvatars(avatars: userAvatars!, followingText: followingText),
        ],
        if (milestoneBadge != null) ...[
          const SizedBox(height: 8),
          milestoneBadge!,
        ],
      ],
    );
  }
}

class _UserAvatars extends StatelessWidget {
  final List<String> avatars;
  final String? followingText;

  const _UserAvatars({required this.avatars, this.followingText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...avatars.map(
          (avatar) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _UserAvatar(imageUrl: avatar),
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

class _UserAvatar extends StatelessWidget {
  final String imageUrl;

  const _UserAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.person, size: 16),
            );
          },
        ),
      ),
    );
  }
}

class NotificationActionButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const NotificationActionButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MilestoneBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const MilestoneBadge({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _AppBarIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: const Size(40, 40),
      ),
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface,
        size: 20,
      ),
    );
  }
}
