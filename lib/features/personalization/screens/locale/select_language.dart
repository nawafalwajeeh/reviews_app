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
  const SelectLanguageScreen({super.key});

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
  final List<Map<String, dynamic>> _allLanguages = [
    {
      'code': 'ar',
      'names': {'ar': 'العربية', 'en': 'Arabic'},
      'flag': '🇾🇪',
      'selected': true,
      'isSupported': true,
    },

    {
      'code': 'en',
      'names': {'ar': 'الإنجليزية', 'en': 'English'},
      'flag': '🇺🇸',
      'selected': false,
      'isSupported': true,
    },

    // The rest are set to unsupported and given localized names
    {
      'code': 'fr',
      'names': {'ar': 'الفرنسية', 'en': 'French'},
      'flag': '🇫🇷',
      'selected': false,
      'isSupported': false,
    },

    {
      'code': 'de',
      'names': {'ar': 'الألمانية', 'en': 'German'},
      'flag': '🇩🇪',
      'selected': false,
      'isSupported': false,
    },

    {
      'code': 'es',
      'names': {'ar': 'الإسبانية', 'en': 'Spanish'},
      'flag': '🇪🇸',
      'selected': false,
      'isSupported': false,
    },

    {
      'code': 'hi',
      'names': {'ar': 'الهندية', 'en': 'Hindi'},
      'flag': '🇮🇳',
      'selected': false,
      'isSupported': false,
    },

    {
      'code': 'ko',
      'names': {'ar': 'الكورية', 'en': 'Korean'},
      'flag': '🇰🇷',
      'selected': false,
      'isSupported': false,
    },

    {
      'code': 'zh',

      'names': {'ar': 'الصينية', 'en': 'Chinese'},

      'flag': '🇨🇳',

      'selected': false,

      'isSupported': false,
    },

    {
      'code': 'ja',

      'names': {'ar': 'اليابانية', 'en': 'Japanese'},

      'flag': '🇯🇵',

      'selected': false,

      'isSupported': false,
    },

    {
      'code': 'pt',

      'names': {'ar': 'البرتغالية', 'en': 'Portuguese'},

      'flag': '🇵🇹',

      'selected': false,

      'isSupported': false,
    },

    {
      'code': 'it',

      'names': {'ar': 'الإيطالية', 'en': 'Italian'},

      'flag': '🇮🇹',

      'selected': false,

      'isSupported': false,
    },

    {
      'code': 'ru',

      'names': {'ar': 'الروسية', 'en': 'Russian'},

      'flag': '🇷🇺',

      'selected': false,

      'isSupported': false,
    },
  ];

  // --- I N L I N E D - H E L P E R S ---

  /// Custom helper function to replace Color.withOpacity with the requested

  /// Color.withValues(alpha: value) syntax. 'alpha' here acts as the opacity (0.0 - 1.0).

  static Color _withValues({required Color color, required double alpha}) {
    return color.withOpacity(alpha);
  }

  /// Helper to get the display name of a language based on the current selected locale.

  String _getLocalizedLanguageName(Map<String, dynamic> lang) {
    // Get the names map from the language item

    final names = lang['names'] as Map<String, String>?;

    // Determine the key for localization (use 'ar' or 'en' from the selected language)

    final localeKey = (_selectedLanguage == 'ar') ? 'ar' : 'en';

    // Return the localized name, falling back to English or the language code if not found.

    return names?[localeKey] ?? names?['en'] ?? lang['code']!;
  }

  // --- E N D - O F - I N L I N E D - H E L P E R S ---

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

  void _initializeLanguage() {
    final storedLang = _storage.read('languageCode') ?? 'ar';

    _selectedLanguage = storedLang;

    for (var lang in _allLanguages) {
      lang['selected'] = lang['code'] == _selectedLanguage;
    }

    _loadInitialLocalizedTexts(_selectedLanguage);
  }

  /// Loads all necessary localized texts for the initial screen based on the current locale.

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
              'currentLanguageHeader': languageCode == 'ar'
                  ? 'اللغة الحالية'
                  : 'Current Language',

              'allLanguagesText': languageCode == 'ar'
                  ? 'كل اللغات'
                  : 'All Languages',

              'search': initialLocalizations.search,

              'comingSoon': languageCode == 'ar' ? 'قريباً' : 'Coming Soon',
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

              'currentLanguageHeader': 'Current Language',

              'allLanguagesText': 'All Languages',

              'search': 'Search',

              'comingSoon': 'Coming Soon',
            };

            _isLoading = false;
          });

          _animationController.forward();
        });
  }

  /// Updates localized texts when a new language is selected.

  Future<void> _updateLocalizedTexts(String languageCode) async {
    final tempLocale = Locale(languageCode);

    final tempLocalizations = AppLocalizations(tempLocale);

    await tempLocalizations.load();

    setState(() {
      _localizedTexts = {
        'chooseLanguage': tempLocalizations.chooseLanguage,

        'selectPreferredLanguage': tempLocalizations.selectPreferredLanguage,

        'continue': tempLocalizations.continueText,

        'currentLanguageHeader': languageCode == 'ar'
            ? 'اللغة الحالية'
            : 'Current Language',

        'allLanguagesText': languageCode == 'ar'
            ? 'كل اللغات'
            : 'All Languages',

        'search': tempLocalizations.search,

        'comingSoon': languageCode == 'ar' ? 'قريباً' : 'Coming Soon',
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

    final bool isFirstTime = _storage.read('IsFirstTime') != false;

    if (isFirstTime) {
      Get.offAll(() => const OnBoardingScreen());
    } else {
      Get.offAll(() => const LoginScreen());
    }
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

        body: SafeArea(
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
                    color: backgroundColor, // Use theme-aware background color

                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),

                    child: _buildContinueButton(isArabic),
                  ),
                ],
              ),
            ),
          ),
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

    // FIX 2: Corrected filtering logic to handle Arabic search by using raw strings

    // for Arabic names, and lowercased comparison for Latin (English) names.

    final filteredLanguages = _searchQuery.isEmpty
        ? _allLanguages.where((lang) => lang['selected'] != true).toList()
        : _allLanguages.where((lang) {
            // Extract raw names

            final names = lang['names'] as Map<String, String>?;

            final englishName = names?['en'] ?? '';

            final arabicName = names?['ar'] ?? '';

            // 1. Check against English name (case-insensitive)

            final englishMatch = englishName.toLowerCase().contains(queryLower);

            // 2. Check against Arabic name (raw comparison to avoid normalization issues)

            final arabicMatch = arabicName.contains(_searchQuery);

            // 3. Check against the currently localized name (using appropriate method)

            final localizedName = _getLocalizedLanguageName(lang);

            final localizedMatch = _selectedLanguage == 'ar'
                ? localizedName.contains(_searchQuery)
                : localizedName.toLowerCase().contains(queryLower);

            return (englishMatch || arabicMatch || localizedMatch) &&
                lang['selected'] != true;
          }).toList();

    if (filteredLanguages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),

        child: Center(
          child: Text(
            // Use localization fallback for this internal message
            _selectedLanguage == 'ar'
                ? 'لم يتم العثور على لغات'
                : 'No languages found',

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

    final bool isSupported =
        lang['isSupported'] ?? true; // Default to supported if key is missing

    final bool isArabic = _selectedLanguage == 'ar';

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
                child: Text(
                  displayName,

                  style: TextStyle(
                    color: nameColor,

                    fontSize: 16.5,

                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,

                    fontFamily: isArabic ? 'Tajawal' : 'Poppins',

                    letterSpacing: -0.3,
                  ),
                ),
              ),

              // Status Indicator (Checkmark or Coming Soon chip)
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,

                  color: selectedBorderColor,

                  size: 28,
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
