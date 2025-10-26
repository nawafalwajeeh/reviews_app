import 'package:flutter/material.dart';

class CreatePlaceButton extends StatelessWidget {
  const CreatePlaceButton({super.key, this.onPressed});

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          'Create Place',
          style: Theme.of(context).textTheme.titleMedium,
          // ?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
