import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';
import '../../config/db.dart';
import '../../models/auth/student_model.dart';

class AuthController {
  static const _uuid = Uuid();

  // POST /api/auth/login
  static Future<Response> login(Request req) async {
    try {
      final bodyText = await req.readAsString();
      if (bodyText.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Request body tidak boleh kosong'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = jsonDecode(bodyText) as Map<String, dynamic>;
      final email = body['email'] as String?;
      final password = body['password'] as String?;

      if (email == null || email.trim().isEmpty || password == null || password.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Email dan password wajib diisi.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final student = await StudentModel.findByEmail(email.trim());
      if (student == null || student.passwordHash == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Email atau password salah.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Verifikasi BCrypt
      final bool isMatch = BCrypt.checkpw(password, student.passwordHash!);
      if (!isMatch) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Email atau password salah.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Generate JWT
      final jwt = JWT({
        'idStudent': student.idStudent,
        'email': student.email,
        'name': student.name,
      });

      final token = jwt.sign(SecretKey(Database.jwtSecret), expiresIn: const Duration(days: 7));

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Login berhasil.',
          'token': token,
          'user': student.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[AUTH] Login error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': 'Terjadi kesalahan server.', 'detail': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/auth/register
  static Future<Response> register(Request req) async {
    try {
      final bodyText = await req.readAsString();
      if (bodyText.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Request body tidak boleh kosong'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = jsonDecode(bodyText) as Map<String, dynamic>;
      final name = body['name'] as String?;
      final email = body['email'] as String?;
      final password = body['password'] as String?;

      if (name == null || name.trim().isEmpty ||
          email == null || email.trim().isEmpty ||
          password == null || password.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Semua field wajib diisi (name, email, password).'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Cek apakah email sudah terdaftar
      final existing = await StudentModel.findByEmail(email.trim());
      if (existing != null) {
        return Response(
          409,
          body: jsonEncode({'status': 'error', 'message': 'Email sudah terdaftar.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final idStudent = _uuid.v4();
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      await StudentModel.create(
        idStudent: idStudent,
        name: name.trim(),
        email: email.trim(),
        passwordHash: passwordHash,
      );

      return Response(
        201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Registrasi berhasil.',
          'idStudent': idStudent,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[AUTH] Register error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': 'Terjadi kesalahan server.', 'detail': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // GET /api/auth/me (Protected)
  static Future<Response> getMe(Request req) async {
    try {
      final studentPayload = req.context['student'] as Map<String, dynamic>?;
      if (studentPayload == null) {
        return Response(401, body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}));
      }

      final idStudent = studentPayload['idStudent'] as String;
      final student = await StudentModel.findById(idStudent);

      if (student == null) {
        return Response.notFound(
          jsonEncode({'status': 'error', 'message': 'User tidak ditemukan.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({'status': 'success', 'user': student.toJson()}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
