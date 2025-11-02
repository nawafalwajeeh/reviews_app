import 'package:flutter/material.dart';

/// -- Icon Mapping
Map<String, IconData> _iconMap = {
  'restaurant': Icons.restaurant_rounded,
  'hotel': Icons.hotel_rounded,
  'hospital': Icons.local_hospital_rounded,
  'grocery': Icons.local_grocery_store_rounded,
  'gas': Icons.local_gas_station_rounded,
  'gym': Icons.fitness_center_rounded,
  'school': Icons.school_rounded,
  'museum': Icons.museum_rounded,
  'park': Icons.park_rounded,
  'office': Icons.apartment_rounded,
  'theatre': Icons.theaters_rounded,
  'mall': Icons.shopping_bag_rounded,
  'default_icon': Icons.category,
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
