import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/place/horizontal_place_card.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/features/review/models/category_model.dart';
import 'package:reviews_app/features/review/models/place_model.dart';

class SubCategoriesScreen extends StatelessWidget {
  const SubCategoriesScreen({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final PlaceController placeController = Get.find();

    final Map<String, List<PlaceModel>> categorizedDemoPlaces = {};

    for (final catName in placeController.categories.where(
      (cat) => cat != 'All',
    )) {
      final filteredPlaces = placeController.places
          .where(
            (p) => p.category.toLowerCase().contains(catName.toLowerCase()),
          )
          .toList();

      categorizedDemoPlaces[catName] = filteredPlaces.take(3).toList();

      if (categorizedDemoPlaces[catName]!.isEmpty) {
        if (catName.toLowerCase() == 'restaurant') {
          categorizedDemoPlaces[catName]!.addAll(
            placeController.places
                .where(
                  (p) =>
                      p.title.toLowerCase().contains('restaurant') ||
                      p.category.toLowerCase().contains('italian'),
                )
                .take(2),
          );
        } else if (catName.toLowerCase() == 'hotel') {
          categorizedDemoPlaces[catName]!.addAll(
            placeController.places
                .where(
                  (p) =>
                      p.title.toLowerCase().contains('hotel') ||
                      p.category.toLowerCase().contains('resort'),
                )
                .take(2),
          );
        } else if (catName.toLowerCase() == 'cafe') {
          categorizedDemoPlaces[catName]!.addAll(
            placeController.places
                .where(
                  (p) =>
                      p.title.toLowerCase().contains('coffee') ||
                      p.category.toLowerCase().contains('cafe'),
                )
                .take(2),
          );
        } else if (catName.toLowerCase() == 'school') {
          categorizedDemoPlaces[catName]!.addAll(
            placeController.places
                .where((p) => p.title.toLowerCase().contains('school'))
                .take(2),
          );
        } else {
          categorizedDemoPlaces[catName]!.addAll(
            placeController.places.take(2),
          );
        }
      }
    }

    final List<String> subCategoryNames = placeController.categories
        .where((cat) => cat != 'All')
        .toList();

    const double placeCardHorizontalOverallHeight = 180;

    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          category.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// -- Horizontal Lists of Popular Places for Each Sub-Category
              ListView.builder(
                // itemCount: category.subCategories.length,
                itemCount: subCategoryNames.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final subCategoryName = subCategoryNames[index];
                  final placesForSubCategory =
                      categorizedDemoPlaces[subCategoryName] ?? [];

                  if (placesForSubCategory.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSectionHeading(
                        title: 'Popular $subCategoryName Spots',
                        onPressed: () {},
                      ),
                      const SizedBox(height: AppSizes.md),

                      SizedBox(
                        height: placeCardHorizontalOverallHeight,
                        child: ListView.separated(
                          itemCount: placesForSubCategory.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(
                            left: AppSizes.defaultSpace,
                          ),
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: AppSizes.md),
                          itemBuilder: (context, index) => PlaceCardHorizontal(
                            place: placesForSubCategory[index],
                            height: placeCardHorizontalOverallHeight,
                          ),
                        ),
                      ),
                      if (index < subCategoryNames.length - 1)
                        const SizedBox(height: AppSizes.spaceBtwSections),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
}
