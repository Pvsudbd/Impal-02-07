import 'dart:convert';
import 'package:flutter/material.dart';

class ScheduleModel {
  final String id;
  final String title;
  final String type; // 'Lecture' or 'External'
  final String? course;
  final String? location;
  final String status; // 'Ongoing', 'Upcoming', 'Completed'
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
    this.status = 'Upcoming',
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    this.timeZone = 'WIB',
    this.notes,
    this.repeat = false,
  });

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
      status: status ?? this.status,
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
    if (status.toLowerCase() == 'ongoing') {
      return const Color(0xFFFF826E); // Primary coral accent
    }
    if (status.toLowerCase() == 'upcoming') {
      return const Color(0xFF8E95A5); // Upcoming slate accent
    }
    if (type.toLowerCase() == 'lecture') {
      return const Color(0xFFFF826E);
    }
    return const Color(0xFF8FC7FF); // External blue accent
  }

  Color get statusColor {
    if (status.toLowerCase() == 'ongoing') {
      return const Color(0xFFFF826E);
    }
    return const Color(0xFF8E95A5);
  }
}
