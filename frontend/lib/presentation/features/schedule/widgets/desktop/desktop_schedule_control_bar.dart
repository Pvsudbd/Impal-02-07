import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import 'desktop_schedule_matrix_card.dart';

/// Top control & filter bar matching FigCraft `Control & Filter Bar` (node 2593).
/// Includes the 4-tab View Switcher (`All`, `Today`, `Week`, `Month`),
/// Week Range Navigator (`‹ 12 Okt – 18 Okt 2026 [Minggu 8 • Ganjil] › [Hari Ini]`),
/// and Tonal Category Legend (`Kuliah`, `Kelompok`, `Study / Lab`, `Ongoing`).
class DesktopScheduleControlBar extends StatelessWidget {
  final String selectedView; // 'All', 'Today', 'Week', 'Month'
  final String weekRangeLabel;
  final String academicWeekLabel;
  final ScheduleMatrixCategory? selectedCategory;
  final ValueChanged<String> onViewChanged;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onTodayPressed;
  final ValueChanged<ScheduleMatrixCategory?> onCategorySelected;

  const DesktopScheduleControlBar({
    super.key,
    required this.selectedView,
    required this.weekRangeLabel,
    required this.academicWeekLabel,
    this.selectedCategory,
    required this.onViewChanged,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onTodayPressed,
    required this.onCategorySelected,
  });

  static const List<String> _viewOptions = ['All', 'Today', 'Week', 'Month'];

  @override
  Widget build(BuildContext context) {
    final viewSwitcher = Container(
      height: 36,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < _viewOptions.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            _ViewTabPill(
              tabKey: ValueKey('desktop_schedule_view_${_viewOptions[i]}'),
              label: _viewOptions[i],
              isActive: selectedView == _viewOptions[i],
              onTap: () => onViewChanged(_viewOptions[i]),
            ),
          ],
        ],
      ),
    );

    final weekNavigator = SizedBox(
      height: 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavIconSquareButton(
            buttonKey: const ValueKey('desktop_schedule_prev_week'),
            symbol: '‹',
            tooltip: 'Previous Week',
            onTap: onPreviousWeek,
          ),
          const SizedBox(width: 10),
          Text(
            weekRangeLabel,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(13, min: 12, max: 13),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.skyBadge,
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              academicWeekLabel,
              style: TextStyle(
                color: const Color(0xFF1E398A),
                fontSize: context.rFont(11, min: 10, max: 11),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _NavIconSquareButton(
            buttonKey: const ValueKey('desktop_schedule_next_week'),
            symbol: '›',
            tooltip: 'Next Week',
            onTap: onNextWeek,
          ),
          const SizedBox(width: 10),
          Material(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              key: const ValueKey('desktop_schedule_today_btn'),
              onTap: onTodayPressed,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(12, min: 11, max: 12),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final legend = SizedBox(
      height: 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendPill(
            pillKey: const ValueKey('desktop_legend_kuliah'),
            label: 'Lecture',
            bgColor: const Color(0xFF63CDDA),
            textColor: const Color(0xFF2A8F9C),
            isSelected: selectedCategory == ScheduleMatrixCategory.kuliah,
            isDimmed: selectedCategory != null &&
                selectedCategory != ScheduleMatrixCategory.kuliah,
            onTap: () => onCategorySelected(
              selectedCategory == ScheduleMatrixCategory.kuliah
                  ? null
                  : ScheduleMatrixCategory.kuliah,
            ),
          ),
          const SizedBox(width: 6),
          _LegendPill(
            pillKey: const ValueKey('desktop_legend_kelompok'),
            label: 'Team',
            bgColor: const Color(0xFF786FA6),
            textColor: const Color(0xFF4A3C8C),
            isSelected: selectedCategory == ScheduleMatrixCategory.kelompok,
            isDimmed: selectedCategory != null &&
                selectedCategory != ScheduleMatrixCategory.kelompok,
            onTap: () => onCategorySelected(
              selectedCategory == ScheduleMatrixCategory.kelompok
                  ? null
                  : ScheduleMatrixCategory.kelompok,
            ),
          ),
          const SizedBox(width: 6),
          _LegendPill(
            pillKey: const ValueKey('desktop_legend_study'),
            label: 'Study / Lab',
            bgColor: const Color(0xFF778BEB),
            textColor: const Color(0xFF4055C0),
            isSelected: selectedCategory == ScheduleMatrixCategory.studyLab,
            isDimmed: selectedCategory != null &&
                selectedCategory != ScheduleMatrixCategory.studyLab,
            onTap: () => onCategorySelected(
              selectedCategory == ScheduleMatrixCategory.studyLab
                  ? null
                  : ScheduleMatrixCategory.studyLab,
            ),
          ),
          const SizedBox(width: 6),
          _LegendPill(
            pillKey: const ValueKey('desktop_legend_ongoing'),
            label: 'Ongoing',
            bgColor: AppColors.primaryAccent,
            textColor: Colors.white,
            isSelected: selectedCategory == ScheduleMatrixCategory.ongoing,
            isDimmed: selectedCategory != null &&
                selectedCategory != ScheduleMatrixCategory.ongoing,
            onTap: () => onCategorySelected(
              selectedCategory == ScheduleMatrixCategory.ongoing
                  ? null
                  : ScheduleMatrixCategory.ongoing,
            ),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 980) {
          return SizedBox(
            height: 38,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    viewSwitcher,
                    const SizedBox(width: 12),
                    weekNavigator,
                    const SizedBox(width: 12),
                    legend,
                  ],
                ),
              ),
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: viewSwitcher,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: weekNavigator,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: legend,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ViewTabPill extends StatelessWidget {
  final Key tabKey;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewTabPill({
    required this.tabKey,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        key: tabKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 28,
          padding: EdgeInsets.symmetric(horizontal: isActive ? 14 : 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.textMuted,
              fontSize: context.rFont(12, min: 11, max: 12),
              fontFamily: 'Inter',
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIconSquareButton extends StatelessWidget {
  final Key buttonKey;
  final String symbol;
  final String tooltip;
  final VoidCallback onTap;

  const _NavIconSquareButton({
    required this.buttonKey,
    required this.symbol,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          key: buttonKey,
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              symbol,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: context.rFont(16, min: 14, max: 16),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendPill extends StatelessWidget {
  final Key pillKey;
  final String label;
  final Color bgColor;
  final Color textColor;
  final bool isSelected;
  final bool isDimmed;
  final VoidCallback onTap;

  const _LegendPill({
    required this.pillKey,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.isSelected,
    required this.isDimmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDimmed ? 0.45 : 1.0,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          key: pillKey,
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 1.5)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: context.rFont(10, min: 9.5, max: 10),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
