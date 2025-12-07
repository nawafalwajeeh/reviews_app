import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../controllers/place_controller.dart';
import 'trending_card.dart';

class HomeTrendings extends StatefulWidget {
  const HomeTrendings({super.key});

  @override
  State<HomeTrendings> createState() => _HomeTrendingsState();
}

class _HomeTrendingsState extends State<HomeTrendings> {
  final controller = PlaceController.instance;

  Future<void> _refreshTrendings() async {
    await controller.refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final places = controller.featuredPlaces;

      if (places.isEmpty) {
        return const SizedBox.shrink();
      }

      return RefreshIndicator(
        onRefresh: _refreshTrendings,
        child: SizedBox(
          height: 285,
          width: double.infinity,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: places.length,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final place = places[index];

              return Padding(
                padding: const EdgeInsets.only(right: AppSizes.spaceBtwItems),
                child: TrendingCard(place: place),
              );
            },
          ),
        ),
      );
    });
  }
}
