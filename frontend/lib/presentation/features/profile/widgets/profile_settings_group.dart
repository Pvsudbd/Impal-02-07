import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../common_widgets/impal_time_picker_dialog.dart';
import '../models/user_profile_model.dart';

/// Grouped settings cards for Reminders & Schedule preferences.
class ProfileSettingsGroup extends StatelessWidget {
  final UserProfileModel profile;
  final ValueChanged<bool>? onToggleDeadlineAlerts;
  final ValueChanged<bool>? onToggleSoundVibration;
  final ValueChanged<String>? onBriefingTimeChanged;

  const ProfileSettingsGroup({
    super.key,
    required this.profile,
    this.onToggleDeadlineAlerts,
    this.onToggleSoundVibration,
    this.onBriefingTimeChanged,
  });

  Future<void> _pickBriefingTime(BuildContext context) async {
    // Parse current time string (e.g. '07:00 WIB')
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(profile.dailyMorningBriefingTime);
    final initialHour = match != null ? int.tryParse(match.group(1)!) ?? 7 : 7;
    final initialMinute = match != null ? int.tryParse(match.group(2)!) ?? 0 : 0;

    final picked = await showImpalTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );

    if (picked != null && onBriefingTimeChanged != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      onBriefingTimeChanged!('$h:$m WIB');
    }
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

        // Grouped Settings Container
        Container(
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
          child: Column(
            children: [
              // 1. Deadline Alerts
              _buildSettingTile(
                context,
                icon: Icons.notifications_none_rounded,
                iconBgColor: const Color(0xFFFF5E4D).withValues(alpha: 0.18),
                iconColor: const Color(0xFFFF7D65),
                title: 'Deadline Alerts',
                subtitle: 'Automatic alarm at H-3, H-1 & Day H',
                trailing: Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: profile.deadlineAlertsEnabled,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF10B981),
                    inactiveThumbColor: Colors.white70,
                    inactiveTrackColor: const Color(0xFF434A59),
                    onChanged: onToggleDeadlineAlerts,
                  ),
                ),
              ),

              const Divider(height: 1, color: Color(0xFF383F4D), indent: 16, endIndent: 16),

              // 2. Daily Morning Briefing
              _buildSettingTile(
                context,
                icon: Icons.access_time_rounded,
                iconBgColor: const Color(0xFF5B93FF).withValues(alpha: 0.18),
                iconColor: const Color(0xFF5B93FF),
                title: 'Daily Morning Briefing',
                subtitle: "Summary of today's classes & urgent tasks",
                trailing: InkWell(
                  onTap: () => _pickBriefingTime(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile.dailyMorningBriefingTime,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(12.5, min: 11, max: 14),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(height: 1, color: Color(0xFF383F4D), indent: 16, endIndent: 16),

              // 3. Sound & Vibration
              _buildSettingTile(
                context,
                icon: Icons.volume_up_outlined,
                iconBgColor: const Color(0xFFFBBF24).withValues(alpha: 0.18),
                iconColor: const Color(0xFFFBBF24),
                title: 'Sound & Vibration',
                subtitle: 'Use system default notification ringtone',
                trailing: Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: profile.soundVibrationEnabled,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF10B981),
                    inactiveThumbColor: Colors.white70,
                    inactiveTrackColor: const Color(0xFF434A59),
                    onChanged: onToggleSoundVibration,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(14),
        vertical: context.rSpacing(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          SizedBox(width: context.rSpacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(13.5, min: 12, max: 15),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: context.rFont(11, min: 10, max: 12.5),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}
