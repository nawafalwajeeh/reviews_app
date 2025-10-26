import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/place_controller.dart';
import 'widgets/business_card.dart';
import 'widgets/home_appbar.dart';
import 'widgets/home_categories.dart';
import 'widgets/home_trendings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlaceController());
    return GestureDetector(
      onTap: () {},
      // onTap: () => FocusScope.of(context).unfocus();
      child: Scaffold(
        // key: scaffoldKey,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPrimaryHeaderContainer(
                child: Column(
                  children: [
                    /// -- AppBar
                    const HomeAppBar(),
                    const SizedBox(height: AppSizes.spaceBtwSections),

                    /// -- SearchBar
                    AppSearchContainer(
                      text: 'Search for Places',
                      // onTap: () => Get.to(() => SearchScreen()),
                    ),
                    const SizedBox(height: AppSizes.spaceBtwSections),
                  ],
                ),
              ),

              /// -- Categories
              const Padding(
                // padding: EdgeInsets.all(AppSizes.defaultSpace),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.defaultSpace,
                ),
                child: Column(
                  children: [
                    AppSectionHeading(
                      title: 'Popular Categories',
                      showActionButton: false,
                    ),
                    SizedBox(height: AppSizes.spaceBtwItems),

                    /// Categories
                    HomeCategories(),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              /// -- Business Card
              BusinessCard(),
              const SizedBox(height: AppSizes.spaceBtwSections),

              /// -- Trending
              Padding(
                // padding: EdgeInsets.all(AppSizes.defaultSpace),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.defaultSpace,
                ),
                child: Column(
                  children: [
                    AppSectionHeading(
                      title: 'Trending',
                      showActionButton: false,
                    ),
                    SizedBox(height: AppSizes.spaceBtwItems),

                    /// Trending
                    HomeTrendings(places: controller.demoPlaces),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwItems),
            ],
          ),
        ),
      ),
    );
  }
}
