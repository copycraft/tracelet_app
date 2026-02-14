import 'package:flutter/material.dart';
import '../models/trace_event.dart'; // make sure this is where TraceEvent is defined

class EventTile extends StatelessWidget {
  final TraceEvent event;

  const EventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // soft background instead of bright white
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.status ?? "Unknown status",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black, // black letters
            ),
          ),
          const SizedBox(height: 4),
          if (event.location != null)
            Text(
              "Location: ${event.location}",
              style: const TextStyle(color: Colors.black87),
            ),
          if (event.actor != null)
            Text(
              "Actor: ${event.actor}",
              style: const TextStyle(color: Colors.black87),
            ),
          Text(
            "Time: ${event.timestamp?.toLocal().toString() ?? "Unknown"}",
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
