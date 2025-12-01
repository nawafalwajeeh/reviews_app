import 'package:flutter/material.dart';

/// A widget that displays a section heading with an optional action button.
class AppSectionHeading extends StatelessWidget {
  const AppSectionHeading({
    super.key,
    required this.title,
    this.showActionButton = true,
    this.buttonTitle = 'View All',
    this.textColor,
    this.onPressed,
    this.titleStyle,
  });

  final String title, buttonTitle;
  final bool showActionButton;
  final Color? textColor;
  final void Function()? onPressed;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              titleStyle ??
              Theme.of(
                context,
              ).textTheme.headlineSmall?.apply(color: textColor),
        ),
        ?showActionButton
            ? TextButton(onPressed: onPressed, child: Text(buttonTitle))
            : null,
      ],
    );
  }
}
