import 'package:flutter/material.dart';
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

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Positioned(
        bottom: AppDeviceUtils.getBottomNavigationBarHeight() + 25,
        left: AppSizes.defaultSpace,

        child: SmoothPageIndicator(
          controller: controller.pageController,
          count: 3,
          onDotClicked: controller.doNavigationClick,
          effect: ExpandingDotsEffect(
            activeDotColor: dark ? AppColors.light : AppColors.dark,
            dotHeight: 6,
          ),
        ),
      ),
    );
  }
}
