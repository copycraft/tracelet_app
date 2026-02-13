import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/parcel.dart';
import 'trace_screen.dart';

class EntityDetailScreen extends StatefulWidget {
  final ApiClient apiClient;
  final String entityId;

  const EntityDetailScreen({
    super.key,
    required this.apiClient,
    required this.entityId,
  });

  @override
  State<EntityDetailScreen> createState() => _EntityDetailScreenState();
}

class _EntityDetailScreenState extends State<EntityDetailScreen> {
  Parcel? parcel;
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
      final data = await widget.apiClient.getEntity(widget.entityId);
      setState(() => parcel = Parcel.fromJson(data));
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Entity Detail")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (parcel != null)
              Card(
                child: ListTile(
                  title: Text(parcel!.externalId ?? parcel!.id),
                  subtitle: Text(
                      "Type: ${parcel!.type}\nCreated: ${parcel!.createdAt}"),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TraceScreen(
                    apiClient: widget.apiClient,
                    entityId: widget.entityId, // use entityId here
                  ),
                ));
              },
              child: const Text("View Trace Tree"),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text("Error: $error"),
              ),
          ],
        ),
      ),
    );
  }
}
