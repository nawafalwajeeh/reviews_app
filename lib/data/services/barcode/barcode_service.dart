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

  String? parseBarcodeData(String scannedData) {
    try {
      final parts = scannedData.split('::');
      if (parts.length >= 2 && parts[0] == 'REVIEWS_APP') {
        return parts[1];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  BarcodeWidget generateBarcodeWidget(String data, {double? width, double? height}) {
    return BarcodeWidget(
      barcode: Barcode.qrCode(),
      data: data,
      width: width ?? 180, // Default optimal size
      height: height ?? 180,
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
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
              Text(
                'QR Error',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}