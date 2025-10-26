import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AppChipTheme {
  AppChipTheme._();

  ///-- Light ChipTheme
  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: AppColors.grey.withValues(alpha: 0.4),
    labelStyle: const TextStyle(color: AppColors.black, fontFamily: 'Poppins'),
    selectedColor: AppColors.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: AppColors.white,
  );

  ///-- Dark ChipTheme
  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: AppColors.darkerGrey,
    labelStyle: const TextStyle(color: AppColors.white, fontFamily: 'Poppins'),
    selectedColor: AppColors.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: AppColors.white,
  );
}
