import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:reviews_app/localization/app_localizations.dart'
    show AppLocalizations;

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../data/services/barcode/barcode_service.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/loaders.dart';
import '../../controllers/barcode_scanner_controller.dart';
import '../place_details/place_details.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  // Camera controller - keep as local state
  late MobileScannerController cameraController;

  // Scanner state - keep as local state
  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _hasScanned = false;
  CameraFacing _cameraFacing = CameraFacing.back;
  String? _lastScannedData;

  // Use GetX controller for business logic only
  final _scannerController = Get.put(BarcodeScannerController());

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      torchEnabled: _isTorchOn,
      facing: _cameraFacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: CustomAppBar(
        // title: const Text('Scan QR Code'),
        title: Text(AppLocalizations.of(context).scanQRCode),
        // backgroundColor: Colors.black.withValues(alpha: 0.5),
        // elevation: 0,
        showBackArrow: true,
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: isDark ? AppColors.white : AppColors.dark,
            ),
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: Icon(
              _cameraFacing == CameraFacing.front
                  ? Icons.camera_front
                  : Icons.camera_rear,
              color: isDark ? AppColors.white : AppColors.dark,
            ),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera scanner
          MobileScanner(
            controller: cameraController,
            onDetect: _onBarcodeDetected,
          ),

          // Scanner overlay
          Positioned.fill(child: CustomPaint(painter: ScannerOverlayPainter())),

          // Instructions
          _buildInstructions(),

          // Loading overlay (optional reactive approach)
          Obx(
            () => _scannerController.isLoading.value
                ? _buildLoadingOverlay()
                : const SizedBox(),
          ),

          // Error overlay (optional reactive approach)
          Obx(
            () => _scannerController.errorMessage.isNotEmpty
                ? _buildErrorOverlay()
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing || _hasScanned) return;

    for (final barcode in capture.barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null &&
          rawValue.isNotEmpty &&
          rawValue != _lastScannedData) {
        _lastScannedData = rawValue;
        _isProcessing = true;
        _hasScanned = true;

        _handleScannedBarcode(rawValue);
        break;
      }
    }
  }

  void _handleScannedBarcode(String scannedData) async {
    try {
      final appLocalizations = AppLocalizations.of(context);
      final String? placeId = BarcodeService().parseBarcodeData(scannedData);

      if (placeId == null || placeId.isEmpty) {
        // _showErrorSnackbar('Invalid QR Code', 'Unrecognized format.');
        _showErrorSnackbar(
          appLocalizations.invalidQRCode,
          appLocalizations.unrecognizedFormat,
        );
        _resumeScanning();
        return;
      }

      // Show processing
      Get.snackbar(
        // '🔍 Looking Up Place...',
        // 'Checking our database...',
        appLocalizations.lookingUpPlace,
        appLocalizations.checkingDatabase,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      // Use GetX controller for place fetching
      final placeModel = await _scannerController.fetchPlaceById(placeId);

      await cameraController.stop();

      Get.snackbar(
        // '✅ Success!',
        appLocalizations.success,
        // 'Redirecting to ${placeModel.title}',
        appLocalizations.redirectingTo(placeModel.title),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(milliseconds: 1500));
      Get.to(() => PlaceDetailsScreen(place: placeModel));
    } catch (e) {
      _showDetailedError(scannedData, e.toString());
    }
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

  void _resumeScanning() {
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _hasScanned = false;
        _lastScannedData = null;
      });
    }
  }

  Widget _buildInstructions() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 100,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          // 'Align QR code within the frame',
          AppLocalizations.of(context).alignQRCode,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              // 'Processing QR Code...',
              AppLocalizations.of(context).processingQRCode,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.white, size: 40),
              SizedBox(height: 10),
              Text(
                // 'Scan Error',
                AppLocalizations.of(context).scanError,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 5),
              Obx(
                () => Text(
                  _scannerController.errorMessage.value,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _resumeScanning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                ),
                // child: Text('Try Again'),
                child: Text(AppLocalizations.of(context).tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    AppLoaders.successSnackBar(title: title, message: message);
  }

  void _showDetailedError(String scannedData, String error) {
    AppLoaders.errorSnackBar(title: scannedData, message: error);
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
    // Create a path that covers the entire screen
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Define the scanning area (transparent hole in the center)
    final scanningAreaSize = size.width * 0.7;
    final scanningArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanningAreaSize,
      height: scanningAreaSize,
    );

    // Add the scanning area as a hole (this will be transparent)
    final scanningAreaPath = Path()..addRect(scanningArea);
    path.addPath(scanningAreaPath, Offset.zero);

    // Use evenOdd fill type to create the hole
    path.fillType = PathFillType.evenOdd;

    // Fill the surrounding area with semi-transparent black
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
