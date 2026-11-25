import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../schedule/models/schedule_model.dart';
import '../../task/models/task_item_model.dart';
import '../../task/models/task_repository.dart';
import 'team_milestone_model.dart';
import 'team_task_model.dart';

export 'team_milestone_model.dart';

/// Centralized in-memory repository managing team tasks and milestones for team dashboards.
///
/// Follows singleton pattern with ChangeNotifier, automatically synchronizing
/// team project progress and completion with [TaskRepository].
class TeamTaskRepository with ChangeNotifier {
  static final TeamTaskRepository _instance = TeamTaskRepository._internal();
  factory TeamTaskRepository() => _instance;
  TeamTaskRepository._internal();

  final Map<String, List<TeamTaskModel>> _teamTasks = {};
  final Map<String, List<TeamMilestoneModel>> _teamMilestones = {};
  final Map<String, List<ScheduleModel>> _teamMeetings = {};
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _teamTasks.clear();
    _teamMilestones.clear();
    _teamMeetings.clear();
    _seedDefaultFixtures();
    _initialized = true;
  }

  void _seedDefaultFixtures() {
    final now = DateTime.now();
    _teamMeetings['7X29'] = [
      ScheduleModel(
        id: 'sch_4',
        title: 'IMPAL Project Mentoring',
        type: 'External',
        course: 'IMPAL Project Mentoring',
        location: 'Discord - Group IMPAL',
        status: 'Upcoming',
        date: now.add(const Duration(days: 1)),
        timeStart: '10:00',
        timeEnd: '11:30',
        timeZone: 'WIB',
        notes: 'Discussion with lab assistant about architecture',
        repeat: false,
        teamName: 'Group IMPAL',
      ),
      ScheduleModel(
        id: 'sch_3',
        title: 'MEETING IMPAL',
        type: 'External',
        location: 'Discord - Group IMPAL',
        status: 'Ongoing',
        date: now,
        timeStart: '19:00',
        timeEnd: '20:30',
        timeZone: 'WIB',
        notes: 'Discussion on frontend and backend integration continuation for sprint 2',
        repeat: false,
        teamName: 'Group IMPAL',
      ),
    ];
    _teamTasks['7X29'] = [
      const TeamTaskModel(
        id: 'task_1',
        title: 'Create team UI page',
        priority: TaskPriority.high,
        assignedTo: 'Yoga Perkasa Didik',
        assigneeColor: Color(0xFFF3A683),
        timeRange: '09:30 - 11:30 WIB',
        dueBadge: '12h',
        isDone: false,
      ),
      const TeamTaskModel(
        id: 'task_2',
        title: 'Create home UI page',
        priority: TaskPriority.medium,
        assignedTo: 'Ahmad Sahroni, Muhammad Kafi Rijal',
        assigneeColor: Color(0xFF63CDDA),
        assigneeColors: [Color(0xFF63CDDA), Color(0xFF786FA6)],
        timeRange: '09:30 - 11:30 WIB',
        dueBadge: '18h',
        isDone: false,
      ),
      const TeamTaskModel(
        id: 'task_3',
        title: 'Create task form UI',
        priority: TaskPriority.low,
        assignedTo: 'Yoga Perkasa Didik',
        assigneeColor: Color(0xFFF3A683),
        timeRange: '09:30 - 11:30 WIB',
        dueBadge: '2d',
        isDone: false,
      ),
    ];

    _teamMilestones['7X29'] = [
      TeamMilestoneModel(
        id: 'milestone_1',
        teamCode: '7X29',
        title: 'Responsi 1 - UI & Architecture',
        description: 'Implementation of team dashboard layout and responsiveness.',
        deadline: DateTime(2026, 10, 18, 23, 59),
        formattedDeadline: 'Sat 18 Oct 2026, 23: 59 WIB',
        dueBadge: '6d',
        taskIds: const ['task_1', 'task_2'],
        dateCreated: DateTime(2026, 10, 1),
      ),
    ];
  }

  /// Resets repository to default mock fixtures (useful for unit tests).
  void resetToDefaults() {
    _initialized = false;
    _teamTasks.clear();
    _teamMilestones.clear();
    _teamMeetings.clear();
    _seedDefaultFixtures();
    _initialized = true;
    _syncWithTaskRepository('7X29');
    notifyListeners();
  }

  /// Returns unmodifiable list of meetings for given team code or name.
  List<ScheduleModel> getMeetings(String teamCode) {
    init();
    final clean = teamCode.trim();
    if (clean.isEmpty) return const [];
    if (_teamMeetings.containsKey(clean) && _teamMeetings[clean]!.isNotEmpty) {
      return List.unmodifiable(_teamMeetings[clean]!);
    }
    for (final entry in _teamMeetings.entries) {
      if (entry.key.toLowerCase() == clean.toLowerCase() && entry.value.isNotEmpty) {
        _teamMeetings[clean] = entry.value;
        return List.unmodifiable(entry.value);
      }
    }
    final cleanUpper = clean.toUpperCase();
    if (cleanUpper == '7X29' || clean.toLowerCase().contains('impal')) {
      return List.unmodifiable(_teamMeetings['7X29'] ?? const []);
    }
    return const [];
  }

  /// Returns all meetings across all registered teams.
  List<ScheduleModel> get allMeetings {
    init();
    final list = <ScheduleModel>[];
    for (final mList in _teamMeetings.values) {
      for (final m in mList) {
        if (!list.any((existing) => existing.id == m.id)) {
          list.add(m);
        }
      }
    }
    return List.unmodifiable(list);
  }

  /// Returns all loaded team tasks across all teams without altering initialization state.
  List<TeamTaskModel> get allTasks {
    final list = <TeamTaskModel>[];
    for (final tList in _teamTasks.values) {
      for (final t in tList) {
        if (!list.any((existing) => existing.id == t.id)) {
          list.add(t);
        }
      }
    }
    return List.unmodifiable(list);
  }

  /// Sinkronisasi daftar meeting dari remote PostgreSQL (/api/groups/<teamCode>/meetings)
  Future<List<ScheduleModel>> fetchMeetingsFromApi(
    String teamCode, {
    String? targetTeamName,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return getMeetings(teamCode);
    }

    try {
      final encodedCode = Uri.encodeComponent(teamCode.trim());
      final res = await ApiClient.get(
        '/api/groups/$encodedCode/meetings',
        token: token,
      );

      if (res['status'] == 'success' && res['data'] is List) {
        final List<dynamic> raw = res['data'];
        final resolvedTeam = targetTeamName?.trim().isNotEmpty == true
            ? targetTeamName!.trim()
            : teamCode.trim();

        final fetched = <ScheduleModel>[];
        for (final item in raw) {
          if (item is! Map) continue;
          final row = Map<String, dynamic>.from(item);
          final idMeeting =
              (row['id_meeting'] ?? row['id'])?.toString() ?? '';
          if (idMeeting.isEmpty) continue;

          final title = (row['meeting_title'] ?? row['title'])?.toString() ??
              'Team Meeting';
          final desc =
              (row['description'] ?? row['notes'])?.toString() ?? '';
          final rawTime =
              (row['start_time'] ?? row['date'])?.toString() ?? '';
          final parsedDate = DateTime.tryParse(rawTime) ?? DateTime.now();
          final loc = (row['platform_location'] ?? row['location'])?.toString() ??
              'Online / Google Meet';

          final timeStart =
              '${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
          final endDt = parsedDate.add(const Duration(hours: 1));
          final timeEnd =
              '${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}';

          final isVirtual = loc.startsWith('http') ||
              loc.toLowerCase().contains('discord') ||
              loc.toLowerCase().contains('meet') ||
              loc.toLowerCase().contains('zoom');

          fetched.add(
            ScheduleModel(
              id: idMeeting,
              title: title,
              type: 'Meeting',
              teamName: resolvedTeam,
              location: loc,
              meetingUrl: isVirtual ? loc : null,
              notes: desc,
              date: parsedDate,
              timeStart: timeStart,
              timeEnd: timeEnd,
              timeZone: 'WIB',
              repeat: false,
            ),
          );
        }

        _teamMeetings[teamCode.trim()] = fetched;
        if (targetTeamName != null &&
            targetTeamName.trim().isNotEmpty &&
            targetTeamName.trim() != teamCode.trim()) {
          _teamMeetings[targetTeamName.trim()] = fetched;
        }
        notifyListeners();
        return fetched;
      }
    } catch (e) {
      debugPrint('[TEAM_TASK_REPO] fetchMeetingsFromApi error: $e');
    }
    return getMeetings(teamCode);
  }

  /// Tambah meeting baru ke repository kelompok dan simpan ke database remote PostgreSQL
  Future<void> addMeeting(String teamCode, ScheduleModel meeting) async {
    init();
    final cleanCode = teamCode.trim();
    final list = List<ScheduleModel>.from(_teamMeetings[cleanCode] ?? []);
    final idx = list.indexWhere((m) => m.id == meeting.id);
    if (idx != -1) {
      list[idx] = meeting;
    } else {
      list.insert(0, meeting);
    }
    _teamMeetings[cleanCode] = list;
    if (meeting.teamName != null &&
        meeting.teamName!.trim().isNotEmpty &&
        meeting.teamName!.trim() != cleanCode) {
      _teamMeetings[meeting.teamName!.trim()] = list;
    }
    notifyListeners();

    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final encodedCode = Uri.encodeComponent(cleanCode);
        final startDt = meeting.startDateTime ?? meeting.date;
        final body = {
          'id': meeting.id,
          'id_meeting': meeting.id,
          'meeting_title': meeting.title,
          'description': meeting.notes ?? '',
          'start_time': startDt.toIso8601String(),
          'platform_location': meeting.meetingUrl ??
              (meeting.location?.trim().isNotEmpty == true
                  ? meeting.location!.trim()
                  : 'Online / Google Meet'),
        };
        await ApiClient.post(
          '/api/groups/$encodedCode/meetings',
          body,
          token: token,
        );
      } catch (e) {
        debugPrint('[TEAM_TASK_REPO] addMeeting API error: $e');
      }
    }
  }

  /// Update meeting kelompok dan sinkronisasi ke PostgreSQL
  Future<void> updateMeeting(String teamCode, ScheduleModel meeting) async {
    init();
    final cleanCode = teamCode.trim();
    final list = List<ScheduleModel>.from(_teamMeetings[cleanCode] ?? []);
    final idx = list.indexWhere((m) => m.id == meeting.id);
    if (idx != -1) {
      list[idx] = meeting;
      _teamMeetings[cleanCode] = list;
      if (meeting.teamName != null &&
          meeting.teamName!.trim().isNotEmpty &&
          meeting.teamName!.trim() != cleanCode) {
        _teamMeetings[meeting.teamName!.trim()] = list;
      }
      notifyListeners();
    }

    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final encodedCode = Uri.encodeComponent(cleanCode);
        final startDt = meeting.startDateTime ?? meeting.date;
        final body = {
          'id_meeting': meeting.id,
          'meeting_title': meeting.title,
          'description': meeting.notes ?? '',
          'start_time': startDt.toIso8601String(),
          'platform_location': meeting.meetingUrl ??
              (meeting.location?.trim().isNotEmpty == true
                  ? meeting.location!.trim()
                  : 'Online / Google Meet'),
        };
        await ApiClient.put(
          '/api/groups/$encodedCode/meetings/${Uri.encodeComponent(meeting.id)}',
          body,
          token: token,
        );
      } catch (e) {
        debugPrint('[TEAM_TASK_REPO] updateMeeting API error: $e');
      }
    }
  }

  /// Hapus meeting kelompok dan sinkronisasi ke PostgreSQL
  Future<void> deleteMeeting(String teamCode, String idMeeting) async {
    init();
    final cleanCode = teamCode.trim();
    final list = List<ScheduleModel>.from(_teamMeetings[cleanCode] ?? []);
    list.removeWhere((m) => m.id == idMeeting);
    _teamMeetings[cleanCode] = list;
    notifyListeners();

    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final encodedCode = Uri.encodeComponent(cleanCode);
        await ApiClient.delete(
          '/api/groups/$encodedCode/meetings/${Uri.encodeComponent(idMeeting)}',
          token: token,
        );
      } catch (e) {
        debugPrint('[TEAM_TASK_REPO] deleteMeeting API error: $e');
      }
    }
  }

  /// Returns unmodifiable list of tasks for given team code.
  List<TeamTaskModel> getTasks(String teamCode) {
    init();
    return List.unmodifiable(_teamTasks[teamCode] ?? []);
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token') ?? prefs.getString('jwt_token');
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveMilestonesToLocal(String teamCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _teamMilestones[teamCode] ?? [];
      final encoded = jsonEncode(list.map((m) => m.toMap()).toList());
      await prefs.setString('offline_milestones_$teamCode', encoded);
      for (final m in list) {
        if (m.teamCode.isNotEmpty && m.teamCode != teamCode) {
          await prefs.setString('offline_milestones_${m.teamCode}', encoded);
        }
      }
    } catch (e) {
      debugPrint('[TEAM_TASK_REPO] _saveMilestonesToLocal error: $e');
    }
  }

  Future<void> _loadMilestonesFromLocal(String teamCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? raw = prefs.getString('offline_milestones_$teamCode');
      if (raw == null || raw.isEmpty) {
        // Fallback: search any offline_milestones_* keys in prefs
        final allKeys = prefs.getKeys().where((k) => k.startsWith('offline_milestones_'));
        for (final k in allKeys) {
          final val = prefs.getString(k);
          if (val != null && val.contains(teamCode)) {
            raw = val;
            break;
          }
        }
      }
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        final list = decoded
            .map((item) => TeamMilestoneModel.fromMap(item as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          _teamMilestones[teamCode] = list;
          for (final m in list) {
            if (m.teamCode.isNotEmpty && m.teamCode != teamCode) {
              _teamMilestones[m.teamCode] = list;
            }
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[TEAM_TASK_REPO] _loadMilestonesFromLocal error: $e');
    }
  }

  /// Sinkronisasi daftar task dari Backend API (GET /api/groups/<teamCode>/tasks).
  /// Offline-first: data lama tetap tampil jika request gagal.
  Future<List<TeamTaskModel>> fetchTasksFromApi(String teamCode) async {
    init();
    if (teamCode.trim().isEmpty) return [];

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return List.unmodifiable(_teamTasks[teamCode] ?? []);
    }

    try {
      final encodedCode = Uri.encodeComponent(teamCode.trim());
      final res = await ApiClient.get('/api/groups/$encodedCode/tasks', token: token);
      if (res['status'] == 'success' && res['data'] is List) {
        final List<dynamic> raw = res['data'];
        final fetched = <TeamTaskModel>[];
        final milestoneTaskMap = <String, List<String>>{};
        for (final item in raw) {
          if (item is! Map) continue;
          final row = Map<String, dynamic>.from(item);
          final task = TeamTaskModel.fromMap(row);
          if (task.id.isNotEmpty && task.title.isNotEmpty) {
            fetched.add(task);
            final mid = row['id_milestone']?.toString().trim();
            if (mid != null && mid.isNotEmpty) {
              milestoneTaskMap.putIfAbsent(mid, () => []).add(task.id);
            }
          }
        }

        _teamTasks[teamCode] = fetched;
        final existingMilestones = _teamMilestones[teamCode];
        if (existingMilestones != null && milestoneTaskMap.isNotEmpty) {
          bool milestoneChanged = false;
          for (int i = 0; i < existingMilestones.length; i++) {
            final m = existingMilestones[i];
            final linkedIds = milestoneTaskMap[m.id];
            if (linkedIds != null && linkedIds.isNotEmpty) {
              final mergedIds = {...m.taskIds, ...linkedIds}.toList();
              if (mergedIds.length != m.taskIds.length) {
                existingMilestones[i] = m.copyWith(taskIds: mergedIds);
                milestoneChanged = true;
              }
            }
          }
          if (milestoneChanged) {
            await _saveMilestonesToLocal(teamCode);
          }
        }
        notifyListeners();
        return fetched;
      }
    } catch (e) {
      debugPrint('[TEAM_TASK_REPO] fetchTasksFromApi error (offline fallback active): $e');
    }

    return List.unmodifiable(_teamTasks[teamCode] ?? []);
  }

  /// Sinkronisasi daftar milestone dari Backend API (GET /api/groups/<teamCode>/milestones)
  /// dengan Fallback ke Local Storage (Offline-First).
  Future<List<TeamMilestoneModel>> fetchMilestonesFromApi(String teamCode) async {
    init();
    if (teamCode.trim().isEmpty) return [];

    // 1. Baca dari cache lokal dulu (0ms - Offline First)
    await _loadMilestonesFromLocal(teamCode);

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return getMilestones(teamCode);
    }

    try {
      final encodedCode = Uri.encodeComponent(teamCode.trim());
      final res = await ApiClient.get('/api/groups/$encodedCode/milestones', token: token);
      if (res['status'] == 'success' && res['data'] is List) {
        final List<dynamic> raw = res['data'];
        final fetched = raw
            .map((item) => TeamMilestoneModel.fromMap(item as Map<String, dynamic>))
            .toList();

        _teamMilestones[teamCode] = fetched;
        for (final m in fetched) {
          if (m.teamCode.isNotEmpty && m.teamCode != teamCode) {
            _teamMilestones[m.teamCode] = fetched;
          }
        }
        await _saveMilestonesToLocal(teamCode);
        notifyListeners();
        return fetched;
      }
    } catch (e) {
      debugPrint('[TEAM_TASK_REPO] fetchMilestonesFromApi error (offline fallback active): $e');
    }

    return getMilestones(teamCode);
  }

  /// Returns unmodifiable list of milestones for given team code.
  List<TeamMilestoneModel> getMilestones(String teamCode) {
    init();
    if (teamCode.trim().isEmpty) return [];
    if (_teamMilestones.containsKey(teamCode) && _teamMilestones[teamCode]!.isNotEmpty) {
      return List.unmodifiable(_teamMilestones[teamCode]!);
    }
    // Cek apakah ada milestone di memori yang memiliki m.teamCode sama
    for (final entry in _teamMilestones.entries) {
      if (entry.value.any((m) => m.teamCode == teamCode)) {
        _teamMilestones[teamCode] = entry.value;
        return List.unmodifiable(entry.value);
      }
    }
    _loadMilestonesFromLocal(teamCode);
    return List.unmodifiable(_teamMilestones[teamCode] ?? []);
  }

  /// Returns tasks belonging to a specific milestone.
  List<TeamTaskModel> getTasksForMilestone(String teamCode, String milestoneId) {
    init();
    final milestones = _teamMilestones[teamCode] ?? [];
    final milestone = milestones.where((m) => m.id == milestoneId).firstOrNull;
    if (milestone == null) return [];
    final allTasks = getTasks(teamCode);
    return milestone.getMemberTasks(allTasks);
  }

  /// Returns tasks that are not assigned to any milestone in this team.
  List<TeamTaskModel> getUncategorizedTasks(String teamCode) {
    init();
    final allTasks = getTasks(teamCode);
    final milestones = _teamMilestones[teamCode] ?? [];
    final assignedTaskIds = <String>{};
    for (final m in milestones) {
      assignedTaskIds.addAll(m.taskIds);
    }
    return allTasks.where((t) => !assignedTaskIds.contains(t.id)).toList();
  }

  /// Adds a new milestone.
  void addMilestone(String teamCode, TeamMilestoneModel milestone) {
    init();
    final list = _teamMilestones.putIfAbsent(teamCode, () => []);
    list.removeWhere((m) => m.id == milestone.id);
    list.insert(0, milestone);
    _saveMilestonesToLocal(teamCode);
    if (milestone.teamCode.isNotEmpty && milestone.teamCode != teamCode) {
      final altList = _teamMilestones.putIfAbsent(milestone.teamCode, () => []);
      altList.removeWhere((m) => m.id == milestone.id);
      altList.insert(0, milestone);
      _saveMilestonesToLocal(milestone.teamCode);
    }
    notifyListeners();

    _pushCreateMilestone(teamCode, milestone);
  }

  Future<void> _pushCreateMilestone(String teamCode, TeamMilestoneModel milestone) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    try {
      final encodedCode = Uri.encodeComponent(teamCode.trim());
      await ApiClient.post(
        '/api/groups/$encodedCode/milestones',
        {
          'id': milestone.id,
          'id_milestone': milestone.id,
          'title': milestone.title,
          'description': milestone.description ?? '',
          'deadline': milestone.deadline.toIso8601String(),
          'task_ids': milestone.taskIds,
        },
        token: token,
      );
    } catch (e) {
      debugPrint('[TEAM_TASK_REPO] _pushCreateMilestone error: $e');
    }
  }

  /// Updates an existing milestone.
  void updateMilestone(String teamCode, TeamMilestoneModel updated) {
    init();
    void updateIn(String key) {
      final list = _teamMilestones[key];
      if (list != null) {
        final index = list.indexWhere((m) => m.id == updated.id);
        if (index != -1) {
          list[index] = updated;
          _saveMilestonesToLocal(key);
        }
      }
    }
    updateIn(teamCode);
    if (updated.teamCode.isNotEmpty && updated.teamCode != teamCode) {
      updateIn(updated.teamCode);
    }
    notifyListeners();

    _pushUpdateMilestone(teamCode, updated);
  }

  Future<void> _pushUpdateMilestone(String teamCode, TeamMilestoneModel milestone) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    try {
      final encodedCode = Uri.encodeComponent(teamCode.trim());
      final encodedId = Uri.encodeComponent(milestone.id.trim());
      await ApiClient.put(
        '/api/groups/$encodedCode/milestones/$encodedId',
        {
          'title': milestone.title,
          'description': milestone.description ?? '',
          'deadline': milestone.deadline.toIso8601String(),
          'task_ids': milestone.taskIds,
        },
        token: token,
      );
    } catch (e) {
      debugPrint('[TEAM_TASK_REPO] _pushUpdateMilestone error: $e');
    }
  }

  /// Finds which milestone contains this task id, if any.
  TeamMilestoneModel? getMilestoneForTask(String teamCode, String taskId) {
    init();
    final list = _teamMilestones[teamCode] ?? [];
    return list.where((m) => m.taskIds.contains(taskId)).firstOrNull;
  }

  /// Sets or clears the milestone association for a task.
  void setTaskMilestone({
    required String teamCode,
    required String taskId,
    String? milestoneId,
  }) {
    init();
    final list = _teamMilestones[teamCode];
    if (list != null) {
      bool changed = false;
      for (int i = 0; i < list.length; i++) {
        final m = list[i];
        final contains = m.taskIds.contains(taskId);
        if (m.id == milestoneId && !contains) {
          final updatedIds = List<String>.from(m.taskIds)..add(taskId);
          list[i] = m.copyWith(taskIds: updatedIds);
          changed = true;
        } else if (m.id != milestoneId && contains) {
          final updatedIds = List<String>.from(m.taskIds)..remove(taskId);
          list[i] = m.copyWith(taskIds: updatedIds);
          changed = true;
        }
      }
      if (changed) {
        _saveMilestonesToLocal(teamCode);
        notifyListeners();
        _pushSetTaskMilestone(teamCode, taskId, milestoneId);
      }
    }
  }

  /// Deletes a milestone without deleting its member tasks.
  void deleteMilestone(String teamCode, String milestoneId) {
    init();
    final list = _teamMilestones[teamCode];
    if (list != null) {
      list.removeWhere((m) => m.id == milestoneId);
      _saveMilestonesToLocal(teamCode);
    }
    for (final entry in _teamMilestones.entries) {
      if (entry.key != teamCode) {
        entry.value.removeWhere((m) => m.id == milestoneId);
        _saveMilestonesToLocal(entry.key);
      }
    }
    notifyListeners();

    _pushDeleteMilestone(teamCode, milestoneId);
  }

  /// Membersihkan data memori saat logout tanpa menghapus cache lokal offline.
  void clear() {
    _teamTasks.clear();
    _teamMilestones.clear();
    notifyListeners();
  }

  Future<void> _pushDeleteMilestone(String teamCode, String milestoneId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    try {
      final encodedCode = Uri.encodeComponent(teamCode.trim());
      final encodedId = Uri.encodeComponent(milestoneId.trim());
      await ApiClient.delete(
        '/api/groups/$encodedCode/milestones/$encodedId',
        token: token,
      );
    } catch (e) {
      debugPrint('[TEAM_TASK_REPO] _pushDeleteMilestone error: $e');
    }
  }

  /// Checks if all team tasks under given team code are finished.
  bool areAllTasksCompleted(String teamCode) {
    init();
    final tasks = _teamTasks[teamCode];
    if (tasks == null || tasks.isEmpty) return false;
    return tasks.every((t) => t.isDone);
  }

  /// Calculates percentage of completed tasks (0 - 100).
  int getCompletionPercentage(String teamCode) {
    init();
    final tasks = _teamTasks[teamCode];
    if (tasks == null || tasks.isEmpty) return 0;
    final done = tasks.where((t) => t.isDone).length;
    return ((done / tasks.length) * 100).round();
  }

  /// Toggles completion of a specific team task and automatically syncs project status.
  void toggleTaskCompletion({
    required String teamCode,
    required String taskId,
  }) {
    init();
    String targetKey = teamCode;
    List<TeamTaskModel>? list = _teamTasks[teamCode];
    int index = list?.indexWhere((t) => t.id == taskId) ?? -1;

    if (index == -1) {
      for (final entry in _teamTasks.entries) {
        final foundIdx = entry.value.indexWhere((t) => t.id == taskId);
        if (foundIdx != -1) {
          targetKey = entry.key;
          list = entry.value;
          index = foundIdx;
          break;
        }
      }
    }

    if (list != null && index != -1) {
      list[index] = list[index].copyWith(isDone: !list[index].isDone);
      _syncWithTaskRepository(targetKey);
      notifyListeners();
      _pushToggleTask(targetKey, taskId);
    }
  }

  /// Convenience alias for [toggleTaskCompletion].
  void toggleTaskDone(String teamCode, String taskId) {
    toggleTaskCompletion(teamCode: teamCode, taskId: taskId);
  }

  /// Adds a new team task. Idempotent: skips insertion if a task with the same id already exists.
  void addTask(String teamCode, TeamTaskModel task, {String? milestoneId}) {
    init();
    final list = _teamTasks.putIfAbsent(teamCode, () => []);
    if (list.any((t) => t.id == task.id)) return; // idempotent guard
    list.insert(0, task);
    _syncWithTaskRepository(teamCode);
    notifyListeners();
    _pushCreateTask(teamCode, task, milestoneId: milestoneId);
  }

  Future<void> _pushCreateTask(String teamCode, TeamTaskModel task, {String? milestoneId}) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    try {
      final encodedCode = Uri.encodeComponent(teamCode.trim());
      await ApiClient.post(
        '/api/groups/$encodedCode/tasks',
        {
          ...task.toApiMap(),
          'title': task.title,
          if (task.assignedMemberId != null && task.assignedMemberId!.isNotEmpty)
            'id_assigned_to': task.assignedMemberId,
          if (task.assignedTo.isNotEmpty)
            'assigned_to': task.assignedTo,
          if (milestoneId != null && milestoneId.isNotEmpty) 'id_milestone': milestoneId,
        },
        token: token,
      );
    } catch (e) {
      debugPrint('[TEAM_TASK_REPO] _pushCreateTask error: $e');
    }
  }

  Future<void> _pushUpdateTask(String teamCode, TeamTaskModel task) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    try {
      final encodedCode = Uri.encodeComponent(teamCode.trim());
      final encodedId = Uri.encodeComponent(task.id.trim());
      final currentMilestone = getMilestoneForTask(teamCode, task.id);
      await ApiClient.put(
        '/api/groups/$encodedCode/tasks/$encodedId',
        {
          ...task.toApiMap(),
          'title': task.title,
          if (task.assignedMemberId != null && task.assignedMemberId!.isNotEmpty)
            'id_assigned_to': task.assignedMemberId,
          if (task.assignedTo.isNotEmpty)
            'assigned_to': task.assignedTo,
          if (currentMilestone != null) 'id_milestone': currentMilestone.id,
        },
        token: token,
      );
    } catch (e) {
      debugPrint('[TEAM_TASK_REPO] _pushUpdateTask error: $e');
    }
  }

  Future<void> _pushDeleteTask(String teamCode, String taskId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    try {
      final encodedCode = Uri.encodeComponent(teamCode.trim());
      final encodedId = Uri.encodeComponent(taskId.trim());
      await ApiClient.delete(
        '/api/groups/$encodedCode/tasks/$encodedId',
        token: token,
      );
    } catch (e) {
      debugPrint('[TEAM_TASK_REPO] _pushDeleteTask error: $e');
    }
  }

  Future<void> _pushToggleTask(String teamCode, String taskId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    try {
      final encodedCode = Uri.encodeComponent(teamCode.trim());
      final encodedId = Uri.encodeComponent(taskId.trim());
      final list = _teamTasks[teamCode];
      final task = list?.where((t) => t.id == taskId).firstOrNull;
      if (task != null) {
        await ApiClient.put(
          '/api/groups/$encodedCode/tasks/$encodedId',
          {
            'is_completed': task.isDone ? 1 : 0,
          },
          token: token,
        );
      }
    } catch (e) {
      debugPrint('[TEAM_TASK_REPO] _pushToggleTask error: $e');
    }
  }

  Future<void> _pushSetTaskMilestone(String teamCode, String taskId, String? milestoneId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    try {
      final encodedCode = Uri.encodeComponent(teamCode.trim());
      final encodedId = Uri.encodeComponent(taskId.trim());
      await ApiClient.put(
        '/api/groups/$encodedCode/tasks/$encodedId',
        {
          'id_milestone': milestoneId ?? '',
        },
        token: token,
      );
    } catch (e) {
      debugPrint('[TEAM_TASK_REPO] _pushSetTaskMilestone error: $e');
    }
  }

  /// Updates an existing team task.
  void updateTask(String teamCode, TeamTaskModel updatedTask) {
    init();
    final list = _teamTasks[teamCode];
    if (list != null) {
      final index = list.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        list[index] = updatedTask;
        _syncWithTaskRepository(teamCode);
        notifyListeners();
        _pushUpdateTask(teamCode, updatedTask);
      }
    }
  }

  /// Deletes a team task.
  void deleteTask(String teamCode, String taskId) {
    init();
    final list = _teamTasks[teamCode];
    if (list != null) {
      list.removeWhere((t) => t.id == taskId);
      _syncWithTaskRepository(teamCode);
      notifyListeners();
      _pushDeleteTask(teamCode, taskId);
    }
  }

  /// Returns true when [task] is assigned to [userName].
  bool isTaskAssignedToUser(TeamTaskModel task, String userName) {
    final userLower = userName.toLowerCase().trim();
    final assignedLower = task.assignedTo.toLowerCase().trim();
    if (userLower.isEmpty) return false;
    if (assignedLower.contains(userLower) || userLower.contains(assignedLower)) return true;
    if (userLower == 'jarvis' &&
        (assignedLower.contains('yoga') || assignedLower.contains('jarvis'))) {
      return true;
    }
    final parts = userLower.split(RegExp(r'[\s,]+')).where((s) => s.length >= 3);
    for (final p in parts) {
      if (assignedLower.contains(p)) return true;
    }
    final assignedParts = assignedLower.split(RegExp(r'[\s,]+')).where((s) => s.length >= 3);
    for (final ap in assignedParts) {
      if (userLower.contains(ap)) return true;
    }
    return false;
  }

  /// Converts team tasks assigned to [userName] into [TaskItemModel] items
  /// not already duplicated by title in [existingRepoTasks].
  List<TaskItemModel> getAssignedTaskItemsForUser(
    String userName,
    List<TaskItemModel> existingRepoTasks, {
    String teamCode = '7X29',
  }) {
    return getTasks(teamCode)
        .where((t) => isTaskAssignedToUser(t, userName))
        .map(_convertTeamTaskToTaskItem)
        .where(
          (converted) => !existingRepoTasks.any(
            (r) => r.title.toLowerCase() == converted.title.toLowerCase(),
          ),
        )
        .toList();
  }

  TaskItemModel _convertTeamTaskToTaskItem(TeamTaskModel task) {
    final priorityLevel = task.priority == TaskPriority.high
        ? TaskPriorityLevel.high
        : (task.priority == TaskPriority.medium
            ? TaskPriorityLevel.medium
            : TaskPriorityLevel.low);

    return TaskItemModel(
      id: 'team_task_${task.id}',
      title: task.title,
      teamName: 'Kelompok IMPAL',
      priority: priorityLevel,
      durationBadge: task.effectiveDueBadge,
      durationBadgeColor: task.isUrgent
          ? const Color(0xFFFF7D65)
          : const Color(0xFF5B93FF),
      durationTextColor: Colors.white,
      subtitle: task.assignedTo,
      deadlineDate: task.deadline ?? DateTime(2026, 10, 18, 23, 59),
      formattedDeadline: 'Sun 18 Oct 2026, ${task.timeRange}',
      memberAvatars: task.colors,
      tags: const [
        TaskTagModel(
          label: 'Team',
          backgroundColor: Color(0xFF786FA6),
          textColor: Color(0xFF4A3C8C),
        ),
      ],
      groupMembers: [task.assignedTo],
      course: 'Kelompok IMPAL • 7X29',
      notes: task.description ?? '',
      isCompleted: task.isDone,
      isAssignedToUser: true,
      isCollegeTask: true,
      isAlertEnabled: task.isAlertEnabled,
    );
  }

  /// Private helper to automatically synchronize group task state in TaskRepository.
  void _syncWithTaskRepository(String teamCode) {
    final allDone = areAllTasksCompleted(teamCode);
    final percentage = getCompletionPercentage(teamCode);
    TaskRepository().syncTeamProjectStatus(
      isCompleted: allDone,
      progressPercent: percentage,
    );
  }
}

