import 'package:flutter/material.dart';

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
  final Color assigneeColor;
  final List<Color>? assigneeColors;
  final String timeRange;
  final bool isDone;
  final String? description;
  final DateTime? deadline;
  final String? dueBadge;
  final bool isAlertEnabled;

  const TeamTaskModel({
    required this.id,
    required this.title,
    required this.priority,
    required this.assignedTo,
    required this.assigneeColor,
    this.assigneeColors,
    required this.timeRange,
    this.isDone = false,
    this.description,
    this.deadline,
    this.dueBadge,
    this.isAlertEnabled = true,
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
    Color? assigneeColor,
    List<Color>? assigneeColors,
    String? timeRange,
    bool? isDone,
    String? description,
    DateTime? deadline,
    String? dueBadge,
    bool? isAlertEnabled,
  }) {
    return TeamTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      assigneeColor: assigneeColor ?? this.assigneeColor,
      assigneeColors: assigneeColors ?? this.assigneeColors,
      timeRange: timeRange ?? this.timeRange,
      isDone: isDone ?? this.isDone,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      dueBadge: dueBadge ?? this.dueBadge,
      isAlertEnabled: isAlertEnabled ?? this.isAlertEnabled,
    );
  }
}

