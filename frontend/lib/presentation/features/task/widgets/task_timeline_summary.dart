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

  const TaskTimelineSummary({
    super.key,
    this.highCount = 3,
    this.mediumCount = 1,
    this.lowCount = 2,
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
              ),
            ),
            SizedBox(width: context.rSpacing(10)),
            Expanded(
              child: _buildCounterCard(
                context,
                count: mediumCount,
                label: 'Medium',
              ),
            ),
            SizedBox(width: context.rSpacing(10)),
            Expanded(
              child: _buildCounterCard(
                context,
                count: lowCount,
                label: 'Low',
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
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(14),
        vertical: context.rSpacing(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              color: AppColors.textWhite,
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
              color: AppColors.textMuted,
              fontSize: context.rFont(12, min: 11, max: 14),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
