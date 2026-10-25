import 'dart:convert';
import 'package:flutter/material.dart';

class ScheduleModel {
  final String id;
  final String title;
  final String type; // 'Lecture' or 'External'
  final String? course;
  final String? location;
  final DateTime date;
  final String timeStart; // '09:30'
  final String timeEnd; // '11:30'
  final String timeZone; // 'WIB'
  final String? notes;
  final bool repeat;

  const ScheduleModel({
    required this.id,
    required this.title,
    required this.type,
    this.course,
    this.location,
    String? status,
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    this.timeZone = 'WIB',
    this.notes,
    this.repeat = false,
  });

  /// Automatically computes the schedule status ('Ongoing', 'Upcoming', 'Overdue')
  /// based on [date], [timeStart], [timeEnd], and [DateTime.now()].
  String get status => calculateStatus(
        date: date,
        timeStart: timeStart,
        timeEnd: timeEnd,
      );

  /// Evaluates status with an optional custom [now] time for testing or time-travel.
  String getStatusAt([DateTime? now]) => calculateStatus(
        date: date,
        timeStart: timeStart,
        timeEnd: timeEnd,
        now: now,
      );

  /// Pure static method to calculate status given date and time range:
  /// - 'Ongoing' if current date & time is within [startDateTime, endDateTime]
  /// - 'Upcoming' if date & time has not arrived yet (in the future)
  /// - 'Overdue' if date & time has already passed
  static String calculateStatus({
    required DateTime date,
    required String timeStart,
    required String timeEnd,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    try {
      final start = _parseTimeString(timeStart);
      final end = _parseTimeString(timeEnd);

      final startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        start.hour,
        start.minute,
      );

      var endDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        end.hour,
        end.minute,
      );

      // Handle overnight schedules (e.g. 23:00 - 01:00)
      if (endDateTime.isBefore(startDateTime)) {
        endDateTime = endDateTime.add(const Duration(days: 1));
      }

      if (current.isBefore(startDateTime)) {
        return 'Upcoming';
      } else if (current.isAfter(endDateTime)) {
        return 'Overdue';
      } else {
        return 'Ongoing';
      }
    } catch (_) {
      final today = DateTime(current.year, current.month, current.day);
      final scheduleDate = DateTime(date.year, date.month, date.day);
      if (scheduleDate.isBefore(today)) {
        return 'Overdue';
      } else if (scheduleDate.isAfter(today)) {
        return 'Upcoming';
      }
      return 'Ongoing';
    }
  }

  static TimeOfDay _parseTimeString(String str) {
    final clean = str.trim();
    final parts = clean.contains(':') ? clean.split(':') : clean.split('.');
    if (parts.length >= 2) {
      return TimeOfDay(
        hour: int.parse(parts[0].trim()),
        minute: int.parse(parts[1].trim()),
      );
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  DateTime? get startDateTime {
    try {
      final start = _parseTimeString(timeStart);
      return DateTime(date.year, date.month, date.day, start.hour, start.minute);
    } catch (_) {
      return null;
    }
  }

  DateTime? get endDateTime {
    try {
      final start = _parseTimeString(timeStart);
      final end = _parseTimeString(timeEnd);
      var endDt = DateTime(date.year, date.month, date.day, end.hour, end.minute);
      final startDt = DateTime(date.year, date.month, date.day, start.hour, start.minute);
      if (endDt.isBefore(startDt)) {
        endDt = endDt.add(const Duration(days: 1));
      }
      return endDt;
    } catch (_) {
      return null;
    }
  }

  ScheduleModel copyWith({
    String? id,
    String? title,
    String? type,
    String? course,
    String? location,
    String? status,
    DateTime? date,
    String? timeStart,
    String? timeEnd,
    String? timeZone,
    String? notes,
    bool? repeat,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      course: course ?? this.course,
      location: location ?? this.location,
      status: status,
      date: date ?? this.date,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      timeZone: timeZone ?? this.timeZone,
      notes: notes ?? this.notes,
      repeat: repeat ?? this.repeat,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'course': course,
      'location': location,
      'status': status,
      'date': date.toIso8601String(),
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'timeZone': timeZone,
      'notes': notes,
      'repeat': repeat,
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? 'Lecture',
      course: map['course'],
      location: map['location'],
      status: map['status'] ?? 'Upcoming',
      date: map['date'] != null
          ? (DateTime.tryParse(map['date']) ?? DateTime.now())
          : DateTime.now(),
      timeStart: map['timeStart'] ?? '09:30',
      timeEnd: map['timeEnd'] ?? '11:30',
      timeZone: map['timeZone'] ?? 'WIB',
      notes: map['notes'],
      repeat: map['repeat'] == true,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScheduleModel.fromJson(String source) =>
      ScheduleModel.fromMap(json.decode(source));

  String get formattedTime => '$timeStart - $timeEnd $timeZone';

  Color get accentColor {
    final s = status.toLowerCase();
    if (s == 'ongoing') {
      return const Color(0xFFFF826E); // Primary coral accent
    }
    if (s == 'overdue' || s == 'completed') {
      return const Color(0xFF8E95A5); // Overdue slate gray accent (same as upcoming)
    }
    if (s == 'upcoming') {
      return const Color(0xFF8E95A5); // Upcoming slate accent
    }
    if (type.toLowerCase() == 'lecture') {
      return const Color(0xFFFF826E);
    }
    return const Color(0xFF8FC7FF); // External blue accent
  }

  Color get statusColor {
    final s = status.toLowerCase();
    if (s == 'ongoing') {
      return const Color(0xFFFF826E);
    }
    if (s == 'overdue' || s == 'completed' || s == 'upcoming') {
      return const Color(0xFF8E95A5); // Overdue & Upcoming slate gray
    }
    return const Color(0xFF8E95A5);
  }
}
