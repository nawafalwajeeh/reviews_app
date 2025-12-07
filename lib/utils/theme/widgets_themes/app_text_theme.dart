import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../helpers/font_helper.dart';

class AppTextTheme {
  AppTextTheme._();

  ///-- Light Text Theme
  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: AppColors.dark,
      fontFamily: FontHelper.appFontFamily,
    ),
    headlineMedium: const TextStyle().copyWith(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      // color: AppColors.dark,
      fontFamily: FontHelper.appFontFamily,
    ),
    headlineSmall: const TextStyle().copyWith(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AppColors.dark,
      fontFamily: FontHelper.appFontFamily,
    ),

    titleLarge: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: AppColors.dark,
      fontFamily: FontHelper.appFontFamily,
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: AppColors.dark,
      fontFamily: FontHelper.appFontFamily,
    ),
    titleSmall: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      color: AppColors.dark,
      fontFamily: FontHelper.appFontFamily,
    ),

    bodyLarge: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: AppColors.dark,
      fontFamily: FontHelper.appFontFamily,
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: AppColors.dark,
      fontFamily: FontHelper.appFontFamily,
    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: AppColors.dark.withValues(alpha: 0.5),
      fontFamily: FontHelper.appFontFamily,
    ),

    labelLarge: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: AppColors.dark,
      fontFamily: FontHelper.appFontFamily,
    ),
    labelMedium: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: AppColors.dark.withValues(alpha: 0.5),
      fontFamily: FontHelper.appFontFamily,
    ),
  );

  ///-- Dark Text Theme
  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: AppColors.light,
      fontFamily: FontHelper.appFontFamily,
    ),
    headlineMedium: const TextStyle().copyWith(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: AppColors.light,
      fontFamily: FontHelper.appFontFamily,
    ),
    headlineSmall: const TextStyle().copyWith(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AppColors.light,
      fontFamily: FontHelper.appFontFamily,
    ),

    titleLarge: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: AppColors.light,
      fontFamily: FontHelper.appFontFamily,
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: AppColors.light,
      fontFamily: FontHelper.appFontFamily,
    ),
    titleSmall: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      color: AppColors.light,
      fontFamily: FontHelper.appFontFamily,
    ),

    bodyLarge: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: AppColors.light,
      fontFamily: FontHelper.appFontFamily,
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: AppColors.light,
      fontFamily: FontHelper.appFontFamily,
    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: AppColors.light.withValues(alpha: 0.5),
      fontFamily: FontHelper.appFontFamily,
    ),

    labelLarge: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: AppColors.light,
      fontFamily: FontHelper.appFontFamily,
    ),
    labelMedium: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: AppColors.light.withValues(alpha: 0.5),
      fontFamily: FontHelper.appFontFamily,
    ),
  );
}
