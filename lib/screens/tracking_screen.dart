import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/api_client.dart';
import '../models/trace_event.dart';
import '../widgets/event_tile.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class TrackingScreen extends StatefulWidget {
  final ApiClient apiClient;
  final String trackingNumber;

  const TrackingScreen({super.key, required this.apiClient, required this.trackingNumber});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Map<String, dynamic>? data;
  bool loading = true;
  List<TraceEvent> events = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final r = await widget.apiClient.trackPackage(widget.trackingNumber);
      setState(() {
        data = r;
      });

      // try fetching events from entity id if present
      final entityId = r['id'] ?? r['package']?['id'] ?? r['entity_id'];
      if (entityId != null) {
        events = await widget.apiClient.fetchTraceEvents(entityId.toString());
      } else if (r['events'] != null && r['events'] is List) {
        events = (r['events'] as List).map((e) => TraceEvent.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _downloadAndOpenPdf() async {
    try {
      final bytes = await widget.apiClient.downloadPackagePdf(widget.trackingNumber);
      if (bytes.isEmpty) return;
      // show print/share preview
      await Printing.layoutPdf(onLayout: (_) async => bytes);
      // optional: save/share
      // final tmp = await writeToTempAndReturnPath(bytes, "${widget.trackingNumber}.pdf");
      // await Share.shareFiles([tmp]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PDF error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.yMMMd().add_Hm();
    return Scaffold(
      appBar: AppBar(title: Text("Track: ${widget.trackingNumber}")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text(data?["external_id"]?.toString() ?? widget.trackingNumber),
                subtitle: Text("Type: ${data?["type"] ?? "package"}\nId: ${data?["id"] ?? "--"}"),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _downloadAndOpenPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Download PDF"),
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
