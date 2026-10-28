import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../common_widgets/impal_schedule_card.dart';
import '../../jadwal/models/schedule_model.dart';
import '../../jadwal/models/schedule_repository.dart';

/// Reusable team schedule section for both Team List and Team Dashboard.
class TeamScheduleSection extends StatelessWidget {
  final bool isDashboard;
  final VoidCallback onActionTap;
  final VoidCallback? onAddScheduleTap;
  final void Function(ScheduleModel) onEditSchedule;
  final void Function(ScheduleModel) onDeleteSchedule;

  const TeamScheduleSection({
    super.key,
    this.isDashboard = false,
    required this.onActionTap,
    this.onAddScheduleTap,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
  });

  String _formatScheduleTime(ScheduleModel schedule) {
    final now = DateTime.now();
    final scheduleDate =
        DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    String dayPrefix;
    if (scheduleDate == today) {
      dayPrefix = 'Today';
    } else if (scheduleDate == tomorrow) {
      dayPrefix = 'Tomorrow';
    } else if (scheduleDate == yesterday) {
      dayPrefix = 'Yesterday';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      dayPrefix = '${schedule.date.day} ${months[schedule.date.month - 1]}';
    }

    final timeStr = schedule.timeEnd.isNotEmpty
        ? '${schedule.timeStart} - ${schedule.timeEnd} ${schedule.timeZone}'
        : '${schedule.timeStart} ${schedule.timeZone}';
    return '$dayPrefix • $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ScheduleModel>>(
      valueListenable: ScheduleRepository().schedulesNotifier,
      builder: (context, allSchedules, _) {
        final rawTeamSchedules = allSchedules.where((s) {
          final type = s.type.trim().toLowerCase();
          if (type == 'lecture') return false;
          if (type == 'team' ||
              type == 'team meeting' ||
              type == 'meeting' ||
              type == 'rapat' ||
              type == 'group') {
            return true;
          }

          final t = s.title.toLowerCase();
          final n = (s.notes ?? '').toLowerCase();
          final loc = (s.location ?? '').toLowerCase();

          if (t.contains('ujian') ||
              t.contains('uts') ||
              t.contains('uas') ||
              t.contains('kuis')) {
            return false;
          }

          return t.contains('meet') ||
              t.contains('rapat') ||
              t.contains('diskusi') ||
              t.contains('team') ||
              t.contains('tim') ||
              t.contains('kelompok') ||
              t.contains('mentoring') ||
              t.contains('briefing') ||
              t.contains('standup') ||
              t.contains('sync') ||
              t.contains('sprint') ||
              t.contains('evaluasi') ||
              t.contains('koordinasi') ||
              n.contains('meet') ||
              n.contains('rapat') ||
              n.contains('diskusi') ||
              n.contains('kelompok') ||
              n.contains('mentoring') ||
              n.contains('sprint') ||
              loc.contains('group') ||
              loc.contains('tim') ||
              loc.contains('team') ||
              loc.contains('discord') ||
              loc.contains('meet') ||
              loc.contains('zoom');
        }).toList();

        final teamSchedules = rawTeamSchedules;
        teamSchedules.sort((a, b) {
          int statusWeight(String s) {
            final st = s.toLowerCase();
            if (st == 'overdue' || st == 'completed') return 0;
            if (st == 'ongoing') return 1;
            return 2;
          }

          final wA = statusWeight(a.status);
          final wB = statusWeight(b.status);
          if (wA != wB) return wA.compareTo(wB);

          final dtA = a.startDateTime ?? DateTime(2000);
          final dtB = b.startDateTime ?? DateTime(2000);
          return dtA.compareTo(dtB);
        });

        Widget scheduleContent;
        if (teamSchedules.isEmpty) {
          scheduleContent = isDashboard
              ? ImpalScheduleCard(
                  schedule: ScheduleRepository.defaultTeamSchedule,
                  isHorizontal: false,
                  isLast: true,
                  customTimeText: _formatScheduleTime(ScheduleRepository.defaultTeamSchedule),
                  onEdit: () => onEditSchedule(ScheduleRepository.defaultTeamSchedule),
                  onDelete: () => onDeleteSchedule(ScheduleRepository.defaultTeamSchedule),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'No team schedules yet',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: onAddScheduleTap ?? onActionTap,
                        child: const Text(
                          '+ Add Team Schedule',
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 12.5,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
        } else if (teamSchedules.length == 1) {
          scheduleContent = ImpalScheduleCard(
            schedule: teamSchedules.first,
            isHorizontal: false,
            isLast: true,
            customTimeText: _formatScheduleTime(teamSchedules.first),
            onEdit: () => onEditSchedule(teamSchedules.first),
            onDelete: () => onDeleteSchedule(teamSchedules.first),
          );
        } else {
          scheduleContent = ImpalHorizontalScheduleList(
            scrollKey: isDashboard
                ? const ValueKey('team_dashboard_schedules_horizontal_scroll')
                : const ValueKey('team_schedules_horizontal_scroll'),
            schedules: teamSchedules,
            customTimeFormatter: _formatScheduleTime,
            onEdit: onEditSchedule,
            onDelete: onDeleteSchedule,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    "Team's Schedule",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isDashboard)
                  GestureDetector(
                    key: const ValueKey('dashboard_create_meeting_button'),
                    onTap: onActionTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '+ Create Meeting',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    key: const ValueKey('team_schedule_see_all'),
                    onTap: onActionTap,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Text(
                        'See all',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            scheduleContent,
          ],
        );
      },
    );
  }
}
