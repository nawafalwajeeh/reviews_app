import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/common/widgets/place/category/category_tag.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../../../../common/widgets/list_tiles/place_meta_data_tile.dart';
import '../../../models/place_model.dart';

class PlaceMetadata extends StatelessWidget {
  const PlaceMetadata({super.key, required this.place});
  final PlaceModel place;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          place.title,
          style: Theme.of(context).textTheme.headlineMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSizes.sm),

        // Category Tag
        CategoryTagWidget(text: place.category),
        const SizedBox(height: AppSizes.spaceBtwItems),

        // Location
        PlaceDetailsMetadataTile(text: place.title, icon: Iconsax.location),

        const SizedBox(height: AppSizes.spaceBtwItems),
        PlaceDetailsMetadataTile(text: '+967 778228445', icon: Iconsax.mobile),
        const SizedBox(height: AppSizes.spaceBtwItems),
        PlaceDetailsMetadataTile(
          text: 'Open: 11:00 AM - 10:00 PM',
          icon: Iconsax.box_time,
        ),
      ],
    );
  }
}
