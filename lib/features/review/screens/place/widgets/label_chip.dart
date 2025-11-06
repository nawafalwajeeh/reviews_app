import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/chips/choice_chip.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

// class LabeledChips extends StatelessWidget {
//   final String label;
//   final List<String> options;
//   final RxList<String> selectedTags;
//   final void Function(String tag)? onSelected;

//   const LabeledChips({
//     super.key,
//     required this.label,
//     required this.options,
//     required this.selectedTags,
//     this.onSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 8),
//         // Obx wraps the Wrap widget to rebuild whenever a tag is added/removed
//         Obx(
//           () => Wrap(
//             spacing: 8.0,
//             runSpacing: 4.0,
//             children: options.map((tag) {
//               final isSelected = selectedTags.contains(tag);
//               return AppChoiceChip(
//                 label: Text(tag),
//                 selected: isSelected,
//                 onSelected: (_) => onSelected?.call(tag),
//                 backgroundColor: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
//                 selectedColor: Colors.blue.shade300,
//                 labelStyle: TextStyle(
//                   color: isSelected ? Colors.blue.shade900 : Colors.black87,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   side: BorderSide(
//                     color: isSelected ? Colors.blue.shade700 : Colors.grey.shade400,
//                   ),
//                 ), text: '',
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }
// }

class LabeledChips extends StatelessWidget {
  final String label;
  final List<String> tags;
  final RxList<String> selectedTags;
  final void Function(String)? onSelected;

  const LabeledChips({
    super.key,
    required this.label,
    required this.tags,
    required this.selectedTags,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSizes.sm),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              final isSelected = selectedTags.contains(tag);
              return AppChoiceChip(
                text: tag,
                selected: isSelected,
                onSelected: onSelected,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
