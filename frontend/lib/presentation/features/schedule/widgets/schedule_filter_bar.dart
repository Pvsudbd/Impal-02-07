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
    return Row(
      children: filters.asMap().entries.map((entry) {
        final index = entry.key;
        final f = entry.value;
        final isSelected = selectedFilter.toLowerCase() == f.toLowerCase();
        final isLast = index == filters.length - 1;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : context.rSpacing(8)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onFilterChanged(f),
                borderRadius: BorderRadius.circular(6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: const BoxConstraints(minHeight: 28),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(4),
                    vertical: context.rSpacing(4.5),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderSubtle,
                      width: 0.6,
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
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      f,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textMuted,
                        fontSize: context.rFont(11, min: 10, max: 12.5),
                        fontFamily: 'Inter',
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: 0.15,
                      ),
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


