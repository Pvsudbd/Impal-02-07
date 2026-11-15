import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import 'schedule_model.dart';

class ScheduleRepository {
  static final ScheduleRepository _instance = ScheduleRepository._internal();
  factory ScheduleRepository() => _instance;
  ScheduleRepository._internal();

  static const String _storageKey = 'saved_schedules_v1';

  final ValueNotifier<List<ScheduleModel>> schedulesNotifier =
      ValueNotifier<List<ScheduleModel>>(_defaultSchedules);

  bool _initialized = false;

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (_) {
      return null;
    }
  }

  /// Sinkronisasi data jadwal terbaru dari Backend API
  Future<void> fetchSchedulesFromApi() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    try {
      final response = await ApiClient.get('/api/agenda', token: token);
      if (response['status'] == 'success' && response['data'] is List) {
        final List<dynamic> rawList = response['data'];
        final list = rawList
            .map((item) => ScheduleModel.fromMap(item as Map<String, dynamic>))
            .toList();
        schedulesNotifier.value = list;
        await _persist();
      }
    } catch (e) {
      debugPrint('[SCHEDULE_REPO] fetchSchedulesFromApi error: $e');
    }
  }

  Future<void> init() async {
    if (_initialized) {
      await fetchSchedulesFromApi();
      return;
    }
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
      } catch (_) {
        schedulesNotifier.value = _defaultSchedules;
      }
    } else {
      schedulesNotifier.value = _defaultSchedules;
    }

    // Ambil data terbaru dari backend MySQL
    await fetchSchedulesFromApi();
  }

  List<ScheduleModel> get schedules => schedulesNotifier.value;

  ScheduleModel? getById(String id) {
    try {
      return schedulesNotifier.value.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addSchedule(ScheduleModel item) async {
    // 1. Optimistic update tampilan lokal
    final current = List<ScheduleModel>.from(schedulesNotifier.value);
    current.insert(0, item);
    schedulesNotifier.value = current;
    await _persist();

    // 2. Kirim dan simpan ke Backend API & MySQL
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      try {
        String dayName(DateTime dt) {
          const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
          return days[dt.weekday - 1];
        }

        final isCourse = item.type.toLowerCase() == 'lecture';
        final isMeeting = item.type.toLowerCase() == 'meeting';
        final body = {
          'id': item.id,
          'title': item.title,
          'type': item.type,
          'agendaType': isCourse ? 'COURSE' : 'PERSONAL',
          'timeStart': item.timeStart,
          'timeEnd': item.timeEnd,
          'date': item.date.toIso8601String(),
          'courseCode': item.course ?? item.title,
          'day': dayName(item.date),
          'room': item.location ?? 'Classroom',
          'category': isCourse ? 'Kuliah' : (isMeeting ? 'Meeting' : 'External'),
          'location': item.location ?? '',
          'notes': item.notes ?? '',
          if (item.meetingUrl != null && item.meetingUrl!.isNotEmpty) 'meetingUrl': item.meetingUrl,
          if (item.teamName != null && item.teamName!.isNotEmpty) 'teamName': item.teamName,
        };

        final response = await ApiClient.post('/api/agenda', body, token: token);
        if (response['status'] == 'success' && response['data'] != null) {
          final serverItem = ScheduleModel.fromMap(response['data'] as Map<String, dynamic>);
          final updatedList = List<ScheduleModel>.from(schedulesNotifier.value);
          final idx = updatedList.indexWhere((s) => s.id == item.id);
          if (idx != -1) {
            updatedList[idx] = serverItem;
            schedulesNotifier.value = updatedList;
            await _persist();
          }
        }
      } catch (e) {
        debugPrint('[SCHEDULE_REPO] addSchedule API error: $e');
      }
    }
  }

  Future<void> updateSchedule(ScheduleModel item) async {
    // 1. Optimistic update tampilan lokal
    final current = List<ScheduleModel>.from(schedulesNotifier.value);
    final index = current.indexWhere((s) => s.id == item.id);
    if (index != -1) {
      current[index] = item;
      schedulesNotifier.value = current;
      await _persist();
    }

    // 2. Kirim update ke Backend API & MySQL
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      try {
        String dayName(DateTime dt) {
          const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
          return days[dt.weekday - 1];
        }

        final isCourse = item.type.toLowerCase() == 'lecture';
        final isMeeting = item.type.toLowerCase() == 'meeting';
        final body = {
          'id': item.id,
          'title': item.title,
          'type': item.type,
          'agendaType': isCourse ? 'COURSE' : 'PERSONAL',
          'timeStart': item.timeStart,
          'timeEnd': item.timeEnd,
          'date': item.date.toIso8601String(),
          'courseCode': item.course ?? item.title,
          'day': dayName(item.date),
          'room': item.location ?? 'Classroom',
          'category': isCourse ? 'Kuliah' : (isMeeting ? 'Meeting' : 'External'),
          'location': item.location ?? '',
          'notes': item.notes ?? '',
          if (item.meetingUrl != null && item.meetingUrl!.isNotEmpty) 'meetingUrl': item.meetingUrl,
          if (item.teamName != null && item.teamName!.isNotEmpty) 'teamName': item.teamName,
        };

        await ApiClient.put('/api/agenda/${item.id}', body, token: token);
      } catch (e) {
        debugPrint('[SCHEDULE_REPO] updateSchedule API error: $e');
      }
    }
  }

  Future<void> deleteSchedule(String id) async {
    // 1. Optimistic delete tampilan lokal
    final current = List<ScheduleModel>.from(schedulesNotifier.value);
    current.removeWhere((s) => s.id == id);
    schedulesNotifier.value = current;
    await _persist();

    // 2. Hapus di Backend API & MySQL
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await ApiClient.delete('/api/agenda/$id', token: token);
      } catch (e) {
        debugPrint('[SCHEDULE_REPO] deleteSchedule API error: $e');
      }
    }
  }

  void resetToDefault() {
    schedulesNotifier.value = _defaultSchedules;
  }

  /// Detects whether a proposed schedule overlaps in time with any existing schedule on the same date.
  /// Returns a list of all conflicting schedules.
  List<ScheduleModel> findConflicts({
    required DateTime date,
    required String timeStart,
    required String timeEnd,
    String? excludeId,
  }) {
    final startMinutes = _timeStringToMinutes(timeStart);
    final endMinutes = _timeStringToMinutes(timeEnd);
    if (startMinutes == null || endMinutes == null) return [];

    return schedulesNotifier.value.where((s) {
      if (excludeId != null && s.id == excludeId) return false;
      // Must be on the exact same calendar day
      if (s.date.year != date.year ||
          s.date.month != date.month ||
          s.date.day != date.day) {
        return false;
      }
      final sStart = _timeStringToMinutes(s.timeStart);
      final sEnd = _timeStringToMinutes(s.timeEnd);
      if (sStart == null || sEnd == null) return false;

      // Interval overlap: (startA < endB) && (endA > startB)
      return startMinutes < sEnd && endMinutes > sStart;
    }).toList();
  }

  static int? _timeStringToMinutes(String timeStr) {
    try {
      final parts = timeStr.trim().split(':');
      if (parts.length < 2) return null;
      final h = int.parse(parts[0].trim());
      final m = int.parse(parts[1].trim().split(' ')[0]);
      return h * 60 + m;
    } catch (_) {
      return null;
    }
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
      notes: 'Discussion on frontend and backend integration continuation for sprint 2',
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
        title: 'UBXCCB2 - LINGUISTICS & COMMUNICATION',
        type: 'Lecture',
        course: 'UBXCCB2 • LINGUISTICS & COMMUNICATION',
        location: 'KTT B-106 • SSIF-04-REG-GAB02',
        status: 'Overdue',
        date: now,
        timeStart: fmt(morningStart),
        timeEnd: fmt(morningEnd),
        notes: 'Lecture 7: Bibliography and Citation Formatting',
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
        notes: 'Flutter Unit Testing & Integration Testing Lab',
        repeat: true,
      ),
      defaultTeamSchedule,
      ScheduleModel(
        id: 'sch_4',
        title: 'IMPAL Project Mentoring',
        type: 'External',
        location: 'Building B Conference Room, 2nd Floor',
        status: 'Upcoming',
        date: now.add(const Duration(days: 1)),
        timeStart: '10:00',
        timeEnd: '11:30',
        notes: 'Weekly sprint progress report with lab assistant',
        repeat: false,
      ),
      ScheduleModel(
        id: 'sch_5',
        title: 'Advanced Calculus - Tutorial',
        type: 'Lecture',
        course: 'Advanced Calculus',
        location: 'KTT A-101 • Academic Hall',
        status: 'Upcoming',
        date: now.add(const Duration(days: 4)),
        timeStart: '08:00',
        timeEnd: '10:00',
        notes: 'Problem set practice for multiple integrals quiz 2',
        repeat: true,
      ),
    ];
  }
}
