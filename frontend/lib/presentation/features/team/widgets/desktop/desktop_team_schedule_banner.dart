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

  const DesktopTeamScheduleBanner({
    super.key,
    this.title = 'MEETING IMPAL',
    this.platformLabel = 'Discord • Group IMPAL',
    this.agendaText =
        'Tomorrow 19:00 WIB • Agenda: Sprint 1 Review & UI Demo Prototype',
    this.ctaLabel = 'Join Discord Voice',
    required this.onJoinMeetingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
                              child: const Text(
                                'Join Discord Voice',
                                style: TextStyle(
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
