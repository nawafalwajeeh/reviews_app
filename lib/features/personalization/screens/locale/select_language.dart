import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/data/services/localization/localization_service.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../authentication/screens/login/login.dart';
import '../../../authentication/screens/onboarding/onboarding.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  final LocalizationService _localizationService = LocalizationService.instance;
  final GetStorage _storage = GetStorage();
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _localizationService.currentLanguage;
  }

  void _onLanguageSelected(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  void _onContinuePressed() async {
    // Save language selection
    await _localizationService.changeLanguage(_selectedLanguage);

    // Mark language as selected
    _storage.write('hasSelectedLanguage', true);

    // Navigate to next screen based on whether it's first time
    final bool isFirstTime = _storage.read('IsFirstTime') == true;

    if (isFirstTime) {
      Get.offAll(() => const OnBoardingScreen());
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? AppColors.dark : AppColors.light,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIconSection(dark),
                const SizedBox(height: 40),
                _buildTitleSection(appLocalizations, dark),
                const SizedBox(height: 12),
                _buildSubtitleSection(appLocalizations, dark),
                const SizedBox(height: 48),
                _buildLanguageList(dark),
                const SizedBox(height: 48),
                _buildContinueButton(appLocalizations),
                // Add extra space at bottom for small screens
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSection(bool dark) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: AppColors.primaryColor,
            offset: const Offset(0, 8),
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.language, color: AppColors.white, size: 48),
    );
  }

  Widget _buildTitleSection(AppLocalizations appLocalizations, bool dark) {
    return Text(
      appLocalizations.chooseLanguage,
      // 'Choose Language',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: dark ? AppColors.white : AppColors.dark,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubtitleSection(AppLocalizations appLocalizations, bool dark) {
    return Text(
      appLocalizations.selectPreferredLanguage,
      // 'Select Preferred Language',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: dark ? AppColors.lightGrey : AppColors.darkGrey,
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  Widget _buildLanguageList(bool dark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _localizationService.supportedLanguages.entries.map((entry) {
        final languageCode = entry.key;
        final languageName = entry.value;
        final isSelected = _selectedLanguage == languageCode;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildLanguageItem(
            code: languageCode,
            name: languageName,
            isSelected: isSelected,
            dark: dark,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageItem({
    required String code,
    required String name,
    required bool isSelected,
    required bool dark,
  }) {
    return GestureDetector(
      onTap: () => _onLanguageSelected(code),
      child: Container(
        width: double.infinity,
        height: 86,
        decoration: BoxDecoration(
          color: dark ? AppColors.darkerGrey : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : (dark ? AppColors.darkGrey : AppColors.grey),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    blurRadius: 12,
                    color: AppColors.primaryColor,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Language Icon/Flag
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          code == 'ar' ? 'ع' : 'EN',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            // fontFamily: FontHelper.appFontFamily,
                            fontFamily: code == 'ar' ? 'Tajawal' : 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Language Details
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: dark ? AppColors.white : AppColors.dark,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: code == 'ar' ? 'Tajawal' : 'Poppins',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            code == 'ar' ? 'Arabic' : 'English',
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : (dark
                                        ? AppColors.lightGrey
                                        : AppColors.darkGrey),
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Selection Indicator
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected
                    ? AppColors.primaryColor
                    : (dark ? AppColors.darkGrey : AppColors.grey),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get localized text based on selected language
  String _getLocalizedText(String key) {
    // Create a temporary locale to get the text
    final tempLocale = Locale(_selectedLanguage);
    final tempAppLocalizations = AppLocalizations(tempLocale);

    switch (key) {
      case 'chooseLanguage':
        return tempAppLocalizations.chooseLanguage;
      case 'selectPreferredLanguage':
        return tempAppLocalizations.selectPreferredLanguage;
      case 'continue':
        return tempAppLocalizations.continueText;
      default:
        return key;
    }
  }

  Widget _buildContinueButton(AppLocalizations appLocalizations) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _onContinuePressed,

        child: Text(
          appLocalizations.continueText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

//-------------------------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:reviews_app/localization/app_localizations.dart';
// import 'package:reviews_app/data/services/localization/localization_service.dart';
// import '../../../../utils/constants/colors.dart';
// import '../../../../utils/helpers/helper_functions.dart';
// import '../../../authentication/screens/login/login.dart';
// import '../../../authentication/screens/onboarding/onboarding.dart';

// class SelectLanguageScreen extends StatefulWidget {
//   const SelectLanguageScreen({super.key});

//   @override
//   State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
// }

// class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
//   final LocalizationService _localizationService = LocalizationService.instance;
//   final GetStorage _storage = GetStorage();
//   late String _selectedLanguage;

//   @override
//   void initState() {
//     super.initState();
//     // Start with Arabic as default
//     _selectedLanguage = 'ar'; // Arabic as default
//   }

//   void _onLanguageSelected(String languageCode) {
//     setState(() {
//       _selectedLanguage = languageCode;
//     });

//     // Immediately update the app language when user selects
//     _localizationService.changeLanguage(languageCode);
//   }

//   void _onContinuePressed() async {
//     // Language is already saved when selected, just mark as selected
//     _storage.write('hasSelectedLanguage', true);

//     // Navigate to next screen based on whether it's first time
//     final bool isFirstTime = _storage.read('IsFirstTime') == true;

//     if (isFirstTime) {
//       Get.offAll(() => const OnBoardingScreen());
//     } else {
//       Get.offAll(() => const LoginScreen());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dark = AppHelperFunctions.isDarkMode(context);
//     final isRTL = _selectedLanguage == 'ar';

//     return Scaffold(
//       backgroundColor: dark ? AppColors.dark : AppColors.light,
//       body: SafeArea(
//         child: Directionality(
//           textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
//           child: SingleChildScrollView(
//             child: Container(
//               width: double.infinity,
//               constraints: BoxConstraints(
//                 minHeight:
//                     MediaQuery.of(context).size.height -
//                     MediaQuery.of(context).padding.top -
//                     MediaQuery.of(context).padding.bottom,
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildIconSection(dark),
//                   const SizedBox(height: 40),
//                   _buildTitleSection(dark),
//                   const SizedBox(height: 12),
//                   _buildSubtitleSection(dark),
//                   const SizedBox(height: 48),
//                   _buildLanguageList(dark),
//                   const SizedBox(height: 48),
//                   _buildContinueButton(),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildIconSection(bool dark) {
//     return Container(
//       width: 120,
//       height: 120,
//       decoration: BoxDecoration(
//         color: AppColors.primaryColor,
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 20,
//             color: AppColors.primaryColor.withValues(alpha: 0.3),
//             offset: const Offset(0, 8),
//           ),
//         ],
//         shape: BoxShape.circle,
//       ),
//       child: Icon(Icons.language, color: AppColors.white, size: 48),
//     );
//   }

//   Widget _buildTitleSection(bool dark) {
//     return Text(
//       _getLocalizedText('chooseLanguage'),
//       textAlign: TextAlign.center,
//       style: TextStyle(
//         color: dark ? AppColors.white : AppColors.dark,
//         fontSize: 32,
//         fontWeight: FontWeight.bold,
//         fontFamily: _selectedLanguage == 'ar' ? 'Tajawal' : 'Poppins',
//       ),
//     );
//   }

//   Widget _buildSubtitleSection(bool dark) {
//     return Text(
//       _getLocalizedText('selectPreferredLanguage'),
//       textAlign: TextAlign.center,
//       style: TextStyle(
//         color: dark ? AppColors.lightGrey : AppColors.darkGrey,
//         fontSize: 16,
//         height: 1.5,
//         fontFamily: _selectedLanguage == 'ar' ? 'Tajawal' : 'Poppins',
//       ),
//     );
//   }

//   Widget _buildLanguageList(bool dark) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: _localizationService.supportedLanguages.entries.map((entry) {
//         final languageCode = entry.key;
//         final languageName = entry.value;
//         final isSelected = _selectedLanguage == languageCode;

//         return Padding(
//           padding: const EdgeInsets.only(bottom: 16),
//           child: _buildLanguageItem(
//             code: languageCode,
//             name: languageName,
//             isSelected: isSelected,
//             dark: dark,
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildLanguageItem({
//     required String code,
//     required String name,
//     required bool isSelected,
//     required bool dark,
//   }) {
//     final isRTL = code == 'ar';

//     return GestureDetector(
//       onTap: () => _onLanguageSelected(code),
//       child: Container(
//         width: double.infinity,
//         height: 80,
//         decoration: BoxDecoration(
//           color: dark ? AppColors.darkerGrey : AppColors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: isSelected
//                 ? AppColors.primaryColor
//                 : (dark ? AppColors.darkGrey : AppColors.grey),
//             width: isSelected ? 2 : 1,
//           ),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     blurRadius: 12,
//                     color: AppColors.primaryColor.withValues(alpha: 0.2),
//                     offset: const Offset(0, 4),
//                   ),
//                 ]
//               : [
//                   BoxShadow(
//                     blurRadius: 4,
//                     color: Colors.black.withValues(alpha: 0.05),
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Row(
//                   children: [
//                     // Language Icon/Flag
//                     Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryColor,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Center(
//                         child: Text(
//                           code == 'ar' ? 'ع' : 'EN',
//                           style: TextStyle(
//                             color: AppColors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                             fontFamily: code == 'ar' ? 'Tajawal' : 'Poppins',
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),

//                     // Language Details
//                     Expanded(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: isRTL
//                             ? CrossAxisAlignment.end
//                             : CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             name,
//                             style: TextStyle(
//                               color: dark ? AppColors.white : AppColors.dark,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               fontFamily: code == 'ar' ? 'Tajawal' : 'Poppins',
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                             textAlign: isRTL ? TextAlign.right : TextAlign.left,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             _getLanguageSubtitle(code),
//                             style: TextStyle(
//                               color: isSelected
//                                   ? AppColors.primaryColor
//                                   : (dark
//                                         ? AppColors.lightGrey
//                                         : AppColors.darkGrey),
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                               fontFamily: code == 'ar' ? 'Tajawal' : 'Poppins',
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                             textAlign: isRTL ? TextAlign.right : TextAlign.left,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Selection Indicator
//               Icon(
//                 isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
//                 color: isSelected
//                     ? AppColors.primaryColor
//                     : (dark ? AppColors.darkGrey : AppColors.grey),
//                 size: 24,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildContinueButton() {
//     final isRTL = _selectedLanguage == 'ar';

//     return SizedBox(
//       width: double.infinity,
//       // height: 56,
//       child: ElevatedButton(
//         onPressed: _onContinuePressed,
//         child: Text(
//           _getLocalizedText('continue'),
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             fontFamily: isRTL ? 'Tajawal' : 'Poppins',
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper method to get localized text based on selected language
//   String _getLocalizedText(String key) {
//     // Create a temporary locale to get the text
//     final tempLocale = Locale(_selectedLanguage);
//     final tempAppLocalizations = AppLocalizations(tempLocale);

//     switch (key) {
//       case 'chooseLanguage':
//         return tempAppLocalizations.chooseLanguage;
//       case 'selectPreferredLanguage':
//         return tempAppLocalizations.selectPreferredLanguage;
//       case 'continue':
//         return tempAppLocalizations.continueText;
//       default:
//         return key;
//     }
//   }

//   // Helper method to get language subtitle in the selected language
//   String _getLanguageSubtitle(String languageCode) {
//     final tempLocale = Locale(_selectedLanguage);
//     final _ = AppLocalizations(tempLocale);

//     if (languageCode == 'ar') {
//       return _selectedLanguage == 'ar' ? 'العربية' : 'Arabic';
//     } else {
//       return _selectedLanguage == 'ar' ? 'الإنجليزية' : 'English';
//     }
//   }
// }
