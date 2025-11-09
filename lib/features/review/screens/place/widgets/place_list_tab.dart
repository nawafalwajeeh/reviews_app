import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/place/place_card.dart';
import 'package:reviews_app/common/widgets/shimmers/big_card_shimmer.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart'; // Import the helper function
import '../../../models/place_model.dart';

/// Renders a list of PlaceCards filtered by the given category, using FutureBuilder
/// and the same loading logic as AllProducts.
class PlaceListTab extends StatelessWidget {
  const PlaceListTab({
    super.key,
    required this.categoryFilter,
    this.query,
    this.futureMethod,
  });

  final String categoryFilter;
  final Query? query;
  final Future<List<PlaceModel>>? futureMethod;

  @override
  Widget build(BuildContext context) {
    // final controller = PlaceController.instance;

    return FutureBuilder<List<PlaceModel>>(
      // future: futureMethod ?? controller.fetchPlacesByQuery(query),
      future: futureMethod,
      builder: (_, snapshot) {
        // 1. Check the state of the FutureBuilder snapshot (Just like AllProducts)
        const loader = PlaceCardShimmer(); // Use the new list shimmer

        final widget = AppCloudHelperFunctions.checkMultiRecordState(
          snapshot: snapshot,
          loader: loader,
        );

        // Return appropriate widget based on snapshot state (Shimmer, Empty, Error)
        if (widget != null) {
          // Wrap the result in padding to match the original list padding
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.defaultSpace,
              vertical: AppSizes.defaultSpace / 2,
            ),
            child: widget,
          );
        }

        // Data Found (Success)
        final filteredPlaces = snapshot.data!;

        // Return the successful list view (ListView.separated)
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.defaultSpace,
            vertical: AppSizes.defaultSpace / 2,
          ),
          itemCount: filteredPlaces.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppSizes.spaceBtwSections),
          itemBuilder: (context, index) {
            final place = filteredPlaces[index];
            return PlaceCard(place: place);
          },
        );
      },
    );
  }
}


// // ---------------Original code---------------
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
//     // final List<PlaceModel> allPlaces = controller.places;
//     final List<PlaceModel> allPlaces = controller.featuredPlaces;

//     final List<PlaceModel> filteredPlaces = categoryFilter == 'All'
//         ? allPlaces
//         : allPlaces
//               .where((place) => place.categoryId == categoryFilter)
//               .toList();
//     if (filteredPlaces.isEmpty) {
//       return Center(
//         child: Text(
//           'No places found for $categoryFilter.',
//           style: Theme.of(context).textTheme.bodyLarge,
//         ),
//       );
//     }

//     return ListView.separated(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppSizes.defaultSpace,
//         vertical: AppSizes.defaultSpace / 2,
//       ),
//       itemCount: filteredPlaces.length,
//       separatorBuilder: (_, _) =>
//           const SizedBox(height: AppSizes.spaceBtwSections),
//       itemBuilder: (context, index) {
//         final place = filteredPlaces[index];

//         return PlaceCard(place: place);
//       },
//     );
//   }
// }

