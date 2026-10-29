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
  final _notesController = TextEditingController();

  String _selectedType = 'Lecture';
  bool _isTeamMeeting = false;
  bool _isSubmitting = false;
  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 30);
  bool _repeatWeekly = true;

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
    _notesController.dispose();
    super.dispose();
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

    if (isEdit) {
      final confirmed = await PopUpKonfirmasiEdit.show(context);
      if (confirmed != true) {
        setState(() => _isSubmitting = false);
        return;
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
      final confirmed = await PopUpMakeSchedule.show(context);
      if (confirmed != true) {
        setState(() => _isSubmitting = false);
        return;
      }

      final scheduleDate = _selectedDate;

      final newSchedule = ScheduleModel(
        id: 'sch_${DateTime.now().millisecondsSinceEpoch}',
        title: enteredText,
        type: _selectedType,
        course: _selectedType == 'Lecture' ? enteredText : null,
        teamName: teamNameValue,
        location: locationValue,
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
        leading: IconButton(
          key: const ValueKey('close_create_meeting_button'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
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
                        hint: isLecture
                            ? 'e.g. SSIF-04-REG • Software Testing & Implementation'
                            : (isMeeting
                                ? 'e.g. Weekly Standup Kelompok IMPAL'
                                : 'e.g. Meet Impal Kelompok 7'),
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
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      maxLines: maxLines,
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
}
