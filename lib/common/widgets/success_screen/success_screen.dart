import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:reviews_app/common/styles/spacing_styles.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/constants/text_strings.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    this.onPressed,
  });

  final String image, title, subTitle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyles.paddingWithAppBarHeight,

          child: Column(
            children: [
              /// static Image
              // Image(
              //   image: AssetImage(image),
              //   width: AppHelperFunctions.screenWidth() * 0.6,
              // ),
              /// Animation
              Lottie.asset(
                image,
                width: AppHelperFunctions.screenWidth() * 0.6,
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              /// Title & Subtitle
              Text(
                // AppTexts.yourAccountCreatedTitle,
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),

              Text(
                // AppTexts.yourAccountCreatedSubTitle,
                subTitle,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              /// Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  child: const Text(AppTexts.tContinue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
