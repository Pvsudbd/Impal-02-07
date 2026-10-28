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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: defaultFilters.map((filter) {
          final isSelected = filter.toLowerCase() == selectedFilter.toLowerCase();
          return Padding(
            padding: EdgeInsets.only(right: context.rSpacing(8)),
            child: InkWell(
              onTap: () => onFilterSelected(filter),
              borderRadius: BorderRadius.circular(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                constraints: const BoxConstraints(minHeight: 28),
                padding: EdgeInsets.symmetric(
                  horizontal: context.rSpacing(12),
                  vertical: context.rSpacing(4.5),
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
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMuted,
                    fontSize: context.rFont(11.5, min: 10, max: 13),
                    fontFamily: 'Inter',
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

