import 'package:flutter/material.dart';

enum NotificationCategory {
  all,
  deadline,
  lecture,
  team,
  aiSystem,
}

enum NotificationActionType {
  viewTask,
  classroom,
  openTeam,
  aiReason,
  sessionDetails,
}

class NotificationModel {
  final String id;
  final NotificationCategory category;
  final String categoryLabel;
  final String statusTag;
  final Color statusTagColor;
  final String title;
  final String description;
  final String timestamp;
  final String dateGroup;
  final String dateFormatted;
  final String actionLabel;
  final NotificationActionType actionType;
  final Color accentColor;
  final IconData icon;
  final String? targetId;
  final String? dedupKey;
  final DateTime? sentAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.statusTag,
    required this.statusTagColor,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.dateGroup,
    required this.dateFormatted,
    required this.actionLabel,
    required this.actionType,
    required this.accentColor,
    required this.icon,
    this.targetId,
    this.dedupKey,
    this.sentAt,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      category: category,
      categoryLabel: categoryLabel,
      statusTag: statusTag,
      statusTagColor: statusTagColor,
      title: title,
      description: description,
      timestamp: timestamp,
      dateGroup: dateGroup,
      dateFormatted: dateFormatted,
      actionLabel: actionLabel,
      actionType: actionType,
      accentColor: accentColor,
      icon: icon,
      targetId: targetId,
      dedupKey: dedupKey,
      sentAt: sentAt,
      isRead: isRead ?? this.isRead,
    );
  }

  static NotificationCategory categoryFromString(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'deadline':
        return NotificationCategory.deadline;
      case 'lecture':
        return NotificationCategory.lecture;
      case 'team':
        return NotificationCategory.team;
      case 'ai_system':
      case 'aisystem':
        return NotificationCategory.aiSystem;
      default:
        return NotificationCategory.all;
    }
  }

  static String categoryToApi(NotificationCategory c) {
    switch (c) {
      case NotificationCategory.deadline:
        return 'deadline';
      case NotificationCategory.lecture:
        return 'lecture';
      case NotificationCategory.team:
        return 'team';
      case NotificationCategory.aiSystem:
        return 'ai_system';
      case NotificationCategory.all:
        return 'all';
    }
  }

  static NotificationActionType actionTypeFromString(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'view_task':
      case 'viewtask':
        return NotificationActionType.viewTask;
      case 'classroom':
        return NotificationActionType.classroom;
      case 'open_team':
      case 'openteam':
        return NotificationActionType.openTeam;
      case 'ai_reason':
      case 'aireason':
        return NotificationActionType.aiReason;
      case 'session_details':
      case 'sessiondetails':
        return NotificationActionType.sessionDetails;
      default:
        return NotificationActionType.viewTask;
    }
  }

  static String actionTypeToApi(NotificationActionType t) {
    switch (t) {
      case NotificationActionType.viewTask:
        return 'view_task';
      case NotificationActionType.classroom:
        return 'classroom';
      case NotificationActionType.openTeam:
        return 'open_team';
      case NotificationActionType.aiReason:
        return 'ai_reason';
      case NotificationActionType.sessionDetails:
        return 'session_details';
    }
  }

  static Color accentColorFor(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.deadline:
        return const Color(0xFFFF5E4D);
      case NotificationCategory.lecture:
        return const Color(0xFFF5A623);
      case NotificationCategory.team:
        return const Color(0xFF5B93FF);
      case NotificationCategory.aiSystem:
        return const Color(0xFF10B981);
      case NotificationCategory.all:
        return const Color(0xFF64748B);
    }
  }

  static IconData iconFor(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.deadline:
        return Icons.warning_amber_rounded;
      case NotificationCategory.lecture:
        return Icons.laptop_chromebook_rounded;
      case NotificationCategory.team:
        return Icons.groups_outlined;
      case NotificationCategory.aiSystem:
        return Icons.auto_awesome_rounded;
      case NotificationCategory.all:
        return Icons.notifications_active_outlined;
    }
  }

  static String formatTimestampLabel(DateTime dt) {
    final local = dt.toLocal();
    final diff = DateTime.now().difference(local);
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    if (diff.inMinutes < 1) return 'Just now • $hh:$mm WIB';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago • $hh:$mm WIB';
    if (diff.inHours < 24) return '${diff.inHours}h ago • $hh:$mm WIB';
    return '${local.day}/${local.month} • $hh:$mm WIB';
  }

  static String formatDateGroup(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(local.year, local.month, local.day);
    final dayDiff = today.difference(target).inDays;
    if (dayDiff <= 0) return 'TODAY';
    if (dayDiff == 1) return 'YESTERDAY';
    return 'EARLIER';
  }

  static String formatDateReadable(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  factory NotificationModel.fromApiMap(Map<String, dynamic> map) {
    final category = categoryFromString((map['category'] ?? 'deadline').toString());
    final actionType = actionTypeFromString((map['action_type'] ?? 'view_task').toString());
    final sentAt = DateTime.tryParse((map['sent_time'] ?? map['created_at'] ?? '').toString()) ??
        DateTime.now();
    final accent = accentColorFor(category);
    return NotificationModel(
      id: (map['id_notification'] ?? map['id'] ?? '').toString(),
      category: category,
      categoryLabel: (map['category_label'] ?? 'Reminder').toString(),
      statusTag: (map['status_tag'] ?? 'Upcoming').toString(),
      statusTagColor: accent,
      title: (map['title'] ?? map['message_title'] ?? '').toString(),
      description: (map['description'] ?? map['message'] ?? '').toString(),
      timestamp: formatTimestampLabel(sentAt),
      dateGroup: formatDateGroup(sentAt),
      dateFormatted: formatDateReadable(sentAt),
      actionLabel: (map['action_label'] ?? 'View →').toString(),
      actionType: actionType,
      accentColor: accent,
      icon: iconFor(category),
      targetId: map['target_id']?.toString(),
      dedupKey: map['dedup_key']?.toString(),
      sentAt: sentAt,
      isRead: map['is_read'] == true || map['is_read'] == 1,
    );
  }

  Map<String, dynamic> toApiMap({String? idTask}) => {
        'id_notification': id,
        'id_task': idTask ?? (category == NotificationCategory.deadline ? targetId : null),
        'category': categoryToApi(category),
        'category_label': categoryLabel,
        'status_tag': statusTag,
        'title': title,
        'message_title': title,
        'description': description,
        'message': description,
        'action_label': actionLabel,
        'action_type': actionTypeToApi(actionType),
        'target_id': targetId,
        'dedup_key': dedupKey,
        'is_read': isRead,
        'sent_time': (sentAt ?? DateTime.now()).toUtc().toIso8601String(),
      };
}

