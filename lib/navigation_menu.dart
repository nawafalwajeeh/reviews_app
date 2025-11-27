import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/features/review/screens/home/home.dart';
import 'package:reviews_app/features/review/screens/map/place_map.dart';
import 'package:reviews_app/features/review/screens/place/places_screen.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';
import 'features/personalization/screens/settings/settings.dart';
import 'features/review/screens/wishlist/wishlist.dart';
import 'localization/app_localizations.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final dark = AppHelperFunctions.isDarkMode(context);

    return Obx(
      () => Scaffold(
        bottomNavigationBar: NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          backgroundColor: dark ? AppColors.black : AppColors.white,
          indicatorColor: dark
              ? AppColors.white.withValues(alpha: 0.1)
              : AppColors.black.withValues(alpha: 0.1),

          // destinations: const [
          //   NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
          //   NavigationDestination(icon: Icon(Iconsax.image), label: 'Places'),
          //   NavigationDestination(icon: Icon(Iconsax.location), label: 'Map'),
          //   NavigationDestination(icon: Icon(Iconsax.heart), label: 'Wishlist'),
          //   NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
          // ],
          destinations: [
            NavigationDestination(
              icon: const Icon(Iconsax.home),
              label: AppLocalizations.of(context).navigationHome,
            ),
            NavigationDestination(
              icon: const Icon(Iconsax.image),
              label: AppLocalizations.of(context).navigationPlaces,
            ),
            NavigationDestination(
              icon: const Icon(Iconsax.location),
              label: AppLocalizations.of(context).navigationMap,
            ),
            NavigationDestination(
              icon: const Icon(Iconsax.heart),
              label: AppLocalizations.of(context).navigationWishlist,
            ),
            NavigationDestination(
              icon: const Icon(Iconsax.user),
              label: AppLocalizations.of(context).navigationProfile,
            ),
          ],
        ),

        /// -- body
        body: controller.screens[controller.selectedIndex.value],
      ),
    );
  }
}

/// -- Navigation Controller
class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();

  /// -- Variables
  final RxInt selectedIndex = 0.obs;

  /// -- Screens list
  final screens = const [
    HomeScreen(),
    AllPlacesScreen(),
    PlacesMapScreen(),
    FavouriteScreen(),
    SettingsScreen(),
  ];
}
