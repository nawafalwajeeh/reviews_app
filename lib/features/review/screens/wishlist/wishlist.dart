import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/headers/custom_header.dart';
import 'package:reviews_app/common/widgets/layouts/grid_layout.dart';
import 'package:reviews_app/common/widgets/place/small_place_card.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlaceController());

    return DefaultTabController(
      length: controller.categories.length,
      child: Scaffold(
        body: Column(
          children: [
            CustomHeader(
              title: 'Favorites',
              icon: Iconsax.sort,
              isFavorite: true,
              // icon: Iconsax.add,
              // onPressed: () => Get.to(() => const HomeScreen()),
            ),

            const SizedBox(height: AppSizes.spaceBtwItems),
            AppSearchContainer(text: 'Search for favorite place'),
            const SizedBox(height: AppSizes.spaceBtwItems),

            /// -- GridView Expanded ensures grid takes all remaining space
            Expanded(
              child: AppGridLayout(
                itemCount: controller.places.length,
                crossAxisCount: 2,
                mainAxisExtent: 250,
                childAspectRatio: 1.0,
                itemBuilder: (_, index) =>
                    SmallPlaceCard(place: controller.places[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
