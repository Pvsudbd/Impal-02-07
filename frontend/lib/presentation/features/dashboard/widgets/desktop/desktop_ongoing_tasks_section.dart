import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../../schedule/pop_up_konfirmasi_delete.dart';
import '../../../task/models/tag_model.dart';
import '../../../task/models/tag_repository.dart';
import '../../../task/widgets/task_tag_picker.dart';
import '../../models/dashboard_models.dart';
import 'desktop_task_grid_card.dart';

/// Desktop `Ongoing Tasks` section with header (`See all (N)`), category &
/// synced Custom Tag filter pills, and responsive 2-column task grid.
class DesktopOngoingTasksSection extends StatelessWidget {
  final List<TaskItem> tasks;
  final int totalPendingCount;
  final int? collegeCount;
  final int? personalCount;
  final int? teamCount;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onSeeAllTap;
  final ValueChanged<TaskItem> onTaskTap;
  final ValueChanged<TaskItem>? onTaskToggleComplete;
  final VoidCallback? onClearFilterTap;

  const DesktopOngoingTasksSection({
    super.key,
    required this.tasks,
    required this.totalPendingCount,
    this.collegeCount,
    this.personalCount,
    this.teamCount,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onSeeAllTap,
    required this.onTaskTap,
    this.onTaskToggleComplete,
    this.onClearFilterTap,
  });

  Future<void> _openAddTagDialog(BuildContext context) async {
    final created = await AddCustomTagDialog.show(context);
    if (created != null) {
      onCategorySelected(created.label);
    }
  }

  Future<void> _confirmDeleteTag(
    BuildContext context,
    CustomTagModel tag,
  ) async {
    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: 'Delete Tag?',
      message: 'Remove custom tag "${tag.label}" from quick filters?',
    );
    if (confirmed == true) {
      await TaskTagRepository().deleteTag(tag.id);
      if (selectedCategory.toLowerCase() == tag.label.toLowerCase()) {
        onCategorySelected('All');
      }
      if (context.mounted) {
        PopUpPemberitahuan.show(
          context,
          title: 'Tag Deleted',
          message: 'Tag "${tag.label}" removed.',
          icon: Icons.delete_outline_rounded,
          iconBgColor: PopUpPemberitahuan.negativeColor,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TaskTagRepository(),
      builder: (context, _) {
        final repoTags = TaskTagRepository().tags;
        final categories = <String>[
          'All',
          'College',
          'Personal',
          'Team',
          ...repoTags.map((t) => t.label),
        ];
        final displayedTasks =
            (selectedCategory == 'All' ||
                    selectedCategory == 'College' ||
                    selectedCategory == 'Personal' ||
                    selectedCategory == 'Team')
                ? tasks
                : tasks.where((task) {
                    final q = selectedCategory.toLowerCase();
                    return task.title.toLowerCase().contains(q) ||
                        task.course.toLowerCase().contains(q) ||
                        task.tags.any((t) => t.label.toLowerCase() == q);
                  }).toList();

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
                        categories: categories,
                        repoTags: repoTags,
                        selectedCategory: selectedCategory,
                        totalPendingCount: totalPendingCount,
                        collegeCount: collegeCount,
                        personalCount: personalCount,
                        teamCount: teamCount,
                        onCategorySelected: onCategorySelected,
                        onAddCategoryTap: () => _openAddTagDialog(context),
                        onDeleteCustomTag: (tag) =>
                            _confirmDeleteTag(context, tag),
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

            if (displayedTasks.isEmpty)
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
                        for (int i = 0; i < displayedTasks.length; i++) ...[
                          DesktopTaskGridCard(
                            task: displayedTasks[i],
                            onTap: () => onTaskTap(displayedTasks[i]),
                            onToggleComplete: onTaskToggleComplete != null
                                ? () => onTaskToggleComplete!(displayedTasks[i])
                                : null,
                          ),
                          if (i < displayedTasks.length - 1)
                            const SizedBox(height: gap),
                        ],
                      ],
                    );
                  }

                  final cardWidth = (constraints.maxWidth - gap) / 2;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final task in displayedTasks)
                        SizedBox(
                          width: cardWidth,
                          child: DesktopTaskGridCard(
                            task: task,
                            onTap: () => onTaskTap(task),
                            onToggleComplete: onTaskToggleComplete != null
                                ? () => onTaskToggleComplete!(task)
                                : null,
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _CategoryQuickFilterRow extends StatelessWidget {
  final List<String> categories;
  final List<CustomTagModel> repoTags;
  final String selectedCategory;
  final int totalPendingCount;
  final int? collegeCount;
  final int? personalCount;
  final int? teamCount;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onAddCategoryTap;
  final ValueChanged<CustomTagModel> onDeleteCustomTag;

  const _CategoryQuickFilterRow({
    required this.categories,
    required this.repoTags,
    required this.selectedCategory,
    required this.totalPendingCount,
    this.collegeCount,
    this.personalCount,
    this.teamCount,
    required this.onCategorySelected,
    required this.onAddCategoryTap,
    required this.onDeleteCustomTag,
  });

  CustomTagModel? _tagFor(String cat) {
    for (final tag in repoTags) {
      if (tag.label.toLowerCase() == cat.toLowerCase()) return tag;
    }
    return null;
  }

  int? _countFor(String cat) {
    switch (cat) {
      case 'All':
        return totalPendingCount;
      case 'College':
        return collegeCount;
      case 'Personal':
        return personalCount;
      case 'Team':
        return teamCount;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final cat in categories)
          Builder(
            builder: (context) {
              final isSelected = selectedCategory == cat;
              final count = _countFor(cat);
              final customTag = _tagFor(cat);
              return InkWell(
                onTap: () => onCategorySelected(cat),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.16)
                        : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (customTag != null) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: customTag.backgroundColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        cat,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryAccent
                              : AppColors.textMuted,
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (customTag != null) ...[
                        const SizedBox(width: 4),
                        InkWell(
                          key: ValueKey('desktop_delete_tag_${customTag.id}'),
                          onTap: () => onDeleteCustomTag(customTag),
                          borderRadius: BorderRadius.circular(999),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      if (count != null) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.25)
                                : AppColors.bgPrimary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textMuted,
                              fontSize: 9.5,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        Tooltip(
          message: 'Add custom category',
          child: InkWell(
            key: const ValueKey('desktop_add_category_btn'),
            onTap: onAddCategoryTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 13,
                color: AppColors.textMuted,
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

