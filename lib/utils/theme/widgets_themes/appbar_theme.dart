import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../helpers/font_helper.dart';

class CustomAppBarTheme {
  CustomAppBarTheme._();

  ///-- Light AppBar Theme
  static final lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: const IconThemeData(
      color: AppColors.black,
      size: AppSizes.iconMd,
    ),
    actionsIconTheme: const IconThemeData(
      color: AppColors.black,
      size: AppSizes.iconMd,
    ),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
      // fontFamily: 'Poppins',
      fontFamily: FontHelper.appFontFamily,
    ),
  );

  ///-- Dark AppBar Theme
  static final darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: AppColors.black, size: AppSizes.iconMd),
    actionsIconTheme: IconThemeData(
      color: AppColors.white,
      size: AppSizes.iconMd,
    ),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      // fontFamily: 'Poppins',
      fontFamily: FontHelper.appFontFamily,
    ),
  );
}
