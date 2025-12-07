import 'package:flutter/material.dart';

import 'category_formatter.dart';

class CategoryTranslationService {
  // Singleton instance
  static final CategoryTranslationService _instance =
      CategoryTranslationService._internal();
  factory CategoryTranslationService() => _instance;
  CategoryTranslationService._internal();

  // Translation map: English -> Arabic
  static final Map<String, String> _englishToArabic = {
    'All': 'الكل',
    'Restaurants': 'مطاعم',
    'Cafes': 'مقاهي',
    'Bars & Pubs': 'حانات وخمارات',
    'Nightclubs': 'نوادي ليلية',
    'Bakeries': 'مخابز',
    'Dessert Shops': 'محلات حلويات',
    'Food Trucks': 'شاحنات الطعام',
    'Hotels': 'فنادق',
    'Motels': 'موتيلات',
    'Hostels': 'نُزُل',
    'Apartments': 'شقق',
    'Housing Communities': 'مجمعات سكنية',
    'Hospitals': 'مستشفيات',
    'Clinics': 'عيادات',
    'Pharmacies': 'صيدليات',
    'Dentists': 'أطباء أسنان',
    'Therapy Centers': 'مراكز علاجية',
    'Veterinarians': 'أطباء بيطريون',
    'Schools': 'مدارس',
    'Universities': 'جامعات',
    'Libraries': 'مكتبات',
    'Museums': 'متاحف',
    'Art Galleries': 'معارض فنية',
    'Historical Sites': 'مواقع تاريخية',
    'Parks': 'حدائق',
    'Playgrounds': 'ملاعب',
    'Stadiums': 'ملاعب رياضية',
    'Theatres': 'مسارح',
    'Movie Theatres': 'دور سينما',
    'Gyms': 'صالات رياضية',
    'Spas': 'منتجعات صحية',
    'Fitness Studios': 'استوديوهات لياقة',
    'Malls': 'مراكز تسوق',
    'Supermarkets': 'أسواق مركزية',
    'Convenience Stores': 'متاجر صغيرة',
    'Electronics Stores': 'متاجر إلكترونيات',
    'Clothing Stores': 'متاجر ملابس',
    'Bookstores': 'مكتبات',
    'Hardware Stores': 'متاجر أدوات',
    'Pet Stores': 'متاجر حيوانات أليفة',
    'Gas Stations': 'محطات وقود',
    'Car Repair': 'تصليح سيارات',
    'Banks': 'بنوك',
    'ATMs': 'صراف آلي',
    'Post Offices': 'مكاتب بريد',
    'Laundromats': 'مغاسل',
    'Dry Cleaners': 'مغاسل تنظيف جاف',
    'Hair Salons': 'صالونات شعر',
    'Barbershops': 'محلات حلاقة',
    'Bus Stops': 'مواقف حافلات',
    'Train Stations': 'محطات قطار',
    'Airports': 'مطارات',
    'Parking Lots': 'مواقف سيارات',
    'Car Rental': 'تأجير سيارات',
    'Police Stations': 'مراكز شرطة',
    'Fire Stations': 'مراكز إطفاء',
    'Government Offices': 'مكاتب حكومية',
    'Churches': 'كنائس',
    'Mosques': 'مساجد',
    'Temples': 'معابد',
    'Offices & Coworking': 'مكاتب ومساحات عمل',
    'Factories & Industrial': 'مصانع ومناطق صناعية',
    'Conference Centers': 'مراكز مؤتمرات',
    'Other': 'أخرى',
  };

  // Get translated category name
  String getTranslatedName(String englishName, String languageCode) {
    if (languageCode == 'ar') {
      return _englishToArabic[englishName] ?? englishName;
    }
    return englishName; // Return English for any other language
  }

  // Get translated name using BuildContext
  String getTranslatedNameInContext(String englishName, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return getTranslatedName(englishName, locale);
  }

  // Check if a category name exists in translations
  bool hasTranslation(String englishName) {
    return _englishToArabic.containsKey(englishName);
  }

  // Get all available English category names
  List<String> get allEnglishCategories => _englishToArabic.keys.toList();

  // Get all available Arabic category names
  List<String> get allArabicCategories => _englishToArabic.values.toList();

  /// Get singular translated category name
  String getTranslatedSingularName(String englishName, String languageCode) {
    final singularEnglish = CategoryFormatter.getSingularForm(englishName);
    return getTranslatedName(singularEnglish, languageCode);
  }

  /// Get singular translated name using BuildContext
  String getTranslatedSingularNameInContext(
    String englishName,
    BuildContext context,
  ) {
    final singularEnglish = CategoryFormatter.getSingularForm(englishName);
    return getTranslatedNameInContext(singularEnglish, context);
  }
}
