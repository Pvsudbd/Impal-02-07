import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../../core/widgets/unfocus_on_tap.dart';
import '../../../../common_widgets/impal_date_picker_dialog.dart';
import '../../../../common_widgets/impal_time_picker_dialog.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../../schedule/pop_up_konfirmasi_delete.dart';
import '../../models/team_task_model.dart';
import '../../models/team_task_repository.dart';

/// Centered Desktop Pop-Up Modal for Creating and Editing a Team Milestone.
///
/// Mirrors FigCraft `Modal - Create Milestone (Pop-Up)` (node `7238`) with
/// mobile [PopUpCreateMilestone] wording, tabular figures, quick top-right `[✕]`
/// dismissal (without redundant bottom-left Cancel button), and Edit/Delete flow.
class DesktopMilestoneModal extends StatefulWidget {
  final String teamCode;
  final TeamMilestoneModel? existingMilestone;
  final VoidCallback? onMilestoneDeleted;

  const DesktopMilestoneModal({
    super.key,
    required this.teamCode,
    this.existingMilestone,
    this.onMilestoneDeleted,
  });

  static Future<TeamMilestoneModel?> show(
    BuildContext context, {
    required String teamCode,
    TeamMilestoneModel? existingMilestone,
    VoidCallback? onMilestoneDeleted,
  }) {
    return showDialog<TeamMilestoneModel>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => DesktopMilestoneModal(
        teamCode: teamCode,
        existingMilestone: existingMilestone,
        onMilestoneDeleted: onMilestoneDeleted,
      ),
    );
  }

  @override
  State<DesktopMilestoneModal> createState() => _DesktopMilestoneModalState();
}

class _DesktopMilestoneModalState extends State<DesktopMilestoneModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late final Set<String> _selectedTaskIds;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingMilestone != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingMilestone;
    if (existing != null) {
      _titleController = TextEditingController(text: existing.title);
      _descController = TextEditingController(text: existing.description ?? '');
      _selectedDate = existing.deadline;
      _selectedTime = TimeOfDay(
        hour: existing.deadline.hour,
        minute: existing.deadline.minute,
      );
      _selectedTaskIds = Set<String>.from(existing.taskIds);
    } else {
      _titleController = TextEditingController();
      _descController = TextEditingController();
      _selectedDate = DateTime.now().add(const Duration(days: 7));
      _selectedTime = const TimeOfDay(hour: 23, minute: 59);
      _selectedTaskIds = <String>{};
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _close([TeamMilestoneModel? result]) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(result);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showImpalDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      title: 'Select Milestone Deadline',
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showImpalTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _submit() {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final deadline = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final milestone = TeamMilestoneModel(
      id: widget.existingMilestone?.id ??
          'milestone_${DateTime.now().millisecondsSinceEpoch}',
      teamCode: widget.teamCode,
      title: title,
      description: desc.isNotEmpty ? desc : null,
      deadline: deadline,
      taskIds: _selectedTaskIds.toList(),
      dateCreated: widget.existingMilestone?.dateCreated ?? DateTime.now(),
    );

    if (_isEditing) {
      TeamTaskRepository().updateMilestone(widget.teamCode, milestone);
      PopUpPemberitahuan.milestoneUpdated(context, title: title);
    } else {
      TeamTaskRepository().addMilestone(widget.teamCode, milestone);
      PopUpPemberitahuan.milestoneCreated(
        context,
        title: title,
        taskCount: _selectedTaskIds.length,
      );
    }

    _close(milestone);
  }

  Future<void> _handleDelete() async {
    final existing = widget.existingMilestone;
    if (existing == null || _isSubmitting) return;

    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: 'Delete Milestone?',
      message:
          'Are you sure you want to delete "${existing.title}"? Member tasks will remain in the dashboard.',
    );
    if (confirmed == true && mounted) {
      TeamTaskRepository().deleteMilestone(widget.teamCode, existing.id);
      PopUpPemberitahuan.milestoneDeleted(context, title: existing.title);
      widget.onMilestoneDeleted?.call();
      _close();
    }
  }

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  String _formatTime(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = TeamTaskRepository().getTasks(widget.teamCode);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final animDuration =
        disableAnimations ? Duration.zero : const Duration(milliseconds: 180);
    final screenSize = MediaQuery.sizeOf(context);
    final modalWidth = (screenSize.width - 48).clamp(320.0, 480.0);
    final maxModalHeight = (screenSize.height * 0.88).clamp(440.0, 680.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(24),
        vertical: context.rSpacing(24),
      ),
      child: UnfocusOnTap(
        child: TweenAnimationBuilder<double>(
          duration: animDuration,
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.96, end: 1.0),
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: ((scale - 0.96) / 0.04).clamp(0.0, 1.0),
              child: child,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: modalWidth,
              maxHeight: maxModalHeight,
            ),
            child: Container(
              width: modalWidth,
              decoration: BoxDecoration(
                color: AppColors.bgDialog,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x8A000000),
                    blurRadius: 30,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderSubtle,
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(context.rSpacing(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel(context, 'Milestone Title *'),
                            SizedBox(height: context.rSpacing(6)),
                            TextFormField(
                              key: const ValueKey(
                                'desktop_milestone_title_input',
                              ),
                              controller: _titleController,
                              maxLength: 100,
                              buildCounter: (_,
                                      {required currentLength,
                                      required isFocused,
                                      required maxLength}) =>
                                  null,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.rFont(13.5, min: 12, max: 15),
                                fontFamily: 'Inter',
                              ),
                              decoration: _inputDecoration(
                                context,
                                'e.g. Responsi 1, Sprint 1, Tubes Tahap 1',
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter a milestone title';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: context.rSpacing(16)),
                            _buildFieldLabel(context, 'General Deadline *'),
                            SizedBox(height: context.rSpacing(6)),
                            _buildDeadlineRow(context),
                            SizedBox(height: context.rSpacing(16)),
                            _buildFieldLabel(
                              context,
                              'Objective / Notes (Optional)',
                            ),
                            SizedBox(height: context.rSpacing(6)),
                            TextFormField(
                              key: const ValueKey(
                                'desktop_milestone_notes_input',
                              ),
                              controller: _descController,
                              maxLines: 2,
                              maxLength: 500,
                              textAlignVertical: TextAlignVertical.top,
                              buildCounter: (_,
                                      {required currentLength,
                                      required isFocused,
                                      required maxLength}) =>
                                  null,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.rFont(13, min: 12, max: 14),
                                fontFamily: 'Inter',
                              ),
                              decoration: _inputDecoration(
                                context,
                                'Brief summary of requirements for this milestone...',
                              ),
                            ),
                            SizedBox(height: context.rSpacing(20)),
                            _buildTaskSelectionHeader(context),
                            SizedBox(height: context.rSpacing(8)),
                            _buildTaskList(context, allTasks),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderSubtle,
                    ),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.rSpacing(20),
        context.rSpacing(18),
        context.rSpacing(12),
        context.rSpacing(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.flag_rounded,
              color: AppColors.primary,
              size: context.rIcon(18),
            ),
          ),
          SizedBox(width: context.rSpacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Milestone' : 'Create Milestone',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(17, min: 15, max: 19),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Group team tasks under an overarching deadline',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: context.rFont(11.5, min: 10.5, max: 13),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('desktop_milestone_modal_close_btn'),
              onTap: () => _close(),
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.textBody,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Material(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              key: const ValueKey('desktop_milestone_date_btn'),
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: context.rIcon(16),
                      color: AppColors.primaryAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatDate(_selectedDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(12.5, min: 11.5, max: 14),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Material(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              key: const ValueKey('desktop_milestone_time_btn'),
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: context.rIcon(16),
                      color: AppColors.primaryAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatTime(_selectedTime),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(12.5, min: 11.5, max: 14),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskSelectionHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildFieldLabel(context, 'Select Tasks to Include')),
        Container(
          key: const ValueKey('desktop_milestone_selected_count'),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${_selectedTaskIds.length} Selected',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: context.rFont(10.5, min: 9.5, max: 12),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(BuildContext context, List<TeamTaskModel> allTasks) {
    if (allTasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: context.rSpacing(20),
          horizontal: context.rSpacing(16),
        ),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Text(
          'No team tasks found. Please create team tasks first.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: context.rFont(12, min: 11, max: 13),
            fontFamily: 'Inter',
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allTasks.length,
      itemBuilder: (context, index) {
        final task = allTasks[index];
        final isSelected = _selectedTaskIds.contains(task.id);
        final priorityColor = task.priority == TaskPriority.high
            ? AppColors.primary
            : task.priority == TaskPriority.medium
                ? const Color(0xFFFBBF24)
                : const Color(0xFF6EE7B7);

        return Container(
          margin: EdgeInsets.only(bottom: index < allTasks.length - 1 ? 8 : 0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF384050) : AppColors.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.borderSubtle,
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: InkWell(
            key: ValueKey('desktop_milestone_task_${task.id}'),
            borderRadius: BorderRadius.circular(10),
            onTap: () => _toggleTask(task.id, !isSelected),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isSelected,
                      activeColor: AppColors.primary,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(
                        color: AppColors.textSubtle,
                        width: 1.2,
                      ),
                      onChanged: (val) => _toggleTask(task.id, val ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(12.5, min: 11.5, max: 14),
                            fontFamily: 'Inter',
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: task.assigneeColor,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                task.assignedTo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize:
                                      context.rFont(10.5, min: 9.5, max: 12),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.bgDialog,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      task.priority.label,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: context.rFont(10, min: 9, max: 11),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleTask(String taskId, bool select) {
    setState(() {
      if (select) {
        _selectedTaskIds.add(taskId);
      } else {
        _selectedTaskIds.remove(taskId);
      }
    });
  }

  Widget _buildFooter(BuildContext context) {
    final submitLabel = _isEditing ? 'Save Changes' : 'Save Milestone';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(20),
        vertical: context.rSpacing(14),
      ),
      child: Row(
        children: [
          if (_isEditing) ...[
            SizedBox(
              height: 44,
              child: OutlinedButton(
                key: const ValueKey('desktop_milestone_delete_btn'),
                onPressed: _isSubmitting ? null : _handleDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  'Delete Milestone',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                key: const ValueKey('desktop_milestone_submit_btn'),
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSubmitting) ...[
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        submitLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(13.5, min: 12.5, max: 15),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white,
        fontSize: context.rFont(12.5, min: 11.5, max: 14),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textSubtle,
        fontSize: context.rFont(12.5, min: 11.5, max: 14),
        fontFamily: 'Inter',
      ),
      filled: true,
      fillColor: AppColors.bgCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
