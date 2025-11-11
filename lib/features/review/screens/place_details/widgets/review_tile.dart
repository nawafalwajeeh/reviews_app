//TODO: Remove this file if not used
// import 'package:flutter/material.dart';

// import '../../../models/review_model.dart';

// class ReviewTile extends StatelessWidget {
//   final ReviewModel review;

//   const ReviewTile({super.key, required this.review});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(
//           context,
//         ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 backgroundImage: NetworkImage(review.avatarUrl),
//                 radius: 20,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       review.userName,
//                       style: const TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                     Text(
//                       review.timeAgo,
//                       style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 children: List.generate(
//                   5,
//                   (index) => Icon(
//                     index < review.rating ? Icons.star : Icons.star_border,
//                     color: const Color(0xFFFFCC00),
//                     size: 16,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(review.comment, style: const TextStyle(height: 1.4)),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               IconButton(
//                 onPressed: () {},
//                 icon: Icon(Icons.thumb_up, color: Colors.grey[600], size: 18),
//               ),
//               Text(
//                 '${review.likes}',
//                 style: TextStyle(color: Colors.grey[600]),
//               ),
//               const SizedBox(width: 16),
//               TextButton(
//                 onPressed: () {},
//                 child: Text(
//                   'Reply',
//                   style: TextStyle(
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
