import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/helpers/helper_functions.dart';

import '../../../utils/constants/sizes.dart';

class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.text,
    required this.selected,
    this.onSelected,
  });

  final String text;
  final bool selected;
  // final void Function(bool)? onSelected;
  final void Function(String tag)? onSelected;

  @override
  Widget build(BuildContext context) {
    final isColor = AppHelperFunctions.getColor(text) != null;

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: ChoiceChip(
        label: isColor ? const SizedBox() : Text(text),
        selected: selected,
        onSelected: (_) => onSelected?.call(text),
        labelStyle: TextStyle(color: selected ? AppColors.white : null),
        avatar: isColor
            ? AppRoundedContainer(
                width: 50,
                height: 50,
                backgroundColor: AppHelperFunctions.getColor(text)!,
              )
            : null,
        // shape: isColor ? const CircleBorder() : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusXlg),
        ),
        // Make icon in the center
        labelPadding: isColor ? const EdgeInsets.all(0) : null,
        padding: isColor ? const EdgeInsets.all(0) : null,
        // backgroundColor: AppHelperFunctions.getColor(text),
        backgroundColor: selected ? AppColors.primaryColor : AppColors.grey,
      ),
    );
  }
}
