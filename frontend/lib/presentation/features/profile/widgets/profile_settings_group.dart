import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../models/user_profile_model.dart';
import 'deadline_alert_settings_modal.dart';

/// Grouped settings cards for Reminders & Alerts preferences.
/// Supports granular, independent alert configuration for:
/// 1. Task Deadlines (Personal assignments & submissions)
/// 2. Class Schedule (Lectures & laboratory sessions)
/// 3. Team Tasks & Meetings (Group work & sync discussions)
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
        } else if (onSaveAlertSettings != null && category == AlertCategoryType.taskDeadline) {
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
          config: profile.taskDeadlineAlerts,
        ),
        SizedBox(height: context.rSpacing(10)),

        // Category 2: Class Schedule
        _buildCategoryCard(
          context,
          category: AlertCategoryType.classSchedule,
          config: profile.classScheduleAlerts,
        ),
        SizedBox(height: context.rSpacing(10)),

        // Category 3: Team Tasks & Meetings
        _buildCategoryCard(
          context,
          category: AlertCategoryType.teamMeeting,
          config: profile.teamMeetingAlerts,
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required AlertCategoryType category,
    required CategoryAlertConfig config,
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
                // Leading Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: config.enabled
                        ? category.accentColor.withValues(alpha: 0.18)
                        : const Color(0xFF475569).withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    config.enabled
                        ? category.icon
                        : Icons.notifications_off_outlined,
                    size: 20,
                    color: config.enabled
                        ? category.accentColor
                        : const Color(0xFF94A3B8),
                  ),
                ),
                SizedBox(width: context.rSpacing(12)),

                // Title & Dynamic Summary Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(13.5, min: 12, max: 15),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        config.summary,
                        style: TextStyle(
                          color: config.enabled
                              ? AppColors.primaryAccent
                              : AppColors.textMuted,
                          fontSize: context.rFont(11, min: 10, max: 12.5),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Category Switch
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: config.enabled,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF10B981),
                    inactiveThumbColor: Colors.white70,
                    inactiveTrackColor: const Color(0xFF434A59),
                    onChanged: (val) {
                      UserProfileRepository().toggleCategoryAlert(category, val);
                      if (category == AlertCategoryType.taskDeadline) {
                        onToggleDeadlineAlerts?.call(val);
                      }
                    },
                  ),
                ),

                const SizedBox(width: 2),

                // Chevron indicating modal configurability
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
