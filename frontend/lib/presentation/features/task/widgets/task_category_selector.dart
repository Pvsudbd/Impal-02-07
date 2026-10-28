import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';

/// Interactive selector for Task Category: "Tugas Kuliah" vs "Non-Kuliah / Personal".
///
/// When "Tugas Kuliah" is selected, the Course form field is displayed.
/// When "Non-Kuliah / Personal" is selected, the Course field is hidden.
class TaskCategorySelector extends StatelessWidget {
  final bool isCollegeTask;
  final ValueChanged<bool> onCategoryChanged;

  const TaskCategorySelector({
    super.key,
    required this.isCollegeTask,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Task Category',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: context.rFont(13, min: 11, max: 15),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.rSpacing(8)),
        Row(
          children: [
            Expanded(
              child: _buildCategoryOption(
                context,
                title: 'Tugas Kuliah',
                icon: Icons.school_rounded,
                isSelected: isCollegeTask,
                onTap: () => onCategoryChanged(true),
              ),
            ),
            SizedBox(width: context.rSpacing(10)),
            Expanded(
              child: _buildCategoryOption(
                context,
                title: 'Non-Kuliah',
                icon: Icons.person_rounded,
                isSelected: !isCollegeTask,
                onTap: () => onCategoryChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.18)
              : const Color(0xFF1E232D),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontSize: context.rFont(12, min: 11, max: 14),
                  fontFamily: 'Inter',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

