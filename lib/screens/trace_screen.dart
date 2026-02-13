import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/trace_event.dart';
import '../widgets/event_tile.dart';

class TraceScreen extends StatelessWidget {
  final ApiClient apiClient;
  final String entityId;

  const TraceScreen({
    super.key,
    required this.apiClient,
    required this.entityId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trace Entity"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<TraceEvent>>(
        future: apiClient.fetchTraceEvents(entityId), // Make sure this exists in ApiClient
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final traceEvents = snapshot.data ?? [];
          if (traceEvents.isEmpty) {
            return const Center(child: Text("No trace events found."));
          }

          return ListView.builder(
            itemCount: traceEvents.length,
            itemBuilder: (context, index) {
              return EventTile(event: traceEvents[index]);
            },
          );
        },
      ),
    );
  }
}
