import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../data/services/barcode/barcode_service.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/place_model.dart';

class BarcodeSection extends StatelessWidget {
  final PlaceModel place;

  const BarcodeSection({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final barcodeService = BarcodeService();
    final barcodeData = place.barcodeData.isNotEmpty
        ? place.barcodeData
        : barcodeService.generateBarcodeData(place.id);

    return Padding(
      padding: const EdgeInsets.all(AppSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           AppSectionHeading(
            // title: 'Place QR Code',
            title: AppLocalizations.of(context).placeQRCode,
            showActionButton: false,
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                children: [
                  // Smaller rectangular barcode
                  Container(
                    width: 120, // Smaller width for rectangle
                    height: 120, // Same height for square
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: barcodeService.generateBarcodeWidget(barcodeData),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Scan instructions
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: Colors.blue,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          // 'Scan to view this place',
                          AppLocalizations.of(context).scanToView,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _shareBarcodeAsPdf(context, barcodeData),
                          icon: const Icon(Icons.share, size: 16),
                          // label: const Text('Share PDF'),
                          label:  Text(AppLocalizations.of(context).sharePDF),

                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.spaceBtwItems),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _saveBarcodeAsPdf(context, barcodeData),
                          icon: const Icon(Icons.download, size: 16),
                          // label: const Text('Save PDF'),
                          label:  Text(AppLocalizations.of(context).savePDF),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareBarcodeAsPdf(
    BuildContext context,
    String barcodeData,
  ) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: true,
      );

      // Generate PDF
      final pdfBytes = await _generatePdfBytes(barcodeData);

      // Create temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/${_sanitizeFileName(place.title)}_qrcode.pdf',
      );
      await file.writeAsBytes(pdfBytes);

      Get.back(); // Close loading dialog

      // Share the PDF file
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text:
              'Check out ${place.title} QR Code!\n\nScan this QR code to view the place details in the Reviews App.',
  
          subject: '${place.title} - QR Code',
        ),
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Share Failed',
        'Failed to share QR code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveBarcodeAsPdf(
    BuildContext context,
    String barcodeData,
  ) async {
    try {
      // Request storage permission with better handling
      final status = await Permission.manageExternalStorage.request();

      if (status.isPermanentlyDenied) {
        // Show dialog to open app settings
        await Get.dialog(
          AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'Storage permission is required to save PDF files. Please enable it in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return;
      }

      if (!status.isGranted) {
        Get.snackbar(
          'Permission Required',
          'Please grant storage permission to save PDF files',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Generate PDF
      final pdfBytes = await _generatePdfBytes(barcodeData);

      // For Android 10+, use Downloads directory
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Could not access downloads directory');
      }

      final filePath =
          '${directory.path}/${_sanitizeFileName(place.title)}_QR_Code.pdf';
      final file = File(filePath);

      // Check if file already exists
      if (await file.exists()) {
        Get.back(); // Close loading dialog
        await _showFileExistsDialog(filePath);
        return;
      }

      await file.writeAsBytes(pdfBytes);

      Get.back(); // Close loading dialog

      Get.snackbar(
        'Success!',
        'QR Code PDF saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Save Failed',
        'Failed to save QR code: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _showFileExistsDialog(String filePath) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('File Exists'),
        content: const Text(
          'A PDF with this name already exists. Would you like to overwrite it?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await _overwriteFile(filePath);
            },
            child: const Text('Overwrite'),
          ),
        ],
      ),
    );
  }

  Future<void> _overwriteFile(String filePath) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final pdfBytes = await _generatePdfBytes(place.barcodeData);
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      Get.back();

      Get.snackbar(
        'Success!',
        'File overwritten successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to overwrite file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<Uint8List> _generatePdfBytes(String barcodeData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  place.title,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),

              if (place.description.isNotEmpty)
                pw.Text(
                  'Description: ${place.description}',
                  style: const pw.TextStyle(fontSize: 12),
                ),

              pw.SizedBox(height: 20),

              pw.Center(
                child: pw.Container(
                  width: 150,
                  height: 150,
                  child: pw.BarcodeWidget(
                    data: barcodeData,
                    barcode: pw.Barcode.qrCode(),
                  ),
                ),
              ),

              pw.SizedBox(height: 15),
              pw.Center(
                child: pw.Text(
                  'Scan to view place details in Reviews App',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(' ', '_');
  }
}

//------------------------
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../../../../../common/widgets/texts/section_heading.dart';
// import '../../../../../data/services/barcode/barcode_service.dart';
// import '../../../../../utils/constants/sizes.dart';
// import '../../../controllers/place_controller.dart';
// import '../../../models/place_model.dart';

// class BarcodeSection extends StatelessWidget {
//   final PlaceModel place;

//   const BarcodeSection({super.key, required this.place});

//   @override
//   Widget build(BuildContext context) {
//     final barcodeService = BarcodeService();
//     final barcodeData = place.barcodeData.isNotEmpty
//         ? place.barcodeData
//         : barcodeService.generateBarcodeData(place.id);

//     return Padding(
//       padding: const EdgeInsets.all(AppSizes.defaultSpace),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const AppSectionHeading(
//             title: 'Place QR Code',
//             showActionButton: false,
//           ),
//           const SizedBox(height: AppSizes.spaceBtwItems),
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(AppSizes.defaultSpace),
//               child: Column(
//                 children: [
//                   // Perfectly sized barcode
//                   Container(
//                     width: 150,
//                     height: 150,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       color: Colors.white,
//                     ),
//                     padding: const EdgeInsets.all(12),
//                     child: barcodeService.generateBarcodeWidget(barcodeData),
//                   ),
//                   const SizedBox(height: AppSizes.spaceBtwItems),

//                   // Scan instructions
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.qr_code_scanner,
//                           color: Colors.blue,
//                           size: 16,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Scan to view this place',
//                           style: Theme.of(context).textTheme.bodyMedium
//                               ?.copyWith(
//                                 color: Colors.blue,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: AppSizes.spaceBtwItems),

//                   // Action buttons
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: () =>
//                               _shareBarcodeAsPdf(context, barcodeData),
//                           icon: const Icon(Icons.share, size: 18),
//                           label: const Text('Share'),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: AppSizes.spaceBtwItems),
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () =>
//                               _saveBarcodeAsPdf(context, barcodeData),
//                           icon: const Icon(Icons.download, size: 18),
//                           label: const Text('Save'),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _shareBarcodeAsPdf(
//     BuildContext context,
//     String barcodeData,
//   ) async {
//     try {
//       Get.dialog(
//         const Center(child: CircularProgressIndicator()),
//         barrierDismissible: false,
//       );

//       // Generate PDF
//       final pdfBytes = await _generatePdfBytes(barcodeData);

//       // Create temporary file
//       final tempDir = await getTemporaryDirectory();
//       final file = File(
//         '${tempDir.path}/${_sanitizeFileName(place.title)}_qrcode.pdf',
//       );
//       await file.writeAsBytes(pdfBytes);

//       Get.back(); // Close loading dialog

//       // Share the PDF file
//       await SharePlus.instance.share(
//         ShareParams(
//           files: [XFile(file.path)],
//           text:
//               'Check out ${place.title} QR Code!\n\nScan this QR code to view the place details in the Reviews App.',
//           subject: '${place.title} - QR Code',
//         ),
//       );
//     } catch (e) {
//       Get.back(); // Close loading dialog
//       Get.snackbar(
//         'Share Failed',
//         'Failed to share QR code: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   Future<void> _saveBarcodeAsPdf(
//     BuildContext context,
//     String barcodeData,
//   ) async {
//     try {
//       // Request storage permission
//       final status = await Permission.storage.request();
//       if (!status.isGranted) {
//         Get.snackbar(
//           'Permission Required',
//           'Storage permission is needed to save PDF',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//         );
//         return;
//       }

//       Get.dialog(
//         const Center(child: CircularProgressIndicator()),
//         barrierDismissible: false,
//       );

//       // Generate PDF
//       final pdfBytes = await _generatePdfBytes(barcodeData);

//       // Get downloads directory
//       final directory = await getDownloadsDirectory();
//       if (directory == null) {
//         throw Exception('Could not access downloads directory');
//       }

//       final file = File(
//         '${directory.path}/${_sanitizeFileName(place.title)}_QR_Code.pdf',
//       );
//       await file.writeAsBytes(pdfBytes);

//       Get.back(); // Close loading dialog

//       Get.snackbar(
//         'Success!',
//         'QR Code PDF saved to Downloads folder',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     } catch (e) {
//       Get.back(); // Close loading dialog
//       Get.snackbar(
//         'Save Failed',
//         'Failed to save QR code: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   Future<Uint8List> _generatePdfBytes(String barcodeData) async {
//     final pdf = pw.Document();

//     // Add a page to the PDF
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               // Header
//               pw.Center(
//                 child: pw.Text(
//                   place.title,
//                   style: pw.TextStyle(
//                     fontSize: 24,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//               ),
//               pw.SizedBox(height: 10),

//               // Description
//               if (place.description.isNotEmpty)
//                 pw.Text(
//                   'Description: ${place.description}',
//                   style: const pw.TextStyle(fontSize: 12),
//                 ),

//               pw.SizedBox(height: 20),

//               // QR Code - centered
//               pw.Center(
//                 child: pw.Container(
//                   width: 200,
//                   height: 200,
//                   child: pw.BarcodeWidget(
//                     data: barcodeData,
//                     barcode: pw.Barcode.qrCode(),
//                   ),
//                 ),
//               ),

//               pw.SizedBox(height: 20),

//               // Instructions
//               pw.Center(
//                 child: pw.Text(
//                   'Scan this QR code to view place details',
//                   style: pw.TextStyle(
//                     fontSize: 14,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//               ),

//               pw.SizedBox(height: 10),

//               // Place details
//               pw.Container(
//                 padding: const pw.EdgeInsets.all(10),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey),
//                   borderRadius: pw.BorderRadius.circular(5),
//                 ),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text('Location: ${place.address.toString()}'),
//                     if (place.phoneNumber?.isNotEmpty ?? false)
//                       pw.Text('Phone: ${place.phoneNumber}'),
//                     pw.Text('Category: ${_getCategoryName()}'),
//                     pw.Text('Added: ${_formatDate(place.dateAdded)}'),
//                   ],
//                 ),
//               ),

//               pw.SizedBox(height: 20),

//               // Footer
//               pw.Center(
//                 child: pw.Text(
//                   'Generated by Reviews App',
//                   style: const pw.TextStyle(
//                     fontSize: 10,
//                     color: PdfColors.grey,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     return await pdf.save();
//   }

//   String _getCategoryName() {
//     final controller = PlaceController.instance;
//     return controller.selectedCategoryName.value.isNotEmpty
//         ? controller.selectedCategoryName.value
//         : 'General';
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return 'Unknown';
//     final day = date.day.toString().padLeft(2, '0');
//     final month = date.month.toString().padLeft(2, '0');
//     final year = date.year.toString();
//     return '$day/$month/$year';
//   }

//   String _sanitizeFileName(String fileName) {
//     // Remove invalid characters for file names
//     return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
//   }
// }
