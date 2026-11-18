import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';
import 'api_response.dart';

/// Studio API Client for communicating with Dart Frog Backend and PostgreSQL.
///
/// Complies with AGENTS.md Section 6:
/// - Adaptive Base URL detection
/// - Automatic Bearer token header injection
/// - Envelope JSON parsing
class ApiClient {
  final http.Client _client;
  final String _baseUrl;
  String? _cachedToken;

  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiEndpoints.baseUrl;

  static const Duration requestTimeout = Duration(seconds: 15);

  /// Allows explicit token injection (e.g. after login)
  void setToken(String? token) {
    _cachedToken = token;
  }

  Future<String?> _getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString('jwt_token');
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

  /// Sends a GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);
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

  /// Sends a POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
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

