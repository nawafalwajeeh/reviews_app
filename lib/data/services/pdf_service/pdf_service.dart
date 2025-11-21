import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../features/review/models/place_model.dart';

class PdfExportService {
  static Future<void> generatePlacePdf(PlaceModel place) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(place.title, style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text(place.description),
              pw.SizedBox(height: 20),
              // Add barcode image to PDF
              // You'll need to convert the barcode widget to an image
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}