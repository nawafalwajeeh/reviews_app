import 'package:get/get.dart';

import '../models/category_model.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final RxInt selectedIndex = 0.obs;
  // final RxInt isSelected = 0.obs;

  bool isSelected(int index) => index == selectedIndex.value;

  final List<String> categories = [
    'All',
    'Restaurants',
    'Schools',
    'Cafes',
    'Hotels',
  ];

//   final Map<String, dynamic> iconStyleMap = {
//   // Use unique, contrasting gradients that look good against the primary blue.
//   'restaurants': {
//     'icon': Icons.restaurant_rounded,
//     'colors': [Color(0xFFFF6B6B), Color(0xFFEE5A52)], // Vibrant Red/Orange
//     'iconColor': Colors.white,
//   },
//   'hotels': {
//     'icon': Icons.hotel_rounded,
//     'colors': [Color(0xFF4ECDC4), Color(0xFF44A08D)], // Teal/Mint
//     'iconColor': Colors.white,
//   },
//   'hospitals': {
//     'icon': Icons.local_hospital_rounded,
//     'colors': [Color(0xFF667EEA), Color(0xFF764BA2)], // Blue/Purple
//     'iconColor': Colors.white,
//   },
//   'groceries': {
//     'icon': Icons.local_grocery_store_rounded,
//     'colors': [Color(0xFFFFECD2), Color(0xFFFCB69F)], // Light Peach/Cream
//     'iconColor': Color(0xFF333333), // Dark icon needed for contrast on light background
//   },
//   'gas_stations': {
//     'icon': Icons.local_gas_station_rounded,
//     'colors': [Color(0xFFFDBB2D), Color(0xFFFA890F)], // Gold/Orange
//     'iconColor': Colors.white,
//   },
//   'gyms': {
//     'icon': Icons.fitness_center_rounded,
//     'colors': [Color(0xFF00C9FF), Color(0xFF92FE9D)], // Cyan/Light Green
//     'iconColor': Colors.white,
//   },
//   'schools': {
//     'icon': Icons.school_rounded,
//     'colors': [Color(0xFF6A11CB), Color(0xFF4376E6)], // Deep Purple/Blue
//     'iconColor': Colors.white,
//   },
//   'default': {
//     'icon': Icons.category_rounded,
//     'colors': [Color(0xFFBDBDBD), Color(0xFF808080)], // Neutral Grey
//     'iconColor': Color(0xFF333333),
//   },
// };  


// final List<CategoryModel> allCategories = [
//   CategoryModel(
//     title: 'Restaurants',
//     icon: Icons.restaurant_rounded,
//     gradientColors: [const Color(0xFFFF6B6B), const Color(0xFFEE5A52)],
//     iconColor: Colors.white,
//   ),
//   CategoryModel(
//     title: 'Hotels',
//     icon: Icons.hotel_rounded,
//     gradientColors: [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
//     iconColor: Colors.white,
//   ),
//   CategoryModel(
//     title: 'Hospitals',
//     icon: Icons.local_hospital_rounded,
//     gradientColors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
//     iconColor: Colors.white,
//   ),
//   CategoryModel(
//     title: 'Groceries',
//     icon: Icons.local_grocery_store_rounded,
//     gradientColors: [const Color(0xFFFFECD2), const Color(0xFFFCB69F)],
//     iconColor: const Color(0xFF8B4513),
//   ),
//   CategoryModel(
//     title: 'Gas Stations',
//     icon: Icons.local_gas_station_rounded,
//     gradientColors: [const Color(0xFFFDBB2D), const Color(0xFFFA890F)],
//     iconColor: Colors.white,
//   ),
//   CategoryModel(
//     title: 'Gyms',
//     icon: Icons.fitness_center_rounded,
//     gradientColors: [const Color(0xFF00C9FF), const Color(0xFF92FE9D)],
//     iconColor: Colors.white,
//   ),
//   CategoryModel(
//     title: 'Schools',
//     icon: Icons.school_rounded,
//     gradientColors: [const Color(0xFF6A11CB), const Color(0xFF4376E6)],
//     iconColor: Colors.white,
//   ),
//   // Add any additional categories here that were not listed in HomeCategories
// ];

}
