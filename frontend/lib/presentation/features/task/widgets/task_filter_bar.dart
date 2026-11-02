import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';

/// Filter chips row for Task Page ('All', 'Today', 'Next 7 Days', 'Overdue').
///
/// Complies with AGENTS.md 48x48 min touch targets and ResponsiveContext.
class TaskFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const TaskFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  static const List<String> defaultFilters = [
    'All',
    'Today',
    'Next 7 Days',
    'Overdue',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: defaultFilters.asMap().entries.map((entry) {
        final index = entry.key;
        final filter = entry.value;
        final isSelected = filter.toLowerCase() == selectedFilter.toLowerCase();
        final isLast = index == defaultFilters.length - 1;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : context.rSpacing(8)),
            child: InkWell(
              onTap: () => onFilterSelected(filter),
              borderRadius: BorderRadius.circular(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                constraints: const BoxConstraints(minHeight: 28),
                padding: EdgeInsets.symmetric(
                  horizontal: context.rSpacing(4),
                  vertical: context.rSpacing(5.5),
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                    width: 0.5,
                  ),
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textMuted,
                      fontSize: context.rFont(11.5, min: 9.5, max: 13),
                      fontFamily: 'Inter',
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

