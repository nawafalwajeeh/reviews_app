import 'package:flutter/material.dart';
import '../../../data/services/tag/tag_translation_service.dart';

/// Extension methods for List<String> to easily get localized tags
extension TagListLocalization on List<String> {
  List<String> getLocalizedTags(BuildContext context) {
    return map(
      (tag) => TagTranslationService().getTranslatedNameInContext(tag, context),
    ).toList();
  }

  // Helper method to find English tag from localized tag
  String? findEnglishTag(String localizedTag, BuildContext context) {
    final englishTags = TagTranslationService().allEnglishTags;
    for (final englishTag in englishTags) {
      final translated = TagTranslationService().getTranslatedNameInContext(
        englishTag,
        context,
      );
      if (translated == localizedTag) {
        return englishTag;
      }
    }
    return null;
  }
}
