import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../models/dashboard_models.dart';
import 'desktop_task_grid_card.dart';

/// Desktop `Ongoing Tasks` section with header (`See all (N)`), optional category
/// filter badge, and responsive 2-column task grid.
class DesktopOngoingTasksSection extends StatelessWidget {
  final List<TaskItem> tasks;
  final int totalPendingCount;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onSeeAllTap;
  final ValueChanged<TaskItem> onTaskTap;
  final VoidCallback? onClearFilterTap;

  const DesktopOngoingTasksSection({
    super.key,
    required this.tasks,
    required this.totalPendingCount,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onSeeAllTap,
    required this.onTaskTap,
    this.onClearFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header row
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    'Ongoing Tasks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(18, min: 16, max: 20),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  _CategoryQuickFilterRow(
                    selectedCategory: selectedCategory,
                    onCategorySelected: onCategorySelected,
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('desktop_see_all_tasks_btn'),
                  onTap: onSeeAllTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Text(
                      'See all ($totalPendingCount)',
                      style: const TextStyle(
                        color: AppColors.primaryAccent,
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (tasks.isEmpty)
          _EmptyTasksState(
            selectedCategory: selectedCategory,
            onClearFilterTap: onClearFilterTap,
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 16.0;
              final twoColumns = constraints.maxWidth >= 540.0;
              if (!twoColumns) {
                return Column(
                  children: [
                    for (int i = 0; i < tasks.length; i++) ...[
                      DesktopTaskGridCard(
                        task: tasks[i],
                        onTap: () => onTaskTap(tasks[i]),
                      ),
                      if (i < tasks.length - 1) const SizedBox(height: gap),
                    ],
                  ],
                );
              }

              final cardWidth = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final task in tasks)
                    SizedBox(
                      width: cardWidth,
                      child: DesktopTaskGridCard(
                        task: task,
                        onTap: () => onTaskTap(task),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _CategoryQuickFilterRow extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const _CategoryQuickFilterRow({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    const categories = ['All', 'College', 'Personal'];

    return Wrap(
      spacing: 6,
      children: [
        for (final cat in categories)
          InkWell(
            onTap: () => onCategorySelected(cat),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: selectedCategory == cat
                    ? AppColors.primary.withValues(alpha: 0.16)
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selectedCategory == cat
                      ? AppColors.primary
                      : AppColors.borderSubtle,
                  width: 1,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: selectedCategory == cat
                      ? AppColors.primaryAccent
                      : AppColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyTasksState extends StatelessWidget {
  final String selectedCategory;
  final VoidCallback? onClearFilterTap;

  const _EmptyTasksState({
    required this.selectedCategory,
    this.onClearFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.assignment_turned_in_outlined,
            color: AppColors.textMuted,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            'No ongoing tasks match "$selectedCategory"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try switching category or clearing your search query.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          if (onClearFilterTap != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onClearFilterTap,
              child: const Text(
                'Reset Filter',
                style: TextStyle(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

