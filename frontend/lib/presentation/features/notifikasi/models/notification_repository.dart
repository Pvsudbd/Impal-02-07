import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import 'notification_model.dart';

class NotificationRepository extends ChangeNotifier {
  static final NotificationRepository instance = NotificationRepository._internal();
  factory NotificationRepository() => instance;

  static const String _storageKey = 'saved_notifications_v1';
  static const String _ownerKey = 'saved_notifications_owner';

  NotificationRepository._internal() {
    _initDefaultNotifications();
  }

  late List<NotificationModel> _notifications;
  bool _initializedForSession = false;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _initDefaultNotifications() {
    _notifications = [
      NotificationModel(
        id: 'notif-1',
        category: NotificationCategory.deadline,
        categoryLabel: 'UBXCCB2 • IMPAL',
        statusTag: 'Due in 4 Hours',
        statusTagColor: const Color(0xFFFF7D65),
        title: 'Submission: SKPL Document & Group 7 Model Diagram',
        description:
            'Submission deadline on Telkom University LMS portal closes tonight at 23:59 WIB. Assignment weight 45% (Fuzzy Mamdani Crisp: 94.2).',
        timestamp: '12m ago • 09:15 WIB',
        dateGroup: 'TODAY',
        dateFormatted: 'Saturday, Oct 24, 2026',
        actionLabel: 'View Task →',
        actionType: NotificationActionType.viewTask,
        accentColor: const Color(0xFFFF5E4D),
        icon: Icons.warning_amber_rounded,
        isRead: false,
      ),
      NotificationModel(
        id: 'notif-2',
        category: NotificationCategory.lecture,
        categoryLabel: 'SSIF-04 • HCI',
        statusTag: 'Starts in 15 Min',
        statusTagColor: const Color(0xFFF5A623),
        title: 'Human-Computer Interaction Class (Room KTT B-106)',
        description:
            'Regular face-to-face lecture from 09:30 - 11:30 WIB with Lecturer. Remember to prepare your UI mockup draft.',
        timestamp: '25m ago • 09:05 WIB',
        dateGroup: 'TODAY',
        dateFormatted: 'Saturday, Oct 24, 2026',
        actionLabel: 'Classroom',
        actionType: NotificationActionType.classroom,
        accentColor: const Color(0xFFF5A623),
        icon: Icons.laptop_chromebook_rounded,
        isRead: false,
      ),
      NotificationModel(
        id: 'notif-3',
        category: NotificationCategory.team,
        categoryLabel: 'Group 7',
        statusTag: 'Discord Voice',
        statusTagColor: const Color(0xFF818CF8),
        title: 'Meeting Invitation: Sprint 2 Finalization & AI Inference Review',
        description:
            'Invited by Faishal (Scrum Master). Agenda: presentation tasks division and MySQL schema review. Meeting at 19:30 WIB.',
        timestamp: '2h ago • 07:30 WIB',
        dateGroup: 'TODAY',
        dateFormatted: 'Saturday, Oct 24, 2026',
        actionLabel: 'Open Team →',
        actionType: NotificationActionType.openTeam,
        accentColor: const Color(0xFF5B93FF),
        icon: Icons.groups_outlined,
        isRead: false,
      ),
      NotificationModel(
        id: 'notif-4',
        category: NotificationCategory.aiSystem,
        categoryLabel: 'Mamdani Engine',
        statusTag: 'Score: 87.5 / 100',
        statusTagColor: const Color(0xFF10B981),
        title: 'Smart Priority Escalation: Figma UI Task Raised to Critical',
        description:
            'Inference model detected 2 days remaining with 30% task weight. Recommended execution rank automatically escalated to #1.',
        timestamp: 'Yesterday • 18:40 WIB',
        dateGroup: 'YESTERDAY',
        dateFormatted: 'Friday, Oct 23, 2026',
        actionLabel: 'AI Reason (XAI)',
        actionType: NotificationActionType.aiReason,
        accentColor: const Color(0xFF10B981),
        icon: Icons.auto_awesome_rounded,
        isRead: true,
      ),
      NotificationModel(
        id: 'notif-5',
        category: NotificationCategory.all,
        categoryLabel: 'Account Security',
        statusTag: 'CAS TLS 1.3',
        statusTagColor: const Color(0xFF10B981),
        title: 'Tel-U SSO Directory & Course Schedule Sync Successful',
        description:
            '6 course schedules and 19 active semester credits successfully synchronized securely to local storage.',
        timestamp: 'Yesterday • 08:00 WIB',
        dateGroup: 'YESTERDAY',
        dateFormatted: 'Friday, Oct 23, 2026',
        actionLabel: 'Session Details',
        actionType: NotificationActionType.sessionDetails,
        accentColor: const Color(0xFF64748B),
        icon: Icons.shield_outlined,
        isRead: true,
      ),
    ];
  }

  Future<void> init() async {
    if (_initializedForSession) return;
    _initializedForSession = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      return;
    }

    final currentUserId = prefs.getString('user_id') ?? prefs.getString('auth_user') ?? '';
    final owner = prefs.getString(_ownerKey);
    if (owner == null || owner == currentUserId) {
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            _notifications = decoded
                .whereType<Map>()
                .map((m) => NotificationModel.fromApiMap(Map<String, dynamic>.from(m)))
                .toList();
            notifyListeners();
          }
        } catch (_) {}
      } else {
        _notifications = [];
        notifyListeners();
      }
    } else {
      _notifications = [];
      notifyListeners();
    }

    await fetchFromApi();
  }

  Future<void> _persistLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final owner = prefs.getString('user_id') ?? prefs.getString('auth_user') ?? '';
      if (owner.isNotEmpty) {
        await prefs.setString(_ownerKey, owner);
      }
      final encoded = _notifications.take(100).map((n) => n.toApiMap()).toList();
      await prefs.setString(_storageKey, jsonEncode(encoded));
    } catch (_) {}
  }

  Future<void> fetchFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('jwt_token');
      if (token == null || token.isEmpty) return;

      final res = await ApiClient.get('/api/notifications?limit=100', token: token);
      if (res['status'] == 'success' && res['data'] is Map) {
        final data = Map<String, dynamic>.from(res['data'] as Map);
        final rawItems = data['items'];
        if (rawItems is List) {
          final serverList = rawItems
              .whereType<Map>()
              .map((m) => NotificationModel.fromApiMap(Map<String, dynamic>.from(m)))
              .toList();
          _notifications = serverList;
          await _persistLocal();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[NOTIF_REPO] fetchFromApi error: $e');
    }
  }

  bool hasDedupKey(String dedupKey) {
    return _notifications.any((n) => n.dedupKey == dedupKey);
  }

  Future<void> recordReminder(
    NotificationModel notification, {
    String? dedupKey,
    String? idTask,
  }) async {
    final effectiveKey = dedupKey ?? notification.dedupKey;
    if (effectiveKey != null && hasDedupKey(effectiveKey)) return;

    final item = NotificationModel(
      id: notification.id,
      category: notification.category,
      categoryLabel: notification.categoryLabel,
      statusTag: notification.statusTag,
      statusTagColor: notification.statusTagColor,
      title: notification.title,
      description: notification.description,
      timestamp: notification.timestamp,
      dateGroup: notification.dateGroup,
      dateFormatted: notification.dateFormatted,
      actionLabel: notification.actionLabel,
      actionType: notification.actionType,
      accentColor: notification.accentColor,
      icon: notification.icon,
      targetId: notification.targetId,
      dedupKey: effectiveKey,
      sentAt: notification.sentAt ?? DateTime.now(),
      isRead: notification.isRead,
    );

    _notifications = [item, ..._notifications.where((n) => n.id != item.id)];
    notifyListeners();
    await _persistLocal();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('jwt_token');
      if (token == null || token.isEmpty) return;

      final res = await ApiClient.post(
        '/api/notifications',
        item.toApiMap(idTask: idTask),
        token: token,
      );
      if (res['status'] == 'success' && res['data'] is Map) {
        final serverItem = NotificationModel.fromApiMap(
          Map<String, dynamic>.from(res['data'] as Map),
        );
        final idx = _notifications.indexWhere(
          (n) => n.id == item.id || (effectiveKey != null && n.dedupKey == effectiveKey),
        );
        if (idx != -1) {
          _notifications[idx] = serverItem;
          await _persistLocal();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[NOTIF_REPO] recordReminder sync error: $e');
    }
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
      _persistLocal();
      _syncMarkRead(id);
    }
  }

  Future<void> _syncMarkRead(String id) async {
    if (id.startsWith('notif-') || id.startsWith('local-')) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('jwt_token');
      if (token == null || token.isEmpty) return;
      await ApiClient.patch('/api/notifications/$id/read', {}, token: token);
    } catch (e) {
      debugPrint('[NOTIF_REPO] _syncMarkRead error: $e');
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (final item in _notifications) {
      if (!item.isRead) {
        item.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      _persistLocal();
      _syncMarkAllRead();
    }
  }

  Future<void> _syncMarkAllRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('jwt_token');
      if (token == null || token.isEmpty) return;
      await ApiClient.patch('/api/notifications/read-all', {}, token: token);
    } catch (e) {
      debugPrint('[NOTIF_REPO] _syncMarkAllRead error: $e');
    }
  }

  int getCategoryCount(NotificationCategory category) {
    if (category == NotificationCategory.all) {
      return _notifications.length;
    }
    return _notifications.where((n) => n.category == category).length;
  }

  List<NotificationModel> getFiltered(NotificationCategory category) {
    if (category == NotificationCategory.all) {
      return notifications;
    }
    return _notifications.where((n) => n.category == category).toList();
  }

  void reset() {
    _initializedForSession = false;
    _initDefaultNotifications();
    notifyListeners();
  }

  Future<void> clearForLogout() async {
    _initializedForSession = false;
    _notifications = [];
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await prefs.remove(_ownerKey);
    } catch (_) {}
  }
}
