class Parcel {
  final String id;
  final String type;
  final String? externalId;
  final DateTime createdAt;
  final Map<String, dynamic>? extraData;
  final String? latestStatus;

  Parcel({
    required this.id,
    required this.type,
    required this.createdAt,
    this.externalId,
    this.extraData,
    this.latestStatus,
  });

  factory Parcel.fromJson(Map<String, dynamic> json) {
    return Parcel(
      id: json["id"]?.toString() ?? "",
      type: json["type"]?.toString() ?? "package",
      externalId: json["external_id"]?.toString(),
      createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? "") ?? DateTime.now(),
      extraData: json["extra_data"] is Map ? Map<String, dynamic>.from(json["extra_data"]) : null,
      latestStatus: (json["extra_data"] is Map && (json["extra_data"]["status"] != null))
          ? json["extra_data"]["status"].toString()
          : null,
    );
  }
}
