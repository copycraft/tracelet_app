import 'package:flutter/material.dart';
import '../core/api_client.dart';
import 'package:printing/printing.dart';
import '../utils/pdf_utils.dart';

class CreateParcelScreen extends StatefulWidget {
  final ApiClient apiClient;
  const CreateParcelScreen({super.key, required this.apiClient});

  @override
  State<CreateParcelScreen> createState() => _CreateParcelScreenState();
}

class _CreateParcelScreenState extends State<CreateParcelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tracking = TextEditingController();
  final _sender = TextEditingController();
  final _recipient = TextEditingController();
  final _destination = TextEditingController();
  final _weight = TextEditingController();
  bool _sending = false;
  String? _message;

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
      if (_weight.text.trim().isNotEmpty) "weight_kg": double.tryParse(_weight.text.trim()) ?? 0,
    };
    try {
      await widget.apiClient.createPackage(payload);
      setState(() => _message = "Created successfully");

      // Generate and preview PDF locally
      final pdfBytes = await PdfUtils.generatePackagePdf(
        trackingNumber: _tracking.text.trim(),
        sender: _sender.text.trim(),
        recipient: _recipient.text.trim(),
        destination: _destination.text.trim(),
        weight: _weight.text.trim(),
      );

      // Use printing package to preview / share
      await Printing.layoutPdf(onLayout: (_) => pdfBytes);

    } catch (e) {
      setState(() => _message = "Error: $e");
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  @override
  void dispose() {
    _tracking.dispose();
    _sender.dispose();
    _recipient.dispose();
    _destination.dispose();
    _weight.dispose();
    super.dispose();
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
              TextFormField(controller: _tracking, decoration: const InputDecoration(labelText: "Tracking Number"), validator: (v) => v!.isEmpty ? "required" : null),
              TextFormField(controller: _sender, decoration: const InputDecoration(labelText: "Sender"), validator: (v) => v!.isEmpty ? "required" : null),
              TextFormField(controller: _recipient, decoration: const InputDecoration(labelText: "Recipient"), validator: (v) => v!.isEmpty ? "required" : null),
              TextFormField(controller: _destination, decoration: const InputDecoration(labelText: "Destination"), validator: (v) => v!.isEmpty ? "required" : null),
              TextFormField(controller: _weight, decoration: const InputDecoration(labelText: "Weight (kg)"), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _sending ? null : _submit, child: _sending ? const CircularProgressIndicator() : const Text("Create & Preview PDF")),
              if (_message != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_message!)),
            ],
          ),
        ),
      ),
    );
  }
}
