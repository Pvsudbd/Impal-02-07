import 'package:flutter/material.dart';

/// Priority levels for a task.
enum TaskPriorityLevel {
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case TaskPriorityLevel.high:
        return 'High';
      case TaskPriorityLevel.medium:
        return 'Medium';
      case TaskPriorityLevel.low:
        return 'Low';
    }
  }

  Color get badgeBg {
    switch (this) {
      case TaskPriorityLevel.high:
        return const Color(0xFFFF7D65);
      case TaskPriorityLevel.medium:
        return const Color(0xFF786FA6);
      case TaskPriorityLevel.low:
        return const Color(0xFF63CDDA);
    }
  }

  Color get badgeText => Colors.white;

  static TaskPriorityLevel fromString(String value) {
    final lower = value.trim().toLowerCase();
    if (lower.contains('high')) return TaskPriorityLevel.high;
    if (lower.contains('medium') || lower.contains('med')) return TaskPriorityLevel.medium;
    return TaskPriorityLevel.low;
  }
}

/// Visual tag / category badge on task cards.
class TaskTagModel {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const TaskTagModel({
    required this.label,
    required this.backgroundColor,
    this.textColor = Colors.white,
  });
}

/// Rich domain model representing a single task in IMPAL Task Manager.
///
/// Designed to support both collapsed summaries in the task list
/// and the detailed expanded view ("card nya memanjang").
class TaskItemModel {
  final String id;
  final String title;
  final TaskPriorityLevel priority;
  final String durationBadge; // e.g. '12h', '13h', '20h'
  final Color durationBadgeColor;
  final Color durationTextColor;
  final String? subtitle; // e.g. 'Team members' or 'Membuat video perkenalan'
  final DateTime deadlineDate;
  final String formattedDeadline; // e.g. 'Sat 11 Oct 2026, 23: 59 WIB'
  final List<Color> memberAvatars;
  final int? progressPercent; // e.g. 98 -> 98% circular ring
  final List<TaskTagModel> tags;
  final List<String> groupMembers;
  final String course;
  final String dateCreated;
  final String centroidDefuzzification;
  final String centroidScale;
  final String warningNotice;
  final String notes;
  final bool isAutomaticWeight;
  final bool isAssignedToUser;
  final bool isCollegeTask;
  final bool isAlertEnabled;

  const TaskItemModel({
    required this.id,
    required this.title,
    this.priority = TaskPriorityLevel.high,
    this.durationBadge = '12h',
    this.durationBadgeColor = const Color(0xFF5B93FF),
    this.durationTextColor = Colors.white,
    this.subtitle,
    required this.deadlineDate,
    required this.formattedDeadline,
    this.memberAvatars = const [],
    this.progressPercent,
    this.tags = const [],
    this.groupMembers = const [],
    this.course = 'SSIF-04-REG • Software Testing & Implementation',
    this.dateCreated = 'Monday, 30 Sep 2026',
    this.centroidDefuzzification = 'z* = 28.6',
    this.centroidScale = 'scale(0-100)',
    this.warningNotice = '*This task is asigned to you, and you can’t delete',
    this.notes = '',
    this.isAutomaticWeight = true,
    this.isAssignedToUser = true,
    this.isCollegeTask = true,
    this.isAlertEnabled = true,
  });

  String get priorityLabel {
    switch (priority) {
      case TaskPriorityLevel.high:
        return 'High';
      case TaskPriorityLevel.medium:
        return 'Medium';
      case TaskPriorityLevel.low:
        return 'Low';
    }
  }

  Color get priorityBadgeColor {
    switch (priority) {
      case TaskPriorityLevel.high:
        return const Color(0xFFFF5E4D);
      case TaskPriorityLevel.medium:
        return const Color(0xFFFBBF24);
      case TaskPriorityLevel.low:
        return const Color(0xFF6EE7B7);
    }
  }

  Color get priorityTextColor {
    switch (priority) {
      case TaskPriorityLevel.high:
        return Colors.white;
      case TaskPriorityLevel.medium:
        return const Color(0xFF1F2937);
      case TaskPriorityLevel.low:
        return const Color(0xFF064E3B);
    }
  }

  bool get isTeamTask =>
      memberAvatars.isNotEmpty ||
      tags.any((t) => t.label.trim().toLowerCase() == 'kelompok') ||
      groupMembers.length > 1;

  TaskItemModel copyWith({
    String? id,
    String? title,
    TaskPriorityLevel? priority,
    String? durationBadge,
    Color? durationBadgeColor,
    Color? durationTextColor,
    String? subtitle,
    DateTime? deadlineDate,
    String? formattedDeadline,
    List<Color>? memberAvatars,
    int? progressPercent,
    List<TaskTagModel>? tags,
    List<String>? groupMembers,
    String? course,
    String? dateCreated,
    String? centroidDefuzzification,
    String? centroidScale,
    String? warningNotice,
    String? notes,
    bool? isAutomaticWeight,
    bool? isAssignedToUser,
    bool? isCollegeTask,
    bool? isAlertEnabled,
  }) {
    return TaskItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      durationBadge: durationBadge ?? this.durationBadge,
      durationBadgeColor: durationBadgeColor ?? this.durationBadgeColor,
      durationTextColor: durationTextColor ?? this.durationTextColor,
      subtitle: subtitle ?? this.subtitle,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      formattedDeadline: formattedDeadline ?? this.formattedDeadline,
      memberAvatars: memberAvatars ?? this.memberAvatars,
      progressPercent: progressPercent ?? this.progressPercent,
      tags: tags ?? this.tags,
      groupMembers: groupMembers ?? this.groupMembers,
      course: course ?? this.course,
      dateCreated: dateCreated ?? this.dateCreated,
      centroidDefuzzification:
          centroidDefuzzification ?? this.centroidDefuzzification,
      centroidScale: centroidScale ?? this.centroidScale,
      warningNotice: warningNotice ?? this.warningNotice,
      notes: notes ?? this.notes,
      isAutomaticWeight: isAutomaticWeight ?? this.isAutomaticWeight,
      isAssignedToUser: isAssignedToUser ?? this.isAssignedToUser,
      isCollegeTask: isCollegeTask ?? this.isCollegeTask,
      isAlertEnabled: isAlertEnabled ?? this.isAlertEnabled,
    );
  }

  /// Default mock tasks reflecting the exact Figma design screenshots.
  static List<TaskItemModel> get defaultTasks => [
        TaskItemModel(
          id: 'task_1',
          title: 'Tugas Besar Kecerdasan AI',
          priority: TaskPriorityLevel.high,
          durationBadge: '12h',
          durationBadgeColor: const Color(0xFF5B93FF),
          durationTextColor: Colors.white,
          subtitle: 'Team members',
          deadlineDate: DateTime(2026, 10, 11, 23, 59),
          formattedDeadline: 'Sat 11 Oct 2026, 23: 59 WIB',
          memberAvatars: const [
            Color(0xFFF3A683),
            Color(0xFF786FA6),
            Color(0xFF63CDDA),
          ],
          progressPercent: 98,
          tags: const [
            TaskTagModel(
              label: 'Kelompok',
              backgroundColor: Color(0xFF786FA6),
              textColor: Color(0xFF4A3C8C),
            ),
            TaskTagModel(
              label: 'Code',
              backgroundColor: Color(0xFF778BEB),
              textColor: Color(0xFF4056C0),
            ),
          ],
          groupMembers: const [
            'Andi sukamoto (Leader)',
            'Rayya Gemintang Nusasntarra',
            'Kafi Rijal Perkasa Situmorang',
          ],
          course: 'SSIF-04-REG • Software Testing & Implementation',
          dateCreated: 'Monday, 30 Sep 2026',
          centroidDefuzzification: 'z* = 28.6',
          centroidScale: 'scale(0-100)',
          warningNotice: '*This task is asigned to you, and you can’t delete',
          notes: 'Implementasi fuzzy inference system Mamdani pada model prediksi AI.',
          isAutomaticWeight: true,
        ),
        TaskItemModel(
          id: 'task_2',
          title: 'Tugas Video BINDO',
          priority: TaskPriorityLevel.medium,
          durationBadge: '13h',
          durationBadgeColor: const Color(0xFF5B93FF),
          durationTextColor: Colors.white,
          subtitle: 'Membuat video perkenalan',
          deadlineDate: DateTime(2026, 10, 11, 23, 59),
          formattedDeadline: 'Sat 11 Oct 2026, 23: 59 WIB',
          memberAvatars: const [],
          progressPercent: null,
          tags: const [
            TaskTagModel(
              label: 'personal',
              backgroundColor: Color(0xFF786FA6),
              textColor: Color(0xFF4A3C8C),
            ),
            TaskTagModel(
              label: 'Video',
              backgroundColor: Color(0xFF63CDDA),
              textColor: Color(0xFF1C636D),
            ),
          ],
          groupMembers: const [
            'Personal Task • Jarvis',
          ],
          course: 'BINDO-02 • Bahasa Indonesia',
          dateCreated: 'Tuesday, 01 Oct 2026',
          centroidDefuzzification: 'z* = 45.2',
          centroidScale: 'scale(0-100)',
          warningNotice: '*This task is asigned to you, and you can’t delete',
          notes: 'Rekaman video monolog bahasa Indonesia formal durasi 3-5 menit.',
          isAutomaticWeight: false,
          isCollegeTask: false,
        ),
        TaskItemModel(
          id: 'task_3',
          title: 'Analisis Teks Paragraf BINDO',
          priority: TaskPriorityLevel.medium,
          durationBadge: '20h',
          durationBadgeColor: const Color(0xFFFF7D65),
          durationTextColor: Colors.white,
          subtitle: 'Team members',
          deadlineDate: DateTime(2026, 10, 15, 23, 59),
          formattedDeadline: 'Wed 15 Oct 2026, 23: 59 WIB',
          memberAvatars: const [
            Color(0xFFF3A683),
            Color(0xFF778BEB),
          ],
          progressPercent: null,
          tags: const [
            TaskTagModel(
              label: 'Kelompok',
              backgroundColor: Color(0xFF786FA6),
              textColor: Color(0xFF4A3C8C),
            ),
            TaskTagModel(
              label: 'Analisis',
              backgroundColor: Color(0xFF778BEB),
              textColor: Color(0xFF4056C0),
            ),
          ],
          groupMembers: const [
            'Andi sukamoto (Leader)',
            'Kafi Rijal Perkasa Situmorang',
          ],
          course: 'BINDO-02 • Bahasa Indonesia',
          dateCreated: 'Wednesday, 02 Oct 2026',
          centroidDefuzzification: 'z* = 18.4',
          centroidScale: 'scale(0-100)',
          warningNotice: '*This task is asigned to you, and you can’t delete',
          notes: 'Bedah struktur paragraf deduktif dan induktif artikel opini.',
          isAutomaticWeight: true,
        ),
      ];
}

