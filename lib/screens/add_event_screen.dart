import 'package:flutter/material.dart';
import '../core/api_client.dart';

class AddEventScreen extends StatelessWidget {
  final ApiClient apiClient;
  final String trackingNumber;

  const AddEventScreen({
    super.key,
    required this.apiClient,
    required this.trackingNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Event")),
      body: Center(
        child: Text("Add event for tracking: $trackingNumber"),
      ),
    );
  }
}
