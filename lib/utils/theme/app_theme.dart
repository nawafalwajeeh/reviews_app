import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/theme/widgets_themes/appbar_theme.dart';
import 'package:reviews_app/utils/theme/widgets_themes/app_bottom_sheet_theme.dart';
import 'package:reviews_app/utils/theme/widgets_themes/app_checkbox_theme.dart';
import 'package:reviews_app/utils/theme/widgets_themes/app_chip_theme.dart';
import 'package:reviews_app/utils/theme/widgets_themes/app_elevated_button_theme.dart';
import 'package:reviews_app/utils/theme/widgets_themes/app_outlined_button_theme.dart';
import 'package:reviews_app/utils/theme/widgets_themes/app_text_field_theme.dart';
import 'package:reviews_app/utils/theme/widgets_themes/app_text_theme.dart';

import '../helpers/font_helper.dart';

class AppTheme {
  AppTheme._();

  ///-- Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    // fontFamily: 'Poppins',
    fontFamily: FontHelper.appFontFamily,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.white,
    textTheme: AppTextTheme.lightTextTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: AppOutlinedButtonTheme.lightOutlinedButtonTheme,
    appBarTheme: CustomAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: AppBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme: AppCheckboxTheme.lightCheckboxTheme,
    inputDecorationTheme: AppTextFieldTheme.lightTextFieldTheme,
    chipTheme: AppChipTheme.lightChipTheme,
  );

  ///-- Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    // fontFamily: 'Poppins',
    fontFamily: FontHelper.appFontFamily,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.black,
    textTheme: AppTextTheme.darkTextTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: AppOutlinedButtonTheme.darkOutlinedButtonTheme,
    appBarTheme: CustomAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: AppBottomSheetTheme.darkBottomSheetTheme,
    checkboxTheme: AppCheckboxTheme.darkCheckboxTheme,
    inputDecorationTheme: AppTextFieldTheme.darkTextFieldTheme,
    chipTheme: AppChipTheme.darkChipTheme,
  );
}
