import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/api_client.dart';
import 'tracking_screen.dart';

class ScannerScreen extends StatefulWidget {
  final ApiClient apiClient;
  const ScannerScreen({super.key, required this.apiClient});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool found = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),
      body: MobileScanner(
        onDetect: (capture) {
          if (found) return;
          final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
          if (barcode == null) return;
          found = true;

          // parse: "tracking_number | created_at" or just tracking_number
          final parts = barcode.split('|').map((s) => s.trim()).toList();
          final tracking = parts.isNotEmpty ? parts[0] : barcode;

          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => TrackingScreen(apiClient: widget.apiClient, trackingNumber: tracking),
          ));
        },
      ),
    );
  }
}
