import 'package:flutter/material.dart';
import '../../schedule/models/schedule_model.dart';
import '../../task/models/task_item_model.dart';

/// Schedule preview item for the dashboard
class ScheduleItem {
  final String courseCode;
  final String status;
  final String location;
  final String time;

  const ScheduleItem({
    required this.courseCode,
    required this.status,
    required this.location,
    required this.time,
  });

  factory ScheduleItem.fromModel(ScheduleModel model) {
    return ScheduleItem(
      courseCode: model.title,
      status: model.status,
      location: model.location ?? model.course ?? '',
      time: model.formattedTime,
    );
  }
}

/// Category item for dashboard filtering
class CategoryItem {
  final String name;
  final String count;
  final IconData icon;

  const CategoryItem({
    required this.name,
    required this.count,
    required this.icon,
  });
}

/// Task item displayed in ongoing tasks list with full expandable details
class TaskItem {
  final String id;
  final String title;
  final String? subtitle;
  final String dueBadge;
  final Color dueColor;
  final Color dueTextColor;
  final bool isUrgent;
  final List<Color>? members;
  final double? progress;
  final String deadline;
  final List<TaskTag> tags;
  final List<String> groupMembers;
  final String course;
  final String dateCreated;
  final String centroidDefuzzification;
  final String centroidScale;
  final String warningNotice;
  final String notes;
  final bool isCollegeTask;

  const TaskItem({
    this.id = '',
    required this.title,
    this.subtitle,
    required this.dueBadge,
    required this.dueColor,
    required this.dueTextColor,
    required this.isUrgent,
    this.members,
    this.progress,
    required this.deadline,
    required this.tags,
    this.groupMembers = const [
      'Andi sukamoto (Leader)',
      'Rayya Gemintang Nusasntarra',
      'Kafi Rijal Perkasa Situmorang',
    ],
    this.course = 'SSIF-04-REG • Software Testing & Implementation',
    this.dateCreated = 'Monday, 30 Sep 2026',
    this.centroidDefuzzification = 'z* = 28.6',
    this.centroidScale = 'scale(0-100)',
    this.warningNotice = '*This task is asigned to you, and you can’t delete',
    this.notes = '',
    this.isCollegeTask = true,
  });

  bool get isTeamTask =>
      (members != null && members!.isNotEmpty) ||
      tags.any((t) => t.label.trim().toLowerCase() == 'kelompok') ||
      groupMembers.length > 1;

  TaskItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? dueBadge,
    Color? dueColor,
    Color? dueTextColor,
    bool? isUrgent,
    List<Color>? members,
    double? progress,
    String? deadline,
    List<TaskTag>? tags,
    List<String>? groupMembers,
    String? course,
    String? dateCreated,
    String? centroidDefuzzification,
    String? centroidScale,
    String? warningNotice,
    String? notes,
    bool? isCollegeTask,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      dueBadge: dueBadge ?? this.dueBadge,
      dueColor: dueColor ?? this.dueColor,
      dueTextColor: dueTextColor ?? this.dueTextColor,
      isUrgent: isUrgent ?? this.isUrgent,
      members: members ?? this.members,
      progress: progress ?? this.progress,
      deadline: deadline ?? this.deadline,
      tags: tags ?? this.tags,
      groupMembers: groupMembers ?? this.groupMembers,
      course: course ?? this.course,
      dateCreated: dateCreated ?? this.dateCreated,
      centroidDefuzzification: centroidDefuzzification ?? this.centroidDefuzzification,
      centroidScale: centroidScale ?? this.centroidScale,
      warningNotice: warningNotice ?? this.warningNotice,
      notes: notes ?? this.notes,
      isCollegeTask: isCollegeTask ?? this.isCollegeTask,
    );
  }

  TaskItemModel toTaskItemModel() {
    return TaskItemModel(
      id: id.isNotEmpty ? id : 'task_${title.hashCode}',
      title: title,
      subtitle: subtitle,
      priority: isUrgent ? TaskPriorityLevel.high : TaskPriorityLevel.medium,
      durationBadge: dueBadge,
      durationBadgeColor: dueColor,
      durationTextColor: dueTextColor,
      formattedDeadline: deadline,
      deadlineDate: DateTime(2026, 10, 11, 23, 59),
      memberAvatars: members ?? const [],
      progressPercent: progress != null ? (progress! * 100).toInt() : null,
      tags: tags.map((t) => TaskTagModel(label: t.label, backgroundColor: t.bg, textColor: t.text)).toList(),
      groupMembers: groupMembers,
      course: course,
      dateCreated: dateCreated,
      centroidDefuzzification: centroidDefuzzification,
      centroidScale: centroidScale,
      warningNotice: warningNotice,
      notes: notes,
      isCollegeTask: isCollegeTask,
    );
  }

  factory TaskItem.fromTaskItemModel(TaskItemModel model) {
    return TaskItem(
      id: model.id,
      title: model.title,
      subtitle: model.subtitle,
      dueBadge: model.durationBadge,
      dueColor: model.durationBadgeColor,
      dueTextColor: model.durationTextColor,
      isUrgent: model.priority == TaskPriorityLevel.high,
      members: model.memberAvatars,
      progress: model.progressPercent != null ? (model.progressPercent! / 100.0) : null,
      deadline: model.formattedDeadline,
      tags: model.tags.map((t) => TaskTag(label: t.label, bg: t.backgroundColor, text: t.textColor)).toList(),
      groupMembers: model.groupMembers,
      course: model.course,
      dateCreated: model.dateCreated,
      centroidDefuzzification: model.centroidDefuzzification,
      centroidScale: model.centroidScale,
      warningNotice: model.warningNotice,
      notes: model.notes,
      isCollegeTask: model.isCollegeTask,
    );
  }
}

/// Tag label associated with a task
class TaskTag {
  final String label;
  final Color bg;
  final Color text;

  const TaskTag({
    required this.label,
    required this.bg,
    required this.text,
  });
}

