import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/features/review/screens/categories/categories.dart';
// import 'package:reviews_app/features/review/screens/place/places_screen.dart';
// import 'package:get/get.dart';
import 'category_card.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      padding: EdgeInsets.zero,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.7,
      children: [
        CategoryCard(
          title: 'Restaurants',
          icon: Icons.restaurant_rounded,
          gradientColors: [Color(0xFF89CFF0), Color(0xFF4169E1)],
          iconColor: Color(0xFF2D3A64),
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),
        CategoryCard(
          title: 'Hotels',
          icon: Icons.hotel_rounded,
          gradientColors: [Color(0xFF89CFF0), Color(0xFF4682B4)],
          iconColor: Color(0xFF2E3A59),
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),
        CategoryCard(
          title: 'Hospitals',
          icon: Icons.local_hospital_rounded,
          gradientColors: [Color(0xFF89CFF0), Color(0xFF86A8E7)],
          iconColor: Color(0xFF2D3A64),
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),
        CategoryCard(
          title: 'Groceries',
          icon: Icons.local_grocery_store_rounded,
          gradientColors: [Color(0xFFB0E0FF), Color(0xFF5D6EA0)],
          iconColor: Color(0xFF2D3A64),
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),
        CategoryCard(
          title: 'Gas Stations',
          icon: Icons.local_gas_station_rounded,
          gradientColors: [Color(0xFFF3E7FF), Color(0xFFADD8E6)],
          iconColor: Color(0xFF2D3A64),
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),
        CategoryCard(
          title: 'Gyms',
          icon: Icons.fitness_center_rounded,
          gradientColors: [Color(0xFF9FACE6), Color(0xFFB8E1FF)],
          iconColor: Color(0xFF2D3A64),
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),
        CategoryCard(
          title: 'Schools',
          icon: Icons.school_rounded,
          gradientColors: [Color(0xFFA0C1FF), Color(0xFFC8E7FF)],
          iconColor: Color(0xFF2D3A64),
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),
        CategoryCard(
          title: 'More',
          icon: Icons.more_horiz_rounded,
          gradientColors: [Color(0xFFBEE6D8), Color(0xFFA0C1FF)],
          iconColor: Color(0xFF2D3A64),
          onTap: () => Get.to(() => const AllCategoriesScreen()),
        ),
      ],
    );
  }
}
