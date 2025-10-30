// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../../common/widgets/place/category/category_card.dart';

import 'package:flutter/material.dart';

import '../../../../common/widgets/place/category/category_card.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Categories'),
        // Match the AppBar style to your primary color
        // backgroundColor: AppColors.primaryColor,
        // foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          // Set to 4 columns as requested
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          // Set a slightly taller ratio to prevent text overflow
          childAspectRatio: 0.85,
          // children: .map((category) {
          //   return CategoryCard(
          //     title: category.title,
          //     icon: category.icon,
          //     gradientColors: category.gradientColors,
          //     iconColor: category.iconColor,
          //     onTap: () {
          //       // Placeholder action when a category is tapped
          //       Get.snackbar('Selected', 'Navigating to places in ${category.title}',
          //           snackPosition: SnackPosition.BOTTOM);
          //       // You would replace this with Get.to(() => PlacesScreen(category: category))
          //     },
          //   );
          // }).toList(),
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
          ],
        ),
      ),
    );
  }
}
