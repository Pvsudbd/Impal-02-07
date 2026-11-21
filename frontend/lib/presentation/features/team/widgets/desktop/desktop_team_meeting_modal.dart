import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../../core/widgets/unfocus_on_tap.dart';
import '../../../../common_widgets/impal_date_picker_dialog.dart';
import '../../../../common_widgets/impal_time_picker_dialog.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../../profile/models/user_profile_model.dart';
import '../../../schedule/models/schedule_model.dart';
import '../../../schedule/models/schedule_repository.dart';
import '../../../schedule/pop_up_konfirmasi_delete.dart';
import '../../../schedule/pop_up_schedule_conflict_dialog.dart';
import '../../../schedule/widgets/team_meeting_autocomplete.dart';

/// Centered Desktop Pop-Up Modal for Creating and Editing Team Meetings.
///
/// Mirrors FigCraft `Modal - Create Team Meeting (Pop-Up)` (node `7160`) with
/// mobile `PopUpCreateMeeting` wording & field keys, top Alert Bell toggle pill,
/// `TeamMeetingAutocomplete`, 2-column `Start Time` / `End Time (Estimated)`,
/// `Repeat Weekly` switch, live conflict warning banner, Meeting Link/URL,
/// Description, top-right `[✕]` dismissal (without redundant Cancel button),
/// and Edit-mode `Delete Meeting` + `Save Changes` footer actions.
class DesktopTeamMeetingModal extends StatefulWidget {
  final String initialName;
  final String initialLocation;
  final String initialDescription;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final TimeOfDay? initialEndTime;
  final bool initialRepeatWeekly;
  final String? teamName;
  final bool showTeamMeetingOption;
  final ScheduleModel? existingSchedule;
  final bool embeddedPanel;
  final ValueChanged<ScheduleModel>? onCreated;
  final ValueChanged<ScheduleModel>? onUpdated;
  final VoidCallback? onClose;

  const DesktopTeamMeetingModal({
    super.key,
    this.initialName = '',
    this.initialLocation = '',
    this.initialDescription = '',
    this.initialDate,
    this.initialTime,
    this.initialEndTime,
    this.initialRepeatWeekly = false,
    this.teamName,
    this.showTeamMeetingOption = true,
    this.existingSchedule,
    this.embeddedPanel = false,
    this.onCreated,
    this.onUpdated,
    this.onClose,
  });

  static Future<ScheduleModel?> show(
    BuildContext context, {
    String initialName = '',
    String initialLocation = '',
    String initialDescription = '',
    DateTime? initialDate,
    TimeOfDay? initialTime,
    TimeOfDay? initialEndTime,
    bool initialRepeatWeekly = false,
    String? teamName,
    bool showTeamMeetingOption = true,
    ValueChanged<ScheduleModel>? onCreated,
  }) {
    return showDialog<ScheduleModel>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => DesktopTeamMeetingModal(
        initialName: initialName,
        initialLocation: initialLocation,
        initialDescription: initialDescription,
        initialDate: initialDate,
        initialTime: initialTime,
        initialEndTime: initialEndTime,
        initialRepeatWeekly: initialRepeatWeekly,
        teamName: teamName,
        showTeamMeetingOption: showTeamMeetingOption,
        onCreated: onCreated,
      ),
    );
  }

  static Future<ScheduleModel?> showEdit(
    BuildContext context, {
    ScheduleModel? schedule,
    ScheduleModel? existingSchedule,
    String? teamName,
    bool showTeamMeetingOption = true,
    ValueChanged<ScheduleModel>? onUpdated,
  }) {
    final target = schedule ?? existingSchedule;
    assert(target != null, 'Either schedule or existingSchedule must be provided');
    return showDialog<ScheduleModel>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => DesktopTeamMeetingModal(
        existingSchedule: target,
        teamName: teamName,
        showTeamMeetingOption: showTeamMeetingOption,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<DesktopTeamMeetingModal> createState() =>
      _DesktopTeamMeetingModalState();
}

class _DesktopTeamMeetingModalState extends State<DesktopTeamMeetingModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _teamController;
  late final TextEditingController _locationController;
  late final TextEditingController _meetingUrlController;
  late final TextEditingController _descController;
  late bool _isTeamMeeting;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _repeatWeekly;
  late bool _isAlertEnabled;
  bool _isSubmitting = false;

  bool get isEdit => widget.existingSchedule != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSchedule;
    _isAlertEnabled = existing?.isAlertEnabled ?? true;
    if (existing != null) {
      _nameController = TextEditingController(text: existing.title);
      _locationController =
          TextEditingController(text: existing.location ?? '');
      _meetingUrlController =
          TextEditingController(text: existing.meetingUrl ?? '');
      _descController = TextEditingController(text: existing.notes ?? '');
      _selectedDate = existing.date;
      _startTime = _parseTimeOfDay(existing.timeStart);
      final parsedEnd = _parseTimeOfDay(existing.timeEnd);
      if (parsedEnd.hour == _startTime.hour &&
          parsedEnd.minute == _startTime.minute) {
        _endTime = TimeOfDay(
          hour: (_startTime.hour + 1) % 24,
          minute: _startTime.minute,
        );
      } else {
        _endTime = parsedEnd;
      }
      _repeatWeekly = existing.repeat;
      _isTeamMeeting =
          (existing.teamName != null && existing.teamName!.isNotEmpty) ||
              (widget.teamName != null && widget.teamName!.isNotEmpty);
      _teamController = TextEditingController(
        text: existing.teamName ?? widget.teamName ?? '',
      );
    } else {
      _nameController = TextEditingController(text: widget.initialName);
      _locationController = TextEditingController(
        text: widget.initialLocation.isNotEmpty
            ? widget.initialLocation
            : 'Online / Google Meet',
      );
      _meetingUrlController = TextEditingController();
      _descController = TextEditingController(text: widget.initialDescription);
      _selectedDate = widget.initialDate ?? DateTime.now();
      _startTime = widget.initialTime ??
          TimeOfDay(
            hour: (DateTime.now().hour + 1) % 24,
            minute: 0,
          );
      _endTime = widget.initialEndTime ??
          TimeOfDay(
            hour: (_startTime.hour + 1) % 24,
            minute: _startTime.minute,
          );
      _repeatWeekly = widget.initialRepeatWeekly;
      _isTeamMeeting = widget.teamName != null && widget.teamName!.isNotEmpty;
      _teamController = TextEditingController(text: widget.teamName ?? '');
    }
  }

  static TimeOfDay _parseTimeOfDay(String str) {
    try {
      final clean = str.trim();
      final parts = clean.contains(':') ? clean.split(':') : clean.split('.');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0].trim()),
          minute: int.parse(parts[1].trim()),
        );
      }
    } catch (_) {}
    return const TimeOfDay(hour: 9, minute: 0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teamController.dispose();
    _locationController.dispose();
    _meetingUrlController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _close([ScheduleModel? result]) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.embeddedPanel) {
      widget.onClose?.call();
      return;
    }
    Navigator.of(context).pop(result);
  }

  List<ScheduleModel> get _currentConflicts {
    final startStr = _formatTime(_startTime).replaceAll(' WIB', '');
    final endStr = _formatTime(_endTime).replaceAll(' WIB', '');
    return ScheduleRepository().findConflicts(
      date: _selectedDate,
      timeStart: startStr,
      timeEnd: endStr,
      excludeId: widget.existingSchedule?.id,
    );
  }

  String _formatDate(DateTime dt) {
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  Future<void> _pickDate() async {
    final picked = await showImpalDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      title: 'Select Meeting Date',
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showImpalTimePicker(
      context: context,
      initialTime: _startTime,
      title: 'Select Start Time',
    );
    if (picked != null && mounted) {
      setState(() {
        final durationHours = (_endTime.hour - _startTime.hour) % 24;
        final durationMinutes = _endTime.minute - _startTime.minute;
        _startTime = picked;
        if (durationHours <= 0 && durationMinutes <= 0) {
          _endTime = TimeOfDay(
            hour: (picked.hour + 1) % 24,
            minute: picked.minute,
          );
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showImpalTimePicker(
      context: context,
      initialTime: _endTime,
      title: 'Select End Time (Estimated)',
    );
    if (picked != null && mounted) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _handleSave() async {
    if (_isSubmitting) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      PopUpPemberitahuan.teamWarning(
        context,
        title: 'Meeting Name Required',
        message: 'Please enter a meeting name.',
      );
      return;
    }

    final location = _locationController.text.trim().isNotEmpty
        ? _locationController.text.trim()
        : 'Online / Google Meet';

    final teamNameValue =
        _isTeamMeeting && _teamController.text.trim().isNotEmpty
            ? _teamController.text.trim()
            : null;

    final scheduleDate = _selectedDate;
    final meetingUrlVal = _meetingUrlController.text.trim().isNotEmpty
        ? _meetingUrlController.text.trim()
        : null;

    final conflicts = _currentConflicts;
    if (conflicts.isNotEmpty) {
      final proceed = await PopUpScheduleConflictDialog.show(
        context,
        conflicts: conflicts,
      );
      if (proceed != true || !mounted) {
        return;
      }
    }

    setState(() => _isSubmitting = true);

    if (isEdit) {
      final updated = widget.existingSchedule!.copyWith(
        title: name,
        type: 'Meeting',
        location: location,
        meetingUrl: meetingUrlVal,
        notes: _descController.text.trim(),
        date: scheduleDate,
        timeStart: _formatTime(_startTime).replaceAll(' WIB', ''),
        timeEnd: _formatTime(_endTime).replaceAll(' WIB', ''),
        repeat: _repeatWeekly,
        teamName: teamNameValue,
        isAlertEnabled: _isAlertEnabled,
      );

      await ScheduleRepository().updateSchedule(updated);

      if (!mounted) return;
      widget.onUpdated?.call(updated);
      PopUpPemberitahuan.meetingUpdated(context);
      _close(updated);
    } else {
      final newSchedule = ScheduleModel(
        id: 'meeting_${DateTime.now().millisecondsSinceEpoch}',
        title: name,
        type: 'Meeting',
        status: ScheduleModel.calculateStatus(
          date: scheduleDate,
          timeStart: _formatTime(_startTime).replaceAll(' WIB', ''),
          timeEnd: _formatTime(_endTime).replaceAll(' WIB', ''),
        ),
        location: location,
        meetingUrl: meetingUrlVal,
        notes: _descController.text.trim(),
        date: scheduleDate,
        timeStart: _formatTime(_startTime).replaceAll(' WIB', ''),
        timeEnd: _formatTime(_endTime).replaceAll(' WIB', ''),
        repeat: _repeatWeekly,
        teamName: teamNameValue,
        isAlertEnabled: _isAlertEnabled,
      );

      await ScheduleRepository().addSchedule(newSchedule);

      if (!mounted) return;
      widget.onCreated?.call(newSchedule);
      PopUpPemberitahuan.meetingCreated(context);
      _close(newSchedule);
    }
  }

  Future<void> _handleDelete() async {
    final existing = widget.existingSchedule;
    if (existing == null) return;

    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: 'Delete Meeting?',
      message: 'Are you sure you want to delete "${existing.title}"?',
    );

    if (confirmed == true && mounted) {
      await ScheduleRepository().deleteSchedule(existing.id);
      if (mounted) {
        PopUpPemberitahuan.meetingDeleted(context);
        _close(existing);
      }
    }
  }

  Color get _controlSurfaceColor =>
      widget.embeddedPanel ? AppColors.bgCard : AppColors.bgPrimary;

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.disableAnimationsOf(context);
    final animDuration =
        disableMotion ? Duration.zero : const Duration(milliseconds: 200);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    final formShellColumn = Column(
      mainAxisSize: widget.embeddedPanel ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            widget.embeddedPanel ? 24 : 26,
            20,
            widget.embeddedPanel ? 24 : 26,
            widget.embeddedPanel ? 16 : 0,
          ),
          child: _buildHeaderRow(context, animDuration),
        ),
        if (widget.embeddedPanel)
          const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
        Flexible(
          fit: widget.embeddedPanel ? FlexFit.tight : FlexFit.loose,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              widget.embeddedPanel ? 24 : 26,
              widget.embeddedPanel ? 16 : 14,
              widget.embeddedPanel ? 24 : 26,
              22,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFieldLabel(context, 'Meeting Name'),
                const SizedBox(height: 8),
                _buildTextField(
                  key: const ValueKey('create_meeting_name_input'),
                  controller: _nameController,
                  hint: 'e.g. Weekly Standup Kelompok IMPAL',
                  prefixIcon: Icons.groups_rounded,
                  maxLength: 80,
                ),
                if (widget.showTeamMeetingOption)
                  TeamMeetingAutocomplete(
                    isTeamMeeting: _isTeamMeeting,
                    teamController: _teamController,
                    onToggleTeamMeeting: (val) {
                      setState(() {
                        _isTeamMeeting = val;
                        if (!_isTeamMeeting) {
                          _teamController.clear();
                        }
                      });
                    },
                    onTeamChanged: () => setState(() {}),
                  ),
                const SizedBox(height: 14),
                _buildFieldLabel(context, 'Location'),
                const SizedBox(height: 8),
                _buildTextField(
                  key: const ValueKey('create_meeting_location_input'),
                  controller: _locationController,
                  hint: 'e.g. Ruang Rapat / Google Meet / Discord',
                  prefixIcon: Icons.location_on_rounded,
                  maxLength: 80,
                ),
                const SizedBox(height: 14),
                _buildDateAndTimeSection(context),
                const SizedBox(height: 14),
                _buildRepeatWeeklyCard(context),
                if (_currentConflicts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildConflictWarningBanner(_currentConflicts),
                ],
                const SizedBox(height: 14),
                _buildFieldLabel(context, 'Meeting Link / URL (Optional)'),
                const SizedBox(height: 8),
                _buildTextField(
                  key: const ValueKey('create_meeting_url_input'),
                  controller: _meetingUrlController,
                  hint: 'https://meet.google.com/... or Zoom link',
                  prefixIcon: Icons.videocam_outlined,
                  maxLength: 250,
                ),
                const SizedBox(height: 14),
                _buildFieldLabel(context, 'Description (Optional)'),
                const SizedBox(height: 8),
                _buildTextField(
                  key: const ValueKey('create_meeting_desc_input'),
                  controller: _descController,
                  hint: 'Write meeting agenda, topics, or notes here...',
                  prefixIcon: Icons.notes_rounded,
                  maxLines: 3,
                  maxLength: 500,
                ),
                if (!widget.embeddedPanel) ...[
                  const SizedBox(height: 20),
                  _buildFooterActions(context),
                ],
              ],
            ),
          ),
        ),
        if (widget.embeddedPanel) ...[
          const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
            child: _buildFooterActions(context),
          ),
        ],
      ],
    );

    if (widget.embeddedPanel) {
      return UnfocusOnTap(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bgPrimary,
            border: Border(
              left: BorderSide(color: AppColors.borderSubtle, width: 1),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: formShellColumn,
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: UnfocusOnTap(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
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
              child: formShellColumn,
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
            isEdit ? 'Edit Meeting' : 'Create Meeting',
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
        _buildAlertToggle(context, animDuration),
        const SizedBox(width: 10),
        Material(
          color: _controlSurfaceColor,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            key: const ValueKey('close_create_meeting_button'),
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

  Widget _buildAlertToggle(BuildContext context, Duration animDuration) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('desktop_meeting_alert_toggle_btn'),
        onTap: () {
          setState(() => _isAlertEnabled = !_isAlertEnabled);
          final categoryConfig =
              UserProfileRepository().profile.teamMeetingAlerts;
          PopUpPemberitahuan.show(
            context,
            title: _isAlertEnabled
                ? 'Meeting Alert Active'
                : 'Meeting Alert Muted',
            message: _isAlertEnabled
                ? 'Meeting alerts enabled (Following Profile: ${categoryConfig.summary}).'
                : 'Alerts muted for this meeting.',
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
          duration: animDuration,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: _isAlertEnabled ? AppColors.primary : _controlSurfaceColor,
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
        color: AppColors.textMuted,
        fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    int? maxLength,
  }) {
    final isMultilineWithIcon = maxLines > 1 && prefixIcon != null;

    final field = TextField(
      key: key,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      textAlignVertical:
          maxLines > 1 ? TextAlignVertical.top : TextAlignVertical.center,
      buildCounter: maxLength != null
          ? (
              context, {
              required currentLength,
              required isFocused,
              required maxLength,
            }) =>
              null
          : null,
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
        prefixIcon: (!isMultilineWithIcon && prefixIcon != null)
            ? Icon(prefixIcon, color: AppColors.textMuted, size: 18)
            : null,
        filled: true,
        fillColor: _controlSurfaceColor,
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
        contentPadding: isMultilineWithIcon
            ? const EdgeInsets.fromLTRB(44, 12, 14, 12)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );

    if (!isMultilineWithIcon) return field;

    return Stack(
      children: [
        field,
        Positioned(
          top: 13,
          left: 14,
          child: IgnorePointer(
            child: Icon(
              prefixIcon,
              color: AppColors.textMuted,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateAndTimeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, 'Date & Time'),
        const SizedBox(height: 8),
        Material(
          color: _controlSurfaceColor,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            key: const ValueKey('create_meeting_date_picker_button'),
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.textMuted,
                    size: 17,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _formatDate(_selectedDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.edit_calendar_rounded,
                    color: AppColors.primary,
                    size: 17,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel(context, 'Start Time'),
                  const SizedBox(height: 8),
                  _buildTimeTile(
                    key: const ValueKey('create_meeting_time_picker_button'),
                    icon: Icons.access_time_rounded,
                    text: _formatTime(_startTime),
                    onTap: _pickStartTime,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel(context, 'End Time (Estimated)'),
                  const SizedBox(height: 8),
                  _buildTimeTile(
                    key:
                        const ValueKey('create_meeting_end_time_picker_button'),
                    icon: Icons.timer_outlined,
                    text: _formatTime(_endTime),
                    onTap: _pickEndTime,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeTile({
    required Key key,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _controlSurfaceColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textMuted, size: 17),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
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

  Widget _buildRepeatWeeklyCard(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _controlSurfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.repeat_rounded,
            color: AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Repeat Weekly',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              key: const ValueKey('create_meeting_repeat_weekly_switch'),
              value: _repeatWeekly,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              onChanged: (val) => setState(() => _repeatWeekly = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictWarningBanner(List<ScheduleModel> conflicts) {
    final conflict = conflicts.first;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _controlSurfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFBBF24), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFBBF24),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Schedule Conflict Detected',
                  style: TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Overlaps with "${conflict.title}" (${conflict.formattedTime})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context) {
    final submitLabel = isEdit ? 'Save Changes' : 'Create Meeting';

    return Row(
      children: [
        if (isEdit) ...[
          SizedBox(
            height: 44,
            child: OutlinedButton(
              key: const ValueKey('delete_meeting_button'),
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
                'Delete Meeting',
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
              key: const ValueKey('create_meeting_submit_button'),
              onPressed: _isSubmitting ? null : _handleSave,
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
