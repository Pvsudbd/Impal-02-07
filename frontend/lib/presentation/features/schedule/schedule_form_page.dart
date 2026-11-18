import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/unfocus_on_tap.dart';
import '../../common_widgets/impal_date_picker_dialog.dart';
import '../../common_widgets/impal_time_picker_dialog.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import 'models/schedule_model.dart';
import 'models/schedule_repository.dart';
import 'pop_up_konfirmasi_delete.dart';
import 'pop_up_konfirmasi_edit.dart';
import 'pop_up_make_schedule.dart';
import 'pop_up_schedule_conflict_dialog.dart';
import 'widgets/schedule_date_time_section.dart';
import 'widgets/schedule_type_selector.dart';
import 'widgets/team_meeting_autocomplete.dart';

/// Aliases for backwards compatibility
typedef AddNewSchedule = ScheduleFormPage;
typedef EditSchedule = ScheduleFormPage;
typedef AddNewScheduleVar1 = ScheduleFormPage;
typedef AddNewScheduleVar2 = ScheduleFormPage;
typedef AddNewTask = ScheduleFormPage;
typedef AddNewTaskVar1 = ScheduleFormPage;
typedef AddNewTaskVar2 = ScheduleFormPage;
typedef EditScheduleVar1 = ScheduleFormPage;
typedef EditScheduleVar2 = ScheduleFormPage;
typedef EditTask = ScheduleFormPage;
typedef EditTaskVar1 = ScheduleFormPage;
typedef EditTaskVar2 = ScheduleFormPage;
typedef Edittask = ScheduleFormPage;
typedef EdittaskVar2 = ScheduleFormPage;

/// Unified screen for adding or editing a schedule.
/// When [schedule] is provided, this page operates in Edit mode.
/// When [schedule] is null, it operates in Create / Add mode.
class ScheduleFormPage extends StatefulWidget {
  final ScheduleModel? schedule;
  final DateTime? initialDate;
  final String? initialType;

  const ScheduleFormPage({
    super.key,
    this.schedule,
    this.initialDate,
    this.initialType,
  });

  bool get isEdit => schedule != null;

  @override
  State<ScheduleFormPage> createState() => _ScheduleFormPageState();
}

class _ScheduleFormPageState extends State<ScheduleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _teamController = TextEditingController();
  final _locationController = TextEditingController();
  final _meetingUrlController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'Lecture';
  bool _isTeamMeeting = false;
  bool _isSubmitting = false;
  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 30);
  bool _repeatWeekly = true;
  bool _isAlertEnabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      final s = widget.schedule!;
      final rawType = s.type.trim();
      if (rawType.toLowerCase() == 'lecture') {
        _selectedType = 'Lecture';
      } else if (rawType.toLowerCase() == 'meeting') {
        _selectedType = 'Meeting';
      } else {
        _selectedType = 'External';
      }
      _titleController.text = (_selectedType == 'Lecture' ? (s.course ?? s.title) : s.title);
      _locationController.text = s.location ?? '';
      _meetingUrlController.text = s.meetingUrl ?? '';
      _notesController.text = s.notes ?? '';
      _selectedDate = s.date;
      _repeatWeekly = s.repeat;
      _startTime = _parseTime(s.timeStart, const TimeOfDay(hour: 9, minute: 30));
      _endTime = _parseTime(s.timeEnd, const TimeOfDay(hour: 11, minute: 30));
      _isTeamMeeting = (s.teamName != null && s.teamName!.isNotEmpty) ||
          (_selectedType == 'Meeting' && (s.location?.toLowerCase().contains('team') == true));
      _teamController.text = s.teamName ?? '';
    } else {
      final rawType = (widget.initialType ?? 'Lecture').trim();
      if (rawType.toLowerCase() == 'lecture') {
        _selectedType = 'Lecture';
      } else if (rawType.toLowerCase() == 'meeting') {
        _selectedType = 'Meeting';
      } else {
        _selectedType = 'External';
      }
      _selectedDate = widget.initialDate ?? DateTime.now();
      _repeatWeekly = _selectedType == 'Lecture';
      _startTime = const TimeOfDay(hour: 9, minute: 30);
      _endTime = const TimeOfDay(hour: 11, minute: 30);
      _isTeamMeeting = false;
      _teamController.text = '';
      _meetingUrlController.text = '';
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

  List<ScheduleModel> get _currentConflicts {
    return ScheduleRepository().findConflicts(
      date: _selectedDate,
      timeStart: _formatTime(_startTime),
      timeEnd: _formatTime(_endTime),
      excludeId: widget.schedule?.id,
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _selectDate() async {
    final picked = await showImpalDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      title: 'Select Date',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showImpalTimePicker(
      context: context,
      initialTime: _startTime,
      title: 'Select Start Time',
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showImpalTimePicker(
      context: context,
      initialTime: _endTime,
      title: 'Select End Time',
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _deleteSchedule() async {
    if (widget.schedule == null) return;
    final isMeeting = _selectedType == 'Meeting' || widget.schedule!.type == 'Meeting';
    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: isMeeting ? 'Delete Meeting?' : 'Delete Schedule',
      message: isMeeting
          ? 'Are you sure you want to delete this meeting? This action cannot be undone.'
          : 'Are you sure you want to delete this schedule? This action cannot be undone.',
    );
    if (confirmed != true) return;

    await ScheduleRepository().deleteSchedule(widget.schedule!.id);

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
    setState(() => _isSubmitting = true);

    final isEdit = widget.isEdit;
    final isMeeting = _selectedType == 'Meeting';
    final enteredText = _titleController.text.trim();
    final teamNameValue = (isMeeting && _isTeamMeeting && _teamController.text.trim().isNotEmpty)
        ? _teamController.text.trim()
        : null;

    String defaultLocation;
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
    bool conflictConfirmed = false;
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

    if (isEdit) {
      if (!conflictConfirmed) {
        final confirmed = await PopUpKonfirmasiEdit.show(context);
        if (confirmed != true || !mounted) {
          if (mounted) setState(() => _isSubmitting = false);
          return;
        }
      }

      final scheduleDate = _selectedDate;
      final autoStatus = ScheduleModel.calculateStatus(
        date: scheduleDate,
        timeStart: _formatTime(_startTime),
        timeEnd: _formatTime(_endTime),
      );

      final updated = widget.schedule!.copyWith(
        title: enteredText,
        type: _selectedType,
        status: autoStatus,
        course: _selectedType == 'Lecture' ? enteredText : null,
        teamName: teamNameValue,
        location: locationValue,
        meetingUrl: meetingUrlValue,
        date: scheduleDate,
        timeStart: _formatTime(_startTime),
        timeEnd: _formatTime(_endTime),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        repeat: _repeatWeekly,
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

      final scheduleDate = _selectedDate;

      final newSchedule = ScheduleModel(
        id: 'sch_${DateTime.now().millisecondsSinceEpoch}',
        title: enteredText,
        type: _selectedType,
        course: _selectedType == 'Lecture' ? enteredText : null,
        teamName: teamNameValue,
        location: locationValue,
        meetingUrl: meetingUrlValue,
        status: ScheduleModel.calculateStatus(
          date: scheduleDate,
          timeStart: _formatTime(_startTime),
          timeEnd: _formatTime(_endTime),
        ),
        date: scheduleDate,
        timeStart: _formatTime(_startTime),
        timeEnd: _formatTime(_endTime),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        repeat: _repeatWeekly,
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
    final isEdit = widget.isEdit;
    final isLecture = _selectedType == 'Lecture';
    final isMeeting = _selectedType == 'Meeting';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: Center(
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF323846),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF3B4150), width: 1.0),
            ),
            child: IconButton(
              key: const ValueKey('close_create_meeting_button'),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
        title: Text(
          isEdit
              ? (_selectedType == 'Meeting' ? 'Edit Meeting' : 'Edit Schedule')
              : (_selectedType == 'Meeting' ? 'Create Meeting' : 'Add Schedule'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isEdit) ...[
            IconButton(
              key: const ValueKey('delete_meeting_button'),
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.primary),
              tooltip: _selectedType == 'Meeting' ? 'Delete Meeting' : 'Delete Schedule',
              onPressed: _deleteSchedule,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: UnfocusOnTap(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row with Title & Alert Bell Toggle Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEdit
                                ? (_selectedType == 'Meeting' ? 'Edit Meeting' : 'Edit Schedule')
                                : (_selectedType == 'Meeting' ? 'Meeting Details' : 'Schedule Details'),
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          _buildAlertToggle(),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 1. Schedule Type selector
                      ScheduleTypeSelector(
                        selectedType: _selectedType,
                        onTypeChanged: (type) {
                          setState(() {
                            _selectedType = type;
                            _repeatWeekly = type == 'Lecture';
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // 2. Course / Meeting Title field
                      Text(
                        isLecture
                            ? 'Course'
                            : (isMeeting ? 'Meeting Title' : 'Schedule Title'),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        key: isMeeting ? const ValueKey('create_meeting_name_input') : null,
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

                      // 3. Team Meeting Checkbox & Autocomplete
                      if (isMeeting)
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

                      const SizedBox(height: 16),

                      // 4. Room / Location
                      const Text(
                        'Location / Room',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        key: isMeeting ? const ValueKey('create_meeting_location_input') : null,
                        controller: _locationController,
                        maxLength: 80,
                        hint: isLecture
                            ? 'e.g. KTT B-106 • SSIF-04-REG-GAB02'
                            : (isMeeting
                                ? 'e.g. Ruang Rapat / Google Meet / Zoom'
                                : 'Location'),
                        prefixIcon: Icons.location_on_rounded,
                      ),
                      const SizedBox(height: 16),

                      // 5. Date & Time Range & Repeat
                      ScheduleDateTimeSection(
                        selectedDate: _selectedDate,
                        startTime: _startTime,
                        endTime: _endTime,
                        repeatWeekly: _repeatWeekly,
                        isMeeting: isMeeting,
                        onSelectDate: _selectDate,
                        onSelectStartTime: _selectStartTime,
                        onSelectEndTime: _selectEndTime,
                        onToggleRepeat: (val) => setState(() => _repeatWeekly = val),
                      ),
                      if (_currentConflicts.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildConflictWarningBanner(_currentConflicts),
                      ],
                      const SizedBox(height: 16),

                      // Meeting URL (Optional)
                      const Text(
                        'Meeting Link / URL (Optional)',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        key: const ValueKey('schedule_meeting_url_input'),
                        controller: _meetingUrlController,
                        maxLength: 250,
                        hint: 'https://meet.google.com/... or Zoom link',
                        prefixIcon: Icons.videocam_outlined,
                      ),
                      const SizedBox(height: 16),

                      // 6. Notes (Optional)
                      const Text(
                        'Notes (Optional)',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        key: isMeeting ? const ValueKey('create_meeting_desc_input') : null,
                        controller: _notesController,
                        maxLength: 500,
                        hint: 'Add reminders, assignment info, or topics...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          key: isMeeting ? const ValueKey('create_meeting_submit_button') : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _submitForm,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isSubmitting) ...[
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                              Text(
                                isEdit
                                    ? 'Save Changes'
                                    : (isMeeting ? 'Create Meeting' : 'Create Schedule'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      buildCounter: maxLength != null
          ? (context, {required currentLength, required isFocused, required maxLength}) => null
          : null,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textMuted, size: 20)
            : null,
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildAlertToggle() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _isAlertEnabled = !_isAlertEnabled);
          PopUpPemberitahuan.show(
            context,
            title: _isAlertEnabled ? 'Schedule Alert Active' : 'Schedule Alert Muted',
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
                  fontSize: 12,
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

  Widget _buildConflictWarningBanner(List<ScheduleModel> conflicts) {
    final conflict = conflicts.first;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF282D37),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3B4150),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFBBF24),
            size: 20,
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
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Overlaps with "${conflict.title}" (${conflict.formattedTime})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
