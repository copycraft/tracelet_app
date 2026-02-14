// lib/models/trace_event.dart
class TraceEvent {
  final String id;
  final String entityId;
  final String eventType;
  final DateTime? timestamp;
  final String? location;
  final String? actor;
  final String? status;
  final Map<String, dynamic>? payload;
  final String? notes;

  TraceEvent({
    required this.id,
    required this.entityId,
    required this.eventType,
    this.timestamp,
    this.location,
    this.actor,
    this.status,
    this.payload,
    this.notes,
  });

  factory TraceEvent.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    final payload = rawPayload is Map ? Map<String, dynamic>.from(rawPayload) : <String, dynamic>{};

    DateTime? parsedTs;
    final tsCandidate = json['timestamp'] ?? json['created_at'] ?? payload['timestamp'] ?? payload['created_at'];
    if (tsCandidate != null) {
      parsedTs = DateTime.tryParse(tsCandidate.toString());
    }

    return TraceEvent(
      id: json['id']?.toString() ?? '',
      entityId: json['entity_id']?.toString() ?? json['entityId']?.toString() ?? '',
      eventType: json['event_type']?.toString() ?? json['type']?.toString() ?? '',
      timestamp: parsedTs,
      location: (json['location']?.toString()) ?? (payload['location']?.toString()),
      actor: (json['actor']?.toString()) ?? (payload['actor']?.toString()),
      status: (json['status']?.toString()) ?? (payload['status']?.toString()),
      notes: (payload['notes']?.toString()) ?? (json['notes']?.toString()),
      payload: payload.isNotEmpty ? payload : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity_id': entityId,
      'event_type': eventType,
      'timestamp': timestamp?.toIso8601String(),
      'location': location,
      'actor': actor,
      'status': status,
      'payload': payload,
    };
  }
}
