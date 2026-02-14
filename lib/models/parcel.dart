import 'trace_event.dart';
import 'package:flutter/foundation.dart';

class Parcel {
  final String id;
  final String type;
  final String? externalId;
  final DateTime createdAt;
  final Map<String, dynamic>? extraData;
  final String? latestStatus;
  final List<TraceEvent> events;

  Parcel({
    required this.id,
    required this.type,
    required this.createdAt,
    this.externalId,
    this.extraData,
    this.latestStatus,
    required this.events,
  });

  factory Parcel.fromJson(Map<String, dynamic> json) {
    final extra = json['extra_data'] is Map
        ? Map<String, dynamic>.from(json['extra_data'])
        : null;

    List<TraceEvent> eventList = [];

    // Recursive helper to find events anywhere in the JSON
    void searchForEvents(dynamic node) {
      try {
        if (node is List) {
          for (var e in node) {
            if (e is Map &&
                (e.containsKey('event_type') ||
                    e.containsKey('status') ||
                    e.containsKey('timestamp') ||
                    e.containsKey('time'))) {
              debugPrint("DEBUG: Found event -> $e");
              eventList.add(TraceEvent.fromJson(Map<String, dynamic>.from(e)));
            } else {
              searchForEvents(e);
            }
          }
        } else if (node is Map) {
          node.values.forEach(searchForEvents);
        }
      } catch (ex, st) {
        debugPrint("Error in searchForEvents: $ex\n$st");
      }
    }

    searchForEvents(json);

    // Sort events descending by timestamp
    eventList.sort((a, b) {
      if (a.timestamp == null && b.timestamp == null) return 0;
      if (a.timestamp == null) return 1;
      if (b.timestamp == null) return -1;
      return b.timestamp!.compareTo(a.timestamp!);
    });

    return Parcel(
      id: json["id"]?.toString() ?? "",
      type: json["type"]?.toString() ?? "package",
      externalId: json["external_id"]?.toString() ??
          json['tracking_number']?.toString(),
      createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? "") ??
          DateTime.now(),
      extraData: extra,
      latestStatus: extra != null && extra['status'] != null
          ? extra['status'].toString()
          : null,
      events: eventList,
    );
  }
}
