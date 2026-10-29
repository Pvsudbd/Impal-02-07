import 'package:flutter/material.dart';
import 'notification_model.dart';

class NotificationRepository extends ChangeNotifier {
  static final NotificationRepository instance = NotificationRepository._internal();
  factory NotificationRepository() => instance;

  NotificationRepository._internal() {
    _initDefaultNotifications();
  }

  late List<NotificationModel> _notifications;

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

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
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
    _initDefaultNotifications();
    notifyListeners();
  }
}

