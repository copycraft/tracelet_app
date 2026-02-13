import 'package:flutter/material.dart';
import '../core/api_client.dart';

class TraceScreen extends StatelessWidget {
  final ApiClient apiClient;
  final String trackingNumber; // must match API

  const TraceScreen({
    super.key,
    required this.apiClient,
    required this.trackingNumber, // updated parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trace Package")),
      body: Center(
        child: Text("Tracing package: $trackingNumber"),
      ),
    );
  }
}
