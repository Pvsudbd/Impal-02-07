import 'package:flutter/material.dart';

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

  // Reminders & Schedule Settings
  final bool deadlineAlertsEnabled;
  final String dailyMorningBriefingTime;
  final bool soundVibrationEnabled;

  // Intelligent System AI Fuzzy
  final bool isFuzzyModelActive;

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
    this.deadlineAlertsEnabled = true,
    this.dailyMorningBriefingTime = '07:00 WIB',
    this.soundVibrationEnabled = true,
    this.isFuzzyModelActive = true,
  });

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
    bool? deadlineAlertsEnabled,
    String? dailyMorningBriefingTime,
    bool? soundVibrationEnabled,
    bool? isFuzzyModelActive,
  }) {
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
      deadlineAlertsEnabled: deadlineAlertsEnabled ?? this.deadlineAlertsEnabled,
      dailyMorningBriefingTime:
          dailyMorningBriefingTime ?? this.dailyMorningBriefingTime,
      soundVibrationEnabled:
          soundVibrationEnabled ?? this.soundVibrationEnabled,
      isFuzzyModelActive: isFuzzyModelActive ?? this.isFuzzyModelActive,
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

  void toggleDeadlineAlerts(bool value) {
    _profile = _profile.copyWith(deadlineAlertsEnabled: value);
    notifyListeners();
  }

  void toggleSoundVibration(bool value) {
    _profile = _profile.copyWith(soundVibrationEnabled: value);
    notifyListeners();
  }

  void updateBriefingTime(String newTime) {
    _profile = _profile.copyWith(dailyMorningBriefingTime: newTime);
    notifyListeners();
  }
}

