import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../task/widgets/task_tag_picker.dart';
import '../models/dashboard_models.dart';

/// Compact root category tabs (`All`, `College`, `Personal`, `Team`) aligned
/// inline with the horizontally scrollable tag strip and Desktop-style `+` pill.
class HomeCategoriesSection extends StatelessWidget {
  final List<CategoryItem> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final int? totalCount;
  final int? collegeCount;
  final int? personalCount;
  final int? teamCount;

  const HomeCategoriesSection({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.totalCount,
    this.collegeCount,
    this.personalCount,
    this.teamCount,
  });

  String? get _activeTagFilter {
    final lower = selectedCategory.toLowerCase();
    if (lower == 'all' ||
        lower == 'college' ||
        lower == 'personal' ||
        lower == 'team') {
      return null;
    }
    return selectedCategory;
  }

  int? _countFor(CategoryItem category) {
    final lower = category.name.toLowerCase();
    if (lower == 'college' && collegeCount != null) return collegeCount;
    if (lower == 'personal' && personalCount != null) return personalCount;
    final match = RegExp(r'\d+').firstMatch(category.count);
    return match != null ? int.tryParse(match.group(0)!) : null;
  }

  @override
  Widget build(BuildContext context) {
    final rootPills = <Widget>[
      _buildRootTabPill(
        context,
        tabKey: const ValueKey('mobile_category_tab_all'),
        label: 'All',
        count: totalCount,
        isSelected: selectedCategory == 'All',
        onTap: () => onCategorySelected('All'),
      ),
      ...categories.map((cat) {
        return _buildRootTabPill(
          context,
          tabKey: ValueKey('mobile_category_tab_${cat.name.toLowerCase()}'),
          label: cat.name,
          count: _countFor(cat),
          isSelected: selectedCategory == cat.name,
          onTap: () => onCategorySelected(cat.name),
        );
      }),
      _buildRootTabPill(
        context,
        tabKey: const ValueKey('mobile_category_tab_team'),
        label: 'Team',
        count: teamCount,
        isSelected: selectedCategory == 'Team',
        onTap: () => onCategorySelected('Team'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.rFont(18, min: 16, max: 20),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: context.rSpacing(10)),
        // Single inline scrollable row: [All] [College] [Personal] [Team] + Tags + fixed (+) pill
        Row(
          children: [
            Expanded(
              child: TagFilterStrip(
                selectedTag: _activeTagFilter,
                scrollable: true,
                leadingChips: rootPills,
                onTagSelected: (tagLabel) {
                  onCategorySelected(tagLabel ?? 'All');
                },
              ),
            ),
            SizedBox(width: context.rSpacing(8)),
            Tooltip(
              message: 'Add custom tag',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('mobile_add_category_btn'),
                  borderRadius: BorderRadius.circular(999),
                  onTap: () async {
                    final created = await AddCustomTagDialog.show(context);
                    if (created != null) {
                      onCategorySelected(created.label);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: context.rIcon(16),
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRootTabPill(
    BuildContext context, {
    required Key tabKey,
    required String label,
    required int? count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: tabKey,
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.16)
                : AppColors.bgCard,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primaryAccent
                      : AppColors.textMuted,
                  fontSize: context.rFont(12, min: 11, max: 13),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1.5,
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
                      color: isSelected ? Colors.white : AppColors.textMuted,
                      fontSize: context.rFont(10, min: 9.5, max: 11),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
