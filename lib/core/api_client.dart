import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/trace_event.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(String baseUrl)
      : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 7),
    receiveTimeout: const Duration(seconds: 7),
    headers: {"Content-Type": "application/json"},
  ));

  // ... your other methods ...

  /// Fetch trace events for an entity (returns parsed TraceEvent list)
  Future<List<TraceEvent>> fetchTraceEvents(String entityId) async {
    final response = await _dio.get("/api/v1/events/entity/$entityId");
    if (response.data is List) {
      return (response.data as List)
          .map((e) => TraceEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    // some endpoints return {"events": [...]}
    if (response.data is Map && response.data['events'] is List) {
      return (response.data['events'] as List)
          .map((e) => TraceEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// Download server-generated PDF for a package
  Future<Uint8List> downloadPackagePdf(String trackingNumber) async {
    final response = await _dio.get<List<int>>(
      "/api/v1/tracking/$trackingNumber/download-pdf",
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    return Uint8List.fromList(bytes ?? []);
  }
}
