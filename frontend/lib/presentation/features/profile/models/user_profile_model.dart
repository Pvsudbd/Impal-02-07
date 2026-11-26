import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../data/local/isar_service.dart';

/// Output mode for deadline alert notifications.
enum AlertSoundVibrationMode {
  soundAndVibrate,
  soundOnly,
  vibrationOnly,
  silent,
}

extension AlertSoundVibrationModeX on AlertSoundVibrationMode {
  String get label {
    switch (this) {
      case AlertSoundVibrationMode.soundAndVibrate:
        return 'Sound & Vibration';
      case AlertSoundVibrationMode.soundOnly:
        return 'Sound Only';
      case AlertSoundVibrationMode.vibrationOnly:
        return 'Vibration Only';
      case AlertSoundVibrationMode.silent:
        return 'Silent';
    }
  }

  String get shortLabel {
    switch (this) {
      case AlertSoundVibrationMode.soundAndVibrate:
        return 'Sound & Vibrate';
      case AlertSoundVibrationMode.soundOnly:
        return 'Sound Only';
      case AlertSoundVibrationMode.vibrationOnly:
        return 'Vibrate Only';
      case AlertSoundVibrationMode.silent:
        return 'Silent';
    }
  }

  IconData get icon {
    switch (this) {
      case AlertSoundVibrationMode.soundAndVibrate:
        return Icons.notifications_active_rounded;
      case AlertSoundVibrationMode.soundOnly:
        return Icons.volume_up_rounded;
      case AlertSoundVibrationMode.vibrationOnly:
        return Icons.vibration_rounded;
      case AlertSoundVibrationMode.silent:
        return Icons.notifications_off_outlined;
    }
  }
}

/// Main pillars of alert configuration in Profile.
enum AlertCategoryType {
  taskDeadline,
  schedule,
  team,
  // Backwards compatibility aliases
  classSchedule,
  teamMeeting;

  String get label {
    switch (this) {
      case AlertCategoryType.taskDeadline:
        return 'Task Deadlines';
      case AlertCategoryType.schedule:
      case AlertCategoryType.classSchedule:
        return 'Schedule Alerts';
      case AlertCategoryType.team:
      case AlertCategoryType.teamMeeting:
        return 'Team Alerts';
    }
  }

  String get description {
    switch (this) {
      case AlertCategoryType.taskDeadline:
        return 'Personal assignment & submission reminders';
      case AlertCategoryType.schedule:
      case AlertCategoryType.classSchedule:
        return 'Campus lectures & external schedule alerts';
      case AlertCategoryType.team:
      case AlertCategoryType.teamMeeting:
        return 'Group task deadlines & team meeting reminders';
    }
  }

  IconData get icon {
    switch (this) {
      case AlertCategoryType.taskDeadline:
        return Icons.assignment_late_outlined;
      case AlertCategoryType.schedule:
      case AlertCategoryType.classSchedule:
        return Icons.calendar_month_outlined;
      case AlertCategoryType.team:
      case AlertCategoryType.teamMeeting:
        return Icons.groups_outlined;
    }
  }

  Color get accentColor {
    switch (this) {
      case AlertCategoryType.taskDeadline:
        return const Color(0xFFFF7D65); // Coral
      case AlertCategoryType.schedule:
      case AlertCategoryType.classSchedule:
        return const Color(0xFF5B93FF); // Sky Blue
      case AlertCategoryType.team:
      case AlertCategoryType.teamMeeting:
        return const Color(0xFFFBBF24); // Warm Amber
    }
  }
}

/// Alert configuration for a specific activity category.
class CategoryAlertConfig {
  final bool enabled;
  final List<String> timings;
  final AlertSoundVibrationMode soundMode;

  const CategoryAlertConfig({
    this.enabled = true,
    this.timings = const ['H-1 (24 Hours)', '1 Hour'],
    this.soundMode = AlertSoundVibrationMode.soundAndVibrate,
  });

  CategoryAlertConfig copyWith({
    bool? enabled,
    List<String>? timings,
    AlertSoundVibrationMode? soundMode,
  }) {
    return CategoryAlertConfig(
      enabled: enabled ?? this.enabled,
      timings: timings ?? this.timings,
      soundMode: soundMode ?? this.soundMode,
    );
  }

  Map<String, dynamic> toMap() => {
        'enabled': enabled,
        'timings': timings,
        'soundMode': soundMode.name,
      };

  static AlertSoundVibrationMode _parseSoundMode(dynamic raw) {
    final s = (raw ?? '').toString().trim();
    switch (s) {
      case 'soundAndVibrate':
      case 'soundAndVibration':
        return AlertSoundVibrationMode.soundAndVibrate;
      case 'soundOnly':
        return AlertSoundVibrationMode.soundOnly;
      case 'vibrationOnly':
        return AlertSoundVibrationMode.vibrationOnly;
      case 'silent':
        return AlertSoundVibrationMode.silent;
      default:
        return AlertSoundVibrationMode.soundAndVibrate;
    }
  }

  factory CategoryAlertConfig.fromMap(
    Map<String, dynamic> map, {
    CategoryAlertConfig fallback = const CategoryAlertConfig(),
  }) {
    final rawTimings = map['timings'];
    final parsedTimings = rawTimings is List
        ? rawTimings.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList()
        : fallback.timings;
    return CategoryAlertConfig(
      enabled: map['enabled'] is bool ? map['enabled'] as bool : fallback.enabled,
      timings: parsedTimings,
      soundMode: map.containsKey('soundMode')
          ? _parseSoundMode(map['soundMode'])
          : fallback.soundMode,
    );
  }

  String get cleanTimingsSummary {
    if (!enabled) return 'Muted';
    if (timings.isEmpty) return 'Day H';
    final first = timings.first.replaceAll(RegExp(r'\(.*?\)'), '').trim();
    return first.isEmpty ? timings.first : first;
  }

  String get summary {
    if (!enabled) return 'Muted • Tap to configure';
    final timingParts = timings.isNotEmpty
        ? timings.map((t) {
            final cleaned = t.replaceAll(RegExp(r'\(.*?\)'), '').trim();
            return cleaned.isEmpty ? t : cleaned;
          }).join(', ')
        : 'Day H';
    return '$timingParts • ${soundMode.shortLabel}';
  }
}

/// Available topics that can be included in the Daily Morning Briefing.
abstract class DailyBriefingTopic {
  static const String personalTasks = 'personal_tasks';
  static const String lectureSchedule = 'lecture_schedule';
  static const String externalSchedule = 'external_schedule';
  static const String teamTasks = 'team_tasks';
  static const String teamMeetings = 'team_meetings';

  static const List<String> all = [
    personalTasks,
    lectureSchedule,
    externalSchedule,
    teamTasks,
    teamMeetings,
  ];

  static String label(String topic) {
    switch (topic) {
      case personalTasks:
        return 'Personal Tasks';
      case lectureSchedule:
        return 'Lecture Schedule';
      case externalSchedule:
        return 'External Schedule';
      case teamTasks:
        return 'Team Tasks';
      case teamMeetings:
        return 'Team Meetings';
      default:
        return topic;
    }
  }

  static String description(String topic) {
    switch (topic) {
      case personalTasks:
        return 'Individual assignments & deadlines due today';
      case lectureSchedule:
        return 'Campus classes, lectures & lab sessions for today';
      case externalSchedule:
        return 'Seminars, competitions & external agendas for today';
      case teamTasks:
        return 'Group deliverables & team task deadlines';
      case teamMeetings:
        return 'Group voice calls, syncs & discussions today';
      default:
        return '';
    }
  }

  static IconData icon(String topic) {
    switch (topic) {
      case personalTasks:
        return Icons.assignment_outlined;
      case lectureSchedule:
        return Icons.school_outlined;
      case externalSchedule:
        return Icons.event_note_outlined;
      case teamTasks:
        return Icons.assignment_turned_in_outlined;
      case teamMeetings:
        return Icons.groups_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  static Color color(String topic) {
    switch (topic) {
      case personalTasks:
        return const Color(0xFFFF7D65); // Coral
      case lectureSchedule:
        return const Color(0xFF38BDF8); // Sky Blue
      case externalSchedule:
        return const Color(0xFF10B981); // Emerald Green
      case teamTasks:
        return const Color(0xFFFBBF24); // Warm Amber
      case teamMeetings:
        return const Color(0xFFA78BFA); // Purple
      default:
        return const Color(0xFF94A3B8);
    }
  }
}

/// Domain model representing the user's academic profile and app settings.
class UserProfileModel {
  final String fullName;
  final String studentId;
  final String majorCampus;
  final String email;
  final bool isEmailVerified;
  final String phoneNumber;
  final String groupRole;
  final String bio;
  final String avatarInitials;
  final bool isActiveStudent;

  // Academic Statistics
  final int tasksDoneCount;
  final int tasksPendingCount;
  final int courseCount;
  final int sksCount;
  final int onTimeRatePercent;

  // Reminders & Schedule Settings (Granular Independent Sub-Categories)
  final CategoryAlertConfig taskDeadlineAlerts;
  final CategoryAlertConfig lectureScheduleAlerts;
  final CategoryAlertConfig externalScheduleAlerts;
  final CategoryAlertConfig teamTaskAlerts;
  final CategoryAlertConfig teamMeetingAlerts;

  final bool isDailyBriefingEnabled;
  final String dailyMorningBriefingTime;
  final List<String> dailyBriefingTopics;
  final bool isDailyBriefingCompact;
  final bool soundVibrationEnabled;

  // Intelligent System AI Fuzzy
  final bool isFuzzyModelActive;
  final bool scoreExplainabilityEnabled;

  const UserProfileModel({
    this.fullName = 'Yoga Perkasa Didik',
    this.studentId = '103072400106',
    this.majorCampus = 'S1 Informatika • Telkom University Surabaya',
    this.email = 'yogaperkasa@student.telkomuniversity.ac.id',
    this.isEmailVerified = true,
    this.phoneNumber = '+62 812-3456-7890',
    this.groupRole = 'Kelompok 7 IMPAL (Lead Architect)',
    this.bio = 'Focused on Software Architecture, Fuzzy Logic Engine & Clean Code.',
    this.avatarInitials = 'YP',
    this.isActiveStudent = true,
    this.tasksDoneCount = 28,
    this.tasksPendingCount = 5,
    this.courseCount = 6,
    this.sksCount = 19,
    this.onTimeRatePercent = 94,
    this.taskDeadlineAlerts = const CategoryAlertConfig(
      enabled: true,
      timings: ['H-1 (24 Hours)', '1 Hour'],
      soundMode: AlertSoundVibrationMode.vibrationOnly,
    ),
    this.lectureScheduleAlerts = const CategoryAlertConfig(
      enabled: true,
      timings: ['30 Minutes', '15 Minutes'],
      soundMode: AlertSoundVibrationMode.soundAndVibrate,
    ),
    this.externalScheduleAlerts = const CategoryAlertConfig(
      enabled: true,
      timings: ['H-1 (24 Hours)', '1 Hour'],
      soundMode: AlertSoundVibrationMode.vibrationOnly,
    ),
    this.teamTaskAlerts = const CategoryAlertConfig(
      enabled: true,
      timings: ['H-1 (24 Hours)', '3 Hours'],
      soundMode: AlertSoundVibrationMode.vibrationOnly,
    ),
    this.teamMeetingAlerts = const CategoryAlertConfig(
      enabled: true,
      timings: ['1 Hour', '15 Minutes'],
      soundMode: AlertSoundVibrationMode.soundOnly,
    ),
    this.isDailyBriefingEnabled = true,
    this.dailyMorningBriefingTime = '07:00 WIB',
    this.dailyBriefingTopics = const [
      DailyBriefingTopic.personalTasks,
      DailyBriefingTopic.lectureSchedule,
      DailyBriefingTopic.externalSchedule,
      DailyBriefingTopic.teamTasks,
      DailyBriefingTopic.teamMeetings,
    ],
    this.isDailyBriefingCompact = false,
    this.soundVibrationEnabled = true,
    this.isFuzzyModelActive = true,
    this.scoreExplainabilityEnabled = true,
  });

  // Backward compatibility getters
  CategoryAlertConfig get classScheduleAlerts => lectureScheduleAlerts;
  bool get deadlineAlertsEnabled => taskDeadlineAlerts.enabled;
  List<String> get deadlineAlertTimings => taskDeadlineAlerts.timings;
  AlertSoundVibrationMode get alertSoundMode => taskDeadlineAlerts.soundMode;
  String get deadlineAlertsSummary => taskDeadlineAlerts.summary;

  String get scheduleAlertsSummary {
    final lText = lectureScheduleAlerts.enabled
        ? '${lectureScheduleAlerts.cleanTimingsSummary} (${lectureScheduleAlerts.soundMode.shortLabel})'
        : 'Muted';
    final eText = externalScheduleAlerts.enabled
        ? '${externalScheduleAlerts.cleanTimingsSummary} (${externalScheduleAlerts.soundMode.shortLabel})'
        : 'Muted';
    return 'Lecture: $lText • External: $eText';
  }

  String get teamAlertsSummary {
    final tText = teamTaskAlerts.enabled
        ? '${teamTaskAlerts.cleanTimingsSummary} (${teamTaskAlerts.soundMode.shortLabel})'
        : 'Muted';
    final mText = teamMeetingAlerts.enabled
        ? '${teamMeetingAlerts.cleanTimingsSummary} (${teamMeetingAlerts.soundMode.shortLabel})'
        : 'Muted';
    return 'Tasks: $tText • Meetings: $mText';
  }

  String get dailyBriefingSummary {
    if (!isDailyBriefingEnabled) return 'Muted • Tap to configure';
    final count = dailyBriefingTopics.length;
    final styleTag = isDailyBriefingCompact ? 'Compact' : 'Detailed';
    if (count == 0) return '$dailyMorningBriefingTime • No topics ($styleTag)';
    if (count == DailyBriefingTopic.all.length) {
      return '$dailyMorningBriefingTime • All topics • $styleTag';
    }
    final topicNames =
        dailyBriefingTopics.map(DailyBriefingTopic.label).join(', ');
    return '$dailyMorningBriefingTime • $topicNames • $styleTag';
  }

  CategoryAlertConfig configFor(AlertCategoryType category) {
    switch (category) {
      case AlertCategoryType.taskDeadline:
        return taskDeadlineAlerts;
      case AlertCategoryType.schedule:
      case AlertCategoryType.classSchedule:
        return lectureScheduleAlerts;
      case AlertCategoryType.team:
      case AlertCategoryType.teamMeeting:
        return teamMeetingAlerts;
    }
  }

  /// Derives initials from the full name if not custom set.
  String get initials {
    if (avatarInitials.trim().isNotEmpty) return avatarInitials.trim();
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName.substring(0, 1).toUpperCase() : 'YP';
  }

  UserProfileModel copyWith({
    String? fullName,
    String? studentId,
    String? majorCampus,
    String? email,
    bool? isEmailVerified,
    String? phoneNumber,
    String? groupRole,
    String? bio,
    String? avatarInitials,
    bool? isActiveStudent,
    int? tasksDoneCount,
    int? tasksPendingCount,
    int? courseCount,
    int? sksCount,
    int? onTimeRatePercent,
    CategoryAlertConfig? taskDeadlineAlerts,
    CategoryAlertConfig? lectureScheduleAlerts,
    CategoryAlertConfig? externalScheduleAlerts,
    CategoryAlertConfig? teamTaskAlerts,
    CategoryAlertConfig? teamMeetingAlerts,
    // Backwards compatibility parameters
    CategoryAlertConfig? classScheduleAlerts,
    bool? deadlineAlertsEnabled,
    List<String>? deadlineAlertTimings,
    AlertSoundVibrationMode? alertSoundMode,
    bool? isDailyBriefingEnabled,
    String? dailyMorningBriefingTime,
    List<String>? dailyBriefingTopics,
    bool? isDailyBriefingCompact,
    bool? soundVibrationEnabled,
    bool? isFuzzyModelActive,
    bool? scoreExplainabilityEnabled,
  }) {
    CategoryAlertConfig resolvedTaskDeadline =
        taskDeadlineAlerts ?? this.taskDeadlineAlerts;
    if (deadlineAlertsEnabled != null ||
        deadlineAlertTimings != null ||
        alertSoundMode != null) {
      resolvedTaskDeadline = resolvedTaskDeadline.copyWith(
        enabled: deadlineAlertsEnabled,
        timings: deadlineAlertTimings,
        soundMode: alertSoundMode,
      );
    }

    return UserProfileModel(
      fullName: fullName ?? this.fullName,
      studentId: studentId ?? this.studentId,
      majorCampus: majorCampus ?? this.majorCampus,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      groupRole: groupRole ?? this.groupRole,
      bio: bio ?? this.bio,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      isActiveStudent: isActiveStudent ?? this.isActiveStudent,
      tasksDoneCount: tasksDoneCount ?? this.tasksDoneCount,
      tasksPendingCount: tasksPendingCount ?? this.tasksPendingCount,
      courseCount: courseCount ?? this.courseCount,
      sksCount: sksCount ?? this.sksCount,
      onTimeRatePercent: onTimeRatePercent ?? this.onTimeRatePercent,
      taskDeadlineAlerts: resolvedTaskDeadline,
      lectureScheduleAlerts: lectureScheduleAlerts ??
          classScheduleAlerts ??
          this.lectureScheduleAlerts,
      externalScheduleAlerts:
          externalScheduleAlerts ?? this.externalScheduleAlerts,
      teamTaskAlerts: teamTaskAlerts ?? this.teamTaskAlerts,
      teamMeetingAlerts: teamMeetingAlerts ?? this.teamMeetingAlerts,
      isDailyBriefingEnabled:
          isDailyBriefingEnabled ?? this.isDailyBriefingEnabled,
      dailyMorningBriefingTime:
          dailyMorningBriefingTime ?? this.dailyMorningBriefingTime,
      dailyBriefingTopics:
          dailyBriefingTopics ?? this.dailyBriefingTopics,
      isDailyBriefingCompact:
          isDailyBriefingCompact ?? this.isDailyBriefingCompact,
      soundVibrationEnabled:
          soundVibrationEnabled ?? this.soundVibrationEnabled,
      isFuzzyModelActive: isFuzzyModelActive ?? this.isFuzzyModelActive,
      scoreExplainabilityEnabled:
          scoreExplainabilityEnabled ?? this.scoreExplainabilityEnabled,
    );
  }

  Map<String, dynamic> toPreferencesMap() => {
        'sound_vibration_enabled': soundVibrationEnabled,
        'is_fuzzy_model_active': isFuzzyModelActive,
        'score_explainability_enabled': scoreExplainabilityEnabled,
        'task_deadline_alerts': taskDeadlineAlerts.toMap(),
        'lecture_schedule_alerts': lectureScheduleAlerts.toMap(),
        'external_schedule_alerts': externalScheduleAlerts.toMap(),
        'team_task_alerts': teamTaskAlerts.toMap(),
        'team_meeting_alerts': teamMeetingAlerts.toMap(),
        'daily_briefing_enabled': isDailyBriefingEnabled,
        'daily_briefing_time': dailyMorningBriefingTime,
        'daily_briefing_topics': dailyBriefingTopics,
        'daily_briefing_compact': isDailyBriefingCompact,
      };

  static bool _boolFrom(dynamic v, bool fallback) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final low = v.toLowerCase();
      if (low == 'true' || low == '1' || low == 't') return true;
      if (low == 'false' || low == '0' || low == 'f') return false;
    }
    return fallback;
  }

  static Map<String, dynamic>? _mapFrom(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    if (v is String && v.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(v);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  UserProfileModel applyPreferencesMap(Map<String, dynamic> map) {
    final taskMap = _mapFrom(map['task_deadline_alerts'] ?? map['taskDeadlineAlerts']);
    final lectureMap = _mapFrom(map['lecture_schedule_alerts'] ?? map['lectureScheduleAlerts']);
    final externalMap = _mapFrom(map['external_schedule_alerts'] ?? map['externalScheduleAlerts']);
    final teamTaskMap = _mapFrom(map['team_task_alerts'] ?? map['teamTaskAlerts']);
    final teamMeetingMap = _mapFrom(map['team_meeting_alerts'] ?? map['teamMeetingAlerts']);

    final rawTopics = map['daily_briefing_topics'] ?? map['dailyBriefingTopics'];
    List<String>? topics;
    if (rawTopics is List) {
      topics = rawTopics.map((e) => e.toString()).toList();
    } else if (rawTopics is String && rawTopics.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawTopics);
        if (decoded is List) {
          topics = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    final rawTime = (map['daily_briefing_time'] ?? map['dailyMorningBriefingTime'])?.toString().trim();

    return copyWith(
      soundVibrationEnabled: _boolFrom(
        map['sound_vibration_enabled'] ?? map['soundVibrationEnabled'],
        soundVibrationEnabled,
      ),
      isFuzzyModelActive: _boolFrom(
        map['is_fuzzy_model_active'] ?? map['isFuzzyModelActive'],
        isFuzzyModelActive,
      ),
      scoreExplainabilityEnabled: _boolFrom(
        map['score_explainability_enabled'] ?? map['scoreExplainabilityEnabled'],
        scoreExplainabilityEnabled,
      ),
      taskDeadlineAlerts: taskMap != null
          ? CategoryAlertConfig.fromMap(taskMap, fallback: taskDeadlineAlerts)
          : null,
      lectureScheduleAlerts: lectureMap != null
          ? CategoryAlertConfig.fromMap(lectureMap, fallback: lectureScheduleAlerts)
          : null,
      externalScheduleAlerts: externalMap != null
          ? CategoryAlertConfig.fromMap(externalMap, fallback: externalScheduleAlerts)
          : null,
      teamTaskAlerts: teamTaskMap != null
          ? CategoryAlertConfig.fromMap(teamTaskMap, fallback: teamTaskAlerts)
          : null,
      teamMeetingAlerts: teamMeetingMap != null
          ? CategoryAlertConfig.fromMap(teamMeetingMap, fallback: teamMeetingAlerts)
          : null,
      isDailyBriefingEnabled: _boolFrom(
        map['daily_briefing_enabled'] ?? map['isDailyBriefingEnabled'],
        isDailyBriefingEnabled,
      ),
      dailyMorningBriefingTime: (rawTime != null && rawTime.isNotEmpty) ? rawTime : null,
      dailyBriefingTopics: topics,
      isDailyBriefingCompact: _boolFrom(
        map['daily_briefing_compact'] ?? map['isDailyBriefingCompact'],
        isDailyBriefingCompact,
      ),
    );
  }

  static const UserProfileModel defaultProfile = UserProfileModel();
}

/// Central in-memory repository with singleton ChangeNotifier pattern.
class UserProfileRepository with ChangeNotifier {
  static final UserProfileRepository _instance =
      UserProfileRepository._internal();
  factory UserProfileRepository() => _instance;
  UserProfileRepository._internal();

  static const String _prefsKey = 'user_preferences_json';
  static const String _prefsOwnerKey = 'user_preferences_owner';
  static const String _prefsDirtyKey = 'user_preferences_dirty';

  UserProfileModel _profile = UserProfileModel.defaultProfile;
  bool _initialized = false;
  String? _activeUserId;

  UserProfileModel get profile => _profile;
  bool get isInitialized => _initialized;

  String? _extractUserIdFromToken(String? token) {
    if (token == null || token.isEmpty) return null;
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      if (payload is Map) {
        final raw = payload['idUser'] ??
            payload['idStudent'] ??
            payload['id_user'] ??
            payload['id_student'] ??
            payload['sub'];
        if (raw != null && raw.toString().trim().isNotEmpty) {
          return raw.toString().trim();
        }
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _resolveUserId(SharedPreferences prefs) async {
    if (_activeUserId != null && _activeUserId!.isNotEmpty) return _activeUserId;
    final fromPrefs = prefs.getString('user_id') ?? prefs.getString('auth_user_id');
    if (fromPrefs != null && fromPrefs.isNotEmpty) {
      _activeUserId = fromPrefs;
      return _activeUserId;
    }
    final token = prefs.getString('auth_token') ?? prefs.getString('jwt_token');
    _activeUserId = _extractUserIdFromToken(token);
    return _activeUserId;
  }

  void init({String? userName}) {
    if (userName != null && userName.trim().isNotEmpty && userName != 'Jarvis') {
      _profile = _profile.copyWith(fullName: userName);
    }
    _loadLocalProfile();
    fetchProfileFromApi();
    _initialized = true;
  }

  Future<void> _loadLocalProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _resolveUserId(prefs);
      final phone = prefs.getString('user_phone');
      final bio = prefs.getString('user_bio');
      if ((phone != null && phone.isNotEmpty) || (bio != null && bio.isNotEmpty)) {
        _profile = _profile.copyWith(
          phoneNumber: (phone != null && phone.isNotEmpty) ? phone : _profile.phoneNumber,
          bio: (bio != null && bio.isNotEmpty) ? bio : _profile.bio,
        );
      }

      final owner = prefs.getString(_prefsOwnerKey);
      final sameOwner = owner == null || userId == null || owner == userId;
      bool hydratedFromLocal = false;

      if (sameOwner) {
        final rawPrefs = prefs.getString(_prefsKey);
        if (rawPrefs != null && rawPrefs.trim().isNotEmpty) {
          final decoded = jsonDecode(rawPrefs);
          if (decoded is Map<String, dynamic>) {
            _profile = _profile.applyPreferencesMap(decoded);
            hydratedFromLocal = true;
          } else if (decoded is Map) {
            _profile = _profile.applyPreferencesMap(Map<String, dynamic>.from(decoded));
            hydratedFromLocal = true;
          }
        }
      }

      if (!hydratedFromLocal && userId != null && userId.isNotEmpty) {
        final isarMap = await IsarService().getUserPreferencesMap(userId);
        if (isarMap != null) {
          _profile = _profile.applyPreferencesMap(isarMap);
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('[PROFILE_REPO] _loadLocalProfile: $e');
    }
  }

  /// Sinkronisasi profil mahasiswa & preferensi reminder dari backend API
  Future<void> fetchProfileFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('jwt_token');
      final savedPhone = prefs.getString('user_phone');
      final savedBio = prefs.getString('user_bio');
      if (token == null || token.isEmpty) return;

      final res = await ApiClient.get('/api/profile', token: token);
      if (res['status'] == 'success' && res['data'] is Map<String, dynamic>) {
        final data = res['data'] as Map<String, dynamic>;
        final stats = data['statistics'] as Map<String, dynamic>?;
        final apiUserId = (data['idUser'] ?? data['userId'] ?? data['idStudent'])?.toString();
        if (apiUserId != null && apiUserId.isNotEmpty) {
          _activeUserId = apiUserId;
          await prefs.setString('user_id', apiUserId);
        }

        final name = data['name']?.toString() ?? _profile.fullName;
        final studentId = data['studentId']?.toString() ?? _profile.studentId;
        final email = data['email']?.toString() ?? _profile.email;

        final initials = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

        var nextProfile = _profile.copyWith(
          fullName: name,
          studentId: studentId.isNotEmpty ? studentId : _profile.studentId,
          email: email.isNotEmpty ? email : _profile.email,
          phoneNumber: (savedPhone != null && savedPhone.isNotEmpty) ? savedPhone : _profile.phoneNumber,
          bio: (savedBio != null && savedBio.isNotEmpty) ? savedBio : _profile.bio,
          avatarInitials: initials.isNotEmpty ? initials : _profile.avatarInitials,
          tasksDoneCount: stats != null ? (stats['tasksDoneCount'] as int? ?? _profile.tasksDoneCount) : _profile.tasksDoneCount,
          tasksPendingCount: stats != null ? (stats['tasksPendingCount'] as int? ?? _profile.tasksPendingCount) : _profile.tasksPendingCount,
          courseCount: stats != null ? (stats['coursesCount'] as int? ?? _profile.courseCount) : _profile.courseCount,
        );

        final isDirty = prefs.getBool(_prefsDirtyKey) ?? false;
        final owner = prefs.getString(_prefsOwnerKey);
        final isSameOwner = owner != null && _activeUserId != null && owner == _activeUserId;

        if (isDirty && isSameOwner) {
          _profile = nextProfile;
          notifyListeners();
          await _syncPreferencesToBackend(_profile);
          return;
        }

        Map<String, dynamic>? serverPrefs;
        if (data['preferences'] is Map) {
          serverPrefs = Map<String, dynamic>.from(data['preferences'] as Map);
        } else {
          final prefRes = await ApiClient.get('/api/profile/preferences', token: token);
          if (prefRes['status'] == 'success' && prefRes['data'] is Map) {
            serverPrefs = Map<String, dynamic>.from(prefRes['data'] as Map);
          }
        }

        if (serverPrefs != null) {
          nextProfile = nextProfile.applyPreferencesMap(serverPrefs);
        }

        _profile = nextProfile;
        await _saveLocalPreferences(_profile, isSynced: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[PROFILE_REPO] fetchProfileFromApi: $e');
    }
  }

  void updateProfile(UserProfileModel newProfile) {
    _profile = newProfile;
    notifyListeners();
    _saveLocalProfile(newProfile);
    _saveLocalPreferences(newProfile, isSynced: false);
    _syncToBackend(newProfile);
    _syncPreferencesToBackend(newProfile);
  }

  Future<void> _saveLocalProfile(UserProfileModel p) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_phone', p.phoneNumber);
      await prefs.setString('user_bio', p.bio);
    } catch (_) {}
  }

  Future<void> _saveLocalPreferences(
    UserProfileModel p, {
    required bool isSynced,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _resolveUserId(prefs);
      final map = p.toPreferencesMap();
      await prefs.setString(_prefsKey, jsonEncode(map));
      if (userId != null && userId.isNotEmpty) {
        await prefs.setString(_prefsOwnerKey, userId);
        await IsarService().saveUserPreferencesMap(
          userId,
          map,
          name: p.fullName,
          email: p.email,
          isSynced: isSynced,
        );
      }
      await prefs.setBool(_prefsDirtyKey, !isSynced);
    } catch (e) {
      debugPrint('[PROFILE_REPO] _saveLocalPreferences: $e');
    }
  }

  Future<void> _syncPreferencesToBackend(UserProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('jwt_token');
      if (token == null || token.isEmpty) return;

      final res = await ApiClient.put(
        '/api/profile/preferences',
        profile.toPreferencesMap(),
        token: token,
      );
      if (res['status'] == 'success') {
        await prefs.setBool(_prefsDirtyKey, false);
        final userId = await _resolveUserId(prefs);
        if (userId != null && userId.isNotEmpty) {
          await IsarService().saveUserPreferencesMap(
            userId,
            profile.toPreferencesMap(),
            name: profile.fullName,
            email: profile.email,
            isSynced: true,
          );
        }
      }
    } catch (e) {
      debugPrint('[PROFILE_REPO] _syncPreferencesToBackend error: $e');
    }
  }

  void _persistAndSyncPreferences() {
    _saveLocalPreferences(_profile, isSynced: false);
    _syncPreferencesToBackend(_profile);
  }

  Future<void> resetForLogout() async {
    _profile = UserProfileModel.defaultProfile;
    _initialized = false;
    _activeUserId = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_phone');
      await prefs.remove('user_bio');
      await prefs.remove('user_id');
      await prefs.remove(_prefsKey);
      await prefs.remove(_prefsOwnerKey);
      await prefs.remove(_prefsDirtyKey);
    } catch (_) {}
  }

  Future<void> _syncToBackend(UserProfileModel newProfile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('jwt_token');
      if (token == null || token.isEmpty) return;

      await ApiClient.put(
        '/api/profile',
        {
          'name': newProfile.fullName,
          'email': newProfile.email,
        },
        token: token,
      );
    } catch (e) {
      debugPrint('[PROFILE_REPO] _syncToBackend error: $e');
    }
  }

  void updateScheduleAlertSettings({
    required CategoryAlertConfig lectureConfig,
    required CategoryAlertConfig externalConfig,
  }) {
    _profile = _profile.copyWith(
      lectureScheduleAlerts: lectureConfig,
      externalScheduleAlerts: externalConfig,
    );
    notifyListeners();
    _persistAndSyncPreferences();
  }

  void updateTeamAlertSettings({
    required CategoryAlertConfig teamTaskConfig,
    required CategoryAlertConfig teamMeetingConfig,
  }) {
    _profile = _profile.copyWith(
      teamTaskAlerts: teamTaskConfig,
      teamMeetingAlerts: teamMeetingConfig,
    );
    notifyListeners();
    _persistAndSyncPreferences();
  }

  void updateCategoryAlertSettings({
    required AlertCategoryType category,
    required bool enabled,
    required List<String> timings,
    required AlertSoundVibrationMode mode,
  }) {
    final updatedConfig = CategoryAlertConfig(
      enabled: enabled,
      timings: timings,
      soundMode: mode,
    );
    switch (category) {
      case AlertCategoryType.taskDeadline:
        _profile = _profile.copyWith(taskDeadlineAlerts: updatedConfig);
        break;
      case AlertCategoryType.schedule:
      case AlertCategoryType.classSchedule:
        _profile = _profile.copyWith(lectureScheduleAlerts: updatedConfig);
        break;
      case AlertCategoryType.team:
      case AlertCategoryType.teamMeeting:
        _profile = _profile.copyWith(teamMeetingAlerts: updatedConfig);
        break;
    }
    notifyListeners();
    _persistAndSyncPreferences();
  }

  void toggleCategoryAlert(AlertCategoryType category, bool enabled) {
    switch (category) {
      case AlertCategoryType.taskDeadline:
        _profile = _profile.copyWith(
          taskDeadlineAlerts:
              _profile.taskDeadlineAlerts.copyWith(enabled: enabled),
        );
        break;
      case AlertCategoryType.schedule:
        _profile = _profile.copyWith(
          lectureScheduleAlerts:
              _profile.lectureScheduleAlerts.copyWith(enabled: enabled),
          externalScheduleAlerts:
              _profile.externalScheduleAlerts.copyWith(enabled: enabled),
        );
        break;
      case AlertCategoryType.classSchedule:
        _profile = _profile.copyWith(
          lectureScheduleAlerts:
              _profile.lectureScheduleAlerts.copyWith(enabled: enabled),
        );
        break;
      case AlertCategoryType.team:
        _profile = _profile.copyWith(
          teamTaskAlerts:
              _profile.teamTaskAlerts.copyWith(enabled: enabled),
          teamMeetingAlerts:
              _profile.teamMeetingAlerts.copyWith(enabled: enabled),
        );
        break;
      case AlertCategoryType.teamMeeting:
        _profile = _profile.copyWith(
          teamMeetingAlerts:
              _profile.teamMeetingAlerts.copyWith(enabled: enabled),
        );
        break;
    }
    notifyListeners();
    _persistAndSyncPreferences();
  }

  void toggleDeadlineAlerts(bool value) {
    toggleCategoryAlert(AlertCategoryType.taskDeadline, value);
  }

  void updateDeadlineAlertSettings({
    required bool enabled,
    required List<String> timings,
    required AlertSoundVibrationMode mode,
  }) {
    updateCategoryAlertSettings(
      category: AlertCategoryType.taskDeadline,
      enabled: enabled,
      timings: timings,
      mode: mode,
    );
  }

  void toggleSoundVibration(bool value) {
    _profile = _profile.copyWith(soundVibrationEnabled: value);
    notifyListeners();
    _persistAndSyncPreferences();
  }

  void updateBriefingTime(String newTime) {
    _profile = _profile.copyWith(dailyMorningBriefingTime: newTime);
    notifyListeners();
    _persistAndSyncPreferences();
  }

  void updateDailyBriefingSettings({
    required bool enabled,
    required String time,
    required List<String> topics,
    bool isCompact = false,
  }) {
    _profile = _profile.copyWith(
      isDailyBriefingEnabled: enabled,
      dailyMorningBriefingTime: time,
      dailyBriefingTopics: topics,
      isDailyBriefingCompact: isCompact,
    );
    notifyListeners();
    _persistAndSyncPreferences();
  }

  void toggleDailyBriefing(bool value) {
    _profile = _profile.copyWith(isDailyBriefingEnabled: value);
    notifyListeners();
    _persistAndSyncPreferences();
  }

  void toggleScoreExplainability(bool value) {
    _profile = _profile.copyWith(scoreExplainabilityEnabled: value);
    notifyListeners();
    _persistAndSyncPreferences();
  }

  void toggleFuzzyModel(bool value) {
    _profile = _profile.copyWith(isFuzzyModelActive: value);
    notifyListeners();
    _persistAndSyncPreferences();
  }
}
