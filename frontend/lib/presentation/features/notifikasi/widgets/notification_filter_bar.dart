import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../models/notification_model.dart';
import '../models/notification_repository.dart';

class NotificationFilterBar extends StatelessWidget {
  final NotificationCategory selectedCategory;
  final ValueChanged<NotificationCategory> onCategoryChanged;

  const NotificationFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final repo = NotificationRepository.instance;

    final filterItems = [
      (NotificationCategory.all, 'All', repo.getCategoryCount(NotificationCategory.all)),
      (NotificationCategory.deadline, 'Deadlines', repo.getCategoryCount(NotificationCategory.deadline)),
      (NotificationCategory.lecture, 'Classes', repo.getCategoryCount(NotificationCategory.lecture)),
      (NotificationCategory.team, 'Teams', repo.getCategoryCount(NotificationCategory.team)),
      (NotificationCategory.aiSystem, 'AI System', repo.getCategoryCount(NotificationCategory.aiSystem)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filterItems.map((item) {
          final category = item.$1;
          final label = item.$2;
          final count = item.$3;
          final isSelected = category == selectedCategory;

          return Padding(
            padding: EdgeInsets.only(right: context.rSpacing(8)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => onCategoryChanged(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(14),
                    vertical: context.rSpacing(7),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [
                              AppColors.primaryGradientStart,
                              AppColors.primaryGradientEnd,
                            ],
                          )
                        : null,
                    color: isSelected ? null : AppColors.bgCard,
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
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textMuted,
                          fontSize: context.rFont(12.5, min: 11, max: 14),
                          fontFamily: 'Inter',
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: context.rSpacing(6)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.black.withValues(alpha: 0.25)
                              : AppColors.bgPrimary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textMuted,
                            fontSize: context.rFont(10.5, min: 9.5, max: 12),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
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
