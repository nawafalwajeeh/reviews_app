import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../data/services/barcode/barcode_service.dart';
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
      final String? placeId = BarcodeService().parseBarcodeData(scannedData);

      if (placeId == null || placeId.isEmpty) {
        _showErrorSnackbar('Invalid QR Code', 'Unrecognized format.');
        _resumeScanning();
        return;
      }

      // Show processing
      Get.snackbar(
        '🔍 Looking Up Place...',
        'Checking our database...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      // Use GetX controller for place fetching
      final placeModel = await _scannerController.fetchPlaceById(placeId);

      await cameraController.stop();

      Get.snackbar(
        '✅ Success!',
        'Redirecting to ${placeModel.title}',
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
          'Align QR code within the frame',
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
                'Scan Error',
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
                child: Text('Try Again'),
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
      ..color = Colors.black.withOpacity(0.6)
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

//----------------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:reviews_app/features/review/controllers/place_controller.dart';

// import '../../../../data/repositories/place/place_repository.dart';
// import '../../../../data/services/barcode/barcode_service.dart';
// import '../../models/place_model.dart';
// import '../place_details/place_details.dart';

// class BarcodeScannerScreen extends StatefulWidget {
//   const BarcodeScannerScreen({super.key});

//   @override
//   State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
// }

// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
//   MobileScannerController cameraController = MobileScannerController(
//     torchEnabled: false,
//     facing: CameraFacing.back,
//   );

//   final BarcodeService _barcodeService = BarcodeService();
//   bool _isProcessing = false;
//   bool _isTorchOn = false;
//   CameraFacing _cameraFacing = CameraFacing.back;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan QR Code'),
//         backgroundColor: Colors.black.withValues(alpha: 0.5),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(
//               _isTorchOn ? Icons.flash_on : Icons.flash_off,
//               color: Colors.white,
//             ),
//             onPressed: _toggleTorch,
//           ),
//           IconButton(
//             icon: Icon(
//               _cameraFacing == CameraFacing.front
//                   ? Icons.camera_front
//                   : Icons.camera_rear,
//               color: Colors.white,
//             ),
//             onPressed: _switchCamera,
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Full screen mobile scanner - camera takes entire screen
//           MobileScanner(
//             controller: cameraController,
//             onDetect: (capture) {
//               if (_isProcessing) return;

//               final List<Barcode> barcodes = capture.barcodes;

//               for (final barcode in barcodes) {
//                 final String? rawValue = barcode.rawValue;
//                 if (rawValue != null && rawValue.isNotEmpty) {
//                   _isProcessing = true;
//                   _handleScannedBarcode(rawValue);
//                   break;
//                 }
//               }
//             },
//           ),

//           // CORRECTED: Overlay with transparent scan area and black surroundings
//           Positioned.fill(child: CustomPaint(painter: ScannerOverlayPainter())),

//           // Instructions
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 100,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 'Align QR code within the frame',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),

//           if (_isProcessing)
//             Container(
//               color: Colors.black54,
//               child: const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(color: Colors.white),
//                     SizedBox(height: 16),
//                     Text(
//                       'Processing QR Code...',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   void _toggleTorch() {
//     setState(() {
//       _isTorchOn = !_isTorchOn;
//       cameraController.toggleTorch();
//     });
//   }

//   void _switchCamera() {
//     setState(() {
//       _cameraFacing = _cameraFacing == CameraFacing.back
//           ? CameraFacing.front
//           : CameraFacing.back;
//       cameraController.switchCamera();
//     });
//   }

//   void _handleScannedBarcode(String scannedData) async {
//     try {
//       final String? placeId = _barcodeService.parseBarcodeData(scannedData);

//       if (placeId != null && mounted) {
//         Get.snackbar(
//           'Success!',
//           'Place found! Redirecting...',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 2),
//         );
//         final placeModel = await _fetchPlaceById(placeId);
//         debugPrint('Fetched Place: ${placeModel.title}');
//         await Future.delayed(const Duration(milliseconds: 1500));

//         await cameraController.stop();

//         Get.offAll(() => PlaceDetailsScreen(place: placeModel));
//       } else {
//         Get.snackbar(
//           'Invalid QR Code',
//           'This QR code is not recognized by the app.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         _resumeScanning();
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Scan Error',
//         'Failed to process QR code: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       _resumeScanning();
//     }
//   }

//   void _resumeScanning() {
//     if (mounted) {
//       setState(() {
//         _isProcessing = false;
//       });
//     }
//   }

//   Future<PlaceModel> _fetchPlaceById(String placeId) async {
//     try {
//       final placeRepository = Get.put(PlaceRepository());
//       final place = await placeRepository.getPlaceById(placeId);

//       if (place != null) {
//         return place;
//       } else {
//         throw Exception('Place not found');
//       }
//     } catch (e) {
//       debugPrint('Error fetching place: $e');
//       throw Exception('Failed to fetch place: $e');
//     }
//   }

//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }
// }

// class ScannerOverlayPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     // CORRECTED: Create a path that covers the entire screen
//     final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

//     // CORRECTED: Define the scanning area (transparent hole in the center)
//     final scanningAreaSize = size.width * 0.7;
//     final scanningArea = Rect.fromCenter(
//       center: Offset(size.width / 2, size.height / 2),
//       width: scanningAreaSize,
//       height: scanningAreaSize,
//     );

//     // CORRECTED: Add the scanning area as a hole (this will be transparent)
//     final scanningAreaPath = Path()..addRect(scanningArea);
//     path.addPath(scanningAreaPath, Offset.zero);

//     // CORRECTED: Use evenOdd fill type to create the hole
//     path.fillType = PathFillType.evenOdd;

//     // CORRECTED: Fill the surrounding area with semi-transparent black
//     final paint = Paint()
//       ..color = Colors.black.withValues(alpha: 0.6)
//       ..style = PaintingStyle.fill;

//     canvas.drawPath(path, paint);

//     // Draw border around the scanning area
//     final borderPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     canvas.drawRect(scanningArea, borderPaint);

//     // Draw corner marks around the scanning area
//     _drawCornerMarks(canvas, scanningArea);
//   }

//   void _drawCornerMarks(Canvas canvas, Rect scanningArea) {
//     final cornerPaint = Paint()
//       ..color = Colors.green
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4.0
//       ..strokeCap = StrokeCap.round;

//     final cornerSize = 25.0;

//     // Top left corner
//     canvas.drawLine(
//       scanningArea.topLeft,
//       Offset(scanningArea.left + cornerSize, scanningArea.top),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       scanningArea.topLeft,
//       Offset(scanningArea.left, scanningArea.top + cornerSize),
//       cornerPaint,
//     );

//     // Top right corner
//     canvas.drawLine(
//       scanningArea.topRight,
//       Offset(scanningArea.right - cornerSize, scanningArea.top),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       scanningArea.topRight,
//       Offset(scanningArea.right, scanningArea.top + cornerSize),
//       cornerPaint,
//     );

//     // Bottom left corner
//     canvas.drawLine(
//       scanningArea.bottomLeft,
//       Offset(scanningArea.left + cornerSize, scanningArea.bottom),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       scanningArea.bottomLeft,
//       Offset(scanningArea.left, scanningArea.bottom - cornerSize),
//       cornerPaint,
//     );

//     // Bottom right corner
//     canvas.drawLine(
//       scanningArea.bottomRight,
//       Offset(scanningArea.right - cornerSize, scanningArea.bottom),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       scanningArea.bottomRight,
//       Offset(scanningArea.right, scanningArea.bottom - cornerSize),
//       cornerPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }






//-------------------------------
// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

// import '../../../../data/services/barcode/barcode_service.dart';
// import '../../models/place_model.dart';
// import '../place_details/place_details.dart';

// class BarcodeScannerScreen extends StatefulWidget {
//   const BarcodeScannerScreen({super.key});

//   @override
//   State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
// }

// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
//   MobileScannerController cameraController = MobileScannerController(
//     torchEnabled: false,
//     facing: CameraFacing.back,
//   );

//   final BarcodeService _barcodeService = BarcodeService();
//   bool _isProcessing = false;
//   bool _isTorchOn = false;
//   bool _hasScanned = false; // NEW: Prevent multiple scans
//   CameraFacing _cameraFacing = CameraFacing.back;
//   String? _lastScannedData; // NEW: Track last scanned data to avoid duplicates

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan QR Code'),
//         backgroundColor: Colors.black.withValues(alpha: 0.5),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(
//               _isTorchOn ? Icons.flash_on : Icons.flash_off,
//               color: Colors.white,
//             ),
//             onPressed: _toggleTorch,
//           ),
//           IconButton(
//             icon: Icon(
//               _cameraFacing == CameraFacing.front
//                   ? Icons.camera_front
//                   : Icons.camera_rear,
//               color: Colors.white,
//             ),
//             onPressed: _switchCamera,
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Full screen mobile scanner - camera takes entire screen
//           MobileScanner(
//             controller: cameraController,
//             onDetect: (capture) {
//               if (_isProcessing || _hasScanned)
//                 return; // NEW: Prevent if already scanned

//               final List<Barcode> barcodes = capture.barcodes;

//               for (final barcode in barcodes) {
//                 final String? rawValue = barcode.rawValue;
//                 if (rawValue != null &&
//                     rawValue.isNotEmpty &&
//                     rawValue != _lastScannedData) {
//                   // NEW: Check for duplicates

//                   _lastScannedData = rawValue; // NEW: Store last scanned data
//                   _isProcessing = true;
//                   _hasScanned = true; // NEW: Mark as scanned
//                   _handleScannedBarcode(rawValue);
//                   break;
//                 }
//               }
//             },
//           ),

//           // Overlay with transparent scan area and black surroundings
//           Positioned.fill(child: CustomPaint(painter: ScannerOverlayPainter())),

//           // Instructions
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 100,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 'Align QR code within the frame',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),

//           if (_isProcessing)
//             Container(
//               color: Colors.black54,
//               child: const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(color: Colors.white),
//                     SizedBox(height: 16),
//                     Text(
//                       'Processing QR Code...',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   void _toggleTorch() {
//     setState(() {
//       _isTorchOn = !_isTorchOn;
//       cameraController.toggleTorch();
//     });
//   }

//   void _switchCamera() {
//     setState(() {
//       _cameraFacing = _cameraFacing == CameraFacing.back
//           ? CameraFacing.front
//           : CameraFacing.back;
//       cameraController.switchCamera();
//     });
//   }

//   void _handleScannedBarcode(String scannedData) async {
//     try {
//       debugPrint('🎯 Starting QR code processing...');

//       final String? placeId = _barcodeService.parseBarcodeData(scannedData);
//       debugPrint('🔍 Parsed place ID: "$placeId"');

//       if (placeId == null || placeId.isEmpty) {
//         _showErrorSnackbar(
//           'Invalid QR Code',
//           'This QR code format is not recognized.',
//         );
//         _resumeScanning();
//         return;
//       }

//       // Show processing message
//       if (mounted) {
//         Get.snackbar(
//           '🔍 Looking Up Place...',
//           'Checking our database...',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.blue,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 10),
//         );
//       }

//       debugPrint('🚀 Fetching place with universal method...');
//       final placeModel = await _universalFetchPlace(placeId);

//       if (!mounted) return;

//       debugPrint('✅ SUCCESS: Place found - ${placeModel.title}');

//       // Stop camera to prevent further scans
//       await cameraController.stop();

//       // Show success message
//       Get.snackbar(
//         '✅ Success!',
//         'Redirecting to ${placeModel.title}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 2),
//       );

//       // Small delay for smooth transition
//       await Future.delayed(const Duration(milliseconds: 1500));

//       debugPrint('🧭 Navigating to place details...');
//       Get.offAll(() => PlaceDetailsScreen(place: placeModel));
//     } catch (e) {
//       debugPrint('💥 QR processing error: $e');

//       // Show detailed error with retry option
//       _showDetailedError(scannedData, e.toString());
//     }
//   }

//   void _showDetailedError(String scannedData, String error) {
//     Get.dialog(
//       AlertDialog(
//         title: Row(
//           children: [
//             Icon(Icons.error_outline, color: Colors.red),
//             SizedBox(width: 10),
//             Text('Place Not Found'),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('We couldn\'t find this place in our database.'),
//             SizedBox(height: 10),
//             Text(
//               'Possible reasons:',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 5),
//             Text('• Place was deleted'),
//             Text('• Database synchronization issue'),
//             Text('• QR code contains wrong ID'),
//             SizedBox(height: 15),
//             Text(
//               'Technical details:',
//               style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               error.length > 100 ? '${error.substring(0, 100)}...' : error,
//               style: TextStyle(fontSize: 10, color: Colors.grey),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Get.back();
//               _resumeScanning();
//             },
//             child: Text('Scan Different Code'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               _handleScannedBarcode(scannedData); // Retry same code
//             },
//             child: Text('Try Again'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<PlaceModel> _universalFetchPlace(String scannedPlaceId) async {
//     try {
//       debugPrint('🎯 === UNIVERSAL PLACE FETCH ===');
//       debugPrint('📱 Scanned place ID: $scannedPlaceId');

//       final firestore = FirebaseFirestore.instance;
//       final placesRef = firestore.collection('Places');

//       // METHOD 1: Try direct document ID access (most common)
//       debugPrint('🔄 Method 1: Direct document access...');
//       var doc = await placesRef.doc(scannedPlaceId).get();
//       if (doc.exists && doc.data() != null) {
//         debugPrint('✅ SUCCESS: Found by document ID');
//         return PlaceModel.fromSnapshot(doc);
//       }

//       // METHOD 2: Try query by uniqueBarcode field
//       debugPrint('🔄 Method 2: Query by uniqueBarcode...');
//       final uniqueBarcodeQuery = await placesRef
//           .where('UniqueBarcode', isEqualTo: 'QR_$scannedPlaceId')
//           .limit(1)
//           .get();

//       if (uniqueBarcodeQuery.docs.isNotEmpty) {
//         debugPrint('✅ SUCCESS: Found by uniqueBarcode: QR_$scannedPlaceId');
//         return PlaceModel.fromSnapshot(
//           uniqueBarcodeQuery.docs.first
//               as DocumentSnapshot<Map<String, dynamic>>,
//         );
//       }

//       // METHOD 3: Try query by BarcodeData field (contains the place ID)
//       debugPrint('🔄 Method 3: Query by BarcodeData...');
//       final barcodeDataQuery = await placesRef
//           .where('BarcodeData', isEqualTo: 'REVIEWS_APP::$scannedPlaceId::')
//           .limit(1)
//           .get();

//       if (barcodeDataQuery.docs.isNotEmpty) {
//         debugPrint('✅ SUCCESS: Found by BarcodeData prefix');
//         return PlaceModel.fromSnapshot(
//           barcodeDataQuery.docs.first as DocumentSnapshot<Map<String, dynamic>>,
//         );
//       }

//       // METHOD 4: Try query by BarcodeData with partial match
//       debugPrint('🔄 Method 4: Query by BarcodeData contains...');
//       final partialBarcodeQuery = await placesRef
//           .where(
//             'BarcodeData',
//             isGreaterThanOrEqualTo: 'REVIEWS_APP::$scannedPlaceId',
//           )
//           .where(
//             'BarcodeData',
//             isLessThan:
//                 'REVIEWS_APP::$scannedPlaceId'
//                 'z',
//           )
//           .limit(5)
//           .get();

//       for (final doc in partialBarcodeQuery.docs) {
//         final data = doc.data();
//         if (data['BarcodeData']?.toString().contains(scannedPlaceId) == true) {
//           debugPrint('✅ SUCCESS: Found by BarcodeData partial match');
//           return PlaceModel.fromSnapshot(
//             doc as DocumentSnapshot<Map<String, dynamic>>,
//           );
//         }
//       }

//       // METHOD 5: Last resort - search all places and match by ID field
//       debugPrint('🔄 Method 5: Searching all places...');
//       final allPlacesQuery = await placesRef.limit(50).get();

//       for (final doc in allPlacesQuery.docs) {
//         final data = doc.data();

//         // Check if the document ID matches
//         if (doc.id == scannedPlaceId) {
//           debugPrint('✅ SUCCESS: Found by document ID in bulk query');
//           return PlaceModel.fromSnapshot(
//             doc as DocumentSnapshot<Map<String, dynamic>>,
//           );
//         }

//         // Check if the Id field matches
//         if (data['Id']?.toString() == scannedPlaceId) {
//           debugPrint('✅ SUCCESS: Found by Id field');
//           return PlaceModel.fromSnapshot(
//             doc as DocumentSnapshot<Map<String, dynamic>>,
//           );
//         }

//         // Check if uniqueBarcode matches
//         if (data['UniqueBarcode']?.toString() == 'QR_$scannedPlaceId') {
//           debugPrint('✅ SUCCESS: Found by UniqueBarcode in bulk query');
//           return PlaceModel.fromSnapshot(
//             doc as DocumentSnapshot<Map<String, dynamic>>,
//           );
//         }

//         // Check if barcodeData contains the place ID
//         if (data['BarcodeData']?.toString().contains(scannedPlaceId) == true) {
//           debugPrint('✅ SUCCESS: Found by BarcodeData in bulk query');
//           return PlaceModel.fromSnapshot(
//             doc as DocumentSnapshot<Map<String, dynamic>>,
//           );
//         }
//       }

//       // If we get here, no method worked
//       debugPrint('❌ FAIL: Place not found using any method');
//       throw Exception('Place not found in database');
//     } catch (e) {
//       debugPrint('💥 Universal fetch error: $e');
//       rethrow;
//     }
//   }



//   void _showErrorSnackbar(String title, String message) {
//     if (mounted) {
//       Get.snackbar(
//         title,
//         message,
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     }
//   }

//   void _resumeScanning() {
//     if (mounted) {
//       setState(() {
//         _isProcessing = false;
//         _hasScanned = false; // NEW: Reset scan flag
//         _lastScannedData = null; // NEW: Reset last scanned data
//       });
//     }
//   }

//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }
// }

// class ScannerOverlayPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     // Create a path that covers the entire screen
//     final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

//     // Define the scanning area (transparent hole in the center)
//     final scanningAreaSize = size.width * 0.7;
//     final scanningArea = Rect.fromCenter(
//       center: Offset(size.width / 2, size.height / 2),
//       width: scanningAreaSize,
//       height: scanningAreaSize,
//     );

//     // Add the scanning area as a hole (this will be transparent)
//     final scanningAreaPath = Path()..addRect(scanningArea);
//     path.addPath(scanningAreaPath, Offset.zero);

//     // Use evenOdd fill type to create the hole
//     path.fillType = PathFillType.evenOdd;

//     // Fill the surrounding area with semi-transparent black
//     final paint = Paint()
//       ..color = Colors.black.withOpacity(0.6)
//       ..style = PaintingStyle.fill;

//     canvas.drawPath(path, paint);

//     // Draw border around the scanning area
//     final borderPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     canvas.drawRect(scanningArea, borderPaint);

//     // Draw corner marks around the scanning area
//     _drawCornerMarks(canvas, scanningArea);
//   }

//   void _drawCornerMarks(Canvas canvas, Rect scanningArea) {
//     final cornerPaint = Paint()
//       ..color = Colors.green
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4.0
//       ..strokeCap = StrokeCap.round;

//     final cornerSize = 25.0;

//     // Top left corner
//     canvas.drawLine(
//       scanningArea.topLeft,
//       Offset(scanningArea.left + cornerSize, scanningArea.top),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       scanningArea.topLeft,
//       Offset(scanningArea.left, scanningArea.top + cornerSize),
//       cornerPaint,
//     );

//     // Top right corner
//     canvas.drawLine(
//       scanningArea.topRight,
//       Offset(scanningArea.right - cornerSize, scanningArea.top),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       scanningArea.topRight,
//       Offset(scanningArea.right, scanningArea.top + cornerSize),
//       cornerPaint,
//     );

//     // Bottom left corner
//     canvas.drawLine(
//       scanningArea.bottomLeft,
//       Offset(scanningArea.left + cornerSize, scanningArea.bottom),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       scanningArea.bottomLeft,
//       Offset(scanningArea.left, scanningArea.bottom - cornerSize),
//       cornerPaint,
//     );

//     // Bottom right corner
//     canvas.drawLine(
//       scanningArea.bottomRight,
//       Offset(scanningArea.right - cornerSize, scanningArea.bottom),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       scanningArea.bottomRight,
//       Offset(scanningArea.right, scanningArea.bottom - cornerSize),
//       cornerPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

//----------------------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:reviews_app/features/review/controllers/place_controller.dart';

// import '../../../../data/repositories/place/place_repository.dart';
// import '../../../../data/services/barcode/barcode_service.dart';
// import '../../models/place_model.dart';
// import '../place_details/place_details.dart';

// class BarcodeScannerScreen extends StatefulWidget {
//   const BarcodeScannerScreen({super.key});

//   @override
//   State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
// }

// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
//   MobileScannerController cameraController = MobileScannerController(
//     torchEnabled: false,
//     facing: CameraFacing.back,
//   );

//   final BarcodeService _barcodeService = BarcodeService();
//   bool _isProcessing = false;
//   bool _isTorchOn = false;
//   CameraFacing _cameraFacing = CameraFacing.back;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan QR Code'),
//         backgroundColor: Colors.black.withValues(alpha: 0.5),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(
//               _isTorchOn ? Icons.flash_on : Icons.flash_off,
//               color: Colors.white,
//             ),
//             onPressed: _toggleTorch,
//           ),
//           IconButton(
//             icon: Icon(
//               _cameraFacing == CameraFacing.front
//                   ? Icons.camera_front
//                   : Icons.camera_rear,
//               color: Colors.white,
//             ),
//             onPressed: _switchCamera,
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Full screen mobile scanner - camera takes entire screen
//           MobileScanner(
//             controller: cameraController,
//             onDetect: (capture) {
//               if (_isProcessing) return;

//               final List<Barcode> barcodes = capture.barcodes;

//               for (final barcode in barcodes) {
//                 final String? rawValue = barcode.rawValue;
//                 if (rawValue != null && rawValue.isNotEmpty) {
//                   _isProcessing = true;
//                   _handleScannedBarcode(rawValue);
//                   break;
//                 }
//               }
//             },
//           ),

//           // CORRECTED: Overlay with transparent scan area and black surroundings
//           Positioned.fill(child: CustomPaint(painter: ScannerOverlayPainter())),

//           // Instructions
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 100,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 'Align QR code within the frame',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),

//           if (_isProcessing)
//             Container(
//               color: Colors.black54,
//               child: const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(color: Colors.white),
//                     SizedBox(height: 16),
//                     Text(
//                       'Processing QR Code...',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   void _toggleTorch() {
//     setState(() {
//       _isTorchOn = !_isTorchOn;
//       cameraController.toggleTorch();
//     });
//   }

//   void _switchCamera() {
//     setState(() {
//       _cameraFacing = _cameraFacing == CameraFacing.back
//           ? CameraFacing.front
//           : CameraFacing.back;
//       cameraController.switchCamera();
//     });
//   }

//   void _handleScannedBarcode(String scannedData) async {
//     try {
//       final String? placeId = _barcodeService.parseBarcodeData(scannedData);

//       if (placeId != null && mounted) {
//         Get.snackbar(
//           'Success!',
//           'Place found! Redirecting...',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 2),
//         );
//         final placeModel = await _fetchPlaceById(placeId);
//         debugPrint('Fetched Place: ${placeModel.title}');
//         await Future.delayed(const Duration(milliseconds: 1500));

//         await cameraController.stop();

//         Get.offAll(() => PlaceDetailsScreen(place: placeModel));
//       } else {
//         Get.snackbar(
//           'Invalid QR Code',
//           'This QR code is not recognized by the app.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         _resumeScanning();
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Scan Error',
//         'Failed to process QR code: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       _resumeScanning();
//     }
//   }

//   void _resumeScanning() {
//     if (mounted) {
//       setState(() {
//         _isProcessing = false;
//       });
//     }
//   }

//   Future<PlaceModel> _fetchPlaceById(String placeId) async {
//     try {
//       final placeRepository = Get.put(PlaceRepository());
//       final place = await placeRepository.getPlaceById(placeId);

//       if (place != null) {
//         return place;
//       } else {
//         throw Exception('Place not found');
//       }
//     } catch (e) {
//       debugPrint('Error fetching place: $e');
//       throw Exception('Failed to fetch place: $e');
//     }
//   }

//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }
// }

// class ScannerOverlayPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     // CORRECTED: Create a path that covers the entire screen
//     final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

//     // CORRECTED: Define the scanning area (transparent hole in the center)
//     final scanningAreaSize = size.width * 0.7;
//     final scanningArea = Rect.fromCenter(
//       center: Offset(size.width / 2, size.height / 2),
//       width: scanningAreaSize,
//       height: scanningAreaSize,
//     );

//     // CORRECTED: Add the scanning area as a hole (this will be transparent)
//     final scanningAreaPath = Path()..addRect(scanningArea);
//     path.addPath(scanningAreaPath, Offset.zero);

//     // CORRECTED: Use evenOdd fill type to create the hole
//     path.fillType = PathFillType.evenOdd;

//     // CORRECTED: Fill the surrounding area with semi-transparent black
//     final paint = Paint()
//       ..color = Colors.black.withValues(alpha: 0.6)
//       ..style = PaintingStyle.fill;

//     canvas.drawPath(path, paint);

//     // Draw border around the scanning area
//     final borderPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     canvas.drawRect(scanningArea, borderPaint);

//     // Draw corner marks around the scanning area
//     _drawCornerMarks(canvas, scanningArea);
//   }

//   void _drawCornerMarks(Canvas canvas, Rect scanningArea) {
//     final cornerPaint = Paint()
//       ..color = Colors.green
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4.0
//       ..strokeCap = StrokeCap.round;

//     final cornerSize = 25.0;

//     // Top left corner
//     canvas.drawLine(
//       scanningArea.topLeft,
//       Offset(scanningArea.left + cornerSize, scanningArea.top),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       scanningArea.topLeft,
//       Offset(scanningArea.left, scanningArea.top + cornerSize),
//       cornerPaint,
//     );

//     // Top right corner
//     canvas.drawLine(
//       scanningArea.topRight,
//       Offset(scanningArea.right - cornerSize, scanningArea.top),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       scanningArea.topRight,
//       Offset(scanningArea.right, scanningArea.top + cornerSize),
//       cornerPaint,
//     );

//     // Bottom left corner
//     canvas.drawLine(
//       scanningArea.bottomLeft,
//       Offset(scanningArea.left + cornerSize, scanningArea.bottom),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       scanningArea.bottomLeft,
//       Offset(scanningArea.left, scanningArea.bottom - cornerSize),
//       cornerPaint,
//     );

//     // Bottom right corner
//     canvas.drawLine(
//       scanningArea.bottomRight,
//       Offset(scanningArea.right - cornerSize, scanningArea.bottom),
//       cornerPaint,
//     );
//     canvas.drawLine(
//       scanningArea.bottomRight,
//       Offset(scanningArea.right, scanningArea.bottom - cornerSize),
//       cornerPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
