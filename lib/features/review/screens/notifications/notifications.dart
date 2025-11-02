import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

import 'widgets/notifications_list.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spaceBtwItems,
            ),
            child: Row(
              children: [
                AppBarIconButton(
                  icon: Icons.settings_rounded,
                  onPressed: () {},
                ),
                const SizedBox(width: AppSizes.spaceBtwItems / 2),
                AppBarIconButton(
                  icon: Icons.mark_email_read_rounded,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // _HeaderSection(),
          Opacity(
            opacity: 0.8,
            child: Text(
              'Stay updated with reviews and recommendations',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? AppColors.white : AppColors.dark,
              ),
            ),
          ),
          Expanded(child: NotificationList()),
        ],
      ),
    );
  }
}

class AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

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
