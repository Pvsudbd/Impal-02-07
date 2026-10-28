import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Segmented filter pill bar for schedules ('All', 'Today', 'Week', 'Month').
class ScheduleFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const ScheduleFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    const filters = ['All', 'Today', 'Week', 'Month'];
    return Row(
      children: filters.map((f) {
        final isSelected = selectedFilter == f;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: f != filters.last ? 8.0 : 0.0,
            ),
            child: InkWell(
              onTap: () => onFilterChanged(f),
              borderRadius: BorderRadius.circular(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 25,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    f,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textMuted,
                      fontSize: 11.5,
                      fontFamily: 'Inter',
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.1,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

