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
    // final List<PlaceModel> allPlaces = controller.places;
    final List<PlaceModel> allPlaces = controller.featuredPlaces;

    final List<PlaceModel> filteredPlaces = categoryFilter == 'All'
        ? allPlaces
        : allPlaces
              .where((place) => place.categoryId == categoryFilter)
              .toList();
    if (filteredPlaces.isEmpty) {
      return Center(
        child: Text(
          'No places found for $categoryFilter.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(
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
  }
}

//TODO:----best approach will be implemented-----------
/*
import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/place/place_card.dart';
import 'package:reviews_app/common/widgets/shimmers/vertical_place_cards_shimmer.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/utils/helpers/cloud_helper_functions.dart'; // Import the helper function
import '../../../controllers/place_controller.dart';
import '../../../models/place_model.dart';

/// Renders a list of PlaceCards filtered by the given category, using FutureBuilder
/// and the same loading logic as AllProducts.
class PlaceListTab extends StatelessWidget {
  final String categoryFilter;

  const PlaceListTab({super.key, required this.categoryFilter});

  // This method gets the Future, which is equivalent to 'futureMethod ?? controller.fetchProductsByQuery(query)' 
  // in your AllProducts widget.
  Future<List<PlaceModel>> _getPlacesFuture(String categoryFilter) {
    final controller = PlaceController.instance;

    // *** IMPORTANT ***
    // You need to implement this method in your PlaceController. 
    // It should handle the actual asynchronous data fetching (e.g., Firestore query).
    return controller.fetchPlacesByCategory(categoryFilter);
  }

  @override
  Widget build(BuildContext context) {
    // The FutureBuilder handles the asynchronous data flow
    return FutureBuilder<List<PlaceModel>>(
      future: _getPlacesFuture(categoryFilter),
      builder: (_, snapshot) {
        
        // 1. Check the state of the FutureBuilder snapshot (Just like AllProducts)
        const loader = VerticalPlaceCardsShimmer(itemCount: 4); // Use the new list shimmer
        
        final widget = AppCloudHelperFunctions.checkMultiRecordState(
          snapshot: snapshot,
          loader: loader,
        );

        // 2. Return appropriate widget based on snapshot state (Shimmer, Empty, Error)
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

        // 3. Data Found (Success)
        final filteredPlaces = snapshot.data!;

        // 4. Return the successful list view (ListView.separated)
        return ListView.separated(
          // Important: Must be scrollable to fit in the Expanded TabBarView section
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
*/
