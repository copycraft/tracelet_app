// lib/widgets/event_tile.dart
import 'package:flutter/material.dart';
import '../models/trace_event.dart';

class EventTile extends StatelessWidget {
  final TraceEvent event;
  const EventTile({super.key, required this.event});

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // map some common statuses to colors (fallbacks)
    final s = (event.status ?? '').toLowerCase();
    if (s.contains('delivered') || s.contains('done')) return Colors.green.shade600;
    if (s.contains('failed') || s.contains('error')) return Colors.red.shade600;
    if (s.contains('in_transit') || s.contains('transit') || s.contains('shipped')) return Colors.orange.shade600;
    return cs.primary;
  }

  @override
  Widget build(BuildContext context) {
    final ts = event.timestamp != null ? event.timestamp!.toLocal().toString() : 'unknown';
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: _statusColor(context).withOpacity(0.12),
          child: Icon(
            Icons.local_shipping,
            color: _statusColor(context),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                "${event.eventType}${event.status != null && event.status!.isNotEmpty ? ' — ${event.status}' : ''}",
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              ts.split(' ').first, // date only, keeps it compact
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.location != null && event.location!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text("Location: ${event.location}", style: theme.textTheme.bodySmall),
            ],
            if (event.actor != null && event.actor!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text("Actor: ${event.actor}", style: theme.textTheme.bodySmall),
            ],
            if (event.payload != null && event.payload!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text("Notes: ${event.payload!['notes']?.toString() ?? ''}", style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}