import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../models/task_item_model.dart';

/// Interactive selector for Course Grade Weight with an Automatic toggle.
///
/// Features:
/// - "Course Grade Weight" label with an "Automatic" checkbox aligned on top right
/// - 3 side-by-side buttons: High, Medium, Low
/// - Complies with AGENTS.md ResponsiveContext and touch target standards.
class CourseGradeWeightChips extends StatelessWidget {
  final TaskPriorityLevel selectedPriority;
  final bool isAutomatic;
  final ValueChanged<TaskPriorityLevel> onPriorityChanged;
  final ValueChanged<bool> onAutomaticChanged;

  const CourseGradeWeightChips({
    super.key,
    required this.selectedPriority,
    required this.isAutomatic,
    required this.onPriorityChanged,
    required this.onAutomaticChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Course Grade Weight',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: context.rFont(13, min: 11, max: 15),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            InkWell(
              onTap: () => onAutomaticChanged(!isAutomatic),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isAutomatic ? AppColors.primary : const Color(0xFF1E232D),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isAutomatic ? AppColors.primary : AppColors.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: isAutomatic
                        ? const Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Automatic',
                    style: TextStyle(
                      color: isAutomatic ? Colors.white : AppColors.textMuted,
                      fontSize: context.rFont(11, min: 10, max: 13),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: context.rSpacing(8)),
        Row(
          children: [
            Expanded(
              child: _buildPriorityButton(
                context,
                level: TaskPriorityLevel.high,
                label: 'High',
              ),
            ),
            SizedBox(width: context.rSpacing(8)),
            Expanded(
              child: _buildPriorityButton(
                context,
                level: TaskPriorityLevel.medium,
                label: 'Medium',
              ),
            ),
            SizedBox(width: context.rSpacing(8)),
            Expanded(
              child: _buildPriorityButton(
                context,
                level: TaskPriorityLevel.low,
                label: 'Low',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityButton(
    BuildContext context, {
    required TaskPriorityLevel level,
    required String label,
  }) {
    final isSelected = selectedPriority == level;

    return InkWell(
      onTap: () => onPriorityChanged(level),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 42,
        decoration: BoxDecoration(
          color: isSelected
              ? (isAutomatic
                  ? const Color(0xFF384357)
                  : AppColors.primary.withValues(alpha: 0.2))
              : const Color(0xFF1E232D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (isAutomatic ? AppColors.primary : AppColors.primary)
                : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontSize: context.rFont(12, min: 11, max: 14),
            fontFamily: 'Inter',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
