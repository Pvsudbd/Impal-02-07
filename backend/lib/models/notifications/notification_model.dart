import 'package:uuid/uuid.dart';
import '../../config/db.dart';

/// Model & query PostgreSQL untuk tabel `notification` (REQ-009 & Reminder Engine).
class NotificationModel {
  static const _uuid = Uuid();

  static const Set<String> allowedCategories = {
    'all',
    'deadline',
    'lecture',
    'team',
    'ai_system',
  };

  static const Set<String> allowedActionTypes = {
    'view_task',
    'classroom',
    'open_team',
    'ai_reason',
    'session_details',
  };

  static DateTime _parseDate(dynamic val) {
    if (val is DateTime) return val;
    return DateTime.tryParse(val?.toString() ?? '') ?? DateTime.now();
  }

  static bool _parseBool(dynamic val) {
    if (val is bool) return val;
    if (val is num) return val != 0;
    final s = val?.toString().toLowerCase() ?? '';
    return s == 'true' || s == '1' || s == 't';
  }

  static Map<String, dynamic> rowToJson(Map<String, dynamic> row) {
    return {
      'id': (row['id_notification'] ?? '').toString(),
      'id_notification': (row['id_notification'] ?? '').toString(),
      'id_user': (row['id_user'] ?? '').toString(),
      'id_task': row['id_task']?.toString(),
      'category': (row['category'] ?? 'deadline').toString(),
      'category_label': (row['category_label'] ?? 'Reminder').toString(),
      'status_tag': (row['status_tag'] ?? 'Upcoming').toString(),
      'title': (row['message_title'] ?? '').toString(),
      'message_title': (row['message_title'] ?? '').toString(),
      'description': (row['message'] ?? '').toString(),
      'message': (row['message'] ?? '').toString(),
      'action_label': (row['action_label'] ?? 'View →').toString(),
      'action_type': (row['action_type'] ?? 'view_task').toString(),
      'target_id': row['target_id']?.toString(),
      'dedup_key': row['dedup_key']?.toString(),
      'is_read': _parseBool(row['is_read']),
      'sent_time': _parseDate(row['sent_time']).toIso8601String(),
      'created_at': _parseDate(row['created_at'] ?? row['sent_time']).toIso8601String(),
    };
  }

  static Future<Map<String, dynamic>> listForUser(
    String idUser, {
    String? category,
    int limit = 50,
  }) async {
    final safeLimit = limit.clamp(1, 200);
    final normalizedCategory = category?.trim().toLowerCase();
    final filterByCategory = normalizedCategory != null &&
        normalizedCategory.isNotEmpty &&
        normalizedCategory != 'all' &&
        allowedCategories.contains(normalizedCategory);

    final itemsSql = filterByCategory
        ? '''
          SELECT id_notification, id_user, id_task, category, category_label, status_tag,
                 message_title, message, action_label, action_type, target_id, dedup_key,
                 sent_time, is_read, created_at
          FROM notification
          WHERE id_user = :idUser AND category = :category
          ORDER BY sent_time DESC, created_at DESC
          LIMIT $safeLimit
          '''
        : '''
          SELECT id_notification, id_user, id_task, category, category_label, status_tag,
                 message_title, message, action_label, action_type, target_id, dedup_key,
                 sent_time, is_read, created_at
          FROM notification
          WHERE id_user = :idUser
          ORDER BY sent_time DESC, created_at DESC
          LIMIT $safeLimit
          ''';

    final params = <String, dynamic>{'idUser': idUser};
    if (filterByCategory) {
      params['category'] = normalizedCategory;
    }

    final listRes = await Database.query(itemsSql, params);
    final unreadRes = await Database.query(
      'SELECT COUNT(*) AS unread_count FROM notification WHERE id_user = :idUser AND is_read IS FALSE',
      {'idUser': idUser},
    );

    final unreadCount = unreadRes.rows.isNotEmpty
        ? (int.tryParse(unreadRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0)
        : 0;

    return {
      'unread_count': unreadCount,
      'items': listRes.rows.map((r) => rowToJson(r.assoc())).toList(),
    };
  }

  static Future<Map<String, dynamic>> createOrDeduplicate(
    String idUser,
    Map<String, dynamic> body,
  ) async {
    final rawTitle = (body['message_title'] ?? body['title'] ?? '').toString().trim();
    final rawMessage = (body['message'] ?? body['description'] ?? '').toString().trim();
    if (rawTitle.isEmpty || rawMessage.isEmpty) {
      throw const FormatException('title and description are required');
    }

    final rawCategory = (body['category'] ?? 'deadline').toString().trim().toLowerCase();
    final category = allowedCategories.contains(rawCategory) ? rawCategory : 'deadline';

    final rawActionType = (body['action_type'] ?? 'view_task').toString().trim().toLowerCase();
    final actionType = allowedActionTypes.contains(rawActionType) ? rawActionType : 'view_task';

    final categoryLabel = ((body['category_label'] ?? 'Reminder').toString().trim()).isEmpty
        ? 'Reminder'
        : body['category_label'].toString().trim();
    final statusTag = ((body['status_tag'] ?? 'Upcoming').toString().trim()).isEmpty
        ? 'Upcoming'
        : body['status_tag'].toString().trim();
    final actionLabel = ((body['action_label'] ?? 'View →').toString().trim()).isEmpty
        ? 'View →'
        : body['action_label'].toString().trim();

    final idTask = body['id_task']?.toString().trim();
    final targetId = body['target_id']?.toString().trim();
    final dedupKeyRaw = body['dedup_key']?.toString().trim();
    final dedupKey = (dedupKeyRaw != null && dedupKeyRaw.isNotEmpty)
        ? (dedupKeyRaw.length > 150 ? dedupKeyRaw.substring(0, 150) : dedupKeyRaw)
        : null;

    if (dedupKey != null) {
      final existing = await Database.query(
        '''
        SELECT id_notification, id_user, id_task, category, category_label, status_tag,
               message_title, message, action_label, action_type, target_id, dedup_key,
               sent_time, is_read, created_at
        FROM notification
        WHERE id_user = :idUser AND dedup_key = :dedupKey
        LIMIT 1
        ''',
        {'idUser': idUser, 'dedupKey': dedupKey},
      );
      if (existing.rows.isNotEmpty) {
        return rowToJson(existing.rows.first.assoc());
      }
    }

    final idNotification = _uuid.v4();
    final sentTime = DateTime.tryParse(body['sent_time']?.toString() ?? '') ?? DateTime.now().toUtc();
    final isRead = body['is_read'] == true;

    await Database.query(
      '''
      INSERT INTO notification (
        id_notification, id_user, id_task, category, category_label, status_tag,
        message_title, message, action_label, action_type, target_id, dedup_key,
        sent_time, is_read, created_at
      ) VALUES (
        :idNotification, :idUser, :idTask, :category, :categoryLabel, :statusTag,
        :messageTitle, :message, :actionLabel, :actionType, :targetId, :dedupKey,
        :sentTime, :isRead, NOW()
      )
      ON CONFLICT (id_user, dedup_key) WHERE dedup_key IS NOT NULL DO NOTHING
      ''',
      {
        'idNotification': idNotification,
        'idUser': idUser,
        'idTask': (idTask != null && idTask.isNotEmpty) ? idTask : null,
        'category': category,
        'categoryLabel': categoryLabel.length > 100 ? categoryLabel.substring(0, 100) : categoryLabel,
        'statusTag': statusTag.length > 60 ? statusTag.substring(0, 60) : statusTag,
        'messageTitle': rawTitle.length > 150 ? rawTitle.substring(0, 150) : rawTitle,
        'message': rawMessage,
        'actionLabel': actionLabel.length > 50 ? actionLabel.substring(0, 50) : actionLabel,
        'actionType': actionType,
        'targetId': (targetId != null && targetId.isNotEmpty) ? targetId : null,
        'dedupKey': dedupKey,
        'sentTime': sentTime.toIso8601String(),
        'isRead': isRead,
      },
    );

    final fetched = await Database.query(
      '''
      SELECT id_notification, id_user, id_task, category, category_label, status_tag,
             message_title, message, action_label, action_type, target_id, dedup_key,
             sent_time, is_read, created_at
      FROM notification
      WHERE id_user = :idUser AND (id_notification = :idNotification OR (:dedupKey IS NOT NULL AND dedup_key = :dedupKey))
      LIMIT 1
      ''',
      {'idUser': idUser, 'idNotification': idNotification, 'dedupKey': dedupKey},
    );

    if (fetched.rows.isNotEmpty) {
      return rowToJson(fetched.rows.first.assoc());
    }

    return {
      'id': idNotification,
      'id_notification': idNotification,
      'id_user': idUser,
      'id_task': idTask,
      'category': category,
      'category_label': categoryLabel,
      'status_tag': statusTag,
      'title': rawTitle,
      'message_title': rawTitle,
      'description': rawMessage,
      'message': rawMessage,
      'action_label': actionLabel,
      'action_type': actionType,
      'target_id': targetId,
      'dedup_key': dedupKey,
      'is_read': isRead,
      'sent_time': sentTime.toIso8601String(),
      'created_at': sentTime.toIso8601String(),
    };
  }

  static Future<bool> markAsRead(String idUser, String idNotification) async {
    final res = await Database.query(
      '''
      UPDATE notification
      SET is_read = TRUE
      WHERE id_user = :idUser AND id_notification = :idNotification
      ''',
      {'idUser': idUser, 'idNotification': idNotification},
    );
    return res.affectedRows > 0;
  }

  static Future<void> markAllAsRead(String idUser) async {
    await Database.query(
      '''
      UPDATE notification
      SET is_read = TRUE
      WHERE id_user = :idUser AND is_read IS FALSE
      ''',
      {'idUser': idUser},
    );
  }
}

