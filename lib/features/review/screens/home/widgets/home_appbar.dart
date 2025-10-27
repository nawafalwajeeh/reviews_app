import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/icons/circular_icon.dart';
// import 'package:get/get.dart';
// import 'package:reviews_app/features/review/screens/notifications/notifications.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/text_strings.dart';

import '../../../../../utils/constants/sizes.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(UserController());

    return CustomAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.homeAppbarTitle,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.apply(color: AppColors.grey),
          ),
          Text(
            'Clean_coder',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.apply(color: AppColors.white),
          ),
        ],
      ),
      actions: [
        AppCircularIcon(
          icon: Icons.notifications_outlined,
          backgroundColor: Colors.blue[100],
          color: Colors.blue,
          size: AppSizes.iconMd,
          // onPressed: () => Get.to(() => const NotificationsScreen()),
        ),
      ],
    );
  }
}

// class HomeAppBar extends StatelessWidget {
//   const HomeAppBar({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(UserController());
//
//     return CustomAppBar(
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             AppTexts.homeAppbarTitle,
//             style: Theme.of(
//               context,
//             ).textTheme.labelMedium?.apply(color: AppColors.grey),
//           ),
//
//           Obx(() {
//             if (controller.profileLoading.value) {
//               return const AppShimmerEffect(width: 80, height: 15);
//             } else {
//               return GestureDetector(
//                 onTap: () => Get.toNamed(AppRoutes.userProfile),
//                 child: Text(
//                   controller.user.value.fullName,
//                   style: Theme.of(
//                     context,
//                   ).textTheme.headlineSmall?.apply(color: AppColors.white),
//                 ),
//               );
//             }
//           }),
//         ],
//       ),
//       actions: [
//           AppCircularIcon(
//             icon: Icons.notifications_outlined,
//             backgroundColor: Colors.blue[100],
//             color: Colors.blue,
//            size: AppSizes.iconMd,
//            onPressed: () => Get.to(() => const NotificationsScreen()),
//         ),
//       ],
//     );
//   }
// }
