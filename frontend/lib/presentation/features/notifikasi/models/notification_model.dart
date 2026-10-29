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
    this.isRead = false,
  });

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
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
      isRead: isRead ?? this.isRead,
    );
  }
}

