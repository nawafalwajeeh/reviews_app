import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/localization/localization_service.dart';

class LocalizedWidget extends StatelessWidget {
  final Widget child;
  
  const LocalizedWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final localizationService = Get.find<LocalizationService>();
    
    return Obx(() => Directionality(
      textDirection: localizationService.textDirection,
      child: child,
    ));
  }
}