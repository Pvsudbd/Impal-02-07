import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import '../../config/db.dart';
import '../../models/tags/tag_model.dart';

/// Controller untuk mengelola Custom Task Tags per pengguna (tabel `task_tags`).
///
/// Mematuhi spesifikasi REQ-006, standar JWT/BOLA, dan parameterized query.
class TagController {
  static const _uuid = Uuid();

  static const Set<String> _reservedLabels = {
    'all',
    'college',
    'personal',
    'team',
    'completed',
    'task',
  };

  static String? _getUserId(Request req) {
    final user = (req.context['user'] ?? req.context['student']) as Map<String, dynamic>?;
    return (user?['idUser'] ??
            user?['idStudent'] ??
            user?['id_user'] ??
            user?['id_student'] ??
            user?['id'] ??
            user?['sub']) as String?;
  }

  // GET /api/tags
  static Future<Response> getTags(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final results = await Database.query(
        '''
        SELECT id_tag, id_user, label, background_color, text_color, is_default, created_at, updated_at
        FROM task_tags
        WHERE id_user::text = @idUser
        ORDER BY created_at ASC, label ASC
        ''',
        {'idUser': idUser},
      );

      final tags = results.rows.map((r) => TagModel.fromJson(r.assoc()).toJson()).toList();
      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Task tags retrieved successfully',
          'count': tags.length,
          'data': tags,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[TAGS] getTags error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/tags
  static Future<Response> createTag(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final rawBody = await req.readAsString();
      if (rawBody.trim().isEmpty) {
        return Response(400,
            body: jsonEncode({'status': 'error', 'message': 'Request body cannot be empty'}),
            headers: {'Content-Type': 'application/json'});
      }

      final body = jsonDecode(rawBody) as Map<String, dynamic>;
      final label = (body['label'] ?? '').toString().trim();
      if (label.isEmpty) {
        return Response(400,
            body: jsonEncode({'status': 'error', 'message': 'Tag name is required.'}),
            headers: {'Content-Type': 'application/json'});
      }
      if (label.length > 24) {
        return Response(400,
            body: jsonEncode({'status': 'error', 'message': 'Tag name must be 24 characters or fewer.'}),
            headers: {'Content-Type': 'application/json'});
      }
      if (_reservedLabels.contains(label.toLowerCase())) {
        return Response(400,
            body: jsonEncode({'status': 'error', 'message': '"$label" is a reserved category filter name.'}),
            headers: {'Content-Type': 'application/json'});
      }

      final existing = await Database.query(
        '''
        SELECT id_tag, id_user, label, background_color, text_color, is_default, created_at, updated_at
        FROM task_tags
        WHERE id_user::text = @idUser AND LOWER(label) = LOWER(@label)
        LIMIT 1
        ''',
        {'idUser': idUser, 'label': label},
      );

      if (existing.rows.isNotEmpty) {
        return Response(409,
            body: jsonEncode({
              'status': 'error',
              'message': 'Tag "$label" already exists.',
              'data': TagModel.fromJson(existing.rows.first.assoc()).toJson(),
            }),
            headers: {'Content-Type': 'application/json'});
      }

      final requestedId = (body['id_tag'] ?? body['id'])?.toString().trim();
      final idTag = (requestedId != null && requestedId.isNotEmpty && requestedId.length <= 36)
          ? requestedId
          : _uuid.v4();
      final bgColor = (body['background_color'] as num?)?.toInt() ?? 0xFF778BEB;
      final textColor = (body['text_color'] as num?)?.toInt() ?? 0xFF1E296B;
      final isDefault = body['is_default'] == true || body['is_default'] == 1;

      await Database.query(
        '''
        INSERT INTO task_tags (
          id_tag, id_user, label, background_color, text_color, is_default, created_at, updated_at
        ) VALUES (
          @idTag, @idUser, @label, @bgColor, @textColor, @isDefault, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        )
        ''',
        {
          'idTag': idTag,
          'idUser': idUser,
          'label': label,
          'bgColor': bgColor,
          'textColor': textColor,
          'isDefault': isDefault,
        },
      );

      final created = TagModel(
        idTag: idTag,
        idUser: idUser,
        label: label,
        backgroundColor: bgColor,
        textColor: textColor,
        isDefault: isDefault,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return Response(201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Tag created successfully',
          'data': created.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[TAGS] createTag error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // DELETE /api/tags/<idTag>
  static Future<Response> deleteTag(Request req, String idTag) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      await Database.query(
        'DELETE FROM task_tags WHERE id_tag::text = @idTag AND id_user::text = @idUser',
        {'idTag': idTag, 'idUser': idUser},
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Tag deleted successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[TAGS] deleteTag error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}

