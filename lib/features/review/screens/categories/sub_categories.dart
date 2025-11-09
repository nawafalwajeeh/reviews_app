import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/appbar/appbar.dart';
import 'package:reviews_app/common/widgets/place/horizontal_place_card.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/features/review/controllers/category_controller.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';
import 'package:reviews_app/features/review/models/category_model.dart';
import 'package:reviews_app/features/review/models/place_model.dart';

class SubCategoriesScreen extends StatelessWidget {
  const SubCategoriesScreen({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final placeController = PlaceController.instance;
    final categoryController = CategoryController.instance;
    final Map<String, List<PlaceModel>> categorizedDemoPlaces = {};

    for (final catName in categoryController.categories.where(
      (cat) => cat != 'All',
    )) {
      final filteredPlaces = placeController.places
          .where(
            (p) => p.categoryId.toLowerCase().contains(catName.toLowerCase()),
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
                      p.categoryId.toLowerCase().contains('italian'),
                )
                .take(2),
          );
        } else if (catName.toLowerCase() == 'hotel') {
          categorizedDemoPlaces[catName]!.addAll(
            placeController.places
                .where(
                  (p) =>
                      p.title.toLowerCase().contains('hotel') ||
                      p.categoryId.toLowerCase().contains('resort'),
                )
                .take(2),
          );
        } else if (catName.toLowerCase() == 'cafe') {
          categorizedDemoPlaces[catName]!.addAll(
            placeController.places
                .where(
                  (p) =>
                      p.title.toLowerCase().contains('coffee') ||
                      p.categoryId.toLowerCase().contains('cafe'),
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

    final List<String> subCategoryNames = categoryController.categories
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
                        height: 180,
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


//------Backend code--------------
/* 
import 'package:flutter/material.dart';
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
    final controller = PlaceController.instance;

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
            children: [
              // Banner
              if ((category.image ?? '').isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(120),
                  child: Image.network(
                    category.image!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                )
              else
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    category.name.isNotEmpty ? category.name[0].toUpperCase() : '',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Sub-categories (async)
              FutureBuilder<List<CategoryModel>>(
                future: controller.getSubCategories(categoryId: category.id),
                builder: (context, snapshot) {
                  final widget = _checkSnapshotState(
                    snapshot: snapshot,
                    loader: const _HorizontalPlaceShimmer(),
                  );
                  if (widget != null) return widget;

                  final subCategories = snapshot.data!;

                  return ListView.builder(
                    itemCount: subCategories.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final sub = subCategories[index];

                      return FutureBuilder<List<PlaceModel>>(
                        future: controller.getCategoryPlaces(categoryId: sub.id),
                        builder: (context, snapshot2) {
                          final widget2 = _checkSnapshotState(
                            snapshot: snapshot2,
                            loader: const _HorizontalPlaceShimmer(),
                          );
                          if (widget2 != null) return widget2;

                          final places = snapshot2.data!;

                          if (places.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppSectionHeading(
                                title: sub.name,
                                onPressed: () {},
                              ),
                              const SizedBox(height: AppSizes.spaceBtwItems / 2),
                              SizedBox(
                                height: 180,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.only(left: AppSizes.defaultSpace),
                                  itemCount: places.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: AppSizes.spaceBtwItems),
                                  itemBuilder: (context, i) => PlaceCardHorizontal(
                                    place: places[i],
                                    height: 180,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSizes.spaceBtwSections),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
*/