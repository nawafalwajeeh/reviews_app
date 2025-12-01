// utils/helpers/font_helper.dart
import 'package:flutter/material.dart';
import '../../data/services/localization/localization_service.dart';

class FontHelper {
  static String get appFontFamily {
    final localizationService = LocalizationService.instance;
    // return localizationService.currentLanguage == 'ar'
    //     ? 'Tajawal' // Arabic font
    //     : 'Poppins'; // English font (your existing font)
    return localizationService.appFontFamily.value;
  }

  static bool get isArabic =>
      LocalizationService.instance.currentLanguage == 'ar';

  // Helper method to get text style with appropriate font
  static TextStyle getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: appFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // Helper to get optimal font weight for Arabic
  static FontWeight getOptimalFontWeight(FontWeight fontWeight) {
    final isArabic = LocalizationService.instance.currentLanguage == 'ar';

    if (!isArabic) return fontWeight; // Use all weights for English

    // Optimize weights for Arabic readability
    switch (fontWeight) {
      case FontWeight.w100:
      case FontWeight.w200:
      case FontWeight.w300:
        return FontWeight.w300; // Use Light
      case FontWeight.w400:
        return FontWeight.w400; // Use Regular
      case FontWeight.w500:
        return FontWeight.w500; // Use Medium
      case FontWeight.w600:
      case FontWeight.w700:
      case FontWeight.w800:
      case FontWeight.w900:
        return FontWeight.w700; // Use Bold for all heavy weights
      default:
        return FontWeight.w400;
    }
  }
}
