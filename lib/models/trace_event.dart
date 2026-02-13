class TraceEvent {
  final String id;
  final String entityId;
  final String eventType;
  final String timestamp;
  final String? location;
  final String? actor;
  final String? status;
  final Map<String, dynamic>? payload;

  TraceEvent({
    required this.id,
    required this.entityId,
    required this.eventType,
    required this.timestamp,
    this.location,
    this.actor,
    this.status,
    this.payload,
  });

  factory TraceEvent.fromJson(Map<String, dynamic> json) {
    return TraceEvent(
      id: json['id'] ?? '',
      entityId: json['entity_id'] ?? '',
      eventType: json['event_type'] ?? '',
      timestamp: json['timestamp'] ?? '',
      location: json['location'],
      actor: json['actor'],
      status: json['status'],
      payload: json['payload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "entity_id": entityId,
      "event_type": eventType,
      "timestamp": timestamp,
      "location": location,
      "actor": actor,
      "status": status,
      "payload": payload,
    };
  }
}
