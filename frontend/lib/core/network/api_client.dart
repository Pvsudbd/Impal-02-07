import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Ganti ke IP LAN kamu kalau test di HP fisik, misal: http://192.168.1.x:3000
  static const String baseUrl = 'http://localhost:3000';

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

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

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

    final response = await http.get(uri, headers: headers);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
