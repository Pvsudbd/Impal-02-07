import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import '../../config/db.dart';
import '../../models/todo/todo_item.dart';

/// Controller untuk mengelola Checklist To-Do Harian (Tabel todo_item).
class TodoController {
  static const _uuid = Uuid();

  static String? _getUserId(Request req) {
    final user = (req.context['user'] ?? req.context['student']) as Map<String, dynamic>?;
    return (user?['idUser'] ?? user?['idStudent']) as String?;
  }

  // GET /api/todo
  static Future<Response> getTodos(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final dateParam = req.url.queryParameters['date'];
      String sql;
      Map<String, dynamic> params = {'idUser': idUser};

      if (dateParam != null && dateParam.isNotEmpty) {
        sql = '''
          SELECT * FROM todo_item
          WHERE id_user = @idUser AND date = @date::date
          ORDER BY is_done ASC, created_at ASC
        ''';
        params['date'] = dateParam;
      } else {
        sql = '''
          SELECT * FROM todo_item
          WHERE id_user = @idUser
          ORDER BY date DESC, is_done ASC, created_at ASC
        ''';
      }

      final results = await Database.query(sql, params);
      final todos = results.rows.map((r) => r.assoc()).toList();

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'count': todos.length,
          'data': todos,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[TODO] getTodos error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/todo
  static Future<Response> createTodo(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final title = (body['activity_title'] ?? body['title'])?.toString().trim();
      final notes = (body['notes'] ?? '')?.toString().trim();
      final dateStr = body['date']?.toString() ?? DateTime.now().toIso8601String().split('T').first;

      if (title == null || title.isEmpty) {
        return Response(400,
            body: jsonEncode({'status': 'error', 'message': 'Activity title is required'}),
            headers: {'Content-Type': 'application/json'});
      }

      final idItem = 'todo_${_uuid.v4()}';
      final sql = '''
        INSERT INTO todo_item (id_item, id_user, activity_title, notes, date, is_done, created_at, updated_at)
        VALUES (@idItem, @idUser, @title, @notes, @date::date, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      ''';

      await Database.query(sql, {
        'idItem': idItem,
        'idUser': idUser,
        'title': title,
        'notes': notes,
        'date': dateStr,
      });

      return Response(201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Todo item created successfully',
          'data': {
            'id_item': idItem,
            'id_user': idUser,
            'activity_title': title,
            'notes': notes,
            'date': dateStr,
            'is_done': false,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[TODO] createTodo error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // PUT /api/todo/<idItem>/toggle
  static Future<Response> toggleTodo(Request req, String idItem) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final sql = '''
        UPDATE todo_item
        SET is_done = NOT is_done, updated_at = CURRENT_TIMESTAMP
        WHERE id_item = @idItem AND id_user = @idUser
        RETURNING is_done
      ''';

      final res = await Database.query(sql, {'idItem': idItem, 'idUser': idUser});
      if (res.rows.isEmpty) {
        return Response(404,
            body: jsonEncode({'status': 'error', 'message': 'Todo item not found'}),
            headers: {'Content-Type': 'application/json'});
      }

      final newStatus = res.rows.first['is_done'];

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Todo status updated',
          'data': {'id_item': idItem, 'is_done': newStatus},
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

  // DELETE /api/todo/<idItem>
  static Future<Response> deleteTodo(Request req, String idItem) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final sql = 'DELETE FROM todo_item WHERE id_item = @idItem AND id_user = @idUser';
      final res = await Database.query(sql, {'idItem': idItem, 'idUser': idUser});

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Todo item deleted successfully',
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
