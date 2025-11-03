import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/place/place_card.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../controllers/place_controller.dart';
import '../../../models/place_model.dart';

/// Renders a list of PlaceCards filtered by the given category.
class PlaceListTab extends StatelessWidget {
  final String categoryFilter;

  const PlaceListTab({super.key, required this.categoryFilter});

  @override
  Widget build(BuildContext context) {
    final controller = PlaceController.instance;
    // 1. Get the list of places.
    // Use Obx or GetX to react to changes in the full list if it's coming from state management.
    final List<PlaceModel> allPlaces = controller.places;
    // 2. Filter the places based on the category.
    final List<PlaceModel> filteredPlaces = categoryFilter == 'All'
        ? allPlaces
        : allPlaces.where((place) => place.categoryId == categoryFilter).toList();
    if (filteredPlaces.isEmpty) {
      return Center(
        child: Text(
          'No places found for $categoryFilter.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    // 3. Use ListView.separated to display the filtered list.
    return ListView.separated(
      // Padding is added directly to the ListView instead of the parent Padding widget in the screen.
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.defaultSpace,
        vertical: AppSizes.defaultSpace / 2,
      ),
      itemCount: filteredPlaces.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppSizes.spaceBtwSections),
      itemBuilder: (context, index) {
        final place = filteredPlaces[index];

        // 4. Use the unified PlaceCard for every item.
        return PlaceCard(place: place);
      },
    );
  }
}
//------------------------
// import 'package:flutter/material.dart';
// import 'package:reviews_app/common/widgets/place/place_card.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';

// import '../../../controllers/place_controller.dart';
// import '../../../models/place_model.dart';

// /// Renders a list of PlaceCards filtered by the given category.
// class PlaceListTab extends StatelessWidget {
//   final String categoryFilter;
//   const PlaceListTab({super.key, required this.categoryFilter});

//   @override
//   Widget build(BuildContext context) {
//     final controller = PlaceController.instance;

//     // 1. Get the list of places.
//     // Use Obx or GetX to react to changes in the full list if it's coming from state management.
//     final List<PlaceModel> allPlaces = controller.demoPlaces;

//     // 2. Filter the places based on the category.
//     final List<PlaceModel> filteredPlaces = categoryFilter == 'All'
//         ? allPlaces
//         : allPlaces
//             .where((place) => place.category == categoryFilter)
//             .toList();

//     if (filteredPlaces.isEmpty) {
//       return Center(
//         child: Text(
//           'No places found for $categoryFilter.',
//           style: Theme.of(context).textTheme.bodyLarge,
//         ),
//       );
//     }

//     // 3. Use ListView.separated to display the filtered list.
//     return ListView.separated(
//       // Padding is added directly to the ListView instead of the parent Padding widget in the screen.
//       padding: const EdgeInsets.symmetric(
//           horizontal: AppSizes.defaultSpace, vertical: AppSizes.defaultSpace / 2),
      
//       itemCount: filteredPlaces.length,
      
//       separatorBuilder: (_, _) => const SizedBox(height: AppSizes.spaceBtwSections),
      
//       itemBuilder: (context, index) {
//         final place = filteredPlaces[index];
//         // 4. Use the unified PlaceCard for every item.
//         return PlaceCard(place: place);
//       },
//     );
//   }
// }
