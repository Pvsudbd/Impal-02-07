import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../../core/widgets/unfocus_on_tap.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../team/widgets/submission_deadline_picker.dart';
import 'edit_task.dart';
import 'models/task_item_model.dart';
import 'widgets/course_grade_weight_chips.dart';
import 'widgets/task_category_selector.dart';

// Backward compatibility aliases matching Figma exports
export 'edit_task.dart';
export 'models/task_item_model.dart';

typedef AddNewTask = CreateTaskPage;
typedef TaskFormPage = CreateTaskPage;

/// Unified dual-mode Form for Creating and Editing Tasks.
///
/// Complies strictly with AGENTS.md, ResponsiveContext, UnfocusOnTap,
/// loading button label retention, and PopUpPemberitahuan standards.
class CreateTaskPage extends StatefulWidget {
  final TaskItemModel? existingTask;
  final void Function(TaskItemModel task)? onTaskCreated;
  final void Function(TaskItemModel updatedTask)? onTaskUpdated;
  final VoidCallback? onBack;
  final String userInitials;

  const CreateTaskPage({
    super.key,
    this.existingTask,
    this.onTaskCreated,
    this.onTaskUpdated,
    this.onBack,
    this.userInitials = 'JS',
  });

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
  bool _isSubmitting = false;
  final int _currentTab = 1; // Task Tab

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    if (task != null) {
      _isCollegeTask = task.isCollegeTask;
      _titleController = TextEditingController(text: task.title);
      _courseController = TextEditingController(text: task.course);
      _notesController = TextEditingController(text: task.notes);
      _selectedDate = task.deadlineDate;
      _selectedTime = _parseTimeOfDay(task.formattedDeadline);
      _selectedPriority = task.priority;
      _isAutomaticWeight = task.isAutomaticWeight;
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
    }
  }

  @override
  void dispose() {
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

    if (_isEditing) {
      final updated = widget.existingTask!.copyWith(
        title: title,
        course: course.isNotEmpty
            ? course
            : (_isCollegeTask ? widget.existingTask!.course : ''),
        notes: notes,
        deadlineDate: _selectedDate,
        formattedDeadline: formattedDeadline,
        priority: _selectedPriority,
        isAutomaticWeight: _isAutomaticWeight,
        isCollegeTask: _isCollegeTask,
      );

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

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.disableAnimationsOf(context);

    return UnfocusOnTap(
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(20),
                    vertical: context.rSpacing(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar: Back & User Initials Avatar
                      _buildTopBar(context),
                      SizedBox(height: context.rSpacing(18)),

                      // Main Form Card Container
                      Container(
                        padding: EdgeInsets.all(context.rSpacing(20)),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.borderSubtle,
                            width: 0.6,
                          ),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Card Title
                              Text(
                                _isEditing ? 'Edit Task' : 'Add New Task',
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: context.rFont(18, min: 16, max: 22),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
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
                                    _buildTextField(
                                      controller: _courseController,
                                      hintText:
                                          'SSIF-04-REG • Software Testing & Implementa...',
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
                              ),
                              SizedBox(height: context.rSpacing(20)),

                              // Submit Button with Loading State
                              _buildSubmitButton(context),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: context.rSpacing(24)),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation Bar
              ImpalBottomNavBar(
                currentTab: _currentTab,
                onTabSelected: (index) {
                  if (index != _currentTab) {
                    Navigator.of(context).pop();
                  }
                },
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
        InkWell(
          onTap: widget.onBack ?? () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 6),
                Text(
                  'Back',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: context.rFont(20, min: 18, max: 24),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontFamily: 'Inter',
      ),
      enableInteractiveSelection: true, // Never block paste per AGENTS.md
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1E232D),
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
          fontFamily: 'Inter',
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
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
}
