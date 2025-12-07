import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class BarcodeService {
  static final BarcodeService _instance = BarcodeService._internal();
  factory BarcodeService() => _instance;
  BarcodeService._internal();

  final Uuid _uuid = Uuid();

  String generateBarcodeData(String placeId) {
    return 'REVIEWS_APP::$placeId::${_uuid.v4()}';
  }

  // String? parseBarcodeData(String scannedData) {
  //   try {
  //     final parts = scannedData.split('::');
  //     if (parts.length >= 2 && parts[0] == 'REVIEWS_APP') {
  //       return parts[1];
  //     }
  //     return null;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  BarcodeWidget generateBarcodeWidget(
    String data, {
    double? width,
    double? height,
  }) {
    return BarcodeWidget(
      barcode: Barcode.qrCode(),
      data: data,
      width: width ?? 180, // Default optimal size
      height: height ?? 180,
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      drawText: false, // Hide text for cleaner look
      errorBuilder: (context, error) => Container(
        width: width ?? 180,
        height: height ?? 180,
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(height: 8),
              Text('QR Error', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  String? parseBarcodeData(String scannedData) {
    try {
      debugPrint('🎯 === BARCODE PARSING ===');
      debugPrint('📱 Raw input: "$scannedData"');

      // Clean the input
      final cleanData = scannedData.trim();
      debugPrint('🧹 Cleaned data: "$cleanData"');

      // Split by the delimiter
      final parts = cleanData.split('::');
      debugPrint('📊 Parts after split: $parts');
      debugPrint('📊 Number of parts: ${parts.length}');

      // Validate format
      if (parts.length >= 2 && parts[0] == 'REVIEWS_APP') {
        final placeId = parts[1].trim();
        debugPrint('✅ Extracted place ID: "$placeId"');
        debugPrint('📏 Place ID length: ${placeId.length}');

        // Basic validation - should be a UUID format
        if (placeId.isNotEmpty && _looksLikeValidId(placeId)) {
          debugPrint('✅ Place ID looks valid');
          return placeId;
        } else {
          debugPrint('❌ Place ID format invalid');
        }
      } else {
        debugPrint('❌ Invalid QR format or prefix mismatch');
        debugPrint('❌ Expected: REVIEWS_APP::placeId::uuid');
        debugPrint('❌ Actual prefix: ${parts.isNotEmpty ? parts[0] : "none"}');
      }
      return null;
    } catch (e) {
      debugPrint('💥 Barcode parsing error: $e');
      return null;
    }
  }

  bool _looksLikeValidId(String id) {
    // Basic check - should not be empty and should be reasonable length
    if (id.isEmpty) return false;

    // UUIDs are typically 36 characters, but be flexible
    if (id.length < 5 || id.length > 50) {
      debugPrint('❌ ID length suspicious: ${id.length}');
      return false;
    }

    // Should contain alphanumeric characters and possibly hyphens
    final validRegex = RegExp(r'^[a-zA-Z0-9\-_]+$');
    return validRegex.hasMatch(id);
  }
}
