import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';

class ApiProvider with ChangeNotifier {
  static const _prefKey = "tracelet_base_url";
  ApiClient? client;
  String? baseUrl;
  bool _loaded = false;

  Future<bool> ensureLoaded() async {
    if (_loaded) return true;
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString(_prefKey);
    if (baseUrl != null && baseUrl!.isNotEmpty) {
      client = ApiClient(baseUrl!);
    }
    _loaded = true;
    return true;
  }

  Future<void> setBaseUrl(String base) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, base);
    baseUrl = base;
    client = ApiClient(base);
    notifyListeners();
  }

  Future<void> clearBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    baseUrl = null;
    client = null;
    notifyListeners();
  }
}
