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
//         title: AppLocalizations.of(context).locale.languageCode == 'ar'
//             ? 'تغيير اللغة'
//             : 'Change Language',

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



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../common/widgets/list_tiles/settings_menu_tile.dart';
import '../../../../../localization/app_localizations.dart';
import '../../../../../data/services/localization/localization_service.dart';

class LanguageSwitchWidget extends StatelessWidget {
  const LanguageSwitchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService.instance;

    return Obx(
      () => SettingsMenuTile(
        icon: Icons.language,
        title: AppLocalizations.of(context).chooseLanguage,
        subTitle: localizationService.getCurrentLanguageName(),
        trailing: DropdownButton<String>(
          value: localizationService.currentLanguage,
          onChanged: (String? newValue) {
            if (newValue != null) {
              localizationService.changeLanguage(newValue);
            }
          },
          items: localizationService.supportedLanguages.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
