import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../../core/widgets/unfocus_on_tap.dart';
import '../../../../common_widgets/impal_date_picker_dialog.dart';
import '../../../../common_widgets/impal_time_picker_dialog.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../../profile/models/user_profile_model.dart';
import '../../../schedule/pop_up_konfirmasi_delete.dart';
import '../../models/task_item_model.dart';
import '../../models/task_repository.dart';

/// Centered Desktop Pop-Up Modal for Creating and Editing Personal / College Tasks.
///
/// Mirrors FigCraft `Modal - Create Task Personal (Pop-Up)` (node `6810`) &
/// `Modal - Edit Task Personal (Pop-Up)` (node `7377`) with mobile wording,
/// Title Case field labels (no ALL-CAPS), top bell Alert toggle, and collapsible
/// manual priority pills when `Automatic` is enabled.
class DesktopPersonalTaskModal extends StatefulWidget {
  final TaskItemModel? task;
  final String userInitials;
  final void Function(TaskItemModel task)? onTaskCreated;
  final void Function(TaskItemModel updatedTask)? onTaskUpdated;
  final VoidCallback? onTaskDeleted;
  final VoidCallback? onClose;

  const DesktopPersonalTaskModal({
    super.key,
    this.task,
    this.userInitials = 'JS',
    this.onTaskCreated,
    this.onTaskUpdated,
    this.onTaskDeleted,
    this.onClose,
  });

  static Future<TaskItemModel?> show(
    BuildContext context, {
    TaskItemModel? task,
    String userInitials = 'JS',
    void Function(TaskItemModel task)? onTaskCreated,
    void Function(TaskItemModel updatedTask)? onTaskUpdated,
    VoidCallback? onTaskDeleted,
  }) {
    return showDialog<TaskItemModel>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => DesktopPersonalTaskModal(
        task: task,
        userInitials: userInitials,
        onTaskCreated: onTaskCreated,
        onTaskUpdated: onTaskUpdated,
        onTaskDeleted: onTaskDeleted,
      ),
    );
  }

  @override
  State<DesktopPersonalTaskModal> createState() =>
      _DesktopPersonalTaskModalState();
}

class _DesktopPersonalTaskModalState extends State<DesktopPersonalTaskModal> {
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
  bool _isSubmitting = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.task;
    if (existing != null) {
      _isCollegeTask = existing.isCollegeTask;
      _titleController = TextEditingController(text: existing.title);
      _courseController = TextEditingController(text: existing.course);
      _notesController = TextEditingController(text: existing.notes);
      _selectedDate = existing.deadlineDate;
      _selectedTime = _parseTimeOfDay(existing.formattedDeadline);
      _selectedPriority = existing.priority;
      _isAutomaticWeight = existing.isAutomaticWeight;
      _isAlertEnabled = existing.isAlertEnabled;
    } else {
      _isCollegeTask = true;
      _titleController = TextEditingController();
      _courseController = TextEditingController(
        text: 'SSIF-04-REG • Software Testing & Implementation',
      );
      _notesController = TextEditingController();
      _selectedDate = DateTime(2026, 10, 18);
      _selectedTime = const TimeOfDay(hour: 23, minute: 59);
      _selectedPriority = TaskPriorityLevel.high;
      _isAutomaticWeight = true;
      _isAlertEnabled = true;
    }
    _titleController.addListener(_onTitleChanged);
  }

  void _onTitleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$dayName ${date.day} $monthName ${date.year}, $h: $m WIB';
  }

  void _close([TaskItemModel? result]) {
    if (widget.onClose != null && result == null) {
      widget.onClose!();
    } else {
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showImpalDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      title: 'Select Submission Date',
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showImpalTimePicker(
      context: context,
      initialTime: _selectedTime,
      title: 'Select Submission Time',
    );
    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  void _toggleAlert() {
    setState(() => _isAlertEnabled = !_isAlertEnabled);
    final categoryConfig = UserProfileRepository().profile.taskDeadlineAlerts;
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
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final title = _titleController.text.trim();
    final course = _isCollegeTask ? _courseController.text.trim() : '';
    final notes = _notesController.text.trim();
    final formattedDeadline = _formatDeadline(_selectedDate, _selectedTime);

    if (_isEditing) {
      final updated = widget.task!.copyWith(
        title: title,
        course: course.isNotEmpty
            ? course
            : (_isCollegeTask ? widget.task!.course : ''),
        notes: notes,
        deadlineDate: _selectedDate,
        formattedDeadline: formattedDeadline,
        priority: _selectedPriority,
        isAutomaticWeight: _isAutomaticWeight,
        isCollegeTask: _isCollegeTask,
        isAlertEnabled: _isAlertEnabled,
      );

      TaskRepository().updateTask(updated);
      widget.onTaskUpdated?.call(updated);
      PopUpPemberitahuan.taskUpdated(context, taskName: title);
      Navigator.of(context).pop(updated);
      return;
    }

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
      subtitle: 'Personal & Team task',
      tags: [
        TaskTagModel(
          label: 'Task',
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

  Future<void> _handleDelete() async {
    final target = widget.task;
    if (target == null) return;
    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: 'Delete Personal Task?',
      message:
          'Are you sure you want to delete this personal task? This action cannot be undone.',
    );
    if (confirmed == true && mounted) {
      TaskRepository().deleteTask(target.id);
      widget.onTaskDeleted?.call();
      PopUpPemberitahuan.taskDeleted(context, taskName: target.title);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.disableAnimationsOf(context);
    final duration = disableMotion
        ? Duration.zero
        : const Duration(milliseconds: 220);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: UnfocusOnTap(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeaderRow(context),
                    SizedBox(height: context.rSpacing(16)),
                    _buildCategorySelector(context, duration),
                    SizedBox(height: context.rSpacing(14)),
                    _buildTaskTitleField(context),
                    SizedBox(height: context.rSpacing(14)),
                    _buildCourseSection(context, duration),
                    _buildDeadlineSection(context),
                    SizedBox(height: context.rSpacing(14)),
                    _buildTaskGradeWeightSection(context, duration),
                    SizedBox(height: context.rSpacing(14)),
                    _buildNotesField(context),
                    SizedBox(height: context.rSpacing(18)),
                    _buildFooterActions(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            _isEditing ? 'Edit Task' : 'Create Task',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(20, min: 18, max: 22),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _buildTopBellAlertToggle(context),
        const SizedBox(width: 10),
        Material(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            key: const ValueKey('desktop_task_modal_close_btn'),
            onTap: () => _close(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBellAlertToggle(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('desktop_task_modal_alert_toggle'),
        onTap: _toggleAlert,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isAlertEnabled ? AppColors.primary : AppColors.bgPrimary,
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
                color: _isAlertEnabled ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                _isAlertEnabled ? 'Alert On' : 'Alert Off',
                style: TextStyle(
                  color: _isAlertEnabled ? Colors.white : AppColors.textMuted,
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

  Widget _buildCategorySelector(BuildContext context, Duration duration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(context, 'Task Category'),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildCategoryTab(
                  context,
                  tabKey: const ValueKey('desktop_task_category_college'),
                  label: 'College Task',
                  icon: Icons.school_rounded,
                  isSelected: _isCollegeTask,
                  duration: duration,
                  onTap: () => setState(() => _isCollegeTask = true),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildCategoryTab(
                  context,
                  tabKey: const ValueKey('desktop_task_category_personal'),
                  label: 'Personal',
                  icon: Icons.person_rounded,
                  isSelected: !_isCollegeTask,
                  duration: duration,
                  onTap: () => setState(() => _isCollegeTask = false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTab(
    BuildContext context, {
    required Key tabKey,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Duration duration,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: tabKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeInOut,
          height: 34,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMuted,
                    fontSize: context.rFont(12, min: 11, max: 13),
                    fontFamily: 'Inter',
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTitleField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel(context, 'Task Title'),
            Text(
              '${_titleController.text.length}/80',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildTextField(
          fieldKey: const ValueKey('desktop_task_title_input'),
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
      ],
    );
  }

  Widget _buildCourseSection(BuildContext context, Duration duration) {
    return AnimatedCrossFade(
      duration: duration,
      crossFadeState: _isCollegeTask
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLabel(context, 'Course'),
          const SizedBox(height: 6),
          _buildTextField(
            fieldKey: const ValueKey('desktop_task_course_input'),
            controller: _courseController,
            hintText: 'SSIF-04-REG • Software Testing & Implementation',
            maxLength: 80,
          ),
          SizedBox(height: context.rSpacing(14)),
        ],
      ),
      secondChild: const SizedBox(width: double.infinity, height: 0),
    );
  }

  Widget _buildDeadlineSection(BuildContext context) {
    final dateText = DateFormat('EEE dd MMM yyyy').format(_selectedDate);
    final h = _selectedTime.hour.toString().padLeft(2, '0');
    final m = _selectedTime.minute.toString().padLeft(2, '0');
    final timeText = '$h:$m WIB';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(context, 'Submission Deadline'),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildPickerTile(
                context,
                tileKey: const ValueKey('desktop_task_date_picker'),
                icon: Icons.calendar_today_outlined,
                label: dateText,
                onTap: _pickDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPickerTile(
                context,
                tileKey: const ValueKey('desktop_task_time_picker'),
                icon: Icons.access_time_rounded,
                label: timeText,
                onTap: _pickTime,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPickerTile(
    BuildContext context, {
    required Key tileKey,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.bgPrimary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        key: tileKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(12, min: 11, max: 13),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const Text(
                '▾',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskGradeWeightSection(BuildContext context, Duration duration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLabel(context, 'Task Grade Weight'),
            InkWell(
              key: const ValueKey('desktop_task_automatic_toggle'),
              onTap: () =>
                  setState(() => _isAutomaticWeight = !_isAutomaticWeight),
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Automatic',
                      style: TextStyle(
                        color: _isAutomaticWeight
                            ? Colors.white
                            : AppColors.textMuted,
                        fontSize: context.rFont(12, min: 11, max: 13),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeInOut,
                      width: 40,
                      height: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: _isAutomaticWeight
                            ? AppColors.primary
                            : AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(999),
                        border: _isAutomaticWeight
                            ? null
                            : Border.all(
                                color: AppColors.borderSubtle,
                                width: 1,
                              ),
                      ),
                      child: AnimatedAlign(
                        duration: duration,
                        curve: Curves.easeInOut,
                        alignment: _isAutomaticWeight
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        AnimatedCrossFade(
          duration: duration,
          crossFadeState: _isAutomaticWeight
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                  child: _buildPriorityPill(
                    context,
                    pillKey: const ValueKey('desktop_task_priority_high'),
                    level: TaskPriorityLevel.high,
                    label: 'High',
                    duration: duration,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPriorityPill(
                    context,
                    pillKey: const ValueKey('desktop_task_priority_medium'),
                    level: TaskPriorityLevel.medium,
                    label: 'Medium',
                    duration: duration,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPriorityPill(
                    context,
                    pillKey: const ValueKey('desktop_task_priority_low'),
                    level: TaskPriorityLevel.low,
                    label: 'Low',
                    duration: duration,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityPill(
    BuildContext context, {
    required Key pillKey,
    required TaskPriorityLevel level,
    required String label,
    required Duration duration,
  }) {
    final isSelected = _selectedPriority == level;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: pillKey,
        onTap: () => setState(() => _selectedPriority = level),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeInOut,
          height: 38,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? null
                : Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textMuted,
              fontSize: context.rFont(12, min: 11, max: 13),
              fontFamily: 'Inter',
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(context, 'Notes & Instructions'),
        const SizedBox(height: 6),
        _buildTextField(
          fieldKey: const ValueKey('desktop_task_notes_input'),
          controller: _notesController,
          hintText: 'Add assignment details or links here...',
          maxLines: 3,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildFooterActions(BuildContext context) {
    final submitLabel = _isEditing ? 'Save Changes' : 'Create Task';
    final showDelete =
        _isEditing && widget.task != null && !widget.task!.isTeamTask;

    return Row(
      children: [
        if (showDelete) ...[
          SizedBox(
            height: 42,
            child: OutlinedButton(
              key: const ValueKey('desktop_task_delete_btn'),
              onPressed: _isSubmitting ? null : _handleDelete,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Delete Task',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12.5,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: SizedBox(
            height: 42,
            child: ElevatedButton(
              key: const ValueKey('submit_task_button'),
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.6,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            submitLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      submitLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: context.rFont(13, min: 12, max: 14),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required Key fieldKey,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      buildCounter: maxLength != null
          ? (
              context, {
              required currentLength,
              required isFocused,
              required maxLength,
            }) =>
                null
          : null,
      style: TextStyle(
        color: Colors.white,
        fontSize: context.rFont(13, min: 12, max: 14),
        fontFamily: 'Inter',
      ),
      enableInteractiveSelection: true,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.bgPrimary,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12.5,
          fontFamily: 'Inter',
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        ),
      ),
    );
  }
}
