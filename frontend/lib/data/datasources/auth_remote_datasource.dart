import '../../core/network/api_client.dart';

class AuthRemoteDatasource {
  /// Login — returns { token, user } atau throws Exception dengan pesan error
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/api/auth/login',
      {'email': email, 'password': password},
    );

    if (response['status'] == 'success') {
      return response;
    } else {
      throw Exception(response['message'] ?? 'Login gagal');
    }
  }

  /// Register — returns idStudent atau throws Exception dengan pesan error
  static Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/api/auth/register',
      {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    if (response['status'] == 'success') {
      return response['idStudent'] as String;
    } else {
      throw Exception(response['message'] ?? 'Registrasi gagal');
    }
  }
}
