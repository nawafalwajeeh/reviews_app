import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/data/services/localization/localization_service.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class AppProfileMenu extends StatelessWidget {
  const AppProfileMenu({
    super.key,
    this.icon = Iconsax.arrow_right_34,
    this.onPressed,
    required this.title,
    required this.value,
    this.isArrowIcon = true,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String title, value;
  final bool isArrowIcon;

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService.instance;
    final actualIcon = isArrowIcon
        ? localizationService.isRTL()
              ? Icons.arrow_forward_ios
              : icon
        : icon;

    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.spaceBtwItems / 1.5,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Expanded(child: Icon(icon, size: AppSizes.iconSm)),
            Expanded(child: Icon(actualIcon, size: AppSizes.iconSm)),
          ],
        ),
      ),
    );
  }
}
