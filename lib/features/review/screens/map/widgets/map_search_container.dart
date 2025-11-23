
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reviews_app/utils/constants/colors.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class MapSearchContainer extends StatelessWidget {
  final String text;
  final Function(String) onChanged;
  final VoidCallback onVoiceSearch;
  final VoidCallback? onClear;
  final bool isListening;
  final TextEditingController? controller;

  const MapSearchContainer({
    super.key,
    required this.text,
    required this.onChanged,
    required this.onVoiceSearch,
    this.onClear,
    required this.isListening,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: text,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.darkGrey,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(Iconsax.search_normal, color: AppColors.darkGrey),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller?.text.isNotEmpty == true)
                IconButton(
                  icon: Icon(Iconsax.close_circle, color: AppColors.darkGrey),
                  onPressed: onClear,
                ),
              IconButton(
                icon: Icon(
                  isListening ? Iconsax.microphone_slash : Iconsax.microphone,
                  color: isListening ? AppColors.error : AppColors.primaryColor,
                ),
                onPressed: onVoiceSearch,
              ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        ),
      ),
    );
  }
}


//---------------------
// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:reviews_app/utils/constants/colors.dart';
// import 'package:reviews_app/utils/constants/sizes.dart';
// import 'package:reviews_app/utils/device/device_utility.dart';
// import 'package:reviews_app/utils/helpers/helper_functions.dart';

// class MapSearchContainer extends StatelessWidget {
//   const MapSearchContainer({
//     super.key,
//     required this.text,
//     this.showBackground = true,
//     this.icon = Iconsax.search_normal,
//     this.showBorder = true,
//     this.onTap,
//     this.onChanged,
//     this.onSubmitted,
//     this.controller,
//     this.padding = const EdgeInsets.symmetric(
//       horizontal: AppSizes.defaultSpace,
//     ),
//     this.focusNode,
//     this.autofocus = false,
//     this.readOnly = false,
//     this.enabled = true,
//     this.showFilterIcon = true,
//     this.backgroundColor,
//     this.borderColor,
//     this.iconColor,
//     this.textColor,
//     this.hintColor,
//     this.cursorColor,
//     this.borderRadius,
//     this.contentPadding,
//     this.leadingIcon,
//     this.trailingIcon,
//     this.textStyle,
//     this.hintStyle,
//   });

//   final String text;
//   final IconData? icon;
//   final bool showBackground, showBorder;
//   final void Function()? onTap;
//   final ValueChanged<String>? onChanged;
//   final ValueChanged<String>? onSubmitted;
//   final TextEditingController? controller;
//   final EdgeInsetsGeometry padding;
//   final FocusNode? focusNode;
//   final bool autofocus;
//   final bool readOnly;
//   final bool enabled;
//   final bool showFilterIcon;

//   // Custom colors
//   final Color? backgroundColor;
//   final Color? borderColor;
//   final Color? iconColor;
//   final Color? textColor;
//   final Color? hintColor;
//   final Color? cursorColor;

//   // Custom styling
//   final double? borderRadius;
//   final EdgeInsetsGeometry? contentPadding;
//   final Widget? leadingIcon;
//   final Widget? trailingIcon;
//   final TextStyle? textStyle;
//   final TextStyle? hintStyle;

//   @override
//   Widget build(BuildContext context) {
//     final dark = AppHelperFunctions.isDarkMode(context);

//     // Default colors based on theme
//     final defaultBackgroundColor = showBackground
//         ? (dark ? AppColors.dark : AppColors.light)
//         : Colors.transparent;

//     final defaultBorderColor = dark ? AppColors.darkerGrey : AppColors.grey;
//     final defaultIconColor = dark ? AppColors.darkerGrey : AppColors.grey;
//     final defaultTextColor = dark ? AppColors.white : AppColors.dark;
//     final defaultHintColor = dark ? AppColors.darkerGrey : AppColors.grey;
//     final defaultCursorColor = AppColors.primaryColor;

//     return Padding(
//       padding: padding,
//       child: Container(
//         width: AppDeviceUtils.getScreenWidth(context),
//         padding: const EdgeInsets.all(AppSizes.md - 4),
//         decoration: BoxDecoration(
//           color: backgroundColor ?? defaultBackgroundColor,
//           borderRadius: BorderRadius.circular(
//             borderRadius ?? AppSizes.cardRadiusLg,
//           ),
//           border: showBorder
//               ? Border.all(color: borderColor ?? defaultBorderColor)
//               : null,
//           boxShadow: [
//             if (showBackground)
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.05),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//           ],
//         ),
//         child: Row(
//           children: [
//             // Leading Icon (custom or default)
//             leadingIcon ??
//                 Icon(icon, color: iconColor ?? defaultIconColor, size: 20),
//             const SizedBox(width: AppSizes.spaceBtwItems),

//             // Expanded TextField
//             Expanded(
//               child: TextField(
//                 controller: controller,
//                 focusNode: focusNode,
//                 autofocus: autofocus,
//                 readOnly: readOnly,
//                 enabled: enabled,
//                 onChanged: onChanged,
//                 onSubmitted: onSubmitted,
//                 onTap: onTap,
//                 decoration: InputDecoration(
//                   hintText: text,
//                   hintStyle:
//                       hintStyle ??
//                       Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: hintColor ?? defaultHintColor,
//                       ),
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.zero,
//                   isDense: true,
//                   // Remove any default padding
//                 ),
//                 style:
//                     textStyle ??
//                     Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: textColor ?? defaultTextColor,
//                     ),
//                 cursorColor: cursorColor ?? defaultCursorColor,
//                 textInputAction: TextInputAction.search,
//               ),
//             ),

//             const SizedBox(width: AppSizes.spaceBtwItems),

//             // Trailing Icon (custom or default filter icon)
//             if (showFilterIcon)
//               trailingIcon ??
//                   Icon(
//                     Icons.tune_rounded,
//                     color: iconColor ?? defaultIconColor,
//                     size: 20,
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
