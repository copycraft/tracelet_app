// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/api_client.dart';
import 'tracking_screen.dart';
import 'create_package_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ApiClient apiClient;
  const DashboardScreen({super.key, required this.apiClient});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? stats;
  List<Map<String, dynamic>> packages = [];
  bool loadingStats = true;
  bool loadingPackages = true;
  final _searchController = TextEditingController();
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadStats(), _loadPackages()]);
  }

  Future<void> _loadStats() async {
    setState(() => loadingStats = true);
    try {
      final r = await widget.apiClient.stats();
      setState(() => stats = r);
    } catch (e) {
      setState(() => stats = {"error": e.toString()});
    } finally {
      setState(() => loadingStats = false);
    }
  }

  Future<void> _loadPackages() async {
    setState(() {
      loadingPackages = true;
      error = null;
    });
    try {
      final list = await widget.apiClient.listPackages(limit: 200);
      setState(() => packages = list);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loadingPackages = false);
    }
  }

  void _onSearch() {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TrackingScreen(apiClient: widget.apiClient, trackingNumber: q),
    ));
  }

  void _openCreate() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CreatePackageScreen(apiClient: widget.apiClient),
    ));
    await _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.compact();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracelet Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAll,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: "Track number / external id",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _onSearch(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _onSearch, child: const Text("Track")),
            ]),
            const SizedBox(height: 16),

            if (loadingStats)
              const Card(child: Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())))
            else
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
                      const SizedBox(height: 6),
                      if (stats != null && stats!["by_status"] != null && stats!["by_status"] is Map)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (stats!["by_status"] as Map).entries.map<Widget>((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text("${e.key}: ${e.value}"),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _openCreate,
                  icon: const Icon(Icons.add),
                  label: const Text("Create Package"),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _loadAll,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh"),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => TrackingScreen(apiClient: widget.apiClient, trackingNumber: _searchController.text.trim()))),
                  icon: const Icon(Icons.search),
                  label: const Text("Open Search"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text("Packages", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (loadingPackages)
              const Center(child: CircularProgressIndicator())
            else if (error != null)
              Center(child: Text("Error loading packages: $error"))
            else if (packages.isEmpty)
                const Center(child: Text("No packages"))
              else
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: packages.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final p = packages[i];
                      final ext = (p['external_id'] ?? p['tracking_number'] ?? p['id'])?.toString() ?? 'unknown';
                      final type = (p['type'] ?? 'package').toString();
                      final subtitle = p['extra_data'] != null ? p['extra_data'].toString() : type;
                      return ListTile(
                        title: Text(ext),
                        subtitle: Text(subtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => TrackingScreen(apiClient: widget.apiClient, trackingNumber: ext),
                          ));
                        },
                      );
                    },
                  ),
                ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
