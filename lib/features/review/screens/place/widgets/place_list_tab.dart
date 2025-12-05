import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/sizes.dart' show AppSizes;

import '../../../../../common/widgets/place/place_card.dart';
import '../../../../../common/widgets/shimmers/big_card_shimmer.dart'
    show PlaceCardShimmer;
import '../../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../controllers/place_controller.dart';
import '../edit_place.dart';

// --- NEW HELPER WIDGET ---
/// A stateless wrapper that executes a callback immediately after the first frame
/// is built, preventing 'setState during build' errors for initial data loading.
class StatelessInitWrapper extends StatelessWidget {
  const StatelessInitWrapper({
    super.key,
    required this.onInit,
    required this.child,
  });

  final VoidCallback onInit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Schedule the state-changing call for the next frame.
    // This allows the current build cycle to complete successfully.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onInit();
    });
    return child;
  }
}
// -------------------------

class PlaceListTab extends StatelessWidget {
  PlaceListTab({super.key, required this.categoryId});

  final String categoryId;

  // Get the controller instance once
  final controller = PlaceController.instance;

  @override
  Widget build(BuildContext context) {
    return StatelessInitWrapper(
      // 1. We move the problematic call here.
      onInit: () {
        controller.streamPlacesForCategory(categoryId);
      },

      // 2. The child contains the reactive UI (Obx)
      child: Obx(() {
        final categoryPlaces = controller.categoryPlaces;
        final isLoading = controller.isLoading.value;

        // 1. HANDLE LOADING STATE
        if (isLoading && categoryPlaces.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.defaultSpace,
              vertical: AppSizes.defaultSpace / 2,
            ),
            child: PlaceCardShimmer(),
          );
        }

        // 2. HANDLE NO DATA FOUND STATE
        if (categoryPlaces.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.defaultSpace),
              child: Text(
                // 'No places found in this category.',
                AppLocalizations.of(context).noPlacesFound,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // 3. DATA FOUND STATE (Success)
        // 3. DATA FOUND STATE (Success)
        return RefreshIndicator(
          onRefresh: () async {
            controller.streamPlacesForCategory(categoryId);
            // Optional: wait a bit to show the spinner
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.defaultSpace,
              vertical: AppSizes.defaultSpace / 2,
            ),
            itemCount: categoryPlaces.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSizes.spaceBtwSections),
            itemBuilder: (context, index) {
              final place = categoryPlaces[index];

              // Determine if the current user is the creator
              bool isCreator =
                  (place.userId == AuthenticationRepository.instance.getUserID);

              return PlaceCard(
                place: place,
                showEditOptions: isCreator,
                onEdit: () {
                  if (isCreator) {
                    controller.initializeEditForm(place);
                    Get.to(() => EditPlaceScreen(place: place));
                  }
                },
                onDelete: () {
                  if (isCreator) {
                    controller.deletePlaceWithConfirmation(place);
                  }
                },
              );
            },
          ),
        );
      }),
    );
  }
}
