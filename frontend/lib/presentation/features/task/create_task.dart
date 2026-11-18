import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../../core/widgets/unfocus_on_tap.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../profile/models/user_profile_model.dart';
import '../schedule/pop_up_konfirmasi_delete.dart';
import '../smart_system/models/course_rubric_model.dart';
import '../smart_system/models/course_rubric_repository.dart';
import '../team/widgets/submission_deadline_picker.dart';
import 'models/task_item_model.dart';
import 'models/task_repository.dart';
import 'widgets/course_grade_weight_chips.dart';
import 'widgets/desktop/desktop_personal_task_modal.dart';
import 'widgets/task_category_selector.dart';

// Backward compatibility aliases matching Figma exports
export 'models/task_item_model.dart';

typedef AddNewTask = CreateTaskPage;
typedef TaskFormPage = CreateTaskPage;
typedef EditTaskPage = CreateTaskPage;
typedef EditTask = CreateTaskPage;

/// Unified dual-mode Form for Creating and Editing Tasks.
///
/// Complies strictly with AGENTS.md, ResponsiveContext, UnfocusOnTap,
/// loading button label retention, and PopUpPemberitahuan standards.
class CreateTaskPage extends StatefulWidget {
  final TaskItemModel? task;
  final TaskItemModel? existingTask;
  final void Function(TaskItemModel task)? onTaskCreated;
  final void Function(TaskItemModel updatedTask)? onTaskUpdated;
  final VoidCallback? onBack;
  final String userInitials;

  const CreateTaskPage({
    super.key,
    this.task,
    this.existingTask,
    this.onTaskCreated,
    this.onTaskUpdated,
    this.onBack,
    this.userInitials = 'JS',
  });

  TaskItemModel? get targetTask => task ?? existingTask;

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _courseController;
  late final TextEditingController _notesController;

  late bool _isCollegeTask;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TaskPriorityLevel _selectedPriority;
  late bool _isAutomaticWeight;
  late bool _isAlertEnabled;
  String? _selectedCourseId;
  String? _selectedComponentId;
  int? _customWeightPercent;
  final CourseRubricRepository _rubricRepo = CourseRubricRepository();
  bool _isSubmitting = false;

  bool get _isEditing => widget.targetTask != null;

  @override
  void initState() {
    super.initState();
    _rubricRepo.init();
    _rubricRepo.addListener(_onRubricsChanged);
    final task = widget.targetTask;
    if (task != null) {
      _isCollegeTask = task.isCollegeTask;
      _titleController = TextEditingController(text: task.title);
      _courseController = TextEditingController(text: task.course);
      _notesController = TextEditingController(text: task.notes);
      _selectedDate = task.deadlineDate;
      _selectedTime = _parseTimeOfDay(task.formattedDeadline);
      _selectedPriority = task.priority;
      _isAutomaticWeight = task.isAutomaticWeight;
      _isAlertEnabled = task.isAlertEnabled;
      final matched = _rubricRepo.getCourseById(task.rubricCourseId) ??
          _rubricRepo.findCourseByTextOrId(task.course);
      _selectedCourseId = matched?.id;
      _selectedComponentId = task.rubricComponentId ??
          (matched != null && matched.components.isNotEmpty
              ? matched.components.first.id
              : null);
      if (task.rubricComponentId == null && task.gradeWeightPercent != null) {
        _customWeightPercent = task.gradeWeightPercent;
      }
    } else {
      _isCollegeTask = true;
      _titleController = TextEditingController();
      final defaultCourse = _rubricRepo.courses.isNotEmpty
          ? _rubricRepo.courses.first
          : null;
      _courseController = TextEditingController(
        text: defaultCourse?.displayLabel ??
            'SSIF-04-REG • Software Testing & Implementation',
      );
      _selectedCourseId = defaultCourse?.id;
      _selectedComponentId =
          (defaultCourse != null && defaultCourse.components.isNotEmpty)
              ? defaultCourse.components.first.id
              : null;
      _notesController = TextEditingController();
      _selectedDate = DateTime(2026, 10, 18);
      _selectedTime = const TimeOfDay(hour: 23, minute: 59);
      _selectedPriority = TaskPriorityLevel.high;
      _isAutomaticWeight = true;
      _isAlertEnabled = true;
    }
  }

  void _onRubricsChanged() {
    if (mounted) setState(() {});
  }

  CourseRubricModel? get _activeRubricCourse =>
      _rubricRepo.getCourseById(_selectedCourseId) ??
      _rubricRepo.findCourseByTextOrId(_courseController.text);

  @override
  void dispose() {
    _rubricRepo.removeListener(_onRubricsChanged);
    _titleController.dispose();
    _courseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  static TimeOfDay _parseTimeOfDay(String timeStr) {
    final match = RegExp(r'(\d{1,2}):\s*(\d{2})').firstMatch(timeStr);
    if (match != null) {
      final h = int.tryParse(match.group(1)!) ?? 23;
      final m = int.tryParse(match.group(2)!) ?? 59;
      return TimeOfDay(hour: h, minute: m);
    }
    return const TimeOfDay(hour: 23, minute: 59);
  }

  String _formatDeadline(DateTime date, TimeOfDay time) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$dayName ${date.day} $monthName ${date.year}, $h: $m WIB';
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate async network latency
    await Future.delayed(const Duration(milliseconds: 350));

    final title = _titleController.text.trim();
    final course = _isCollegeTask ? _courseController.text.trim() : '';
    final notes = _notesController.text.trim();
    final formattedDeadline = _formatDeadline(_selectedDate, _selectedTime);

    final activeCourse = _activeRubricCourse;
    final selectedComp = _rubricRepo.findComponent(
      activeCourse?.id,
      _selectedComponentId,
    );
    final resolvedWeight = _isCollegeTask && _isAutomaticWeight
        ? (_customWeightPercent ?? selectedComp?.weightPercent)
        : null;

    if (_isEditing) {
      final updated = widget.targetTask!.copyWith(
        title: title,
        course: course.isNotEmpty
            ? course
            : (_isCollegeTask ? widget.targetTask!.course : ''),
        notes: notes,
        deadlineDate: _selectedDate,
        formattedDeadline: formattedDeadline,
        priority: _selectedPriority,
        isAutomaticWeight: _isAutomaticWeight,
        isCollegeTask: _isCollegeTask,
        isAlertEnabled: _isAlertEnabled,
        rubricCourseId: _isCollegeTask ? activeCourse?.id : null,
        rubricComponentId:
            _isCollegeTask && _customWeightPercent == null ? selectedComp?.id : null,
        rubricComponentName: _isCollegeTask && _customWeightPercent == null
            ? selectedComp?.name
            : null,
        gradeWeightPercent: resolvedWeight,
      );

      TaskRepository().updateTask(updated);
      widget.onTaskUpdated?.call(updated);
      if (mounted) {
        PopUpPemberitahuan.taskUpdated(context, taskName: title);
        Navigator.of(context).pop(updated);
      }
    } else {
      final newTask = TaskItemModel(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        course: _isCollegeTask
            ? (course.isNotEmpty ? course : 'General Course')
            : '',
        notes: notes,
        deadlineDate: _selectedDate,
        formattedDeadline: formattedDeadline,
        priority: _selectedPriority,
        durationBadge: _selectedPriority == TaskPriorityLevel.high ? '12h' : '24h',
        isAutomaticWeight: _isAutomaticWeight,
        isCollegeTask: _isCollegeTask,
        isAlertEnabled: _isAlertEnabled,
        rubricCourseId: _isCollegeTask ? activeCourse?.id : null,
        rubricComponentId:
            _isCollegeTask && _customWeightPercent == null ? selectedComp?.id : null,
        rubricComponentName: _isCollegeTask && _customWeightPercent == null
            ? selectedComp?.name
            : null,
        gradeWeightPercent: resolvedWeight,
        subtitle: 'Personal & Team task',
        tags: [
          TaskTagModel(
            label: (_isCollegeTask && selectedComp != null)
                ? '${selectedComp.name} (${resolvedWeight ?? selectedComp.weightPercent}%)'
                : 'Task',
            backgroundColor: _selectedPriority.badgeBg,
            textColor: Colors.white,
          ),
        ],
        groupMembers: const ['Personal Task • Jarvis'],
        dateCreated: 'Today',
        centroidDefuzzification: 'z* = 32.4',
        centroidScale: 'scale(0-100)',
      );

      widget.onTaskCreated?.call(newTask);
      if (mounted) {
        PopUpPemberitahuan.taskCreated(context, taskName: title);
        Navigator.of(context).pop(newTask);
      }
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.bgSecondary,
        body: DesktopPersonalTaskModal(
          task: widget.targetTask,
          userInitials: widget.userInitials,
          onTaskCreated: widget.onTaskCreated,
          onTaskUpdated: widget.onTaskUpdated,
          onClose: widget.onBack,
        ),
      );
    }

    final disableMotion = MediaQuery.disableAnimationsOf(context);

    return UnfocusOnTap(
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              context.rSpacing(20),
              context.rSpacing(12),
              context.rSpacing(20),
              context.rSpacing(32),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar: Back & User Initials Avatar
                  _buildTopBar(context),
                  SizedBox(height: context.rSpacing(18)),

                  // Section Title & Alert Bell Toggle Button (Direct page layout without card)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _isEditing ? 'Edit Task Details' : 'Task Details',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: context.rFont(18, min: 16, max: 22),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildAlertToggle(context),
                    ],
                  ),
                  SizedBox(height: context.rSpacing(16)),

                  // Field 0: Task Category Selector (Tugas Kuliah vs Non-Kuliah)
                  TaskCategorySelector(
                    isCollegeTask: _isCollegeTask,
                    onCategoryChanged: (isCollege) {
                      setState(() => _isCollegeTask = isCollege);
                    },
                  ),
                  SizedBox(height: context.rSpacing(14)),

                  // Field 1: Task Title
                  _buildFieldLabel(context, 'Task Title'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _titleController,
                    hintText: 'IMPAL Architecture Analysis',
                    maxLength: 80,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter task title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: context.rSpacing(14)),

                  // Field 2: Course (Only visible if Tugas Kuliah)
                  AnimatedCrossFade(
                    duration: disableMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    crossFadeState: _isCollegeTask
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFieldLabel(context, 'Course'),
                        const SizedBox(height: 6),
                        if (_rubricRepo.courses.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: _rubricRepo.courses.map((courseItem) {
                              final isSelected =
                                  _activeRubricCourse?.id == courseItem.id;
                              return InkWell(
                                key: ValueKey(
                                    'task_course_chip_${courseItem.id}'),
                                onTap: () {
                                  setState(() {
                                    _selectedCourseId = courseItem.id;
                                    _courseController.text =
                                        courseItem.displayLabel;
                                    _customWeightPercent = null;
                                    _selectedComponentId =
                                        courseItem.components.isNotEmpty
                                            ? courseItem.components.first.id
                                            : null;
                                  });
                                },
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                            .withValues(alpha: 0.2)
                                        : AppColors.bgCard,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.borderSubtle,
                                    ),
                                  ),
                                  child: Text(
                                    courseItem.courseCode.isNotEmpty
                                        ? '${courseItem.courseCode} • ${courseItem.courseName}'
                                        : courseItem.courseName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textMuted,
                                      fontSize: context.rFont(11,
                                          min: 10, max: 12.5),
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                        ],
                        _buildTextField(
                          controller: _courseController,
                          hintText:
                              'SSIF-04-REG • Software Testing & Implementa...',
                          maxLength: 80,
                        ),
                        SizedBox(height: context.rSpacing(14)),
                      ],
                    ),
                    secondChild: const SizedBox(
                      width: double.infinity,
                      height: 0,
                    ),
                  ),

                  // Field 3: Submission Deadline (Date & Time)
                  SubmissionDeadlinePicker(
                    selectedDate: _selectedDate,
                    selectedTime: _selectedTime,
                    onDateChanged: (d) =>
                        setState(() => _selectedDate = d),
                    onTimeChanged: (t) =>
                        setState(() => _selectedTime = t),
                  ),
                  SizedBox(height: context.rSpacing(14)),

                  // Field 4: Course Grade Weight Chips
                  CourseGradeWeightChips(
                    selectedPriority: _selectedPriority,
                    isAutomatic: _isAutomaticWeight,
                    isCollegeTask: _isCollegeTask,
                    rubricComponents: _activeRubricCourse?.components ?? const [],
                    selectedComponentId: _selectedComponentId,
                    customWeightPercent: _customWeightPercent,
                    onComponentSelected: (comp) => setState(() {
                      _selectedComponentId = comp?.id;
                    }),
                    onCustomWeightChanged: (w) => setState(() {
                      _customWeightPercent = w;
                    }),
                    onPriorityChanged: (p) =>
                        setState(() => _selectedPriority = p),
                    onAutomaticChanged: (a) =>
                        setState(() => _isAutomaticWeight = a),
                  ),
                  SizedBox(height: context.rSpacing(14)),

                  // Field 5: Notes & Instructions
                  _buildFieldLabel(context, 'Notes & Instructions'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _notesController,
                    hintText: 'Add assignment details or links here...',
                    maxLines: 4,
                    maxLength: 500,
                  ),
                  SizedBox(height: context.rSpacing(24)),

                  // Submit Button with Loading State
                  _buildSubmitButton(context),
                  if (_isEditing &&
                      widget.targetTask != null &&
                      !widget.targetTask!.isTeamTask) ...[
                    SizedBox(height: context.rSpacing(12)),
                    _buildDeleteButton(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertToggle(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _isAlertEnabled = !_isAlertEnabled);
          final categoryConfig =
              UserProfileRepository().profile.taskDeadlineAlerts;
          PopUpPemberitahuan.show(
            context,
            title: _isAlertEnabled ? 'Alert Active' : 'Alert Muted',
            message: _isAlertEnabled
                ? 'Task deadline alerts enabled (Following Profile: ${categoryConfig.summary}).'
                : 'Alerts muted for this task.',
            icon: _isAlertEnabled
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_outlined,
            iconBgColor: _isAlertEnabled
                ? PopUpPemberitahuan.positiveColor
                : PopUpPemberitahuan.neutralColor,
          );
        },
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _isAlertEnabled
                ? AppColors.primary
                : const Color(0xFF323846),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: _isAlertEnabled
                  ? AppColors.primary
                  : AppColors.borderSubtle,
              width: 1,
            ),
            boxShadow: _isAlertEnabled
                ? const [
                    BoxShadow(
                      color: Color(0x40FA6144),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isAlertEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_outlined,
                size: 15,
                color: _isAlertEnabled
                    ? Colors.white
                    : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                _isAlertEnabled ? 'Alert On' : 'Alert Off',
                style: TextStyle(
                  color: _isAlertEnabled
                      ? Colors.white
                      : AppColors.textMuted,
                  fontSize: context.rFont(12, min: 11, max: 13),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF323846),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFF3B4150), width: 1.0),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  _isEditing ? 'Edit Task' : 'Create Task',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: context.rFont(20, min: 18, max: 24),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: context.rIcon(42),
          height: context.rIcon(42),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.borderSubtle,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.userInitials,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(14, min: 12, max: 16),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textWhite,
        fontSize: context.rFont(13, min: 11, max: 15),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      buildCounter: maxLength != null
          ? (context, {required currentLength, required isFocused, required maxLength}) => null
          : null,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontFamily: 'Inter',
      ),
      enableInteractiveSelection: true, // Never block paste per AGENTS.md
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.bgCard,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
          fontFamily: 'Inter',
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final label = _isEditing ? 'Save Changes' : 'Create Task';

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        key: const ValueKey('submit_task_button'),
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label, // Retains original label per AGENTS.md rule
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(15, min: 13, max: 17),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(15, min: 13, max: 17),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await PopUpKonfirmasiDelete.show(
            context,
            title: 'Delete Personal Task?',
            message:
                'Are you sure you want to delete this personal task? This action cannot be undone.',
          );
          if (confirmed == true && context.mounted) {
            TaskRepository().deleteTask(widget.targetTask!.id);
            PopUpPemberitahuan.taskDeleted(
              context,
              taskName: widget.targetTask!.title,
            );
            Navigator.of(context).pop();
          }
        },
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFFF5E4D),
          size: 18,
        ),
        label: const Text(
          'Delete Task',
          style: TextStyle(
            color: Color(0xFFFF5E4D),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFF5E4D), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
