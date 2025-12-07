import 'package:flutter/material.dart';
import 'package:reviews_app/utils/constants/colors.dart';

import '../curved_edges/curved_edges_widget.dart';
import 'rounded_container.dart';

class AppPrimaryHeaderContainer extends StatelessWidget {
  const AppPrimaryHeaderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCurvedEdgesWidget(
      child: Container(
        color: AppColors.primaryColor,
        padding: const EdgeInsets.all(0),
        child: Stack(
          children: [
            Positioned(
              top: -150,
              right: -250,
              child: AppRoundedContainer(
                width: 400,
                height: 400,
                radius: 400,
                backgroundColor: AppColors.textWhite.withValues(alpha: 0.1),
              ),
            ),
            Positioned(
              top: 100,
              right: -300,
              child: AppRoundedContainer(
                width: 400,
                height: 400,
                radius: 400,
                backgroundColor: AppColors.textWhite.withValues(alpha: 0.1),
              ),
            ),

            child,
          ],
        ),
      ),
    );
  }
}
