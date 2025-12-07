import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;

  const NotificationIcon({super.key, required this.icon, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          stops: const [0, 1],
          begin: const AlignmentDirectional(1, -1),
          end: const AlignmentDirectional(-1, 1),
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}