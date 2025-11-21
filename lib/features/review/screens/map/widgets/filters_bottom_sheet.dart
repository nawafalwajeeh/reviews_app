// import 'package:flutter/material.dart';
// import 'package:reviews_app/utils/constants/colors.dart';

// import '../../../../../utils/constants/sizes.dart';
// import '../../../controllers/map_controller.dart';

// class FiltersBottomSheet extends StatelessWidget {
//   final MapController controller;

//   const FiltersBottomSheet({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(AppSizes.defaultSpace),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
//           SizedBox(height: AppSizes.md),
          
//           // Category Filter
//           DropdownButtonFormField<String>(
//             initialValue: controller.currentFilter.value.category,
//             items: controller.availableCategories.map((category) {
//               return DropdownMenuItem(
//                 value: category,
//                 child: Text(category.replaceAll('_', ' ')),
//               );
//             }).toList(),
//             onChanged: (value) {
//               if (value != null) {
//                 controller.updateFilter(
//                   controller.currentFilter.value.copyWith(category: value),
//                 );
//               }
//             },
//           ),
          
//           SizedBox(height: AppSizes.md),
          
//           // Rating Filter
//           Row(
//             children: [
//               Text('Minimum rating:'),
//               SizedBox(width: AppSizes.sm),
//               ...List.generate(5, (index) {
//                 return IconButton(
//                   icon: Icon(
//                     index < controller.currentFilter.value.minRating.round() 
//                         ? Icons.star 
//                         : Icons.star_border,
//                     color: AppColors.warning,
//                   ),
//                   onPressed: () {
//                     controller.updateFilter(
//                       controller.currentFilter.value.copyWith(minRating: index + 1.0),
//                     );
//                   },
//                 );
//               }),
//             ],
//           ),
          
//           SizedBox(height: AppSizes.md),
          
//           // Open Now Filter
//           SwitchListTile(
//             title: Text('Open now'),
//             value: controller.currentFilter.value.openNow,
//             onChanged: (value) {
//               controller.updateFilter(
//                 controller.currentFilter.value.copyWith(openNow: value),
//               );
//             },
//           ),
          
//           SizedBox(height: AppSizes.md),
          
//           // Radius Filter
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Search radius: ${controller.currentFilter.value.radius.round()}m'),
//               Slider(
//                 value: controller.currentFilter.value.radius,
//                 min: 1000,
//                 max: 20000,
//                 divisions: 19,
//                 onChanged: (value) {
//                   controller.updateFilter(
//                     controller.currentFilter.value.copyWith(radius: value),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }