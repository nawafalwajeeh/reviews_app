import 'package:flutter/material.dart';
import 'package:reviews_app/utils/helpers/font_helper.dart';
import '../../constants/colors.dart';

class AppChipTheme {
  AppChipTheme._();

  ///-- Light ChipTheme
  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: AppColors.grey.withValues(alpha: 0.4),
    // labelStyle: const TextStyle(color: AppColors.black, fontFamily: 'Poppins'),
    labelStyle: TextStyle(
      color: AppColors.black,
      fontFamily: FontHelper.appFontFamily,
    ),
    selectedColor: AppColors.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: AppColors.white,
  );

  ///-- Dark ChipTheme
  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: AppColors.darkerGrey,
    // labelStyle: const TextStyle(color: AppColors.white, fontFamily: 'Poppins'),
    labelStyle: TextStyle(
      color: AppColors.white,
      fontFamily: FontHelper.appFontFamily,
    ),
    selectedColor: AppColors.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: AppColors.white,
  );
}
