// screens/add_new_place_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../controllers/place_controller.dart';
import '../../controllers/subscription_controller.dart';
import '../subscription/widgets/subscription_status_section.dart';
import 'widgets/add_photo_box.dart';
import 'widgets/custom_questions_section.dart';
import 'widgets/place_form.dart';
import 'widgets/guid_lines_box.dart';

class AddNewPlaceScreen extends StatelessWidget {
  const AddNewPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PlaceController.instance;
    final subscriptionController = SubscriptionController.instance;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          controller.resetForm();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: CustomAppBar(
            leadingIcon: Icons.clear,
            leadingOnPressed: () {
              controller.resetForm();
              Get.back();
            },
            actions: [
              Obx(
                () => subscriptionController.hasActiveSubscription.value
                    ? _buildPremiumBadge()
                    : const SizedBox(),
              ),
              IconButton(
                icon: Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.darkGrey,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.defaultSpace,
              ),
              child: Form(
                key: controller.placeFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    Text(
                      // 'Create New Place',
                      AppLocalizations.of(context).createNewPlace,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      // 'Share your favorite spot with the community',
                      AppLocalizations.of(context).shareFavoriteSpot,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceBtwItems),

                    // Subscription Status Section (REPLACES Payment Section)
                    const SubscriptionStatusSection(),
                    const SizedBox(height: AppSizes.spaceBtwItems),

                    const AddPhotoBox(),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    const PlaceForm(),
                    const SizedBox(height: AppSizes.spaceBtwItems),

                    // Custom Questions Section
                    const CustomQuestionsSection(),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    const CommunityGuidelinesBox(),
                    const SizedBox(height: AppSizes.spaceBtwItems),

                    /// -- Create Button (Now handles subscription check)
                    // _buildCreateButton(controller, subscriptionController),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.createPlace(),
                        // child: const Text('Create Place'),
                        child: Text(
                          AppLocalizations.of(context).createNewPlace,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceBtwSections),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      margin: const EdgeInsets.only(right: AppSizes.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded, size: 14, color: AppColors.primaryColor),
          const SizedBox(width: 4),
          Text(
            // 'PREMIUM',
            AppLocalizations.of(Get.context!).premiumFeature,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(
    PlaceController controller,
    SubscriptionController subscriptionController,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() {
        if (subscriptionController.hasActiveSubscription.value) {
          // User has subscription - show normal create button
          return ElevatedButton(
            onPressed: () => controller.createPlace(),
            // child: const Text('Create Place'),
            child: Text(AppLocalizations.of(Get.context!).createNewPlace),
          );
        } else {
          // User doesn't have subscription - show upgrade button
          return ElevatedButton(
            onPressed: () {
              subscriptionController.showSubscriptionRequired(
                Get.context!,
                // message: 'Create unlimited places with Premium subscription',
                message: AppLocalizations.of(Get.context!).getUnlimitedAccess,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, size: 20),
                SizedBox(width: AppSizes.sm),
                // Text('Upgrade to Create Place'),
                Text(AppLocalizations.of(Get.context!).upgradeToCreate),
              ],
            ),
          );
        }
      }),
    );
  }
}
