import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../models/smart_priority_model.dart';
import '../../models/smart_priority_repository.dart';
import '../course_rubric_manager_panel.dart';
import '../smart_engine_status_card.dart';
import '../smart_priority_task_card.dart';

/// Desktop 2-column workspace for Mamdani Smart Priority Ranking (left) and
/// Course Grading Rubrics Management & Team Sync (right).
class DesktopSmartPriorityView extends StatefulWidget {
  final String searchQuery;

  const DesktopSmartPriorityView({
    super.key,
    this.searchQuery = '',
  });

  @override
  State<DesktopSmartPriorityView> createState() =>
      _DesktopSmartPriorityViewState();
}

class _DesktopSmartPriorityViewState extends State<DesktopSmartPriorityView> {
  final SmartPriorityRepository _repo = SmartPriorityRepository.instance;
  final Set<String> _expandedTaskIds = <String>{};
  SmartPriorityLevel? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _toggleEngine() {
    _repo.toggleEngineActive();
    PopUpPemberitahuan.show(
      context,
      title: _repo.isEngineActive
          ? 'Mamdani Engine Active'
          : 'Mamdani Engine Inactive',
      message: _repo.isEngineActive
          ? 'Mamdani Fuzzy Logic Inference is now active across all tasks.'
          : 'Mamdani Fuzzy Logic Inference has been paused.',
      icon: _repo.isEngineActive
          ? Icons.psychology_rounded
          : Icons.pause_circle_outline_rounded,
      iconBgColor: _repo.isEngineActive
          ? PopUpPemberitahuan.positiveColor
          : PopUpPemberitahuan.negativeColor,
    );
  }

  void _onTaskTap(SmartPriorityModel item) {
    if (!_repo.isScoreExplainabilityActive) {
      PopUpPemberitahuan.show(
        context,
        title: 'XAI Disabled',
        message:
            'Score Explainability (XAI) is disabled in Profile & Settings. Enable it to view mathematical calculations.',
        icon: Icons.lightbulb_outline_rounded,
        iconBgColor: PopUpPemberitahuan.negativeColor,
      );
      return;
    }
    setState(() {
      if (_expandedTaskIds.contains(item.id)) {
        _expandedTaskIds.remove(item.id);
      } else {
        _expandedTaskIds.add(item.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.searchQuery.trim().toLowerCase();
    final filtered = _repo.getFiltered(_selectedFilter).where((item) {
      if (q.isEmpty) return true;
      return item.title.toLowerCase().contains(q) ||
          item.categoryTag.toLowerCase().contains(q) ||
          item.courseWeightText.toLowerCase().contains(q);
    }).toList();

    final filterOptions = [
      (null, 'All Priorities', _repo.getCount(null)),
      (SmartPriorityLevel.high, 'High', _repo.getCount(SmartPriorityLevel.high)),
      (
        SmartPriorityLevel.medium,
        'Medium',
        _repo.getCount(SmartPriorityLevel.medium),
      ),
      (SmartPriorityLevel.low, 'Low', _repo.getCount(SmartPriorityLevel.low)),
    ];

    final rankingColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SmartEngineStatusCard(
          isActive: _repo.isEngineActive,
          onTap: _toggleEngine,
        ),
        SizedBox(height: context.rSpacing(16)),
        Wrap(
          spacing: context.rSpacing(8),
          runSpacing: context.rSpacing(8),
          children: filterOptions.map((opt) {
            final level = opt.$1;
            final label = opt.$2;
            final count = opt.$3;
            final isSelected = _selectedFilter == level;

            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => setState(() => _selectedFilter = level),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: context.rSpacing(13),
                  vertical: context.rSpacing(8),
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Text(
                  '$label ($count)',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMuted,
                    fontSize: context.rFont(12, min: 10.5, max: 13.5),
                    fontFamily: 'Inter',
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: context.rSpacing(16)),
        if (filtered.isEmpty)
          Container(
            padding: EdgeInsets.all(context.rSpacing(24)),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Center(
              child: Text(
                'No tasks matching current filter.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: context.rFont(13, min: 11.5, max: 14.5),
                ),
              ),
            ),
          )
        else
          ...filtered.map(
            (item) => SmartPriorityTaskCard(
              key: ValueKey('desktop_sp_${item.id}'),
              item: item,
              isExpanded: _repo.isScoreExplainabilityActive &&
                  _expandedTaskIds.contains(item.id),
              showExpandChevron: _repo.isScoreExplainabilityActive,
              onTap: () => _onTaskTap(item),
            ),
          ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final useSideBySide = constraints.maxWidth >= 820;

        if (!useSideBySide) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(context.rSpacing(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CourseRubricManagerPanel(),
                SizedBox(height: context.rSpacing(24)),
                rankingColumn,
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(context.rSpacing(24)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: rankingColumn,
              ),
              SizedBox(width: context.rSpacing(24)),
              const Expanded(
                flex: 6,
                child: CourseRubricManagerPanel(),
              ),
            ],
          ),
        );
      },
    );
  }
}
