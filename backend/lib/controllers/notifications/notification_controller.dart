import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../models/notifications/notification_model.dart';

/// Controller REST API untuk Feed Notifikasi In-App & Sync Reminder.
class NotificationController {
  static String? _getUserId(Request req) {
    final user = (req.context['user'] ?? req.context['student']) as Map<String, dynamic>?;
    return (user?['idUser'] ??
            user?['idStudent'] ??
            user?['id_user'] ??
            user?['id_student'] ??
            user?['id'] ??
            user?['sub']) as String?;
  }

  // GET /api/notifications?category=all&limit=50
  static Future<Response> getNotifications(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final category = req.url.queryParameters['category'];
      final limit = int.tryParse(req.url.queryParameters['limit'] ?? '50') ?? 50;
      final data = await NotificationModel.listForUser(
        idUser,
        category: category,
        limit: limit,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Notifications retrieved successfully',
          'data': data,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[NOTIFICATIONS] getNotifications error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': 'Gagal mengambil daftar notifikasi.'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/notifications or POST /api/notifications/sync
  static Future<Response> createOrSyncNotifications(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final rawBody = await req.readAsString();
      if (rawBody.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Request body cannot be empty'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final decoded = jsonDecode(rawBody);
      final List<Map<String, dynamic>> payloads = [];
      if (decoded is Map<String, dynamic> && decoded['items'] is List) {
        for (final entry in decoded['items'] as List) {
          if (entry is Map<String, dynamic>) payloads.add(entry);
        }
      } else if (decoded is Map<String, dynamic>) {
        payloads.add(decoded);
      } else {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Invalid notification payload'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final created = <Map<String, dynamic>>[];
      for (final item in payloads) {
        try {
          created.add(await NotificationModel.createOrDeduplicate(idUser, item));
        } on FormatException {
          // Skip invalid entries in batch sync without failing valid items
          if (payloads.length == 1) rethrow;
        }
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Notifications synced successfully',
          'data': created.length == 1 && !decoded.containsKey('items')
              ? created.first
              : {'items': created},
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } on FormatException catch (e) {
      return Response.badRequest(
        body: jsonEncode({'status': 'error', 'message': e.message}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[NOTIFICATIONS] createOrSync error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': 'Gagal menyimpan notifikasi.'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // PATCH /api/notifications/read-all
  static Future<Response> markAllAsRead(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      await NotificationModel.markAllAsRead(idUser);
      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'All notifications marked as read',
          'data': {'unread_count': 0},
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[NOTIFICATIONS] markAllAsRead error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': 'Gagal menandai notifikasi telah dibaca.'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // PATCH /api/notifications/<id>/read
  static Future<Response> markAsRead(Request req, String idNotification) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(
          401,
          body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final updated = await NotificationModel.markAsRead(idUser, idNotification);
      if (!updated) {
        return Response.notFound(
          jsonEncode({'status': 'error', 'message': 'Notification not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Notification marked as read',
          'data': {'id': idNotification, 'is_read': true},
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[NOTIFICATIONS] markAsRead error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': 'Gagal menandai notifikasi.'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
