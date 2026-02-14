// lib/screens/ip_entry_screen.dart
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import 'dashboard_screen.dart';

class IpEntryScreen extends StatefulWidget {
  const IpEntryScreen({super.key});

  @override
  State<IpEntryScreen> createState() => _IpEntryScreenState();
}

class _IpEntryScreenState extends State<IpEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller.text = "http://192.168.1.100:8000"; // default placeholder
  }

  Future<void> _saveBaseUrl() async {
    final val = _controller.text.trim();
    if (val.isEmpty) return;

    setState(() => _saving = true);

    try {
      // Save the URL and initialize the singleton ApiClient
      await ApiClient.setBaseUrl(val);
      final client = await ApiClient.getInstance();

      if (client != null) {
        // Navigate to DashboardScreen
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => DashboardScreen(apiClient: client),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to initialize ApiClient")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving URL: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Tracelet Server URL")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Enter the full base URL of your Tracelet server "
                  "(example: http://192.168.1.100:8000)",
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Base URL",
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveBaseUrl,
                child: _saving
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : const Text("Connect & Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
