import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../models/task_item_model.dart';

/// Priority KPI summary row matching FigCraft `Row KPI Priority` (node 2126).
/// Displays 4 metric cards: High Priority, Medium Priority, Low Priority, and Total Tasks.
class DesktopTaskKpiRow extends StatelessWidget {
  final int highCount;
  final int mediumCount;
  final int lowCount;
  final int totalCount;
  final int todayDueCount;
  final TaskPriorityLevel? selectedPriority;
  final ValueChanged<TaskPriorityLevel?>? onPriorityTap;

  const DesktopTaskKpiRow({
    super.key,
    required this.highCount,
    required this.mediumCount,
    required this.lowCount,
    required this.totalCount,
    required this.todayDueCount,
    this.selectedPriority,
    this.onPriorityTap,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiCardData(
        cardKey: const ValueKey('desktop_kpi_high'),
        badgeLabel: 'HIGH PRIORITY',
        badgeBg: AppColors.priorityHighBg,
        badgeTextColor: AppColors.priorityHighText,
        dotColor: AppColors.primary,
        valueText: '$highCount',
        subtitle: highCount == 1 ? 'Task pending' : 'Tasks pending',
        subtitleColor: AppColors.textMuted,
        isSelected: selectedPriority == TaskPriorityLevel.high,
        onTap: onPriorityTap == null
            ? null
            : () => onPriorityTap!(
                  selectedPriority == TaskPriorityLevel.high
                      ? null
                      : TaskPriorityLevel.high,
                ),
      ),
      _KpiCardData(
        cardKey: const ValueKey('desktop_kpi_medium'),
        badgeLabel: 'MEDIUM PRIORITY',
        badgeBg: AppColors.priorityMediumBg,
        badgeTextColor: AppColors.priorityMediumText,
        dotColor: AppColors.priorityMediumBg,
        valueText: '$mediumCount',
        subtitle: mediumCount == 1 ? 'Task this week' : 'Tasks this week',
        subtitleColor: AppColors.textMuted,
        isSelected: selectedPriority == TaskPriorityLevel.medium,
        onTap: onPriorityTap == null
            ? null
            : () => onPriorityTap!(
                  selectedPriority == TaskPriorityLevel.medium
                      ? null
                      : TaskPriorityLevel.medium,
                ),
      ),
      _KpiCardData(
        cardKey: const ValueKey('desktop_kpi_low'),
        badgeLabel: 'LOW PRIORITY',
        badgeBg: AppColors.priorityLowBg,
        badgeTextColor: AppColors.priorityLowText,
        dotColor: AppColors.mintAccent,
        valueText: '$lowCount',
        subtitle: lowCount == 1 ? 'Task on track' : 'Tasks on track',
        subtitleColor: AppColors.textMuted,
        isSelected: selectedPriority == TaskPriorityLevel.low,
        onTap: onPriorityTap == null
            ? null
            : () => onPriorityTap!(
                  selectedPriority == TaskPriorityLevel.low
                      ? null
                      : TaskPriorityLevel.low,
                ),
      ),
      _KpiCardData(
        cardKey: const ValueKey('desktop_kpi_total'),
        badgeLabel: 'TOTAL TASKS',
        badgeBg: AppColors.skyBadge,
        badgeTextColor: AppColors.skyBadgeText,
        dotColor: const Color(0xFF60A5FA),
        valueText: '$totalCount',
        subtitle: '$todayDueCount due today',
        subtitleColor: AppColors.primary,
        isSelected: selectedPriority == null && false,
        onTap: onPriorityTap == null ? null : () => onPriorityTap!(null),
      ),
    ];

    final gap = context.rSpacing(12);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          final cardWidth = (constraints.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final card in cards)
                SizedBox(
                  width: cardWidth,
                  child: _DesktopKpiCard(data: card),
                ),
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: _DesktopKpiCard(data: cards[i])),
              if (i < cards.length - 1) SizedBox(width: gap),
            ],
          ],
        );
      },
    );
  }
}

class _KpiCardData {
  final Key cardKey;
  final String badgeLabel;
  final Color badgeBg;
  final Color badgeTextColor;
  final Color dotColor;
  final String valueText;
  final String subtitle;
  final Color subtitleColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const _KpiCardData({
    required this.cardKey,
    required this.badgeLabel,
    required this.badgeBg,
    required this.badgeTextColor,
    required this.dotColor,
    required this.valueText,
    required this.subtitle,
    required this.subtitleColor,
    required this.isSelected,
    this.onTap,
  });
}

class _DesktopKpiCard extends StatelessWidget {
  final _KpiCardData data;

  const _DesktopKpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final radius = context.rSpacing(16);

    return RepaintBoundary(
      child: Material(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          key: data.cardKey,
          onTap: data.onTap,
          borderRadius: BorderRadius.circular(radius),
          hoverColor: Colors.white.withValues(alpha: 0.03),
          child: Container(
            constraints: const BoxConstraints(minHeight: 86),
            padding: EdgeInsets.symmetric(
              horizontal: context.rSpacing(14),
              vertical: context.rSpacing(12),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: data.isSelected
                    ? data.badgeBg
                    : AppColors.borderSubtle,
                width: data.isSelected ? 1.4 : 0.9,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.rSpacing(7),
                          vertical: context.rSpacing(3),
                        ),
                        decoration: BoxDecoration(
                          color: data.badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          data.badgeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: data.badgeTextColor,
                            fontSize: context.rFont(9, min: 8.5, max: 10),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: context.rIcon(8),
                      height: context.rIcon(8),
                      decoration: BoxDecoration(
                        color: data.dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.rSpacing(10)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      data.valueText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(24, min: 20, max: 26),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    SizedBox(width: context.rSpacing(8)),
                    Expanded(
                      child: Text(
                        data.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: data.subtitleColor,
                          fontSize: context.rFont(11.5, min: 10, max: 12.5),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
