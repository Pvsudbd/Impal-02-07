import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../models/profile/profile_model.dart';

/// Controller handling HTTP requests for the User Profile & User academic domain.
/// Adheres strictly to .agents/cybersecurity.md:
/// - Extracts idUser solely from verified JWT payload (BOLA/IDOR protection).
/// - Whitelists allowable fields (Mass Assignment protection).
/// - Sanitizes error responses to prevent internal information leakage.
class ProfileController {
  static const _jsonHeaders = {'Content-Type': 'application/json'};
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  // Helper to extract authenticated user from JWT
  static Map<String, dynamic>? _getAuthUser(Request req) {
    return (req.context['user'] ?? req.context['student'])
        as Map<String, dynamic>?;
  }

  // ─── GET /api/profile or /api/user ─────────────────────────────────────────
  static Future<Response> getProfile(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final idUser = (user['idUser'] ?? user['idStudent']) as String;
      final profile = await ProfileModel.getProfile(idUser);

      if (profile == null) {
        return Response.notFound(
          jsonEncode({
            'status': 'error',
            'message': 'Profil pengguna tidak ditemukan.',
          }),
          headers: _jsonHeaders,
        );
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Profil berhasil diambil.',
          'data': profile.toJson(),
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[PROFILE] getProfile error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengambil data profil.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // ─── PUT /api/profile or /api/user ─────────────────────────────────────────
  static Future<Response> updateProfile(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final idUser = (user['idUser'] ?? user['idStudent']) as String;
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

      // Whitelist only allowed fields to prevent Mass Assignment
      final name = decoded['name'] as String? ?? decoded['fullName'] as String?;
      final email = decoded['email'] as String?;

      if (name == null || name.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Nama lengkap wajib diisi.',
          }),
          headers: _jsonHeaders,
        );
      }

      if (name.trim().length > 100) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Nama lengkap maksimal 100 karakter.',
          }),
          headers: _jsonHeaders,
        );
      }

      if (email != null && email.trim().isNotEmpty) {
        final cleanEmail = email.trim().toLowerCase();
        if (cleanEmail.length > 100 || !_emailRegex.hasMatch(cleanEmail)) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Format email tidak valid.',
            }),
            headers: _jsonHeaders,
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
        headers: _jsonHeaders,
      );
    } on DuplicateEmailException catch (e) {
      return Response(
        409,
        body: jsonEncode({
          'status': 'error',
          'message': e.message,
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
      print('[PROFILE] updateProfile error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal memperbarui profil.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // ─── PUT /api/profile/password ─────────────────────────────────────────────
  static Future<Response> changePassword(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final idUser = (user['idUser'] ?? user['idStudent']) as String;
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

      final currentPassword = decoded['currentPassword'] as String?;
      final newPassword = decoded['newPassword'] as String?;

      if (currentPassword == null ||
          currentPassword.isEmpty ||
          newPassword == null ||
          newPassword.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Password saat ini dan password baru wajib diisi.',
          }),
          headers: _jsonHeaders,
        );
      }

      if (newPassword.length < 6) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Password baru minimal harus 6 karakter.',
          }),
          headers: _jsonHeaders,
        );
      }

      if (newPassword.contains(RegExp(r'\s'))) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Password baru tidak boleh mengandung spasi.',
          }),
          headers: _jsonHeaders,
        );
      }

      if (newPassword == currentPassword) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message':
                'Password baru tidak boleh sama dengan password saat ini.',
          }),
          headers: _jsonHeaders,
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
          headers: _jsonHeaders,
        );
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': result['message'],
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
      print('[PROFILE] changePassword error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengganti password.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // ─── GET /api/profile/daily-agenda?date=YYYY-MM-DD ─────────────────────────
  static Future<Response> viewDailyAgenda(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final idUser = (user['idUser'] ?? user['idStudent']) as String;
      final dateQuery = req.url.queryParameters['date'];
      final targetDate = dateQuery != null
          ? DateTime.tryParse(dateQuery) ?? DateTime.now()
          : DateTime.now();

      final agendas = await ProfileModel.viewDailyAgenda(idUser, targetDate);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Jadwal harian berhasil diambil.',
          'date':
              "${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}",
          'total': agendas.length,
          'data': agendas,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[PROFILE] viewDailyAgenda error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengambil jadwal harian.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // ─── GET /api/profile/course-schedules ─────────────────────────────────────
  static Future<Response> viewCourseSchedule(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
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
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[PROFILE] viewCourseSchedule error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengambil jadwal kuliah.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // ─── GET /api/profile/remaining-tasks ──────────────────────────────────────
  static Future<Response> viewRemainingTasks(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
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
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[PROFILE] viewRemainingTasks error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengambil sisa tugas.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // ─── POST /api/profile/join-group ──────────────────────────────────────────
  static Future<Response> joinGroup(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final idUser = (user['idUser'] ?? user['idStudent']) as String;
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

      final inviteCode =
          decoded['inviteCode'] as String? ?? decoded['teamCode'] as String?;

      if (inviteCode == null || inviteCode.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Kode undangan kelompok wajib diisi.',
          }),
          headers: _jsonHeaders,
        );
      }

      final result = await ProfileModel.joinGroup(idUser, inviteCode);
      if (result['success'] != true) {
        return Response(
          400,
          body: jsonEncode({'status': 'error', 'message': result['message']}),
          headers: _jsonHeaders,
        );
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': result['message'],
          'data': result['data'],
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
      print('[PROFILE] joinGroup error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal bergabung ke kelompok.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // ─── GET /api/profile/preferences ──────────────────────────────────────────
  static Future<Response> getPreferences(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final idUser =
          (user['idUser'] ?? user['idStudent'] ?? user['id_user']) as String?;
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final preferences = await ProfileModel.getPreferences(idUser);
      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Preferensi reminder dan jadwal berhasil diambil.',
          'data': preferences,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[PROFILE] getPreferences error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengambil preferensi.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // ─── PUT /api/profile/preferences ──────────────────────────────────────────
  static Future<Response> updatePreferences(Request req) async {
    try {
      final user = _getAuthUser(req);
      if (user == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final idUser =
          (user['idUser'] ?? user['idStudent'] ?? user['id_user']) as String?;
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final bodyText = await req.readAsString();
      if (bodyText.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Request body tidak boleh kosong.',
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

      final updated = await ProfileModel.upsertPreferences(idUser, decoded);
      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Preferensi reminder dan jadwal berhasil disimpan.',
          'data': updated,
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
      print('[PROFILE] updatePreferences error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal menyimpan preferensi.',
        }),
        headers: _jsonHeaders,
      );
    }
  }
}
