import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import '../../config/db.dart';
import '../../models/task/task.dart';

/// Controller untuk mengelola Tugas Akademik & Pribadi (Tabel task).
///
/// Mematuhi spesifikasi PostgreSQL 15+ 3NF dan batasan UUID 36-karakter.
class TaskController {
  static const _uuid = Uuid();

  // Helper mengambil idUser dari token JWT yang telah diverifikasi middleware
  static String? _getUserId(Request req) {
    final user = (req.context['user'] ?? req.context['student']) as Map<String, dynamic>?;
    return (user?['idUser'] ??
            user?['idStudent'] ??
            user?['id_user'] ??
            user?['id_student'] ??
            user?['id'] ??
            user?['sub']) as String?;
  }

  // ─── 1. AMBIL SEMUA TUGAS MILIK PENGGUNA ──────────────────────────────────
  // GET /api/task
  static Future<Response> getTasks(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      QueryResult results;
      try {
        results = await Database.query('''
          SELECT t.*, c.course_name
          FROM task t
          LEFT JOIN course c ON t.course_code = c.course_code
          WHERE t.id_student = @idUser
          ORDER BY t.is_completed ASC, t.deadline ASC
        ''', {'idUser': idUser});
      } catch (e) {
        if (e.toString().contains('id_student')) {
          results = await Database.query('''
            SELECT t.*, c.course_name
            FROM task t
            LEFT JOIN course c ON t.course_code = c.course_code
            WHERE t.id_user = @idUser
            ORDER BY t.is_completed ASC, t.deadline ASC
          ''', {'idUser': idUser});
        } else {
          rethrow;
        }
      }

      final tasks = results.rows.map((r) {
        final row = r.assoc();
        return Task.fromJson(row).toJson();
      }).toList();

      print('[TASK] getTasks: fetched ${tasks.length} tasks for user $idUser');

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'count': tasks.length,
          'data': tasks,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[TASK] getTasks error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── 2. AMBIL DETAIL TUGAS BERDASARKAN ID ─────────────────────────────────
  // GET /api/task/<idTask>
  static Future<Response> getTaskById(Request req, String idTask) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      QueryResult results;
      try {
        results = await Database.query('''
          SELECT t.*, c.course_name
          FROM task t
          LEFT JOIN course c ON t.course_code = c.course_code
          WHERE t.id_task = @idTask AND t.id_student = @idUser
          LIMIT 1
        ''', {'idTask': idTask, 'idUser': idUser});
      } catch (e) {
        if (e.toString().contains('id_student')) {
          results = await Database.query('''
            SELECT t.*, c.course_name
            FROM task t
            LEFT JOIN course c ON t.course_code = c.course_code
            WHERE t.id_task = @idTask AND t.id_user = @idUser
            LIMIT 1
          ''', {'idTask': idTask, 'idUser': idUser});
        } else {
          rethrow;
        }
      }

      if (results.rows.isEmpty) {
        return Response(404,
            body: jsonEncode({'status': 'error', 'message': 'Task not found'}),
            headers: {'Content-Type': 'application/json'});
      }

      final task = Task.fromJson(results.rows.first.assoc());
      return Response.ok(
        jsonEncode({
          'status': 'success',
          'data': task.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[TASK] getTaskById error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── 3. MEMBUAT TUGAS BARU ───────────────────────────────────────────────
  // POST /api/task
  static Future<Response> createTask(Request req) async {
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
          body: jsonEncode({'status': 'error', 'message': 'Request body cannot be empty'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = jsonDecode(bodyText) as Map<String, dynamic>;
      final taskTitle = (body['task_title'] ?? body['title'])?.toString().trim();
      if (taskTitle == null || taskTitle.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Task title is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final rawDeadline = body['deadline'];
      DateTime deadline;
      if (rawDeadline == null) {
        deadline = DateTime.now().add(const Duration(days: 1));
      } else if (rawDeadline is DateTime) {
        deadline = rawDeadline;
      } else {
        deadline = DateTime.tryParse(rawDeadline.toString()) ?? DateTime.now().add(const Duration(days: 1));
      }

      final description = (body['description'] ?? body['notes'] ?? '').toString().trim();
      final gradeWeight = (body['grade_weight'] as num?)?.toDouble() ?? 0.0;
      final priorityScore = (body['priority_score'] as num?)?.toDouble() ?? 0.0;
      final rawPriority = (body['priority'] ?? 'MEDIUM').toString().toUpperCase();
      final priority = ['HIGH', 'MEDIUM', 'LOW'].contains(rawPriority) ? rawPriority : 'MEDIUM';
      final isFuzzyAuto = body['is_fuzzy_auto'] != false && body['is_fuzzy_auto'] != 0;
      final isCompleted = body['is_completed'] == true || body['is_completed'] == 1;

      // Sanitasi & normalisasi course_code & course_name
      String rawCourse = (body['course_code'] ?? body['course'] ?? '').toString().trim();
      String courseCode;
      String courseName;

      if (rawCourse.isEmpty) {
        courseCode = 'GEN-DEFAULT';
        courseName = 'General Task';
      } else if (rawCourse.contains('•')) {
        courseCode = rawCourse.split('•').first.trim();
        courseName = rawCourse.split('•').last.trim();
      } else if (rawCourse.length > 20) {
        courseCode = rawCourse.substring(0, 20).trim();
        courseName = rawCourse;
      } else {
        courseCode = rawCourse;
        courseName = rawCourse;
      }

      if (courseCode.length > 20) {
        courseCode = courseCode.substring(0, 20);
      }
      if (courseName.length > 100) {
        courseName = courseName.substring(0, 100);
      }

      // Pastikan courseCode ada di tabel course (menghindari error FK fk_task_course)
      try {
        final existingCourse = await Database.query(
          'SELECT course_code FROM course WHERE course_code = @courseCode LIMIT 1',
          {'courseCode': courseCode},
        );
        if (existingCourse.rows.isEmpty) {
          try {
            await Database.query(
              '''
              INSERT INTO course (course_code, course_name, credits, lecturer)
              VALUES (@courseCode, @courseName, 3, 'General')
              ''',
              {'courseCode': courseCode, 'courseName': courseName},
            );
          } catch (e1) {
            try {
              await Database.query(
                '''
                INSERT INTO course (course_code, course_name, credits, lecturer, created_at)
                VALUES (@courseCode, @courseName, 3, 'General', CURRENT_TIMESTAMP)
                ''',
                {'courseCode': courseCode, 'courseName': courseName},
              );
            } catch (_) {}
          }
        }
      } catch (e) {
        print('[TASK] Course check error: $e');
      }

      // Generate pure UUID v4 (36 chars, mematuhi Section 8A AGENTS.md)
      final idTask = _uuid.v4();
      final deadlineStr = deadline.toIso8601String();
      final isFuzzyAutoInt = isFuzzyAuto ? 1 : 0;
      final isCompletedInt = isCompleted ? 1 : 0;

      try {
        await Database.query('''
          INSERT INTO task (
            id_task, id_student, course_code, task_title, description,
            deadline, grade_weight, priority_score, priority,
            is_fuzzy_auto, is_completed, created_at, updated_at
          ) VALUES (
            @idTask, @idUser, @courseCode, @taskTitle, @description,
            @deadline::timestamp, @gradeWeight, @priorityScore, @priority,
            @isFuzzyAuto, @isCompleted, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
          )
        ''', {
          'idTask': idTask,
          'idUser': idUser,
          'courseCode': courseCode,
          'taskTitle': taskTitle,
          'description': description,
          'deadline': deadlineStr,
          'gradeWeight': gradeWeight,
          'priorityScore': priorityScore,
          'priority': priority,
          'isFuzzyAuto': isFuzzyAutoInt,
          'isCompleted': isCompletedInt,
        });
      } catch (e) {
        print('[TASK] Primary insert (id_student) error: $e. Retrying with id_user fallback...');
        if (e.toString().contains('id_student')) {
          await Database.query('''
            INSERT INTO task (
              id_task, id_user, course_code, task_title, description,
              deadline, grade_weight, priority_score, priority,
              is_fuzzy_auto, is_completed, created_at, updated_at
            ) VALUES (
              @idTask, @idUser, @courseCode, @taskTitle, @description,
              @deadline::timestamp, @gradeWeight, @priorityScore, @priority,
              @isFuzzyAuto, @isCompleted, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            )
          ''', {
            'idTask': idTask,
            'idUser': idUser,
            'courseCode': courseCode,
            'taskTitle': taskTitle,
            'description': description,
            'deadline': deadlineStr,
            'gradeWeight': gradeWeight,
            'priorityScore': priorityScore,
            'priority': priority,
            'isFuzzyAuto': isFuzzyAutoInt,
            'isCompleted': isCompletedInt,
          });
        } else {
          rethrow;
        }
      }

      final createdTask = Task(
        taskId: idTask,
        userId: idUser,
        courseCode: courseCode,
        taskTitle: taskTitle,
        description: description,
        deadline: deadline,
        gradeWeight: gradeWeight,
        priorityScore: priorityScore,
        priority: priority,
        isFuzzyAuto: isFuzzyAuto,
        isCompleted: isCompleted,
      );

      print('[TASK] Task created successfully in DB: $idTask ("$taskTitle") for user: $idUser');

      return Response(
        201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Task created successfully',
          'data': createdTask.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[TASK] createTask error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── 4. PERBARUI TUGAS (UPDATE) ───────────────────────────────────────────
  // PUT /api/task/<idTask>
  static Future<Response> updateTask(Request req, String idTask) async {
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
          body: jsonEncode({'status': 'error', 'message': 'Request body cannot be empty'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = jsonDecode(bodyText) as Map<String, dynamic>;
      final taskTitle = (body['task_title'] ?? body['title'])?.toString().trim();
      final description = (body['description'] ?? body['notes'])?.toString().trim();
      final rawDeadline = body['deadline'];
      DateTime? deadline;
      if (rawDeadline != null) {
        deadline = rawDeadline is DateTime ? rawDeadline : DateTime.tryParse(rawDeadline.toString());
      }
      final gradeWeight = (body['grade_weight'] as num?)?.toDouble();
      final priorityScore = (body['priority_score'] as num?)?.toDouble();
      final rawPriority = body['priority']?.toString().toUpperCase();
      final priority = rawPriority != null && ['HIGH', 'MEDIUM', 'LOW'].contains(rawPriority) ? rawPriority : null;
      final isFuzzyAuto = body['is_fuzzy_auto'] != null ? (body['is_fuzzy_auto'] != false && body['is_fuzzy_auto'] != 0) : null;
      final isCompleted = body['is_completed'] != null ? (body['is_completed'] == true || body['is_completed'] == 1) : null;

      // Handle course_code if provided
      String? courseCode;
      if (body.containsKey('course_code') || body.containsKey('course')) {
        final rawCourse = (body['course_code'] ?? body['course'] ?? '').toString().trim();
        String cCode = rawCourse.isEmpty ? 'GEN-DEFAULT' : rawCourse;
        String cName = rawCourse.isEmpty ? 'General Task' : rawCourse;
        if (cCode.contains('•')) {
          cName = cCode.split('•').last.trim();
          cCode = cCode.split('•').first.trim();
        }
        if (cCode.length > 20) cCode = cCode.substring(0, 20);
        if (cName.length > 100) cName = cName.substring(0, 100);
        courseCode = cCode;

        // Ensure course exists
        try {
          final existingCourse = await Database.query(
            'SELECT course_code FROM course WHERE course_code = @courseCode LIMIT 1',
            {'courseCode': courseCode},
          );
          if (existingCourse.rows.isEmpty) {
            try {
              await Database.query(
                '''
                INSERT INTO course (course_code, course_name, credits, lecturer)
                VALUES (@courseCode, @courseName, 3, 'General')
                ''',
                {'courseCode': courseCode, 'courseName': cName},
              );
            } catch (_) {}
          }
        } catch (_) {}
      }

      // Check existence & ownership
      QueryResult existing;
      try {
        existing = await Database.query(
          'SELECT * FROM task WHERE id_task = @idTask AND id_student = @idUser LIMIT 1',
          {'idTask': idTask, 'idUser': idUser},
        );
      } catch (e) {
        if (e.toString().contains('id_student')) {
          existing = await Database.query(
            'SELECT * FROM task WHERE id_task = @idTask AND id_user = @idUser LIMIT 1',
            {'idTask': idTask, 'idUser': idUser},
          );
        } else {
          rethrow;
        }
      }

      if (existing.rows.isEmpty) {
        return Response(404,
            body: jsonEncode({'status': 'error', 'message': 'Task not found or access denied'}),
            headers: {'Content-Type': 'application/json'});
      }

      final current = existing.rows.first.assoc();
      final finalTitle = taskTitle ?? current['task_title'];
      final finalDesc = description ?? current['description'];
      final finalDeadline = deadline?.toIso8601String() ?? current['deadline']?.toString();
      final finalWeight = gradeWeight ?? (current['grade_weight'] as num?)?.toDouble() ?? 0.0;
      final finalScore = priorityScore ?? (current['priority_score'] as num?)?.toDouble() ?? 0.0;
      final finalPriority = priority ?? current['priority']?.toString() ?? 'MEDIUM';
      final finalFuzzy = isFuzzyAuto ?? (current['is_fuzzy_auto'] == true || current['is_fuzzy_auto'] == 1);
      final finalCompleted = isCompleted ?? (current['is_completed'] == true || current['is_completed'] == 1);
      final finalCourse = courseCode ?? current['course_code']?.toString() ?? 'GEN-DEFAULT';

      final finalFuzzyInt = finalFuzzy ? 1 : 0;
      final finalCompletedInt = finalCompleted ? 1 : 0;

      try {
        await Database.query('''
          UPDATE task SET
            task_title = @title,
            description = @desc,
            course_code = @course,
            deadline = @deadline::timestamp,
            grade_weight = @weight,
            priority_score = @score,
            priority = @priority,
            is_fuzzy_auto = @fuzzy,
            is_completed = @completed,
            updated_at = CURRENT_TIMESTAMP
          WHERE id_task = @idTask AND id_student = @idUser
        ''', {
          'title': finalTitle,
          'desc': finalDesc,
          'course': finalCourse,
          'deadline': finalDeadline,
          'weight': finalWeight,
          'score': finalScore,
          'priority': finalPriority,
          'fuzzy': finalFuzzyInt,
          'completed': finalCompletedInt,
          'idTask': idTask,
          'idUser': idUser,
        });
      } catch (e) {
        if (e.toString().contains('id_student')) {
          await Database.query('''
            UPDATE task SET
              task_title = @title,
              description = @desc,
              course_code = @course,
              deadline = @deadline::timestamp,
              grade_weight = @weight,
              priority_score = @score,
              priority = @priority,
              is_fuzzy_auto = @fuzzy,
              is_completed = @completed,
              updated_at = CURRENT_TIMESTAMP
            WHERE id_task = @idTask AND id_user = @idUser
          ''', {
            'title': finalTitle,
            'desc': finalDesc,
            'course': finalCourse,
            'deadline': finalDeadline,
            'weight': finalWeight,
            'score': finalScore,
            'priority': finalPriority,
            'fuzzy': finalFuzzyInt,
            'completed': finalCompletedInt,
            'idTask': idTask,
            'idUser': idUser,
          });
        } else {
          rethrow;
        }
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Task updated successfully',
          'data': {
            'id_task': idTask,
            'id_user': idUser,
            'task_title': finalTitle,
            'description': finalDesc,
            'course_code': finalCourse,
            'deadline': finalDeadline,
            'grade_weight': finalWeight,
            'priority_score': finalScore,
            'priority': finalPriority,
            'is_fuzzy_auto': finalFuzzy,
            'is_completed': finalCompleted,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[TASK] updateTask error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── 5. TOGGLE STATUS PENYELESAIAN (IS_COMPLETED) ──────────────────────────
  // PUT /api/task/<idTask>/toggle
  static Future<Response> toggleComplete(Request req, String idTask) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      QueryResult res;
      try {
        res = await Database.query('''
          UPDATE task
          SET is_completed = (CASE WHEN is_completed = 1 THEN 0 ELSE 1 END), updated_at = CURRENT_TIMESTAMP
          WHERE id_task = @idTask AND id_student = @idUser
          RETURNING is_completed, task_title
        ''', {'idTask': idTask, 'idUser': idUser});
      } catch (e) {
        if (e.toString().contains('id_student')) {
          res = await Database.query('''
            UPDATE task
            SET is_completed = (CASE WHEN is_completed = 1 THEN 0 ELSE 1 END), updated_at = CURRENT_TIMESTAMP
            WHERE id_task = @idTask AND id_user = @idUser
            RETURNING is_completed, task_title
          ''', {'idTask': idTask, 'idUser': idUser});
        } else {
          rethrow;
        }
      }

      if (res.rows.isEmpty) {
        return Response(404,
            body: jsonEncode({'status': 'error', 'message': 'Task not found or access denied'}),
            headers: {'Content-Type': 'application/json'});
      }

      final newStatus = res.rows.first['is_completed'];
      final title = res.rows.first['task_title'];

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Task status updated',
          'data': {
            'id_task': idTask,
            'is_completed': newStatus,
            'task_title': title,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── 6. HAPUS TUGAS (DELETE) ──────────────────────────────────────────────
  // DELETE /api/task/<idTask>
  static Future<Response> deleteTask(Request req, String idTask) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      QueryResult res;
      try {
        res = await Database.query(
          'DELETE FROM task WHERE id_task = @idTask AND id_student = @idUser',
          {'idTask': idTask, 'idUser': idUser},
        );
      } catch (e) {
        if (e.toString().contains('id_student')) {
          res = await Database.query(
            'DELETE FROM task WHERE id_task = @idTask AND id_user = @idUser',
            {'idTask': idTask, 'idUser': idUser},
          );
        } else {
          rethrow;
        }
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Task deleted successfully',
          'affectedRows': res.affectedRows,
        }),
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
