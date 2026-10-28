import 'package:flutter/material.dart';
import '../../schedule/models/schedule_model.dart';

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

/// Task item displayed in ongoing tasks list
class TaskItem {
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

  const TaskItem({
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
  });
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

