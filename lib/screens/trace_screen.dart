// lib/screens/trace_screen.dart
// Parcel trace display — keeps the complex fallback traceTree logic intact
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/parcel.dart';
import '../models/trace_event.dart';

class TraceScreen extends StatefulWidget {
  final ApiClient apiClient;
  final String trackingNumber;

  const TraceScreen({super.key, required this.apiClient, required this.trackingNumber});

  @override
  State<TraceScreen> createState() => _TraceScreenState();
}

class _TraceScreenState extends State<TraceScreen> {
  Parcel? parcel;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadParcel();
  }

  Future<void> _loadParcel() async {
    setState(() => loading = true);
    try {
      final data = await widget.apiClient.trackPackage(widget.trackingNumber);
      debugPrint("DEBUG: trackPackage returned -> $data");

      final fetchedParcel = Parcel.fromJson(data);

      // If no events found, try traceTree as fallback
      if (fetchedParcel.events.isEmpty) {
        debugPrint("DEBUG: No events found in trackPackage, calling traceTree...");
        final traceData = await widget.apiClient.traceTree(fetchedParcel.id);
        debugPrint("DEBUG: traceTree returned -> $traceData");

        List<TraceEvent> additionalEvents = [];

        void extractEvents(dynamic node) {
          try {
            if (node is List) {
              for (var e in node) {
                if (e is Map &&
                    (e.containsKey('event_type') ||
                        e.containsKey('status') ||
                        e.containsKey('timestamp') ||
                        e.containsKey('time'))) {
                  debugPrint("DEBUG: Found event in traceTree -> $e");
                  additionalEvents.add(TraceEvent.fromJson(Map<String, dynamic>.from(e)));
                } else {
                  extractEvents(e);
                }
              }
            } else if (node is Map) {
              node.values.forEach(extractEvents);
            }
          } catch (ex, st) {
            debugPrint("Error in extractEvents: $ex\n$st");
          }
        }

        extractEvents(traceData);

        parcel = Parcel(
          id: fetchedParcel.id,
          type: fetchedParcel.type,
          externalId: fetchedParcel.externalId,
          createdAt: fetchedParcel.createdAt,
          extraData: fetchedParcel.extraData,
          events: additionalEvents.isNotEmpty ? additionalEvents : [],
        );
      } else {
        parcel = fetchedParcel;
      }

      debugPrint("DEBUG: Final parcel events count -> ${parcel!.events.length}");
    } catch (e, st) {
      debugPrint("Error loading parcel: $e\n$st");
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _buildEventTile(TraceEvent e) {
    final ts = e.timestamp != null ? e.timestamp!.toLocal().toString() : 'unknown time';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text("${e.eventType}${e.status != null ? ' — ${e.status}' : ''}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (e.location != null && e.location!.isNotEmpty) Text("Location: ${e.location}"),
            if (e.actor != null && e.actor!.isNotEmpty) Text("Actor: ${e.actor}"),
            if (e.payload != null && e.payload!.isNotEmpty)
              Text("Notes: ${e.payload!['notes']?.toString() ?? ''}"),
            Text("When: $ts"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null) return Scaffold(body: Center(child: Text("Error: $error")));
    if (parcel == null) return const Scaffold(body: Center(child: Text("Entity not found")));

    return Scaffold(
      appBar: AppBar(title: Text(parcel!.externalId ?? parcel!.id)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(parcel!.externalId ?? parcel!.id),
                subtitle: Text("Type: ${parcel!.type}\nCreated: ${parcel!.createdAt}"),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: parcel!.events.isEmpty
                  ? const Center(child: Text("No events"))
                  : ListView.builder(
                itemCount: parcel!.events.length,
                itemBuilder: (_, i) => _buildEventTile(parcel!.events[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}