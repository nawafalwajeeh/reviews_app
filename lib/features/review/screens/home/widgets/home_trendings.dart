import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/sizes.dart';
import '../../../models/place_model.dart';
import 'trending_card.dart';

class HomeTrendings extends StatelessWidget {
  const HomeTrendings({super.key, required this.places});

  final List<PlaceModel> places;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 285,
      width: double.infinity,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
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
    );
  }
}
