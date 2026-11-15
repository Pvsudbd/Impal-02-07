import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';

/// Team's Schedule banner matching FigCraft `Section Teams Schedule` (node 5402)
/// inside `Desktop - Group Directory (List Kelompok)` (`1440×980`).
class DesktopTeamScheduleBanner extends StatelessWidget {
  final String title;
  final String platformLabel;
  final String agendaText;
  final String ctaLabel;
  final VoidCallback onJoinMeetingTap;
  final VoidCallback? onCreateMeetingTap;
  final VoidCallback? onSeeAllTap;
  final VoidCallback? onEditMeetingTap;
  final VoidCallback? onDeleteMeetingTap;
  final int currentIndex;
  final int totalCount;
  final VoidCallback? onPrevTap;
  final VoidCallback? onNextTap;

  const DesktopTeamScheduleBanner({
    super.key,
    this.title = 'MEETING IMPAL',
    this.platformLabel = 'Discord • Group IMPAL',
    this.agendaText =
        'Tomorrow 19:00 WIB • Agenda: Sprint 1 Review & UI Demo Prototype',
    this.ctaLabel = 'Join Discord Voice',
    required this.onJoinMeetingTap,
    this.onCreateMeetingTap,
    this.onSeeAllTap,
    this.onEditMeetingTap,
    this.onDeleteMeetingTap,
    this.currentIndex = 0,
    this.totalCount = 1,
    this.onPrevTap,
    this.onNextTap,
  });

  @override
  Widget build(BuildContext context) {
    final safeTotal = totalCount < 1 ? 1 : totalCount;
    final safeIndex = currentIndex.clamp(0, safeTotal - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                "Team's Schedule",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(15, min: 14, max: 17),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (safeTotal > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            key: const ValueKey(
                              'desktop_team_schedule_prev_btn',
                            ),
                            onTap: onPrevTap,
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                size: context.rIcon(16),
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '${safeIndex + 1}/$safeTotal',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          InkWell(
                            key: const ValueKey(
                              'desktop_team_schedule_next_btn',
                            ),
                            onTap: onNextTap,
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                size: context.rIcon(16),
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (onCreateMeetingTap != null)
                    Material(
                      color: AppColors.primaryAccent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        key: const ValueKey('desktop_team_create_meeting_btn'),
                        onTap: onCreateMeetingTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primaryAccent.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: context.rIcon(14),
                                color: AppColors.primaryAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Create Meeting',
                                style: TextStyle(
                                  color: AppColors.primaryAccent,
                                  fontSize: context.rFont(11, min: 10, max: 13),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (onSeeAllTap != null)
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
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          key: const ValueKey('desktop_team_schedule_banner_card'),
          constraints: const BoxConstraints(minHeight: 86),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 5dp solid coral vertical accent strip (node 5405)
                Container(
                  width: 5,
                  color: AppColors.primaryAccent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 20, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: context.rFont(
                                          15,
                                          min: 13.5,
                                          max: 15.5,
                                        ),
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      height: 20,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF63CDDA),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        platformLabel,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: Color(0xFF2A8F9C),
                                          fontSize: 10,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.access_time_rounded,
                                      size: 9,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      agendaText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: context.rFont(
                                          12,
                                          min: 11,
                                          max: 13,
                                        ),
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (onEditMeetingTap != null) ...[
                          Tooltip(
                            message: 'Edit Meeting',
                            child: Material(
                              color: AppColors.bgPrimary,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                key: const ValueKey(
                                  'desktop_team_edit_meeting_btn',
                                ),
                                onTap: onEditMeetingTap,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.borderSubtle,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.edit_rounded,
                                    size: context.rIcon(16),
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (onDeleteMeetingTap != null) ...[
                          Tooltip(
                            message: 'Delete Meeting',
                            child: Material(
                              color: AppColors.bgPrimary,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                key: const ValueKey(
                                  'desktop_team_delete_meeting_btn',
                                ),
                                onTap: onDeleteMeetingTap,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.error.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: context.rIcon(16),
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Material(
                          color: AppColors.primaryAccent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            key: const ValueKey(
                              'desktop_team_join_discord_btn',
                            ),
                            onTap: onJoinMeetingTap,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                ctaLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
