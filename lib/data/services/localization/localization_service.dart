import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocalizationService extends GetxService {
  static LocalizationService get instance => Get.find();

  /// Variables
  final GetStorage _storage = GetStorage();
  final RxString _currentLang = 'ar'.obs;

  // Properly typed with Locale objects
  static final Map<String, Locale> _supportedLocales = {
    'ar': const Locale('ar', 'SA'),
    'en': const Locale('en', 'US'),
    'fr': const Locale('fr', 'FR'),
    'de': const Locale('de', 'DE'),
    'es': const Locale('es', 'ES'),
    'hi': const Locale('hi', 'IN'),
    'ko': const Locale('ko', 'KR'),
    'zh': const Locale('zh', 'CN'),
    'ja': const Locale('ja', 'JP'),
    'pt': const Locale('pt', 'PT'),
    'it': const Locale('it', 'IT'),
    'ru': const Locale('ru', 'RU'),
  };

  static final Map<String, String> _languageNames = {
    'ar': 'العربية',
    'en': 'English',
    'fr': 'French',
    'de': 'German',
    'es': 'Spanish',
    'hi': 'Hindi',
    'ko': 'Korean',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'pt': 'Portuguese',
    'it': 'Italian',
    'ru': 'Russian',
  };

  final appFontFamily = 'Tajawal'.obs;

  void _loadFontFamily() {
    _currentLang.value == 'ar' ? appFontFamily.value = 'Tajawal' : 'Poppins';
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
    _loadFontFamily();
  }

  String get currentLanguage => _currentLang.value;
  Locale get currentLocale => _supportedLocales[_currentLang.value]!;

  // Return List<Locale> directly from the values
  List<Locale> get supportedLocales => _supportedLocales.values.toList();

  // Return Map<String, String> for language names
  Map<String, String> get supportedLanguages => _languageNames;

  Future<void> _loadSavedLanguage() async {
    String? savedLang = _storage.read('language');
    if (_supportedLocales.containsKey(savedLang)) {
      _currentLang.value = savedLang ?? 'ar';
    } else {
      // Default to device locale or English
      final deviceLocale = Get.deviceLocale;
      if (deviceLocale != null &&
          _supportedLocales.containsKey(deviceLocale.languageCode)) {
        _currentLang.value = deviceLocale.languageCode;
      } else {
        _currentLang.value = 'ar';
      }
    }

    // Update GetX locale
    Get.updateLocale(currentLocale);
  }

  // Future<void> changeLanguage(String languageCode) async {
  //   if (_supportedLocales.containsKey(languageCode)) {
  //     _currentLang.value = languageCode;
  //     await _storage.write('language', languageCode);
  //     Get.updateLocale(_supportedLocales[languageCode]!);
  //   }
  // }

  // In your LocalizationService.dart
  Future<void> changeLanguage(String languageCode) async {
    print('🔄 Changing language to: $languageCode');

    if (_supportedLocales.containsKey(languageCode)) {
      _currentLang.value = languageCode;
      await _storage.write(
        'language',
        languageCode,
      ); // Should write to 'language'
      print('✅ Saved to storage as: ${_storage.read('language')}');
      Get.updateLocale(_supportedLocales[languageCode]!);
    }
  }

  bool isRTL() {
    return _currentLang.value == 'ar';
  }

  TextDirection get textDirection {
    return isRTL() ? TextDirection.rtl : TextDirection.ltr;
  }

  Alignment get alignment {
    return isRTL() ? Alignment.centerRight : Alignment.centerLeft;
  }

  TextAlign get textAlign {
    return isRTL() ? TextAlign.right : TextAlign.left;
  }

  String getCurrentLanguageName() {
    return _languageNames[_currentLang.value] ?? 'العربية';
  }

  static bool isLanguageRTL(String languageCode) {
    return languageCode == 'ar';
  }

  /// Check if user has selected a language
  bool get hasSelectedLanguage {
    return _storage.read('hasSelectedLanguage') == true;
  }

  /// Reset language selection (show language screen again)
  void resetLanguageSelection() {
    _storage.remove('hasSelectedLanguage');
  }

  /// Force show language screen (for testing)
  void forceShowLanguageScreen() {
    _storage.write('hasSelectedLanguage', false);
  }

  void changeLanguageWithUpdate(String languageCode) async {
    if (_supportedLocales.containsKey(languageCode)) {
      _currentLang.value = languageCode;
      await _storage.write('language', languageCode);
      Get.updateLocale(_supportedLocales[languageCode]!);
    }
  }
}
