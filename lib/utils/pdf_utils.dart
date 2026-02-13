import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfUtils {
  /// Generate a simple package PDF with QR code embedded.
  static Future<Uint8List> generatePackagePdf({
    required String trackingNumber,
    required String sender,
    required String recipient,
    required String destination,
    String? weight,
  }) async {
    final doc = pw.Document();
    final qrData = "$trackingNumber | ${DateTime.now().toIso8601String()}";

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Package: $trackingNumber", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text("Created at: ${DateTime.now().toIso8601String()}"),
            pw.SizedBox(height: 8),
            pw.Text("Sender: $sender"),
            pw.Text("Recipient: $recipient"),
            pw.Text("Destination: $destination"),
            if (weight != null && weight.isNotEmpty) pw.Text("Weight: $weight kg"),
            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 150,
                height: 150,
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: qrData,
                ),
              ),
            ),
          ],
        );
      },
    ));

    return doc.save();
  }
}
