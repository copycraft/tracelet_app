// lib/screens/trace_root_screen.dart
// Very small screen that shows a trace root id (styling only)
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
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text("Tracing root: $rootId"),
        ),
      ),
    );
  }
}