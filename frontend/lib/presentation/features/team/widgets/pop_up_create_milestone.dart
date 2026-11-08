import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../../core/widgets/unfocus_on_tap.dart';
import '../../../common_widgets/impal_date_picker_dialog.dart';
import '../../../common_widgets/impal_time_picker_dialog.dart';
import '../../../common_widgets/pop_up_pemberitahuan.dart';
import '../models/team_task_model.dart';
import '../models/team_task_repository.dart';

/// Modal dialog for creating and editing a team task Milestone with a General Deadline.
///
/// Complies with 100% English UI Mandate, ResponsiveContext, and AGENTS.md standards.
class PopUpCreateMilestone extends StatefulWidget {
  final String teamCode;
  final TeamMilestoneModel? existingMilestone;

  const PopUpCreateMilestone({
    super.key,
    required this.teamCode,
    this.existingMilestone,
  });

  /// Convenient helper to open the milestone creation/edit modal.
  static Future<TeamMilestoneModel?> show(
    BuildContext context, {
    required String teamCode,
    TeamMilestoneModel? existingMilestone,
  }) {
    return showDialog<TeamMilestoneModel>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      builder: (_) => PopUpCreateMilestone(
        teamCode: teamCode,
        existingMilestone: existingMilestone,
      ),
    );
  }

  @override
  State<PopUpCreateMilestone> createState() => _PopUpCreateMilestoneState();
}

class _PopUpCreateMilestoneState extends State<PopUpCreateMilestone> {
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
    final m = widget.existingMilestone;
    if (m != null) {
      _titleController = TextEditingController(text: m.title);
      _descController = TextEditingController(text: m.description ?? '');
      _selectedDate = m.deadline;
      _selectedTime = TimeOfDay(hour: m.deadline.hour, minute: m.deadline.minute);
      _selectedTaskIds = Set<String>.from(m.taskIds);
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showImpalDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      title: 'Select Milestone Deadline',
    );
    if (picked != null) {
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
    if (picked != null) {
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
      id: widget.existingMilestone?.id ?? 'milestone_${DateTime.now().millisecondsSinceEpoch}',
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

    Navigator.of(context).pop(milestone);
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = TeamTaskRepository().getTasks(widget.teamCode);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(16),
        vertical: context.rSpacing(24),
      ),
      child: UnfocusOnTap(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
          decoration: BoxDecoration(
            color: const Color(0xFF282D37),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF3B4150), width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
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
                // 1. Dialog Header
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.rSpacing(20),
                    context.rSpacing(18),
                    context.rSpacing(16),
                    context.rSpacing(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.flag_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: context.rSpacing(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEditing ? 'Edit Milestone' : 'Create Milestone',
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
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: context.rFont(11.5, min: 10, max: 13),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFF3B4150)),

                // 2. Scrollable Form Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(context.rSpacing(20)),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Milestone Title
                        _buildFieldLabel('Milestone Title *'),
                        SizedBox(height: context.rSpacing(6)),
                        TextFormField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white, fontSize: 13.5, fontFamily: 'Inter'),
                          decoration: _inputDecoration('e.g. Responsi 1, Sprint 1, Tubes Tahap 1'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter a milestone title';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: context.rSpacing(16)),

                        // General Deadline Picker
                        _buildFieldLabel('General Deadline *'),
                        SizedBox(height: context.rSpacing(6)),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF323846),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF3B4150), width: 0.8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFFFF7D65)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.5,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: _pickTime,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF323846),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF3B4150), width: 0.8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFFFF7D65)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.5,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
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
                        SizedBox(height: context.rSpacing(16)),

                        // Description (Optional)
                        _buildFieldLabel('Objective / Notes (Optional)'),
                        SizedBox(height: context.rSpacing(6)),
                        TextFormField(
                          controller: _descController,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Inter'),
                          decoration: _inputDecoration('Brief summary of requirements for this milestone...'),
                        ),
                        SizedBox(height: context.rSpacing(20)),

                        // Tasks Selection Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFieldLabel('Select Tasks to Include'),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${_selectedTaskIds.length} Selected',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10.5,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.rSpacing(8)),

                        if (allTasks.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF323846),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'No team tasks found. Please create team tasks first.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF8E95A5),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: allTasks.length,
                            itemBuilder: (context, index) {
                              final task = allTasks[index];
                              final isSelected = _selectedTaskIds.contains(task.id);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF384050) : const Color(0xFF323846),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary.withValues(alpha: 0.6) : const Color(0xFF3B4150),
                                    width: isSelected ? 1.2 : 0.6,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedTaskIds.remove(task.id);
                                      } else {
                                        _selectedTaskIds.add(task.id);
                                      }
                                    });
                                  },
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
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            side: const BorderSide(color: Color(0xFF6B7280), width: 1.2),
                                            onChanged: (val) {
                                              setState(() {
                                                if (val == true) {
                                                  _selectedTaskIds.add(task.id);
                                                } else {
                                                  _selectedTaskIds.remove(task.id);
                                                }
                                              });
                                            },
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
                                                  fontSize: 12.5,
                                                  fontFamily: 'Inter',
                                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 5,
                                                    backgroundColor: task.assigneeColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      task.assignedTo,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Color(0xFF8E95A5),
                                                        fontSize: 10.5,
                                                        fontFamily: 'Inter',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF282D37),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            task.priority.label,
                                            style: TextStyle(
                                              color: task.priority == TaskPriority.high
                                                  ? AppColors.primary
                                                  : task.priority == TaskPriority.medium
                                                      ? const Color(0xFFFBBF24)
                                                      : const Color(0xFF6EE7B7),
                                              fontSize: 9.5,
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
                          ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1, color: Color(0xFF3B4150)),

                // 3. Action Buttons Footer
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(20),
                    vertical: context.rSpacing(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF8E95A5),
                            side: const BorderSide(color: Color(0xFF3B4150)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isSubmitting) ...[
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                _isEditing ? 'Save Changes' : 'Save Milestone',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12.5,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12.5),
      filled: true,
      fillColor: const Color(0xFF323846),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3B4150), width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3B4150), width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
    );
  }
}
