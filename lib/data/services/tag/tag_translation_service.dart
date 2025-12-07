import 'package:flutter/material.dart';

class TagTranslationService {
  // Singleton instance
  static final TagTranslationService _instance = TagTranslationService._internal();
  factory TagTranslationService() => _instance;
  TagTranslationService._internal();

  // Translation map: English -> Arabic
  static final Map<String, String> _englishToArabic = {
    // General
    'Family Friendly': 'ملائم للعائلة',
    'Pet Friendly': 'ملائم للحيوانات الأليفة',
    'Budget Friendly': 'اقتصادي',
    'Luxury': 'فاخر',
    'Romantic': 'رومانسي',
    'Business': 'أعمال',
    'Student Friendly': 'ملائم للطلاب',

    // Location Types
    'Outdoor': 'في الهواء الطلق',
    'Indoor': 'داخلي',
    'Beachfront': 'مطل على الشاطئ',
    'Mountain View': 'مطل على الجبل',
    'City Center': 'وسط المدينة',
    'Suburban': 'ضواحي',
    'Rural': 'ريفي',

    // Amenities
    'Free WiFi': 'واي فاي مجاني',
    'Parking Available': 'موقف سيارات متاح',
    'Wheelchair Accessible': 'ملائم لكرسي المقعدين',
    'Air Conditioned': 'مكيف',
    'Heating': 'تدفئة',
    'Swimming Pool': 'مسبح',
    'Gym': 'صالة رياضية',
    'Spa': 'منتجع صحي',

    // Activities
    'Live Music': 'موسيقى حية',
    'Sports Bar': 'بار رياضي',
    'Gaming': 'ألعاب',
    'Karaoke': 'كاريوكي',
    'Dance Floor': 'رقص',
    'Quiet Atmosphere': 'جو هادئ',

    // Food & Drink
    'Vegetarian Options': 'خيارات نباتية',
    'Vegan Options': 'خيارات نباتية صرفة',
    'Gluten-Free Options': 'خيارات خالية من الغلوتين',
    'Halal': 'حلال',
    'Alcohol Served': 'يقدم الكحول',
    'Coffee Shop': 'مقهى',
    'Fine Dining': 'مطعم فاخر',
    'Fast Food': 'وجبات سريعة',
    'Buffet': 'بوفيه',

    // Accommodation
    'Hotel': 'فندق',
    'Hostel': 'نزل',
    'Resort': 'منتجع',
    'Vacation Rental': 'تأجير عطلات',
    'Camping': 'تخييم',

    // Entertainment
    'Cinema': 'سينما',
    'Theater': 'مسرح',
    'Museum': 'متحف',
    'Art Gallery': 'معرض فني',
    'Shopping': 'تسوق',
    'Amusement Park': 'ملاهي',

    // Services
    '24/7': 'مفتوح 24/7',
    'Delivery': 'توصيل',
    'Takeaway': 'طَلَبٌ لِخَارِجِ الـمَطْعَم',
    'Reservations': 'حجوزات',
    'Catering': 'خدمات التموين',
    'Event Space': 'مكان فعاليات',

    // Special Features
    'Historic': 'تاريخي',
    'Modern': 'حديث',
    'Traditional': 'تقليدي',
    'Eco-Friendly': 'صديق للبيئة',
    'LGBTQ+ Friendly': 'ملائم لمجتمع الميم',
    'Kid Friendly': 'ملائم للأطفال',
  };

  // Get translated tag name
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

  // Get all available English tags
  List<String> get allEnglishTags => _englishToArabic.keys.toList();

  // Get all available Arabic tags
  List<String> get allArabicTags => _englishToArabic.values.toList();

  // Get localized tags list for current context
  List<String> getLocalizedTags(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return allEnglishTags.map((tag) => getTranslatedName(tag, locale)).toList();
  }
}