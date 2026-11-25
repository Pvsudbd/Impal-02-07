import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';
import '../../config/db.dart';
import '../../models/auth/user_model.dart';

class AuthController {
  static const _uuid = Uuid();
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  // POST /api/auth/login
  static Future<Response> login(Request req) async {
    try {
      final bodyText = await req.readAsString();
      if (bodyText.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Request body tidak boleh kosong',
          }),
          headers: _jsonHeaders,
        );
      }

      final decoded = jsonDecode(bodyText);
      if (decoded is! Map<String, dynamic>) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Format JSON tidak valid.',
          }),
          headers: _jsonHeaders,
        );
      }

      final email = decoded['email'] as String?;
      final password = decoded['password'] as String?;

      if (email == null ||
          email.trim().isEmpty ||
          password == null ||
          password.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Email dan password wajib diisi.',
          }),
          headers: _jsonHeaders,
        );
      }

      final user = await UserModel.findByEmail(email);
      if (user == null || user.passwordHash == null) {
        return Response(
          401,
          body: jsonEncode({
            'status': 'error',
            'message': 'Email atau password salah.',
          }),
          headers: _jsonHeaders,
        );
      }

      // Verifikasi BCrypt
      final bool isMatch = BCrypt.checkpw(password, user.passwordHash!);
      if (!isMatch) {
        return Response(
          401,
          body: jsonEncode({
            'status': 'error',
            'message': 'Email atau password salah.',
          }),
          headers: _jsonHeaders,
        );
      }

      // Generate JWT
      final jwt = JWT({
        'idUser': user.idUser,
        'idStudent': user.idUser, // backward compatibility
        'email': user.email,
        'name': user.name,
      });

      final token = jwt.sign(
        SecretKey(Database.jwtSecret),
        expiresIn: const Duration(days: 7),
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Login berhasil.',
          'token': token,
          'user': user.toJson(),
        }),
        headers: _jsonHeaders,
      );
    } on FormatException {
      return Response.badRequest(
        body: jsonEncode({
          'status': 'error',
          'message': 'Format JSON tidak valid.',
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[AUTH] Login error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Terjadi kesalahan pada server saat login.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // POST /api/auth/register
  static Future<Response> register(Request req) async {
    try {
      final bodyText = await req.readAsString();
      if (bodyText.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Request body tidak boleh kosong',
          }),
          headers: _jsonHeaders,
        );
      }

      final decoded = jsonDecode(bodyText);
      if (decoded is! Map<String, dynamic>) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Format JSON tidak valid.',
          }),
          headers: _jsonHeaders,
        );
      }

      final name = decoded['name'] as String?;
      final email = decoded['email'] as String?;
      final password = decoded['password'] as String?;

      if (name == null ||
          name.trim().isEmpty ||
          email == null ||
          email.trim().isEmpty ||
          password == null ||
          password.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Semua field wajib diisi (name, email, password).',
          }),
          headers: _jsonHeaders,
        );
      }

      final cleanName = name.trim();
      final cleanEmail = email.trim().toLowerCase();

      if (cleanName.length > 100) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Nama lengkap maksimal 100 karakter.',
          }),
          headers: _jsonHeaders,
        );
      }

      if (cleanEmail.length > 100 || !_emailRegex.hasMatch(cleanEmail)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Format email tidak valid.',
          }),
          headers: _jsonHeaders,
        );
      }

      if (password.length < 6) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Password minimal harus 6 karakter.',
          }),
          headers: _jsonHeaders,
        );
      }

      if (password.contains(RegExp(r'\s'))) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Password tidak boleh mengandung spasi.',
          }),
          headers: _jsonHeaders,
        );
      }

      final existing = await UserModel.findByEmail(cleanEmail);
      if (existing != null) {
        return Response(
          409,
          body: jsonEncode({
            'status': 'error',
            'message': 'Email sudah terdaftar.',
          }),
          headers: _jsonHeaders,
        );
      }

      final idUser = _uuid.v4();
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      await UserModel.create(
        idUser: idUser,
        name: cleanName,
        email: cleanEmail,
        passwordHash: passwordHash,
      );

      return Response(
        201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Registrasi berhasil.',
          'idUser': idUser,
          'idStudent': idUser, // backward compatibility
        }),
        headers: _jsonHeaders,
      );
    } on FormatException {
      return Response.badRequest(
        body: jsonEncode({
          'status': 'error',
          'message': 'Format JSON tidak valid.',
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[AUTH] Register error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Terjadi kesalahan pada server saat registrasi.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // GET /api/auth/me (Protected)
  static Future<Response> getMe(Request req) async {
    try {
      final userPayload =
          (req.context['user'] ?? req.context['student']) as Map<String, dynamic>?;
      if (userPayload == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final idUser = (userPayload['idUser'] ?? userPayload['idStudent']) as String;
      final user = await UserModel.findById(idUser);

      if (user == null) {
        return Response.notFound(
          jsonEncode({'status': 'error', 'message': 'User tidak ditemukan.'}),
          headers: _jsonHeaders,
        );
      }

      return Response.ok(
        jsonEncode({'status': 'success', 'user': user.toJson()}),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[AUTH] getMe error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengambil data pengguna.',
        }),
        headers: _jsonHeaders,
      );
    }
  }
}
