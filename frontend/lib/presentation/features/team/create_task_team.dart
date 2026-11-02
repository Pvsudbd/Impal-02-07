import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../../core/widgets/unfocus_on_tap.dart';
import '../profile/models/user_profile_model.dart';
import '../schedule/pop_up_konfirmasi_delete.dart';
import 'models/team_member_model.dart';
import 'models/team_task_model.dart';
import 'pop_up_pemberitahuan_team.dart';
import 'widgets/assignee_dropdown.dart';
import 'widgets/submission_deadline_picker.dart';

// Re-exports & Aliases for backward compatibility
export 'models/team_member_model.dart';
export 'models/team_task_model.dart';

typedef EditTaskTeamPage = CreateTaskTeamPage;
typedef CreateTaskKelompok = CreateTaskTeamPage;
typedef EditTaskKelompok = CreateTaskTeamPage;
typedef CreateTaskPage = CreateTaskTeamPage;
typedef EditTaskPage = CreateTaskTeamPage;

/// Unified form screen for Creating and Editing team tasks.
///
/// Features:
/// - Dual-Mode Form: Automatically switches between "Create Task" and "Edit Task"
/// - Multi-Assignee: Supports assigning tasks to multiple team members
/// - PopUp Pemberitahuan: Uses standard IMPAL notification popups on success/warnings
///
/// Adheres strictly to AGENTS.md, ResponsiveContext, and 60 FPS performance standards.
class CreateTaskTeamPage extends StatefulWidget {
  final TeamTaskModel? existingTask;
  final void Function(TeamTaskModel task)? onTaskCreated;
  final void Function(TeamTaskModel updatedTask)? onTaskUpdated;
  final VoidCallback? onBack;
  final String userInitials;

  const CreateTaskTeamPage({
    super.key,
    this.existingTask,
    this.onTaskCreated,
    this.onTaskUpdated,
    this.onBack,
    this.userInitials = 'JS',
  });

  @override
  State<CreateTaskTeamPage> createState() => _CreateTaskTeamPageState();
}

class _CreateTaskTeamPageState extends State<CreateTaskTeamPage> {
  late final TextEditingController _taskNameController;
  late final TextEditingController _descriptionController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late List<TeamMemberModel> _selectedMembers;
  late bool _isAlertEnabled;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _isAlertEnabled = task?.isAlertEnabled ?? true;
    if (task != null) {
      _taskNameController = TextEditingController(text: task.title);
      _descriptionController = TextEditingController(text: task.description ?? '');
      _selectedDate = task.deadline ?? DateTime(2026, 10, 18);
      _selectedTime = _parseTimeOfDay(task.timeRange);
      _selectedMembers = _matchMembers(task.assignedTo);
    } else {
      _taskNameController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = DateTime(2026, 10, 18);
      _selectedTime = const TimeOfDay(hour: 23, minute: 59);
      _selectedMembers = [TeamMemberModel.defaultMembers.first];
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

  Future<void> _handleSaveTask() async {
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

    // Simulate short network / processing delay
    await Future.delayed(const Duration(milliseconds: 300));

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

      if (mounted) {
        setState(() => _isSubmitting = false);
        PopUpPemberitahuanTeam.taskUpdated(context, taskName: taskName);
        widget.onTaskUpdated?.call(updatedTask);
        widget.onTaskCreated?.call(updatedTask);
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(updatedTask);
        }
      }
    } else {
      final newTask = TeamTaskModel(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
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

      if (mounted) {
        setState(() => _isSubmitting = false);
        PopUpPemberitahuanTeam.taskCreated(
          context,
          taskName: taskName,
          assignees: assignedNames,
        );
        widget.onTaskCreated?.call(newTask);
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(newTask);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    final Widget pageBody = SingleChildScrollView(
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
                  // Top Navigation Bar (Back Button + Avatar Initials)
                  _buildTopHeader(context),
                  SizedBox(height: context.rSpacing(18)),

                  // Main Form Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rSpacing(20),
                      vertical: context.rSpacing(24),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Title & Alert Bell Toggle Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isEditing ? 'Edit Task' : 'Create Task',
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: context.rFont(22, min: 20, max: 26),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.1,
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() => _isAlertEnabled = !_isAlertEnabled);
                                  final categoryConfig =
                                      UserProfileRepository().profile.teamTaskAlerts;
                                  PopUpPemberitahuanTeam.show(
                                    context,
                                    title: _isAlertEnabled
                                        ? 'Team Alert Active'
                                        : 'Team Alert Muted',
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
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isAlertEnabled
                                        ? const Color(0xFFFBBF24).withValues(alpha: 0.18)
                                        : const Color(0xFF334155).withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _isAlertEnabled
                                          ? const Color(0xFFFBBF24)
                                          : const Color(0xFF475569),
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
                                        size: 15,
                                        color: _isAlertEnabled
                                            ? const Color(0xFFFBBF24)
                                            : const Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        _isAlertEnabled ? 'Alert On' : 'Alert Off',
                                        style: TextStyle(
                                          color: _isAlertEnabled
                                              ? const Color(0xFFFBBF24)
                                              : const Color(0xFF94A3B8),
                                          fontSize: context.rFont(11.5, min: 10, max: 13),
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
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

                        // Task Name Field
                        _buildSectionLabel(context, 'Task Name'),
                        SizedBox(height: context.rSpacing(8)),
                        _buildInputField(
                          context,
                          controller: _taskNameController,
                          hintText: 'Name meeting',
                          minLines: 1,
                          maxLines: 1,
                        ),
                        SizedBox(height: context.rSpacing(16)),

                        // Description Field
                        _buildSectionLabel(context, 'Description'),
                        SizedBox(height: context.rSpacing(8)),
                        _buildInputField(
                          context,
                          controller: _descriptionController,
                          hintText: 'Write a description here',
                          minLines: 4,
                          maxLines: 5,
                        ),
                        SizedBox(height: context.rSpacing(16)),

                        // Submission Deadline (Date & Time)
                        SubmissionDeadlinePicker(
                          selectedDate: _selectedDate,
                          selectedTime: _selectedTime,
                          onDateChanged: (d) => setState(() => _selectedDate = d),
                          onTimeChanged: (t) => setState(() => _selectedTime = t),
                        ),
                        SizedBox(height: context.rSpacing(16)),

                        // Assign To Dropdown (Multi-Select)
                        AssigneeDropdown(
                          members: TeamMemberModel.defaultMembers,
                          selectedMembers: _selectedMembers,
                          onMembersChanged: (members) =>
                              setState(() => _selectedMembers = members),
                        ),
                        SizedBox(height: context.rSpacing(24)),

                        // Submit Button (Dynamic: "Save Changes" or "Create Task")
                        _buildSubmitButton(context),
                        if (_isEditing) ...[
                          SizedBox(height: context.rSpacing(12)),
                          _buildDeleteButton(context),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: UnfocusOnTap(
        child: SafeArea(
          top: true,
          bottom: true,
          child: isMobile
              ? pageBody
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: pageBody,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button & Page Title
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF323846),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF3B4150), width: 1.0),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
              ),
            ),
            SizedBox(width: context.rSpacing(12)),
            Text(
              widget.existingTask != null ? 'Edit Team Task' : 'Create Team Task',
              style: TextStyle(
                color: Colors.white,
                fontSize: context.rFont(20, min: 18, max: 24),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        // User Avatar Initials Badge
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              widget.userInitials,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: context.rFont(14, min: 13, max: 15),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textWhite,
        fontSize: context.rFont(14.75, min: 13, max: 17),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required int minLines,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        enableInteractiveSelection: true,
        style: TextStyle(
          color: AppColors.textWhite,
          fontSize: context.rFont(14, min: 13, max: 15),
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textMuted,
            fontSize: context.rFont(13, min: 12, max: 14),
            fontFamily: 'Inter',
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(14),
            vertical: context.rSpacing(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final buttonLabel = _isEditing ? 'Save Changes' : 'Create Task';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isSubmitting ? null : _handleSaveTask,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40FA6144),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSubmitting) ...[
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: context.rSpacing(10)),
              ],
              Text(
                buttonLabel,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(15, min: 14, max: 16),
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

  Widget _buildDeleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await PopUpKonfirmasiDelete.show(
            context,
            title: 'Delete Team Task?',
            message:
                'Are you sure you want to delete this team task? This action cannot be undone.',
          );
          if (confirmed == true && context.mounted) {
            PopUpPemberitahuan.taskDeleted(
              context,
              taskName: widget.existingTask!.title,
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
