import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/screens/place/add_new_place.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../../../../localization/app_localizations.dart';

class BusinessCard extends StatelessWidget {
  const BusinessCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),

      child: Container(
        width: double.infinity,
        height: 204,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: AppColors.businessStartColor.withValues(alpha: 0.2),
              offset: const Offset(0, 10),
            ),
          ],

          /// -- Define the gradient
          gradient: const LinearGradient(
            // colors: [AppColors.businessStartColor, AppColors.businessEndColor],
            colors: [Color(0xFFB0E0FF), Color(0xFF5D6EA0)],
            stops: [0, 1],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// -- Title
                    Text(
                      // 'List Your Business',
                      AppLocalizations.of(context).listYourBusiness,
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    /// -- Subtitle & Description
                    Expanded(
                      child: Opacity(
                        opacity: 0.9,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: AppSizes.sm,
                            bottom: AppSizes.spaceBtwItems,
                          ),
                          child: Text(
                            // 'Get discovered by millions of customers and grow your business',
                            AppLocalizations.of(context).getDiscoveredByMillions,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: AppColors.white.withValues(
                                    alpha: 0.9,
                                  ), // Match opacity from parent
                                ),
                          ),
                        ),
                      ),
                    ),

                    /// Button
                    ElevatedButton(
                      onPressed: () => Get.to(() => AddNewPlaceScreen()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primaryColor,
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.defaultSpace,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.cardRadiusMd,
                          ),
                        ),
                      ),
                      child: Text(
                        // 'Get Started',
                        AppLocalizations.of(context).getStarted,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              /// -- Icon
              Opacity(
                opacity: 0.3,
                child: const Icon(
                  Icons.business_rounded,
                  color: AppColors.white,
                  size: 80,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
