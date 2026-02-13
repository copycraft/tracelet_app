import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(String baseUrl)
      : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {"Content-Type": "application/json"},
  ));

  // -------- DASHBOARD --------

  Future<Map<String, dynamic>> health() async {
    final res = await _dio.get("/health");
    return res.data;
  }

  // -------- TRACKING --------

  Future<Map<String, dynamic>> trackPackage(String trackingNumber) async {
    final res =
    await _dio.get("/api/v1/tracking/track/$trackingNumber");
    return res.data;
  }

  Future<List<dynamic>> listPackages({String? status}) async {
    final res = await _dio.get(
      "/api/v1/tracking/packages",
      queryParameters: {
        if (status != null) "status": status,
      },
    );
    return res.data;
  }

  Future<void> createPackage(Map<String, dynamic> data) async {
    await _dio.post("/api/v1/tracking/package", data: data);
  }

  Future<void> addEvent(
      String entityId,
      Map<String, dynamic> data) async {
    await _dio.post("/api/v1/events/", data: {
      ...data,
      "entity_id": entityId,
    });
  }

  // -------- ENTITIES --------

  Future<Map<String, dynamic>> getEntity(String id) async {
    final res = await _dio.get("/api/v1/entities/$id");
    return res.data;
  }

  Future<Map<String, dynamic>> traceTree(String id) async {
    final res =
    await _dio.get("/api/v1/trace/$id/tree");
    return res.data;
  }
}
