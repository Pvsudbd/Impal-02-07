import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../../core/widgets/unfocus_on_tap.dart';
import '../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../team/models/team_repository.dart';
import '../models/course_rubric_model.dart';
import '../models/course_rubric_repository.dart';

/// Modal for Adding or Editing a Course (`CourseRubricModel`).
class CourseEditorDialog extends StatefulWidget {
  final CourseRubricModel? existingCourse;

  const CourseEditorDialog({super.key, this.existingCourse});

  static Future<bool?> show(
    BuildContext context, {
    CourseRubricModel? existingCourse,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => CourseEditorDialog(existingCourse: existingCourse),
    );
  }

  @override
  State<CourseEditorDialog> createState() => _CourseEditorDialogState();
}

class _CourseEditorDialogState extends State<CourseEditorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late int _credits;
  bool _applyPreset = true;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingCourse != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingCourse;
    _codeController = TextEditingController(text: existing?.courseCode ?? '');
    _nameController = TextEditingController(text: existing?.courseName ?? '');
    _credits = existing?.credits ?? 3;
    _applyPreset = !_isEditing;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _close([bool? result]) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(result);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);

    final repo = CourseRubricRepository();
    final res = _isEditing
        ? await repo.updateCourse(
            courseId: widget.existingCourse!.id,
            courseCode: _codeController.text,
            courseName: _nameController.text,
            credits: _credits,
          )
        : await repo.addCourse(
            courseCode: _codeController.text,
            courseName: _nameController.text,
            credits: _credits,
            applyStandardPreset: _applyPreset,
          );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!res.success) {
      PopUpPemberitahuan.show(
        context,
        title: 'Course Error',
        message: res.errorMessage ?? 'Unable to save course.',
        icon: Icons.error_outline_rounded,
        iconBgColor: PopUpPemberitahuan.negativeColor,
      );
      return;
    }

    PopUpPemberitahuan.show(
      context,
      title: _isEditing ? 'Course Updated' : 'Course Added',
      message: _isEditing
          ? 'Course rubric metadata updated successfully.'
          : 'New course added to Smart Priority rubrics.',
      icon: Icons.school_rounded,
      iconBgColor: PopUpPemberitahuan.positiveColor,
    );
    _close(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(20),
        vertical: context.rSpacing(24),
      ),
      child: UnfocusOnTap(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            padding: EdgeInsets.all(context.rSpacing(22)),
            decoration: BoxDecoration(
              color: AppColors.bgDialog,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ModalHeader(
                      title: _isEditing ? 'Edit Course' : 'Add Course',
                      onClose: () => _close(false),
                    ),
                    SizedBox(height: context.rSpacing(18)),
                    const _FieldLabel(label: 'Course Code'),
                    SizedBox(height: context.rSpacing(6)),
                    TextFormField(
                      key: const ValueKey('course_code_field'),
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      style: _inputTextStyle(context),
                      decoration: _inputDecoration(
                        context,
                        hint: 'e.g. SSIF-04-REG or IMPAL',
                      ),
                    ),
                    SizedBox(height: context.rSpacing(14)),
                    const _FieldLabel(label: 'Course Name'),
                    SizedBox(height: context.rSpacing(6)),
                    TextFormField(
                      key: const ValueKey('course_name_field'),
                      controller: _nameController,
                      style: _inputTextStyle(context),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter the course name.';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        context,
                        hint: 'e.g. Software Testing & Implementation',
                      ),
                    ),
                    SizedBox(height: context.rSpacing(14)),
                    const _FieldLabel(label: 'Credits (SKS)'),
                    SizedBox(height: context.rSpacing(8)),
                    Wrap(
                      spacing: context.rSpacing(8),
                      runSpacing: context.rSpacing(8),
                      children: [1, 2, 3, 4].map((sks) {
                        final selected = _credits == sks;
                        return InkWell(
                          onTap: () => setState(() => _credits = sks),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 56,
                              minHeight: 40,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withValues(alpha: 0.18)
                                  : AppColors.bgCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.borderSubtle,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$sks SKS',
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textMuted,
                                    fontSize:
                                        context.rFont(12.5, min: 11, max: 14),
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (!_isEditing) ...[
                      SizedBox(height: context.rSpacing(14)),
                      InkWell(
                        onTap: () =>
                            setState(() => _applyPreset = !_applyPreset),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.all(context.rSpacing(12)),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _applyPreset
                                      ? AppColors.primary
                                      : AppColors.bgPrimary,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: _applyPreset
                                        ? AppColors.primary
                                        : AppColors.borderMedium,
                                  ),
                                ),
                                child: _applyPreset
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              SizedBox(width: context.rSpacing(10)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Apply Standard Rubric Preset',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: context.rFont(12.5,
                                            min: 11, max: 14),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Midterm (UTS), Final Exam (UAS), Quiz, Assignment, Team Project',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: context.rFont(11,
                                            min: 10, max: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: context.rSpacing(20)),
                    _PrimarySubmitButton(
                      key: const ValueKey('save_course_btn'),
                      label: _isEditing ? 'Save Changes' : 'Add Course',
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Modal for Adding or Editing a Rubric Component inside a Course.
class RubricComponentEditorDialog extends StatefulWidget {
  final CourseRubricModel course;
  final RubricComponentModel? existingComponent;

  const RubricComponentEditorDialog({
    super.key,
    required this.course,
    this.existingComponent,
  });

  static Future<bool?> show(
    BuildContext context, {
    required CourseRubricModel course,
    RubricComponentModel? existingComponent,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => RubricComponentEditorDialog(
        course: course,
        existingComponent: existingComponent,
      ),
    );
  }

  @override
  State<RubricComponentEditorDialog> createState() =>
      _RubricComponentEditorDialogState();
}

class _RubricComponentEditorDialogState
    extends State<RubricComponentEditorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  String? _selectedTeamId;
  String? _selectedTeamName;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingComponent != null;

  int get _maxAllowedWeight {
    if (!_isEditing) return widget.course.remainingPercent;
    final otherSum = widget.course.components
        .where((c) => c.id != widget.existingComponent!.id)
        .fold<int>(0, (sum, c) => sum + c.weightPercent);
    return (100 - otherSum).clamp(0, 100);
  }

  static const List<String> _quickNames = [
    'Midterm (UTS)',
    'Final Exam (UAS)',
    'Quiz',
    'Assignment',
    'Team Project',
    'Practicum',
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingComponent;
    _nameController = TextEditingController(text: existing?.name ?? '');
    final defaultWeight = existing?.weightPercent ??
        (_maxAllowedWeight >= 20 ? 20 : _maxAllowedWeight.clamp(1, 20));
    _weightController = TextEditingController(
      text: _maxAllowedWeight > 0 ? '$defaultWeight' : '0',
    );
    _selectedTeamId = existing?.assignedTeamId;
    _selectedTeamName = existing?.assignedTeamName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _close([bool? result]) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(result);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final parsed = int.tryParse(_weightController.text.trim()) ?? 0;

    setState(() => _isSubmitting = true);
    final repo = CourseRubricRepository();
    final res = _isEditing
        ? await repo.updateComponent(
            courseId: widget.course.id,
            componentId: widget.existingComponent!.id,
            name: _nameController.text,
            weightPercent: parsed,
          )
        : await repo.addComponent(
            courseId: widget.course.id,
            name: _nameController.text,
            weightPercent: parsed,
            assignedTeamId: _selectedTeamId,
            assignedTeamName: _selectedTeamName,
          );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!res.success) {
      PopUpPemberitahuan.show(
        context,
        title: 'Weight Limit Exceeded',
        message: res.errorMessage ?? 'Unable to save rubric component.',
        icon: Icons.warning_amber_rounded,
        iconBgColor: PopUpPemberitahuan.negativeColor,
      );
      return;
    }

    PopUpPemberitahuan.show(
      context,
      title: _isEditing ? 'Component Updated' : 'Component Added',
      message:
          '"${_nameController.text.trim()}" ($parsed%) is now active as a task & team category.',
      icon: Icons.check_circle_outline_rounded,
      iconBgColor: PopUpPemberitahuan.positiveColor,
    );
    _close(true);
  }

  @override
  Widget build(BuildContext context) {
    final teams = TeamRepository().teams;
    final currentWeight = int.tryParse(_weightController.text.trim()) ?? 0;
    final exceedsCap = currentWeight > _maxAllowedWeight || currentWeight < 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(20),
        vertical: context.rSpacing(24),
      ),
      child: UnfocusOnTap(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            padding: EdgeInsets.all(context.rSpacing(22)),
            decoration: BoxDecoration(
              color: AppColors.bgDialog,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ModalHeader(
                      title: _isEditing
                          ? 'Edit Rubric Component'
                          : 'Add Rubric Component',
                      onClose: () => _close(false),
                    ),
                    SizedBox(height: context.rSpacing(10)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.rSpacing(12),
                        vertical: context.rSpacing(8),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.course.displayLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textBody,
                                fontSize: context.rFont(12, min: 11, max: 13.5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: context.rSpacing(8)),
                          Text(
                            'Remaining: $_maxAllowedWeight%',
                            style: TextStyle(
                              color: _maxAllowedWeight > 0
                                  ? const Color(0xFF10B981)
                                  : AppColors.primaryAccent,
                              fontSize: context.rFont(11.5, min: 10, max: 13),
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.rSpacing(14)),
                    const _FieldLabel(label: 'Category Name'),
                    SizedBox(height: context.rSpacing(6)),
                    TextFormField(
                      key: const ValueKey('rubric_component_name_field'),
                      controller: _nameController,
                      style: _inputTextStyle(context),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter a category name.';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        context,
                        hint: 'e.g. Midterm (UTS), Quiz, Team Project',
                      ),
                    ),
                    SizedBox(height: context.rSpacing(8)),
                    Wrap(
                      spacing: context.rSpacing(6),
                      runSpacing: context.rSpacing(6),
                      children: _quickNames.map((label) {
                        return InkWell(
                          onTap: () =>
                              setState(() => _nameController.text = label),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: context.rFont(11, min: 10, max: 12),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: context.rSpacing(14)),
                    const _FieldLabel(label: 'Grade Weight (%)'),
                    SizedBox(height: context.rSpacing(6)),
                    TextFormField(
                      key: const ValueKey('rubric_component_weight_field'),
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                      style: _inputTextStyle(context).copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      validator: (v) {
                        final n = int.tryParse(v?.trim() ?? '');
                        if (n == null || n < 1) {
                          return 'Weight must be at least 1%.';
                        }
                        if (n > _maxAllowedWeight) {
                          return 'Cannot exceed remaining $_maxAllowedWeight%.';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        context,
                        hint: 'Enter percentage (1 - $_maxAllowedWeight)',
                        suffixText: '%',
                      ),
                    ),
                    SizedBox(height: context.rSpacing(8)),
                    Wrap(
                      spacing: context.rSpacing(6),
                      runSpacing: context.rSpacing(6),
                      children: [10, 15, 20, 25, 30, 40].map((pct) {
                        final enabled = pct <= _maxAllowedWeight;
                        return InkWell(
                          onTap: enabled
                              ? () => setState(
                                    () => _weightController.text = '$pct',
                                  )
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: currentWeight == pct
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : AppColors.bgCard,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: currentWeight == pct
                                    ? AppColors.primary
                                    : AppColors.borderSubtle,
                              ),
                            ),
                            child: Text(
                              '$pct%',
                              style: TextStyle(
                                color: enabled
                                    ? (currentWeight == pct
                                        ? Colors.white
                                        : AppColors.textBody)
                                    : AppColors.textSubtle,
                                fontSize: context.rFont(11.5, min: 10, max: 13),
                                fontWeight: FontWeight.w600,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (!_isEditing && teams.isNotEmpty) ...[
                      SizedBox(height: context.rSpacing(14)),
                      const _FieldLabel(label: 'Assign to Team (Optional)'),
                      SizedBox(height: context.rSpacing(6)),
                      DropdownButtonFormField<String?>(
                        initialValue: _selectedTeamId,
                        isExpanded: true,
                        dropdownColor: AppColors.bgCard,
                        style: _inputTextStyle(context),
                        decoration: _inputDecoration(
                          context,
                          hint: 'Coursework Category (No Team)',
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Coursework Category (Personal / All)'),
                          ),
                          ...teams.map(
                            (t) => DropdownMenuItem<String?>(
                              value: t.id,
                              child: Text(t.name),
                            ),
                          ),
                        ],
                        onChanged: (teamId) {
                          setState(() {
                            _selectedTeamId = teamId;
                            if (teamId == null) {
                              _selectedTeamName = null;
                            } else {
                              _selectedTeamName = teams
                                  .firstWhere((t) => t.id == teamId)
                                  .name;
                            }
                          });
                        },
                      ),
                    ],
                    if (exceedsCap) ...[
                      SizedBox(height: context.rSpacing(10)),
                      Text(
                        'Available capacity in this course is $_maxAllowedWeight%.',
                        style: TextStyle(
                          color: AppColors.primaryAccent,
                          fontSize: context.rFont(11.5, min: 10.5, max: 13),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    SizedBox(height: context.rSpacing(20)),
                    _PrimarySubmitButton(
                      key: const ValueKey('save_rubric_component_btn'),
                      label: _isEditing ? 'Save Changes' : 'Add Component',
                      isLoading: _isSubmitting,
                      isDisabled: exceedsCap,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bidirectional Team Rubric Assignment Modal.
///
/// Mode A (`component != null`): Pick which Team links to `(course, component)`.
/// Mode B (`teamId / teamName != null`): Pick `(Course -> Component)` to sync to that Team.
class AssignRubricToTeamDialog extends StatefulWidget {
  final CourseRubricModel? course;
  final RubricComponentModel? component;
  final String? teamId;
  final String? teamName;

  const AssignRubricToTeamDialog({
    super.key,
    this.course,
    this.component,
    this.teamId,
    this.teamName,
  });

  static Future<bool?> showForComponent(
    BuildContext context, {
    required CourseRubricModel course,
    required RubricComponentModel component,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => AssignRubricToTeamDialog(
        course: course,
        component: component,
      ),
    );
  }

  static Future<bool?> showForTeam(
    BuildContext context, {
    required String teamId,
    required String teamName,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => AssignRubricToTeamDialog(
        teamId: teamId,
        teamName: teamName,
      ),
    );
  }

  @override
  State<AssignRubricToTeamDialog> createState() =>
      _AssignRubricToTeamDialogState();
}

class _AssignRubricToTeamDialogState extends State<AssignRubricToTeamDialog> {
  String? _selectedCourseId;
  String? _selectedComponentId;
  String? _selectedTeamId;
  bool _isSubmitting = false;

  bool get _isTeamFocused =>
      widget.teamName != null && widget.component == null;

  @override
  void initState() {
    super.initState();
    final repo = CourseRubricRepository();
    if (_isTeamFocused) {
      final linked = repo.getLinkedRubricForTeam(
        teamId: widget.teamId,
        teamName: widget.teamName,
      );
      if (linked != null) {
        _selectedCourseId = linked.course.id;
        _selectedComponentId = linked.component.id;
      } else if (repo.courses.isNotEmpty) {
        _selectedCourseId = repo.courses.first.id;
        if (repo.courses.first.components.isNotEmpty) {
          _selectedComponentId = repo.courses.first.components.last.id;
        }
      }
    } else {
      _selectedCourseId = widget.course?.id;
      _selectedComponentId = widget.component?.id;
      _selectedTeamId = widget.component?.assignedTeamId;
    }
  }

  void _close([bool? result]) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(result);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final repo = CourseRubricRepository();
    final teams = TeamRepository().teams;

    if (_isTeamFocused) {
      if (_selectedCourseId == null || _selectedComponentId == null) {
        await repo.clearTeamAssignment(
          teamId: widget.teamId,
          teamName: widget.teamName,
        );
        if (!mounted) return;
        PopUpPemberitahuan.show(
          context,
          title: 'Team Rubric Unlinked',
          message: 'Grading rubric link removed from ${widget.teamName}.',
          icon: Icons.link_off_rounded,
          iconBgColor: PopUpPemberitahuan.negativeColor,
        );
        _close(true);
        return;
      }
      final res = await repo.assignComponentToTeam(
        courseId: _selectedCourseId!,
        componentId: _selectedComponentId!,
        teamId: widget.teamId ?? widget.teamName!,
        teamName: widget.teamName!,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (res.success) {
        PopUpPemberitahuan.show(
          context,
          title: 'Team Rubric Synced',
          message:
              '${widget.teamName} is now synced to the selected course rubric.',
          icon: Icons.sync_rounded,
          iconBgColor: PopUpPemberitahuan.positiveColor,
        );
        _close(true);
      }
      return;
    }

    if (_selectedTeamId == null) {
      await repo.clearTeamAssignment(
        teamId: widget.component?.assignedTeamId,
        teamName: widget.component?.assignedTeamName,
      );
      if (!mounted) return;
      PopUpPemberitahuan.show(
        context,
        title: 'Team Assignment Cleared',
        message:
            '"${widget.component?.name}" is now unassigned from any team.',
        icon: Icons.link_off_rounded,
        iconBgColor: PopUpPemberitahuan.negativeColor,
      );
      _close(true);
      return;
    }

    final team = teams.firstWhere(
      (t) => t.id == _selectedTeamId,
      orElse: () => teams.first,
    );
    await repo.assignComponentToTeam(
      courseId: widget.course!.id,
      componentId: widget.component!.id,
      teamId: team.id,
      teamName: team.name,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    PopUpPemberitahuan.show(
      context,
      title: 'Rubric Assigned to Team',
      message:
          '"${widget.component!.name}" (${widget.component!.weightPercent}%) synced to ${team.name}.',
      icon: Icons.groups_rounded,
      iconBgColor: PopUpPemberitahuan.positiveColor,
    );
    _close(true);
  }

  @override
  Widget build(BuildContext context) {
    final repo = CourseRubricRepository();
    final courses = repo.courses;
    final teams = TeamRepository().teams;
    final selectedCourse = repo.getCourseById(_selectedCourseId);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(20),
        vertical: context.rSpacing(24),
      ),
      child: UnfocusOnTap(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            padding: EdgeInsets.all(context.rSpacing(22)),
            decoration: BoxDecoration(
              color: AppColors.bgDialog,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModalHeader(
                    title: _isTeamFocused
                        ? 'Sync Team Grading Rubric'
                        : 'Assign Component to Team',
                    onClose: () => _close(false),
                  ),
                  SizedBox(height: context.rSpacing(14)),
                  if (_isTeamFocused) ...[
                    Container(
                      padding: EdgeInsets.all(context.rSpacing(12)),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.groups_rounded,
                            color: const Color(0xFF4A90E2),
                            size: context.rIcon(18),
                          ),
                          SizedBox(width: context.rSpacing(8)),
                          Expanded(
                            child: Text(
                              'Team: ${widget.teamName}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.rFont(13, min: 11.5, max: 14),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.rSpacing(14)),
                    const _FieldLabel(label: 'Course'),
                    SizedBox(height: context.rSpacing(6)),
                    DropdownButtonFormField<String?>(
                      key: const ValueKey('sync_team_course_dropdown'),
                      initialValue: _selectedCourseId,
                      isExpanded: true,
                      dropdownColor: AppColors.bgCard,
                      style: _inputTextStyle(context),
                      decoration: _inputDecoration(
                        context,
                        hint: 'Select Course',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            'No Linked Course',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...courses.map(
                          (c) => DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(
                              c.displayLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (courseId) {
                        setState(() {
                          _selectedCourseId = courseId;
                          final c = repo.getCourseById(courseId);
                          _selectedComponentId =
                              (c != null && c.components.isNotEmpty)
                                  ? c.components.first.id
                                  : null;
                        });
                      },
                    ),
                    if (selectedCourse != null) ...[
                      SizedBox(height: context.rSpacing(14)),
                      const _FieldLabel(label: 'Assessment Component'),
                      SizedBox(height: context.rSpacing(6)),
                      DropdownButtonFormField<String?>(
                        key: const ValueKey('sync_team_component_dropdown'),
                        initialValue: _selectedComponentId,
                        isExpanded: true,
                        dropdownColor: AppColors.bgCard,
                        style: _inputTextStyle(context),
                        decoration: _inputDecoration(
                          context,
                          hint: 'Select Rubric Component',
                        ),
                        items: selectedCourse.components
                            .map(
                              (comp) => DropdownMenuItem<String?>(
                                value: comp.id,
                                child: Text(
                                  '${comp.name} (${comp.weightPercent}%)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (compId) {
                          setState(() => _selectedComponentId = compId);
                        },
                      ),
                    ],
                  ] else ...[
                    Container(
                      padding: EdgeInsets.all(context.rSpacing(12)),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.course?.displayLabel ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize:
                                        context.rFont(11, min: 10, max: 12),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.component?.name ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.rFont(13.5,
                                        min: 12, max: 15),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${widget.component?.weightPercent ?? 0}%',
                              style: TextStyle(
                                color: AppColors.primaryAccent,
                                fontSize: context.rFont(12, min: 11, max: 13),
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
                    SizedBox(height: context.rSpacing(14)),
                    const _FieldLabel(label: 'Target Team'),
                    SizedBox(height: context.rSpacing(6)),
                    DropdownButtonFormField<String?>(
                      key: const ValueKey('assign_component_team_dropdown'),
                      initialValue: _selectedTeamId,
                      isExpanded: true,
                      dropdownColor: AppColors.bgCard,
                      style: _inputTextStyle(context),
                      decoration: _inputDecoration(
                        context,
                        hint: 'Select Team',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('None (Personal / Coursework Category)'),
                        ),
                        ...teams.map(
                          (t) => DropdownMenuItem<String?>(
                            value: t.id,
                            child: Text(t.name),
                          ),
                        ),
                      ],
                      onChanged: (teamId) {
                        setState(() => _selectedTeamId = teamId);
                      },
                    ),
                  ],
                  SizedBox(height: context.rSpacing(20)),
                  _PrimarySubmitButton(
                    key: const ValueKey('confirm_assign_rubric_btn'),
                    label: _isTeamFocused ? 'Sync Grading Rubric' : 'Save Assignment',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _ModalHeader({
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(17, min: 15, max: 19),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: const Center(
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white,
        fontSize: context.rFont(13, min: 11.5, max: 14.5),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _PrimarySubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  const _PrimarySubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    this.isDisabled = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || isDisabled;
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(14, min: 12.5, max: 15.5),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TextStyle _inputTextStyle(BuildContext context) {
  return TextStyle(
    color: Colors.white,
    fontSize: context.rFont(13, min: 11.5, max: 14.5),
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  );
}

InputDecoration _inputDecoration(
  BuildContext context, {
  required String hint,
  String? suffixText,
}) {
  return InputDecoration(
    hintText: hint,
    suffixText: suffixText,
    suffixStyle: TextStyle(
      color: AppColors.textMuted,
      fontSize: context.rFont(13, min: 12, max: 14),
      fontWeight: FontWeight.w600,
    ),
    hintStyle: TextStyle(
      color: AppColors.textSubtle,
      fontSize: context.rFont(12.5, min: 11, max: 14),
    ),
    filled: true,
    fillColor: AppColors.bgCard,
    contentPadding: EdgeInsets.symmetric(
      horizontal: context.rSpacing(14),
      vertical: context.rSpacing(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
  );
}

/// Shared Grading Rubric Inheritance & Optional Override selector used in both
/// Mobile `CreateTaskTeamPage` and Desktop `DesktopTeamTaskModal`.
class TeamRubricLinkSection extends StatelessWidget {
  final String teamCode;
  final String teamName;
  final String? overrideComponentId;
  final ValueChanged<RubricComponentModel?> onOverrideChanged;
  final bool darkSurface;

  const TeamRubricLinkSection({
    super.key,
    required this.teamCode,
    required this.teamName,
    required this.overrideComponentId,
    required this.onOverrideChanged,
    this.darkSurface = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CourseRubricRepository(),
      builder: (context, _) {
        final repo = CourseRubricRepository();
        final linked = repo.getLinkedRubricForTeam(
          teamId: teamCode,
          teamName: teamName,
        );

        if (linked == null) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.rSpacing(12)),
            decoration: BoxDecoration(
              color: darkSurface ? AppColors.bgPrimary : AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.grading_outlined,
                  size: context.rIcon(16),
                  color: AppColors.textMuted,
                ),
                SizedBox(width: context.rSpacing(8)),
                Expanded(
                  child: Text(
                    'No Course Rubric linked to this team yet.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: context.rFont(11.5, min: 10.5, max: 13),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => AssignRubricToTeamDialog.showForTeam(
                    context,
                    teamId: teamCode,
                    teamName: teamName,
                  ),
                  child: const Text(
                    'Link',
                    style: TextStyle(
                      color: AppColors.primaryAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final components = linked.course.components;
        final activeId = overrideComponentId ?? linked.component.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _FieldLabel(label: 'Course Grading Weight (Team Synced)'),
            const SizedBox(height: 6),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.rSpacing(12),
                vertical: context.rSpacing(8),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF4A90E2).withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sync_rounded,
                    size: context.rIcon(15),
                    color: const Color(0xFF60A5FA),
                  ),
                  SizedBox(width: context.rSpacing(8)),
                  Expanded(
                    child: Text(
                      '${linked.course.courseCode.isNotEmpty ? linked.course.courseCode : linked.course.courseName} • Default: ${linked.component.name} (${linked.component.weightPercent}%)',
                      style: TextStyle(
                        color: const Color(0xFF93C5FD),
                        fontSize: context.rFont(11.5, min: 10.5, max: 13),
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (components.isNotEmpty) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey('team_task_rubric_override_$activeId'),
                initialValue:
                    components.any((c) => c.id == activeId) ? activeId : null,
                isExpanded: true,
                dropdownColor: AppColors.bgCard,
                style: _inputTextStyle(context),
                decoration: _inputDecoration(
                  context,
                  hint: 'Select rubric component',
                ),
                items: components
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(
                          '${c.name} (${c.weightPercent}%)${c.id == linked.component.id ? " • Team Default" : ""}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (compId) {
                  if (compId == null || compId == linked.component.id) {
                    onOverrideChanged(null);
                  } else {
                    final match = components.firstWhere((c) => c.id == compId);
                    onOverrideChanged(match);
                  }
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
