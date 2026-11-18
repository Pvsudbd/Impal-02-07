import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../models/task_item_model.dart';

/// Timeline priority summary section matching FigCraft `Section Timeline Summary` (node 2341)
/// inside `Desktop - Tasks Management`.
class DesktopTaskKpiRow extends StatelessWidget {
  final int highCount;
  final int mediumCount;
  final int lowCount;
  final int totalCount;
  final int todayDueCount;
  final TaskPriorityLevel? selectedPriority;
  final ValueChanged<TaskPriorityLevel?>? onPriorityTap;
  final VoidCallback? onSmartPriorityTap;

  const DesktopTaskKpiRow({
    super.key,
    required this.highCount,
    required this.mediumCount,
    required this.lowCount,
    this.totalCount = 0,
    this.todayDueCount = 0,
    this.selectedPriority,
    this.onPriorityTap,
    this.onSmartPriorityTap,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _TimelinePriorityCardData(
        cardKey: const ValueKey('desktop_kpi_high'),
        countText: '$highCount',
        label: 'High',
        accentBorderColor: AppColors.priorityHighBg,
        isSelected: selectedPriority == TaskPriorityLevel.high,
        onTap: onPriorityTap == null
            ? null
            : () => onPriorityTap!(
                  selectedPriority == TaskPriorityLevel.high
                      ? null
                      : TaskPriorityLevel.high,
                ),
      ),
      _TimelinePriorityCardData(
        cardKey: const ValueKey('desktop_kpi_medium'),
        countText: '$mediumCount',
        label: 'Medium',
        accentBorderColor: AppColors.priorityMediumBg,
        isSelected: selectedPriority == TaskPriorityLevel.medium,
        onTap: onPriorityTap == null
            ? null
            : () => onPriorityTap!(
                  selectedPriority == TaskPriorityLevel.medium
                      ? null
                      : TaskPriorityLevel.medium,
                ),
      ),
      _TimelinePriorityCardData(
        cardKey: const ValueKey('desktop_kpi_low'),
        countText: '$lowCount',
        label: 'Low',
        accentBorderColor: AppColors.priorityLowBg,
        isSelected: selectedPriority == TaskPriorityLevel.low,
        onTap: onPriorityTap == null
            ? null
            : () => onPriorityTap!(
                  selectedPriority == TaskPriorityLevel.low
                      ? null
                      : TaskPriorityLevel.low,
                ),
      ),
    ];

    const gap = 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Timeline',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.rFont(18, min: 16, max: 19),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 380) {
              return Column(
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    _TimelinePriorityCard(data: cards[i]),
                    if (i < cards.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );
            }

            return Row(
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  Expanded(child: _TimelinePriorityCard(data: cards[i])),
                  if (i < cards.length - 1) const SizedBox(width: gap),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        RepaintBoundary(
          child: Material(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              key: const ValueKey('desktop_ai_smart_priority_bar'),
              onTap: onSmartPriorityTap,
              borderRadius: BorderRadius.circular(10),
              hoverColor: Colors.white.withValues(alpha: 0.03),
              child: Container(
                constraints: const BoxConstraints(minHeight: 39),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.psychology_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI Smart Priority Ranking',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(12.5, min: 11.5, max: 13),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F3534),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Mamdani CoG',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10.5,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
        ),
      ],
    );
  }
}

class _TimelinePriorityCardData {
  final Key cardKey;
  final String countText;
  final String label;
  final Color accentBorderColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TimelinePriorityCardData({
    required this.cardKey,
    required this.countText,
    required this.label,
    required this.accentBorderColor,
    required this.isSelected,
    this.onTap,
  });
}

class _TimelinePriorityCard extends StatelessWidget {
  final _TimelinePriorityCardData data;

  const _TimelinePriorityCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: data.cardKey,
          onTap: data.onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.white.withValues(alpha: 0.03),
          child: Container(
            height: 69,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: data.isSelected
                    ? data.accentBorderColor
                    : AppColors.borderSubtle,
                width: data.isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.countText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(20, min: 18, max: 22),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: context.rFont(12, min: 11, max: 12.5),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
