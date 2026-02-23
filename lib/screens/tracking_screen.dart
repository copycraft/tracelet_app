// lib/screens/tracking_screen.dart
// Tracking screen: native PDF download, event extraction and ordering preserved; visual polish applied
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../core/api_client.dart';
import '../models/trace_event.dart';
import '../widgets/event_tile.dart';
import 'package:printing/printing.dart';

class TrackingScreen extends StatefulWidget {
  final ApiClient apiClient;
  final String trackingNumber;

  const TrackingScreen({
    super.key,
    required this.apiClient,
    required this.trackingNumber,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Map<String, dynamic> data = {};
  bool loading = true;
  bool pdfLoading = false;
  List<TraceEvent> events = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Collect any arrays/lists that look like events anywhere in the payload
  List<dynamic> _collectEventLists(dynamic node) {
    final found = <dynamic>[];

    void search(dynamic n) {
      try {
        if (n is List) {
          if (n.isNotEmpty && n.first is Map) {
            final firstMap = n.first as Map;
            final keys =
            firstMap.keys.map((k) => k.toString().toLowerCase()).toSet();
            final hit = keys.intersection({
              'event_type',
              'type',
              'status',
              'timestamp',
              'time',
              'created_at',
              'location',
              'id',
              'actor'
            }).isNotEmpty;
            if (hit) {
              found.add(n);
              return;
            }
          } else {
            for (var e in n) search(e);
          }
        } else if (n is Map) {
          final keys = n.keys.map((k) => k.toString().toLowerCase()).toSet();
          if (keys.intersection({
            'event_type',
            'type',
            'status',
            'timestamp',
            'time',
            'created_at',
            'location',
            'id',
            'actor'
          }).isNotEmpty) {
            found.add([n]);
            return;
          }
          for (var v in n.values) search(v);
        }
      } catch (ex, st) {
        debugPrint("Error in _collectEventLists.search: $ex\n$st");
      }
    }

    search(node);
    return found;
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
      events = [];
      data = {};
    });

    try {
      final r = await widget.apiClient.trackPackage(widget.trackingNumber);
      if (r is Map<String, dynamic>) {
        data = Map<String, dynamic>.from(r);
      } else {
        data = {};
      }

      try {
        debugPrint("TRACK RESPONSE for ${widget.trackingNumber}: ${jsonEncode(data)}");
      } catch (_) {
        debugPrint("TRACK RESPONSE: <unencodable payload>");
      }

      List<dynamic> rawEvents = [];

      // PRIMARY: prefer explicit "timeline" if present (server returns timeline)
      if (data['timeline'] is List && (data['timeline'] as List).isNotEmpty) {
        rawEvents = data['timeline'];
        debugPrint("Using 'timeline' as events (length=${rawEvents.length})");
      }

      // SECONDARY: common keys used by other backends
      if (rawEvents.isEmpty) {
        final attempts = <dynamic>[
          data['events'],
          if (data['entity'] is Map) (data['entity'] as Map)['events'],
          data['event_history'],
          data['history'],
          if (data['data'] is Map) (data['data'] as Map)['events'],
          if (data['package'] is Map) (data['package'] as Map)['events'],
          if (data['extra_data'] is Map) (data['extra_data'] as Map)['events'],
        ];

        for (var cand in attempts) {
          if (cand is List && cand.isNotEmpty) {
            rawEvents = cand;
            debugPrint("Found embedded events in a common key, length=${rawEvents.length}");
            break;
          }
        }
      }

      // TERTIARY: recursive scan to find any event-like list
      if (rawEvents.isEmpty) {
        final lists = _collectEventLists(data);
        if (lists.isNotEmpty) {
          rawEvents = lists.first;
          debugPrint("Found event-like list via recursive scan, length=${rawEvents.length}");
        } else {
          debugPrint("No event-like lists found via recursive scan");
        }
      }

      // Convert raw events into TraceEvent objects
      if (rawEvents.isNotEmpty) {
        final converted = rawEvents.where((e) => e != null).map<TraceEvent?>((e) {
          try {
            if (e is Map) return TraceEvent.fromJson(Map<String, dynamic>.from(e));
            if (e is String) {
              final parsed = jsonDecode(e);
              if (parsed is Map) return TraceEvent.fromJson(Map<String, dynamic>.from(parsed));
              return null;
            }
            return null;
          } catch (ex) {
            debugPrint("Failed to convert event item: $ex");
            return null;
          }
        }).whereType<TraceEvent>().toList();

        // Sort descending (newest first)
        converted.sort((a, b) {
          if (a.timestamp == null && b.timestamp == null) return 0;
          if (a.timestamp == null) return 1;
          if (b.timestamp == null) return -1;
          return b.timestamp!.compareTo(a.timestamp!);
        });

        events = converted;
      } else {
        events = [];
      }

      debugPrint("Loaded ${events.length} events for ${widget.trackingNumber}");
    } catch (e, st) {
      debugPrint("Error in _load(): $e\n$st");
      error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _downloadAndOpenPdf() async {
    if (pdfLoading) return;

    setState(() => pdfLoading = true);

    try {
      final bytes = await widget.apiClient.downloadPackagePdf(widget.trackingNumber);

      if (bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Server returned empty PDF")));
        return;
      }

      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PDF error: $e")));
    } finally {
      if (mounted) setState(() => pdfLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Track: ${widget.trackingNumber}"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Error:\n$error",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  (data['external_id']?.toString() ?? data['tracking_number']?.toString() ?? widget.trackingNumber),
                ),
                subtitle: Text(
                  "Type: ${data['type']?.toString() ?? "package"}\nId: ${data['id']?.toString() ?? "--"}",
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: pdfLoading ? null : _downloadAndOpenPdf,
                  icon: pdfLoading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(pdfLoading ? "Loading..." : "Download PDF"),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: events.isEmpty
                  ? const Center(child: Text("No events"))
                  : ListView.builder(
                itemCount: events.length,
                itemBuilder: (_, i) => EventTile(event: events[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}