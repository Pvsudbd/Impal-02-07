import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';
import '../../models/agenda/course_schedule.dart';
import '../../models/agenda/personal_schedule.dart';
import '../../models/course/course_model.dart';

class AgendaController {
  static const _uuid = Uuid();
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  // Helper untuk mengambil idUser dari context JWT (dengan fallback idStudent)
  static String? _getUserId(Request req) {
    final user =
        (req.context['user'] ?? req.context['student']) as Map<String, dynamic>?;
    return (user?['idUser'] ?? user?['idStudent']) as String?;
  }

  // ─── UNIFIED SCHEDULES (Semua Jadwal untuk Kalender / List) ───────────────────
  // GET /api/agenda
  static Future<Response> getAllSchedules(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
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
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[AGENDA] getAllSchedules error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengambil daftar jadwal.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // ─── COURSE SCHEDULE (Jadwal Kuliah Mingguan) ─────────────────────────────────

  // GET /api/agenda/course
  static Future<Response> getCourseSchedules(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final schedules = await CourseSchedule.findByUser(idUser);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'count': schedules.length,
          'data': schedules.map((s) => s.toJson()).toList(),
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[AGENDA] getCourseSchedules error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengambil jadwal kuliah.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // POST /api/agenda/course
  static Future<Response> createCourseSchedule(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

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

      final title = (decoded['title'] as String?)?.trim();
      final rawStart = (decoded['timeStart'] ?? decoded['startTime'])?.toString();
      final rawEnd = (decoded['timeEnd'] ?? decoded['endTime'])?.toString();
      final idCourse = decoded['idCourse']?.toString().trim();
      final courseName =
          (decoded['courseName'] ?? decoded['course'] ?? decoded['title'])
              ?.toString()
              .trim();
      final day = (decoded['day'] ??
              _getDayNameFromDate(decoded['date']?.toString()))
          ?.toString()
          .trim();
      final room =
          (decoded['room'] ?? decoded['location'] ?? 'Classroom').toString().trim();

      final hasCourseRef = (idCourse != null && idCourse.isNotEmpty) ||
          (courseName != null && courseName.isNotEmpty);

      if (title == null ||
          title.isEmpty ||
          rawStart == null ||
          rawEnd == null ||
          !hasCourseRef ||
          day == null ||
          day.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message':
                'Field wajib diisi: title, timeStart, timeEnd, courseName/idCourse, day, room',
          }),
          headers: _jsonHeaders,
        );
      }

      if (title.length > 150 || room.length > 50) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Panjang title maksimal 150 dan room maksimal 50 karakter.',
          }),
          headers: _jsonHeaders,
        );
      }

      final startTime = _parseAndValidateTime(rawStart);
      final endTime = _parseAndValidateTime(rawEnd);
      if (startTime == null || endTime == null) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Format waktu tidak valid. Gunakan format HH:MM (00:00 - 23:59).',
          }),
          headers: _jsonHeaders,
        );
      }

      if (!_isStartBeforeEnd(startTime, endTime)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Waktu mulai harus lebih awal dari waktu selesai.',
          }),
          headers: _jsonHeaders,
        );
      }

      final idAgenda = _uuid.v4();

      await CourseSchedule.create(
        idAgenda: idAgenda,
        idUser: idUser,
        title: title,
        startTime: startTime,
        endTime: endTime,
        idCourse: idCourse,
        courseName: courseName,
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
        headers: _jsonHeaders,
      );
    } on CourseLimitExceededException catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'status': 'error',
          'message': e.message,
        }),
        headers: _jsonHeaders,
      );
    } on CourseNotFoundException catch (e) {
      return Response(
        404,
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
      print('[AGENDA] createCourseSchedule error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal membuat jadwal kuliah.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // PUT /api/agenda/course/<idAgenda>
  static Future<Response> updateCourseSchedule(
    Request req,
    String idAgenda,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final existing = await CourseSchedule.findById(idAgenda, idUser);
      if (existing == null) {
        return Response(
          404,
          body: jsonEncode({
            'status': 'error',
            'message': 'Jadwal kuliah tidak ditemukan',
          }),
          headers: _jsonHeaders,
        );
      }

      final bodyText = await req.readAsString();
      final decoded = bodyText.isNotEmpty
          ? jsonDecode(bodyText)
          : <String, dynamic>{};
      if (decoded is! Map<String, dynamic>) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Format JSON tidak valid.',
          }),
          headers: _jsonHeaders,
        );
      }

      final title = (decoded['title'] as String?)?.trim();
      final rawStart = (decoded['timeStart'] ?? decoded['startTime'])?.toString();
      final rawEnd = (decoded['timeEnd'] ?? decoded['endTime'])?.toString();
      final idCourse = decoded['idCourse']?.toString().trim();
      final courseName =
          (decoded['courseName'] ?? decoded['course'])?.toString().trim();
      final day = decoded['day']?.toString().trim();
      final room = (decoded['room'] ?? decoded['location'])?.toString().trim();

      if ((title != null && title.length > 150) ||
          (room != null && room.length > 50)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Panjang title maksimal 150 dan room maksimal 50 karakter.',
          }),
          headers: _jsonHeaders,
        );
      }

      String? startTime;
      if (rawStart != null) {
        startTime = _parseAndValidateTime(rawStart);
        if (startTime == null) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Format waktu mulai tidak valid.',
            }),
            headers: _jsonHeaders,
          );
        }
      }

      String? endTime;
      if (rawEnd != null) {
        endTime = _parseAndValidateTime(rawEnd);
        if (endTime == null) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Format waktu selesai tidak valid.',
            }),
            headers: _jsonHeaders,
          );
        }
      }

      final effectiveStart = startTime ?? _fmtTime(existing.startTime);
      final effectiveEnd = endTime ?? _fmtTime(existing.endTime);
      if (!_isStartBeforeEnd(effectiveStart, effectiveEnd)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Waktu mulai harus lebih awal dari waktu selesai.',
          }),
          headers: _jsonHeaders,
        );
      }

      await CourseSchedule.update(
        idAgenda: idAgenda,
        idUser: idUser,
        title: title,
        startTime: startTime,
        endTime: endTime,
        idCourse: idCourse,
        courseName: courseName,
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
        headers: _jsonHeaders,
      );
    } on CourseLimitExceededException catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'status': 'error',
          'message': e.message,
        }),
        headers: _jsonHeaders,
      );
    } on CourseNotFoundException catch (e) {
      return Response(
        404,
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
      print('[AGENDA] updateCourseSchedule error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal memperbarui jadwal kuliah.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // DELETE /api/agenda/course/<idAgenda>
  static Future<Response> deleteCourseSchedule(
    Request req,
    String idAgenda,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final existing = await CourseSchedule.findById(idAgenda, idUser);
      if (existing == null) {
        return Response(
          404,
          body: jsonEncode({
            'status': 'error',
            'message': 'Jadwal kuliah tidak ditemukan',
          }),
          headers: _jsonHeaders,
        );
      }

      await CourseSchedule.delete(idAgenda, idUser);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Jadwal kuliah berhasil dihapus',
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[AGENDA] deleteCourseSchedule error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal menghapus jadwal kuliah.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // ─── PERSONAL SCHEDULE (Jadwal Kegiatan Pribadi) ─────────────────────────────

  // GET /api/agenda/personal
  static Future<Response> getPersonalSchedules(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final schedules = await PersonalSchedule.findByUser(idUser);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'count': schedules.length,
          'data': schedules.map((s) => s.toJson()).toList(),
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[AGENDA] getPersonalSchedules error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengambil jadwal personal.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // POST /api/agenda/personal
  static Future<Response> createPersonalSchedule(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

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

      final title = (decoded['title'] as String?)?.trim();
      final rawStart = (decoded['timeStart'] ?? decoded['startTime'])?.toString();
      final rawEnd = (decoded['timeEnd'] ?? decoded['endTime'])?.toString();
      final rawDate = decoded['date']?.toString().split('T')[0];
      final date = rawDate ?? _getTodayDateString();
      final rawType =
          (decoded['type'] ?? decoded['agendaType'] ?? '').toString().toLowerCase();
      var category = (decoded['category'] ?? 'Personal').toString().trim();
      if ((rawType == 'meeting' || rawType.contains('meet')) &&
          (category.isEmpty || category == 'Personal')) {
        category = 'Meeting';
      } else if (rawType == 'external' &&
          (category.isEmpty || category == 'Personal')) {
        category = 'External';
      }
      final location =
          (decoded['location'] ?? decoded['meetingUrl'] ?? '').toString().trim();
      final notes = decoded['notes']?.toString();

      if (title == null || title.isEmpty || rawStart == null || rawEnd == null) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Field wajib diisi: title, timeStart, timeEnd, date',
          }),
          headers: _jsonHeaders,
        );
      }

      if (title.length > 150 ||
          location.length > 100 ||
          category.length > 50) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message':
                'Panjang title maksimal 150, location maksimal 100, dan category maksimal 50 karakter.',
          }),
          headers: _jsonHeaders,
        );
      }

      if (DateTime.tryParse(date) == null) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Format tanggal tidak valid. Gunakan YYYY-MM-DD.',
          }),
          headers: _jsonHeaders,
        );
      }

      final startTime = _parseAndValidateTime(rawStart);
      final endTime = _parseAndValidateTime(rawEnd);
      if (startTime == null || endTime == null) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Format waktu tidak valid. Gunakan format HH:MM (00:00 - 23:59).',
          }),
          headers: _jsonHeaders,
        );
      }

      if (!_isStartBeforeEnd(startTime, endTime)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Waktu mulai harus lebih awal dari waktu selesai.',
          }),
          headers: _jsonHeaders,
        );
      }

      final idAgenda = _uuid.v4();

      await PersonalSchedule.create(
        idAgenda: idAgenda,
        idUser: idUser,
        title: title,
        startTime: startTime,
        endTime: endTime,
        date: date,
        category: category.isEmpty ? 'Personal' : category,
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
      print('[AGENDA] createPersonalSchedule error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal membuat jadwal personal.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // PUT /api/agenda/personal/<idAgenda>
  static Future<Response> updatePersonalSchedule(
    Request req,
    String idAgenda,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final existing = await PersonalSchedule.findById(idAgenda, idUser);
      if (existing == null) {
        return Response(
          404,
          body: jsonEncode({
            'status': 'error',
            'message': 'Jadwal personal tidak ditemukan',
          }),
          headers: _jsonHeaders,
        );
      }

      final bodyText = await req.readAsString();
      final decoded = bodyText.isNotEmpty
          ? jsonDecode(bodyText)
          : <String, dynamic>{};
      if (decoded is! Map<String, dynamic>) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Format JSON tidak valid.',
          }),
          headers: _jsonHeaders,
        );
      }

      final title = (decoded['title'] as String?)?.trim();
      final rawStart = (decoded['timeStart'] ?? decoded['startTime'])?.toString();
      final rawEnd = (decoded['timeEnd'] ?? decoded['endTime'])?.toString();
      final date = decoded['date']?.toString().split('T')[0];
      final category = decoded['category']?.toString().trim();
      final location =
          (decoded['location'] ?? decoded['room'] ?? decoded['meetingUrl'])
              ?.toString()
              .trim();
      final notes = decoded['notes']?.toString();

      if ((title != null && title.length > 150) ||
          (location != null && location.length > 100) ||
          (category != null && category.length > 50)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message':
                'Panjang title maksimal 150, location maksimal 100, dan category maksimal 50 karakter.',
          }),
          headers: _jsonHeaders,
        );
      }

      if (date != null && DateTime.tryParse(date) == null) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Format tanggal tidak valid. Gunakan YYYY-MM-DD.',
          }),
          headers: _jsonHeaders,
        );
      }

      String? startTime;
      if (rawStart != null) {
        startTime = _parseAndValidateTime(rawStart);
        if (startTime == null) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Format waktu mulai tidak valid.',
            }),
            headers: _jsonHeaders,
          );
        }
      }

      String? endTime;
      if (rawEnd != null) {
        endTime = _parseAndValidateTime(rawEnd);
        if (endTime == null) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Format waktu selesai tidak valid.',
            }),
            headers: _jsonHeaders,
          );
        }
      }

      final effectiveStart = startTime ?? _fmtTime(existing.startTime);
      final effectiveEnd = endTime ?? _fmtTime(existing.endTime);
      if (!_isStartBeforeEnd(effectiveStart, effectiveEnd)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Waktu mulai harus lebih awal dari waktu selesai.',
          }),
          headers: _jsonHeaders,
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
      print('[AGENDA] updatePersonalSchedule error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal memperbarui jadwal personal.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // DELETE /api/agenda/personal/<idAgenda>
  static Future<Response> deletePersonalSchedule(
    Request req,
    String idAgenda,
  ) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final existing = await PersonalSchedule.findById(idAgenda, idUser);
      if (existing == null) {
        return Response(
          404,
          body: jsonEncode({
            'status': 'error',
            'message': 'Jadwal personal tidak ditemukan',
          }),
          headers: _jsonHeaders,
        );
      }

      await PersonalSchedule.delete(idAgenda, idUser);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Jadwal personal berhasil dihapus',
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[AGENDA] deletePersonalSchedule error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal menghapus jadwal personal.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // ─── UNIFIED CREATE, UPDATE & DELETE ROUTER ──────────────────────────────────
  // POST /api/agenda (Auto-detect type 'Lecture' / 'External' dari payload)
  static Future<Response> createAgenda(Request req) async {
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

      final type =
          (decoded['type'] ?? decoded['agendaType'] ?? '').toString().toLowerCase();

      final clonedRequest = req.change(body: bodyText);
      if (type == 'lecture' || type == 'course') {
        return await createCourseSchedule(clonedRequest);
      } else {
        return await createPersonalSchedule(clonedRequest);
      }
    } on FormatException {
      return Response.badRequest(
        body: jsonEncode({
          'status': 'error',
          'message': 'Format JSON tidak valid.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // PUT /api/agenda/<idAgenda> (Cek apakah Course atau Personal, lalu perbarui)
  static Future<Response> updateAgenda(Request req, String idAgenda) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

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

      final clonedRequest = req.change(body: bodyText);

      final course = await CourseSchedule.findById(idAgenda, idUser);
      if (course != null) {
        return await updateCourseSchedule(clonedRequest, idAgenda);
      }

      final personal = await PersonalSchedule.findById(idAgenda, idUser);
      if (personal != null) {
        return await updatePersonalSchedule(clonedRequest, idAgenda);
      }

      return Response(
        404,
        body: jsonEncode({
          'status': 'error',
          'message': 'Jadwal tidak ditemukan',
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[AGENDA] updateAgenda error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal memperbarui jadwal.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // DELETE /api/agenda/<idAgenda> (Cek apakah Course atau Personal, lalu hapus)
  static Future<Response> deleteAgenda(Request req, String idAgenda) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: _jsonHeaders,
        );
      }

      final course = await CourseSchedule.findById(idAgenda, idUser);
      if (course != null) {
        await CourseSchedule.delete(idAgenda, idUser);
        return Response.ok(
          jsonEncode({
            'status': 'success',
            'message': 'Jadwal kuliah berhasil dihapus',
          }),
          headers: _jsonHeaders,
        );
      }

      final personal = await PersonalSchedule.findById(idAgenda, idUser);
      if (personal != null) {
        await PersonalSchedule.delete(idAgenda, idUser);
        return Response.ok(
          jsonEncode({
            'status': 'success',
            'message': 'Jadwal personal berhasil dihapus',
          }),
          headers: _jsonHeaders,
        );
      }

      return Response(
        404,
        body: jsonEncode({
          'status': 'error',
          'message': 'Jadwal tidak ditemukan',
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[AGENDA] deleteAgenda error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal menghapus jadwal.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // ─── UTILITY HELPERS ─────────────────────────────────────────────────────────

  static String? _parseAndValidateTime(String raw) {
    final trimmed = raw.trim();
    final match = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$').firstMatch(trimmed);
    if (match == null) return null;

    final h = int.tryParse(match.group(1)!);
    final m = int.tryParse(match.group(2)!);
    final s = match.group(3) != null ? int.tryParse(match.group(3)!) : 0;
    if (h == null || m == null || s == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59 || s < 0 || s > 59) return null;

    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static bool _isStartBeforeEnd(String start, String end) {
    int toSeconds(String t) {
      final parts = t.split(':');
      return int.parse(parts[0]) * 3600 +
          int.parse(parts[1]) * 60 +
          int.parse(parts[2]);
    }

    return toSeconds(start) < toSeconds(end);
  }

  static String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';

  static String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String _getDayNameFromDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Monday';
    try {
      final dt = DateTime.parse(rawDate);
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return days[dt.weekday - 1];
    } catch (_) {
      return 'Monday';
    }
  }
}
