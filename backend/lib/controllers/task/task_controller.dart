import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';
import '../../models/course/course_model.dart';
import '../../models/task/task.dart';

class TaskController {
  static const _uuid = Uuid();
  static const _jsonHeaders = {'Content-Type': 'application/json'};
  static const _validPriorities = {'HIGH', 'MEDIUM', 'LOW'};

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

  static List<dynamic>? _validateTags(dynamic raw) {
    if (raw == null) return null;
    if (raw is! List) return null;
    if (raw.length > 20) return null;
    final result = <dynamic>[];
    for (final item in raw) {
      if (item is String) {
        final trimmed = item.trim();
        if (trimmed.isNotEmpty) {
          if (trimmed.length > 32) return null;
          result.add(trimmed);
        }
      } else if (item is Map) {
        final label = (item['label'] ?? '').toString().trim();
        if (label.isEmpty || label.length > 32) return null;
        result.add(Map<String, dynamic>.from(item));
      } else {
        return null;
      }
    }
    return result;
  }

  // GET /api/tasks?isCompleted=&priority=&idCourse=&q=
  static Future<Response> listTasks(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final qp = req.url.queryParameters;
      bool? isCompleted;
      if (qp.containsKey('isCompleted') && qp['isCompleted']!.isNotEmpty) {
        final raw = qp['isCompleted']!.trim().toLowerCase();
        if (raw == 'true' || raw == '1') {
          isCompleted = true;
        } else if (raw == 'false' || raw == '0') {
          isCompleted = false;
        } else {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Parameter isCompleted harus true/false atau 1/0.',
            }),
            headers: _jsonHeaders,
          );
        }
      }

      final priority = qp['priority']?.trim().toUpperCase();
      if (priority != null &&
          priority.isNotEmpty &&
          !_validPriorities.contains(priority)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Parameter priority harus HIGH, MEDIUM, atau LOW.',
          }),
          headers: _jsonHeaders,
        );
      }

      final tasks = await Task.findByUser(
        idUser,
        isCompleted: isCompleted,
        priority: priority,
        idCourse: qp['idCourse'],
        query: qp['q'],
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'count': tasks.length,
          'data': tasks.map((t) => t.toJson()).toList(),
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[TASK] listTasks error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengambil daftar tugas.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // GET /api/tasks/<idTask>
  static Future<Response> getTask(Request req, String idTask) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final task = await Task.findById(idTask, idUser);
      if (task == null) {
        return Response(
          404,
          body: jsonEncode({
            'status': 'error',
            'message': 'Tugas tidak ditemukan.',
          }),
          headers: _jsonHeaders,
        );
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'data': task.toJson(),
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[TASK] getTask error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengambil detail tugas.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // POST /api/tasks
  static Future<Response> createTask(Request req) async {
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

      final rawTitle =
          (decoded['title'] ?? decoded['taskTitle'] ?? decoded['task_title'])
              ?.toString()
              .trim();
      if (rawTitle == null || rawTitle.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Field wajib diisi: title dan deadline.',
          }),
          headers: _jsonHeaders,
        );
      }
      if (rawTitle.length > 150) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Panjang title maksimal 150 karakter.',
          }),
          headers: _jsonHeaders,
        );
      }

      final rawDeadline = decoded['deadline']?.toString().trim();
      final deadline =
          rawDeadline != null ? DateTime.tryParse(rawDeadline) : null;
      if (deadline == null) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Field deadline wajib diisi dengan format tanggal ISO8601 yang valid.',
          }),
          headers: _jsonHeaders,
        );
      }

      var gradeWeight = 20.0;
      final rawWeight = decoded['gradeWeight'] ?? decoded['grade_weight'];
      if (rawWeight != null) {
        final parsed = rawWeight is num
            ? rawWeight.toDouble()
            : double.tryParse(rawWeight.toString());
        if (parsed == null || parsed < 0 || parsed > 100) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Field gradeWeight harus bernilai antara 0 sampai 100.',
            }),
            headers: _jsonHeaders,
          );
        }
        gradeWeight = parsed;
      }

      final rawAuto = decoded['isFuzzyAuto'] ?? decoded['is_fuzzy_auto'];
      final isFuzzyAuto = rawAuto == null
          ? true
          : (rawAuto == true || rawAuto == 1 || rawAuto == 'true');

      final rawPriority = decoded['priority']?.toString().trim().toUpperCase();
      if (!isFuzzyAuto &&
          rawPriority != null &&
          rawPriority.isNotEmpty &&
          !_validPriorities.contains(rawPriority)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Field priority harus HIGH, MEDIUM, atau LOW.',
          }),
          headers: _jsonHeaders,
        );
      }

      var tags = const <dynamic>[];
      if (decoded.containsKey('tags') && decoded['tags'] != null) {
        final parsedTags = _validateTags(decoded['tags']);
        if (parsedTags == null) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message':
                  'Field tags harus berupa list tag string/objek (maksimal 20 tag).',
            }),
            headers: _jsonHeaders,
          );
        }
        tags = parsedTags;
      }

      final rawIdTask = (decoded['idTask'] ?? decoded['id_task'])?.toString().trim();
      final idTask = (rawIdTask != null &&
              rawIdTask.isNotEmpty &&
              rawIdTask.length <= 36)
          ? rawIdTask
          : _uuid.v4();

      final created = await Task.create(
        idTask: idTask,
        idUser: idUser,
        idCourse: (decoded['idCourse'] ?? decoded['id_course'])?.toString(),
        courseName: (decoded['courseName'] ??
                decoded['course_name'] ??
                decoded['course'] ??
                decoded['courseCode'] ??
                decoded['course_code'])
            ?.toString(),
        taskTitle: rawTitle,
        description: (decoded['description'] ?? decoded['notes'] ?? '').toString(),
        deadline: deadline,
        gradeWeight: gradeWeight,
        isFuzzyAuto: isFuzzyAuto,
        manualPriority: rawPriority,
        manualPriorityScore:
            ((decoded['priorityScore'] ?? decoded['priority_score']) as num?)
                ?.toDouble(),
        tags: tags,
      );

      return Response(
        201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Tugas berhasil dibuat.',
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
        body: jsonEncode({'status': 'error', 'message': e.message}),
        headers: _jsonHeaders,
      );
    } on CourseNotFoundException catch (e) {
      return Response(
        404,
        body: jsonEncode({'status': 'error', 'message': e.message}),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[TASK] createTask error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal membuat tugas.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // PUT /api/tasks/<idTask>
  static Future<Response> updateTask(Request req, String idTask) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final existing = await Task.findById(idTask, idUser);
      if (existing == null) {
        return Response(
          404,
          body: jsonEncode({
            'status': 'error',
            'message': 'Tugas tidak ditemukan.',
          }),
          headers: _jsonHeaders,
        );
      }

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

      String? title;
      if (decoded.containsKey('title') ||
          decoded.containsKey('taskTitle') ||
          decoded.containsKey('task_title')) {
        title =
            (decoded['title'] ?? decoded['taskTitle'] ?? decoded['task_title'])
                ?.toString()
                .trim();
        if (title == null || title.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Field title tidak boleh kosong.',
            }),
            headers: _jsonHeaders,
          );
        }
        if (title.length > 150) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Panjang title maksimal 150 karakter.',
            }),
            headers: _jsonHeaders,
          );
        }
      }

      DateTime? deadline;
      if (decoded.containsKey('deadline') && decoded['deadline'] != null) {
        deadline = DateTime.tryParse(decoded['deadline'].toString().trim());
        if (deadline == null) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Format tanggal deadline tidak valid.',
            }),
            headers: _jsonHeaders,
          );
        }
      }

      double? gradeWeight;
      if (decoded.containsKey('gradeWeight') ||
          decoded.containsKey('grade_weight')) {
        final rawWeight = decoded['gradeWeight'] ?? decoded['grade_weight'];
        final parsed = rawWeight is num
            ? rawWeight.toDouble()
            : double.tryParse(rawWeight?.toString() ?? '');
        if (parsed == null || parsed < 0 || parsed > 100) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message': 'Field gradeWeight harus bernilai antara 0 sampai 100.',
            }),
            headers: _jsonHeaders,
          );
        }
        gradeWeight = parsed;
      }

      bool? isFuzzyAuto;
      if (decoded.containsKey('isFuzzyAuto') ||
          decoded.containsKey('is_fuzzy_auto')) {
        final rawAuto = decoded['isFuzzyAuto'] ?? decoded['is_fuzzy_auto'];
        isFuzzyAuto = rawAuto == true || rawAuto == 1 || rawAuto == 'true';
      }

      bool? isCompleted;
      if (decoded.containsKey('isCompleted') ||
          decoded.containsKey('is_completed')) {
        final rawComp = decoded['isCompleted'] ?? decoded['is_completed'];
        isCompleted = rawComp == true || rawComp == 1 || rawComp == 'true';
      }

      final rawPriority = decoded['priority']?.toString().trim().toUpperCase();
      if (rawPriority != null &&
          rawPriority.isNotEmpty &&
          !_validPriorities.contains(rawPriority)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Field priority harus HIGH, MEDIUM, atau LOW.',
          }),
          headers: _jsonHeaders,
        );
      }

      List<dynamic>? tags;
      if (decoded.containsKey('tags')) {
        tags = _validateTags(decoded['tags']);
        if (tags == null) {
          return Response.badRequest(
            body: jsonEncode({
              'status': 'error',
              'message':
                  'Field tags harus berupa list tag string/objek (maksimal 20 tag).',
            }),
            headers: _jsonHeaders,
          );
        }
      }

      final updated = await Task.update(
        idTask: idTask,
        idUser: idUser,
        idCourse: (decoded['idCourse'] ?? decoded['id_course'])?.toString(),
        courseName: (decoded['courseName'] ??
                decoded['course_name'] ??
                decoded['course'] ??
                decoded['courseCode'] ??
                decoded['course_code'])
            ?.toString(),
        clearCourse: decoded['clearCourse'] == true,
        taskTitle: title,
        description: (decoded['description'] ?? decoded['notes'])?.toString(),
        deadline: deadline,
        gradeWeight: gradeWeight,
        isFuzzyAuto: isFuzzyAuto,
        manualPriority: rawPriority,
        manualPriorityScore:
            ((decoded['priorityScore'] ?? decoded['priority_score']) as num?)
                ?.toDouble(),
        isCompleted: isCompleted,
        tags: tags,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Tugas berhasil diperbarui.',
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
    } on CourseLimitExceededException catch (e) {
      return Response.badRequest(
        body: jsonEncode({'status': 'error', 'message': e.message}),
        headers: _jsonHeaders,
      );
    } on CourseNotFoundException catch (e) {
      return Response(
        404,
        body: jsonEncode({'status': 'error', 'message': e.message}),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[TASK] updateTask error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal memperbarui tugas.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // PATCH /api/tasks/<idTask>/complete
  static Future<Response> toggleComplete(Request req, String idTask) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final existing = await Task.findById(idTask, idUser);
      if (existing == null) {
        return Response(
          404,
          body: jsonEncode({
            'status': 'error',
            'message': 'Tugas tidak ditemukan.',
          }),
          headers: _jsonHeaders,
        );
      }

      var nextCompleted = !existing.isCompleted;
      final bodyText = await req.readAsString();
      if (bodyText.trim().isNotEmpty) {
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
        if (decoded.containsKey('isCompleted') ||
            decoded.containsKey('is_completed')) {
          final raw = decoded['isCompleted'] ?? decoded['is_completed'];
          nextCompleted = raw == true || raw == 1 || raw == 'true';
        }
      }

      final updated = await Task.setCompleted(idTask, idUser, nextCompleted);
      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': nextCompleted
              ? 'Tugas ditandai selesai.'
              : 'Tugas dibuka kembali.',
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
      print('[TASK] toggleComplete error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengubah status tugas.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // DELETE /api/tasks/<idTask>
  static Future<Response> deleteTask(Request req, String idTask) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final deleted = await Task.delete(idTask, idUser);
      if (!deleted) {
        return Response(
          404,
          body: jsonEncode({
            'status': 'error',
            'message': 'Tugas tidak ditemukan.',
          }),
          headers: _jsonHeaders,
        );
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Tugas berhasil dihapus.',
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[TASK] deleteTask error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal menghapus tugas.',
        }),
        headers: _jsonHeaders,
      );
    }
  }
}
