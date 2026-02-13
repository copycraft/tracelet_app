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
        itemCount: packages.length,
        itemBuilder: (context, i) {
          final p = packages[i] as Map<String, dynamic>;
          final ext = p['external_id'] ?? p['id'] ?? 'unknown';
          final sub = p['type'] ?? '';
          return ListTile(
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
