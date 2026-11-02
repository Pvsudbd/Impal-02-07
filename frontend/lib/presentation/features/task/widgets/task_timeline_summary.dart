import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';

/// Section showing Timeline priority counters in 3 side-by-side cards.
///
/// Complies with AGENTS.md ResponsiveContext and Tabular Numbers rule.
class TaskTimelineSummary extends StatelessWidget {
  final int highCount;
  final int mediumCount;
  final int lowCount;
  final String? selectedPriority;
  final ValueChanged<String?>? onPrioritySelected;

  const TaskTimelineSummary({
    super.key,
    this.highCount = 3,
    this.mediumCount = 1,
    this.lowCount = 2,
    this.selectedPriority,
    this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Timeline',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: context.rFont(18, min: 16, max: 22),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.20,
          ),
        ),
        SizedBox(height: context.rSpacing(10)),
        Row(
          children: [
            Expanded(
              child: _buildCounterCard(
                context,
                count: highCount,
                label: 'High',
                isSelected: selectedPriority?.toLowerCase() == 'high',
                onTap: () => onPrioritySelected?.call(
                  selectedPriority?.toLowerCase() == 'high' ? null : 'High',
                ),
              ),
            ),
            SizedBox(width: context.rSpacing(10)),
            Expanded(
              child: _buildCounterCard(
                context,
                count: mediumCount,
                label: 'Medium',
                isSelected: selectedPriority?.toLowerCase() == 'medium',
                onTap: () => onPrioritySelected?.call(
                  selectedPriority?.toLowerCase() == 'medium' ? null : 'Medium',
                ),
              ),
            ),
            SizedBox(width: context.rSpacing(10)),
            Expanded(
              child: _buildCounterCard(
                context,
                count: lowCount,
                label: 'Low',
                isSelected: selectedPriority?.toLowerCase() == 'low',
                onTap: () => onPrioritySelected?.call(
                  selectedPriority?.toLowerCase() == 'low' ? null : 'Low',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterCard(
    BuildContext context, {
    required int count,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.rSpacing(14),
          vertical: context.rSpacing(12),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAccent.withValues(alpha: 0.12)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                color: isSelected ? AppColors.primaryAccent : AppColors.textWhite,
                fontSize: context.rFont(20, min: 17, max: 24),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMuted,
                fontSize: context.rFont(12, min: 11, max: 14),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
