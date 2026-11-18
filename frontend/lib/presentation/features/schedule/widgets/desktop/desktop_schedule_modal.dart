import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../../core/widgets/unfocus_on_tap.dart';
import '../../../../common_widgets/impal_date_picker_dialog.dart';
import '../../../../common_widgets/impal_time_picker_dialog.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../models/schedule_model.dart';
import '../../models/schedule_repository.dart';
import '../../pop_up_konfirmasi_delete.dart';
import '../../pop_up_konfirmasi_edit.dart';
import '../../pop_up_make_schedule.dart';
import '../../pop_up_schedule_conflict_dialog.dart';
import '../team_meeting_autocomplete.dart';

/// Centered Desktop Pop-Up Modal for Adding and Editing Schedules.
///
/// Combines FigCraft `Modal - Add Schedule (Pop-Up)` (node `6866`) and
/// `Modal - Edit Schedule (Pop-Up)` (node `7428`) container/grid styling with
/// mobile `ScheduleFormPage` wording, Title Case labels, top Alert Bell toggle,
/// and quick `[✕]` dismissal without a redundant bottom-left Cancel button.
class DesktopScheduleModal extends StatefulWidget {
  final ScheduleModel? schedule;
  final DateTime? initialDate;
  final String? initialType;

  const DesktopScheduleModal({
    super.key,
    this.schedule,
    this.initialDate,
    this.initialType,
  });

  static Future<bool?> show(
    BuildContext context, {
    ScheduleModel? schedule,
    DateTime? initialDate,
    String? initialType,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => DesktopScheduleModal(
        schedule: schedule,
        initialDate: initialDate,
        initialType: initialType,
      ),
    );
  }

  bool get isEdit => schedule != null;

  @override
  State<DesktopScheduleModal> createState() => _DesktopScheduleModalState();
}

class _DesktopScheduleModalState extends State<DesktopScheduleModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _teamController = TextEditingController();
  final _locationController = TextEditingController();
  final _meetingUrlController = TextEditingController();
  final _notesController = TextEditingController();

  late String _selectedType;
  late bool _isTeamMeeting;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _repeatWeekly;
  late bool _isAlertEnabled;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.schedule;
    if (existing != null) {
      final rawType = existing.type.trim().toLowerCase();
      if (rawType == 'lecture') {
        _selectedType = 'Lecture';
      } else if (rawType == 'meeting') {
        _selectedType = 'Meeting';
      } else {
        _selectedType = 'External';
      }
      _titleController.text =
          _selectedType == 'Lecture' ? (existing.course ?? existing.title) : existing.title;
      _locationController.text = existing.location ?? '';
      _meetingUrlController.text = existing.meetingUrl ?? '';
      _notesController.text = existing.notes ?? '';
      _selectedDate = existing.date;
      _startTime =
          _parseTime(existing.timeStart, const TimeOfDay(hour: 9, minute: 30));
      _endTime =
          _parseTime(existing.timeEnd, const TimeOfDay(hour: 11, minute: 30));
      _repeatWeekly = existing.repeat;
      _isAlertEnabled = existing.isAlertEnabled;
      _isTeamMeeting = (existing.teamName != null &&
              existing.teamName!.isNotEmpty) ||
          (_selectedType == 'Meeting' &&
              (existing.location?.toLowerCase().contains('team') == true));
      _teamController.text = existing.teamName ?? '';
    } else {
      final rawType = (widget.initialType ?? 'Lecture').trim().toLowerCase();
      if (rawType == 'meeting') {
        _selectedType = 'Meeting';
      } else if (rawType == 'external') {
        _selectedType = 'External';
      } else {
        _selectedType = 'Lecture';
      }
      _selectedDate = widget.initialDate ?? DateTime.now();
      _startTime = const TimeOfDay(hour: 9, minute: 30);
      _endTime = const TimeOfDay(hour: 11, minute: 30);
      _repeatWeekly = _selectedType == 'Lecture';
      _isAlertEnabled = true;
      _isTeamMeeting = false;
    }
  }

  TimeOfDay _parseTime(String str, TimeOfDay fallback) {
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
    return fallback;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _teamController.dispose();
    _locationController.dispose();
    _meetingUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  int get _durationMinutes {
    final startMin = _startTime.hour * 60 + _startTime.minute;
    final endMin = _endTime.hour * 60 + _endTime.minute;
    return endMin - startMin;
  }

  List<ScheduleModel> get _currentConflicts {
    return ScheduleRepository().findConflicts(
      date: _selectedDate,
      timeStart: _formatTime(_startTime),
      timeEnd: _formatTime(_endTime),
      excludeId: widget.schedule?.id,
    );
  }

  Future<void> _selectDate() async {
    final picked = await showImpalDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      title: 'Select Date',
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showImpalTimePicker(
      context: context,
      initialTime: _startTime,
      title: 'Select Start Time',
    );
    if (picked != null && mounted) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showImpalTimePicker(
      context: context,
      initialTime: _endTime,
      title: 'Select End Time',
    );
    if (picked != null && mounted) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _deleteSchedule() async {
    final existing = widget.schedule;
    if (existing == null) return;
    final isMeeting =
        _selectedType == 'Meeting' || existing.type == 'Meeting';
    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: isMeeting ? 'Delete Meeting?' : 'Delete Schedule',
      message: isMeeting
          ? 'Are you sure you want to delete this meeting? This action cannot be undone.'
          : 'Are you sure you want to delete this schedule? This action cannot be undone.',
    );
    if (confirmed != true) return;

    await ScheduleRepository().deleteSchedule(existing.id);

    if (mounted) {
      if (isMeeting) {
        PopUpPemberitahuan.meetingDeleted(context);
      } else {
        PopUpPemberitahuan.scheduleDeleted(context);
      }
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _submitForm() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_durationMinutes <= 0) {
      PopUpPemberitahuan.show(
        context,
        title: 'Invalid Time Slot',
        message: 'End time must be later than start time.',
        icon: Icons.schedule_rounded,
        iconBgColor: PopUpPemberitahuan.negativeColor,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final isEdit = widget.isEdit;
    final isMeeting = _selectedType == 'Meeting';
    final enteredText = _titleController.text.trim();
    final teamNameValue = (isMeeting &&
            _isTeamMeeting &&
            _teamController.text.trim().isNotEmpty)
        ? _teamController.text.trim()
        : null;

    final String defaultLocation;
    if (_selectedType == 'Lecture') {
      defaultLocation = 'Classroom';
    } else if (isMeeting) {
      defaultLocation = teamNameValue != null
          ? 'Team $teamNameValue / Online'
          : 'Online / Google Meet';
    } else {
      defaultLocation = 'Online / Meeting';
    }

    final locationValue = _locationController.text.trim().isNotEmpty
        ? _locationController.text.trim()
        : defaultLocation;

    final conflicts = _currentConflicts;
    var conflictConfirmed = false;
    if (conflicts.isNotEmpty) {
      final proceed = await PopUpScheduleConflictDialog.show(
        context,
        conflicts: conflicts,
      );
      if (proceed != true || !mounted) {
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }
      conflictConfirmed = true;
    }

    if (!mounted) return;

    final meetingUrlValue = _meetingUrlController.text.trim().isNotEmpty
        ? _meetingUrlController.text.trim()
        : null;
    final notesValue = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : null;

    if (isEdit) {
      if (!conflictConfirmed) {
        final confirmed = await PopUpKonfirmasiEdit.show(context);
        if (confirmed != true || !mounted) {
          if (mounted) setState(() => _isSubmitting = false);
          return;
        }
      }

      final updated = widget.schedule!.copyWith(
        title: enteredText,
        type: _selectedType,
        status: ScheduleModel.calculateStatus(
          date: _selectedDate,
          timeStart: _formatTime(_startTime),
          timeEnd: _formatTime(_endTime),
        ),
        course: _selectedType == 'Lecture' ? enteredText : null,
        teamName: teamNameValue,
        location: locationValue,
        meetingUrl: meetingUrlValue,
        date: _selectedDate,
        timeStart: _formatTime(_startTime),
        timeEnd: _formatTime(_endTime),
        notes: notesValue,
        repeat: _repeatWeekly,
        isAlertEnabled: _isAlertEnabled,
      );

      await ScheduleRepository().updateSchedule(updated);

      if (mounted) {
        if (isMeeting) {
          PopUpPemberitahuan.meetingUpdated(context);
        } else {
          PopUpPemberitahuan.scheduleUpdated(context);
        }
        Navigator.of(context).pop(true);
      }
    } else {
      if (!conflictConfirmed) {
        final confirmed = await PopUpMakeSchedule.show(context);
        if (confirmed != true || !mounted) {
          if (mounted) setState(() => _isSubmitting = false);
          return;
        }
      }

      final newSchedule = ScheduleModel(
        id: 'sch_${DateTime.now().millisecondsSinceEpoch}',
        title: enteredText,
        type: _selectedType,
        course: _selectedType == 'Lecture' ? enteredText : null,
        teamName: teamNameValue,
        location: locationValue,
        meetingUrl: meetingUrlValue,
        status: ScheduleModel.calculateStatus(
          date: _selectedDate,
          timeStart: _formatTime(_startTime),
          timeEnd: _formatTime(_endTime),
        ),
        date: _selectedDate,
        timeStart: _formatTime(_startTime),
        timeEnd: _formatTime(_endTime),
        notes: notesValue,
        repeat: _repeatWeekly,
        isAlertEnabled: _isAlertEnabled,
      );

      await ScheduleRepository().addSchedule(newSchedule);

      if (mounted) {
        if (isMeeting) {
          PopUpPemberitahuan.meetingCreated(context);
        } else {
          PopUpPemberitahuan.scheduleCreated(context);
        }
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.disableAnimationsOf(context);
    final animDuration =
        disableMotion ? Duration.zero : const Duration(milliseconds: 200);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    final isLecture = _selectedType == 'Lecture';
    final isMeeting = _selectedType == 'Meeting';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: UnfocusOnTap(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 540,
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
                            _buildTypeSegmentedBar(context),
                            const SizedBox(height: 16),
                            _buildFieldLabel(
                              context,
                              isLecture
                                  ? 'Course'
                                  : (isMeeting
                                      ? 'Meeting Title'
                                      : 'Schedule Title'),
                            ),
                            const SizedBox(height: 8),
                            _buildTextField(
                              key: ValueKey(
                                isMeeting
                                    ? 'create_meeting_name_input'
                                    : 'desktop_schedule_title_input',
                              ),
                              controller: _titleController,
                              maxLength: 80,
                              hint: isLecture
                                  ? 'e.g. SSIF-04-REG • Software Testing & Implementation'
                                  : (isMeeting
                                      ? 'e.g. Weekly Standup IMPAL Team'
                                      : 'e.g. IMPAL Team 7 Sync'),
                              prefixIcon: isLecture
                                  ? Icons.school_outlined
                                  : (isMeeting
                                      ? Icons.groups_outlined
                                      : Icons.event_note_rounded),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  if (isLecture) return 'Please enter course name';
                                  if (isMeeting) return 'Please enter meeting title';
                                  return 'Please enter schedule title';
                                }
                                return null;
                              },
                            ),
                            if (isMeeting) ...[
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
                            ],
                            const SizedBox(height: 14),
                            _buildFieldLabel(context, 'Location / Room'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              key: ValueKey(
                                isMeeting
                                    ? 'create_meeting_location_input'
                                    : 'desktop_schedule_location_input',
                              ),
                              controller: _locationController,
                              maxLength: 80,
                              hint: isLecture
                                  ? 'e.g. KTT B-106 • SSIF-04-REG-GAB02'
                                  : (isMeeting
                                      ? 'e.g. Ruang Rapat / Google Meet / Zoom'
                                      : 'Location'),
                              prefixIcon: Icons.location_on_rounded,
                            ),
                            const SizedBox(height: 14),
                            _buildDateSection(context),
                            const SizedBox(height: 14),
                            _buildTimeSlotSection(context),
                            if (_currentConflicts.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildConflictWarningBanner(_currentConflicts),
                            ],
                            const SizedBox(height: 14),
                            _buildRepeatToggleCard(context),
                            const SizedBox(height: 14),
                            _buildFieldLabel(
                                context, 'Meeting Link / URL (Optional)'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              key: const ValueKey('schedule_meeting_url_input'),
                              controller: _meetingUrlController,
                              maxLength: 250,
                              hint: 'https://meet.google.com/... or Zoom link',
                              prefixIcon: Icons.videocam_outlined,
                            ),
                            const SizedBox(height: 14),
                            _buildFieldLabel(context, 'Notes (Optional)'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              key: ValueKey(
                                isMeeting
                                    ? 'create_meeting_desc_input'
                                    : 'desktop_schedule_notes_input',
                              ),
                              controller: _notesController,
                              maxLength: 500,
                              hint:
                                  'Add reminders, assignment info, or topics...',
                              maxLines: 3,
                            ),
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
    final isEdit = widget.isEdit;
    final isMeeting = _selectedType == 'Meeting';
    final title = isEdit
        ? (isMeeting ? 'Edit Meeting' : 'Edit Schedule')
        : (isMeeting ? 'Create Meeting' : 'Add Schedule');
    final isOngoing = isEdit && widget.schedule?.status == 'Ongoing';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
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
              if (isOngoing) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Ongoing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildTopBellAlertToggle(context, animDuration),
        const SizedBox(width: 10),
        Material(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            key: const ValueKey('desktop_schedule_modal_close_btn'),
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop(false);
            },
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

  Widget _buildTopBellAlertToggle(BuildContext context, Duration animDuration) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('desktop_schedule_alert_toggle_btn'),
        onTap: () {
          setState(() => _isAlertEnabled = !_isAlertEnabled);
          PopUpPemberitahuan.show(
            context,
            title: _isAlertEnabled
                ? 'Schedule Alert Active'
                : 'Schedule Alert Muted',
            message: _isAlertEnabled
                ? 'Schedule reminder notifications enabled.'
                : 'Schedule reminder notifications muted.',
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

  Widget _buildTypeSegmentedBar(BuildContext context) {
    const types = [
      ('Lecture', Icons.school_rounded),
      ('Meeting', Icons.groups_rounded),
      ('External', Icons.event_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        children: types.map((entry) {
          final type = entry.$1;
          final icon = entry.$2;
          final isSelected = _selectedType == type;
          return Expanded(
            child: Material(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                key: ValueKey('desktop_schedule_type_$type'),
                onTap: () {
                  setState(() {
                    _selectedType = type;
                    if (!widget.isEdit) {
                      _repeatWeekly = type == 'Lecture';
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 15,
                        color: isSelected ? Colors.white : AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textMuted,
                          fontSize: 12.5,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      buildCounter: maxLength != null
          ? (context,
                  {required currentLength,
                  required isFocused,
                  required maxLength}) =>
              null
          : null,
      validator: validator,
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
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textMuted, size: 18)
            : null,
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

  Widget _buildDateSection(BuildContext context) {
    final formattedDate = DateFormat('d MMM yyyy').format(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, 'Date'),
        const SizedBox(height: 8),
        Material(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            key: const ValueKey('desktop_schedule_date_btn'),
            onTap: _selectDate,
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
                    size: 17,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      formattedDate,
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
                    size: 17,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, 'Time Duration'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTimeButton(
                key: const ValueKey('desktop_schedule_start_time_btn'),
                label: _formatTime(_startTime),
                onTap: _selectStartTime,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '-',
                style: TextStyle(color: AppColors.textMuted, fontSize: 18),
              ),
            ),
            Expanded(
              child: _buildTimeButton(
                key: const ValueKey('desktop_schedule_end_time_btn'),
                label: _formatTime(_endTime),
                onTap: _selectEndTime,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeButton({
    required Key key,
    required String label,
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
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 17,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
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

  Widget _buildRepeatToggleCard(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.repeat_rounded,
            size: 18,
            color: AppColors.textMuted,
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
              key: const ValueKey('desktop_schedule_repeat_switch'),
              value: _repeatWeekly,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              activeThumbColor: AppColors.primary,
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
        color: AppColors.bgPrimary,
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
    final isEdit = widget.isEdit;
    final isMeeting = _selectedType == 'Meeting';
    final submitLabel = isEdit
        ? 'Save Changes'
        : (isMeeting ? 'Create Meeting' : 'Create Schedule');

    return Row(
      children: [
        if (isEdit) ...[
          SizedBox(
            height: 44,
            child: OutlinedButton(
              key: const ValueKey('delete_meeting_button'),
              onPressed: _isSubmitting ? null : _deleteSchedule,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                isMeeting ? 'Delete Meeting' : 'Delete Schedule',
                style: const TextStyle(
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
              key: ValueKey(
                isMeeting
                    ? 'create_meeting_submit_button'
                    : 'desktop_schedule_submit_btn',
              ),
              onPressed: _isSubmitting ? null : _submitForm,
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
                      fontWeight: FontWeight.w600,
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
