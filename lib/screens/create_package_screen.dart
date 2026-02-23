// lib/screens/create_package_screen.dart
// Create package form — M3 polish (preserves all logic & methods)
import 'package:flutter/material.dart';
import '../core/api_client.dart';

class CreatePackageScreen extends StatefulWidget {
  final ApiClient apiClient;
  const CreatePackageScreen({super.key, required this.apiClient});

  @override
  State<CreatePackageScreen> createState() => _CreatePackageScreenState();
}

class _CreatePackageScreenState extends State<CreatePackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tracking = TextEditingController();
  final _sender = TextEditingController();
  final _recipient = TextEditingController();
  final _destination = TextEditingController();
  final _weight = TextEditingController();
  bool _sending = false;
  String? _message;

  @override
  void dispose() {
    _tracking.dispose();
    _sender.dispose();
    _recipient.dispose();
    _destination.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _message = null;
    });

    final payload = {
      "tracking_number": _tracking.text.trim(),
      "sender": _sender.text.trim(),
      "recipient": _recipient.text.trim(),
      "destination": _destination.text.trim(),
      if (_weight.text.trim().isNotEmpty)
        "weight_kg": double.tryParse(_weight.text.trim()) ?? 0.0,
    };

    try {
      final res = await widget.apiClient.createPackage(payload);
      final id = res['id'] ?? res['external_id'] ?? '';
      final msg = "Created successfully: $id";
      setState(() => _message = msg);
      // Show success as snack bar for better UX
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
      await Future.delayed(const Duration(milliseconds: 450));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      final err = "Error creating package: $e";
      setState(() => _message = err);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Create Package")),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text("Package Details", style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),

              TextFormField(
                controller: _tracking,
                decoration: const InputDecoration(
                  labelText: "Tracking Number / External ID",
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _sender,
                decoration: const InputDecoration(labelText: "Sender"),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _recipient,
                decoration: const InputDecoration(labelText: "Recipient"),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _destination,
                decoration: const InputDecoration(labelText: "Destination"),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _weight,
                decoration: const InputDecoration(labelText: "Weight (kg)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: _sending ? null : _submit,
                icon: _sending
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.local_shipping),
                label: Text(_sending ? "Creating..." : "Create Package"),
              ),

              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(_message!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}