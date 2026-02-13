import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/api_client.dart';
import 'tracking_screen.dart';
import 'create_package_screen.dart';
import '../core/constants.dart';

class DashboardScreen extends StatefulWidget {
  final ApiClient apiClient;
  const DashboardScreen({super.key, required this.apiClient});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? stats;
  bool loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => loading = true);
    try {
      final r = await widget.apiClient.stats();
      setState(() {
        stats = r;
      });
    } catch (e) {
      // ignore, show empty
      setState(() {
        stats = {"error": e.toString()};
      });
    } finally {
      setState(() => loading = false);
    }
  }

  void _onSearch() {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TrackingScreen(apiClient: widget.apiClient, trackingNumber: q),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.compact();
    return Scaffold(
      appBar: AppBar(title: const Text("Tracelet Dashboard")),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(labelText: "Track number / external id"),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _onSearch, child: const Text("Track")),
            ]),
            const SizedBox(height: 16),
            if (loading) const Center(child: CircularProgressIndicator()),
            if (!loading)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Stats", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text("Raw: ${stats ?? {}}"),
                      if (stats != null && stats!["total_packages"] != null)
                        Text("Total packages: ${format.format(stats!["total_packages"])}"),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CreatePackageScreen(apiClient: widget.apiClient),
                ));
              },
              icon: const Icon(Icons.add),
              label: const Text("Create Package"),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loadStats,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh Stats"),
            ),
          ],
        ),
      ),
    );
  }
}
