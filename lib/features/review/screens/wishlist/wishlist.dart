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
import '../../../../localization/app_localizations.dart';
import '../../../../navigation_menu.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/cloud_helper_functions.dart';
import '../gallery/gallery.dart';

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
              title: AppLocalizations.of(context).favorites,
              // icon: Iconsax.sort,
              icon: Iconsax.image,
              isFavorite: true,
              favoriteCount: controller.favorites.length,
              onPressed: () => Get.to(() => ImageGalleryScreen()),
            ),
          ),

          const SizedBox(height: AppSizes.spaceBtwItems),
          AppSearchContainer(
            text: AppLocalizations.of(context).searchPlaces,
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
                  text: AppLocalizations.of(context).wishlistEmpty,
                  animation: AppImages.pencilAnimation,
                  showAction: true,
                  actionText: AppLocalizations.of(context).letsAddSome,
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
