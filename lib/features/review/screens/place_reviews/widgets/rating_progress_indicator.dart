// widgets/overall_place_rating.dart
import 'package:flutter/material.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'progress_indicator_and_rating.dart';

class OverallPlaceRating extends StatelessWidget {
  final String rating;
  final int totalReviews;
  final Map<String, int> ratingDistribution;

  const OverallPlaceRating({
    super.key, 
    required this.rating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations =   AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rating, style: Theme.of(context).textTheme.displayLarge),
              Text(
                // '$totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}',
                '$totalReviews ${totalReviews == 1 ? appLocalizations.reviews : appLocalizations.reviews}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildRatingProgressIndicator(5),
              _buildRatingProgressIndicator(4),
              _buildRatingProgressIndicator(3),
              _buildRatingProgressIndicator(2),
              _buildRatingProgressIndicator(1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingProgressIndicator(int starRating) {
    final count = ratingDistribution[starRating.toString()] ?? 0;
    final percentage = totalReviews > 0 ? count / totalReviews : 0.0;
    
    return AppRatingProgressIndicator(
      text: starRating.toString(),
      value: percentage,
    );
  }
}
//------------------
// // widgets/overall_place_rating.dart
// import 'package:flutter/material.dart';
// import 'progress_indicator_and_rating.dart';

// class OverallPlaceRating extends StatelessWidget {
//   final String rating;
//   final int totalReviews;
//   final Map<String, int>? ratingDistribution;

//   const OverallPlaceRating({
//     super.key, 
//     required this.rating,
//     required this.totalReviews,
//     this.ratingDistribution,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           flex: 3,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(rating, style: Theme.of(context).textTheme.displayLarge),
//               Text(
//                 '$totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         Expanded(
//           flex: 7,
//           child: Column(
//             children: [
//               _buildRatingProgressIndicator(5),
//               _buildRatingProgressIndicator(4),
//               _buildRatingProgressIndicator(3),
//               _buildRatingProgressIndicator(2),
//               _buildRatingProgressIndicator(1),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRatingProgressIndicator(int starRating) {
//     if (ratingDistribution != null && totalReviews > 0) {
//       // Use real distribution data if available
//       final count = ratingDistribution![starRating.toString()] ?? 0;
//       final percentage = count / totalReviews;
//       return AppRatingProgressIndicator(
//         text: starRating.toString(),
//         value: percentage,
//       );
//     } else {
//       // Calculate estimated distribution based on average rating
//       final estimatedValue = _calculateEstimatedValue(starRating, double.parse(rating));
//       return AppRatingProgressIndicator(
//         text: starRating.toString(),
//         value: estimatedValue,
//       );
//     }
//   }

//   double _calculateEstimatedValue(int starRating, double averageRating) {
//     // Smart estimation based on average rating
//     switch (starRating) {
//       case 5:
//         return averageRating >= 4.5 ? 0.7 : 
//                averageRating >= 4.0 ? 0.5 : 
//                averageRating >= 3.5 ? 0.3 : 0.1;
//       case 4:
//         return averageRating >= 4.5 ? 0.2 : 
//                averageRating >= 4.0 ? 0.3 : 
//                averageRating >= 3.5 ? 0.4 : 0.3;
//       case 3:
//         return averageRating >= 4.5 ? 0.1 : 
//                averageRating >= 4.0 ? 0.15 : 
//                averageRating >= 3.5 ? 0.25 : 0.3;
//       case 2:
//         return averageRating >= 4.0 ? 0.05 : 
//                averageRating >= 3.0 ? 0.1 : 0.2;
//       case 1:
//         return averageRating >= 4.0 ? 0.0 : 
//                averageRating >= 3.0 ? 0.05 : 0.1;
//       default:
//         return 0.0;
//     }
//   }
// }
//--------------------------
// // widgets/overall_place_rating.dart
// import 'package:flutter/material.dart';
// import 'package:reviews_app/common/widgets/place/rating/rating_indicator.dart';

// class OverallPlaceRating extends StatelessWidget {
//   final String rating;
//   final int totalReviews;

//   const OverallPlaceRating({
//     super.key, 
//     required this.rating,
//     required this.totalReviews,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           flex: 3,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(rating, style: Theme.of(context).textTheme.displayLarge),
//               Text(
//                 '$totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         Expanded(
//           flex: 7,
//           child: Column(
//             children: [
//               AppRatingBarIndicator(rating: double.parse(rating)),
//               const SizedBox(height: 8),
//               Text(
//                 'Based on $totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

//----------------------
// import 'package:flutter/material.dart';

// import 'progress_indicator_and_rating.dart';

// class OverallPlaceRating extends StatelessWidget {
//   const OverallPlaceRating({super.key, this.rating = '4.8'});

//   final String rating;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           flex: 3,
//           child: Text(rating, style: Theme.of(context).textTheme.displayLarge),
//         ),

//         Expanded(
//           flex: 7,
//           child: Column(
//             children: [
//               AppRatingProgressIndicator(text: '5', value: 1.0),
//               AppRatingProgressIndicator(text: '4', value: 0.8),
//               AppRatingProgressIndicator(text: '3', value: 0.6),
//               AppRatingProgressIndicator(text: '2', value: 0.4),
//               AppRatingProgressIndicator(text: '1', value: 0.2),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

