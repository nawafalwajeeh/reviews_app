import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../constants/colors.dart';
import '../../helpers/font_helper.dart';

class AppElevatedButtonTheme {
  AppElevatedButtonTheme._();

  ///-- Light Elevated Button Theme
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColors.light,
      backgroundColor: AppColors.primaryColor,
      disabledForegroundColor: AppColors.darkGrey,
      disabledBackgroundColor: AppColors.buttonDisabled,
      side: const BorderSide(color: AppColors.primaryColor),
      padding: const EdgeInsets.symmetric(vertical: AppSizes.buttonHeight),
      textStyle: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w600,
        // fontFamily: 'Poppins',
        fontFamily: FontHelper.appFontFamily,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      ),
    ),
  );

  ///-- Dark Elevated Button Theme
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColors.light,
      backgroundColor: AppColors.primaryColor,
      disabledForegroundColor: AppColors.darkGrey,
      disabledBackgroundColor: AppColors.darkerGrey,
      side: const BorderSide(color: AppColors.primaryColor),
      padding: const EdgeInsets.symmetric(vertical: AppSizes.buttonHeight),
      textStyle: TextStyle(
        fontSize: 16,
        color: AppColors.textWhite,
        fontWeight: FontWeight.w600,
        // fontFamily: 'Poppins',
        fontFamily: FontHelper.appFontFamily,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      ),
    ),
  );
}
