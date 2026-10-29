import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../models/user_profile_model.dart';
import 'deadline_alert_settings_modal.dart';

/// Grouped settings cards for Reminders & Alerts preferences.
/// Supports 3 high-level pillars with progressive sub-disclosure:
/// 1. Task Deadlines (Personal assignments & submissions)
/// 2. Schedule Alerts (Lecture schedule & external schedule)
/// 3. Team Alerts (Team tasks & team meetings)
class ProfileSettingsGroup extends StatelessWidget {
  final UserProfileModel profile;
  final ValueChanged<bool>? onToggleDeadlineAlerts;
  final void Function({
    required bool enabled,
    required List<String> timings,
    required AlertSoundVibrationMode mode,
  })? onSaveAlertSettings;
  final void Function({
    required AlertCategoryType category,
    required bool enabled,
    required List<String> timings,
    required AlertSoundVibrationMode mode,
  })? onSaveCategoryAlertSettings;

  const ProfileSettingsGroup({
    super.key,
    required this.profile,
    this.onToggleDeadlineAlerts,
    this.onSaveAlertSettings,
    this.onSaveCategoryAlertSettings,
  });

  void _openAlertSettingsModal(BuildContext context, AlertCategoryType category) {
    DeadlineAlertSettingsModal.show(
      context,
      profile: profile,
      category: category,
      onSave: ({required enabled, required timings, required mode}) {
        if (onSaveCategoryAlertSettings != null) {
          onSaveCategoryAlertSettings!(
            category: category,
            enabled: enabled,
            timings: timings,
            mode: mode,
          );
        } else if (onSaveAlertSettings != null &&
            category == AlertCategoryType.taskDeadline) {
          onSaveAlertSettings!(
            enabled: enabled,
            timings: timings,
            mode: mode,
          );
        } else {
          UserProfileRepository().updateCategoryAlertSettings(
            category: category,
            enabled: enabled,
            timings: timings,
            mode: mode,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'REMINDERS & SCHEDULE',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: context.rFont(11.5, min: 10, max: 13),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: context.rSpacing(10)),

        // Category 1: Task Deadlines
        _buildCategoryCard(
          context,
          category: AlertCategoryType.taskDeadline,
          title: 'Task Deadlines',
          summary: profile.taskDeadlineAlerts.summary,
          isEnabled: profile.taskDeadlineAlerts.enabled,
          onToggle: (val) {
            UserProfileRepository().toggleCategoryAlert(
              AlertCategoryType.taskDeadline,
              val,
            );
          },
        ),
        SizedBox(height: context.rSpacing(10)),

        // Category 2: Schedule Alerts (Lecture & External)
        _buildCategoryCard(
          context,
          category: AlertCategoryType.schedule,
          title: 'Schedule Alerts',
          summary: profile.scheduleAlertsSummary,
          isEnabled: profile.lectureScheduleAlerts.enabled ||
              profile.externalScheduleAlerts.enabled,
          onToggle: (val) {
            final repo = UserProfileRepository();
            repo.updateScheduleAlertSettings(
              lectureConfig:
                  profile.lectureScheduleAlerts.copyWith(enabled: val),
              externalConfig:
                  profile.externalScheduleAlerts.copyWith(enabled: val),
            );
          },
        ),
        SizedBox(height: context.rSpacing(10)),

        // Category 3: Team Alerts (Tasks & Meetings)
        _buildCategoryCard(
          context,
          category: AlertCategoryType.team,
          title: 'Team Alerts',
          summary: profile.teamAlertsSummary,
          isEnabled: profile.teamTaskAlerts.enabled ||
              profile.teamMeetingAlerts.enabled,
          onToggle: (val) {
            final repo = UserProfileRepository();
            repo.updateTeamAlertSettings(
              teamTaskConfig: profile.teamTaskAlerts.copyWith(enabled: val),
              teamMeetingConfig:
                  profile.teamMeetingAlerts.copyWith(enabled: val),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required AlertCategoryType category,
    required String title,
    required String summary,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF434A59).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openAlertSettingsModal(context, category),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.rSpacing(14),
              vertical: context.rSpacing(13),
            ),
            child: Row(
              children: [
                // Squared container (kotak rounded 10dp) matching Account & Integration
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? category.accentColor.withValues(alpha: 0.18)
                        : const Color(0xFF475569).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isEnabled
                        ? category.icon
                        : Icons.notifications_off_outlined,
                    size: 20,
                    color: isEnabled
                        ? category.accentColor
                        : const Color(0xFF94A3B8),
                  ),
                ),
                SizedBox(width: context.rSpacing(12)),
                // Text Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(14, min: 12.5, max: 16),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isEnabled
                              ? const Color(0xFFFA6144)
                              : AppColors.textMuted,
                          fontSize: context.rFont(11.5, min: 10, max: 13),
                          fontFamily: 'Inter',
                          fontWeight:
                              isEnabled ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Switch
                Switch(
                  value: isEnabled,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF10B981),
                  inactiveThumbColor: Colors.white70,
                  inactiveTrackColor: const Color(0xFF434A59),
                  onChanged: onToggle,
                ),
                const SizedBox(width: 4),
                // Chevron icon indicating tap-to-open modal
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
