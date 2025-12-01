import 'package:flutter/material.dart';
import 'package:reviews_app/data/services/localization/localization_service.dart';
import 'package:reviews_app/features/authentication/controllers/on_boarding/onboarding_controller.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/device/device_utility.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    final dark = AppHelperFunctions.isDarkMode(context);
    final localizationService = LocalizationService.instance;
    final isArabic = localizationService.isRTL();

    return Positioned(
      bottom: AppDeviceUtils.getBottomNavigationBarHeight() + 25,
      left: isArabic ? null : AppSizes.defaultSpace,
      right: isArabic ? AppSizes.defaultSpace : null,

      child: SmoothPageIndicator(
        controller: controller.pageController,
        count: 3,
        onDotClicked: controller.doNavigationClick,
        effect: ExpandingDotsEffect(
          activeDotColor: dark ? AppColors.light : AppColors.dark,
          dotHeight: 6,
        ),
      ),
    );
  }
}
// class OnBoardingDotNavigation extends StatelessWidget {
//   const OnBoardingDotNavigation({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = OnBoardingController.instance;
//     final dark = AppHelperFunctions.isDarkMode(context);

//     return Positioned(
//       bottom: AppDeviceUtils.getBottomNavigationBarHeight() + 25,
//       left: AppSizes.defaultSpace,

//       child: SmoothPageIndicator(
//         controller: controller.pageController,
//         count: 3,
//         onDotClicked: controller.doNavigationClick,
//         effect: ExpandingDotsEffect(
//           activeDotColor: dark ? AppColors.light : AppColors.dark,
//           dotHeight: 6,
//         ),
//       ),
//     );
//   }
// }
