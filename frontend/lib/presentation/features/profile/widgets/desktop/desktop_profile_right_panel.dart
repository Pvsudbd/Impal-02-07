import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../models/user_profile_model.dart';

/// Right Panel Card 1: REMINDERS & SCHEDULE (`FigCraft node 6130` + Mobile Granular Categories & Briefing).
class DesktopRemindersScheduleCard extends StatelessWidget {
  final UserProfileModel profile;
  final void Function(AlertCategoryType category) onOpenCategoryModal;
  final void Function(AlertCategoryType category, bool enabled) onToggleCategory;
  final VoidCallback onOpenDailyBriefingModal;
  final ValueChanged<bool> onToggleDailyBriefing;
  final ValueChanged<bool> onToggleSoundVibration;

  const DesktopRemindersScheduleCard({
    super.key,
    required this.profile,
    required this.onOpenCategoryModal,
    required this.onToggleCategory,
    required this.onOpenDailyBriefingModal,
    required this.onToggleDailyBriefing,
    required this.onToggleSoundVibration,
  });

  String _formatScheduleSummary(UserProfileModel p) {
    final lectureOn = p.lectureScheduleAlerts.enabled;
    final externalOn = p.externalScheduleAlerts.enabled;
    if (!lectureOn && !externalOn) {
      return 'Jadwal kuliah & eksternal nonaktif';
    }
    return p.scheduleAlertsSummary;
  }

  String _formatTeamSummary(UserProfileModel p) {
    final taskOn = p.teamTaskAlerts.enabled;
    final meetingOn = p.teamMeetingAlerts.enabled;
    if (!taskOn && !meetingOn) {
      return 'Alert tugas & meeting tim nonaktif';
    }
    return p.teamAlertsSummary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.rSpacing(22)),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REMINDERS & SCHEDULE',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: context.rSpacing(4)),
          Text(
            'Pengingat tugas, jadwal kuliah, tim & briefing harian',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(11.5, min: 10.5, max: 12.5),
            ),
          ),
          SizedBox(height: context.rSpacing(14)),
          _ReminderCategoryRow(
            key: const Key('desktop_alert_row_task'),
            icon: Icons.alarm_rounded,
            iconColor: AppColors.primaryAccent,
            title: 'Task Deadlines',
            subtitle: profile.taskDeadlineAlerts.enabled
                ? profile.deadlineAlertsSummary
                : 'Dimatikan • Ketuk untuk atur',
            enabled: profile.taskDeadlineAlerts.enabled,
            switchKey: const Key('desktop_alert_switch_task'),
            onTap: () => onOpenCategoryModal(AlertCategoryType.taskDeadline),
            onToggle: (val) =>
                onToggleCategory(AlertCategoryType.taskDeadline, val),
          ),
          SizedBox(height: context.rSpacing(10)),
          _ReminderCategoryRow(
            key: const Key('desktop_alert_row_schedule'),
            icon: Icons.calendar_month_outlined,
            iconColor: const Color(0xFF778BEB),
            title: 'Schedule Alerts',
            subtitle: _formatScheduleSummary(profile),
            enabled: profile.lectureScheduleAlerts.enabled ||
                profile.externalScheduleAlerts.enabled,
            switchKey: const Key('desktop_alert_switch_schedule'),
            onTap: () => onOpenCategoryModal(AlertCategoryType.schedule),
            onToggle: (val) => onToggleCategory(AlertCategoryType.schedule, val),
          ),
          SizedBox(height: context.rSpacing(10)),
          _ReminderCategoryRow(
            key: const Key('desktop_alert_row_team'),
            icon: Icons.groups_rounded,
            iconColor: const Color(0xFF63CDDA),
            title: 'Team Alerts',
            subtitle: _formatTeamSummary(profile),
            enabled: profile.teamTaskAlerts.enabled ||
                profile.teamMeetingAlerts.enabled,
            switchKey: const Key('desktop_alert_switch_team'),
            onTap: () => onOpenCategoryModal(AlertCategoryType.team),
            onToggle: (val) => onToggleCategory(AlertCategoryType.team, val),
          ),
          SizedBox(height: context.rSpacing(10)),
          _DailyBriefingRow(
            key: const Key('desktop_daily_briefing_row'),
            profile: profile,
            onTap: onOpenDailyBriefingModal,
            onToggle: onToggleDailyBriefing,
          ),
          SizedBox(height: context.rSpacing(10)),
          Container(
            key: const Key('desktop_sound_vibration_row'),
            padding: EdgeInsets.symmetric(
              horizontal: context.rSpacing(12),
              vertical: context.rSpacing(10),
            ),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4EB089).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.vibration_rounded,
                    size: context.rIcon(16),
                    color: const Color(0xFF4EB089),
                  ),
                ),
                SizedBox(width: context.rSpacing(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sound & Vibration',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: context.rSpacing(2)),
                      Text(
                        'Nada dering & getaran untuk notifikasi prioritas',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: context.rFont(11, min: 10, max: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  key: const Key('desktop_sound_vibration_switch'),
                  value: profile.soundVibrationEnabled,
                  onChanged: onToggleSoundVibration,
                  activeTrackColor: const Color(0xFF4EB089),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCategoryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool enabled;
  final Key switchKey;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  const _ReminderCategoryRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.switchKey,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgPrimary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(12),
            vertical: context.rSpacing(10),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: context.rIcon(16), color: iconColor),
              ),
              SizedBox(width: context.rSpacing(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize:
                                  context.rFont(12.5, min: 11.5, max: 13.5),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: context.rSpacing(4)),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: context.rIcon(15),
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                    SizedBox(height: context.rSpacing(2)),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: context.rFont(11, min: 10, max: 12),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                key: switchKey,
                value: enabled,
                onChanged: onToggle,
                activeTrackColor: const Color(0xFF4EB089),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyBriefingRow extends StatelessWidget {
  final UserProfileModel profile;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  const _DailyBriefingRow({
    super.key,
    required this.profile,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgPrimary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(12),
            vertical: context.rSpacing(10),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.skyBadge.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.wb_sunny_outlined,
                  size: context.rIcon(16),
                  color: AppColors.skyBadge,
                ),
              ),
              SizedBox(width: context.rSpacing(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: context.rSpacing(6),
                      runSpacing: context.rSpacing(4),
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Daily Briefing Time',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize:
                                context.rFont(12.5, min: 11.5, max: 13.5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.rSpacing(7),
                                vertical: context.rSpacing(2),
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.skyBadge.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                profile.dailyMorningBriefingTime,
                                style: TextStyle(
                                  color: AppColors.skyBadge,
                                  fontSize: context.rFont(10, min: 9, max: 11),
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: context.rSpacing(3)),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: context.rIcon(15),
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: context.rSpacing(2)),
                    Text(
                      profile.isDailyBriefingEnabled
                          ? '${profile.dailyBriefingTopics.length} topik • ${profile.isDailyBriefingCompact ? 'Compact' : 'Detailed'}'
                          : 'Ringkasan pagi dimatikan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: context.rFont(11, min: 10, max: 12),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                key: const Key('desktop_daily_briefing_switch'),
                value: profile.isDailyBriefingEnabled,
                onChanged: onToggle,
                activeTrackColor: const Color(0xFF4EB089),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Right Panel Card 2: INTELLIGENT SYSTEM (`FigCraft node 6151` + SmartPriority Navigation & XAI Toast).
class DesktopIntelligentSystemCard extends StatelessWidget {
  final UserProfileModel profile;
  final VoidCallback onOpenSmartPriorityTap;
  final ValueChanged<bool> onToggleXai;

  const DesktopIntelligentSystemCard({
    super.key,
    required this.profile,
    required this.onOpenSmartPriorityTap,
    required this.onToggleXai,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.rSpacing(22)),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'INTELLIGENT SYSTEM',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.rSpacing(8),
                  vertical: context.rSpacing(3),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF63CDDA).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'AI Auto-Rank Active',
                  style: TextStyle(
                    color: const Color(0xFF63CDDA),
                    fontSize: context.rFont(10, min: 9, max: 11),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.rSpacing(14)),
          Material(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              key: const Key('desktop_fuzzy_model_row'),
              onTap: onOpenSmartPriorityTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.rSpacing(12),
                  vertical: context.rSpacing(11),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF778BEB).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.psychology_outlined,
                        size: context.rIcon(17),
                        color: const Color(0xFF778BEB),
                      ),
                    ),
                    SizedBox(width: context.rSpacing(10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fuzzy Inference Model',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize:
                                  context.rFont(12.5, min: 11.5, max: 13.5),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: context.rSpacing(2)),
                          Text(
                            'Mamdani Max-Min Core',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: context.rFont(11, min: 10, max: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.rSpacing(8),
                        vertical: context.rSpacing(3),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF786FA6).withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          color: const Color(0xFFD6D1FF),
                          fontSize: context.rFont(10.5, min: 9.5, max: 11.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: context.rSpacing(4)),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: context.rIcon(18),
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: context.rSpacing(10)),
          Container(
            key: const Key('desktop_xai_row'),
            padding: EdgeInsets.symmetric(
              horizontal: context.rSpacing(12),
              vertical: context.rSpacing(10),
            ),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4EB089).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    size: context.rIcon(16),
                    color: const Color(0xFF4EB089),
                  ),
                ),
                SizedBox(width: context.rSpacing(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explainable AI (XAI) Pop-up',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: context.rSpacing(2)),
                      Text(
                        'Tampilkan alasan pembobotan skor tugas',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: context.rFont(11, min: 10, max: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  key: const Key('desktop_xai_switch'),
                  value: profile.scoreExplainabilityEnabled,
                  onChanged: onToggleXai,
                  activeTrackColor: const Color(0xFF4EB089),
                ),
              ],
            ),
          ),
          SizedBox(height: context.rSpacing(12)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.rSpacing(14)),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Prioritization Weights:',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: context.rFont(12, min: 11, max: 13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.rSpacing(6)),
                const _WeightRuleLine('• Deadline Proximity: 45% (Sangat Mendesak)'),
                const _WeightRuleLine('• Bobot SKS / Nilai Mata Kuliah: 35%'),
                const _WeightRuleLine('• Tingkat Kompleksitas Tugas: 20%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightRuleLine extends StatelessWidget {
  final String text;

  const _WeightRuleLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.rSpacing(3)),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: context.rFont(11.5, min: 10.5, max: 12.5),
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Right Panel Card 3: SYSTEM ENVIRONMENT (`FigCraft node 6174`).
class DesktopSystemEnvironmentCard extends StatelessWidget {
  const DesktopSystemEnvironmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.rSpacing(20)),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYSTEM ENVIRONMENT',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: context.rFont(12, min: 11, max: 13),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: context.rSpacing(12)),
          const _EnvStatusLine(
            label: 'Tel-U SSO Session: Terhubung (CAS Active)',
          ),
          SizedBox(height: context.rSpacing(8)),
          const _EnvStatusLine(
            label: 'Database Sync: Live (PostgreSQL Cluster)',
          ),
        ],
      ),
    );
  }
}

class _EnvStatusLine extends StatelessWidget {
  final String label;

  const _EnvStatusLine({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF4EB089),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: context.rSpacing(8)),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(11.5, min: 10.5, max: 12.5),
            ),
          ),
        ),
      ],
    );
  }
}
