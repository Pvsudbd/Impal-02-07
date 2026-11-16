import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../models/profile/profile_model.dart';

/// Controller handling HTTP requests for the User Profile & User academic domain.
/// Adheres strictly to .agents/cybersecurity.md:
/// - Extracts idUser solely from verified JWT payload (BOLA/IDOR protection).
/// - Whitelists allowable fields (Mass Assignment protection).
/// - Sanitizes error responses to prevent internal information leakage.
class ProfileController {
  // Helper to extract authenticated user from JWT
  static Map<String, dynamic>? _getAuthUser(Request req) {
    return (req.context['user'] ?? req.context['student']) as Map<String, dynamic>?;
  }

  // ─── GET /api/profile or /api/user ─────────────────────────────────────────
  static Future<Response> getProfile(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final idUser = (user['idUser'] ?? user['idStudent']) as String;
      final profile = await ProfileModel.getProfile(idUser);

      if (profile == null) {
        return Response.notFound(
          jsonEncode({'status': 'error', 'message': 'Profil pengguna tidak ditemukan.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Profil berhasil diambil.',
          'data': profile.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[PROFILE] getProfile error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': 'Gagal mengambil data profil.'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── PUT /api/profile or /api/user ─────────────────────────────────────────
  static Future<Response> updateProfile(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final idUser = (user['idUser'] ?? user['idStudent']) as String;
      final bodyText = await req.readAsString();
      if (bodyText.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Request body tidak boleh kosong'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = jsonDecode(bodyText) as Map<String, dynamic>;
      // Whitelist only allowed fields to prevent Mass Assignment
      final name = body['name'] as String? ?? body['fullName'] as String?;
      final email = body['email'] as String?;

      if (name == null || name.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Nama lengkap wajib diisi.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (name.trim().length < 2) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Nama lengkap minimal 2 karakter.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (email != null && email.trim().isNotEmpty) {
        final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        if (!emailRegex.hasMatch(email.trim())) {
          return Response.badRequest(
            body: jsonEncode({'status': 'error', 'message': 'Format email tidak valid.'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      await ProfileModel.updateProfile(
        idUser,
        name: name.trim(),
        email: email?.trim(),
      );

      final updated = await ProfileModel.getProfile(idUser);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Profil berhasil diperbarui.',
          'data': updated?.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[PROFILE] updateProfile error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': 'Gagal memperbarui profil.'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── PUT /api/profile/password ─────────────────────────────────────────────
  static Future<Response> changePassword(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final idUser = (user['idUser'] ?? user['idStudent']) as String;
      final bodyText = await req.readAsString();
      if (bodyText.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Request body tidak boleh kosong'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = jsonDecode(bodyText) as Map<String, dynamic>;
      final currentPassword = body['currentPassword'] as String?;
      final newPassword = body['newPassword'] as String?;

      if (currentPassword == null || currentPassword.isEmpty ||
          newPassword == null || newPassword.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Password saat ini dan password baru wajib diisi.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (newPassword.length < 6) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Password baru minimal harus 6 karakter.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (newPassword == currentPassword) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Password baru tidak boleh sama dengan password saat ini.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = await ProfileModel.changePassword(
        idUser,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result['success'] != true) {
        return Response(
          400,
          body: jsonEncode({'status': 'error', 'message': result['message']}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': result['message'],
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[PROFILE] changePassword error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': 'Gagal mengganti password.'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── GET /api/profile/daily-agenda?date=YYYY-MM-DD ─────────────────────────
  static Future<Response> viewDailyAgenda(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final idUser = (user['idUser'] ?? user['idStudent']) as String;
      final dateQuery = req.url.queryParameters['date'];
      final targetDate = dateQuery != null ? DateTime.tryParse(dateQuery) ?? DateTime.now() : DateTime.now();

      final agendas = await ProfileModel.viewDailyAgenda(idUser, targetDate);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Jadwal harian berhasil diambil.',
          'date': "${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}",
          'total': agendas.length,
          'data': agendas,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[PROFILE] viewDailyAgenda error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': 'Gagal mengambil jadwal harian.'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── GET /api/profile/course-schedules ─────────────────────────────────────
  static Future<Response> viewCourseSchedule(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final idUser = (user['idUser'] ?? user['idStudent']) as String;
      final courses = await ProfileModel.viewCourseSchedule(idUser);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Jadwal kuliah berhasil diambil.',
          'total': courses.length,
          'data': courses,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[PROFILE] viewCourseSchedule error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': 'Gagal mengambil jadwal kuliah.'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── GET /api/profile/remaining-tasks ──────────────────────────────────────
  static Future<Response> viewRemainingTasks(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final idUser = (user['idUser'] ?? user['idStudent']) as String;
      final tasks = await ProfileModel.viewRemainingTasks(idUser);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Daftar sisa tugas berhasil diambil.',
          'total': tasks.length,
          'data': tasks,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[PROFILE] viewRemainingTasks error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': 'Gagal mengambil sisa tugas.'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── POST /api/profile/join-group ──────────────────────────────────────────
  static Future<Response> joinGroup(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final idUser = (user['idUser'] ?? user['idStudent']) as String;
      final bodyText = await req.readAsString();
      if (bodyText.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Request body tidak boleh kosong'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = jsonDecode(bodyText) as Map<String, dynamic>;
      final inviteCode = body['inviteCode'] as String? ?? body['teamCode'] as String?;

      if (inviteCode == null || inviteCode.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Kode undangan kelompok wajib diisi.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = await ProfileModel.joinGroup(idUser, inviteCode);
      if (result['success'] != true) {
        return Response(
          400,
          body: jsonEncode({'status': 'error', 'message': result['message']}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': result['message'],
          'data': result['data'],
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[PROFILE] joinGroup error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': 'Gagal bergabung ke kelompok.'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
