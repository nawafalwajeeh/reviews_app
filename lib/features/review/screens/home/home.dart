import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:reviews_app/common/widgets/texts/section_heading.dart';
import 'package:reviews_app/features/review/controllers/notification_controller.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/place_controller.dart';
import '../search/search.dart';
import 'widgets/business_card.dart';
import 'widgets/home_appbar.dart';
import 'widgets/home_categories.dart';
import 'widgets/home_trendings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlaceController());
    final _ = Get.put(NotificationController());
    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshAll();
            // Also refresh other controllers if needed, e.g.
            // await NotificationController.instance.fetchNotifications();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                        // text: 'Search for Places',
                        text: AppLocalizations.of(context).searchPlaces,
                        onTap: () => Get.to(() => SearchScreen()),
                      ),
                      const SizedBox(height: AppSizes.spaceBtwSections),
                    ],
                  ),
                ),

                /// -- Categories
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.defaultSpace,
                  ),
                  child: Column(
                    children: [
                      AppSectionHeading(
                        // title: 'Popular Categories',
                        title: AppLocalizations.of(context).popularCategories,
                        showActionButton: false,
                      ),
                      SizedBox(height: AppSizes.spaceBtwItems),

                      /// -- Categories
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
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.defaultSpace,
                  ),
                  child: Column(
                    children: [
                      AppSectionHeading(
                        // title: 'Trending',
                        title: AppLocalizations.of(context).trendingPlaces,
                        showActionButton: false,
                      ),
                      SizedBox(height: AppSizes.spaceBtwItems),

                      /// -- Trendings
                      const HomeTrendings(),

                      const SizedBox(height: AppSizes.spaceBtwItems),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.spaceBtwItems),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
