import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';
// import '../../../../utils/helpers/helper_functions.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.isSelected,
    required this.title,
    this.onTap,
  });

  final bool isSelected;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // final dark = AppHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.apply(
            color: isSelected ? AppColors.light : AppColors.dark,
          ),
        ),
      ),
    );
  }
}
