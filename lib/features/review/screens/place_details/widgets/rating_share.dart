import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

import '../../../../../common/widgets/icons/circular_icon.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../models/place_model.dart';

class RatingAndShareWidget extends StatelessWidget {
  const RatingAndShareWidget({super.key, required this.place});
  final PlaceModel place;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Rating Display
        Row(
          children: [
            const Icon(Iconsax.star5, color: Colors.amber, size: 24),
            const SizedBox(width: AppSizes.xs),
            Text(
              place.averageRating.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: AppSizes.sm),
            Text(
              // '(${(place.rating * 10).toInt().abs() + 10} Reviews)',
              // '(${place.reviewsCount} reviews)',
              '(${place.reviewsCount} ${AppLocalizations.of(context).reviews})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),

        // Share Button
        AppCircularIcon(
          icon: Iconsax.share,
          color: AppColors.dark,
          backgroundColor: Colors.grey.shade100,
          onPressed: () {},
        ),
      ],
    );
  }
}
