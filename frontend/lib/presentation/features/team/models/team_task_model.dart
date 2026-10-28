import 'package:flutter/material.dart';

/// Priority level for team tasks
enum TaskPriority { high, medium, low }

/// Model representing a task in the team dashboard
class TeamTaskModel {
  final String id;
  final String title;
  final TaskPriority priority;
  final String assignedTo;
  final Color assigneeColor;
  final String timeRange;
  final bool isDone;

  const TeamTaskModel({
    required this.id,
    required this.title,
    required this.priority,
    required this.assignedTo,
    required this.assigneeColor,
    required this.timeRange,
    this.isDone = false,
  });

  TeamTaskModel copyWith({
    String? id,
    String? title,
    TaskPriority? priority,
    String? assignedTo,
    Color? assigneeColor,
    String? timeRange,
    bool? isDone,
  }) {
    return TeamTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      assigneeColor: assigneeColor ?? this.assigneeColor,
      timeRange: timeRange ?? this.timeRange,
      isDone: isDone ?? this.isDone,
    );
  }
}

