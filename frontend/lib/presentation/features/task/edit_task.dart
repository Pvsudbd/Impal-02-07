import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../../core/widgets/unfocus_on_tap.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../team/widgets/submission_deadline_picker.dart';
import 'models/task_item_model.dart';
import 'widgets/course_grade_weight_chips.dart';
import 'widgets/task_category_selector.dart';

// Backward compatibility aliases
export 'models/task_item_model.dart';

typedef EditTask = EditTaskPage;

/// Dedicated Edit Task Page with dynamic Course visibility and Task Grade Weight toggle.
///
/// Features:
/// - Category Selector: "Tugas Kuliah" vs "Non-Kuliah / Personal"
///   - If "Tugas Kuliah": Course field is visible
///   - If "Non-Kuliah": Course field is hidden ("hilang")
/// - Task Grade Weight with Automatic toggle:
///   - When "Automatic" is active, High/Medium/Low menu is hidden ("menghilang")
///   - When "Automatic" is unchecked, High/Medium/Low selector is revealed
/// - Standard PopUpPemberitahuan notification on save
/// - Retains button label with loading indicator (anti-layout shift)
class EditTaskPage extends StatefulWidget {
  final TaskItemModel? task;
  final TaskItemModel? existingTask;
  final void Function(TaskItemModel updatedTask)? onTaskUpdated;
  final VoidCallback? onBack;
  final String userInitials;

  const EditTaskPage({
    super.key,
    this.task,
    this.existingTask,
    this.onTaskUpdated,
    this.onBack,
    this.userInitials = 'JS',
  }) : assert(task != null || existingTask != null, 'Either task or existingTask must be provided');

  TaskItemModel get targetTask => task ?? existingTask!;

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
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
  final int _currentTab = 1;

  @override
  void initState() {
    super.initState();
    final task = widget.targetTask;
    _isCollegeTask = task.isCollegeTask;
    _titleController = TextEditingController(text: task.title);
    _courseController = TextEditingController(text: task.course);
    _notesController = TextEditingController(text: task.notes);
    _selectedDate = task.deadlineDate;
    _selectedTime = _parseTimeOfDay(task.formattedDeadline);
    _selectedPriority = task.priority;
    _isAutomaticWeight = task.isAutomaticWeight;
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

  Future<void> _handleSave() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 300));

    final title = _titleController.text.trim();
    final course = _isCollegeTask ? _courseController.text.trim() : '';
    final notes = _notesController.text.trim();
    final formattedDeadline = _formatDeadline(_selectedDate, _selectedTime);

    final updated = widget.targetTask.copyWith(
      title: title,
      course: course.isNotEmpty ? course : (_isCollegeTask ? widget.targetTask.course : ''),
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
                                'Edit Task',
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: context.rFont(18, min: 16, max: 22),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: context.rSpacing(16)),

                              // Field 1: Task Category Selector (Tugas Kuliah vs Non-Kuliah)
                              TaskCategorySelector(
                                isCollegeTask: _isCollegeTask,
                                onCategoryChanged: (isCollege) {
                                  setState(() => _isCollegeTask = isCollege);
                                },
                              ),
                              SizedBox(height: context.rSpacing(14)),

                              // Field 2: Task Title
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

                              // Field 3: Course (Only visible if Tugas Kuliah)
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

                              // Field 4: Submission Deadline (Date & Time)
                              SubmissionDeadlinePicker(
                                selectedDate: _selectedDate,
                                selectedTime: _selectedTime,
                                onDateChanged: (d) =>
                                    setState(() => _selectedDate = d),
                                onTimeChanged: (t) =>
                                    setState(() => _selectedTime = t),
                              ),
                              SizedBox(height: context.rSpacing(14)),

                              // Field 5: Task Grade Weight with Automatic Toggle
                              CourseGradeWeightChips(
                                selectedPriority: _selectedPriority,
                                isAutomatic: _isAutomaticWeight,
                                onPriorityChanged: (p) =>
                                    setState(() => _selectedPriority = p),
                                onAutomaticChanged: (a) =>
                                    setState(() => _isAutomaticWeight = a),
                              ),
                              SizedBox(height: context.rSpacing(14)),

                              // Field 6: Notes & Instructions
                              _buildFieldLabel(context, 'Notes & Instructions'),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _notesController,
                                hintText:
                                    'Add assignment details or links here...',
                                maxLines: 4,
                              ),
                              SizedBox(height: context.rSpacing(20)),

                              // Submit Button with Loading State
                              _buildSaveButton(context),
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
      enableInteractiveSelection: true,
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

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        key: const ValueKey('save_task_changes_button'),
        onPressed: _isSubmitting ? null : _handleSave,
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
                    'Save Changes',
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
                'Save Changes',
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
