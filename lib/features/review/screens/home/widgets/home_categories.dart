import 'package:flutter/material.dart';
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
          gradientColors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
          iconColor: Colors.white,
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),

        CategoryCard(
          title: 'Hotels',
          icon: Icons.hotel_rounded,
          gradientColors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          iconColor: Colors.white,
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),

        CategoryCard(
          title: 'Hospitals',
          icon: Icons.local_hospital_rounded,
          gradientColors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          iconColor: Colors.white,
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),
        CategoryCard(
          title: 'Groceries',
          icon: Icons.local_grocery_store_rounded,
          gradientColors: [Color(0xFFFFECD2), Color(0xFFFCB69F)],
          iconColor: Color(0xFF8B4513),
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),
        CategoryCard(
          title: 'Gas Stations',
          icon: Icons.local_gas_station_rounded,
          gradientColors: [Color(0xFFFA709A), Color(0xFFFEE140)],
          iconColor: Colors.white,
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),
        CategoryCard(
          title: 'Gyms',
          icon: Icons.fitness_center_rounded,
          gradientColors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
          iconColor: Colors.white,
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),
        CategoryCard(
          title: 'Schools',
          icon: Icons.school_rounded,
          gradientColors: [Color(0xFFFD79A8), Color(0xFFFDBB2D)],
          iconColor: Colors.white,
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),
        CategoryCard(
          title: 'More',
          icon: Icons.more_horiz_rounded,
          gradientColors: [Color(0xFFA8EDEA), Color(0xFFFED6E3)],
          iconColor: Color(0xFF8B4513),
          // onTap: () => Get.to(() => const AllPlacesScreen()),
        ),
      ],
    );
  }
}
