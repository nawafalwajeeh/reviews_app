import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/controllers/notification_controller.dart';
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
    final controller = Get.put(NotificationController());

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
                IconButton(
                  icon: Icon(Icons.settings_rounded),
                  onPressed: () {},
                ),
                const SizedBox(width: AppSizes.spaceBtwItems / 2),
                IconButton(
                  icon: Icon(Icons.mark_email_read_rounded),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Opacity(
              opacity: 0.8,
              child: Text(
                'Stay updated with reviews and recommendations',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: dark ? AppColors.white : AppColors.dark,
                ),
              ),
            ),
          ),
          Expanded(child: NotificationList()),
        ],
      ),
    );
  }
}
