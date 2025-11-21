import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:reviews_app/features/review/controllers/place_controller.dart';

import '../../../../data/services/barcode/barcode_service.dart';
import '../../models/place_model.dart';
import '../place_details/place_details.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController cameraController = MobileScannerController(
    torchEnabled: false,
    facing: CameraFacing.back,
  );

  final BarcodeService _barcodeService = BarcodeService();
  bool _isProcessing = false;
  bool _isTorchOn = false;
  CameraFacing _cameraFacing = CameraFacing.back;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: Icon(
              _cameraFacing == CameraFacing.front
                  ? Icons.camera_front
                  : Icons.camera_rear,
              color: Colors.white,
            ),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full screen mobile scanner - camera takes entire screen
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;

              for (final barcode in barcodes) {
                final String? rawValue = barcode.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  _isProcessing = true;
                  _handleScannedBarcode(rawValue);
                  break;
                }
              }
            },
          ),

          // CORRECTED: Overlay with transparent scan area and black surroundings
          Positioned.fill(child: CustomPaint(painter: ScannerOverlayPainter())),

          // Instructions
          Positioned(
            top: MediaQuery.of(context).padding.top + 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Align QR code within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Processing QR Code...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleTorch() {
    setState(() {
      _isTorchOn = !_isTorchOn;
      cameraController.toggleTorch();
    });
  }

  void _switchCamera() {
    setState(() {
      _cameraFacing = _cameraFacing == CameraFacing.back
          ? CameraFacing.front
          : CameraFacing.back;
      cameraController.switchCamera();
    });
  }

  void _handleScannedBarcode(String scannedData) async {
    try {
      final String? placeId = _barcodeService.parseBarcodeData(scannedData);

      if (placeId != null && mounted) {
        Get.snackbar(
          'Success!',
          'Place found! Redirecting...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(milliseconds: 1500));

        await cameraController.stop();

        Get.offAll(
          () async => PlaceDetailsScreen(place: await _fetchPlaceById(placeId)),
        );
      } else {
        Get.snackbar(
          'Invalid QR Code',
          'This QR code is not recognized by the app.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        _resumeScanning();
      }
    } catch (e) {
      Get.snackbar(
        'Scan Error',
        'Failed to process QR code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _resumeScanning();
    }
  }

  void _resumeScanning() {
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<PlaceModel> _fetchPlaceById(String placeId) async {
    try {
      final placeController = Get.find<PlaceController>();
      final place = await placeController.placeRepository.getPlaceById(placeId);
      if (place != null) {
        return place;
      } else {
        throw Exception('Place not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch place: $e');
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // CORRECTED: Create a path that covers the entire screen
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // CORRECTED: Define the scanning area (transparent hole in the center)
    final scanningAreaSize = size.width * 0.7;
    final scanningArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanningAreaSize,
      height: scanningAreaSize,
    );

    // CORRECTED: Add the scanning area as a hole (this will be transparent)
    final scanningAreaPath = Path()..addRect(scanningArea);
    path.addPath(scanningAreaPath, Offset.zero);

    // CORRECTED: Use evenOdd fill type to create the hole
    path.fillType = PathFillType.evenOdd;

    // CORRECTED: Fill the surrounding area with semi-transparent black
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Draw border around the scanning area
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(scanningArea, borderPaint);

    // Draw corner marks around the scanning area
    _drawCornerMarks(canvas, scanningArea);
  }

  void _drawCornerMarks(Canvas canvas, Rect scanningArea) {
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final cornerSize = 25.0;

    // Top left corner
    canvas.drawLine(
      scanningArea.topLeft,
      Offset(scanningArea.left + cornerSize, scanningArea.top),
      cornerPaint,
    );
    canvas.drawLine(
      scanningArea.topLeft,
      Offset(scanningArea.left, scanningArea.top + cornerSize),
      cornerPaint,
    );

    // Top right corner
    canvas.drawLine(
      scanningArea.topRight,
      Offset(scanningArea.right - cornerSize, scanningArea.top),
      cornerPaint,
    );
    canvas.drawLine(
      scanningArea.topRight,
      Offset(scanningArea.right, scanningArea.top + cornerSize),
      cornerPaint,
    );

    // Bottom left corner
    canvas.drawLine(
      scanningArea.bottomLeft,
      Offset(scanningArea.left + cornerSize, scanningArea.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      scanningArea.bottomLeft,
      Offset(scanningArea.left, scanningArea.bottom - cornerSize),
      cornerPaint,
    );

    // Bottom right corner
    canvas.drawLine(
      scanningArea.bottomRight,
      Offset(scanningArea.right - cornerSize, scanningArea.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      scanningArea.bottomRight,
      Offset(scanningArea.right, scanningArea.bottom - cornerSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
