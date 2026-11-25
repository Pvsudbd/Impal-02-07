import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../models/course/course_model.dart';

class CourseController {
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  static String? _getUserId(Request req) {
    final user =
        (req.context['user'] ?? req.context['student']) as Map<String, dynamic>?;
    return (user?['idUser'] ?? user?['idStudent']) as String?;
  }

  static Response _unauthorized() {
    return Response(
      401,
      body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
      headers: _jsonHeaders,
    );
  }

  // GET /api/courses?q=&scope=mine|global|all
  static Future<Response> listCourses(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final query = req.url.queryParameters['q'];
      final scope = req.url.queryParameters['scope'];

      final courses = await CourseModel.findAllForUser(
        idUser,
        query: query,
        scope: scope,
      );
      final customCount = await CourseModel.countCustomByUser(idUser);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'count': courses.length,
          'customCount': customCount,
          'maxCustomCourses': CourseModel.maxCustomCoursesPerUser,
          'data': courses.map((c) => c.toJson()).toList(),
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[COURSE] listCourses error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengambil daftar mata kuliah.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // POST /api/courses
  static Future<Response> createCourse(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final bodyText = await req.readAsString();
      if (bodyText.isEmpty) {
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

      final rawName = decoded['courseName'] ?? decoded['course'];
      final courseName = rawName?.toString().trim() ?? '';
      if (courseName.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Field courseName wajib diisi.',
          }),
          headers: _jsonHeaders,
        );
      }
      if (courseName.length > 100) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Panjang courseName maksimal 100 karakter.',
          }),
          headers: _jsonHeaders,
        );
      }

      var credits = 3;
      if (decoded.containsKey('credits') && decoded['credits'] != null) {
        final rawCredits = decoded['credits'];
        final parsed = rawCredits is num
            ? rawCredits.toInt()
            : int.tryParse(rawCredits.toString());
        if (parsed == null || parsed < 1 || parsed > 12) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Field credits harus berupa angka antara 1 sampai 12.',
            }),
            headers: _jsonHeaders,
          );
        }
        credits = parsed;
      }

      final created = await CourseModel.createCustom(
        idUser: idUser,
        courseName: courseName,
        credits: credits,
      );

      return Response(
        201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Mata kuliah kustom berhasil ditambahkan.',
          'data': created.toJson(),
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
    } on CourseLimitExceededException catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'status': 'error',
          'message': e.message,
        }),
        headers: _jsonHeaders,
      );
    } on DuplicateCourseException catch (e) {
      return Response(
        409,
        body: jsonEncode({
          'status': 'error',
          'message': e.message,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[COURSE] createCourse error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal menambahkan mata kuliah.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // PUT /api/courses/<idCourse>
  static Future<Response> updateCourse(Request req, String idCourse) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final bodyText = await req.readAsString();
      if (bodyText.isEmpty) {
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

      String? courseName;
      if (decoded.containsKey('courseName') || decoded.containsKey('course')) {
        final rawName = decoded['courseName'] ?? decoded['course'];
        courseName = rawName?.toString().trim() ?? '';
        if (courseName.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Field courseName tidak boleh kosong.',
            }),
            headers: _jsonHeaders,
          );
        }
        if (courseName.length > 100) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Panjang courseName maksimal 100 karakter.',
            }),
            headers: _jsonHeaders,
          );
        }
      }

      int? credits;
      if (decoded.containsKey('credits') && decoded['credits'] != null) {
        final rawCredits = decoded['credits'];
        final parsed = rawCredits is num
            ? rawCredits.toInt()
            : int.tryParse(rawCredits.toString());
        if (parsed == null || parsed < 1 || parsed > 12) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Field credits harus berupa angka antara 1 sampai 12.',
            }),
            headers: _jsonHeaders,
          );
        }
        credits = parsed;
      }

      final updated = await CourseModel.updateCustom(
        idCourse: idCourse,
        idUser: idUser,
        courseName: courseName,
        credits: credits,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Mata kuliah kustom berhasil diperbarui.',
          'data': updated.toJson(),
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
    } on CourseNotFoundException catch (e) {
      return Response(
        404,
        body: jsonEncode({
          'status': 'error',
          'message': e.message,
        }),
        headers: _jsonHeaders,
      );
    } on DuplicateCourseException catch (e) {
      return Response(
        409,
        body: jsonEncode({
          'status': 'error',
          'message': e.message,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[COURSE] updateCourse error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal memperbarui mata kuliah.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // DELETE /api/courses/<idCourse>
  static Future<Response> deleteCourse(Request req, String idCourse) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      await CourseModel.deleteCustom(
        idCourse: idCourse,
        idUser: idUser,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Mata kuliah kustom berhasil dihapus.',
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
    } on CourseInUseException catch (e) {
      return Response(
        409,
        body: jsonEncode({
          'status': 'error',
          'message': e.message,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[COURSE] deleteCourse error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal menghapus mata kuliah.',
        }),
        headers: _jsonHeaders,
      );
    }
  }
}
