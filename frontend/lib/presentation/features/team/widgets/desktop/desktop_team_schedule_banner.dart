import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../schedule/models/schedule_model.dart';

/// 2-card Team's Schedule section matching FigCraft
/// `Desktop - Group Directory` (node 5647) and `Desktop - Group Workspace` (node 5968).
class DesktopTeamScheduleBanner extends StatelessWidget {
  final Key? containerKey;
  final Key? joinButtonKey;
  final List<ScheduleModel> meetings;
  final bool showCreateMeetingButton;
  final VoidCallback? onCreateMeetingTap;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<ScheduleModel> onJoinMeetingTap;
  final ValueChanged<ScheduleModel>? onEditMeetingTap;
  final ValueChanged<ScheduleModel>? onDeleteMeetingTap;
  final ValueChanged<ScheduleModel>? onToggleAlertTap;

  const DesktopTeamScheduleBanner({
    super.key,
    this.containerKey,
    this.joinButtonKey,
    required this.meetings,
    this.showCreateMeetingButton = false,
    this.onCreateMeetingTap,
    this.onSeeAllTap,
    required this.onJoinMeetingTap,
    this.onEditMeetingTap,
    this.onDeleteMeetingTap,
    this.onToggleAlertTap,
  });

  List<ScheduleModel> _orderedVisibleMeetings() {
    if (meetings.isEmpty) return const <ScheduleModel>[];

    // Separate user-created custom meetings so new additions stay immediately visible.
    final custom = meetings
        .where((m) => m.id != 'sch_3' && m.id != 'sch_4')
        .toList();
    final sch4 = meetings.where((m) => m.id == 'sch_4').firstOrNull;
    final sch3 = meetings.where((m) => m.id == 'sch_3').firstOrNull;

    final defaultsOrdered = <ScheduleModel>[
      if (sch4 != null) sch4,
      if (sch3 != null) sch3,
    ];

    return [...custom, ...defaultsOrdered].take(2).toList();
  }

  bool _isOngoingCard(ScheduleModel m) {
    if (m.status.trim().toLowerCase() == 'ongoing') return true;
    return m.id == 'sch_3' && m.title.trim() == 'MEETING IMPAL';
  }

  bool _isJoinableCard(ScheduleModel m) {
    if (_isOngoingCard(m)) return true;
    final url = m.meetingUrl?.trim() ?? '';
    final loc = m.location?.toLowerCase() ?? '';
    return url.isNotEmpty || loc.contains('discord') || loc.contains('meet');
  }

  String _formatCardTime(ScheduleModel m) {
    if (m.id == 'sch_3' && m.title.trim() == 'MEETING IMPAL') {
      return 'Today • ${m.timeStart} - ${m.timeEnd} WIB';
    }
    if (m.id == 'sch_4' && m.title.trim() == 'IMPAL Project Mentoring') {
      return 'Tomorrow • ${m.timeStart} - ${m.timeEnd} WIB';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(m.date.year, m.date.month, m.date.day);
    final diff = d.difference(today).inDays;
    final dayLabel = switch (diff) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}',
    };
    return '$dayLabel • ${m.timeStart} - ${m.timeEnd} ${m.timeZone}';
  }

  @override
  Widget build(BuildContext context) {
    final visible = _orderedVisibleMeetings();
    final primaryId = visible.any((m) => _isOngoingCard(m))
        ? visible.firstWhere((m) => _isOngoingCard(m)).id
        : (visible.isNotEmpty ? visible.last.id : '');

    return Column(
      key: containerKey ?? const ValueKey('desktop_team_schedule_banner'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                "Team's Schedule",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(18, min: 15, max: 18),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (showCreateMeetingButton && onCreateMeetingTap != null)
              Material(
                color: AppColors.primaryAccent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  key: const ValueKey(
                    'desktop_workspace_section_create_meeting_btn',
                  ),
                  onTap: onCreateMeetingTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Center(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: Text(
                        '+ Create Meeting',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else if (onSeeAllTap != null)
              InkWell(
                key: const ValueKey('desktop_team_schedule_see_all_btn'),
                onTap: onSeeAllTap,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: AppColors.primaryAccent,
                      fontSize: context.rFont(12, min: 11, max: 13),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          _buildEmptyBanner()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final useSingleColumn =
                  constraints.maxWidth < 520 || visible.length == 1;
              if (useSingleColumn) {
                return Column(
                  children: [
                    for (int i = 0; i < visible.length; i++) ...[
                      _buildScheduleCard(
                        context,
                        visible[i],
                        isPrimaryCard: visible[i].id == primaryId,
                      ),
                      if (i < visible.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildScheduleCard(
                        context,
                        visible[0],
                        isPrimaryCard: visible[0].id == primaryId,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildScheduleCard(
                        context,
                        visible[1],
                        isPrimaryCard: visible[1].id == primaryId,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'No upcoming team meetings. Create a meeting to sync with your group.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ),
          if (onCreateMeetingTap != null) ...[
            const SizedBox(width: 12),
            ElevatedButton(
              key: const ValueKey('desktop_team_create_meeting_btn'),
              onPressed: onCreateMeetingTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '+ Create Meeting',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    ScheduleModel schedule, {
    required bool isPrimaryCard,
  }) {
    final isOngoing = _isOngoingCard(schedule);
    final isJoinable = _isJoinableCard(schedule);
    final accentColor =
        isOngoing ? AppColors.primaryAccent : AppColors.textMuted;
    final statusLabel = isOngoing
        ? 'Ongoing'
        : (schedule.status.trim().isNotEmpty ? schedule.status : 'Upcoming');
    final locationText = (schedule.location?.trim().isNotEmpty ?? false)
        ? schedule.location!.trim()
        : (schedule.teamName?.trim().isNotEmpty ?? false)
            ? schedule.teamName!.trim()
            : 'Online Meeting';
    final timeText = _formatCardTime(schedule);

    final editKey = isPrimaryCard
        ? const ValueKey('desktop_team_edit_meeting_btn')
        : ValueKey('desktop_team_edit_meeting_${schedule.id}');
    final deleteKey = isPrimaryCard
        ? const ValueKey('desktop_team_delete_meeting_btn')
        : ValueKey('desktop_team_delete_meeting_${schedule.id}');
    final joinKey = isPrimaryCard
        ? (joinButtonKey ?? const ValueKey('desktop_team_join_discord_btn'))
        : ValueKey('desktop_team_join_meeting_${schedule.id}');

    return Container(
      key: ValueKey('desktop_team_schedule_card_${schedule.id}'),
      constraints: const BoxConstraints(minHeight: 96),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            schedule.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.rFont(
                                14.5,
                                min: 13.5,
                                max: 15,
                              ),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          key: ValueKey(
                            'desktop_team_alert_meeting_${schedule.id}',
                          ),
                          onTap: onToggleAlertTap == null
                              ? null
                              : () => onToggleAlertTap!(schedule),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              schedule.isAlertEnabled
                                  ? Icons.notifications_none_rounded
                                  : Icons.notifications_off_outlined,
                              size: 15,
                              color: accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          height: 17,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            widthFactor: 1.0,
                            heightFactor: 1.0,
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: isOngoing
                                    ? Colors.white
                                    : const Color(0xFF1F232B),
                                fontSize: 9.5,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      locationText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.access_time_rounded,
                            size: 9,
                            color: isOngoing
                                ? Colors.white
                                : const Color(0xFF1F232B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            timeText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10.5,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        if (isJoinable) ...[
                          const SizedBox(width: 8),
                          Material(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(999),
                            child: InkWell(
                              key: joinKey,
                              onTap: () => onJoinMeetingTap(schedule),
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                height: 21,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.videocam_rounded,
                                      size: 11,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Join Call',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (onEditMeetingTap != null) ...[
                          const SizedBox(width: 6),
                          Tooltip(
                            message: 'Edit Meeting',
                            child: InkWell(
                              key: editKey,
                              onTap: () => onEditMeetingTap!(schedule),
                              borderRadius: BorderRadius.circular(4),
                              child: const Padding(
                                padding: EdgeInsets.all(2),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 15,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (onDeleteMeetingTap != null) ...[
                          const SizedBox(width: 4),
                          Tooltip(
                            message: 'Delete Meeting',
                            child: InkWell(
                              key: deleteKey,
                              onTap: () => onDeleteMeetingTap!(schedule),
                              borderRadius: BorderRadius.circular(4),
                              child: const Padding(
                                padding: EdgeInsets.all(2),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 15,
                                  color: AppColors.primaryAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
