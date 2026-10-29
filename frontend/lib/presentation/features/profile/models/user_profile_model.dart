import 'package:flutter/material.dart';

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
    if (count == 0) return '$dailyMorningBriefingTime • No topics selected';
    if (count == DailyBriefingTopic.all.length) {
      return '$dailyMorningBriefingTime • All topics';
    }
    final topicNames =
        dailyBriefingTopics.map(DailyBriefingTopic.label).join(', ');
    return '$dailyMorningBriefingTime • $topicNames';
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
      soundVibrationEnabled:
          soundVibrationEnabled ?? this.soundVibrationEnabled,
      isFuzzyModelActive: isFuzzyModelActive ?? this.isFuzzyModelActive,
      scoreExplainabilityEnabled:
          scoreExplainabilityEnabled ?? this.scoreExplainabilityEnabled,
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

  UserProfileModel _profile = UserProfileModel.defaultProfile;
  bool _initialized = false;

  UserProfileModel get profile => _profile;

  void init({String? userName}) {
    if (_initialized) return;
    if (userName != null && userName.trim().isNotEmpty && userName != 'Jarvis') {
      _profile = _profile.copyWith(fullName: userName);
    }
    _initialized = true;
  }

  void updateProfile(UserProfileModel newProfile) {
    _profile = newProfile;
    notifyListeners();
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
      case AlertCategoryType.classSchedule:
        _profile = _profile.copyWith(
          lectureScheduleAlerts:
              _profile.lectureScheduleAlerts.copyWith(enabled: enabled),
        );
        break;
      case AlertCategoryType.team:
      case AlertCategoryType.teamMeeting:
        _profile = _profile.copyWith(
          teamMeetingAlerts:
              _profile.teamMeetingAlerts.copyWith(enabled: enabled),
        );
        break;
    }
    notifyListeners();
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
  }

  void updateBriefingTime(String newTime) {
    _profile = _profile.copyWith(dailyMorningBriefingTime: newTime);
    notifyListeners();
  }

  void updateDailyBriefingSettings({
    required bool enabled,
    required String time,
    required List<String> topics,
  }) {
    _profile = _profile.copyWith(
      isDailyBriefingEnabled: enabled,
      dailyMorningBriefingTime: time,
      dailyBriefingTopics: topics,
    );
    notifyListeners();
  }

  void toggleDailyBriefing(bool value) {
    _profile = _profile.copyWith(isDailyBriefingEnabled: value);
    notifyListeners();
  }

  void toggleScoreExplainability(bool value) {
    _profile = _profile.copyWith(scoreExplainabilityEnabled: value);
    notifyListeners();
  }

  void toggleFuzzyModel(bool value) {
    _profile = _profile.copyWith(isFuzzyModelActive: value);
    notifyListeners();
  }
}
