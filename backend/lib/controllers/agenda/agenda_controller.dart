import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';
import '../../models/agenda/course_schedule.dart';
import '../../models/agenda/personal_schedule.dart';

class AgendaController {
  static const _uuid = Uuid();

  // Helper untuk mengambil idUser dari context JWT (dengan fallback idStudent)
  static String? _getUserId(Request req) {
    final user = (req.context['user'] ?? req.context['student']) as Map<String, dynamic>?;
    return (user?['idUser'] ?? user?['idStudent']) as String?;
  }

  // ─── UNIFIED SCHEDULES (Semua Jadwal untuk Kalender / List) ───────────────────
  // GET /api/agenda
  static Future<Response> getAllSchedules(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final courses = await CourseSchedule.findByUser(idUser);
      final personals = await PersonalSchedule.findByUser(idUser);

      final combined = [
        ...courses.map((c) => c.toJson()),
        ...personals.map((p) => p.toJson()),
      ];

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'count': combined.length,
          'data': combined,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[AGENDA] getAllSchedules error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── COURSE SCHEDULE (Jadwal Kuliah Mingguan) ─────────────────────────────────

  // GET /api/agenda/course
  static Future<Response> getCourseSchedules(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final schedules = await CourseSchedule.findByUser(idUser);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'count': schedules.length,
          'data': schedules.map((s) => s.toJson()).toList(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[AGENDA] getCourseSchedules error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/agenda/course
  static Future<Response> createCourseSchedule(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final bodyText = await req.readAsString();
      if (bodyText.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Request body tidak boleh kosong'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = jsonDecode(bodyText) as Map<String, dynamic>;
      final title = body['title'] as String?;
      final startTime = (body['timeStart'] ?? body['startTime']) as String?;
      final endTime = (body['timeEnd'] ?? body['endTime']) as String?;
      final courseCode = (body['courseCode'] ?? body['course'] ?? body['title']) as String?;
      final day = (body['day'] ?? _getDayNameFromDate(body['date']?.toString())) as String?;
      final room = (body['room'] ?? body['location'] ?? 'Classroom').toString();

      if (title == null || startTime == null || endTime == null || courseCode == null || day == null) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Field wajib diisi: title, timeStart, timeEnd, courseCode, day, room'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (!_isValidTimeRange(startTime, endTime)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Jam selesai ($endTime) harus lebih besar dari jam mulai ($startTime).',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final idAgenda = _uuid.v4();

      await CourseSchedule.create(
        idAgenda: idAgenda,
        idUser: idUser,
        title: title,
        startTime: _normalizeTime(startTime),
        endTime: _normalizeTime(endTime),
        courseCode: courseCode,
        day: day,
        room: room,
      );

      final created = await CourseSchedule.findById(idAgenda, idUser);

      return Response(
        201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Jadwal kuliah berhasil dibuat',
          'data': created?.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[AGENDA] createCourseSchedule error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // PUT /api/agenda/course/<idAgenda>
  static Future<Response> updateCourseSchedule(Request req, String idAgenda) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final existing = await CourseSchedule.findById(idAgenda, idUser);
      if (existing == null) {
        return Response(404,
            body: jsonEncode({'status': 'error', 'message': 'Jadwal kuliah tidak ditemukan'}),
            headers: {'Content-Type': 'application/json'});
      }

      final bodyText = await req.readAsString();
      final body = bodyText.isNotEmpty ? jsonDecode(bodyText) as Map<String, dynamic> : <String, dynamic>{};

      final title = body['title'] as String?;
      final startTime = body['timeStart'] != null ? _normalizeTime(body['timeStart'] as String) : null;
      final endTime = body['timeEnd'] != null ? _normalizeTime(body['timeEnd'] as String) : null;
      final courseCode = (body['courseCode'] ?? body['course']) as String?;
      final day = body['day'] as String?;
      final room = (body['room'] ?? body['location']) as String?;

      final effectiveStart = startTime ?? existing.startTime;
      final effectiveEnd = endTime ?? existing.endTime;
      if (!_isValidTimeRange(effectiveStart, effectiveEnd)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Jam selesai ($effectiveEnd) harus lebih besar dari jam mulai ($effectiveStart).',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      await CourseSchedule.update(
        idAgenda: idAgenda,
        idUser: idUser,
        title: title,
        startTime: startTime,
        endTime: endTime,
        courseCode: courseCode,
        day: day,
        room: room,
      );

      final updated = await CourseSchedule.findById(idAgenda, idUser);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Jadwal kuliah berhasil diperbarui',
          'data': updated?.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[AGENDA] updateCourseSchedule error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // DELETE /api/agenda/course/<idAgenda>
  static Future<Response> deleteCourseSchedule(Request req, String idAgenda) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final existing = await CourseSchedule.findById(idAgenda, idUser);
      if (existing == null) {
        return Response(404,
            body: jsonEncode({'status': 'error', 'message': 'Jadwal kuliah tidak ditemukan'}),
            headers: {'Content-Type': 'application/json'});
      }

      await CourseSchedule.delete(idAgenda, idUser);

      return Response.ok(
        jsonEncode({'status': 'success', 'message': 'Jadwal kuliah berhasil dihapus'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[AGENDA] deleteCourseSchedule error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── PERSONAL SCHEDULE (Jadwal Kegiatan Pribadi) ─────────────────────────────

  // GET /api/agenda/personal
  static Future<Response> getPersonalSchedules(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final schedules = await PersonalSchedule.findByUser(idUser);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'count': schedules.length,
          'data': schedules.map((s) => s.toJson()).toList(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[AGENDA] getPersonalSchedules error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/agenda/personal
  static Future<Response> createPersonalSchedule(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final bodyText = await req.readAsString();
      if (bodyText.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Request body tidak boleh kosong'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = jsonDecode(bodyText) as Map<String, dynamic>;
      final title = body['title'] as String?;
      final startTime = (body['timeStart'] ?? body['startTime']) as String?;
      final endTime = (body['timeEnd'] ?? body['endTime']) as String?;
      final date = (body['date']?.toString().split('T')[0]) ?? _getTodayDateString();
      final rawType = (body['type'] ?? body['agendaType'] ?? '').toString().toLowerCase();
      var category = (body['category'] ?? 'Personal') as String?;
      if ((rawType == 'meeting' || rawType.contains('meet')) && (category == null || category == 'Personal')) {
        category = 'Meeting';
      } else if (rawType == 'external' && (category == null || category == 'Personal')) {
        category = 'External';
      }
      final location = (body['location'] ?? body['meetingUrl'] ?? '') as String?;
      final notes = body['notes'] as String?;

      if (title == null || startTime == null || endTime == null) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Field wajib diisi: title, timeStart, timeEnd, date'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (!_isValidTimeRange(startTime, endTime)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Jam selesai ($endTime) harus lebih besar dari jam mulai ($startTime).',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final idAgenda = _uuid.v4();

      await PersonalSchedule.create(
        idAgenda: idAgenda,
        idUser: idUser,
        title: title,
        startTime: _normalizeTime(startTime),
        endTime: _normalizeTime(endTime),
        date: date,
        category: category ?? 'Personal',
        location: location,
        notes: notes,
      );

      final created = await PersonalSchedule.findById(idAgenda, idUser);

      return Response(
        201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Jadwal personal berhasil dibuat',
          'data': created?.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[AGENDA] createPersonalSchedule error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // PUT /api/agenda/personal/<idAgenda>
  static Future<Response> updatePersonalSchedule(Request req, String idAgenda) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final existing = await PersonalSchedule.findById(idAgenda, idUser);
      if (existing == null) {
        return Response(404,
            body: jsonEncode({'status': 'error', 'message': 'Jadwal personal tidak ditemukan'}),
            headers: {'Content-Type': 'application/json'});
      }

      final bodyText = await req.readAsString();
      final body = bodyText.isNotEmpty ? jsonDecode(bodyText) as Map<String, dynamic> : <String, dynamic>{};

      final title = body['title'] as String?;
      final startTime = body['timeStart'] != null ? _normalizeTime(body['timeStart'] as String) : null;
      final endTime = body['timeEnd'] != null ? _normalizeTime(body['timeEnd'] as String) : null;
      final date = body['date']?.toString().split('T')[0];
      final category = body['category'] as String?;
      final location = (body['location'] ?? body['room']) as String?;
      final notes = body['notes'] as String?;

      final effectiveStart = startTime ?? existing.startTime;
      final effectiveEnd = endTime ?? existing.endTime;
      if (!_isValidTimeRange(effectiveStart, effectiveEnd)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Jam selesai ($effectiveEnd) harus lebih besar dari jam mulai ($effectiveStart).',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      await PersonalSchedule.update(
        idAgenda: idAgenda,
        idUser: idUser,
        title: title,
        startTime: startTime,
        endTime: endTime,
        date: date,
        category: category,
        location: location,
        notes: notes,
      );

      final updated = await PersonalSchedule.findById(idAgenda, idUser);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Jadwal personal berhasil diperbarui',
          'data': updated?.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[AGENDA] updatePersonalSchedule error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // DELETE /api/agenda/personal/<idAgenda>
  static Future<Response> deletePersonalSchedule(Request req, String idAgenda) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final existing = await PersonalSchedule.findById(idAgenda, idUser);
      if (existing == null) {
        return Response(404,
            body: jsonEncode({'status': 'error', 'message': 'Jadwal personal tidak ditemukan'}),
            headers: {'Content-Type': 'application/json'});
      }

      await PersonalSchedule.delete(idAgenda, idUser);

      return Response.ok(
        jsonEncode({'status': 'success', 'message': 'Jadwal personal berhasil dihapus'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[AGENDA] deletePersonalSchedule error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── UNIFIED CREATE, UPDATE & DELETE ROUTER ──────────────────────────────────
  // POST /api/agenda (Auto-detect type 'Lecture' / 'External' dari payload)
  static Future<Response> createAgenda(Request req) async {
    final bodyText = await req.readAsString();
    if (bodyText.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'status': 'error', 'message': 'Request body tidak boleh kosong'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final body = jsonDecode(bodyText) as Map<String, dynamic>;
    final type = (body['type'] ?? body['agendaType'] ?? '').toString().toLowerCase();

    final clonedRequest = req.change(body: bodyText);
    if (type == 'lecture' || type == 'course') {
      return createCourseSchedule(clonedRequest);
    } else {
      return createPersonalSchedule(clonedRequest);
    }
  }

  // PUT /api/agenda/<idAgenda> (Cek apakah Course atau Personal, lalu perbarui)
  static Future<Response> updateAgenda(Request req, String idAgenda) async {
    final idUser = _getUserId(req);
    if (idUser == null) {
      return Response(401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: {'Content-Type': 'application/json'});
    }

    final bodyText = await req.readAsString();
    if (bodyText.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'status': 'error', 'message': 'Request body tidak boleh kosong'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final clonedRequest = req.change(body: bodyText);

    final course = await CourseSchedule.findById(idAgenda, idUser);
    if (course != null) {
      return updateCourseSchedule(clonedRequest, idAgenda);
    }

    final personal = await PersonalSchedule.findById(idAgenda, idUser);
    if (personal != null) {
      return updatePersonalSchedule(clonedRequest, idAgenda);
    }

    return Response(404,
        body: jsonEncode({'status': 'error', 'message': 'Jadwal tidak ditemukan'}),
        headers: {'Content-Type': 'application/json'});
  }

  // DELETE /api/agenda/<idAgenda> (Cek apakah Course atau Personal, lalu hapus)
  static Future<Response> deleteAgenda(Request req, String idAgenda) async {
    final idUser = _getUserId(req);
    if (idUser == null) {
      return Response(401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: {'Content-Type': 'application/json'});
    }

    // Coba hapus dari course
    final course = await CourseSchedule.findById(idAgenda, idUser);
    if (course != null) {
      await CourseSchedule.delete(idAgenda, idUser);
      return Response.ok(
        jsonEncode({'status': 'success', 'message': 'Jadwal kuliah berhasil dihapus'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    // Coba hapus dari personal
    final personal = await PersonalSchedule.findById(idAgenda, idUser);
    if (personal != null) {
      await PersonalSchedule.delete(idAgenda, idUser);
      return Response.ok(
        jsonEncode({'status': 'success', 'message': 'Jadwal personal berhasil dihapus'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response(404,
        body: jsonEncode({'status': 'error', 'message': 'Jadwal tidak ditemukan'}),
        headers: {'Content-Type': 'application/json'});
  }

  // ─── UTILITY HELPERS ─────────────────────────────────────────────────────────

  // Validasi apakah waktu selesai strictly lebih besar dari waktu mulai
  static bool _isValidTimeRange(dynamic startTime, dynamic endTime) {
    if (startTime == null || endTime == null) return true;
    int? toMinutes(dynamic t) {
      final clean = t.toString().trim();
      final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(clean);
      if (match != null) {
        final h = int.parse(match.group(1)!);
        final m = int.parse(match.group(2)!);
        return h * 60 + m;
      }
      return null;
    }

    final start = toMinutes(startTime);
    final end = toMinutes(endTime);
    if (start != null && end != null) {
      return end > start;
    }
    return true;
  }

  // Pastikan format TIME MySQL adalah "HH:MM:SS"
  static String _normalizeTime(String timeStr) {
    final trimmed = timeStr.trim();
    final parts = trimmed.split(':');
    final h = parts[0].padLeft(2, '0');
    final m = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
    final s = parts.length > 2 ? parts[2].padLeft(2, '0') : '00';
    return '$h:$m:$s';
  }

  static String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String _getDayNameFromDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Monday';
    try {
      final dt = DateTime.parse(rawDate);
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[dt.weekday - 1];
    } catch (_) {
      return 'Monday';
    }
  }
}
