// category_formatter.dart
import 'package:flutter/material.dart';

class CategoryFormatter {
  // English plural to singular mapping
  static final Map<String, String> _pluralToSingular = {
    // Food & Drink
    'Restaurants': 'Restaurant',
    'Cafes': 'Cafe',
    'Bars & Pubs': 'Bar & Pub',
    'Nightclubs': 'Nightclub',
    'Bakeries': 'Bakery',
    'Dessert Shops': 'Dessert Shop',
    'Food Trucks': 'Food Truck',

    // Accommodation & Residence
    'Hotels': 'Hotel',
    'Motels': 'Motel',
    'Hostels': 'Hostel',
    'Apartments': 'Apartment',
    'Housing Communities': 'Housing Community',

    // Health & Wellness
    'Hospitals': 'Hospital',
    'Clinics': 'Clinic',
    'Pharmacies': 'Pharmacy',
    'Dentists': 'Dentist',
    'Therapy Centers': 'Therapy Center',
    'Veterinarians': 'Veterinarian',

    // Education & Culture
    'Schools': 'School',
    'Universities': 'University',
    'Libraries': 'Library',
    'Museums': 'Museum',
    'Art Galleries': 'Art Gallery',
    'Historical Sites': 'Historical Site',

    // Entertainment & Recreation
    'Parks': 'Park',
    'Playgrounds': 'Playground',
    'Stadiums': 'Stadium',
    'Theatres': 'Theatre',
    'Movie Theatres': 'Movie Theatre',
    'Gyms': 'Gym',
    'Spas': 'Spa',
    'Fitness Studios': 'Fitness Studio',

    // Retail & Shopping
    'Malls': 'Mall',
    'Supermarkets': 'Supermarket',
    'Convenience Stores': 'Convenience Store',
    'Electronics Stores': 'Electronics Store',
    'Clothing Stores': 'Clothing Store',
    'Bookstores': 'Bookstore',
    'Hardware Stores': 'Hardware Store',
    'Pet Stores': 'Pet Store',

    // Service & Utility
    'Gas Stations': 'Gas Station',
    'Car Repair': 'Car Repair',
    'Banks': 'Bank',
    'ATMs': 'ATM',
    'Post Offices': 'Post Office',
    'Laundromats': 'Laundromat',
    'Dry Cleaners': 'Dry Cleaner',
    'Hair Salons': 'Hair Salon',
    'Barbershops': 'Barbershop',

    // Transport & Travel
    'Bus Stops': 'Bus Stop',
    'Train Stations': 'Train Station',
    'Airports': 'Airport',
    'Parking Lots': 'Parking Lot',
    'Car Rental': 'Car Rental',

    // Government & Public Safety
    'Police Stations': 'Police Station',
    'Fire Stations': 'Fire Station',
    'Government Offices': 'Government Office',

    // Spiritual & Religious
    'Churches': 'Church',
    'Mosques': 'Mosque',
    'Temples': 'Temple',

    // Business & Work
    'Offices & Coworking': 'Office & Coworking',
    'Factories & Industrial': 'Factory & Industrial',
    'Conference Centers': 'Conference Center',

    // Catch All
    'Other': 'Other',
  };

  // Arabic plural to singular mapping
  static final Map<String, String> _arabicPluralToSingular = {
    // Food & Drink
    'مطاعم': 'مطعم',
    'مقاهي': 'مقهى',
    'حانات وخمارات': 'حانة',
    'نوادي ليلية': 'نادي ليلي',
    'مخابز': 'مخبز',
    'محلات حلويات': 'محل حلويات',
    'شاحنات الطعام': 'شاحنة طعام',

    // Accommodation & Residence
    'فنادق': 'فندق',
    'موتيلات': 'موتيل',
    'نُزُل': 'نزل',
    'شقق': 'شقة',
    'مجمعات سكنية': 'مجمع سكني',

    // Health & Wellness
    'مستشفيات': 'مستشفى',
    'عيادات': 'عيادة',
    'صيدليات': 'صيدلية',
    'أطباء أسنان': 'طبيب أسنان',
    'مراكز علاجية': 'مركز علاجي',
    'أطباء بيطريون': 'طبيب بيطري',

    // Education & Culture
    'مدارس': 'مدرسة',
    'جامعات': 'جامعة',
    'مكتبات': 'مكتبة',
    'متاحف': 'متحف',
    'معارض فنية': 'معرض فني',
    'مواقع تاريخية': 'موقع تاريخي',

    // Entertainment & Recreation
    'حدائق': 'حديقة',
    'ملاعب': 'ملعب',
    'ملاعب رياضية': 'ملعب رياضي',
    'مسارح': 'مسرح',
    'دور سينما': 'دار سينما',
    'صالات رياضية': 'صالة رياضية',
    'منتجعات صحية': 'منتجع صحي',
    'استوديوهات لياقة': 'استوديو لياقة',

    // Retail & Shopping
    'مراكز تسوق': 'مركز تسوق',
    'أسواق مركزية': 'سوق مركزي',
    'متاجر صغيرة': 'متجر صغير',
    'متاجر إلكترونيات': 'متجر إلكترونيات',
    'متاجر ملابس': 'متجر ملابس',
    // 'مكتبات': 'مكتبة',
    'متاجر أدوات': 'متجر أدوات',
    'متاجر حيوانات أليفة': 'متجر حيوانات أليفة',

    // Service & Utility
    'محطات وقود': 'محطة وقود',
    'تصليح سيارات': 'تصليح سيارات',
    'بنوك': 'بنك',
    'صراف آلي': 'صراف آلي',
    'مكاتب بريد': 'مكتب بريد',
    'مغاسل': 'مغسلة',
    'مغاسل تنظيف جاف': 'مغسلة تنظيف جاف',
    'صالونات شعر': 'صالون شعر',
    'محلات حلاقة': 'محل حلاقة',

    // Transport & Travel
    'مواقف حافلات': 'موقف حافلات',
    'محطات قطار': 'محطة قطار',
    'مطارات': 'مطار',
    'مواقف سيارات': 'موقف سيارات',
    'تأجير سيارات': 'تأجير سيارات',

    // Government & Public Safety
    'مراكز شرطة': 'مركز شرطة',
    'مراكز إطفاء': 'مركز إطفاء',
    'مكاتب حكومية': 'مكتب حكومي',

    // Spiritual & Religious
    'كنائس': 'كنيسة',
    'مساجد': 'مسجد',
    'معابد': 'معبد',

    // Business & Work
    'مكاتب ومساحات عمل': 'مكتب ومساحة عمل',
    'مصانع ومناطق صناعية': 'مصنع ومنطقة صناعية',
    'مراكز مؤتمرات': 'مركز مؤتمرات',

    // Catch All
    'أخرى': 'أخرى',
  };

  /// Get singular form of a category name for any language
  static String getSingularForm(
    String pluralCategoryName, {
    String languageCode = 'en',
  }) {
    if (languageCode == 'ar') {
      return _arabicPluralToSingular[pluralCategoryName] ?? pluralCategoryName;
    }
    return _pluralToSingular[pluralCategoryName] ?? pluralCategoryName;
  }

  /// Get localized singular category name (IMPROVED VERSION)
  static String getLocalizedSingularName(
    String pluralCategoryName,
    String languageCode,
  ) {
    if (languageCode == 'ar') {
      // For Arabic, directly convert from Arabic plural to Arabic singular
      return _arabicPluralToSingular[pluralCategoryName] ?? pluralCategoryName;
    }

    // For English and other languages, use English conversion
    return _pluralToSingular[pluralCategoryName] ?? pluralCategoryName;
  }

  /// Get localized singular name using BuildContext
  static String getLocalizedSingularNameInContext(
    String pluralCategoryName,
    BuildContext context,
  ) {
    final locale = Localizations.localeOf(context).languageCode;
    return getLocalizedSingularName(pluralCategoryName, locale);
  }
}
