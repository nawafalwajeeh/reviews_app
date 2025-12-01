import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/data/services/localization/localization_service.dart';
import 'package:reviews_app/features/authentication/controllers/on_boarding/onboarding_controller.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/device/device_utility.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final localizationService = LocalizationService.instance;
    final isArabic = localizationService.isRTL();

    return Positioned(
      right: isArabic ? null : AppSizes.defaultSpace,
      left: isArabic ? AppSizes.defaultSpace : null,
      bottom: AppDeviceUtils.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        onPressed: () => OnBoardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: dark ? AppColors.primaryColor : AppColors.dark,
        ),
        // child: const Icon(Iconsax.arrow_right_3),
        child: isArabic
            ? Icon(Icons.arrow_forward_ios)
            : Icon(Iconsax.arrow_right_3),
      ),
    );
  }
}
// class OnBoardingNextButton extends StatelessWidget {
//   const OnBoardingNextButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final dark = AppHelperFunctions.isDarkMode(context);

//     return Positioned(
//       right:  AppSizes.defaultSpace,
//       bottom: AppDeviceUtils.getBottomNavigationBarHeight(),
//       child: ElevatedButton(
//         onPressed: () => OnBoardingController.instance.nextPage(),
//         style: ElevatedButton.styleFrom(
//           shape: const CircleBorder(),
//           backgroundColor: dark ? AppColors.primaryColor : AppColors.dark,
//         ),
//         child: const Icon(Iconsax.arrow_right_3),
//       ),
//     );
//   }
// }
