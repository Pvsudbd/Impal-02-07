import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import '../../config/db.dart';

Middleware checkAuthMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          401,
          body: jsonEncode({
            'status': 'error',
            'message': 'Akses ditolak. Token tidak ditemukan.',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7); // Remove 'Bearer '

      try {
        final jwt = JWT.verify(token, SecretKey(Database.jwtSecret));
        final updatedRequest = request.change(context: {'student': jwt.payload});
        return await innerHandler(updatedRequest);
      } catch (e) {
        return Response(
          403,
          body: jsonEncode({
            'status': 'error',
            'message': 'Token tidak valid atau sudah expired.',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    };
  };
}
