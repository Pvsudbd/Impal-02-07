import 'package:flutter/material.dart';
import 'team_model.dart';

/// Category tabs shown in FigCraft `Desktop - Group Directory (List Kelompok)` (node 5421).
enum TeamDirectoryCategory {
  all,
  mataKuliah,
  projekMandiri,
  kompetisi,
}

/// Member initial avatar item inside a desktop team directory card.
class TeamMemberAvatar {
  final String initials;
  final Color bgColor;

  const TeamMemberAvatar({
    required this.initials,
    required this.bgColor,
  });
}

/// Data model for a single team card in FigCraft `Desktop - Group Directory` (node 5340).
class DesktopTeamCardData {
  final String id;
  final String name;
  final String subtitle;
  final String badgeLabel;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final TeamDirectoryCategory category;
  final List<TeamMemberAvatar> members;
  final int completedTasks;
  final int totalTasks;
  final Color progressColor;
  final Color percentTextColor;
  final String inviteCode;
  final bool isPrimaryAction;

  const DesktopTeamCardData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.badgeLabel,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.category,
    required this.members,
    required this.completedTasks,
    required this.totalTasks,
    required this.progressColor,
    required this.percentTextColor,
    required this.inviteCode,
    this.isPrimaryAction = false,
  });

  int get progressPercent {
    if (totalTasks <= 0) return 0;
    return ((completedTasks / totalTasks) * 100).round().clamp(0, 100);
  }

  double get progressRatio {
    if (totalTasks <= 0) return 0;
    return (completedTasks / totalTasks).clamp(0.0, 1.0);
  }

  TeamModel toTeamModel() {
    return TeamModel(
      id: id,
      name: name,
      memberColors: members.map((m) => m.bgColor).toList(),
    );
  }
}

/// Deadline item displayed in the right panel `Tenggat Waktu Kelompok` (node 5558).
class DesktopTeamDeadlineItem {
  final String title;
  final String timeText;
  final String priorityLabel;
  final Color pillBgColor;
  final Color pillTextColor;

  const DesktopTeamDeadlineItem({
    required this.title,
    required this.timeText,
    required this.priorityLabel,
    required this.pillBgColor,
    required this.pillTextColor,
  });
}

/// Activity item displayed in the right panel `Aktivitas Tim Terkini` (node 5578).
class DesktopTeamActivityItem {
  final String initials;
  final Color avatarColor;
  final String description;
  final String timeAgo;

  const DesktopTeamActivityItem({
    required this.initials,
    required this.avatarColor,
    required this.description,
    required this.timeAgo,
  });
}

/// Centralized repository & FigCraft baseline fixtures for `Desktop - Group Directory (List Kelompok)`.
class DesktopTeamDirectoryFixtures {
  static const List<DesktopTeamCardData> defaultTeams = [
    DesktopTeamCardData(
      id: 'dir_impal',
      name: 'Kelompok - IMPAL',
      subtitle: 'Implementasi & Pengujian PL • Kelas SIF-45-02',
      badgeLabel: 'SIF-45',
      badgeBgColor: Color(0xFF63CDDA),
      badgeTextColor: Color(0xFF2A8F9C),
      category: TeamDirectoryCategory.mataKuliah,
      members: [
        TeamMemberAvatar(initials: 'JS', bgColor: Color(0xFFFF7D65)),
        TeamMemberAvatar(initials: 'AS', bgColor: Color(0xFF63CDDA)),
        TeamMemberAvatar(initials: 'MK', bgColor: Color(0xFF786FA6)),
        TeamMemberAvatar(initials: 'YP', bgColor: Color(0xFFF3A683)),
        TeamMemberAvatar(initials: 'RD', bgColor: Color(0xFF778BEB)),
      ],
      completedTasks: 6,
      totalTasks: 8,
      progressColor: Color(0xFFFF7D65),
      percentTextColor: Color(0xFFFF7D65),
      inviteCode: '7X29',
      isPrimaryAction: true,
    ),
    DesktopTeamCardData(
      id: 'dir_ium',
      name: 'Kelompok - IUM',
      subtitle: 'Interaksi Pengguna & Mesin • Usability Evaluation',
      badgeLabel: 'SIF-44',
      badgeBgColor: Color(0xFF786FA6),
      badgeTextColor: Color(0xFF4A3C8C),
      category: TeamDirectoryCategory.mataKuliah,
      members: [
        TeamMemberAvatar(initials: 'YP', bgColor: Color(0xFFF3A683)),
        TeamMemberAvatar(initials: 'AS', bgColor: Color(0xFF63CDDA)),
        TeamMemberAvatar(initials: 'JS', bgColor: Color(0xFFFF7D65)),
      ],
      completedTasks: 2,
      totalTasks: 5,
      progressColor: Color(0xFF63CDDA),
      percentTextColor: Colors.white,
      inviteCode: '3M81',
      isPrimaryAction: false,
    ),
    DesktopTeamCardData(
      id: 'dir_projek_tik',
      name: 'Kelompok - Projek TIK',
      subtitle: 'Pengembangan Sistem Informasi Magang Kampus',
      badgeLabel: 'Projek',
      badgeBgColor: Color(0xFF778BEB),
      badgeTextColor: Color(0xFF4055C0),
      category: TeamDirectoryCategory.projekMandiri,
      members: [
        TeamMemberAvatar(initials: 'JS', bgColor: Color(0xFFFF7D65)),
        TeamMemberAvatar(initials: 'RD', bgColor: Color(0xFF778BEB)),
      ],
      completedTasks: 1,
      totalTasks: 4,
      progressColor: Color(0xFF63CDDA),
      percentTextColor: Colors.white,
      inviteCode: '9K20',
      isPrimaryAction: false,
    ),
    DesktopTeamCardData(
      id: 'dir_ka',
      name: 'Kelompok - KA',
      subtitle: 'Kecerdasan Artifisial • Fuzzy Mamdani & Decision Tree',
      badgeLabel: 'SIF-45',
      badgeBgColor: Color(0xFF63CDDA),
      badgeTextColor: Color(0xFF2A8F9C),
      category: TeamDirectoryCategory.mataKuliah,
      members: [
        TeamMemberAvatar(initials: 'MK', bgColor: Color(0xFF786FA6)),
        TeamMemberAvatar(initials: 'YP', bgColor: Color(0xFFF3A683)),
        TeamMemberAvatar(initials: 'AS', bgColor: Color(0xFF63CDDA)),
        TeamMemberAvatar(initials: 'JS', bgColor: Color(0xFFFF7D65)),
      ],
      completedTasks: 3,
      totalTasks: 5,
      progressColor: Color(0xFF63CDDA),
      percentTextColor: Colors.white,
      inviteCode: '4A12',
      isPrimaryAction: false,
    ),
  ];

  static const List<DesktopTeamDeadlineItem> defaultDeadlines = [
    DesktopTeamDeadlineItem(
      title: 'Sprint 1 Review IMPAL',
      timeText: 'Tomorrow, 19:00 WIB',
      priorityLabel: 'High',
      pillBgColor: Color(0xFFFF7D65),
      pillTextColor: Colors.white,
    ),
    DesktopTeamDeadlineItem(
      title: 'Laporan IUM Bab 2',
      timeText: 'Thursday, 23:59 WIB',
      priorityLabel: 'Medium',
      pillBgColor: Color(0xFF786FA6),
      pillTextColor: Color(0xFF4A3C8C),
    ),
    DesktopTeamDeadlineItem(
      title: 'Dataset KA Testing',
      timeText: 'Friday, 17:00 WIB',
      priorityLabel: 'Medium',
      pillBgColor: Color(0xFF786FA6),
      pillTextColor: Color(0xFF4A3C8C),
    ),
  ];

  static const List<DesktopTeamActivityItem> defaultActivities = [
    DesktopTeamActivityItem(
      initials: 'YP',
      avatarColor: Color(0xFFF3A683),
      description: "Yoga Perkasa completed 'Wireframe UI'",
      timeAgo: '10m ago',
    ),
    DesktopTeamActivityItem(
      initials: 'AS',
      avatarColor: Color(0xFF63CDDA),
      description: "Ahmad Sahroni scheduled 'Meeting IMPAL'",
      timeAgo: '1h ago',
    ),
    DesktopTeamActivityItem(
      initials: 'MK',
      avatarColor: Color(0xFF786FA6),
      description: 'M. Kafi uploaded GitHub PR link',
      timeAgo: '3h ago',
    ),
  ];
}

