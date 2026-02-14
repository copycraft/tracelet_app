// lib/screens/create_package_screen.dart
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
      if (_weight.text.trim().isNotEmpty) "weight_kg": double.tryParse(_weight.text.trim()) ?? 0.0,
    };

    try {
      final res = await widget.apiClient.createPackage(payload);
      setState(() => _message = "Created successfully: ${res['id'] ?? res['external_id'] ?? ''}");
      await Future.delayed(const Duration(milliseconds: 450));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _message = "Error creating package: $e");
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Package")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tracking,
                decoration: const InputDecoration(labelText: "Tracking Number / External ID"),
                validator: (v) => (v == null || v.trim().isEmpty) ? "required" : null,
              ),
              TextFormField(
                controller: _sender,
                decoration: const InputDecoration(labelText: "Sender"),
                validator: (v) => (v == null || v.trim().isEmpty) ? "required" : null,
              ),
              TextFormField(
                controller: _recipient,
                decoration: const InputDecoration(labelText: "Recipient"),
                validator: (v) => (v == null || v.trim().isEmpty) ? "required" : null,
              ),
              TextFormField(
                controller: _destination,
                decoration: const InputDecoration(labelText: "Destination"),
                validator: (v) => (v == null || v.trim().isEmpty) ? "required" : null,
              ),
              TextFormField(
                controller: _weight,
                decoration: const InputDecoration(labelText: "Weight (kg)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sending ? null : _submit,
                child: _sending ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Create"),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(_message!, style: const TextStyle(color: Colors.white70)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
