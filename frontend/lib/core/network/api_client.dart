import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';
import 'api_response.dart';

/// Centralized API Client for backend communication
class ApiClient {
  // Base URL default server backend Dart Shelf (port 3000)
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3000';
      default:
        return 'http://localhost:3000';
    }
  }

  static const Duration requestTimeout = Duration(seconds: 15);

  // ==========================================
  // Static Direct Methods (JSON Map Response)
  // Digunakan oleh AuthRemoteDatasource & ScheduleRepository
  // ==========================================

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http
        .post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(requestTimeout);

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers).timeout(requestTimeout);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http
        .put(
          uri,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(requestTimeout);

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.delete(uri, headers: headers).timeout(requestTimeout);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ==========================================
  // Instance-based Methods (ApiResponse<T>)
  // ==========================================

  final http.Client _client;
  final String _instanceBaseUrl;
  String? _cachedToken;

  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _instanceBaseUrl = baseUrl ?? ApiEndpoints.baseUrl;

  /// Allows explicit token injection (e.g. after login)
  void setToken(String? token) {
    _cachedToken = token;
  }

  Future<String?> _getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString('auth_token') ?? prefs.getString('jwt_token');
    return _cachedToken;
  }

  Future<Map<String, String>> _buildHeaders({
    Map<String, String>? extraHeaders,
    bool requiresAuth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  /// Sends a GET request returning ApiResponse<T>
  Future<ApiResponse<T>> fetchGet<T>(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final uri = Uri.parse('$_instanceBaseUrl$path').replace(queryParameters: queryParams);
      final finalHeaders = await _buildHeaders(extraHeaders: headers, requiresAuth: requiresAuth);

      final response = await _client.get(uri, headers: finalHeaders).timeout(requestTimeout);
      return _parseResponse<T>(response, parser);
    } on SocketException {
      return ApiResponse<T>(
        success: false,
        message: 'Network connection failed. Please check your internet or local server.',
        error: 'SocketException',
      );
    } on TimeoutException {
      return ApiResponse<T>(
        success: false,
        message: 'Request timed out after 15 seconds.',
        error: 'TimeoutException',
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Unexpected error: $e',
        error: e.toString(),
      );
    }
  }

  /// Sends a POST request returning ApiResponse<T>
  Future<ApiResponse<T>> fetchPost<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final uri = Uri.parse('$_instanceBaseUrl$path');
      final finalHeaders = await _buildHeaders(extraHeaders: headers, requiresAuth: requiresAuth);

      final response = await _client
          .post(
            uri,
            headers: finalHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(requestTimeout);

      return _parseResponse<T>(response, parser);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Request failed: $e',
        error: e.toString(),
      );
    }
  }

  ApiResponse<T> _parseResponse<T>(
    http.Response response,
    T Function(dynamic json)? parser,
  ) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return ApiResponse.fromJson(decoded, parser);
      }
      return ApiResponse<T>(
        success: response.statusCode >= 200 && response.statusCode < 300,
        message: 'Response received',
        data: parser != null ? parser(decoded) : decoded as T?,
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Failed to parse JSON response: $e',
        error: response.body,
      );
    }
  }
}
