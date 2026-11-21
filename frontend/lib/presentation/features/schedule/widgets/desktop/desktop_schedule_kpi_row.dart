import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';

/// 4-column KPI summary row matching FigCraft `KPI Summary Row` (node 2622, height 60, gap 12).
class DesktopScheduleKpiRow extends StatelessWidget {
  final int totalSessionsCount;
  final int todayClassesCount;
  final int ongoingCount;
  final int teamMeetingsCount;
  final int studyHoursCount;
  final int activeSksCount;

  const DesktopScheduleKpiRow({
    super.key,
    this.totalSessionsCount = 15,
    this.todayClassesCount = 2,
    this.ongoingCount = 1,
    this.teamMeetingsCount = 5,
    this.studyHoursCount = 30,
    this.activeSksCount = 18,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _ScheduleKpiCardData(
        cardKey: const ValueKey('desktop_schedule_kpi_total'),
        title: '$totalSessionsCount Weekly Sessions',
        subtitle: 'Total Scheduled This Week',
        dotColor: const Color(0xFF63CDDA),
        isHighlighted: false,
      ),
      _ScheduleKpiCardData(
        cardKey: const ValueKey('desktop_schedule_kpi_today'),
        title: '$todayClassesCount Classes Today',
        subtitle: '$ongoingCount Currently Ongoing',
        dotColor: AppColors.primaryAccent,
        isHighlighted: true,
      ),
      _ScheduleKpiCardData(
        cardKey: const ValueKey('desktop_schedule_kpi_team'),
        title: '$teamMeetingsCount Team Meetings',
        subtitle: 'IMPAL & Study Hub Sync',
        dotColor: AppColors.purpleAccent,
        isHighlighted: false,
      ),
      _ScheduleKpiCardData(
        cardKey: const ValueKey('desktop_schedule_kpi_hours'),
        title: '$studyHoursCount Study Hours',
        subtitle: '$activeSksCount Active Credits (SKS)',
        dotColor: AppColors.skyBadge,
        isHighlighted: false,
      ),
    ];

    const gap = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          final cardWidth = (constraints.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final card in cards)
                SizedBox(
                  width: cardWidth,
                  child: _DesktopScheduleKpiCard(data: card),
                ),
            ],
          );
        }

        return SizedBox(
          height: 60,
          child: Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: gap),
                Expanded(child: _DesktopScheduleKpiCard(data: cards[i])),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ScheduleKpiCardData {
  final Key cardKey;
  final String title;
  final String subtitle;
  final Color dotColor;
  final bool isHighlighted;

  const _ScheduleKpiCardData({
    required this.cardKey,
    required this.title,
    required this.subtitle,
    required this.dotColor,
    required this.isHighlighted,
  });
}

class _DesktopScheduleKpiCard extends StatelessWidget {
  final _ScheduleKpiCardData data;

  const _DesktopScheduleKpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: data.cardKey,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: data.isHighlighted ? const Color(0xFF362C30) : AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: data.isHighlighted
              ? AppColors.primaryAccent
              : AppColors.borderSubtle,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(15, min: 14, max: 15),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: data.isHighlighted
                        ? AppColors.primaryAccent
                        : AppColors.textMuted,
                    fontSize: context.rFont(11, min: 10.5, max: 11),
                    fontFamily: 'Inter',
                    fontWeight:
                        data.isHighlighted ? FontWeight.w700 : FontWeight.w400,
                    height: 1.2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: data.dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

