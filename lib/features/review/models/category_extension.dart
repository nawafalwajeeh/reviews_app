import 'package:flutter/material.dart';
import '../../../data/services/category/category_translation_service.dart';
import 'category_model.dart';


/// Extension methods for CategoryModel to easily get localized names
extension CategoryLocalization on CategoryModel {
  String getLocalizedName(BuildContext context) {
    return CategoryTranslationService().getTranslatedNameInContext(name, context);
  }

  String getLocalizedNameByLocale(String languageCode) {
    return CategoryTranslationService().getTranslatedName(name, languageCode);
  }
}

/// Extension methods for List<CategoryModel> to easily get localized lists
extension CategoryListLocalization on List<CategoryModel> {
  List<String> getLocalizedNames(BuildContext context) {
    return map((category) => category.getLocalizedName(context)).toList();
  }

  List<CategoryModel> getLocalizedCategories(BuildContext context) {
    return map((category) => category.copyWith(
      localizedName: category.getLocalizedName(context),
    )).toList();
  }
}