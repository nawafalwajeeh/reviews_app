import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/widgets/list_tiles/settings_menu_tile.dart';
import '../../../../../data/services/localization/localization_service.dart';
import '../../locale/select_language.dart';

class LanguageSwitchWidget extends StatelessWidget {
  const LanguageSwitchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService.instance;

    return Obx(() {
      // Get current language code
      final currentLang = localizationService.currentLanguage;

      // Map language codes to flags
      final Map<String, String> languageFlags = {
        'ar': '🇾🇪', // Yemen flag for Arabic
        'en': '🇺🇸',
        'fr': '🇫🇷',
        'de': '🇩🇪',
        'es': '🇪🇸',
        'hi': '🇮🇳',
        'ko': '🇰🇷',
        'zh': '🇨🇳',
        'ja': '🇯🇵',
        'pt': '🇵🇹',
        'it': '🇮🇹',
        'ru': '🇷🇺',
      };

      // Get flag and language name
      final flag = languageFlags[currentLang] ?? '🌐';
      final languageName = localizationService.getCurrentLanguageName();

      // Combine flag and name for display
      final displayText = '$flag $languageName';

      return SettingsMenuTile(
        icon: Iconsax.language_square,
        // title: AppLocalizations.of(context).language,
        title: localizationService.currentLanguage,
        subTitle: displayText,
        onTap: () {
          // Navigate to your beautiful full-screen language selection
          Get.to(() => SelectLanguageScreen(isFromSettings: true));
        },
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      );
    });
  }
}

//-------------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../../common/widgets/list_tiles/settings_menu_tile.dart';
// import '../../../../../localization/app_localizations.dart';
// import '../../../../../data/services/localization/localization_service.dart';

// class LanguageSwitchWidget extends StatelessWidget {
//   const LanguageSwitchWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final localizationService = LocalizationService.instance;

//     return Obx(
//       () => SettingsMenuTile(
//         icon: Icons.language,
//         title: AppLocalizations.of(context).chooseLanguage,
//         subTitle: localizationService.getCurrentLanguageName(),
//         trailing: DropdownButton<String>(
//           value: localizationService.currentLanguage,
//           onChanged: (String? newValue) {
//             if (newValue != null) {
//               localizationService.changeLanguage(newValue);
//             }
//           },
//           items: localizationService.supportedLanguages.entries.map((entry) {
//             return DropdownMenuItem<String>(
//               value: entry.key,
//               child: Text(entry.value),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }
