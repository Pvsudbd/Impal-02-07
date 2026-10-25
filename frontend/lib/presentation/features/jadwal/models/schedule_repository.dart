import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'schedule_model.dart';

class ScheduleRepository {
  static final ScheduleRepository _instance = ScheduleRepository._internal();
  factory ScheduleRepository() => _instance;
  ScheduleRepository._internal();

  static const String _storageKey = 'saved_schedules_v1';

  final ValueNotifier<List<ScheduleModel>> schedulesNotifier =
      ValueNotifier<List<ScheduleModel>>(_defaultSchedules);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = json.decode(raw);
        schedulesNotifier.value = list
            .map((item) =>
                ScheduleModel.fromMap(item as Map<String, dynamic>))
            .toList();
        return;
      } catch (_) {
        // Fallback to default
      }
    }

    schedulesNotifier.value = _defaultSchedules;
    await _persist();
  }

  List<ScheduleModel> get schedules => schedulesNotifier.value;

  Future<void> addSchedule(ScheduleModel item) async {
    final current = List<ScheduleModel>.from(schedulesNotifier.value);
    current.insert(0, item);
    schedulesNotifier.value = current;
    await _persist();
  }

  Future<void> updateSchedule(ScheduleModel item) async {
    final current = List<ScheduleModel>.from(schedulesNotifier.value);
    final index = current.indexWhere((s) => s.id == item.id);
    if (index != -1) {
      current[index] = item;
      schedulesNotifier.value = current;
      await _persist();
    }
  }

  Future<void> deleteSchedule(String id) async {
    final current = List<ScheduleModel>.from(schedulesNotifier.value);
    current.removeWhere((s) => s.id == id);
    schedulesNotifier.value = current;
    await _persist();
  }

  void resetToDefault() {
    schedulesNotifier.value = _defaultSchedules;
  }

  static ScheduleModel get defaultTeamSchedule {
    final now = DateTime.now();
    return ScheduleModel(
      id: 'sch_3',
      title: 'MEETING IMPAL',
      type: 'External',
      location: 'Discord - Group IMPAL',
      status: 'Upcoming',
      date: now.add(const Duration(days: 1)),
      timeStart: '19:00',
      timeEnd: '20:30',
      timeZone: 'WIB',
      notes: 'Diskusi kelanjutan integrasi frontend dan backend sprint 2',
      repeat: false,
    );
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = schedulesNotifier.value.map((s) => s.toMap()).toList();
      await prefs.setString(_storageKey, json.encode(list));
    } catch (_) {}
  }

  static List<ScheduleModel> get _defaultSchedules {
    final now = DateTime.now();

    String fmt(DateTime dt) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }

    final morningStart = now.subtract(const Duration(hours: 3));
    final morningEnd = now.subtract(const Duration(hours: 1));
    final ongoingStart = now.subtract(const Duration(minutes: 30));
    final ongoingEnd = now.add(const Duration(minutes: 90));

    return [
      ScheduleModel(
        id: 'sch_1',
        title: 'UBXCCB2 - BAHASA INDONESIA',
        type: 'Lecture',
        course: 'UBXCCB2 • BAHASA INDONESIA',
        location: 'KTT B-106 • SSIF-04-REG-GAB02',
        status: 'Completed',
        date: now,
        timeStart: fmt(morningStart),
        timeEnd: fmt(morningEnd),
        notes: 'Pertemuan 7: Penulisan Daftar Pustaka dan Sitasi',
        repeat: true,
      ),
      ScheduleModel(
        id: 'sch_2',
        title: 'SSIF-04-REG • Software Testing & Implementation',
        type: 'Lecture',
        course: 'SSIF-04-REG • Software Testing & Implementation',
        location: 'Lab 3 • Gedung TULT 05.02',
        status: 'Ongoing',
        date: now,
        timeStart: fmt(ongoingStart),
        timeEnd: fmt(ongoingEnd),
        notes: 'Praktikum Unit Testing & Integration Testing Flutter',
        repeat: true,
      ),
      defaultTeamSchedule,
      ScheduleModel(
        id: 'sch_4',
        title: 'Mentoring Proyek Impal',
        type: 'External',
        location: 'Ruang Rapat Gedung B Lantai 2',
        status: 'Upcoming',
        date: now.add(const Duration(days: 1)),
        timeStart: '10:00',
        timeEnd: '11:30',
        notes: 'Progress report sprint mingguan bersama asisten lab',
        repeat: false,
      ),
      ScheduleModel(
        id: 'sch_5',
        title: 'Kalkulus Lanjut - Tutorial',
        type: 'Lecture',
        course: 'Kalkulus Lanjut',
        location: 'KTT A-101 • Gedung Kuliah',
        status: 'Upcoming',
        date: now.add(const Duration(days: 4)),
        timeStart: '08:00',
        timeEnd: '10:00',
        notes: 'Latihan soal persiapan kuis 2 integral lipat',
        repeat: true,
      ),
    ];
  }
}
