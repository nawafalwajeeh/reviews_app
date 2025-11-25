import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:reviews_app/utils/constants/colors.dart';
import '../../features/review/models/place_model.dart';

class CustomMarkerGenerator {
  static Future<BitmapDescriptor> createPlaceMarker({
    required String title,
    required double rating,
    required bool isSelected,
    String? category,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Size based on selection state
    final double width = isSelected ? 140.0 : 120.0;
    final double height = isSelected ? 75.0 : 65.0;
    final double cornerRadius = 12.0;
    final double pointerHeight = isSelected ? 15.0 : 12.0;
    final double ratingCircleSize = isSelected ? 28.0 : 24.0;

    // Draw shadow first
    _drawMarkerShadow(canvas, width, height, cornerRadius, pointerHeight);

    // Draw marker body - Main rectangle with rounded corners
    final Rect bodyRect = Rect.fromLTWH(0, 0, width, height - pointerHeight);
    final RRect roundedRect = RRect.fromRectAndRadius(
      bodyRect,
      Radius.circular(cornerRadius),
    );

    // Gradient background
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isSelected
          ? [Colors.white, Color(0xFFF8F9FA)]
          : [Colors.white, Color(0xFFF1F3F4)],
    );

    final paint = Paint()
      ..shader = gradient.createShader(bodyRect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(roundedRect, paint);

    // Border
    final borderPaint = Paint()
      ..color = isSelected ? AppColors.primaryColor : Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.5;

    canvas.drawRRect(roundedRect, borderPaint);

    // Draw pointer (triangle at bottom)
    final path = Path()
      ..moveTo(width / 2 - 10, height - pointerHeight)
      ..lineTo(width / 2, height)
      ..lineTo(width / 2 + 10, height - pointerHeight)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    // Draw rating circle on left side
    final double circleLeft = 8.0;
    final double circleTop = (height - pointerHeight - ratingCircleSize) / 2;

    // Rating circle background
    final circlePaint = Paint()
      ..color = _getRatingColor(rating)
      ..style = PaintingStyle.fill;

    final circleBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      Offset(
        circleLeft + ratingCircleSize / 2,
        circleTop + ratingCircleSize / 2,
      ),
      ratingCircleSize / 2,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(
        circleLeft + ratingCircleSize / 2,
        circleTop + ratingCircleSize / 2,
      ),
      ratingCircleSize / 2,
      circleBorderPaint,
    );

    // Rating text
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.text = TextSpan(
      text: rating.toStringAsFixed(1),
      style: TextStyle(
        fontSize: isSelected ? 11.0 : 10.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        circleLeft + (ratingCircleSize - textPainter.width) / 2,
        circleTop + (ratingCircleSize - textPainter.height) / 2,
      ),
    );

    // Restaurant name
    final namePainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    // Calculate available width for text
    final double textMaxWidth = width - ratingCircleSize - 20;

    namePainter.text = TextSpan(
      text: _truncateText(title, isSelected ? 12 : 10),
      style: TextStyle(
        fontSize: isSelected ? 12.0 : 11.0,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGrey,
      ),
    );
    namePainter.layout(maxWidth: textMaxWidth);
    namePainter.paint(
      canvas,
      Offset(
        ratingCircleSize + 16,
        (height - pointerHeight - namePainter.height) / 2,
      ),
    );

    // Convert to image
    final image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  static void _drawMarkerShadow(
    Canvas canvas,
    double width,
    double height,
    double cornerRadius,
    double pointerHeight,
  ) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    final shadowRect = Rect.fromLTWH(
      4, // x offset
      4, // y offset
      width,
      height - pointerHeight,
    );

    final shadowRRect = RRect.fromRectAndRadius(
      shadowRect,
      Radius.circular(cornerRadius),
    );

    canvas.drawRRect(shadowRRect, shadowPaint);

    // Shadow for pointer
    final shadowPath = Path()
      ..moveTo(width / 2 - 10 + 4, height - pointerHeight + 4)
      ..lineTo(width / 2 + 4, height + 4)
      ..lineTo(width / 2 + 10 + 4, height - pointerHeight + 4)
      ..close();

    canvas.drawPath(shadowPath, shadowPaint);
  }

  static Color _getRatingColor(double rating) {
    if (rating >= 4.0) {
      return Color(0xFF388E3C); // Green
    } else if (rating >= 3.0) {
      return Color(0xFFF57C00); // Orange
    } else if (rating >= 2.0) {
      return Color(0xFFFBC02D); // Yellow
    } else {
      return Color(0xFFD32F2F); // Red
    }
  }

  static String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 2)}...';
  }

  // Generate marker for places
  static Future<BitmapDescriptor> generatePlaceMarker(
    PlaceModel place, {
    bool isSelected = false,
  }) async {
    return createPlaceMarker(
      title: place.title,
      rating: place.averageRating,
      isSelected: isSelected,
      category: place.categoryId,
    );
  }

  // Current location marker (simple blue dot)
  static Future<BitmapDescriptor> getCurrentLocationMarker() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Size size = Size(50.0, 50.0);

    // Outer pulsing circle
    final outerPaint = Paint()
      ..color = AppColors.primaryColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      20.0,
      outerPaint,
    );

    // Middle circle
    final middlePaint = Paint()
      ..color = AppColors.primaryColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      12.0,
      middlePaint,
    );

    // Inner circle
    final innerPaint = Paint()
      ..color = AppColors.primaryColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 6.0, innerPaint);

    final image = await pictureRecorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // Selected location marker for picker mode
  static Future<BitmapDescriptor> getSelectedLocationMarker() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Size size = Size(60.0, 70.0);

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawCircle(
      Offset(size.width / 2, size.height - 10),
      15.0,
      shadowPaint,
    );

    // Pin body
    final pinPaint = Paint()
      ..color = AppColors.primaryColor
      ..style = PaintingStyle.fill;

    final pinBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw pin shape
    final pinPath = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width * 0.7, size.height * 0.4)
      ..lineTo(size.width * 0.7, size.height - 15)
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height,
        size.width / 2,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height,
        size.width * 0.3,
        size.height - 15,
      )
      ..lineTo(size.width * 0.3, size.height * 0.4)
      ..close();

    canvas.drawPath(pinPath, pinPaint);
    canvas.drawPath(pinPath, pinBorderPaint);

    // Center dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 3), 4.0, dotPaint);

    final image = await pictureRecorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}

//-------------------------
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'dart:ui' as ui;

// import '../../features/review/models/place_model.dart';

// class CustomMarkerGenerator {
//   static Future<BitmapDescriptor> createCustomMarker({
//     required String title,
//     required double rating,
//     required Color color,
//     bool isSelected = false,
//   }) async {
//     final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
//     final Canvas canvas = Canvas(pictureRecorder);
//     final Size size = Size(isSelected ? 80.0 : 60.0, isSelected ? 90.0 : 70.0);

//     // Draw marker shadow
//     final shadowPaint = Paint()
//       ..color = Colors.black.withValues(alpha: 0.3)
//       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

//     canvas.drawCircle(
//       Offset(size.width / 2, size.height - 10),
//       isSelected ? 25.0 : 20.0,
//       shadowPaint,
//     );

//     // Draw marker body
//     final markerPaint = Paint()..color = color;
//     final borderPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = isSelected ? 3.0 : 2.0;

//     // Draw pin shape
//     _drawPinShape(canvas, size, markerPaint, borderPaint, isSelected);

//     // Draw rating circle
//     final ratingCirclePaint = Paint()..color = Colors.white;
//     final ratingBorderPaint = Paint()
//       ..color = color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     canvas.drawCircle(
//       Offset(size.width / 2, size.height / 3),
//       isSelected ? 18.0 : 15.0,
//       ratingCirclePaint,
//     );
//     canvas.drawCircle(
//       Offset(size.width / 2, size.height / 3),
//       isSelected ? 18.0 : 15.0,
//       ratingBorderPaint,
//     );

//     // Draw rating text
//     final textPainter = TextPainter(
//       textDirection: TextDirection.ltr,
//       textAlign: TextAlign.center,
//     );

//     textPainter.text = TextSpan(
//       text: rating.toStringAsFixed(1),
//       style: TextStyle(
//         fontSize: isSelected ? 12.0 : 10.0,
//         fontWeight: FontWeight.bold,
//         color: color,
//       ),
//     );
//     textPainter.layout();
//     textPainter.paint(
//       canvas,
//       Offset(
//         (size.width - textPainter.width) / 2,
//         (size.height / 3) - (textPainter.height / 2),
//       ),
//     );

//     // Convert to image
//     final image = await pictureRecorder.endRecording().toImage(
//       size.width.toInt(),
//       size.height.toInt(),
//     );
//     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

//     return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
//   }

//   static void _drawPinShape(
//     Canvas canvas,
//     Size size,
//     Paint fillPaint,
//     Paint borderPaint,
//     bool isSelected,
//   ) {
//     final double width = size.width;
//     final double height = size.height;
//     final double tipHeight = isSelected ? 25.0 : 20.0;

//     final path = Path()
//       ..moveTo(width / 2, 0)
//       ..lineTo(width * 0.7, height * 0.3)
//       ..lineTo(width * 0.7, height - tipHeight)
//       ..quadraticBezierTo(width * 0.7, height, width / 2, height)
//       ..quadraticBezierTo(width * 0.3, height, width * 0.3, height - tipHeight)
//       ..lineTo(width * 0.3, height * 0.3)
//       ..close();

//     canvas.drawPath(path, fillPaint);
//     canvas.drawPath(path, borderPaint);
//   }

//   // Generate marker based on place rating and category
//   static Future<BitmapDescriptor> generatePlaceMarker(
//     PlaceModel place, {
//     bool isSelected = false,
//   }) async {
//     Color markerColor;

//     // Color based on rating
//     if (place.averageRating >= 4.0) {
//       markerColor = Colors.green;
//     } else if (place.averageRating >= 3.0) {
//       markerColor = Colors.orange;
//     } else if (place.averageRating >= 2.0) {
//       markerColor = Colors.yellow;
//     } else {
//       markerColor = Colors.red;
//     }

//     return createCustomMarker(
//       title: place.title,
//       rating: place.averageRating,
//       color: markerColor,
//       isSelected: isSelected,
//     );
//   }

//   // Current location marker
//   static Future<BitmapDescriptor> getCurrentLocationMarker() async {
//     final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
//     final Canvas canvas = Canvas(pictureRecorder);
//     final Size size = Size(50.0, 50.0);

//     // Outer circle
//     final outerPaint = Paint()
//       ..color = Colors.blue.withValues(alpha: 0.3)
//       ..style = PaintingStyle.fill;

//     canvas.drawCircle(
//       Offset(size.width / 2, size.height / 2),
//       25.0,
//       outerPaint,
//     );

//     // Inner circle
//     final innerPaint = Paint()
//       ..color = Colors.blue
//       ..style = PaintingStyle.fill;

//     canvas.drawCircle(
//       Offset(size.width / 2, size.height / 2),
//       15.0,
//       innerPaint,
//     );

//     // Center dot
//     final centerPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.fill;

//     canvas.drawCircle(
//       Offset(size.width / 2, size.height / 2),
//       5.0,
//       centerPaint,
//     );

//     final image = await pictureRecorder.endRecording().toImage(
//       size.width.toInt(),
//       size.height.toInt(),
//     );
//     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

//     return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
//   }
// }
