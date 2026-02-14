// lib/screens/trace_root_screen.dart
import 'package:flutter/material.dart';
import '../core/api_client.dart';

class TraceRootScreen extends StatelessWidget {
  final ApiClient apiClient;
  final String rootId;

  const TraceRootScreen({
    super.key,
    required this.apiClient,
    required this.rootId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trace Root")),
      body: Center(
        child: Text("Tracing root: $rootId"),
      ),
    );
  }
}
