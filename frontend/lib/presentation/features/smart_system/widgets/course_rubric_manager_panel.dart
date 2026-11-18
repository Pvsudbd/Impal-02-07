import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../schedule/pop_up_konfirmasi_delete.dart';
import '../models/course_rubric_model.dart';
import '../models/course_rubric_repository.dart';
import 'course_rubric_modals.dart';

/// Shared Course Grading Rubrics manager panel used in both Mobile `SmartPriorityPage`
/// and Desktop `DesktopSmartPriorityView`.
///
/// Components added here automatically populate Assessment Category chips in
/// College Task creation forms and can be bidirectionally synced to Teams.
class CourseRubricManagerPanel extends StatefulWidget {
  final bool showHeaderBar;

  const CourseRubricManagerPanel({
    super.key,
    this.showHeaderBar = true,
  });

  @override
  State<CourseRubricManagerPanel> createState() =>
      _CourseRubricManagerPanelState();
}

class _CourseRubricManagerPanelState extends State<CourseRubricManagerPanel> {
  final CourseRubricRepository _repo = CourseRubricRepository();
  String? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _repo.init();
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  CourseRubricModel? get _activeCourse {
    final courses = _repo.courses;
    if (courses.isEmpty) return null;
    return _repo.getCourseById(_selectedCourseId) ?? courses.first;
  }

  Future<void> _deleteCourse(CourseRubricModel course) async {
    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: 'Delete Course Rubric?',
      message:
          'Remove "${course.courseName}" and all its grading components? This action cannot be undone.',
    );
    if (confirmed == true && mounted) {
      await _repo.deleteCourse(course.id);
      if (mounted) {
        PopUpPemberitahuan.show(
          context,
          title: 'Course Deleted',
          message: '"${course.courseName}" removed from Course Rubrics.',
          icon: Icons.delete_outline_rounded,
          iconBgColor: PopUpPemberitahuan.negativeColor,
        );
      }
    }
  }

  Future<void> _deleteComponent(
    CourseRubricModel course,
    RubricComponentModel component,
  ) async {
    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: 'Delete Component?',
      message:
          'Remove "${component.name}" (${component.weightPercent}%) from ${course.courseName}?',
    );
    if (confirmed == true && mounted) {
      await _repo.deleteComponent(
        courseId: course.id,
        componentId: component.id,
      );
      if (mounted) {
        PopUpPemberitahuan.show(
          context,
          title: 'Component Removed',
          message: '"${component.name}" removed from ${course.courseCode}.',
          icon: Icons.delete_outline_rounded,
          iconBgColor: PopUpPemberitahuan.negativeColor,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = _repo.courses;
    final activeCourse = _activeCourse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showHeaderBar) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Grading Rubrics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(16, min: 14, max: 18),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Added components sync directly to College Tasks & Teams.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: context.rFont(11.5, min: 10, max: 13),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.rSpacing(10)),
              ElevatedButton.icon(
                key: const ValueKey('rubric_add_course_btn'),
                onPressed: () => CourseEditorDialog.show(context),
                icon: Icon(Icons.add_rounded, size: context.rIcon(16)),
                label: Text(
                  'Add Course',
                  style: TextStyle(
                    fontSize: context.rFont(12, min: 11, max: 13.5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: context.rSpacing(14)),
        ],

        if (courses.isEmpty)
          _EmptyCourseRubricsState(
            onAddCourse: () => CourseEditorDialog.show(context),
          )
        else ...[
          // Course Selector Chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: courses.length,
              separatorBuilder: (_, __) =>
                  SizedBox(width: context.rSpacing(8)),
              itemBuilder: (ctx, index) {
                final c = courses[index];
                final isSelected = activeCourse?.id == c.id;
                return InkWell(
                  key: ValueKey('course_chip_${c.id}'),
                  onTap: () => setState(() => _selectedCourseId = c.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rSpacing(12),
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.16)
                          : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
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
                          c.courseCode.isNotEmpty
                              ? '${c.courseCode} • ${c.courseName}'
                              : c.courseName,
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white : AppColors.textBody,
                            fontSize: context.rFont(12, min: 10.5, max: 13.5),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: c.isComplete
                                ? const Color(0xFF10B981)
                                    .withValues(alpha: 0.18)
                                : const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${c.totalAssignedPercent}%',
                            style: TextStyle(
                              color: c.isComplete
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFFBBF24),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: context.rSpacing(14)),

          if (activeCourse != null)
            _ActiveCourseCard(
              course: activeCourse,
              onEditCourse: () => CourseEditorDialog.show(
                context,
                existingCourse: activeCourse,
              ),
              onDeleteCourse: () => _deleteCourse(activeCourse),
              onAddComponent: () => RubricComponentEditorDialog.show(
                context,
                course: activeCourse,
              ),
              onApplyPreset: () async {
                await _repo.applyPresetToCourse(activeCourse.id);
                if (context.mounted) {
                  PopUpPemberitahuan.show(
                    context,
                    title: 'Preset Applied',
                    message:
                        'Standard academic rubric applied to ${activeCourse.courseName}.',
                    icon: Icons.auto_fix_high_rounded,
                    iconBgColor: PopUpPemberitahuan.positiveColor,
                  );
                }
              },
              onEditComponent: (comp) => RubricComponentEditorDialog.show(
                context,
                course: activeCourse,
                existingComponent: comp,
              ),
              onDeleteComponent: (comp) => _deleteComponent(activeCourse, comp),
              onAssignTeam: (comp) => AssignRubricToTeamDialog.showForComponent(
                context,
                course: activeCourse,
                component: comp,
              ),
            ),
        ],
      ],
    );
  }
}

class _ActiveCourseCard extends StatelessWidget {
  final CourseRubricModel course;
  final VoidCallback onEditCourse;
  final VoidCallback onDeleteCourse;
  final VoidCallback onAddComponent;
  final VoidCallback onApplyPreset;
  final ValueChanged<RubricComponentModel> onEditComponent;
  final ValueChanged<RubricComponentModel> onDeleteComponent;
  final ValueChanged<RubricComponentModel> onAssignTeam;

  const _ActiveCourseCard({
    required this.course,
    required this.onEditCourse,
    required this.onDeleteCourse,
    required this.onAddComponent,
    required this.onApplyPreset,
    required this.onEditComponent,
    required this.onDeleteComponent,
    required this.onAssignTeam,
  });

  @override
  Widget build(BuildContext context) {
    final allocatedRatio = (course.totalAssignedPercent / 100.0).clamp(0.0, 1.0);
    final isFull = course.totalAssignedPercent >= 100;

    return Container(
      padding: EdgeInsets.all(context.rSpacing(16)),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (course.courseCode.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              course.courseCode,
                              style: TextStyle(
                                color: AppColors.primaryAccent,
                                fontSize: context.rFont(10.5, min: 9.5, max: 12),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bgPrimary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${course.credits} SKS',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: context.rFont(10.5, min: 9.5, max: 12),
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.courseName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(15, min: 13.5, max: 17),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEditCourse,
                tooltip: 'Edit Course',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: Icon(
                  Icons.edit_outlined,
                  size: context.rIcon(18),
                  color: AppColors.textMuted,
                ),
              ),
              IconButton(
                onPressed: onDeleteCourse,
                tooltip: 'Delete Course',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: context.rIcon(18),
                  color: AppColors.primaryAccent,
                ),
              ),
            ],
          ),

          SizedBox(height: context.rSpacing(10)),

          // Allocation Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Allocated: ${course.totalAssignedPercent}% / 100%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(12, min: 10.5, max: 13.5),
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              SizedBox(width: context.rSpacing(8)),
              Flexible(
                child: Text(
                  course.isComplete
                      ? '100% Complete'
                      : 'Remaining: ${course.remainingPercent}%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: course.isComplete
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFBBF24),
                    fontSize: context.rFont(11.5, min: 10, max: 13),
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: allocatedRatio,
              minHeight: 7,
              backgroundColor: AppColors.bgPrimary,
              valueColor: AlwaysStoppedAnimation<Color>(
                course.isComplete
                    ? const Color(0xFF10B981)
                    : AppColors.primary,
              ),
            ),
          ),

          SizedBox(height: context.rSpacing(14)),

          // Action buttons row
          Wrap(
            spacing: context.rSpacing(8),
            runSpacing: context.rSpacing(8),
            children: [
              ElevatedButton.icon(
                key: ValueKey('add_component_btn_${course.id}'),
                onPressed: isFull ? null : onAddComponent,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(
                  isFull ? '100% Allocated' : 'Add Component',
                  style: TextStyle(
                    fontSize: context.rFont(12, min: 11, max: 13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.bgPrimary.withValues(alpha: 0.7),
                  disabledForegroundColor: AppColors.textMuted,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
              if (course.components.isEmpty)
                OutlinedButton.icon(
                  onPressed: onApplyPreset,
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                  label: Text(
                    'Apply Standard Preset',
                    style: TextStyle(
                      fontSize: context.rFont(12, min: 11, max: 13),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: context.rSpacing(14)),

          if (course.components.isEmpty)
            Container(
              padding: EdgeInsets.all(context.rSpacing(16)),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(
                'No grading components yet. Add components like Midterm (UTS), Quiz, or Team Project to auto-populate task & team categories.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: context.rFont(12, min: 11, max: 13.5),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: course.components.length,
              separatorBuilder: (_, __) =>
                  SizedBox(height: context.rSpacing(8)),
              itemBuilder: (ctx, idx) {
                final comp = course.components[idx];
                return _RubricComponentRow(
                  component: comp,
                  onAssignTeam: () => onAssignTeam(comp),
                  onEdit: () => onEditComponent(comp),
                  onDelete: () => onDeleteComponent(comp),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _RubricComponentRow extends StatelessWidget {
  final RubricComponentModel component;
  final VoidCallback onAssignTeam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RubricComponentRow({
    required this.component,
    required this.onAssignTeam,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasTeam = component.isAssignedToTeam;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(12),
        vertical: context.rSpacing(10),
      ),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasTeam
              ? const Color(0xFF4A90E2).withValues(alpha: 0.45)
              : AppColors.borderSubtle,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 400;

          final weightBadge = Container(
            constraints: const BoxConstraints(minWidth: 48),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${component.weightPercent}%',
              style: TextStyle(
                color: AppColors.primaryAccent,
                fontSize: context.rFont(12.5, min: 11, max: 14),
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          );

          final infoCol = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                component.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(13.5, min: 12, max: 15),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: hasTeam
                      ? const Color(0xFF4A90E2).withValues(alpha: 0.16)
                      : const Color(0xFF10B981).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasTeam
                          ? Icons.groups_rounded
                          : Icons.category_outlined,
                      size: 12,
                      color: hasTeam
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        hasTeam
                            ? 'Team: ${component.assignedTeamName}'
                            : 'Auto Task Category',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hasTeam
                              ? const Color(0xFF93C5FD)
                              : const Color(0xFF34D399),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final actionIcons = Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                key: ValueKey('assign_team_btn_${component.id}'),
                onPressed: onAssignTeam,
                tooltip: hasTeam ? 'Change Assigned Team' : 'Assign to Team',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: Icon(
                  Icons.groups_outlined,
                  size: context.rIcon(18),
                  color: hasTeam ? const Color(0xFF60A5FA) : AppColors.textMuted,
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit Component',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: Icon(
                  Icons.edit_outlined,
                  size: context.rIcon(17),
                  color: AppColors.textMuted,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Delete Component',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: context.rIcon(17),
                  color: AppColors.primaryAccent,
                ),
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    weightBadge,
                    SizedBox(width: context.rSpacing(12)),
                    Expanded(child: infoCol),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: actionIcons,
                ),
              ],
            );
          }

          return Row(
            children: [
              weightBadge,
              SizedBox(width: context.rSpacing(12)),
              Expanded(child: infoCol),
              actionIcons,
            ],
          );
        },
      ),
    );
  }
}

class _EmptyCourseRubricsState extends StatelessWidget {
  final VoidCallback onAddCourse;
  const _EmptyCourseRubricsState({required this.onAddCourse});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.rSpacing(24)),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(
            Icons.grading_rounded,
            size: context.rIcon(38),
            color: AppColors.primaryAccent,
          ),
          SizedBox(height: context.rSpacing(10)),
          Text(
            'No Course Rubrics Configured',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(15, min: 13.5, max: 16.5),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.rSpacing(6)),
          Text(
            'Create your first course rubric to auto-generate assessment categories across Tasks and Teams.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(12, min: 11, max: 13.5),
            ),
          ),
          SizedBox(height: context.rSpacing(14)),
          ElevatedButton.icon(
            onPressed: onAddCourse,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add First Course'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
