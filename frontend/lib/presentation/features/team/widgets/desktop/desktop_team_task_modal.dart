import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../../core/widgets/unfocus_on_tap.dart';
import '../../../../common_widgets/impal_date_picker_dialog.dart';
import '../../../../common_widgets/impal_time_picker_dialog.dart';
import '../../../profile/models/user_profile_model.dart';
import '../../../schedule/pop_up_konfirmasi_delete.dart';
import '../../models/team_member_model.dart';
import '../../models/team_task_model.dart';
import '../../models/team_task_repository.dart';
import '../../pop_up_pemberitahuan_team.dart';

/// Centered Desktop Pop-Up Modal for Creating and Editing Team Tasks.
///
/// Mirrors FigCraft `Modal - Create Team Task (Pop-Up)` (node `6211`) &
/// `Modal - Edit Team Task (Pop-Up)` (node `7527`) with mobile
/// `CreateTaskTeamPage` wording, Title Case field labels, top Alert Bell
/// toggle pill, multi-member checklist, optional milestone selector, and
/// top-right `[✕]` dismissal without Course Grade Weight or bottom-left Cancel.
class DesktopTeamTaskModal extends StatefulWidget {
  final TeamTaskModel? existingTask;
  final String teamCode;
  final void Function(TeamTaskModel task)? onTaskCreated;
  final void Function(TeamTaskModel updatedTask)? onTaskUpdated;
  final VoidCallback? onTaskDeleted;

  const DesktopTeamTaskModal({
    super.key,
    this.existingTask,
    this.teamCode = '7X29',
    this.onTaskCreated,
    this.onTaskUpdated,
    this.onTaskDeleted,
  });

  static Future<TeamTaskModel?> show(
    BuildContext context, {
    TeamTaskModel? existingTask,
    String teamCode = '7X29',
    void Function(TeamTaskModel task)? onTaskCreated,
    void Function(TeamTaskModel updatedTask)? onTaskUpdated,
    VoidCallback? onTaskDeleted,
  }) {
    return showDialog<TeamTaskModel>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => DesktopTeamTaskModal(
        existingTask: existingTask,
        teamCode: teamCode,
        onTaskCreated: onTaskCreated,
        onTaskUpdated: onTaskUpdated,
        onTaskDeleted: onTaskDeleted,
      ),
    );
  }

  @override
  State<DesktopTeamTaskModal> createState() => _DesktopTeamTaskModalState();
}

class _DesktopTeamTaskModalState extends State<DesktopTeamTaskModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _taskNameController;
  late final TextEditingController _descriptionController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late List<TeamMemberModel> _selectedMembers;
  late bool _isAlertEnabled;
  String? _selectedMilestoneId;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingTask != null;

  static const Map<String, String> _memberRoles = {
    'member_1': 'Frontend Dev',
    'member_2': 'Backend Dev',
    'member_3': 'UI/UX Designer',
  };

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _isAlertEnabled = task?.isAlertEnabled ?? true;
    if (task != null) {
      _taskNameController = TextEditingController(text: task.title);
      _descriptionController =
          TextEditingController(text: task.description ?? '');
      _selectedDate = task.deadline ?? DateTime(2026, 10, 18);
      _selectedTime = _parseTimeOfDay(task.timeRange);
      _selectedMembers = _matchMembers(task.assignedTo);
      final existingMilestone =
          TeamTaskRepository().getMilestoneForTask(widget.teamCode, task.id);
      _selectedMilestoneId = existingMilestone?.id;
    } else {
      _taskNameController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = DateTime(2026, 10, 18);
      _selectedTime = const TimeOfDay(hour: 23, minute: 59);
      _selectedMembers = [TeamMemberModel.defaultMembers.first];
      _selectedMilestoneId = null;
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  static TimeOfDay _parseTimeOfDay(String timeRange) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeRange);
    if (match != null) {
      final h = int.tryParse(match.group(1)!) ?? 23;
      final m = int.tryParse(match.group(2)!) ?? 59;
      return TimeOfDay(hour: h, minute: m);
    }
    return const TimeOfDay(hour: 23, minute: 59);
  }

  static List<TeamMemberModel> _matchMembers(String assignedTo) {
    final names = assignedTo
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();

    final matched = <TeamMemberModel>[];
    for (final member in TeamMemberModel.defaultMembers) {
      if (names.contains(member.name.toLowerCase())) {
        matched.add(member);
      }
    }
    return matched.isNotEmpty ? matched : [TeamMemberModel.defaultMembers.first];
  }

  static String _initialsFor(String fullName) {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'TM';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  void _close([TeamTaskModel? result]) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(result);
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

  void _toggleMember(TeamMemberModel member) {
    setState(() {
      final exists = _selectedMembers.any((m) => m.id == member.id);
      if (exists) {
        _selectedMembers =
            _selectedMembers.where((m) => m.id != member.id).toList();
      } else {
        _selectedMembers = [..._selectedMembers, member];
      }
    });
  }

  Future<void> _handleSaveTask() async {
    if (_isSubmitting) return;
    final taskName = _taskNameController.text.trim();
    if (taskName.isEmpty) {
      PopUpPemberitahuanTeam.warning(
        context,
        title: 'Task Name Required',
        message: 'Please provide a name for this team task.',
      );
      return;
    }

    if (_selectedMembers.isEmpty) {
      PopUpPemberitahuanTeam.warning(
        context,
        title: 'Assignee Required',
        message: 'Please select at least one person to assign this task.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')} WIB';
    final assignedNames = _selectedMembers.map((m) => m.name).join(', ');
    final primaryAvatarColor = _selectedMembers.first.avatarColor;
    final assignedColors = _selectedMembers.map((m) => m.avatarColor).toList();
    final daysDiff = _selectedDate.difference(DateTime.now()).inDays;
    final dueBadgeStr = daysDiff > 0 ? '${daysDiff}d' : '12h';

    if (_isEditing) {
      final updatedTask = widget.existingTask!.copyWith(
        title: taskName,
        assignedTo: assignedNames,
        assigneeColor: primaryAvatarColor,
        assigneeColors: assignedColors,
        timeRange: timeStr,
        description: _descriptionController.text.trim(),
        deadline: _selectedDate,
        dueBadge: dueBadgeStr,
        isAlertEnabled: _isAlertEnabled,
      );

      TeamTaskRepository().setTaskMilestone(
        teamCode: widget.teamCode,
        taskId: updatedTask.id,
        milestoneId: _selectedMilestoneId,
      );

      widget.onTaskUpdated?.call(updatedTask);
      if (mounted) {
        PopUpPemberitahuanTeam.taskUpdated(context, taskName: taskName);
        _close(updatedTask);
      }
    } else {
      final newTaskId = 'task_${DateTime.now().millisecondsSinceEpoch}';
      final newTask = TeamTaskModel(
        id: newTaskId,
        title: taskName,
        priority: TaskPriority.medium,
        assignedTo: assignedNames,
        assigneeColor: primaryAvatarColor,
        assigneeColors: assignedColors,
        timeRange: timeStr,
        description: _descriptionController.text.trim(),
        deadline: _selectedDate,
        dueBadge: dueBadgeStr,
        isAlertEnabled: _isAlertEnabled,
      );

      TeamTaskRepository().setTaskMilestone(
        teamCode: widget.teamCode,
        taskId: newTaskId,
        milestoneId: _selectedMilestoneId,
      );

      widget.onTaskCreated?.call(newTask);
      if (mounted) {
        PopUpPemberitahuanTeam.taskCreated(
          context,
          taskName: taskName,
          assignees: assignedNames,
        );
        _close(newTask);
      }
    }
  }

  Future<void> _handleDelete() async {
    final existing = widget.existingTask;
    if (existing == null) return;
    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: 'Delete Team Task?',
      message:
          'Are you sure you want to delete this team task? This action cannot be undone.',
    );
    if (confirmed == true && mounted) {
      TeamTaskRepository().deleteTask(widget.teamCode, existing.id);
      widget.onTaskDeleted?.call();
      PopUpPemberitahuan.taskDeleted(
        context,
        taskName: existing.title,
      );
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.disableAnimationsOf(context);
    final animDuration =
        disableMotion ? Duration.zero : const Duration(milliseconds: 200);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: UnfocusOnTap(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: maxHeight,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 32,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                    child: _buildHeaderRow(context, animDuration),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildFieldLabel(context, 'Task Name'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              key: const ValueKey(
                                  'desktop_team_task_name_input'),
                              controller: _taskNameController,
                              hint: 'e.g. Design System Implementation',
                              maxLength: 80,
                            ),
                            const SizedBox(height: 14),
                            _buildFieldLabel(context, 'Description'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              key: const ValueKey(
                                  'desktop_team_task_desc_input'),
                              controller: _descriptionController,
                              hint: 'Write a description here',
                              maxLength: 500,
                              minLines: 3,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 14),
                            _buildDeadlineSection(context),
                            const SizedBox(height: 14),
                            _buildAssigneeSection(context),
                            const SizedBox(height: 14),
                            _buildFieldLabel(context, 'Milestone (Optional)'),
                            const SizedBox(height: 8),
                            _buildMilestoneDropdown(context),
                            const SizedBox(height: 20),
                            _buildFooterActions(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, Duration animDuration) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            _isEditing ? 'Edit Team Task' : 'Create Team Task',
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
        _buildTopBellAlertToggle(context, animDuration),
        const SizedBox(width: 10),
        Material(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            key: const ValueKey('desktop_team_task_modal_close_btn'),
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

  Widget _buildTopBellAlertToggle(
      BuildContext context, Duration animDuration) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('desktop_team_task_alert_toggle_btn'),
        onTap: () {
          setState(() => _isAlertEnabled = !_isAlertEnabled);
          final categoryConfig =
              UserProfileRepository().profile.teamTaskAlerts;
          PopUpPemberitahuanTeam.show(
            context,
            title: _isAlertEnabled ? 'Team Alert Active' : 'Team Alert Muted',
            message: _isAlertEnabled
                ? 'Team task alerts enabled (Following Profile: ${categoryConfig.summary}).'
                : 'Alerts muted for this team task.',
            icon: _isAlertEnabled
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_outlined,
            iconBgColor: _isAlertEnabled
                ? const Color(0xFF10B981)
                : const Color(0xFF475569),
          );
        },
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: animDuration,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: _isAlertEnabled ? AppColors.primary : AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  _isAlertEnabled ? AppColors.primary : AppColors.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isAlertEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_outlined,
                size: 14,
                color: _isAlertEnabled ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 5),
              Text(
                _isAlertEnabled ? 'Alert On' : 'Alert Off',
                style: TextStyle(
                  color: _isAlertEnabled ? Colors.white : AppColors.textMuted,
                  fontSize: 11.5,
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

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: AppColors.textWhite,
        fontSize: context.rFont(13, min: 12, max: 14),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String hint,
    required int maxLength,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      buildCounter: (
        context, {
        required currentLength,
        required isFocused,
        required maxLength,
      }) =>
          null,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13.5,
        fontFamily: 'Inter',
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12.5,
          fontFamily: 'Inter',
        ),
        filled: true,
        fillColor: AppColors.bgPrimary,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildDeadlineSection(BuildContext context) {
    final dateText = DateFormat('EEE dd MMM yyyy').format(_selectedDate);
    final timeText =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')} WIB';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, 'Submission Deadline'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPickerTile(
                key: const ValueKey('desktop_team_task_date_btn'),
                icon: Icons.calendar_today_outlined,
                iconColor: AppColors.primary,
                text: dateText,
                onTap: _pickDate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildPickerTile(
                key: const ValueKey('desktop_team_task_time_btn'),
                icon: Icons.access_time_rounded,
                iconColor: AppColors.primary,
                text: timeText,
                onTap: _pickTime,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPickerTile({
    required Key key,
    required IconData icon,
    required Color iconColor,
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.bgPrimary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssigneeSection(BuildContext context) {
    const members = TeamMemberModel.defaultMembers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFieldLabel(context, 'Assign To'),
            ),
            if (_selectedMembers.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${_selectedMembers.length} assigned',
                  style: const TextStyle(
                    color: AppColors.primaryAccent,
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < members.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderSubtle,
                  ),
                _buildMemberTile(members[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTile(TeamMemberModel member) {
    final isSelected = _selectedMembers.any((m) => m.id == member.id);
    final role = _memberRoles[member.id] ?? 'Team Member';
    final initials = _initialsFor(member.name);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('desktop_team_task_member_${member.id}'),
        onTap: () => _toggleMember(member),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: member.avatarColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: member.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFD1D5DB),
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '  •  $role',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primary : const Color(0xFF323846),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderSubtle,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneDropdown(BuildContext context) {
    final milestones = TeamTaskRepository().getMilestones(widget.teamCode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          key: const ValueKey('desktop_team_task_milestone_dropdown'),
          value: _selectedMilestoneId,
          isExpanded: true,
          dropdownColor: AppColors.bgPrimary,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textMuted,
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'None (No Milestone)',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            for (final m in milestones)
              DropdownMenuItem<String?>(
                value: m.id,
                child: Row(
                  children: [
                    const Icon(
                      Icons.flag_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        m.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      m.effectiveDueBadge,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontFamily: 'Inter',
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: (val) => setState(() => _selectedMilestoneId = val),
        ),
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context) {
    final submitLabel = _isEditing ? 'Save Changes' : 'Create Task';

    return Row(
      children: [
        if (_isEditing) ...[
          SizedBox(
            height: 44,
            child: OutlinedButton(
              key: const ValueKey('desktop_team_task_delete_btn'),
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
                'Delete Task',
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
              key: const ValueKey('desktop_team_task_submit_btn'),
              onPressed: _isSubmitting ? null : _handleSaveTask,
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
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    submitLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
