// lib/screens/dashboard_screen.dart
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/api_client.dart';
import 'tracking_screen.dart';
import 'create_package_screen.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/event_tile.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // ignore if not on mobile

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
      setState(() => packages = List<Map<String, dynamic>>.from(list));
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

  void _openScanner() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => const QRScannerScreen(),
        ),
      );
      if (result != null && result.isNotEmpty) {
        _searchController.text = result;
        _onSearch();
      }
    } else {
      // Windows / Desktop fallback
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("QR Not Supported"),
          content: const Text(
            "QR code scanning is not supported on Windows yet.\n\n"
                "Please use the mobile version to scan QR codes.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Color _statusColorFor(dynamic p, BuildContext ctx) {
    final s = (p['status'] ?? '').toString().toLowerCase();
    if (s.contains('delivered')) return Colors.green;
    if (s.contains('failed') || s.contains('error')) return Colors.red;
    if (s.contains('in_transit') || s.contains('shipped')) return Colors.orange;
    return Theme.of(ctx).colorScheme.primary;
  }

  Widget _buildStatCard(String label, String value, {IconData? icon}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
          if (icon != null) const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              const SizedBox(height: 6),
              Text(value, style: theme.textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.compact();
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Tracelet Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadAll,
          tooltip: "Refresh",
        ),
        if (Platform.isAndroid || Platform.isIOS)
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _openScanner,
            tooltip: "Scan QR",
          ),
      ],
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: LayoutBuilder(builder: (ctx, constraints) {
          final twoCol = constraints.maxWidth > 900;
          return ListView(
            children: [
              // Search Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Track number / external id',
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _onSearch(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _onSearch,
                    child: const Text('Track'),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Stats row
              if (loadingStats)
                Center(child: CircularProgressIndicator())
              else
                twoCol
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildStatCard('Total packages', stats != null && stats!['total_packages'] != null ? format.format(stats!['total_packages']) : '--', icon: Icons.inventory_2),
                          _buildStatCard('Active', (stats?['active']?.toString() ?? '--'), icon: Icons.flash_on),
                          _buildStatCard('Errors', (stats?['errors']?.toString() ?? '--'), icon: Icons.error),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('Raw: ${stats ?? {}}', style: theme.textTheme.bodySmall),
                      ),
                    ),
                  ],
                )
                    : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(width: double.infinity, child: _buildStatCard('Total packages', stats != null && stats!['total_packages'] != null ? format.format(stats!['total_packages']) : '--', icon: Icons.inventory_2)),
                    SizedBox(width: double.infinity, child: _buildStatCard('Active', (stats?['active']?.toString() ?? '--'), icon: Icons.flash_on)),
                    SizedBox(width: double.infinity, child: _buildStatCard('Errors', (stats?['errors']?.toString() ?? '--'), icon: Icons.error)),
                  ],
                ),

              const SizedBox(height: 16),

              // Actions
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(onPressed: _openCreate, icon: const Icon(Icons.add), label: const Text('Create Package')),
                  OutlinedButton.icon(onPressed: _loadAll, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
                ],
              ),

              const SizedBox(height: 18),

              // Packages header
              Row(
                children: [
                  Expanded(child: Text('Packages', style: theme.textTheme.titleMedium)),
                  const SizedBox(width: 8),
                  Text('${packages.length}', style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),

              // Package list
              if (loadingPackages)
                const Center(child: CircularProgressIndicator())
              else if (error != null)
                Center(child: Text('Error loading packages: $error'))
              else if (packages.isEmpty)
                  const Center(child: Text('No packages'))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: twoCol ? 2 : 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: twoCol ? 3.6 : 4.5,
                    ),
                    itemCount: packages.length,
                    itemBuilder: (_, i) {
                      final p = packages[i];
                      final ext = (p['external_id'] ?? p['tracking_number'] ?? p['id'])?.toString() ?? 'unknown';
                      final type = (p['type'] ?? 'package').toString();
                      final subtitle = p['extra_data'] != null ? p['extra_data'].toString() : type;
                      final statusColor = _statusColorFor(p, context);
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => TrackingScreen(apiClient: widget.apiClient, trackingNumber: ext),
                          ));
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(ext, style: theme.textTheme.titleSmall),
                                    const SizedBox(height: 6),
                                    Text(subtitle, style: theme.textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

              const SizedBox(height: 24),
            ],
          );
        }),
      ),
      fab: (Platform.isAndroid || Platform.isIOS)
          ? FloatingActionButton(
        onPressed: _openScanner,
        child: const Icon(Icons.qr_code_scanner),
        tooltip: 'Scan QR',
      )
          : null,
    );
  }
}

/// Minimal mobile QR Scanner screen (keeps your existing logic)
class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return Scaffold(
        appBar: AppBar(title: const Text('QR Scanner')),
        body: const Center(child: Text('QR scanning is only available on mobile.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: (capture) {
          final result = capture.barcodes.first.rawValue;
          if (result != null) Navigator.of(context).pop(result);
        },
      ),
    );
  }
}