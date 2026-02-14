import 'package:flutter/material.dart';
import 'screens/ip_entry_screen.dart';
import 'screens/dashboard_screen.dart';
import 'core/api_client.dart';

void main() {
  runApp(const TraceletApp());
}

class TraceletApp extends StatelessWidget {
  const TraceletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracelet',
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const RootRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RootRouter extends StatefulWidget {
  const RootRouter({super.key});

  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  ApiClient? _client;

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  Future<void> _loadClient() async {
    final client = await ApiClient.getInstance();
    setState(() {
      _client = client;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_client == null) {
      // No client yet → show IP entry screen
      return const IpEntryScreen();
    }

    // Client is ready → show dashboard
    return DashboardScreen(apiClient: _client!);
  }
}
