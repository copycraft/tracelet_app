import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import 'dashboard_screen.dart';

class IpEntryScreen extends StatefulWidget {
  const IpEntryScreen({super.key});

  @override
  State<IpEntryScreen> createState() => _IpEntryScreenState();
}

class _IpEntryScreenState extends State<IpEntryScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // optionally prefill with common localhost patterns
    _controller.text = "http://192.168.1.100:8000";
  }

  Future<void> _saveBaseUrl() async {
    final val = _controller.text.trim();
    if (val.isEmpty) return;
    setState(() => _saving = true);
    final prov = Provider.of<ApiProvider>(context, listen: false);
    await prov.setBaseUrl(val);
    setState(() => _saving = false);
    // navigate to dashboard
    if (prov.client != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => DashboardScreen(apiClient: prov.client!),
      ));
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
                "Enter the full base URL of your Tracelet server (example: http://192.168.1.100:8000)"),
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
            ElevatedButton(
              onPressed: _saving ? null : _saveBaseUrl,
              child: _saving ? const CircularProgressIndicator() : const Text("Connect & Save"),
            ),
          ],
        ),
      ),
    );
  }
}
