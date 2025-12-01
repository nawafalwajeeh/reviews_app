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
  bool _isLoading = true;

  // Cache for localized texts based on selected language
  Map<String, String> _localizedTexts = {};

  @override
  void initState() {
    super.initState();
    _initializeLanguage();
  }

  void _initializeLanguage() {
    // IMPORTANT: Start with Arabic as default, NOT from service
    _selectedLanguage = 'ar'; // Force Arabic as default

    // Load localized texts for Arabic immediately
    _loadInitialArabicTexts();
  }

  void _loadInitialArabicTexts() {
    // Create Arabic locale and load texts
    final arabicLocale = Locale('ar');
    final arabicLocalizations = AppLocalizations(arabicLocale);

    // Load Arabic texts
    arabicLocalizations
        .load()
        .then((_) {
          setState(() {
            _localizedTexts = {
              'chooseLanguage': arabicLocalizations.chooseLanguage,
              'selectPreferredLanguage':
                  arabicLocalizations.selectPreferredLanguage,
              'continue': arabicLocalizations.continueText,
              'english': arabicLocalizations.english,
              'arabic': arabicLocalizations.arabic,
            };
            _isLoading = false;
          });
        })
        .catchError((error) {
          // Fallback to hardcoded Arabic texts if loading fails
          setState(() {
            _localizedTexts = {
              'chooseLanguage': 'اختر اللغة',
              'selectPreferredLanguage': 'اختر لغتك المفضلة للمتابعة',
              'continue': 'متابعة',
              'english': 'الإنجليزية',
              'arabic': 'العربية',
            };
            _isLoading = false;
          });
        });
  }

  Future<void> _updateLocalizedTexts(String languageCode) async {
    final tempLocale = Locale(languageCode);
    final tempLocalizations = AppLocalizations(tempLocale);

    await tempLocalizations.load();

    setState(() {
      _localizedTexts = {
        'chooseLanguage': tempLocalizations.chooseLanguage,
        'selectPreferredLanguage': tempLocalizations.selectPreferredLanguage,
        'continue': tempLocalizations.continueText,
        'english': tempLocalizations.english,
        'arabic': tempLocalizations.arabic,
      };
    });
  }

  void _onLanguageSelected(String languageCode) async {
    if (languageCode == _selectedLanguage) return;

    setState(() {
      _selectedLanguage = languageCode;
    });

    // Update texts for the new language
    await _updateLocalizedTexts(languageCode);
  }

  Future<void> _onContinuePressed() async {
    // Save language selection to service
    await _localizationService.changeLanguage(_selectedLanguage);

    // Mark language as selected in storage
    await _storage.write('hasSelectedLanguage', true);

    // Check if it's first time
    final bool isFirstTime = _storage.read('IsFirstTime') != false;

    if (isFirstTime) {
      Get.offAll(() => const OnBoardingScreen());
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppHelperFunctions.isDarkMode(context)
            ? AppColors.dark
            : AppColors.light,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Always check if selected language is Arabic for RTL
    final bool isArabic = _selectedLanguage == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppHelperFunctions.isDarkMode(context)
            ? AppColors.dark
            : AppColors.light,
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
                  _buildIconSection(),
                  const SizedBox(height: 40),
                  _buildTitleSection(),
                  const SizedBox(height: 12),
                  _buildSubtitleSection(),
                  const SizedBox(height: 48),
                  _buildLanguageList(),
                  const SizedBox(height: 48),
                  _buildContinueButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSection() {
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

  Widget _buildTitleSection() {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Text(
      _localizedTexts['chooseLanguage'] ?? 'اختر اللغة',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: dark ? AppColors.white : AppColors.dark,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: _selectedLanguage == 'ar' ? 'Tajawal' : 'Poppins',
      ),
    );
  }

  Widget _buildSubtitleSection() {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Text(
      _localizedTexts['selectPreferredLanguage'] ??
          'اختر لغتك المفضلة للمتابعة',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: dark ? AppColors.lightGrey : AppColors.darkGrey,
        fontSize: 16,
        height: 1.5,
        fontFamily: _selectedLanguage == 'ar' ? 'Tajawal' : 'Poppins',
      ),
    );
  }

  Widget _buildLanguageList() {
    final dark = AppHelperFunctions.isDarkMode(context);

    // Create language list - Arabic first since it's default
    final languages = [
      {
        'code': 'ar',
        'display': _localizedTexts['arabic'] ?? 'العربية',
        'native': 'العربية',
      },
      {
        'code': 'en',
        'display': _localizedTexts['english'] ?? 'English',
        'native': 'English',
      },
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: languages.map((lang) {
        final languageCode = lang['code']!;
        final isSelected = _selectedLanguage == languageCode;
        final displayName = lang['display']!;
        final nativeName = lang['native']!;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildLanguageItem(
            code: languageCode,
            displayName: displayName,
            nativeName: nativeName,
            isSelected: isSelected,
            dark: dark,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageItem({
    required String code,
    required String displayName,
    required String nativeName,
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
                    color: Colors.black.withOpacity(0.05),
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
                            displayName,
                            style: TextStyle(
                              color: dark ? AppColors.white : AppColors.dark,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: _selectedLanguage == 'ar'
                                  ? 'Tajawal'
                                  : 'Poppins',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nativeName,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : (dark
                                        ? AppColors.lightGrey
                                        : AppColors.darkGrey),
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              fontFamily: code == 'ar' ? 'Tajawal' : 'Poppins',
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

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _onContinuePressed,
        child: Text(
          _localizedTexts['continue'] ?? 'متابعة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: _selectedLanguage == 'ar' ? 'Tajawal' : 'Poppins',
          ),
        ),
      ),
    );
  }
}






















//------------------------------------
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

//   // Cache for localized texts based on selected language
//   Map<String, String> _localizedTexts = {};

//   @override
//   void initState() {
//     super.initState();
//     _selectedLanguage = _localizationService.currentLanguage;
//     _updateLocalizedTexts();
//   }

//   void _onLanguageSelected(String languageCode) {
//     setState(() {
//       _selectedLanguage = languageCode;
//       _updateLocalizedTexts();
//     });
//   }

//   void _updateLocalizedTexts() {
//     // Create a temporary AppLocalizations instance with the selected language
//     final tempLocale = Locale(_selectedLanguage);
//     final tempLocalizations = AppLocalizations(tempLocale);

//     // Load the localization data for the selected language
//     tempLocalizations.load().then((_) {
//       setState(() {
//         _localizedTexts = {
//           'chooseLanguage': tempLocalizations.chooseLanguage,
//           'selectPreferredLanguage': tempLocalizations.selectPreferredLanguage,
//           'continue': tempLocalizations.continueText,
//           'english': tempLocalizations.english,
//           'arabic': tempLocalizations.arabic,
//         };
//       });
//     });
//   }

//   void _onContinuePressed() async {
//     // Save language selection
//     await _localizationService.changeLanguage(_selectedLanguage);

//     // Mark language as selected
//     _storage.write('hasSelectedLanguage', true);

//     // Navigate to next screen based on whether it's first time
//     final bool isFirstTime = _storage.read('IsFirstTime') == true;

//     // if (isFirstTime) {
//     if (!isFirstTime) {
//       Get.offAll(() => const OnBoardingScreen());
//     } else {
//       Get.offAll(() => const LoginScreen());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Use current context for theme detection only
//     final dark = AppHelperFunctions.isDarkMode(context);

//     return Scaffold(
//       backgroundColor: dark ? AppColors.dark : AppColors.light,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             width: double.infinity,
//             constraints: BoxConstraints(
//               minHeight:
//                   MediaQuery.of(context).size.height -
//                   MediaQuery.of(context).padding.top -
//                   MediaQuery.of(context).padding.bottom,
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildIconSection(dark),
//                 const SizedBox(height: 40),
//                 _buildTitleSection(dark),
//                 const SizedBox(height: 12),
//                 _buildSubtitleSection(dark),
//                 const SizedBox(height: 48),
//                 _buildLanguageList(dark),
//                 const SizedBox(height: 48),
//                 _buildContinueButton(),
//                 // Add extra space at bottom for small screens
//                 const SizedBox(height: 20),
//               ],
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
//             color: AppColors.primaryColor,
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
//       _localizedTexts['chooseLanguage'] ?? 'Choose Language',
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
//       _localizedTexts['selectPreferredLanguage'] ??
//           'Select your preferred language to continue',
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
//         final isSelected = _selectedLanguage == languageCode;

//         // Get the display name based on selected language
//         String displayName = languageCode == 'en'
//             ? _localizedTexts['english'] ?? 'English'
//             : _localizedTexts['arabic'] ?? 'Arabic';

//         // Get the language name in its own language
//         String nativeName = languageCode == 'en' ? 'English' : 'العربية';

//         return Padding(
//           padding: const EdgeInsets.only(bottom: 16),
//           child: _buildLanguageItem(
//             code: languageCode,
//             displayName: displayName,
//             nativeName: nativeName,
//             isSelected: isSelected,
//             dark: dark,
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildLanguageItem({
//     required String code,
//     required String displayName,
//     required String nativeName,
//     required bool isSelected,
//     required bool dark,
//   }) {
//     return GestureDetector(
//       onTap: () => _onLanguageSelected(code),
//       child: Container(
//         width: double.infinity,
//         height: 86,
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
//                     color: AppColors.primaryColor,
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
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             displayName,
//                             style: TextStyle(
//                               color: dark ? AppColors.white : AppColors.dark,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               fontFamily: _selectedLanguage == 'ar'
//                                   ? 'Tajawal'
//                                   : 'Poppins',
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             nativeName,
//                             style: TextStyle(
//                               color: isSelected
//                                   ? AppColors.primaryColor
//                                   : (dark
//                                         ? AppColors.lightGrey
//                                         : AppColors.darkGrey),
//                               fontSize: 12,
//                               fontWeight: FontWeight.w300,
//                               fontFamily: code == 'ar' ? 'Tajawal' : 'Poppins',
//                             ),
//                             overflow: TextOverflow.ellipsis,
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
//     return SizedBox(
//       width: double.infinity,
//       height: 56,
//       child: ElevatedButton(
//         onPressed: _onContinuePressed,
//         child: Text(
//           _localizedTexts['continue'] ?? 'Continue',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             fontFamily: _selectedLanguage == 'ar' ? 'Tajawal' : 'Poppins',
//           ),
//         ),
//       ),
//     );
//   }
// }

