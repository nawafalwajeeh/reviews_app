import 'package:flutter/material.dart';

class SettingsTileModel {
  final IconData icon;
  final String title;
  final String subTitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const SettingsTileModel({
    required this.icon,
    required this.title,
    required this.subTitle,
    required this.onTap,
    this.trailing,
  });
}
