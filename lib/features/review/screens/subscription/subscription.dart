import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../controllers/subscription_controller.dart';
import '../../models/subscription_model.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final controller = Get.put(SubscriptionController());
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// App Bar
          SliverAppBar(
            title: Text(
              appLocalizations.placesReviewsPremium,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            leading: IconButton(
              icon: Icon(Icons.close_rounded),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.help_outline_rounded),
                onPressed: () => _showHelpDialog(context, appLocalizations),
              ),
            ],
            floating: true,
            snap: true,
          ),

          /// Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                children: [
                  /// Header Section
                  _buildHeaderSection(context, dark, appLocalizations),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  /// Premium Features Card
                  _buildFeaturesCard(context, dark, appLocalizations),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  /// Subscription Plans
                  _buildSubscriptionPlans(
                    controller,
                    context,
                    dark,
                    appLocalizations,
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  /// Footer
                  _buildFooter(context, dark, appLocalizations),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    bool dark,
    AppLocalizations appLocalizations,
  ) {
    return Column(
      children: [
        Text(
          appLocalizations.unlockPremium,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          appLocalizations.getUnlimitedAccess,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: dark ? AppColors.darkGrey : AppColors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesCard(
    BuildContext context,
    bool dark,
    AppLocalizations appLocalizations,
  ) {
    return AppRoundedContainer(
      padding: const EdgeInsets.all(AppSizes.lg),
      backgroundColor: dark ? AppColors.darkerGrey : AppColors.light,
      borderColor: dark ? AppColors.darkGrey : AppColors.grey,
      child: Column(
        children: [
          /// Header
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: AppColors.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLocalizations.premiumFeatures,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      appLocalizations.everythingYouNeed,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: dark ? AppColors.darkGrey : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          /// Features List
          Column(
            children: [
              _buildFeatureItem(
                context,
                appLocalizations.unlimitedPlaceReviews,
                dark,
              ),
              const SizedBox(height: AppSizes.sm),
              _buildFeatureItem(
                context,
                appLocalizations.advancedSearchFiltering,
                dark,
              ),
              const SizedBox(height: AppSizes.sm),
              _buildFeatureItem(
                context,
                appLocalizations.priorityCustomerSupport,
                dark,
              ),
              const SizedBox(height: AppSizes.sm),
              _buildFeatureItem(
                context,
                appLocalizations.exclusiveInsiderRecommendations,
                dark,
              ),
              const SizedBox(height: AppSizes.sm),
              _buildFeatureItem(
                context,
                appLocalizations.adFreeExperience,
                dark,
              ),
              const SizedBox(height: AppSizes.sm),
              _buildFeatureItem(
                context,
                appLocalizations.earlyAccessNewFeatures,
                dark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text, bool dark) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: AppColors.primaryColor,
          size: 20,
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildSubscriptionPlans(
    SubscriptionController controller,
    BuildContext context,
    bool dark,
    AppLocalizations appLocalizations,
  ) {
    return Obx(
      () => Column(
        children: [
          for (var plan in controller.subscriptionPlans) ...[
            _buildPlanCard(plan, controller, context, dark, appLocalizations),
            const SizedBox(height: AppSizes.md),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    SubscriptionPlan plan,
    SubscriptionController controller,
    BuildContext context,
    bool dark,
    AppLocalizations appLocalizations,
  ) {
    return AppRoundedContainer(
      padding: const EdgeInsets.all(AppSizes.lg),
      backgroundColor: dark ? AppColors.darkerGrey : AppColors.light,
      borderColor: plan.isPopular
          ? AppColors.primaryColor
          : (dark ? AppColors.darkGrey : AppColors.grey),
      child: Column(
        children: [
          /// Plan Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (plan.isPopular) ...[
                          const SizedBox(width: AppSizes.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm,
                              vertical: AppSizes.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(
                                AppSizes.cardRadiusMd,
                              ),
                            ),
                            child: Text(
                              '${appLocalizations.save} ${plan.savingsPercent}%',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      plan.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: dark ? AppColors.darkGrey : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.md),

              /// Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plan.displayPrice,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plan.monthlyEquivalent,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark ? AppColors.darkGrey : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          /// Subscribe Button
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.subscribeToPlan(plan),
                child: controller.isLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        '${appLocalizations.choose} ${plan.name.split(' ').first}',
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    bool dark,
    AppLocalizations appLocalizations,
  ) {
    return Column(
      children: [
        Text(
          appLocalizations.freeTrialFooter,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.sm),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${appLocalizations.bySubscribingAgree} ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark ? AppColors.darkGrey : AppColors.grey,
                ),
              ),
              TextSpan(
                text: appLocalizations.termsOfService,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                recognizer: TapGestureRecognizer()..onTap = () => _openTerms(),
              ),
              TextSpan(
                text: ' ${appLocalizations.and} ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark ? AppColors.darkGrey : AppColors.grey,
                ),
              ),
              TextSpan(
                text: appLocalizations.privacyPolicy,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _openPrivacyPolicy(),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showHelpDialog(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          appLocalizations.needHelp,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          appLocalizations.premiumSubscriptionHelp,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              appLocalizations.gotIt,
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _openTerms() {
    // Implement terms navigation
    print('Open Terms of Service');
  }

  void _openPrivacyPolicy() {
    // Implement privacy policy navigation
    print('Open Privacy Policy');
  }
}

//-----------------------------
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:reviews_app/localization/app_localizations.dart';
// import 'package:reviews_app/utils/constants/colors.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';
// import 'package:reviews_app/utils/helpers/helper_functions.dart';
// import 'package:reviews_app/common/widgets/custom_shapes/containers/rounded_container.dart';
// import '../../controllers/subscription_controller.dart';
// import '../../models/subscription_model.dart';

// class SubscriptionScreen extends StatelessWidget {
//   const SubscriptionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(SubscriptionController());
//     final dark = AppHelperFunctions.isDarkMode(context);

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           /// App Bar
//           SliverAppBar(
//             title: Text(
//               'Places Reviews Premium',
//               // AppLocalizations.of(context).premiumMember,
//               style: Theme.of(
//                 context,
//               ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
//             ),
//             leading: IconButton(
//               icon: Icon(Icons.close_rounded),
//               onPressed: () => Get.back(),
//             ),
//             actions: [
//               IconButton(
//                 icon: Icon(Icons.help_outline_rounded),
//                 onPressed: () => _showHelpDialog(context),
//               ),
//             ],
//             floating: true,
//             snap: true,
//           ),

//           /// Content
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(AppSizes.defaultSpace),
//               child: Column(
//                 children: [
//                   /// Header Section
//                   _buildHeaderSection(context, dark),
//                   const SizedBox(height: AppSizes.spaceBtwSections),

//                   /// Premium Features Card
//                   _buildFeaturesCard(context, dark),
//                   const SizedBox(height: AppSizes.spaceBtwSections),

//                   /// Subscription Plans
//                   _buildSubscriptionPlans(controller, context, dark),
//                   const SizedBox(height: AppSizes.spaceBtwSections),

//                   /// Footer
//                   _buildFooter(context, dark),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeaderSection(BuildContext context, bool dark) {
//     return Column(
//       children: [
//         Text(
//           // 'Unlock Premium',
//           AppLocalizations.of(context).unlockPremium,
//           style: Theme.of(
//             context,
//           ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: AppSizes.sm),
//         Text(
//           // 'Get unlimited access to premium features and discover amazing places like never before',
//           AppLocalizations.of(context).getUnlimitedAccess,
//           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//             color: dark ? AppColors.darkGrey : AppColors.grey,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildFeaturesCard(BuildContext context, bool dark) {
//     return AppRoundedContainer(
//       padding: const EdgeInsets.all(AppSizes.lg),
//       backgroundColor: dark ? AppColors.darkerGrey : AppColors.light,
//       borderColor: dark ? AppColors.darkGrey : AppColors.grey,
//       child: Column(
//         children: [
//           /// Header
//           Row(
//             children: [
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryColor.withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
//                 ),
//                 child: Icon(
//                   Icons.star_rounded,
//                   color: AppColors.primaryColor,
//                   size: 32,
//                 ),
//               ),
//               const SizedBox(width: AppSizes.md),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       // 'Premium Features',
//                       AppLocalizations.of(context).premiumFeatures,
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: AppSizes.xs),
//                     Text(
//                       // 'Everything you need for the perfect review experience',
//                       AppLocalizations.of(context).everythingYouNeed,
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: dark ? AppColors.darkGrey : AppColors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AppSizes.lg),

//           /// Features List
//           Column(
//             children: [
//               _buildFeatureItem(
//                 context,
//                 'Unlimited place reviews & ratings',
//                 // AppLocalizations.of(context).review
//                 dark,
//               ),
//               const SizedBox(height: AppSizes.sm),
//               _buildFeatureItem(context, 'Advanced search & filtering', dark),
//               const SizedBox(height: AppSizes.sm),
//               _buildFeatureItem(context, 'Priority customer support', dark),
//               const SizedBox(height: AppSizes.sm),
//               _buildFeatureItem(
//                 context,
//                 'Exclusive insider recommendations',
//                 dark,
//               ),
//               const SizedBox(height: AppSizes.sm),
//               _buildFeatureItem(context, 'Ad-free experience', dark),
//               const SizedBox(height: AppSizes.sm),
//               _buildFeatureItem(context, 'Early access to new features', dark),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeatureItem(BuildContext context, String text, bool dark) {
//     return Row(
//       children: [
//         Icon(
//           Icons.check_circle_rounded,
//           color: AppColors.primaryColor,
//           size: 20,
//         ),
//         const SizedBox(width: AppSizes.sm),
//         Expanded(
//           child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
//         ),
//       ],
//     );
//   }

//   Widget _buildSubscriptionPlans(
//     SubscriptionController controller,
//     BuildContext context,
//     bool dark,
//   ) {
//     return Obx(
//       () => Column(
//         children: [
//           for (var plan in controller.subscriptionPlans) ...[
//             _buildPlanCard(plan, controller, context, dark),
//             const SizedBox(height: AppSizes.md),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildPlanCard(
//     SubscriptionPlan plan,
//     SubscriptionController controller,
//     BuildContext context,
//     bool dark,
//   ) {
//     return AppRoundedContainer(
//       padding: const EdgeInsets.all(AppSizes.lg),
//       backgroundColor: dark ? AppColors.darkerGrey : AppColors.light,
//       borderColor: plan.isPopular
//           ? AppColors.primaryColor
//           : (dark ? AppColors.darkGrey : AppColors.grey),
//       // borderWidth: plan.isPopular ? 2 : 1,
//       child: Column(
//         children: [
//           /// Plan Header
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             plan.name,
//                             style: Theme.of(context).textTheme.titleLarge
//                                 ?.copyWith(fontWeight: FontWeight.w600),
//                           ),
//                         ),
//                         if (plan.isPopular) ...[
//                           const SizedBox(width: AppSizes.sm),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: AppSizes.sm,
//                               vertical: AppSizes.xs,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColors.primaryColor,
//                               borderRadius: BorderRadius.circular(
//                                 AppSizes.cardRadiusMd,
//                               ),
//                             ),
//                             child: Text(
//                               'SAVE ${plan.savingsPercent}%',
//                               style: Theme.of(context).textTheme.labelSmall
//                                   ?.copyWith(
//                                     color: AppColors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                     const SizedBox(height: AppSizes.xs),
//                     Text(
//                       plan.description,
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: dark ? AppColors.darkGrey : AppColors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: AppSizes.md),

//               /// Price
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     plan.displayPrice,
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primaryColor,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     plan.monthlyEquivalent,
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: dark ? AppColors.darkGrey : AppColors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: AppSizes.lg),

//           /// Subscribe Button
//           Obx(
//             () => SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: controller.isLoading.value
//                     ? null
//                     : () => controller.subscribeToPlan(plan),
//                 child: controller.isLoading.value
//                     ? SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: AppColors.white,
//                         ),
//                       )
//                     : Text('Choose ${plan.name.split(' ').first}'),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFooter(BuildContext context, bool dark) {
//     return Column(
//       children: [
//         Text(
//           '✨ 7-day free trial • Cancel anytime • No hidden fees',
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//             color: AppColors.primaryColor,
//             fontWeight: FontWeight.w500,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: AppSizes.sm),
//         RichText(
//           text: TextSpan(
//             children: [
//               TextSpan(
//                 text: 'By subscribing, you agree to our ',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: dark ? AppColors.darkGrey : AppColors.grey,
//                 ),
//               ),
//               TextSpan(
//                 text: 'Terms of Service',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: AppColors.primaryColor,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 recognizer: TapGestureRecognizer()..onTap = () => _openTerms(),
//               ),
//               TextSpan(
//                 text: ' and ',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: dark ? AppColors.darkGrey : AppColors.grey,
//                 ),
//               ),
//               TextSpan(
//                 text: 'Privacy Policy',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: AppColors.primaryColor,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 recognizer: TapGestureRecognizer()
//                   ..onTap = () => _openPrivacyPolicy(),
//               ),
//             ],
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   void _showHelpDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(
//           'Need Help?',
//           style: Theme.of(context).textTheme.headlineSmall,
//         ),
//         content: Text(
//           'Our premium subscription gives you unlimited access to all features. '
//           'You can cancel anytime during your free trial without being charged.',
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text(
//               'Got it',
//               style: TextStyle(color: AppColors.primaryColor),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _openTerms() {
//     // Implement terms navigation
//     print('Open Terms of Service');
//   }

//   void _openPrivacyPolicy() {
//     // Implement privacy policy navigation
//     print('Open Privacy Policy');
//   }
// }
