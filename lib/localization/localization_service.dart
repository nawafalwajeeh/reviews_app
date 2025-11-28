import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocalizationService extends GetxService {
  static LocalizationService get instance => Get.find();

  /// Variables
  final GetStorage _storage = GetStorage();
  final RxString _currentLang = 'en'.obs;

  // Properly typed with Locale objects
  static final Map<String, Locale> _supportedLocales = {
    'en': const Locale('en', 'US'),
    'ar': const Locale('ar', 'SA'),
  };

  static final Map<String, String> _languageNames = {
    'en': 'English',
    'ar': 'العربية',
  };

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  String get currentLanguage => _currentLang.value;
  Locale get currentLocale => _supportedLocales[_currentLang.value]!;

  // Return List<Locale> directly from the values
  List<Locale> get supportedLocales => _supportedLocales.values.toList();

  // Return Map<String, String> for language names
  Map<String, String> get supportedLanguages => _languageNames;

  Future<void> _loadSavedLanguage() async {
    String? savedLang = _storage.read('language');
    if (savedLang != null && _supportedLocales.containsKey(savedLang)) {
      _currentLang.value = savedLang;
    } else {
      // Default to device locale or English
      final deviceLocale = Get.deviceLocale;
      if (deviceLocale != null &&
          _supportedLocales.containsKey(deviceLocale.languageCode)) {
        _currentLang.value = deviceLocale.languageCode;
      } else {
        _currentLang.value = 'en';
      }
    }

    // Update GetX locale
    Get.updateLocale(currentLocale);
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_supportedLocales.containsKey(languageCode)) {
      _currentLang.value = languageCode;
      await _storage.write('language', languageCode);
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
    return _languageNames[_currentLang.value] ?? 'English';
  }

  static bool isLanguageRTL(String languageCode) {
    return languageCode == 'ar';
  }
}
