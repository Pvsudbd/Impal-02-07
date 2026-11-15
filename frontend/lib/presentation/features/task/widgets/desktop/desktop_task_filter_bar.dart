import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';

/// Filter & sort toolbar matching FigCraft `Row Filters Bar` (node 2159).
/// Pure UI widget exposing filter pill selection, sort mode, and task type dropdowns.
class DesktopTaskFilterBar extends StatelessWidget {
  final String selectedTimeFilter;
  final int allCount;
  final int todayCount;
  final int next7DaysCount;
  final int overdueCount;
  final String sortBy;
  final String taskTypeFilter;
  final String? activeExtraFilterLabel;
  final ValueChanged<String> onTimeFilterSelected;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onTaskTypeChanged;
  final VoidCallback? onClearExtraFilter;

  const DesktopTaskFilterBar({
    super.key,
    required this.selectedTimeFilter,
    required this.allCount,
    required this.todayCount,
    required this.next7DaysCount,
    required this.overdueCount,
    required this.sortBy,
    required this.taskTypeFilter,
    this.activeExtraFilterLabel,
    required this.onTimeFilterSelected,
    required this.onSortChanged,
    required this.onTaskTypeChanged,
    this.onClearExtraFilter,
  });

  @override
  Widget build(BuildContext context) {
    final filterItems = [
      _FilterPillSpec(
        id: 'All Tasks',
        label: 'All Tasks ($allCount)',
        isOverdueTone: false,
      ),
      _FilterPillSpec(
        id: 'Today',
        label: 'Today ($todayCount)',
        isOverdueTone: false,
      ),
      _FilterPillSpec(
        id: 'Next 7 Days',
        label: 'Next 7 Days ($next7DaysCount)',
        isOverdueTone: false,
      ),
      _FilterPillSpec(
        id: 'Overdue',
        label: 'Overdue ($overdueCount)',
        isOverdueTone: true,
      ),
    ];

    final leftPills = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: context.rSpacing(8),
      runSpacing: context.rSpacing(8),
      children: [
        for (final item in filterItems)
          _FilterPill(
            pillKey: ValueKey('desktop_filter_${item.id}'),
            label: item.label,
            isActive: selectedTimeFilter == item.id,
            isOverdueTone: item.isOverdueTone,
            onTap: () => onTimeFilterSelected(item.id),
          ),
        if (activeExtraFilterLabel != null && onClearExtraFilter != null)
          _ClearChip(
            label: activeExtraFilterLabel!,
            onTap: onClearExtraFilter!,
          ),
      ],
    );

    final rightDropdowns = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: context.rSpacing(8),
      runSpacing: context.rSpacing(8),
      children: [
        _DropdownPill(
          menuKey: const ValueKey('desktop_sort_dropdown'),
          label: 'Sort: $sortBy',
          options: const ['Deadline', 'Priority', 'Title'],
          selected: sortBy,
          onSelected: onSortChanged,
        ),
        _DropdownPill(
          menuKey: const ValueKey('desktop_type_dropdown'),
          label: 'Type: $taskTypeFilter',
          options: const ['All', 'College', 'Personal', 'Team', 'Completed'],
          selected: taskTypeFilter,
          onSelected: onTaskTypeChanged,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 620) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: leftPills),
              SizedBox(width: context.rSpacing(10)),
              rightDropdowns,
            ],
          );
        }
        return SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: context.rSpacing(10),
            runSpacing: context.rSpacing(8),
            children: [leftPills, rightDropdowns],
          ),
        );
      },
    );
  }
}

class _FilterPillSpec {
  final String id;
  final String label;
  final bool isOverdueTone;

  const _FilterPillSpec({
    required this.id,
    required this.label,
    required this.isOverdueTone,
  });
}

class _FilterPill extends StatelessWidget {
  final Key pillKey;
  final String label;
  final bool isActive;
  final bool isOverdueTone;
  final VoidCallback onTap;

  const _FilterPill({
    required this.pillKey,
    required this.label,
    required this.isActive,
    required this.isOverdueTone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final Border? border;
    final FontWeight fontWeight;

    if (isActive) {
      bgColor = AppColors.primary;
      textColor = Colors.white;
      border = null;
      fontWeight = FontWeight.w700;
    } else if (isOverdueTone) {
      bgColor = AppColors.overduePillBg;
      textColor = AppColors.primary;
      border = Border.all(color: AppColors.primary, width: 1.0);
      fontWeight = FontWeight.w700;
    } else {
      bgColor = AppColors.bgPrimary;
      textColor = AppColors.textMuted;
      border = null;
      fontWeight = FontWeight.w500;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        key: pillKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: Colors.white.withValues(alpha: 0.05),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(14),
            vertical: context.rSpacing(6),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: textColor,
                  fontSize: context.rFont(12, min: 11, max: 13),
                  fontFamily: 'Inter',
                  fontWeight: fontWeight,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClearChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ClearChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(10),
            vertical: context.rSpacing(5),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.55),
              width: 0.9,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primaryAccent,
                  fontSize: context.rFont(11, min: 10, max: 12),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.close_rounded,
                size: context.rIcon(13),
                color: AppColors.primaryAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownPill extends StatelessWidget {
  final Key menuKey;
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _DropdownPill({
    required this.menuKey,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      key: menuKey,
      color: AppColors.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final option in options)
          PopupMenuItem<String>(
            value: option,
            child: Row(
              children: [
                Icon(
                  option == selected
                      ? Icons.check_rounded
                      : Icons.circle_outlined,
                  size: 14,
                  color: option == selected
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  option,
                  style: TextStyle(
                    color: option == selected
                        ? Colors.white
                        : AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight:
                        option == selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.rSpacing(10),
          vertical: context.rSpacing(5),
        ),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSubtle, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label ▾',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: context.rFont(11, min: 10, max: 12),
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
