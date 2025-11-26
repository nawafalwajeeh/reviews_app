import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/common/widgets/chips/choice_chip.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

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
        const SizedBox(height: AppSizes.xs),
        Obx(
          () => Wrap(
            // spacing: 8,
            // runSpacing: 8,
            spacing: 2,
            runSpacing: 2,
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
