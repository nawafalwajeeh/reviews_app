import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../helpers/font_helper.dart';

class AppOutlinedButtonTheme {
  AppOutlinedButtonTheme._();

  ///-- Light OutlinedButton Theme
  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColors.dark,
      side: const BorderSide(color: AppColors.borderPrimary),
      textStyle: TextStyle(
        fontSize: 16,
        color: AppColors.black,
        fontWeight: FontWeight.w600,
        // fontFamily: 'Poppins',
        fontFamily: FontHelper.appFontFamily,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.buttonHeight,
        horizontal: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      ),
    ),
  );

  ///-- Dark OutlinedButton Theme
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: const BorderSide(color: Colors.blueAccent),
      textStyle: TextStyle(
        fontSize: 16,
        color: AppColors.textWhite,
        fontWeight: FontWeight.w600,
        // fontFamily: 'Poppins',
        fontFamily: FontHelper.appFontFamily,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.buttonHeight,
        horizontal: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      ),
    ),
  );
}
