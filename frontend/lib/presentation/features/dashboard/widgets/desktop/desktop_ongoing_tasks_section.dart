import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../models/dashboard_models.dart';
import 'desktop_task_grid_card.dart';

/// Desktop `Ongoing Tasks` section with header (`See all (N)`), category
/// filter pills with live counts & custom category creation, and responsive 2-column task grid.
class DesktopOngoingTasksSection extends StatefulWidget {
  final List<TaskItem> tasks;
  final int totalPendingCount;
  final int? collegeCount;
  final int? personalCount;
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
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onSeeAllTap,
    required this.onTaskTap,
    this.onTaskToggleComplete,
    this.onClearFilterTap,
  });

  @override
  State<DesktopOngoingTasksSection> createState() =>
      _DesktopOngoingTasksSectionState();
}

class _DesktopOngoingTasksSectionState
    extends State<DesktopOngoingTasksSection> {
  final List<String> _customCategories = <String>[];

  Future<void> _openAddCategoryDialog() async {
    final controller = TextEditingController();
    final created = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: const Text(
          'Add Custom Category',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
          decoration: InputDecoration(
            hintText: 'e.g., Organization, Lab, Quiz',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.bgPrimary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx, text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Add',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    controller.dispose();

    if (!mounted || created == null || created.isEmpty) return;
    setState(() {
      if (!_customCategories.any(
        (c) => c.toLowerCase() == created.toLowerCase(),
      )) {
        _customCategories.add(created);
      }
    });
    widget.onCategorySelected(created);
    PopUpPemberitahuan.success(
      context,
      title: 'Category Added',
      message: 'Category "$created" added to dashboard quick filters.',
      icon: Icons.label_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>['All', 'College', 'Personal', ..._customCategories];
    final displayedTasks =
        (widget.selectedCategory == 'All' ||
                widget.selectedCategory == 'College' ||
                widget.selectedCategory == 'Personal')
            ? widget.tasks
            : widget.tasks.where((task) {
                final q = widget.selectedCategory.toLowerCase();
                return task.title.toLowerCase().contains(q) ||
                    task.course.toLowerCase().contains(q) ||
                    task.tags.any((t) => t.label.toLowerCase().contains(q));
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
                    selectedCategory: widget.selectedCategory,
                    totalPendingCount: widget.totalPendingCount,
                    collegeCount: widget.collegeCount,
                    personalCount: widget.personalCount,
                    onCategorySelected: widget.onCategorySelected,
                    onAddCategoryTap: _openAddCategoryDialog,
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('desktop_see_all_tasks_btn'),
                  onTap: widget.onSeeAllTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Text(
                      'See all (${widget.totalPendingCount})',
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
            selectedCategory: widget.selectedCategory,
            onClearFilterTap: widget.onClearFilterTap,
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
                        onTap: () => widget.onTaskTap(displayedTasks[i]),
                        onToggleComplete: widget.onTaskToggleComplete != null
                            ? () => widget.onTaskToggleComplete!(displayedTasks[i])
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
                        onTap: () => widget.onTaskTap(task),
                        onToggleComplete: widget.onTaskToggleComplete != null
                            ? () => widget.onTaskToggleComplete!(task)
                            : null,
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
  final List<String> categories;
  final String selectedCategory;
  final int totalPendingCount;
  final int? collegeCount;
  final int? personalCount;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onAddCategoryTap;

  const _CategoryQuickFilterRow({
    required this.categories,
    required this.selectedCategory,
    required this.totalPendingCount,
    this.collegeCount,
    this.personalCount,
    required this.onCategorySelected,
    required this.onAddCategoryTap,
  });

  int? _countFor(String cat) {
    switch (cat) {
      case 'All':
        return totalPendingCount;
      case 'College':
        return collegeCount;
      case 'Personal':
        return personalCount;
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

