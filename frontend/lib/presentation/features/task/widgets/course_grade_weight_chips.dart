import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../smart_system/models/course_rubric_model.dart';
import '../models/task_item_model.dart';

// Re-exports & Aliases for backward compatibility
typedef TaskGradeWeightSelector = CourseGradeWeightChips;
typedef TaskGradeWeightChips = CourseGradeWeightChips;

/// Interactive selector for Task Grade Weight with an Automatic toggle.
///
/// Features:
/// - Labelled "Task Grade Weight"
/// - "Automatic" checkbox aligned on top right
/// - Dynamic Menu:
///   - When "Automatic" is active on a College Task, dynamically surfaces the
///     chosen Course's Rubric Assessment Categories (UTS, Quiz, Assignment, etc.)
///     plus an optional manual `%` override.
///   - When "Automatic" is unchecked, manual priority chips (High, Medium, Low) appear.
class CourseGradeWeightChips extends StatelessWidget {
  final TaskPriorityLevel selectedPriority;
  final bool isAutomatic;
  final ValueChanged<TaskPriorityLevel> onPriorityChanged;
  final ValueChanged<bool> onAutomaticChanged;
  final bool isCollegeTask;
  final List<RubricComponentModel> rubricComponents;
  final String? selectedComponentId;
  final ValueChanged<RubricComponentModel?>? onComponentSelected;
  final int? customWeightPercent;
  final ValueChanged<int?>? onCustomWeightChanged;

  const CourseGradeWeightChips({
    super.key,
    required this.selectedPriority,
    required this.isAutomatic,
    required this.onPriorityChanged,
    required this.onAutomaticChanged,
    this.isCollegeTask = false,
    this.rubricComponents = const [],
    this.selectedComponentId,
    this.onComponentSelected,
    this.customWeightPercent,
    this.onCustomWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.disableAnimationsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Task Grade Weight',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: context.rFont(13, min: 11, max: 15),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => onAutomaticChanged(!isAutomatic),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isAutomatic ? AppColors.primary : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isAutomatic
                            ? AppColors.primary
                            : AppColors.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: isAutomatic
                        ? const Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Automatic',
                    style: TextStyle(
                      color: isAutomatic ? Colors.white : AppColors.textMuted,
                      fontSize: context.rFont(11, min: 10, max: 13),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        AnimatedCrossFade(
          duration: disableMotion
              ? Duration.zero
              : const Duration(milliseconds: 220),
          crossFadeState: isAutomatic
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: isCollegeTask && onComponentSelected != null
              ? RubricAssessmentSelector(
                  components: rubricComponents,
                  selectedComponentId: selectedComponentId,
                  customWeightPercent: customWeightPercent,
                  onComponentSelected: onComponentSelected!,
                  onCustomWeightChanged: onCustomWeightChanged,
                )
              : PersonalTaskWeightSelector(
                  selectedWeight: customWeightPercent,
                  onWeightChanged: onCustomWeightChanged ?? (_) {},
                ),
          secondChild: Padding(
            padding: EdgeInsets.only(top: context.rSpacing(8)),
            child: Row(
              children: [
                Expanded(
                  child: _buildPriorityButton(
                    context,
                    level: TaskPriorityLevel.high,
                    label: 'High',
                  ),
                ),
                SizedBox(width: context.rSpacing(8)),
                Expanded(
                  child: _buildPriorityButton(
                    context,
                    level: TaskPriorityLevel.medium,
                    label: 'Medium',
                  ),
                ),
                SizedBox(width: context.rSpacing(8)),
                Expanded(
                  child: _buildPriorityButton(
                    context,
                    level: TaskPriorityLevel.low,
                    label: 'Low',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityButton(
    BuildContext context, {
    required TaskPriorityLevel level,
    required String label,
  }) {
    final isSelected = selectedPriority == level;

    return InkWell(
      onTap: () => onPriorityChanged(level),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 42,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontSize: context.rFont(12, min: 11, max: 14),
            fontFamily: 'Inter',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Reusable Assessment Category picker synced to a Course's Grading Rubric.
/// Shared by both Mobile `CreateTaskPage` and Desktop `DesktopPersonalTaskModal`.
class RubricAssessmentSelector extends StatelessWidget {
  final List<RubricComponentModel> components;
  final String? selectedComponentId;
  final int? customWeightPercent;
  final ValueChanged<RubricComponentModel?> onComponentSelected;
  final ValueChanged<int?>? onCustomWeightChanged;

  const RubricAssessmentSelector({
    super.key,
    required this.components,
    required this.selectedComponentId,
    this.customWeightPercent,
    required this.onComponentSelected,
    this.onCustomWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (components.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: context.rSpacing(8)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(12),
            vertical: context.rSpacing(10),
          ),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Text(
            'No rubric categories for this course yet. Add components in Smart Priority -> Course Rubrics.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(11.5, min: 10, max: 13),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: context.rSpacing(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: context.rSpacing(8),
            runSpacing: context.rSpacing(8),
            children: [
              ...components.map((comp) {
                final isSelected = selectedComponentId == comp.id &&
                    customWeightPercent == null;
                return InkWell(
                  key: ValueKey('rubric_category_chip_${comp.id}'),
                  onTap: () {
                    onCustomWeightChanged?.call(null);
                    onComponentSelected(comp);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderSubtle,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          comp.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textBody,
                            fontSize: context.rFont(12, min: 10.5, max: 13),
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${comp.weightPercent}%',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primaryAccent
                                : AppColors.textMuted,
                            fontSize: context.rFont(11, min: 10, max: 12.5),
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              if (onCustomWeightChanged != null)
                InkWell(
                  key: const ValueKey('rubric_custom_weight_chip'),
                  onTap: () => _showCustomWeightDialog(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: customWeightPercent != null
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: customWeightPercent != null
                            ? AppColors.primary
                            : AppColors.borderSubtle,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 13,
                          color: customWeightPercent != null
                              ? AppColors.primaryAccent
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          customWeightPercent != null
                              ? 'Custom: $customWeightPercent%'
                              : 'Custom %',
                          style: TextStyle(
                            color: customWeightPercent != null
                                ? Colors.white
                                : AppColors.textMuted,
                            fontSize: context.rFont(11.5, min: 10, max: 13),
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomWeightDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: customWeightPercent?.toString() ?? '15',
    );
    final result = await showDialog<int>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgDialog,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Custom Task Weight (%)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  suffixText: '%',
                  filled: true,
                  fillColor: AppColors.bgCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final parsed = int.tryParse(controller.text.trim());
                  Navigator.of(ctx).pop(
                    parsed?.clamp(1, 100),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                ),
                child: const Text('Apply Weight'),
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (result != null) {
      onCustomWeightChanged?.call(result);
    }
  }
}

/// Dynamic selector for Personal (non-college) tasks when Automatic is checked.
///
/// Surfaces predefined importance weight presets (Low 15%, Medium 30%, High 50%, Urgent 80%)
/// alongside a Custom % button with interactive number input dialog.
class PersonalTaskWeightSelector extends StatelessWidget {
  final int? selectedWeight;
  final ValueChanged<int?> onWeightChanged;

  const PersonalTaskWeightSelector({
    super.key,
    required this.selectedWeight,
    required this.onWeightChanged,
  });

  static const List<Map<String, dynamic>> presets = [
    {'name': 'Light', 'weight': 15},
    {'name': 'Normal', 'weight': 30},
    {'name': 'Important', 'weight': 50},
    {'name': 'Urgent', 'weight': 80},
  ];

  Future<void> _showCustomWeightDialog(BuildContext context) async {
    final effectiveWeight = selectedWeight ?? 30;
    final controller = TextEditingController(
      text: effectiveWeight.toString(),
    );
    final result = await showDialog<int>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgDialog,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Custom Personal Weight (%)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter importance weight (1-100%) for automated fuzzy priority calculation.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  suffixText: '%',
                  filled: true,
                  fillColor: AppColors.bgCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final parsed = int.tryParse(controller.text.trim());
                  Navigator.of(ctx).pop(parsed?.clamp(1, 100));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                ),
                child: const Text('Apply Weight'),
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (result != null) {
      onWeightChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveWeight = selectedWeight ?? 30;
    final isCustom = !presets.any((p) => p['weight'] == effectiveWeight);

    return Padding(
      padding: EdgeInsets.only(top: context.rSpacing(8)),
      child: Wrap(
        spacing: context.rSpacing(8),
        runSpacing: context.rSpacing(8),
        children: [
          ...presets.map((preset) {
            final weight = preset['weight'] as int;
            final isSelected = effectiveWeight == weight && !isCustom;
            return InkWell(
              onTap: () => onWeightChanged(weight),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderSubtle,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      preset['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textBody,
                        fontSize: context.rFont(12, min: 10.5, max: 13),
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$weight%',
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryAccent
                            : AppColors.textMuted,
                        fontSize: context.rFont(11, min: 10, max: 12.5),
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          InkWell(
            onTap: () => _showCustomWeightDialog(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isCustom
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCustom
                      ? AppColors.primary
                      : AppColors.borderSubtle,
                  width: isCustom ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 13,
                    color: isCustom
                        ? AppColors.primaryAccent
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isCustom
                        ? 'Custom: $effectiveWeight%'
                        : 'Custom %',
                    style: TextStyle(
                      color: isCustom ? Colors.white : AppColors.textMuted,
                      fontSize: context.rFont(11.5, min: 10, max: 13),
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
