import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/data/services/localization/localization_service.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import '../../../authentication/screens/login/login.dart';
import '../../../authentication/screens/onboarding/onboarding.dart';
import 'package:iconsax/iconsax.dart'; // Assuming this import is available.

class SelectLanguageScreen extends StatefulWidget {
  final bool isFromSettings; // Add this parameter

  const SelectLanguageScreen({super.key, this.isFromSettings = false});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen>
    with SingleTickerProviderStateMixin {
  final LocalizationService _localizationService = LocalizationService.instance;
  final GetStorage _storage = GetStorage();
  late String _selectedLanguage = 'ar';
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Cache for localized texts based on selected language

  Map<String, String> _localizedTexts = {};
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  // Search query is now stored raw, without automatic lowercasing.
  String _searchQuery = '';

  // Language list: Updated to include localized display names in a 'names' map.
  // final List<Map<String, dynamic>> _allLanguages = [
  //   {
  //     'code': 'ar',
  //     'names': {'ar': 'العربية', 'en': 'Arabic'},
  //     'flag': '🇾🇪',
  //     'selected': true,
  //     'isSupported': true,
  //   },

  //   {
  //     'code': 'en',
  //     'names': {'ar': 'الإنجليزية', 'en': 'English'},
  //     'flag': '🇺🇸',
  //     'selected': false,
  //     'isSupported': true,
  //   },

  //   // The rest are set to unsupported and given localized names
  //   {
  //     'code': 'fr',
  //     'names': {'ar': 'الفرنسية', 'en': 'French'},
  //     'flag': '🇫🇷',
  //     'selected': false,
  //     'isSupported': true,
  //   },

  //   {
  //     'code': 'de',
  //     'names': {'ar': 'الألمانية', 'en': 'German'},
  //     'flag': '🇩🇪',
  //     'selected': false,
  //     'isSupported': true,
  //   },

  //   {
  //     'code': 'es',
  //     'names': {'ar': 'الإسبانية', 'en': 'Spanish'},
  //     'flag': '🇪🇸',
  //     'selected': false,
  //     'isSupported': true,
  //   },

  //   {
  //     'code': 'hi',
  //     'names': {'ar': 'الهندية', 'en': 'Hindi'},
  //     'flag': '🇮🇳',
  //     'selected': false,
  //     'isSupported': true,
  //   },

  //   {
  //     'code': 'ko',
  //     'names': {'ar': 'الكورية', 'en': 'Korean'},
  //     'flag': '🇰🇷',
  //     'selected': false,
  //     'isSupported': true,
  //   },

  //   {
  //     'code': 'zh',
  //     'names': {'ar': 'الصينية', 'en': 'Chinese'},
  //     'flag': '🇨🇳',
  //     'selected': false,
  //     'isSupported': true,
  //   },

  //   {
  //     'code': 'ja',
  //     'names': {'ar': 'اليابانية', 'en': 'Japanese'},
  //     'flag': '🇯🇵',
  //     'selected': false,
  //     'isSupported': true,
  //   },

  //   {
  //     'code': 'pt',
  //     'names': {'ar': 'البرتغالية', 'en': 'Portuguese'},
  //     'flag': '🇵🇹',
  //     'selected': false,
  //     'isSupported': true,
  //   },

  //   {
  //     'code': 'it',
  //     'names': {'ar': 'الإيطالية', 'en': 'Italian'},
  //     'flag': '🇮🇹',
  //     'selected': false,
  //     'isSupported': true,
  //   },

  //   {
  //     'code': 'ru',
  //     'names': {'ar': 'الروسية', 'en': 'Russian'},
  //     'flag': '🇷🇺',
  //     'selected': false,
  //     'isSupported': true,
  //   },
  // ];

  // Language list: Updated to include localized display names in a 'names' map.
  final List<Map<String, dynamic>> _allLanguages = [
    {
      'code': 'ar',
      'names': {
        'ar': 'العربية',
        'en': 'Arabic',
        'fr': 'Arabe',
        'de': 'Arabisch',
        'es': 'Árabe',
        'hi': 'अरबी',
        'ko': '아랍어',
        'zh': '阿拉伯语',
        'ja': 'アラビア語',
        'pt': 'Árabe',
        'it': 'Arabo',
        'ru': 'Арабский',
      },
      'flag': '🇾🇪',
      'selected': true,
      'isSupported': true,
    },
    {
      'code': 'en',
      'names': {
        'ar': 'الإنجليزية',
        'en': 'English',
        'fr': 'Anglais',
        'de': 'Englisch',
        'es': 'Inglés',
        'hi': 'अंग्रेज़ी',
        'ko': '영어',
        'zh': '英语',
        'ja': '英語',
        'pt': 'Inglês',
        'it': 'Inglese',
        'ru': 'Английский',
      },
      'flag': '🇺🇸',
      'selected': false,
      'isSupported': true,
    },
    {
      'code': 'fr',
      'names': {
        'ar': 'الفرنسية',
        'en': 'French',
        'fr': 'Français',
        'de': 'Französisch',
        'es': 'Francés',
        'hi': 'फ़्रेंच',
        'ko': '프랑스어',
        'zh': '法语',
        'ja': 'フランス語',
        'pt': 'Francês',
        'it': 'Francese',
        'ru': 'Французский',
      },
      'flag': '🇫🇷',
      'selected': false,
      'isSupported': true,
    },
    {
      'code': 'de',
      'names': {
        'ar': 'الألمانية',
        'en': 'German',
        'fr': 'Allemand',
        'de': 'Deutsch',
        'es': 'Alemán',
        'hi': 'जर्मन',
        'ko': '독일어',
        'zh': '德语',
        'ja': 'ドイツ語',
        'pt': 'Alemão',
        'it': 'Tedesco',
        'ru': 'Немецкий',
      },
      'flag': '🇩🇪',
      'selected': false,
      'isSupported': true,
    },
    {
      'code': 'es',
      'names': {
        'ar': 'الإسبانية',
        'en': 'Spanish',
        'fr': 'Espagnol',
        'de': 'Spanisch',
        'es': 'Español',
        'hi': 'स्पेनिश',
        'ko': '스페인어',
        'zh': '西班牙语',
        'ja': 'スペイン語',
        'pt': 'Espanhol',
        'it': 'Spagnolo',
        'ru': 'Испанский',
      },
      'flag': '🇪🇸',
      'selected': false,
      'isSupported': true,
    },
    {
      'code': 'hi',
      'names': {
        'ar': 'الهندية',
        'en': 'Hindi',
        'fr': 'Hindi',
        'de': 'Hindi',
        'es': 'Hindi',
        'hi': 'हिन्दी',
        'ko': '힌디어',
        'zh': '印地语',
        'ja': 'ヒンディー語',
        'pt': 'Hindi',
        'it': 'Hindi',
        'ru': 'Хинди',
      },
      'flag': '🇮🇳',
      'selected': false,
      'isSupported': true,
    },
    {
      'code': 'ko',
      'names': {
        'ar': 'الكورية',
        'en': 'Korean',
        'fr': 'Coréen',
        'de': 'Koreanisch',
        'es': 'Coreano',
        'hi': 'कोरियाई',
        'ko': '한국어',
        'zh': '韩语',
        'ja': '韓国語',
        'pt': 'Coreano',
        'it': 'Coreano',
        'ru': 'Корейский',
      },
      'flag': '🇰🇷',
      'selected': false,
      'isSupported': true,
    },
    {
      'code': 'zh',
      'names': {
        'ar': 'الصينية',
        'en': 'Chinese',
        'fr': 'Chinois',
        'de': 'Chinesisch',
        'es': 'Chino',
        'hi': 'चीनी',
        'ko': '중국어',
        'zh': '中文',
        'ja': '中国語',
        'pt': 'Chinês',
        'it': 'Cinese',
        'ru': 'Китайский',
      },
      'flag': '🇨🇳',
      'selected': false,
      'isSupported': true,
    },
    {
      'code': 'ja',
      'names': {
        'ar': 'اليابانية',
        'en': 'Japanese',
        'fr': 'Japonais',
        'de': 'Japanisch',
        'es': 'Japonés',
        'hi': 'जापानी',
        'ko': '일본어',
        'zh': '日语',
        'ja': '日本語',
        'pt': 'Japonês',
        'it': 'Giapponese',
        'ru': 'Японский',
      },
      'flag': '🇯🇵',
      'selected': false,
      'isSupported': true,
    },
    {
      'code': 'pt',
      'names': {
        'ar': 'البرتغالية',
        'en': 'Portuguese',
        'fr': 'Portugais',
        'de': 'Portugiesisch',
        'es': 'Portugués',
        'hi': 'पुर्तगाली',
        'ko': '포르투갈어',
        'zh': '葡萄牙语',
        'ja': 'ポルトガル語',
        'pt': 'Português',
        'it': 'Portoghese',
        'ru': 'Португальский',
      },
      'flag': '🇵🇹',
      'selected': false,
      'isSupported': true,
    },
    {
      'code': 'it',
      'names': {
        'ar': 'الإيطالية',
        'en': 'Italian',
        'fr': 'Italien',
        'de': 'Italienisch',
        'es': 'Italiano',
        'hi': 'इतालवी',
        'ko': '이탈리아어',
        'zh': '意大利语',
        'ja': 'イタリア語',
        'pt': 'Italiano',
        'it': 'Italiano',
        'ru': 'Итальянский',
      },
      'flag': '🇮🇹',
      'selected': false,
      'isSupported': true,
    },
    {
      'code': 'ru',
      'names': {
        'ar': 'الروسية',
        'en': 'Russian',
        'fr': 'Russe',
        'de': 'Russisch',
        'es': 'Ruso',
        'hi': 'रूसी',
        'ko': '러시아어',
        'zh': '俄语',
        'ja': 'ロシア語',
        'pt': 'Russo',
        'it': 'Russo',
        'ru': 'Русский',
      },
      'flag': '🇷🇺',
      'selected': false,
      'isSupported': true,
    },
  ];

  /// Custom helper function to replace Color.withOpacity with the requested
  static Color _withValues({required Color color, required double alpha}) {
    return color.withValues(alpha: alpha);
  }

  /// Helper to get the display name of a language based on the current selected locale.
  String _getLocalizedLanguageName(Map<String, dynamic> lang) {
    // Get the names map from the language item
    final names = lang['names'] as Map<String, String>?;

    // Use the current selected language code as the key
    final localeKey = _selectedLanguage;

    // First, try to get the name in the selected language
    final localizedName = names?[localeKey];

    // If not available, try English as fallback
    if (localizedName != null && localizedName.isNotEmpty) {
      return localizedName;
    }

    // Fall back to English
    final englishName = names?['en'];
    if (englishName != null && englishName.isNotEmpty) {
      return englishName;
    }

    // Final fallback to language code
    return lang['code'] ?? 'Unknown';
  }

  @override
  void initState() {
    super.initState();

    _initializeAnimations();

    _initializeLanguage();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),

      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,

            curve: Curves.easeOutCubic,
          ),
        );
  }

  // void _initializeLanguage() {
  //   final storedLang = _storage.read('languageCode') ?? 'ar';

  //   _selectedLanguage = storedLang;

  //   for (var lang in _allLanguages) {
  //     lang['selected'] = lang['code'] == _selectedLanguage;
  //   }

  //   _loadInitialLocalizedTexts(_selectedLanguage);
  // }

  // void _initializeLanguage() {
  //   // CHANGE THIS LINE:
  //   // final storedLang = _storage.read('languageCode') ?? 'ar'; // ❌ OLD
  //   final storedLang = _localizationService.currentLanguage; // ✅ NEW

  //   _selectedLanguage = storedLang;

  //   for (var lang in _allLanguages) {
  //     lang['selected'] = lang['code'] == _selectedLanguage;
  //   }

  //   _loadInitialLocalizedTexts(_selectedLanguage);
  // }

  void _initializeLanguage() {
    // FIRST: Check if we should use Arabic (first time) or saved language
    final savedLanguage = _storage.read('language');
    final hasSelectedBefore = _storage.read('hasSelectedLanguage') == true;

    if (savedLanguage != null && hasSelectedBefore) {
      // User has both saved a language AND marked as selected
      _selectedLanguage = savedLanguage;
    } else {
      // First time or no selection made yet
      _selectedLanguage = 'ar';
    }

    // Rest of your code stays the same...
    for (var lang in _allLanguages) {
      lang['selected'] = lang['code'] == _selectedLanguage;
    }

    _loadInitialLocalizedTexts(_selectedLanguage);
  }

  /// Loads all necessary localized texts for the initial screen based on the current locale.

  // void _loadInitialLocalizedTexts(String languageCode) {
  //   final initialLocale = Locale(languageCode);

  //   final initialLocalizations = AppLocalizations(initialLocale);

  //   initialLocalizations
  //       .load()
  //       .then((_) {
  //         setState(() {
  //           _localizedTexts = {
  //             'chooseLanguage': initialLocalizations.chooseLanguage,

  //             'selectPreferredLanguage':
  //                 initialLocalizations.selectPreferredLanguage,

  //             'continue': initialLocalizations.continueText,

  //             // Custom header localization for the selected language section
  //             'currentLanguageHeader': languageCode == 'ar'
  //                 ? 'اللغة الحالية'
  //                 : 'Current Language',

  //             'allLanguagesText': languageCode == 'ar'
  //                 ? 'كل اللغات'
  //                 : 'All Languages',

  //             'search': initialLocalizations.search,

  //             'comingSoon': languageCode == 'ar' ? 'قريباً' : 'Coming Soon',
  //           };

  //           _isLoading = false;
  //         });

  //         _animationController.forward();
  //       })
  //       .catchError((error) {
  //         // Fallback texts if loading fails

  //         setState(() {
  //           _localizedTexts = {
  //             'chooseLanguage': 'Choose the language',

  //             'selectPreferredLanguage':
  //                 'Select your preferred language below. This helps us serve you better.',

  //             'continue': 'Continue',

  //             'currentLanguageHeader': 'Current Language',

  //             'allLanguagesText': 'All Languages',

  //             'search': 'Search',

  //             'comingSoon': 'Coming Soon',
  //           };

  //           _isLoading = false;
  //         });

  //         _animationController.forward();
  //       });
  // }
  String _getComingSoonText() {
    switch (_selectedLanguage) {
      case 'ar':
        return 'قريباً';
      case 'fr':
        return 'Bientôt disponible';
      case 'de':
        return 'Demnächst verfügbar';
      case 'es':
        return 'Próximamente';
      case 'hi':
        return 'जल्द ही आ रहा है';
      case 'ko':
        return '곧 제공될 예정입니다';
      case 'zh':
        return '即将推出';
      case 'ja':
        return '近日公開予定';
      case 'pt':
        return 'Em breve';
      case 'it':
        return 'Prossimamente';
      case 'ru':
        return 'Скоро будет';
      default:
        return 'Coming Soon';
    }
  }

  void _loadInitialLocalizedTexts(String languageCode) {
    final initialLocale = Locale(languageCode);
    final initialLocalizations = AppLocalizations(initialLocale);

    initialLocalizations
        .load()
        .then((_) {
          setState(() {
            _localizedTexts = {
              'chooseLanguage': initialLocalizations.chooseLanguage,
              'selectPreferredLanguage':
                  initialLocalizations.selectPreferredLanguage,
              'continue': initialLocalizations.continueText,
              // Custom header localization for the selected language section
              'currentLanguageHeader': _getCurrentLanguageHeader(languageCode),
              'allLanguagesText': _getAllLanguagesText(languageCode),
              'search': initialLocalizations.search,
              'comingSoon': _getComingSoonText(),
            };
            _isLoading = false;
          });
          _animationController.forward();
        })
        .catchError((error) {
          // Fallback texts if loading fails
          setState(() {
            _localizedTexts = {
              'chooseLanguage': 'Choose the language',
              'selectPreferredLanguage':
                  'Select your preferred language below. This helps us serve you better.',
              'continue': 'Continue',
              'currentLanguageHeader': _getCurrentLanguageHeader(languageCode),
              'allLanguagesText': _getAllLanguagesText(languageCode),
              'search': 'Search',
              'comingSoon': _getComingSoonText(),
            };
            _isLoading = false;
          });
          _animationController.forward();
        });
  }

  String _getCurrentLanguageHeader(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'اللغة الحالية';
      case 'fr':
        return 'Langue actuelle';
      case 'de':
        return 'Aktuelle Sprache';
      case 'es':
        return 'Idioma actual';
      case 'hi':
        return 'वर्तमान भाषा';
      case 'ko':
        return '현재 언어';
      case 'zh':
        return '当前语言';
      case 'ja':
        return '現在の言語';
      case 'pt':
        return 'Idioma atual';
      case 'it':
        return 'Lingua corrente';
      case 'ru':
        return 'Текущий язык';
      default:
        return 'Current Language';
    }
  }

  String _getAllLanguagesText(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'كل اللغات';
      case 'fr':
        return 'Toutes les langues';
      case 'de':
        return 'Alle Sprachen';
      case 'es':
        return 'Todos los idiomas';
      case 'hi':
        return 'सभी भाषाएँ';
      case 'ko':
        return '모든 언어';
      case 'zh':
        return '所有语言';
      case 'ja':
        return 'すべての言語';
      case 'pt':
        return 'Todos os idiomas';
      case 'it':
        return 'Tutte le lingue';
      case 'ru':
        return 'Все языки';
      default:
        return 'All Languages';
    }
  }

  /// Updates localized texts when a new language is selected.

  // Future<void> _updateLocalizedTexts(String languageCode) async {
  //   final tempLocale = Locale(languageCode);

  //   final tempLocalizations = AppLocalizations(tempLocale);

  //   await tempLocalizations.load();

  //   setState(() {
  //     _localizedTexts = {
  //       'chooseLanguage': tempLocalizations.chooseLanguage,

  //       'selectPreferredLanguage': tempLocalizations.selectPreferredLanguage,

  //       'continue': tempLocalizations.continueText,

  //       'currentLanguageHeader': languageCode == 'ar'
  //           ? 'اللغة الحالية'
  //           : 'Current Language',

  //       'allLanguagesText': languageCode == 'ar'
  //           ? 'كل اللغات'
  //           : 'All Languages',

  //       'search': tempLocalizations.search,

  //       'comingSoon': languageCode == 'ar' ? 'قريباً' : 'Coming Soon',
  //     };
  //   });
  // }

  Future<void> _updateLocalizedTexts(String languageCode) async {
    final tempLocale = Locale(languageCode);
    final tempLocalizations = AppLocalizations(tempLocale);

    await tempLocalizations.load();

    setState(() {
      _localizedTexts = {
        'chooseLanguage': tempLocalizations.chooseLanguage,
        'selectPreferredLanguage': tempLocalizations.selectPreferredLanguage,
        'continue': tempLocalizations.continueText,

        // FIX: Use dynamic methods instead of hardcoding
        'currentLanguageHeader': _getCurrentLanguageHeader(languageCode), // ✅
        'allLanguagesText': _getAllLanguagesText(languageCode), // ✅
        'search': tempLocalizations.search,
        'comingSoon': _getComingSoonText(), // Already fixed
      };
    });
  }

  void _onLanguageSelected(String languageCode) {
    // Find the language item to check support status

    final languageItem = _allLanguages.firstWhereOrNull(
      (lang) => lang['code'] == languageCode,
    );

    // Check if the language is supported before allowing selection

    if (languageItem?['isSupported'] != true) return;

    if (languageCode == _selectedLanguage) return;

    setState(() {
      for (var lang in _allLanguages) {
        lang['selected'] = lang['code'] == languageCode;
      }

      _selectedLanguage = languageCode;
    });

    _updateLocalizedTexts(languageCode);
  }

  Future<void> _onContinuePressed() async {
    await _localizationService.changeLanguage(_selectedLanguage);
    await _storage.write('hasSelectedLanguage', true);

    // Check if coming from settings or first time
    if (widget.isFromSettings) {
      // If from settings, just go back
      Get.back();
      // Show success message
      Get.snackbar(
        txt.success,
        'Language changed successfully',
        // txt.languageChangedSuccessfully,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      // First time flow
      final bool isFirstTime = _storage.read('IsFirstTime') != false;

      if (isFirstTime) {
        Get.offAll(() => const OnBoardingScreen());
      } else {
        Get.offAll(() => const LoginScreen());
      }
    }
    return;
  }

  @override
  void dispose() {
    _animationController.dispose();

    _searchController.dispose();

    super.dispose();
  }

  /// FIX 1: Stop converting the search query to lowercase on input.

  /// This preserves the exact Unicode characters entered by the user,

  /// which is crucial for reliable matching in Arabic.

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query; // Keep the query raw
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- Dynamic Dark Mode Check ---

    final dark = AppHelperFunctions.isDarkMode(context);

    final bool isArabic = _selectedLanguage == 'ar';

    // --- Theme-Aware Colors ---

    // Dark Mode colors provided in original code

    const Color darkBackgroundColor = Color(0xFF0A0A0A);

    const Color darkCardColor = Color(0xFF1A1A1A);

    const Color darkInputColor = Color(0xFF252525);

    // Light Mode color fallbacks (assuming standard AppColors definitions)

    const Color lightBackgroundColor = Colors.white;

    const Color lightCardColor = Color(0xFFF0F0F0); // Subtle light gray

    const Color lightInputColor = Color(
      0xFFE8E8E8,
    ); // Slightly darker for input

    // General theme colors

    final Color backgroundColor = dark
        ? darkBackgroundColor
        : lightBackgroundColor;

    final Color cardColor = dark ? darkCardColor : lightCardColor;

    final Color inputColor = dark ? darkInputColor : lightInputColor;

    final Color textColor = dark
        ? Colors.white
        : AppColors.dark; // Assuming AppColors.dark is black or dark gray

    // Apply _withValues replacement

    final Color mutedColor = dark
        ? _withValues(color: Colors.white, alpha: 0.6)
        : _withValues(color: AppColors.darkGrey, alpha: 0.7);

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,

      child: Scaffold(
        backgroundColor: backgroundColor,

        body: Stack(
          children: [
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,

                child: SlideTransition(
                  position: _slideAnimation,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // Header/Title Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // Title
                            Text(
                              _localizedTexts['chooseLanguage']!,

                              style: TextStyle(
                                color: textColor, // Theme-aware color

                                fontSize: 28,

                                fontWeight: FontWeight.w700,

                                fontFamily: isArabic ? 'Tajawal' : 'Poppins',

                                height: 1.1,

                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Subtitle
                            Text(
                              _localizedTexts['selectPreferredLanguage']!,

                              style: TextStyle(
                                color: mutedColor, // Theme-aware color

                                fontSize: 15.5,

                                height: 1.5,

                                fontWeight: FontWeight.w400,

                                fontFamily: isArabic ? 'Tajawal' : 'Poppins',
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Search Bar
                            _buildSearchBar(
                              dark,

                              isArabic,

                              inputColor,

                              textColor,

                              mutedColor,
                            ), // Pass dynamic colors

                            const SizedBox(height: 32),

                            // --- Current Language Section Header (New) ---
                            Text(
                              _localizedTexts['currentLanguageHeader']!, // Localized

                              style: TextStyle(
                                color: textColor, // Theme-aware color

                                fontSize: 17,

                                fontWeight: FontWeight.w600,

                                fontFamily: isArabic ? 'Tajawal' : 'Poppins',

                                letterSpacing: -0.3,
                              ),
                            ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),

                      // Languages List & Selected Language Card
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),

                          // Add padding to the list content
                          padding: const EdgeInsets.symmetric(horizontal: 24),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              // Find and display the selected language item (Current Language Card)
                              if (_allLanguages.any(
                                (lang) => lang['code'] == _selectedLanguage,
                              ))
                                _buildLanguageListItem(
                                  lang: _allLanguages.firstWhere(
                                    (lang) => lang['code'] == _selectedLanguage,
                                  ),

                                  cardColor: cardColor, // Pass dynamic color

                                  textColor: textColor, // Pass dynamic color

                                  isCurrentLanguageCard: true,
                                ),

                              const SizedBox(height: 32),

                              // All Languages Section Header
                              Text(
                                _localizedTexts['allLanguagesText']!, // Localized

                                style: TextStyle(
                                  color: textColor, // Theme-aware color

                                  fontSize: 17,

                                  fontWeight: FontWeight.w600,

                                  fontFamily: isArabic ? 'Tajawal' : 'Poppins',

                                  letterSpacing: -0.3,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Languages List (excluding the selected one)
                              _buildLanguagesList(
                                cardColor,

                                textColor,
                              ), // Pass dynamic colors

                              const SizedBox(height: 48),
                            ],
                          ),
                        ),
                      ),

                      // Continue Button (Fixed at the bottom)
                      Container(
                        color:
                            backgroundColor, // Use theme-aware background color

                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),

                        child: _buildContinueButton(isArabic),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Close button (when from settings)
            if (widget.isFromSettings)
              Positioned(
                top: 16,
                right: isArabic ? null : 16,
                left: isArabic ? 16 : null,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: backgroundColor.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close,
                      color: dark ? Colors.white : AppColors.dark,
                      size: 22,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    bool dark,

    bool isArabic,

    Color backgroundColor,

    Color textColor,

    Color mutedColor,
  ) {
    return Container(
      height: 52,

      decoration: BoxDecoration(
        color: backgroundColor,

        // Increased rounding for the search bar
        borderRadius: BorderRadius.circular(24),
      ),

      child: TextField(
        controller: _searchController,

        onChanged: _onSearchChanged,

        textAlignVertical: TextAlignVertical.center,

        style: TextStyle(
          color: textColor, // Theme-aware color

          fontFamily: isArabic ? 'Tajawal' : 'Poppins',

          fontSize: 15,
        ),

        decoration: InputDecoration(
          hintText: _localizedTexts['search']!,

          hintStyle: TextStyle(
            color: mutedColor, // Theme-aware color

            fontFamily: isArabic ? 'Tajawal' : 'Poppins',

            fontSize: 15,
          ),

          prefixIcon: Icon(
            Iconsax.search_normal_1,

            color: mutedColor, // Theme-aware color

            size: 20,
          ),

          border: InputBorder.none,

          enabledBorder: InputBorder.none,

          focusedBorder: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,

            horizontal: 16,
          ),

          isDense: true,
        ),
      ),
    );
  }

  Widget _buildLanguagesList(Color cardColor, Color textColor) {
    // Prepare the lowercased search query once for efficient Latin comparison
    final queryLower = _searchQuery.toLowerCase();

    final filteredLanguages = _searchQuery.isEmpty
        ? _allLanguages.where((lang) => lang['selected'] != true).toList()
        : _allLanguages.where((lang) {
            // Get the localized name in the currently selected language
            final localizedName = _getLocalizedLanguageName(lang).toLowerCase();

            // Also search in the language's native name
            final names = lang['names'] as Map<String, String>?;
            final nativeName = names?[lang['code']]?.toLowerCase() ?? '';

            // Search in both localized and native names
            return (localizedName.contains(queryLower) ||
                    nativeName.contains(queryLower) ||
                    // Also search in English name for all languages
                    (names?['en']?.toLowerCase() ?? '').contains(queryLower)) &&
                lang['selected'] != true;
          }).toList();

    if (filteredLanguages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),

        child: Center(
          child: Text(
            // Use dynamic text based on selected language
            _getNoLanguagesFoundText(),

            style: TextStyle(
              // Apply _withValues replacement
              color: _withValues(color: textColor, alpha: 0.5),

              fontSize: 16,

              fontWeight: FontWeight.w500,

              fontFamily: _selectedLanguage == 'ar' ? 'Tajawal' : 'Poppins',
            ),
          ),
        ),
      );
    }

    return Column(
      children: filteredLanguages.map((lang) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),

          child: _buildLanguageListItem(
            lang: lang,

            cardColor: cardColor, // Pass dynamic color

            textColor: textColor, // Pass dynamic color

            isCurrentLanguageCard: false,
          ),
        );
      }).toList(),
    );
  }

  String _getNoLanguagesFoundText() {
    switch (_selectedLanguage) {
      case 'ar':
        return 'لم يتم العثور على لغات';
      case 'fr':
        return 'Aucune langue trouvée';
      case 'de':
        return 'Keine Sprachen gefunden';
      case 'es':
        return 'No se encontraron idiomas';
      case 'hi':
        return 'कोई भाषा नहीं मिली';
      case 'ko':
        return '언어를 찾을 수 없습니다';
      case 'zh':
        return '未找到语言';
      case 'ja':
        return '言語が見つかりません';
      case 'pt':
        return 'Nenhum idioma encontrado';
      case 'it':
        return 'Nessuna lingua trovata';
      case 'ru':
        return 'Языки не найдены';
      default:
        return 'No languages found';
    }
  }

  // /// Builds a single language list item or the selected language card.

  // Widget _buildLanguageListItem({
  //   required Map<String, dynamic> lang,

  //   required Color cardColor,

  //   required Color textColor,

  //   required bool isCurrentLanguageCard,
  // }) {
  //   final String code = lang['code']!;

  //   // Use the localized display name based on the current selected language

  //   final String displayName = _getLocalizedLanguageName(lang);

  //   final String flag = lang['flag']!;

  //   final bool isSelected = lang['selected']!;

  //   final bool isSupported =
  //       lang['isSupported'] ?? true; // Default to supported if key is missing

  //   final bool isArabic = _selectedLanguage == 'ar';

  //   // Define colors for the item based on its state

  //   final Color itemBackgroundColor = cardColor;

  //   // Apply _withValues replacement

  //   final Color nameColor = isSelected
  //       ? AppColors.primaryColor
  //       : (isSupported ? textColor : _withValues(color: textColor, alpha: 0.5));

  //   final Color selectedBorderColor = AppColors.primaryColor;

  //   // Reduced opacity for unsupported languages

  //   final double opacity = isSupported ? 1.0 : 0.6;

  //   const double cardRadius = 24.0; // Increased rounding

  //   // Apply _withValues replacement

  //   final Color unselectedIconColor = _withValues(color: textColor, alpha: 0.3);

  //   return Material(
  //     color: Colors.transparent,

  //     borderRadius: BorderRadius.circular(cardRadius),

  //     child: InkWell(
  //       // Disable onTap if selected or unsupported
  //       onTap: isSelected || !isSupported
  //           ? null
  //           : () => _onLanguageSelected(code),

  //       borderRadius: BorderRadius.circular(cardRadius),

  //       // Apply _withValues replacement
  //       highlightColor: isSupported
  //           ? _withValues(color: AppColors.primaryColor, alpha: 0.1)
  //           : Colors.transparent,

  //       // Apply _withValues replacement
  //       splashColor: isSupported
  //           ? _withValues(color: AppColors.primaryColor, alpha: 0.2)
  //           : Colors.transparent,

  //       child: Container(
  //         height: 64,

  //         padding: const EdgeInsets.symmetric(horizontal: 16),

  //         decoration: BoxDecoration(
  //           // Apply _withValues replacement
  //           color: _withValues(color: itemBackgroundColor, alpha: opacity),

  //           borderRadius: BorderRadius.circular(cardRadius),

  //           border: Border.all(
  //             color: isSelected ? selectedBorderColor : Colors.transparent,

  //             width: isSelected ? 2 : 0,
  //           ),
  //         ),

  //         child: Row(
  //           children: [
  //             // Flag Circle
  //             Container(
  //               width: 40,

  //               height: 40,

  //               decoration: BoxDecoration(
  //                 color: cardColor, // Theme-aware background

  //                 shape: BoxShape.circle,

  //                 border: Border.all(
  //                   // Apply _withValues replacement
  //                   color: _withValues(color: textColor, alpha: 0.1),

  //                   width: 1,
  //                 ),
  //               ),

  //               child: Center(
  //                 child: Text(flag, style: const TextStyle(fontSize: 20)),
  //               ),
  //             ),

  //             const SizedBox(width: 16),

  //             // Language Name
  //             Expanded(
  //               child: Text(
  //                 displayName,
  //                 style: TextStyle(
  //                   color: nameColor,
  //                   fontSize: 16.5,
  //                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
  //                   fontFamily: isArabic ? 'Tajawal' : 'Poppins',
  //                   letterSpacing: -0.3,
  //                 ),
  //               ),
  //             ),

  //             // Status Indicator (Checkmark or Coming Soon chip)
  //             if (isSelected)
  //               Icon(
  //                 Icons.check_circle_rounded,
  //                 color: selectedBorderColor,
  //                 size: 28,
  //               )
  //             else if (!isSupported)
  //               Container(
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 10,
  //                   vertical: 4,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   // Apply _withValues replacement
  //                   color: _withValues(
  //                     color: AppColors.primaryColor,
  //                     alpha: 0.1,
  //                   ),
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //                 child: Text(
  //                   _localizedTexts['comingSoon']!, // Localized "Coming Soon"
  //                   style: TextStyle(
  //                     color: AppColors.primaryColor,
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w600,
  //                     fontFamily: isArabic ? 'Tajawal' : 'Poppins',
  //                   ),
  //                 ),
  //               )
  //             else
  //               Icon(
  //                 Icons.circle_outlined,
  //                 color: unselectedIconColor, // Theme-aware color
  //                 size: 28,
  //               ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  //----new----
  /// Builds a single language list item or the selected language card.
  Widget _buildLanguageListItem({
    required Map<String, dynamic> lang,
    required Color cardColor,
    required Color textColor,
    required bool isCurrentLanguageCard,
  }) {
    final String code = lang['code']!;

    // Use the localized display name based on the current selected language
    final String displayName = _getLocalizedLanguageName(lang);
    final String flag = lang['flag']!;
    final bool isSelected = lang['selected']!;
    final bool isSupported = lang['isSupported'] ?? true;
    final bool isArabic = _selectedLanguage == 'ar';

    // Check if this is Arabic AND user hasn't selected a language yet (first time)
    final bool isFirstTimeArabic =
        code == 'ar' && !_hasUserSelectedLanguage && isSelected;

    // Define colors for the item based on its state
    final Color itemBackgroundColor = cardColor;

    // Apply _withValues replacement
    final Color nameColor = isSelected
        ? AppColors.primaryColor
        : (isSupported ? textColor : _withValues(color: textColor, alpha: 0.5));

    final Color selectedBorderColor = AppColors.primaryColor;

    // Reduced opacity for unsupported languages
    final double opacity = isSupported ? 1.0 : 0.6;
    const double cardRadius = 24.0; // Increased rounding

    // Apply _withValues replacement
    final Color unselectedIconColor = _withValues(color: textColor, alpha: 0.3);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(cardRadius),
      child: InkWell(
        // Disable onTap if selected or unsupported
        onTap: isSelected || !isSupported
            ? null
            : () => _onLanguageSelected(code),
        borderRadius: BorderRadius.circular(cardRadius),

        // Apply _withValues replacement
        highlightColor: isSupported
            ? _withValues(color: AppColors.primaryColor, alpha: 0.1)
            : Colors.transparent,

        // Apply _withValues replacement
        splashColor: isSupported
            ? _withValues(color: AppColors.primaryColor, alpha: 0.2)
            : Colors.transparent,

        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            // Apply _withValues replacement
            color: _withValues(color: itemBackgroundColor, alpha: opacity),
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(
              color: isSelected ? selectedBorderColor : Colors.transparent,
              width: isSelected ? 2 : 0,
            ),
          ),

          child: Row(
            children: [
              // Flag Circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cardColor, // Theme-aware background
                  shape: BoxShape.circle,
                  border: Border.all(
                    // Apply _withValues replacement
                    color: _withValues(color: textColor, alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(flag, style: const TextStyle(fontSize: 20)),
                ),
              ),

              const SizedBox(width: 16),

              // Language Name
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        color: nameColor,
                        fontSize: 16.5,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontFamily: isArabic ? 'Tajawal' : 'Poppins',
                        letterSpacing: -0.3,
                      ),
                    ),

                    // Show "Default" label for first-time Arabic
                    if (isFirstTimeArabic)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _getDefaultText(), // Localized "Default" text
                          style: TextStyle(
                            color: AppColors.primaryColor.withOpacity(0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: isArabic ? 'Tajawal' : 'Poppins',
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Status Indicator (Checkmark or Coming Soon chip)
              if (isSelected)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: selectedBorderColor,
                      size: 28,
                    ),

                    // Show "Default" indicator under checkmark too
                    if (isFirstTimeArabic)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _getDefaultText(),
                          style: TextStyle(
                            color: AppColors.primaryColor.withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: isArabic ? 'Tajawal' : 'Poppins',
                          ),
                        ),
                      ),
                  ],
                )
              else if (!isSupported)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // Apply _withValues replacement
                    color: _withValues(
                      color: AppColors.primaryColor,
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _localizedTexts['comingSoon']!, // Localized "Coming Soon"
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: isArabic ? 'Tajawal' : 'Poppins',
                    ),
                  ),
                )
              else
                Icon(
                  Icons.circle_outlined,
                  color: unselectedIconColor, // Theme-aware color
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Add this helper method for localized "Default" text
  String _getDefaultText() {
    switch (_selectedLanguage) {
      case 'ar':
        return 'الافتراضي';
      case 'fr':
        return 'Par défaut';
      case 'de':
        return 'Standard';
      case 'es':
        return 'Predeterminado';
      case 'hi':
        return 'डिफ़ॉल्ट';
      case 'ko':
        return '기본값';
      case 'zh':
        return '默认';
      case 'ja':
        return 'デフォルト';
      case 'pt':
        return 'Padrão';
      case 'it':
        return 'Predefinito';
      case 'ru':
        return 'По умолчанию';
      default:
        return 'Default';
    }
  }

  // Also add this getter at the top of your class
  bool get _hasUserSelectedLanguage {
    return _storage.read('hasSelectedLanguage') == true;
  }

  Widget _buildContinueButton(bool isArabic) {
    // --- Continue button is colored by AppColors.primaryColor as requested ---

    final Color primaryColor = AppColors.primaryColor;

    return Container(
      width: double.infinity,

      height: 56,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),

        // Use AppColors.primaryColor for the gradient base
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            // Apply _withValues replacement
            _withValues(
              color: primaryColor,
              alpha: 0.8,
            ), // Start slightly muted primary
            primaryColor, // End at full primary color
            // Apply _withValues replacement
            _withValues(
              color: primaryColor,
              alpha: 0.9,
            ), // Add a slight third color for depth
          ],
        ),
        boxShadow: [
          BoxShadow(
            // Apply _withValues replacement
            color: _withValues(
              color: primaryColor,
              alpha: 0.4,
            ), // Theme-aware shadow
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: _onContinuePressed,
          borderRadius: BorderRadius.circular(28),
          // Apply _withValues replacement
          highlightColor: _withValues(color: Colors.white, alpha: 0.2),
          // Apply _withValues replacement
          splashColor: _withValues(color: Colors.white, alpha: 0.3),
          child: Center(
            child: Text(
              _localizedTexts['continue']!,
              style: TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.w600,
                fontFamily: isArabic ? 'Tajawal' : 'Poppins',
                color: Colors
                    .white, // Text is always white for contrast on the primary button
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
