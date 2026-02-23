// lib/screens/parcel_list_screen.dart
// Simple parcel list screen — updated visual surfaces only
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import 'tracking_screen.dart';

class ParcelListScreen extends StatefulWidget {
  final ApiClient apiClient;
  const ParcelListScreen({super.key, required this.apiClient});

  @override
  State<ParcelListScreen> createState() => _ParcelListScreenState();
}

class _ParcelListScreenState extends State<ParcelListScreen> {
  List<dynamic> packages = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final r = await widget.apiClient.listPackages(limit: 200);
      setState(() => packages = r);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parcels"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text("Error: $error"))
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: packages.length,
        itemBuilder: (context, i) {
          final p = packages[i] as Map<String, dynamic>;
          final ext = p['external_id'] ?? p['id'] ?? 'unknown';
          final sub = p['type'] ?? '';
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(ext.toString()),
              subtitle: Text(sub.toString()),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TrackingScreen(
                    apiClient: widget.apiClient,
                    trackingNumber: ext.toString(),
                  ),
                ));
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.qr_code_scanner),
        onPressed: () {
          Navigator.of(context).pushNamed("/scanner");
        },
      ),
    );
  }
}