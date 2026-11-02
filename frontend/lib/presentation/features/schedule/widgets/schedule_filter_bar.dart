import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';

/// Segmented filter pill bar for schedules ('All', 'Today', 'Week', 'Month').
/// Upgraded to match AGENTS.md touch target and responsive guidelines.
class ScheduleFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final List<String> filters;

  const ScheduleFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.filters = const ['All', 'Today', 'Week', 'Month'],
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: filters.map((f) {
          final isSelected = selectedFilter.toLowerCase() == f.toLowerCase();
          return Padding(
            padding: EdgeInsets.only(right: context.rSpacing(8)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onFilterChanged(f),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: const BoxConstraints(minHeight: 34),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(14),
                    vertical: context.rSpacing(6),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderSubtle,
                      width: 0.8,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    f,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textMuted,
                      fontSize: context.rFont(12, min: 11, max: 13.5),
                      fontFamily: 'Inter',
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0.15,
                    ),
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


