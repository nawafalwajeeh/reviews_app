import 'package:flutter/material.dart';

import 'category_model.dart';

final List<String> allCategoryNames = [
  'All',
  // --- Food & Drink ---
  'Restaurants',
  'Cafes',
  'Bars & Pubs',
  'Nightclubs',
  'Bakeries',
  'Dessert Shops',
  'Food Trucks',

  // --- Accommodation & Residence ---
  'Hotels',
  'Motels',
  'Hostels',
  'Apartments',
  'Housing Communities',

  // --- Health & Wellness ---
  'Hospitals',
  'Clinics',
  'Pharmacies',
  'Dentists',
  'Therapy Centers',
  'Veterinarians',

  // --- Education & Culture ---
  'Schools',
  'Universities',
  'Libraries',
  'Museums',
  'Art Galleries',
  'Historical Sites',

  // --- Entertainment & Recreation ---
  'Parks',
  'Playgrounds',
  'Stadiums',
  'Theatres',
  'Movie Theatres',
  'Gyms',
  'Spas',
  'Fitness Studios',

  // --- Retail & Shopping ---
  'Malls',
  'Supermarkets',
  'Convenience Stores',
  'Electronics Stores',
  'Clothing Stores',
  'Bookstores',
  'Hardware Stores',
  'Pet Stores',

  // --- Service & Utility ---
  'Gas Stations',
  'Car Repair',
  'Banks',
  'ATMs',
  'Post Offices',
  'Laundromats',
  'Dry Cleaners',
  'Hair Salons',
  'Barbershops',

  // --- Transport & Travel ---
  'Bus Stops',
  'Train Stations',
  'Airports',
  'Parking Lots',
  'Car Rental',

  // --- Government & Public Safety ---
  'Police Stations',
  'Fire Stations',
  'Government Offices',

  // --- Spiritual & Religious ---
  'Churches',
  'Mosques',
  'Temples',

  // --- Business & Work ---
  'Offices & Coworking',
  'Factories & Industrial',
  'Conference Centers',

  // --- Catch All ---
  'Other',
];

final List<CategoryModel>
allMockCategories = allCategoryNames.sublist(1).asMap().entries.map((entry) {
  final index = entry.key;
  final name = entry.value;
  final id = (index + 1).toString(); // IDs start from 1

  // Set ALL categories to featured
  const bool isFeatured = true;

  // Specific Icon Key Mapping for every category (you map these keys to your actual icons/assets)
  String iconKey;
  switch (name) {
    // Food & Drink
    case 'Restaurants':
      iconKey = 'dining_fork';
      break;
    case 'Cafes':
      iconKey = 'coffee_cup';
      break;
    case 'Bars & Pubs':
      iconKey = 'pint_glass';
      break;
    case 'Nightclubs':
      iconKey = 'disco_ball';
      break;
    case 'Bakeries':
      iconKey = 'bread_loaf';
      break;
    case 'Dessert Shops':
      iconKey = 'ice_cream';
      break;
    case 'Food Trucks':
      iconKey = 'truck_food';
      break;

    // Accommodation & Residence
    case 'Hotels':
      iconKey = 'hotel_star';
      break;
    case 'Motels':
      iconKey = 'motel_sign';
      break;
    case 'Hostels':
      iconKey = 'hostel_bed';
      break;
    case 'Apartments':
      iconKey = 'apartment_building';
      break;
    case 'Housing Communities':
      iconKey = 'community_house';
      break;

    // Health & Wellness
    case 'Hospitals':
      iconKey = 'hospital_cross';
      break;
    case 'Clinics':
      iconKey = 'medical_bag';
      break;
    case 'Pharmacies':
      iconKey = 'pharmacy_pill';
      break;
    case 'Dentists':
      iconKey = 'dental_drill';
      break;
    case 'Therapy Centers':
      iconKey = 'therapy_hands';
      break;
    case 'Veterinarians':
      iconKey = 'vet_paw';
      break;

    // Education & Culture
    case 'Schools':
      iconKey = 'school_bag';
      break;
    case 'Universities':
      iconKey = 'university_hat';
      break;
    case 'Libraries':
      iconKey = 'library_books';
      break;
    case 'Museums':
      iconKey = 'museum_pillar';
      break;
    case 'Art Galleries':
      iconKey = 'gallery_palette';
      break;
    case 'Historical Sites':
      iconKey = 'historical_monument';
      break;

    // Entertainment & Recreation
    case 'Parks':
      iconKey = 'park_bench';
      break;
    case 'Playgrounds':
      iconKey = 'playground_swing';
      break;
    case 'Stadiums':
      iconKey = 'stadium_goal';
      break;
    case 'Theatres':
      iconKey = 'theater_mask';
      break;
    case 'Movie Theatres':
      iconKey = 'cinema_reel';
      break;
    case 'Gyms':
      iconKey = 'gym_dumbbell';
      break;
    case 'Spas':
      iconKey = 'spa_stone';
      break;
    case 'Fitness Studios':
      iconKey = 'studio_weights';
      break;

    // Retail & Shopping
    case 'Malls':
      iconKey = 'mall_basket';
      break;
    case 'Supermarkets':
      iconKey = 'market_cart';
      break;
    case 'Convenience Stores':
      iconKey = 'cstore_door';
      break;
    case 'Electronics Stores':
      iconKey = 'electronics_chip';
      break;
    case 'Clothing Stores':
      iconKey = 'clothing_hanger';
      break;
    case 'Bookstores':
      iconKey = 'bookstore_open';
      break;
    case 'Hardware Stores':
      iconKey = 'hardware_wrench';
      break;
    case 'Pet Stores':
      iconKey = 'petstore_bone';
      break;

    // Service & Utility
    case 'Gas Stations':
      iconKey = 'gas_pump';
      break;
    case 'Car Repair':
      iconKey = 'car_wrench';
      break;
    case 'Banks':
      iconKey = 'bank_vault';
      break;
    case 'ATMs':
      iconKey = 'atm_machine';
      break;
    case 'Post Offices':
      iconKey = 'post_stamp';
      break;
    case 'Laundromats':
      iconKey = 'laundry_washer';
      break;
    case 'Dry Cleaners':
      iconKey = 'dryclean_shirt';
      break;
    case 'Hair Salons':
      iconKey = 'salon_scissors';
      break;
    case 'Barbershops':
      iconKey = 'barber_pole';
      break;

    // Transport & Travel
    case 'Bus Stops':
      iconKey = 'bus_stop';
      break;
    case 'Train Stations':
      iconKey = 'train_rail';
      break;
    case 'Airports':
      iconKey = 'airport_plane';
      break;
    case 'Parking Lots':
      iconKey = 'parking_sign';
      break;
    case 'Car Rental':
      iconKey = 'rental_key';
      break;

    // Government & Public Safety
    case 'Police Stations':
      iconKey = 'police_badge';
      break;
    case 'Fire Stations':
      iconKey = 'fire_truck';
      break;
    case 'Government Offices':
      iconKey = 'government_flag';
      break;

    // Spiritual & Religious
    case 'Churches':
      iconKey = 'church_cross';
      break;
    case 'Mosques':
      iconKey = 'mosque_dome';
      break;
    case 'Temples':
      iconKey = 'temple_statue';
      break;

    // Business & Work
    case 'Offices & Coworking':
      iconKey = 'office_desk';
      break;
    case 'Factories & Industrial':
      iconKey = 'factory_gear';
      break;
    case 'Conference Centers':
      iconKey = 'conference_mic';
      break;

    // Catch All
    case 'Other':
      iconKey = 'misc_question';
      break;

    default:
      iconKey =
          'default_icon'; // Should not happen with this comprehensive list
  }

  // Cycle through gradients for visual diversity (10 types)
  final gradientKey = [
    'blue_grad',
    'dark_blue_grad',
    'light_blue_grad',
    'navy_grad',
    'purple_grad',
    'red_grad',
    'green_grad',
    'yellow_grad',
    'cyan_grad',
    'indigo_grad',
  ][index % 10];

  return CategoryModel(
    id: id,
    name: name,
    image:
        '', // Keeping image empty as requested (or using an empty string placeholder)
    isFeatured: isFeatured,
    iconKey: iconKey,
    gradientKey: gradientKey,
    iconColorValue: 0xFF2D3A64,
  );
}).toList();

/// -- Icon Mapping
final Map<String, IconData> _iconMap = {
  // --- Food & Drink ---
  'dining_fork': Icons.restaurant_menu_rounded,
  'coffee_cup': Icons.local_cafe_rounded,
  'pint_glass': Icons.local_bar_rounded,
  'disco_ball': Icons.nightlife_rounded,
  'bread_loaf': Icons.cake_rounded,
  'ice_cream': Icons.icecream_rounded,
  'truck_food': Icons.fastfood_rounded,

  // --- Accommodation & Residence ---
  'hotel_star': Icons.hotel_rounded,
  'motel_sign': Icons.bed_rounded,
  'hostel_bed': Icons.group_rounded,
  'apartment_building': Icons.apartment_rounded,
  'community_house': Icons.location_city_rounded,

  // --- Health & Wellness ---
  'hospital_cross': Icons.local_hospital_rounded,
  'medical_bag': Icons.medical_services_rounded,
  'pharmacy_pill': Icons.local_pharmacy_rounded,
  'dental_drill': Icons.healing_rounded,
  'therapy_hands': Icons.psychology_rounded,
  'vet_paw': Icons.pets_rounded,

  // --- Education & Culture ---
  'school_bag': Icons.school_rounded,
  'university_hat': Icons.menu_book_rounded,
  'library_books': Icons.library_books_rounded,
  'museum_pillar': Icons.museum_rounded,
  'gallery_palette': Icons.palette_rounded,
  'historical_monument': Icons.gavel_rounded,

  // --- Entertainment & Recreation ---
  'park_bench': Icons.park_rounded,
  'playground_swing': Icons.child_friendly_rounded,
  'stadium_goal': Icons.sports_soccer_rounded,
  'theater_mask': Icons.theaters_rounded,
  'cinema_reel': Icons.movie_rounded,
  'gym_dumbbell': Icons.fitness_center_rounded,
  'spa_stone': Icons.spa_rounded,
  'studio_weights': Icons.directions_run_rounded,

  // --- Retail & Shopping ---
  'mall_basket': Icons.shopping_bag,
  'market_cart': Icons.shopping_cart_rounded,
  'cstore_door': Icons.store_rounded,
  'electronics_chip': Icons.devices_rounded,
  'clothing_hanger': Icons.checkroom_rounded,
  'bookstore_open': Icons.book_rounded,
  'hardware_wrench': Icons.hardware_rounded,
  'petstore_bone': Icons.toys_rounded,

  // --- Service & Utility ---
  'gas_pump': Icons.local_gas_station_rounded,
  'car_wrench': Icons.car_repair_rounded,
  'bank_vault': Icons.account_balance_rounded,
  'atm_machine': Icons.atm_rounded,
  'post_stamp': Icons.local_post_office_rounded,
  'laundry_washer': Icons.local_laundry_service_rounded,
  'dryclean_shirt': Icons.dry_cleaning_rounded,
  'salon_scissors': Icons.content_cut_rounded,
  'barber_pole': Icons.face_rounded,

  // --- Transport & Travel ---
  'bus_stop': Icons.bus_alert_rounded,
  'train_rail': Icons.tram_rounded,
  'airport_plane': Icons.local_airport_rounded,
  'parking_sign': Icons.local_parking_rounded,
  'rental_key': Icons.car_rental_rounded,

  // --- Government & Public Safety ---
  'police_badge': Icons.local_police_rounded,
  'fire_truck': Icons.fire_truck_rounded,
  'government_flag': Icons.corporate_fare_rounded,

  // --- Spiritual & Religious ---
  'church_cross': Icons.church_rounded,
  'mosque_dome': Icons.mosque_rounded,
  'temple_statue': Icons.self_improvement_rounded,

  // --- Business & Work ---
  'office_desk': Icons.business_center_rounded,
  'factory_gear': Icons.factory_rounded,
  'conference_mic': Icons.meeting_room_rounded,

  // --- Catch All & Default ---
  'misc_question': Icons.help_center_rounded,
  'default_icon': Icons.place_rounded,
};

/// -- Gradient Mapping (Using Hexadecimal color values for simplicity)
Map<String, List<Color>> _gradientMap = {
  'blue_grad': [const Color(0xFF89CFF0), const Color(0xFF4169E1)],
  'dark_blue_grad': [const Color(0xFF89CFF0), const Color(0xFF4682B4)],
  'light_blue_grad': [const Color(0xFF89CFF0), const Color(0xFF86A8E7)],
  'navy_grad': [const Color(0xFFB0E0FF), const Color(0xFF5D6EA0)],
  'pastel_grad': [const Color(0xFFF3E7FF), const Color(0xFFADD8E6)],
  'purple_grad': [const Color(0xFF9FACE6), const Color(0xFFB8E1FF)],
  'indigo_grad': [const Color(0xFFA0C1FF), const Color(0xFFC8E7FF)],
  'red_grad': [const Color(0xFF89CFF0), const Color(0xFF86A8E7)],
  'green_grad': [const Color(0xFF89CFF0), const Color(0xFF86A8E7)],
  'gray_grad': [const Color(0xFF89CFF0), const Color(0xFF86A8E7)],
  'yellow_grad': [const Color(0xFFB0E0FF), const Color(0xFF5D6EA0)],
  'cyan_grad': [const Color(0xFFB0E0FF), const Color(0xFF5D6EA0)],
  'default_gradient': [const Color(0xFF89CFF0), const Color(0xFF4169E1)],
};

class CategoryMapper {
  /// Maps a string key from the database to an IconData object.
  static IconData getIcon(String key) {
    return _iconMap[key.toLowerCase()] ?? _iconMap['default_icon']!;
  }

  /// Maps a string key from the database to a List of Colors (Gradient).
  static List<Color> getGradientColors(String key) {
    return _gradientMap[key.toLowerCase()] ?? _gradientMap['default_gradient']!;
  }

  /// Converts the stored integer value to a Color object.
  static Color getIconColor(int value) {
    // Ensures the value is not 0, which often leads to transparent/unseen icons.
    if (value == 0 || value == 0xFFFFFFFF) return const Color(0xFF2D3A64);
    return Color(value);
  }
}
