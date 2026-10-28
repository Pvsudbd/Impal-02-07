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
  });

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
    );
  }
}

