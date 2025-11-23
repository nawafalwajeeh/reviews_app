import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/headers/custom_header.dart';
import 'package:reviews_app/common/widgets/layouts/grid_layout.dart';
import 'package:reviews_app/common/widgets/place/small_place_card.dart';
import 'package:reviews_app/common/widgets/shimmers/vertical_place_shimmer.dart';
import 'package:reviews_app/features/review/controllers/favourite_controller.dart';
import 'package:reviews_app/features/review/screens/search/search.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/loaders/animation_loader.dart';
import '../../../../navigation_menu.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/cloud_helper_functions.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FavouritesController.instance;

    return Scaffold(
      body: Column(
        children: [
          Obx(
            () => CustomHeader(
              title: 'Favorites',
              icon: Iconsax.sort,
              isFavorite: true,
              // icon: Iconsax.add,
              // onPressed: () => Get.to(() => const HomeScreen()),
              favoriteCount: controller.favorites.length,
            ),
          ),

          const SizedBox(height: AppSizes.spaceBtwItems),
          AppSearchContainer(
            text: 'Search for favorite place',
            onTap: () => Get.to(() => SearchScreen()),
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),

          /// -- GridView Expanded ensures grid takes all remaining space
          Obx(
            () => FutureBuilder(
              future: controller.favoritePlaces(),
              builder: (context, snapshot) {
                /// Handle loader, Empty, Error
                const loader = AppVerticalPlaceShimmer(itemCount: 4);

                /// Empty widget
                final emptyWidget = AppAnimationLoaderWidget(
                  text: 'Whoops! Wishlist is Empty...',
                  animation: AppImages.pencilAnimation,
                  showAction: true,
                  actionText: "Let's add some",
                  onActionPressed: () {
                    Get.off(
                      () => const NavigationMenu(),
                      arguments:
                          NavigationController.instance.selectedIndex.value = 0,
                    );
                  },
                );
                final widget = AppCloudHelperFunctions.checkMultiRecordState(
                  snapshot: snapshot,
                  loader: loader,
                  nothingFound: emptyWidget,
                );
                if (widget != null) return widget;

                /// Record Found!
                final places = snapshot.data!;

                return Expanded(
                  child: AppGridLayout(
                    itemCount: places.length,
                    crossAxisCount: 2,
                    mainAxisExtent: 250,
                    childAspectRatio: 1.0,
                    itemBuilder: (_, index) =>
                        SmallPlaceCard(place: places[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


/*

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
*/