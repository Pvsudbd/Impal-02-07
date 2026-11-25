import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/features/notifikasi/models/notification_model.dart';
import '../../presentation/features/notifikasi/models/notification_repository.dart';
import '../../presentation/features/profile/models/user_profile_model.dart';
import '../../presentation/features/schedule/models/schedule_model.dart';
import '../../presentation/features/schedule/models/schedule_repository.dart';
import '../../presentation/features/task/models/task_item_model.dart';
import '../../presentation/features/task/models/task_repository.dart';
import '../../presentation/features/team/models/team_task_model.dart';
import '../../presentation/features/team/models/team_task_repository.dart';

/// Evaluates upcoming Tasks, Schedules, Team Meetings, and Daily Morning Briefing
/// against [UserProfileRepository] settings, emitting real notifications into
/// [NotificationRepository] (PostgreSQL + Bell/Feed) and OS notifications via
/// [FlutterLocalNotificationsPlugin] on supported native platforms.
class ReminderNotificationService {
  static final ReminderNotificationService _instance =
      ReminderNotificationService._internal();
  factory ReminderNotificationService() => _instance;
  ReminderNotificationService._internal();

  static const String _dedupStorageKey = 'triggered_reminder_keys_v1';
  static const String _channelId = 'impal_reminders';
  static const String _channelName = 'IMPAL Reminders & Schedule';

  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _pluginReady = false;
  Timer? _timer;
  final Set<String> _triggeredKeys = <String>{};

  bool get _supportsLocalNotifications {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  Future<void> init() async {
    if (_initialized) {
      await evaluateNow();
      return;
    }
    _initialized = true;

    await _loadTriggeredKeys();
    await _initLocalPlugin();

    UserProfileRepository().addListener(_onSourceChanged);
    TaskRepository().addListener(_onSourceChanged);
    ScheduleRepository().schedulesNotifier.addListener(_onSourceChanged);
    TeamTaskRepository().addListener(_onSourceChanged);

    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 45),
      (_) => evaluateNow(),
    );

    await evaluateNow();
  }

  void _onSourceChanged() {
    evaluateNow();
  }

  Future<void> _initLocalPlugin() async {
    if (!_supportsLocalNotifications || _pluginReady) return;
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings();
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open IMPAL TodoList',
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );
      await _localPlugin.initialize(initSettings);
      _pluginReady = true;
    } catch (e) {
      debugPrint('[REMINDER_SERVICE] Local notification init skipped: $e');
      _pluginReady = false;
    }
  }

  Future<void> _loadTriggeredKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_dedupStorageKey);
      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _triggeredKeys
            ..clear()
            ..addAll(decoded.map((e) => e.toString()));
        }
      }
    } catch (_) {}
  }

  Future<void> _saveTriggeredKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep bounded to the most recent 250 keys
      final trimmed = _triggeredKeys.length > 250
          ? _triggeredKeys.skip(_triggeredKeys.length - 250).toList()
          : _triggeredKeys.toList();
      await prefs.setString(_dedupStorageKey, jsonEncode(trimmed));
    } catch (_) {}
  }

  Future<void> stopAndReset() async {
    _timer?.cancel();
    _timer = null;
    if (_initialized) {
      UserProfileRepository().removeListener(_onSourceChanged);
      TaskRepository().removeListener(_onSourceChanged);
      ScheduleRepository().schedulesNotifier.removeListener(_onSourceChanged);
      TeamTaskRepository().removeListener(_onSourceChanged);
    }
    _initialized = false;
    _triggeredKeys.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dedupStorageKey);
    } catch (_) {}
  }

  /// Parses timing labels like `'H-1 (24 Hours)'`, `'1 Hour'`, `'15 Minutes'`,
  /// `'H-24 Jam'`, `'At Start'`, `'1 Day'` into a lead [Duration].
  static Duration? parseLeadDuration(String label) {
    final low = label.trim().toLowerCase();
    if (low.isEmpty) return null;
    if (low.contains('at start') ||
        low.contains('on time') ||
        low == 'day h' ||
        low == 'h-0') {
      return Duration.zero;
    }

    final hDayMatch = RegExp(r'^h-(\d+)\s*$').firstMatch(low);
    if (hDayMatch != null) {
      final days = int.tryParse(hDayMatch.group(1)!) ?? 0;
      return Duration(days: days);
    }

    if (low.contains('h-3')) return const Duration(days: 3);
    if (low.contains('h-1 (24') || low.contains('h-24')) {
      return const Duration(hours: 24);
    }

    final numMatch = RegExp(r'(\d+)').firstMatch(low);
    final value = int.tryParse(numMatch?.group(1) ?? '');
    if (value == null) return null;

    if (low.contains('day') || low.contains('hari')) {
      return Duration(days: value);
    }
    if (low.contains('hour') || low.contains('jam') || RegExp(r'\d+\s*h\b').hasMatch(low)) {
      return Duration(hours: value);
    }
    if (low.contains('min') || low.contains('menit') || RegExp(r'\d+\s*m\b').hasMatch(low)) {
      return Duration(minutes: value);
    }
    return null;
  }

  static TimeOfDay _parseClock(String raw, {TimeOfDay fallback = const TimeOfDay(hour: 7, minute: 0)}) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw);
    if (match != null) {
      final h = (int.tryParse(match.group(1)!) ?? fallback.hour).clamp(0, 23);
      final m = (int.tryParse(match.group(2)!) ?? fallback.minute).clamp(0, 59);
      return TimeOfDay(hour: h, minute: m);
    }
    return fallback;
  }

  static String _cleanTimingName(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'\(.*?\)'), '').trim();
    return cleaned.isEmpty ? raw : cleaned;
  }

  bool _isDueNow(DateTime targetTime, Duration lead, DateTime now) {
    final triggerAt = targetTime.subtract(lead);
    // Fire if we reached triggerAt and the target event isn't older than 5 mins ago
    final windowEnd = targetTime.add(const Duration(minutes: 5));
    return !now.isBefore(triggerAt) && !now.isAfter(windowEnd);
  }

  Future<void> evaluateNow([DateTime? customNow]) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? prefs.getString('jwt_token');
    if (token == null || token.isEmpty) return;

    final now = customNow ?? DateTime.now();
    final profile = UserProfileRepository().profile;

    // 1. Personal Task Deadlines
    if (profile.taskDeadlineAlerts.enabled) {
      for (final task in TaskRepository().tasks) {
        if (task.isCompleted || !task.isAlertEnabled) continue;
        await _evaluateTaskDeadline(task, profile.taskDeadlineAlerts, profile, now);
      }
    }

    // 2. Lecture, External & Team Meeting Schedules
    final seenScheduleIds = <String>{};
    final allSchedules = <ScheduleModel>[
      ...ScheduleRepository().schedulesNotifier.value,
      ...TeamTaskRepository().allMeetings,
    ];
    for (final sch in allSchedules) {
      if (!seenScheduleIds.add(sch.id) || !sch.isAlertEnabled) continue;

      final isTeamMeeting = sch.type.toLowerCase() == 'meeting' ||
          (sch.teamName != null && sch.teamName!.trim().isNotEmpty);
      final isLecture = sch.type.toLowerCase() == 'lecture';

      final config = isTeamMeeting
          ? profile.teamMeetingAlerts
          : (isLecture ? profile.lectureScheduleAlerts : profile.externalScheduleAlerts);
      if (!config.enabled) continue;

      await _evaluateSchedule(sch, config, profile, now, isTeamMeeting: isTeamMeeting);
    }

    // 3. Team Tasks
    if (profile.teamTaskAlerts.enabled) {
      for (final teamTask in TeamTaskRepository().allTasks) {
        if (teamTask.isDone || !teamTask.isAlertEnabled || teamTask.deadline == null) {
          continue;
        }
        await _evaluateTeamTask(teamTask, profile.teamTaskAlerts, profile, now);
      }
    }

    // 4. Daily Morning Briefing
    if (profile.isDailyBriefingEnabled && profile.dailyBriefingTopics.isNotEmpty) {
      await _evaluateDailyBriefing(profile, now, allSchedules);
    }
  }

  Future<void> _evaluateTaskDeadline(
    TaskItemModel task,
    CategoryAlertConfig config,
    UserProfileModel profile,
    DateTime now,
  ) async {
    for (final timing in config.timings) {
      final lead = parseLeadDuration(timing);
      if (lead == null || !_isDueNow(task.deadlineDate, lead, now)) continue;

      final dedupKey = 'task_${task.id}_${timing.toLowerCase().replaceAll(' ', '_')}';
      if (_wasAlreadyTriggered(dedupKey)) continue;

      final label = _cleanTimingName(timing);
      await _emitNotification(
        id: 'local-task-${task.id}-${lead.inMinutes}',
        dedupKey: dedupKey,
        idTask: task.id,
        category: NotificationCategory.deadline,
        categoryLabel: task.course.isNotEmpty ? task.course : 'Personal Task',
        statusTag: 'Due • $label left',
        title: 'Task Reminder: ${task.title}',
        description:
            'Deadline on ${task.formattedDeadline}. Reminder rule "$label" is active.',
        actionLabel: 'View Task →',
        actionType: NotificationActionType.viewTask,
        targetId: task.id,
        soundMode: config.soundMode,
        globalSoundEnabled: profile.soundVibrationEnabled,
        now: now,
      );
    }
  }

  Future<void> _evaluateSchedule(
    ScheduleModel sch,
    CategoryAlertConfig config,
    UserProfileModel profile,
    DateTime now, {
    required bool isTeamMeeting,
  }) async {
    final clock = _parseClock(sch.timeStart, fallback: const TimeOfDay(hour: 8, minute: 0));
    final startTime = DateTime(
      sch.date.year,
      sch.date.month,
      sch.date.day,
      clock.hour,
      clock.minute,
    );

    for (final timing in config.timings) {
      final lead = parseLeadDuration(timing);
      if (lead == null || !_isDueNow(startTime, lead, now)) continue;

      final dedupKey = 'sched_${sch.id}_${timing.toLowerCase().replaceAll(' ', '_')}';
      if (_wasAlreadyTriggered(dedupKey)) continue;

      final label = _cleanTimingName(timing);
      final category = isTeamMeeting ? NotificationCategory.team : NotificationCategory.lecture;
      await _emitNotification(
        id: 'local-sched-${sch.id}-${lead.inMinutes}',
        dedupKey: dedupKey,
        category: category,
        categoryLabel: isTeamMeeting
            ? (sch.teamName ?? 'Team Meeting')
            : (sch.course ?? sch.type),
        statusTag: lead == Duration.zero ? 'Starting Now' : 'Starts in $label',
        title: '${isTeamMeeting ? "Meeting" : sch.type}: ${sch.title}',
        description:
            '${sch.timeStart} - ${sch.timeEnd} ${sch.timeZone}${sch.location != null && sch.location!.isNotEmpty ? " • ${sch.location}" : ""}',
        actionLabel: isTeamMeeting ? 'Open Team →' : 'Classroom',
        actionType: isTeamMeeting
            ? NotificationActionType.openTeam
            : NotificationActionType.classroom,
        targetId: sch.id,
        soundMode: config.soundMode,
        globalSoundEnabled: profile.soundVibrationEnabled,
        now: now,
      );
    }
  }

  Future<void> _evaluateTeamTask(
    TeamTaskModel task,
    CategoryAlertConfig config,
    UserProfileModel profile,
    DateTime now,
  ) async {
    final dl = task.deadline!;
    final target = DateTime(dl.year, dl.month, dl.day, 23, 59);

    for (final timing in config.timings) {
      final lead = parseLeadDuration(timing);
      if (lead == null || !_isDueNow(target, lead, now)) continue;

      final dedupKey = 'teamtask_${task.id}_${timing.toLowerCase().replaceAll(' ', '_')}';
      if (_wasAlreadyTriggered(dedupKey)) continue;

      final label = _cleanTimingName(timing);
      await _emitNotification(
        id: 'local-teamtask-${task.id}-${lead.inMinutes}',
        dedupKey: dedupKey,
        category: NotificationCategory.team,
        categoryLabel: 'Team Task • ${task.assignedTo}',
        statusTag: 'Due • $label left',
        title: 'Team Task Due: ${task.title}',
        description:
            'Assigned to ${task.assignedTo}. Priority ${task.priority.label} (${task.timeRange}).',
        actionLabel: 'Open Team →',
        actionType: NotificationActionType.openTeam,
        targetId: task.id,
        soundMode: config.soundMode,
        globalSoundEnabled: profile.soundVibrationEnabled,
        now: now,
      );
    }
  }

  Future<void> _evaluateDailyBriefing(
    UserProfileModel profile,
    DateTime now,
    List<ScheduleModel> allSchedules,
  ) async {
    final clock = _parseClock(profile.dailyMorningBriefingTime);
    final scheduledAt = DateTime(now.year, now.month, now.day, clock.hour, clock.minute);
    if (now.isBefore(scheduledAt)) return;

    final dedupKey =
        'briefing_${now.year}_${now.month}_${now.day}_${clock.hour}_${clock.minute}';
    if (_wasAlreadyTriggered(dedupKey)) return;

    bool isToday(DateTime d) =>
        d.year == now.year && d.month == now.month && d.day == now.day;

    final topics = profile.dailyBriefingTopics.toSet();
    final lines = <String>[];
    int totalItems = 0;

    if (topics.contains(DailyBriefingTopic.personalTasks)) {
      final dueToday = TaskRepository()
          .tasks
          .where((t) => !t.isCompleted && isToday(t.deadlineDate))
          .toList();
      totalItems += dueToday.length;
      if (dueToday.isNotEmpty) {
        lines.add('• Personal Tasks (${dueToday.length}): ${dueToday.take(2).map((t) => t.title).join(', ')}');
      }
    }

    if (topics.contains(DailyBriefingTopic.lectureSchedule)) {
      final lectures = allSchedules
          .where((s) => s.type.toLowerCase() == 'lecture' && isToday(s.date))
          .toList();
      totalItems += lectures.length;
      if (lectures.isNotEmpty) {
        lines.add('• Lectures (${lectures.length}): ${lectures.take(2).map((s) => "${s.title} (${s.timeStart})").join(', ')}');
      }
    }

    if (topics.contains(DailyBriefingTopic.externalSchedule)) {
      final externals = allSchedules
          .where((s) =>
              s.type.toLowerCase() == 'external' &&
              (s.teamName == null || s.teamName!.isEmpty) &&
              isToday(s.date))
          .toList();
      totalItems += externals.length;
      if (externals.isNotEmpty) {
        lines.add('• External (${externals.length}): ${externals.take(2).map((s) => "${s.title} (${s.timeStart})").join(', ')}');
      }
    }

    if (topics.contains(DailyBriefingTopic.teamTasks)) {
      final teamTasks = TeamTaskRepository()
          .allTasks
          .where((t) => !t.isDone && t.deadline != null && isToday(t.deadline!))
          .toList();
      totalItems += teamTasks.length;
      if (teamTasks.isNotEmpty) {
        lines.add('• Team Tasks (${teamTasks.length}): ${teamTasks.take(2).map((t) => t.title).join(', ')}');
      }
    }

    if (topics.contains(DailyBriefingTopic.teamMeetings)) {
      final meetings = allSchedules
          .where((s) =>
              (s.type.toLowerCase() == 'meeting' ||
                  (s.teamName != null && s.teamName!.isNotEmpty)) &&
              isToday(s.date))
          .toList();
      totalItems += meetings.length;
      if (meetings.isNotEmpty) {
        lines.add('• Meetings (${meetings.length}): ${meetings.take(2).map((s) => "${s.title} (${s.timeStart})").join(', ')}');
      }
    }

    final body = profile.isDailyBriefingCompact
        ? 'You have $totalItems agenda items scheduled across ${topics.length} selected topics today.'
        : (lines.isNotEmpty
            ? lines.join('\n')
            : 'Clear day ahead! No urgent items due today across your ${topics.length} briefing topics.');

    await _emitNotification(
      id: 'local-briefing-${now.year}${now.month}${now.day}',
      dedupKey: dedupKey,
      category: NotificationCategory.aiSystem,
      categoryLabel: 'Daily Morning Briefing',
      statusTag: profile.dailyMorningBriefingTime,
      title: 'Good Morning! Today\'s Briefing ($totalItems items)',
      description: body,
      actionLabel: 'Session Details',
      actionType: NotificationActionType.sessionDetails,
      soundMode: AlertSoundVibrationMode.soundAndVibrate,
      globalSoundEnabled: profile.soundVibrationEnabled,
      now: now,
    );
  }

  bool _wasAlreadyTriggered(String dedupKey) {
    return _triggeredKeys.contains(dedupKey) ||
        NotificationRepository.instance.hasDedupKey(dedupKey);
  }

  Future<void> _emitNotification({
    required String id,
    required String dedupKey,
    String? idTask,
    required NotificationCategory category,
    required String categoryLabel,
    required String statusTag,
    required String title,
    required String description,
    required String actionLabel,
    required NotificationActionType actionType,
    String? targetId,
    required AlertSoundVibrationMode soundMode,
    required bool globalSoundEnabled,
    required DateTime now,
  }) async {
    _triggeredKeys.add(dedupKey);
    await _saveTriggeredKeys();

    final accent = NotificationModel.accentColorFor(category);
    final model = NotificationModel(
      id: id,
      category: category,
      categoryLabel: categoryLabel,
      statusTag: statusTag,
      statusTagColor: accent,
      title: title,
      description: description,
      timestamp: NotificationModel.formatTimestampLabel(now),
      dateGroup: NotificationModel.formatDateGroup(now),
      dateFormatted: NotificationModel.formatDateReadable(now),
      actionLabel: actionLabel,
      actionType: actionType,
      accentColor: accent,
      icon: NotificationModel.iconFor(category),
      targetId: targetId,
      dedupKey: dedupKey,
      sentAt: now,
      isRead: false,
    );

    await NotificationRepository.instance.recordReminder(
      model,
      dedupKey: dedupKey,
      idTask: idTask,
    );

    await _showOsNotification(
      id: dedupKey.hashCode & 0x7fffffff,
      title: title,
      body: description,
      soundMode: soundMode,
      globalSoundEnabled: globalSoundEnabled,
    );
  }

  Future<void> _showOsNotification({
    required int id,
    required String title,
    required String body,
    required AlertSoundVibrationMode soundMode,
    required bool globalSoundEnabled,
  }) async {
    if (!_pluginReady || !_supportsLocalNotifications) return;

    final playSound = globalSoundEnabled &&
        (soundMode == AlertSoundVibrationMode.soundAndVibrate ||
            soundMode == AlertSoundVibrationMode.soundOnly);
    final enableVibration = globalSoundEnabled &&
        (soundMode == AlertSoundVibrationMode.soundAndVibrate ||
            soundMode == AlertSoundVibrationMode.vibrationOnly);

    try {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
        playSound: playSound,
        enableVibration: enableVibration,
      );
      const darwinDetails = DarwinNotificationDetails();
      final details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );
      await _localPlugin.show(id, title, body, details);
    } catch (e) {
      debugPrint('[REMINDER_SERVICE] _showOsNotification error: $e');
    }
  }
}

