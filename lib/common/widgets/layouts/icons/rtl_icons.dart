import 'package:flutter/material.dart';

class RTLIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  const RTLIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    IconData rtlIcon = icon;

    // Map common icons to their RTL equivalents
    if (Directionality.of(context) == TextDirection.rtl) {
      rtlIcon = _getRTLIcon(icon);
    }

    return Icon(
      rtlIcon,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
  }

  IconData _getRTLIcon(IconData icon) {
    switch (icon) {
      case Icons.arrow_back:
        return Icons.arrow_forward;
      case Icons.arrow_forward:
        return Icons.arrow_back;
      case Icons.arrow_back_ios:
        return Icons.arrow_forward_ios;
      case Icons.arrow_forward_ios:
        return Icons.arrow_back_ios;
      case Icons.chevron_left:
        return Icons.chevron_right;
      case Icons.chevron_right:
        return Icons.chevron_left;
      case Icons.navigate_before:
        return Icons.navigate_next;
      case Icons.navigate_next:
        return Icons.navigate_before;
      case Icons.keyboard_arrow_left:
        return Icons.keyboard_arrow_right;
      case Icons.keyboard_arrow_right:
        return Icons.keyboard_arrow_left;
      // Add more mappings as needed
      default:
        return icon;
    }
  }
}

// Specific commonly used RTL icons
class BackArrowIcon extends StatelessWidget {
  final double? size;
  final Color? color;

  const BackArrowIcon({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return RTLIcon(icon: Icons.arrow_back_ios, size: size, color: color);
  }
}

class ForwardArrowIcon extends StatelessWidget {
  final double? size;
  final Color? color;

  const ForwardArrowIcon({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return RTLIcon(icon: Icons.arrow_forward_ios, size: size, color: color);
  }
}

class ChevronRightIcon extends StatelessWidget {
  final double? size;
  final Color? color;

  const ChevronRightIcon({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return RTLIcon(icon: Icons.chevron_right, size: size, color: color);
  }
}
