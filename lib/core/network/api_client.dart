import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../data/prefs_service.dart';

class ApiClient {
  final String baseUrl;
  ApiClient({required this.baseUrl});

  // --------------------------------------------------------------
  // GET
  // --------------------------------------------------------------
  Future<http.Response> get(String path) async {
    final token = await PrefsService.readToken();

    final response = await http.get(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    _handleStatus(response);
    return response;
  }

  // --------------------------------------------------------------
  // POST
  // --------------------------------------------------------------
  Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    final token = await PrefsService.readToken();

    final response = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: body != null ? jsonEncode(body) : null,
    );

    _handleStatus(response);
    return response;
  }

  // --------------------------------------------------------------
  // DELETE
  // --------------------------------------------------------------
  Future<http.Response> delete(String path) async {
    final token = await PrefsService.readToken();

    final response = await http.delete(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    _handleStatus(response);
    return response;
  }

  // --------------------------------------------------------------
  // ERROR MANAGEMENT
  // --------------------------------------------------------------
  void _handleStatus(http.Response response) {
    if (response.statusCode == 401) {
      throw Exception("Unauthorized — token expired or invalid");
    }
    if (response.statusCode >= 500) {
      throw Exception("Server error — ${response.statusCode}");
    }
  }
}

// --------------------------------------------------------------
// Provider — FINAL (Staging Server Bağlı)
// --------------------------------------------------------------
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: "https://dailygood.dijicrea.net/api/v1",
  );
});
