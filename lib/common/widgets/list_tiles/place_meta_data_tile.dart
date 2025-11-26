import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

class PlaceDetailsMetadataTile extends StatelessWidget {
  const PlaceDetailsMetadataTile({
    super.key,
    required this.text,
    required this.icon,
    this.showTrailing = false,
    this.trailingIcon = Icons.arrow_forward_ios,
    this.onTap,
    this.textStyle,
  });

  final IconData icon;
  final String text;
  final bool showTrailing;
  final IconData trailingIcon;
  final VoidCallback? onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey, size: AppSizes.iconMd),
          const SizedBox(width: AppSizes.xs),
          Expanded(
            child: Text(
              text,
              style: textStyle  ?? Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showTrailing)
            Icon(trailingIcon, color: AppColors.grey, size: AppSizes.iconSm),
        ],
      ),
    );
  }
}


//----------------------------
// import 'package:flutter/material.dart';
// import '../../../utils/constants/colors.dart';
// import '../../../utils/constants/sizes.dart';

// class PlaceDetailsMetadataTile extends StatelessWidget {
//   const PlaceDetailsMetadataTile({
//     super.key,
//     required this.text,
//     required this.icon,
//   });

//   final IconData icon;
//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, color: AppColors.grey, size: AppSizes.iconMd),
//         const SizedBox(width: AppSizes.xs),
//         Flexible(
//           child: Text(
//             text,
//             style: Theme.of(context).textTheme.bodyMedium,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }
