import 'package:flutter/material.dart';
import 'package:reviews_app/common/widgets/chips/choice_chip.dart';
import 'package:reviews_app/utils/constants/sizes.dart';

class LabeledChips extends StatelessWidget {
  final String label;
  final List<String> options;

  const LabeledChips({super.key, required this.label, required this.options});

  // final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            // final selected = _selected.contains(option);
            return AppChoiceChip(
              text: option,
              // selected: selected,
              selected: false,
              onSelected: (value) {
                // setState(() {
                //   if (val) {
                //     _selected.add(option);
                //   } else {
                //     _selected.remove(option);
                //   }
                // });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
