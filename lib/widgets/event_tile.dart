import 'package:flutter/material.dart';

/// Example Event model
class Event {
  final String eventType;
  final String? actor;
  final String? location;
  final DateTime timestamp;

  Event({
    required this.eventType,
    this.actor,
    this.location,
    required this.timestamp,
  });
}

/// EventTile widget
class EventTile extends StatelessWidget {
  final Event event;

  const EventTile({super.key, required this.event});

  // Map status to colors for the little dot
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'created':
        return Colors.blue;
      case 'out_for_delivery':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // softer background instead of pure white
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored status dot
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: _statusColor(event.eventType),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Event details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event type
                Text(
                  event.eventType.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // black text
                  ),
                ),
                const SizedBox(height: 4),
                // Actor / Location (if present)
                if (event.actor != null || event.location != null)
                  Text(
                    '${event.actor ?? ""}${event.actor != null && event.location != null ? " • " : ""}${event.location ?? ""}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800, // dark grey
                    ),
                  ),
                const SizedBox(height: 4),
                // Timestamp
                Text(
                  '${event.timestamp}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
