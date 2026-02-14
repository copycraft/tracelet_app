// lib/core/api_client.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const _prefKey = "tracelet_base_url";
  static ApiClient? _instance;

  final Dio _dio;
  final String baseUrl;

  // Private constructor
  ApiClient._internal(this.baseUrl)
      : _dio = Dio(BaseOptions(
    baseUrl: _normalizeBaseUrl(baseUrl),
    connectTimeout: const Duration(seconds: 7),
    receiveTimeout: const Duration(seconds: 7),
    sendTimeout: const Duration(seconds: 7),
    headers: {"Content-Type": "application/json"},
  ));

  /// Get the singleton instance
  static Future<ApiClient?> getInstance() async {
    if (_instance != null) return _instance;

    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_prefKey);
    if (url != null && url.isNotEmpty) {
      _instance = ApiClient._internal(url);
      return _instance;
    }
    return null;
  }

  /// Set and save base URL
  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, url);
    _instance = ApiClient._internal(url);
  }

  /// Clear base URL
  static Future<void> clearBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    _instance = null;
  }

  static String _normalizeBaseUrl(String url) {
    if (url.endsWith('/')) return url.substring(0, url.length - 1);
    return url;
  }

  // ------------------------
  // Health / Meta
  // ------------------------
  Future<Map<String, dynamic>> health() async {
    final res = await _dio.get("/api/v1/health");
    return _ensureMap(res);
  }

  Future<Map<String, dynamic>> version() async {
    final res = await _dio.get("/api/v1/version");
    return _ensureMap(res);
  }

  // ------------------------
  // Tracking / Packages
  // ------------------------
  Future<Map<String, dynamic>> trackPackage(String trackingNumber) async {
    final res = await _dio.get("/api/v1/tracking/track/$trackingNumber");
    return _ensureMap(res);
  }

  Future<Uint8List> downloadPackagePdf(String trackingNumber) async {
    final res = await _dio.get<List<int>>(
      "/api/v1/tracking_pdf/download-pdf/$trackingNumber",
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(res.data ?? []);
  }

  Future<Map<String, dynamic>> createPackage(Map<String, dynamic> payload) async {
    final res = await _dio.post("/api/v1/tracking/package", data: payload);
    return _ensureMap(res);
  }

  Future<List<Map<String, dynamic>>> listPackages({String? status, int skip = 0, int limit = 100}) async {
    final res = await _dio.get("/api/v1/tracking/packages", queryParameters: {
      if (status != null) "status": status,
      "skip": skip,
      "limit": limit,
    });

    final data = res.data;
    if (data is List) {
      return List<Map<String, dynamic>>.from(data.map((e) => Map<String, dynamic>.from(e)));
    }

    if (data is Map && data['packages'] is List) {
      return List<Map<String, dynamic>>.from((data['packages'] as List).map((e) => Map<String, dynamic>.from(e)));
    }

    return [];
  }

  Future<Map<String, dynamic>> stats() async {
    final res = await _dio.get("/api/v1/tracking/stats");
    return _ensureMap(res);
  }

  // ------------------------
  // Entities & Events
  // ------------------------
  Future<Map<String, dynamic>> getEntity(String id) async {
    final res = await _dio.get("/api/v1/entities/$id");
    return _ensureMap(res);
  }

  Future<Map<String, dynamic>> traceTree(String id) async {
    final res = await _dio.get("/api/v1/trace/$id/tree");
    return _ensureMap(res);
  }

  Future<List<Map<String, dynamic>>> fetchTraceEvents(String entityId) async {
    final res = await _dio.get("/api/v1/events/entity/$entityId");

    final data = res.data;
    if (data is List) {
      return List<Map<String, dynamic>>.from(data.map((e) => Map<String, dynamic>.from(e)));
    }

    if (data is Map && data['events'] is List) {
      return List<Map<String, dynamic>>.from((data['events'] as List).map((e) => Map<String, dynamic>.from(e)));
    }

    return [];
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> payload) async {
    final res = await _dio.post("/api/v1/events/", data: payload);
    return _ensureMap(res);
  }

  // ------------------------
  // Helpers
  // ------------------------
  Map<String, dynamic> _ensureMap(Response r) {
    final d = r.data;
    if (d is Map<String, dynamic>) return d;
    if (d is String) {
      try {
        final parsed = jsonDecode(d);
        if (parsed is Map<String, dynamic>) return parsed;
      } catch (_) {}
    }
    return {};
  }
}
