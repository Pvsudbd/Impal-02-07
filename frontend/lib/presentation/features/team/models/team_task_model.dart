import 'package:flutter/material.dart';
import '../../task/models/task_item_model.dart';

/// Priority level for team tasks
enum TaskPriority {
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }
}

/// Model representing a task in the team dashboard
class TeamTaskModel {
  final String id;
  final String title;
  final TaskPriority priority;
  final String assignedTo;
  final String? assignedMemberId;
  final Color assigneeColor;
  final List<Color>? assigneeColors;
  final String timeRange;
  final bool isDone;
  final String? description;
  final DateTime? deadline;
  final String? dueBadge;
  final bool isAlertEnabled;
  final String? rubricComponentId;
  final String? rubricComponentName;
  final int? gradeWeightPercent;
  final List<TaskTagModel> tags;

  const TeamTaskModel({
    required this.id,
    required this.title,
    required this.priority,
    required this.assignedTo,
    this.assignedMemberId,
    required this.assigneeColor,
    this.assigneeColors,
    required this.timeRange,
    this.isDone = false,
    this.description,
    this.deadline,
    this.dueBadge,
    this.isAlertEnabled = true,
    this.rubricComponentId,
    this.rubricComponentName,
    this.gradeWeightPercent,
    this.tags = const [],
  });

  /// Remaining time until deadline badge (e.g. '12h', '18h', '2d').
  String get effectiveDueBadge {
    if (dueBadge != null && dueBadge!.trim().isNotEmpty) {
      return dueBadge!.trim();
    }
    if (deadline != null) {
      final now = DateTime.now();
      final target = DateTime(
        deadline!.year,
        deadline!.month,
        deadline!.day,
        23,
        59,
      );
      final difference = target.difference(now);
      if (difference.isNegative) {
        return 'Overdue';
      }
      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      }
      if (difference.inHours > 0) {
        return '${difference.inHours}h';
      }
      return '<1h';
    }
    switch (priority) {
      case TaskPriority.high:
        return '12h';
      case TaskPriority.medium:
        return '18h';
      case TaskPriority.low:
        return '2d';
    }
  }

  /// Whether this task has an urgent deadline or high priority.
  bool get isUrgent {
    if (priority == TaskPriority.high) return true;
    final badge = effectiveDueBadge.toLowerCase();
    if (badge == 'overdue') return true;
    if (badge.endsWith('h')) {
      final h = int.tryParse(badge.replaceAll('h', '')) ?? 24;
      return h <= 12;
    }
    return false;
  }

  /// Returns the list of colors for assigned members.
  List<Color> get colors {
    if (assigneeColors != null && assigneeColors!.isNotEmpty) {
      return assigneeColors!;
    }
    return [assigneeColor];
  }

  TeamTaskModel copyWith({
    String? id,
    String? title,
    TaskPriority? priority,
    String? assignedTo,
    String? assignedMemberId,
    Color? assigneeColor,
    List<Color>? assigneeColors,
    String? timeRange,
    bool? isDone,
    String? description,
    DateTime? deadline,
    String? dueBadge,
    bool? isAlertEnabled,
    String? rubricComponentId,
    String? rubricComponentName,
    int? gradeWeightPercent,
    List<TaskTagModel>? tags,
  }) {
    return TeamTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedMemberId: assignedMemberId ?? this.assignedMemberId,
      assigneeColor: assigneeColor ?? this.assigneeColor,
      assigneeColors: assigneeColors ?? this.assigneeColors,
      timeRange: timeRange ?? this.timeRange,
      isDone: isDone ?? this.isDone,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      dueBadge: dueBadge ?? this.dueBadge,
      isAlertEnabled: isAlertEnabled ?? this.isAlertEnabled,
      rubricComponentId: rubricComponentId ?? this.rubricComponentId,
      rubricComponentName: rubricComponentName ?? this.rubricComponentName,
      gradeWeightPercent: gradeWeightPercent ?? this.gradeWeightPercent,
      tags: tags ?? this.tags,
    );
  }

  /// Creates a [TeamTaskModel] from a backend API map (group_task row).
  factory TeamTaskModel.fromMap(Map<String, dynamic> map) {
    final priorityRaw = (map['priority'] as String? ?? 'MEDIUM').toUpperCase();
    final priority = priorityRaw == 'HIGH'
        ? TaskPriority.high
        : (priorityRaw == 'LOW' ? TaskPriority.low : TaskPriority.medium);

    DateTime? deadline;
    final rawDeadline = map['deadline'];
    if (rawDeadline != null) {
      deadline = DateTime.tryParse(rawDeadline.toString());
    }

    final picName = map['pic_name']?.toString();
    final rawAssignedTo = map['assigned_to']?.toString();
    final rawIdAssignedTo = (map['id_assigned_to'] ?? map['assigned_to_id'])?.toString();

    final assignedName = (picName != null && picName.isNotEmpty)
        ? picName
        : ((rawAssignedTo != null && rawAssignedTo.isNotEmpty)
            ? rawAssignedTo
            : (rawIdAssignedTo ?? ''));

    return TeamTaskModel(
      id: (map['id_group_task'] ?? '').toString(),
      title: (map['task_title'] ?? map['title'] ?? '').toString(),
      priority: priority,
      assignedTo: assignedName,
      assignedMemberId: rawIdAssignedTo,
      assigneeColor: const Color(0xFF786FA6),
      timeRange: deadline != null
          ? '${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')} WIB'
          : '--:-- WIB',
      isDone: (map['is_completed'] == true || map['is_completed'] == 1 || map['is_completed'] == 'true'),
      description: map['description']?.toString(),
      deadline: deadline,
      isAlertEnabled: true,
    );
  }

  /// Converts this model to a map for sending to backend API.
  Map<String, dynamic> toApiMap() {
    return {
      'id_group_task': id,
      'task_title': title,
      'description': description ?? '',
      'deadline': deadline?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'grade_weight': gradeWeightPercent != null ? gradeWeightPercent! / 100.0 : 0.0,
      'priority': priority.name.toUpperCase(),
      'is_completed': isDone ? 1 : 0,
      if (assignedMemberId != null && assignedMemberId!.trim().isNotEmpty)
        'id_assigned_to': assignedMemberId!.trim(),
      if (assignedTo.trim().isNotEmpty)
        'assigned_to': assignedTo.trim(),
    };
  }

  /// Helper comparator to sort team tasks by nearest deadline first.
  static int compareTeamTaskDeadlines(TeamTaskModel a, TeamTaskModel b) {
    int getHours(String badge, TaskPriority p) {
      final clean = badge.trim().toLowerCase();
      if (clean == 'overdue') return -1;
      if (clean.endsWith('h')) {
        return int.tryParse(clean.replaceAll('h', '')) ?? 24;
      }
      if (clean.endsWith('d')) {
        return (int.tryParse(clean.replaceAll('d', '')) ?? 1) * 24;
      }
      switch (p) {
        case TaskPriority.high:
          return 12;
        case TaskPriority.medium:
          return 24;
        case TaskPriority.low:
          return 48;
      }
    }

    final aHours = getHours(a.effectiveDueBadge, a.priority);
    final bHours = getHours(b.effectiveDueBadge, b.priority);

    if (aHours != bHours) {
      return aHours.compareTo(bHours);
    }
    if (a.deadline != null && b.deadline != null) {
      return a.deadline!.compareTo(b.deadline!);
    }
    return a.priority.index.compareTo(b.priority.index);
  }
}

