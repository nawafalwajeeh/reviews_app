// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../../../utils/constants/colors.dart';
// import '../../../controllers/map_controller.dart';

// class VoiceSearchButton extends StatelessWidget {
//   final MapController controller;
  
//   const VoiceSearchButton({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => AnimatedContainer(
//       duration: Duration(milliseconds: 300),
//       width: controller.isListening.value ? 200 : 50,
//       height: 50,
//       decoration: BoxDecoration(
//         color: controller.isListening.value ? AppColors.primaryColor : AppColors.white,
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: controller.isListening.value 
//           ? Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.mic, color: AppColors.white),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     controller.speechText.value,
//                     style: TextStyle(color: AppColors.white),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             )
//           : IconButton(
//               icon: Icon(Icons.mic, color: AppColors.primaryColor),
//               onPressed: controller.startListening,
//             ),
//     ));
//   }
// }