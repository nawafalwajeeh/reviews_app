import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../controllers/subscription_controller.dart';
import '../subscription.dart';

class SubscriptionStatusSection extends StatelessWidget {
  const SubscriptionStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final controller = Get.find<SubscriptionController>();
    final dark = AppHelperFunctions.isDarkMode(context);

    return Obx(() {
      if (controller.hasActiveSubscription.value) {
        return _buildActiveSubscription(
          context,
          dark,
          controller,
          appLocalizations,
        );
      } else {
        return _buildUpgradePrompt(context, dark, appLocalizations);
      }
    });
  }

  Widget _buildActiveSubscription(
    BuildContext context,
    bool dark,
    SubscriptionController controller,
    AppLocalizations appLocalizations,
  ) {
    return Column(
      children: [
        AppSectionHeading(
          title: appLocalizations.subscriptionStatus,
          buttonTitle: appLocalizations.manage,
          onPressed: () =>
              _showSubscriptionDetails(context, controller, appLocalizations),
        ),
        const SizedBox(height: AppSizes.spaceBtwItems / 2),
        AppRoundedContainer(
          padding: const EdgeInsets.all(AppSizes.md),
          backgroundColor: dark ? AppColors.darkerGrey : AppColors.light,
          borderColor: AppColors.primaryColor,
          child: Row(
            children: [
              Icon(Icons.star_rounded, color: AppColors.primaryColor, size: 24),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLocalizations.premiumMember,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    if (controller.subscriptionExpiry.value != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${appLocalizations.expires}: ${_formatDate(controller.subscriptionExpiry.value!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: dark ? AppColors.darkGrey : AppColors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                ),
                child: Text(
                  appLocalizations.active,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradePrompt(
    BuildContext context,
    bool dark,
    AppLocalizations appLocalizations,
  ) {
    return Column(
      children: [
        AppSectionHeading(
          title: appLocalizations.createPlaces,
          buttonTitle: appLocalizations.upgrade,
          onPressed: () => Get.to(() => SubscriptionScreen()),
        ),
        const SizedBox(height: AppSizes.spaceBtwItems / 2),
        GestureDetector(
          onTap: () => Get.to(() => SubscriptionScreen()),
          child: AppRoundedContainer(
            padding: const EdgeInsets.all(AppSizes.md),
            backgroundColor: dark ? AppColors.darkerGrey : AppColors.light,
            borderColor: dark ? AppColors.darkGrey : AppColors.grey,
            child: Row(
              children: [
                Icon(Icons.lock_rounded, color: AppColors.warning, size: 24),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLocalizations.premiumFeatures,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                      Text(
                        appLocalizations.upgradeToCreate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: dark ? AppColors.darkGrey : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: dark ? AppColors.darkGrey : AppColors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSubscriptionDetails(
    BuildContext context,
    SubscriptionController controller,
    AppLocalizations appLocalizations,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLocalizations.subscriptionDetails),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appLocalizations.youHaveActivePremium),
            if (controller.subscriptionExpiry.value != null) ...[
              SizedBox(height: AppSizes.sm),
              Text(
                '${appLocalizations.expires}: ${_formatDate(controller.subscriptionExpiry.value!)}',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
            SizedBox(height: AppSizes.sm),
            Text(
              appLocalizations.withPremiumYouCan,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: AppSizes.xs),
            _buildFeatureItem(appLocalizations.createUnlimitedPlaces),
            _buildFeatureItem(appLocalizations.accessAdvancedFeatures),
            _buildFeatureItem(appLocalizations.getPrioritySupport),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(appLocalizations.close),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.primaryColor),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}






//-----------------------------
// // widgets/subscription_status_section.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:reviews_app/common/widgets/texts/section_heading.dart';
// import 'package:reviews_app/localization/app_localizations.dart';
// import 'package:reviews_app/utils/constants/colors.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';
// import 'package:reviews_app/utils/helpers/helper_functions.dart';
// import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
// import '../../../controllers/subscription_controller.dart';
// import '../subscription.dart';

// class SubscriptionStatusSection extends StatelessWidget {
//   const SubscriptionStatusSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<SubscriptionController>();
//     final dark = AppHelperFunctions.isDarkMode(context);

//     return Obx(() {
//       if (controller.hasActiveSubscription.value) {
//         return _buildActiveSubscription(context, dark, controller);
//       } else {
//         return _buildUpgradePrompt(context, dark);
//       }
//     });
//   }

//   Widget _buildActiveSubscription(
//     BuildContext context,
//     bool dark,
//     SubscriptionController controller,
//   ) {
//     return Column(
//       children: [
//         AppSectionHeading(
//           // title: 'Subscription Status',
//           title: AppLocalizations.of(context).subscriptionStatus,
//           // buttonTitle: 'Manage',
//           buttonTitle: AppLocalizations.of(context).manage,
//           onPressed: () => _showSubscriptionDetails(context, controller),
//         ),
//         const SizedBox(height: AppSizes.spaceBtwItems / 2),
//         AppRoundedContainer(
//           padding: const EdgeInsets.all(AppSizes.md),
//           backgroundColor: dark ? AppColors.darkerGrey : AppColors.light,
//           borderColor: AppColors.primaryColor,
//           child: Row(
//             children: [
//               Icon(Icons.star_rounded, color: AppColors.primaryColor, size: 24),
//               const SizedBox(width: AppSizes.sm),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       // 'Premium Member',
//                       AppLocalizations.of(context).premiumMember,
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.primaryColor,
//                       ),
//                     ),
//                     if (controller.subscriptionExpiry.value != null) ...[
//                       const SizedBox(height: 2),
//                       Text(
//                         // 'Expires: ${_formatDate(controller.subscriptionExpiry.value!)}',
//                         '${AppLocalizations.of(context).expires}: ${_formatDate(controller.subscriptionExpiry.value!)}',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: dark ? AppColors.darkGrey : AppColors.grey,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: AppSizes.sm,
//                   vertical: AppSizes.xs,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryColor.withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
//                 ),
//                 child: Text(
//                   // 'ACTIVE',
//                   AppLocalizations.of(context).active,
//                   style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                     color: AppColors.primaryColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildUpgradePrompt(BuildContext context, bool dark) {
//     return Column(
//       children: [
//         AppSectionHeading(
//           // title: 'Create Places',
//           title: AppLocalizations.of(context).createPlaces,
//           // buttonTitle: 'Upgrade',
//           buttonTitle: AppLocalizations.of(context).upgrade,
//           onPressed: () => Get.to(() => SubscriptionScreen()),
//         ),
//         const SizedBox(height: AppSizes.spaceBtwItems / 2),
//         GestureDetector(
//           onTap: () => Get.to(() => SubscriptionScreen()),
//           child: AppRoundedContainer(
//             padding: const EdgeInsets.all(AppSizes.md),
//             backgroundColor: dark ? AppColors.darkerGrey : AppColors.light,
//             borderColor: dark ? AppColors.darkGrey : AppColors.grey,
//             child: Row(
//               children: [
//                 Icon(Icons.lock_rounded, color: AppColors.warning, size: 24),
//                 const SizedBox(width: AppSizes.sm),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         // 'Premium Feature',
//                         AppLocalizations.of(context).premiumFeatures,
//                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.warning,
//                         ),
//                       ),
//                       Text(
//                         // 'Upgrade to create unlimited places',
//                         AppLocalizations.of(context).upgradeToCreate,
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: dark ? AppColors.darkGrey : AppColors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Icon(
//                   Icons.arrow_forward_ios_rounded,
//                   size: 16,
//                   color: dark ? AppColors.darkGrey : AppColors.grey,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _showSubscriptionDetails(
//     BuildContext context,
//     SubscriptionController controller,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         // title: Text('Subscription Details'),
//         title: Text(AppLocalizations.of(context).subscriptionStatus),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('You have an active Premium subscription.'),
//             // Text(AppLocalizations.of(context).pre),
//             if (controller.subscriptionExpiry.value != null) ...[
//               SizedBox(height: AppSizes.sm),
//               Text(
//                 '${AppLocalizations.of(context).expires}: ${_formatDate(controller.subscriptionExpiry.value!)}',
//                 style: TextStyle(fontWeight: FontWeight.w500),
//               ),
//             ],
//             SizedBox(height: AppSizes.sm),
//             Text(
//               'With Premium you can:',
//               // AppLocalizations.of(context).withPremiumYouCan,
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//             SizedBox(height: AppSizes.xs),
//             _buildFeatureItem('Create unlimited places'),
//             _buildFeatureItem('Access advanced features'),
//             _buildFeatureItem('Get priority support'),
            
//             // _buildFeatureItem(AppLocalizations.of(context).unlockPremium),
//             // _buildFeatureItem('Access advanced features'),
//             // _buildFeatureItem('Get priority support'),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: Text('Close')),
//           // TextButton(onPressed: () => Get.back(), child: Text(AppLocalizations.of(context).close)),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeatureItem(String text) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           Icon(Icons.check_circle, size: 16, color: AppColors.primaryColor),
//           SizedBox(width: 8),
//           Text(text, style: TextStyle(fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
