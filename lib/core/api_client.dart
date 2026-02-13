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

  /// Fetch a single entity/package by its ID
  Future<Map<String, dynamic>> getEntity(String id) async {
    final response = await _dio.get("/api/v1/entities/$id");
    return _ensureMap(response);
  }

  /// List parcels/packages, with optional status and pagination
  Future<List<Map<String, dynamic>>> listPackages({
    String? status,
    int skip = 0,
    int limit = 100,
  }) async {
    final response = await _dio.get("/api/v1/tracking/packages", queryParameters: {
      if (status != null) "status": status,
      "skip": skip,
      "limit": limit,
    });

    if (response.data is List) {
      return List<Map<String, dynamic>>.from(response.data);
    }

    if (response.data is Map && response.data['packages'] is List) {
      return List<Map<String, dynamic>>.from(response.data['packages']);
    }

    return [];
  }

  /// Fetch trace events for an entity
  Future<List<TraceEvent>> fetchTraceEvents(String entityId) async {
    final response = await _dio.get("/api/v1/events/entity/$entityId");

    if (response.data is List) {
      return (response.data as List)
          .map((e) => TraceEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

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

  /// Utility: create a new package
  Future<Map<String, dynamic>> createPackage(Map<String, dynamic> payload) async {
    final r = await _dio.post("/api/v1/tracking/package", data: payload);
    return _ensureMap(r);
  }

  Map<String, dynamic> _ensureMap(Response r) {
    if (r.data is Map<String, dynamic>) return r.data as Map<String, dynamic>;
    if (r.data is String) return jsonDecode(r.data as String) as Map<String, dynamic>;
    return {};
  }

  /// Fetch statistics like total packages
  Future<Map<String, dynamic>> stats() async {
    final r = await _dio.get("/api/v1/tracking/stats");
    return _ensureMap(r);
  }

  /// Fetch a single package by its tracking number
  Future<Map<String, dynamic>> trackPackage(String trackingNumber) async {
    final response = await _dio.get("/api/v1/tracking/track/$trackingNumber");
    return _ensureMap(response);
  }

}
