import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trace_event.dart';

class EventTile extends StatelessWidget {
  final TraceEvent event;

  const EventTile({
    Key? key,
    required this.event,
  }) : super(key: key);

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "delivered":
        return Colors.green;
      case "exception":
      case "failed_delivery":
        return Colors.red;
      case "in_transit":
      case "out_for_delivery":
        return Colors.blue;
      case "customs":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(event.timestamp);
    final formattedDate = date != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(date)
        : event.timestamp;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Dot
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

          // Event Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.eventType.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                if (event.location != null)
                  Text(
                    "Location: ${event.location}",
                    style: const TextStyle(fontSize: 14),
                  ),

                if (event.actor != null)
                  Text(
                    "Actor: ${event.actor}",
                    style: const TextStyle(fontSize: 14),
                  ),

                const SizedBox(height: 6),

                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                if (event.payload != null &&
                    event.payload!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.payload.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: "monospace",
                        ),
                      ),
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
