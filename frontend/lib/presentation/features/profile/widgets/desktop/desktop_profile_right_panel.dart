import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../models/user_profile_model.dart';

/// Right Panel Card: REMINDERS & SCHEDULE (`FigCraft node 6285`).
class DesktopRemindersScheduleCard extends StatelessWidget {
  final UserProfileModel profile;
  final void Function(AlertCategoryType category) onOpenCategoryModal;
  final void Function(AlertCategoryType category, bool enabled) onToggleCategory;
  final VoidCallback onOpenDailyBriefingModal;
  final ValueChanged<bool> onToggleDailyBriefing;
  final ValueChanged<bool>? onToggleSoundVibration;

  const DesktopRemindersScheduleCard({
    super.key,
    required this.profile,
    required this.onOpenCategoryModal,
    required this.onToggleCategory,
    required this.onOpenDailyBriefingModal,
    required this.onToggleDailyBriefing,
    this.onToggleSoundVibration,
  });

  String _formatScheduleSummary(UserProfileModel p) {
    final lectureOn = p.lectureScheduleAlerts.enabled;
    final externalOn = p.externalScheduleAlerts.enabled;
    if (!lectureOn && !externalOn) {
      return 'Disabled • Tap to configure';
    }
    return p.scheduleAlertsSummary;
  }

  String _formatTeamSummary(UserProfileModel p) {
    final taskOn = p.teamTaskAlerts.enabled;
    final meetingOn = p.teamMeetingAlerts.enabled;
    if (!taskOn && !meetingOn) {
      return 'Disabled • Tap to configure';
    }
    return p.teamAlertsSummary;
  }

  @override
  Widget build(BuildContext context) {
    final scheduleEnabled = profile.lectureScheduleAlerts.enabled ||
        profile.externalScheduleAlerts.enabled;
    final teamEnabled =
        profile.teamTaskAlerts.enabled || profile.teamMeetingAlerts.enabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REMINDERS & SCHEDULE',
          style: TextStyle(
            color: const Color(0xFF9CA3AF),
            fontSize: context.rFont(11, min: 10, max: 12),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(height: context.rSpacing(8)),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF3E4554)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _ReminderRow(
                key: const Key('desktop_alert_row_task'),
                icon: Icons.error_rounded,
                iconColor: AppColors.primary,
                title: 'Task Deadlines',
                subtitle: profile.taskDeadlineAlerts.enabled
                    ? profile.deadlineAlertsSummary
                    : 'Disabled • Tap to configure',
                subtitleColor: profile.taskDeadlineAlerts.enabled
                    ? AppColors.primaryAccent
                    : const Color(0xFF9CA3AF),
                enabled: profile.taskDeadlineAlerts.enabled,
                switchKey: const Key('desktop_alert_switch_task'),
                onTap: () =>
                    onOpenCategoryModal(AlertCategoryType.taskDeadline),
                onToggle: (val) =>
                    onToggleCategory(AlertCategoryType.taskDeadline, val),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFF3E4554),
              ),
              _ReminderRow(
                key: const Key('desktop_alert_row_schedule'),
                icon: Icons.calendar_today_rounded,
                iconColor: const Color(0xFF3B82F6),
                title: 'Schedule Alerts',
                subtitle: _formatScheduleSummary(profile),
                subtitleColor: scheduleEnabled
                    ? AppColors.primaryAccent
                    : const Color(0xFF9CA3AF),
                enabled: scheduleEnabled,
                switchKey: const Key('desktop_alert_switch_schedule'),
                onTap: () => onOpenCategoryModal(AlertCategoryType.schedule),
                onToggle: (val) =>
                    onToggleCategory(AlertCategoryType.schedule, val),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFF3E4554),
              ),
              _ReminderRow(
                key: const Key('desktop_alert_row_team'),
                icon: Icons.groups_rounded,
                iconColor: const Color(0xFFFBBF24),
                title: 'Team Alerts',
                subtitle: _formatTeamSummary(profile),
                subtitleColor: teamEnabled
                    ? AppColors.primaryAccent
                    : const Color(0xFF9CA3AF),
                enabled: teamEnabled,
                switchKey: const Key('desktop_alert_switch_team'),
                onTap: () => onOpenCategoryModal(AlertCategoryType.team),
                onToggle: (val) =>
                    onToggleCategory(AlertCategoryType.team, val),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFF3E4554),
              ),
              _ReminderRow(
                key: const Key('desktop_daily_briefing_row'),
                icon: Icons.wb_sunny_rounded,
                iconColor: const Color(0xFFFBBF24),
                title: 'Daily Morning Briefing',
                subtitle: profile.dailyBriefingSummary,
                subtitleColor: profile.isDailyBriefingEnabled
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFF9CA3AF),
                enabled: profile.isDailyBriefingEnabled,
                switchKey: const Key('desktop_daily_briefing_switch'),
                onTap: onOpenDailyBriefingModal,
                onToggle: onToggleDailyBriefing,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final bool enabled;
  final Key switchKey;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  const _ReminderRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    required this.enabled,
    required this.switchKey,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(16),
            vertical: context.rSpacing(14),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: context.rIcon(18), color: iconColor),
              ),
              SizedBox(width: context.rSpacing(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: context.rFont(13.5, min: 12, max: 15),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: context.rFont(11.5, min: 10.5, max: 12.5),
                        fontFamily: 'Inter',
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.rSpacing(10)),
              Switch(
                key: switchKey,
                value: enabled,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.statusCompleted,
                inactiveThumbColor: Colors.white70,
                inactiveTrackColor: const Color(0xFF434A59),
                onChanged: onToggle,
              ),
              SizedBox(width: context.rSpacing(4)),
              Icon(
                Icons.chevron_right_rounded,
                size: context.rIcon(18),
                color: const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Intelligent System (AI Fuzzy) Section (`FigCraft node 6285` Left Bottom).
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INTELLIGENT SYSTEM (AI FUZZY)',
          style: TextStyle(
            color: const Color(0xFF9CA3AF),
            fontSize: context.rFont(11, min: 10, max: 12),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(height: context.rSpacing(8)),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF3E4554)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const Key('desktop_fuzzy_model_row'),
                  onTap: onOpenSmartPriorityTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rSpacing(16),
                      vertical: context.rSpacing(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.settings_rounded,
                            size: context.rIcon(18),
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                        SizedBox(width: context.rSpacing(14)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fuzzy Inference Model',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize:
                                      context.rFont(13.5, min: 12, max: 15),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Mamdani Min-Max (Centroid Defuzzification)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: const Color(0xFF9CA3AF),
                                  fontSize:
                                      context.rFont(11.5, min: 10.5, max: 12.5),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: context.rSpacing(10)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.rSpacing(10),
                            vertical: context.rSpacing(4),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.statusCompleted
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.statusCompleted
                                  .withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(
                              color: AppColors.statusCompleted,
                              fontSize: context.rFont(10.5, min: 9.5, max: 11.5),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: context.rSpacing(10)),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: context.rIcon(18),
                          color: const Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFF3E4554),
              ),
              Padding(
                key: const Key('desktop_xai_row'),
                padding: EdgeInsets.symmetric(
                  horizontal: context.rSpacing(16),
                  vertical: context.rSpacing(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color:
                            AppColors.statusCompleted.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.lightbulb_rounded,
                        size: context.rIcon(18),
                        color: AppColors.statusCompleted,
                      ),
                    ),
                    SizedBox(width: context.rSpacing(14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Score Explainability (XAI)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: context.rFont(13.5, min: 12, max: 15),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Show mathematical reasons for task rank',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF9CA3AF),
                              fontSize:
                                  context.rFont(11.5, min: 10.5, max: 12.5),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: context.rSpacing(10)),
                    Switch(
                      key: const Key('desktop_xai_switch'),
                      value: profile.scoreExplainabilityEnabled,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.statusCompleted,
                      inactiveThumbColor: Colors.white70,
                      inactiveTrackColor: const Color(0xFF434A59),
                      onChanged: onToggleXai,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
