import 'package:flutter/material.dart';
import '../../common_widgets/impal_date_picker_dialog.dart';
import '../../common_widgets/impal_time_picker_dialog.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../jadwal/models/schedule_model.dart';
import '../jadwal/models/schedule_repository.dart';
import '../jadwal/pop_up_konfirmasi_delete.dart';

/// Aliases for backwards compatibility with Figma export & routes
typedef FormCreateMeeting = PopUpCreateMeeting;
typedef PopUpEditMeeting = PopUpCreateMeeting;
typedef FormEditMeeting = PopUpCreateMeeting;

/// Pop up dialog for creating or editing a meeting matching Figma design & IMPAL rules
class PopUpCreateMeeting extends StatefulWidget {
  final String initialName;
  final String initialLocation;
  final String initialDescription;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final TimeOfDay? initialEndTime;
  final bool initialRepeatWeekly;
  final String? teamName;
  final ScheduleModel? existingSchedule;
  final ValueChanged<ScheduleModel>? onCreated;
  final ValueChanged<ScheduleModel>? onUpdated;

  const PopUpCreateMeeting({
    super.key,
    this.initialName = '',
    this.initialLocation = '',
    this.initialDescription = '',
    this.initialDate,
    this.initialTime,
    this.initialEndTime,
    this.initialRepeatWeekly = false,
    this.teamName,
    this.existingSchedule,
    this.onCreated,
    this.onUpdated,
  });

  /// Helper to show the Create Meeting popup as a modal dialog
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
    ValueChanged<ScheduleModel>? onCreated,
  }) {
    return showDialog<ScheduleModel>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => PopUpCreateMeeting(
        initialName: initialName,
        initialLocation: initialLocation,
        initialDescription: initialDescription,
        initialDate: initialDate,
        initialTime: initialTime,
        initialEndTime: initialEndTime,
        initialRepeatWeekly: initialRepeatWeekly,
        teamName: teamName,
        onCreated: onCreated,
      ),
    );
  }

  /// Helper to show the Edit Meeting popup for an existing schedule
  static Future<ScheduleModel?> showEdit(
    BuildContext context, {
    ScheduleModel? schedule,
    ScheduleModel? existingSchedule,
    String? teamName,
    ValueChanged<ScheduleModel>? onUpdated,
  }) {
    final target = schedule ?? existingSchedule;
    assert(target != null, 'Either schedule or existingSchedule must be provided');
    return showDialog<ScheduleModel>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => PopUpCreateMeeting(
        existingSchedule: target,
        teamName: teamName,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<PopUpCreateMeeting> createState() => _PopUpCreateMeetingState();
}

class _PopUpCreateMeetingState extends State<PopUpCreateMeeting> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _descController;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _repeatWeekly;

  bool get isEdit => widget.existingSchedule != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSchedule;
    if (existing != null) {
      _nameController = TextEditingController(text: existing.title);
      _locationController = TextEditingController(text: existing.location ?? '');
      _descController = TextEditingController(text: existing.notes ?? '');
      _selectedDate = existing.date;
      _startTime = _parseTimeOfDay(existing.timeStart);
      final parsedEnd = _parseTimeOfDay(existing.timeEnd);
      if (parsedEnd.hour == _startTime.hour && parsedEnd.minute == _startTime.minute) {
        _endTime = TimeOfDay(
          hour: (_startTime.hour + 1) % 24,
          minute: _startTime.minute,
        );
      } else {
        _endTime = parsedEnd;
      }
      _repeatWeekly = existing.repeat;
    } else {
      _nameController = TextEditingController(text: widget.initialName);
      _locationController = TextEditingController(
        text: widget.initialLocation.isNotEmpty
            ? widget.initialLocation
            : 'Online / Google Meet',
      );
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
    _locationController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dayName = dayNames[dt.weekday - 1];
    final monthName = monthNames[dt.month - 1];
    return '$dayName ${dt.day} $monthName ${dt.year}';
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
      title: isEdit ? 'Select Meeting Date' : 'Select Meeting Date',
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
        // Keep end time after start time if default duration was negative/zero
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
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      PopUpPemberitahuan.teamWarning(
        context,
        title: 'Meeting Name Required',
        message: 'Please enter meeting name.',
      );
      return;
    }

    try {
      final startH = _startTime.hour.toString().padLeft(2, '0');
      final startM = _startTime.minute.toString().padLeft(2, '0');
      final endH = _endTime.hour.toString().padLeft(2, '0');
      final endM = _endTime.minute.toString().padLeft(2, '0');

      final timeStartStr = '$startH:$startM';
      final timeEndStr = '$endH:$endM';

      final status = ScheduleModel.calculateStatus(
        date: _selectedDate,
        timeStart: timeStartStr,
        timeEnd: timeEndStr,
      );

      final inputLoc = _locationController.text.trim();
      final loc = inputLoc.isNotEmpty
          ? inputLoc
          : (widget.teamName != null && widget.teamName!.isNotEmpty
              ? 'Team ${widget.teamName} / Online'
              : 'Online / Google Meet');

      if (isEdit && widget.existingSchedule != null) {
        final updatedSchedule = widget.existingSchedule!.copyWith(
          title: name,
          type: 'Meeting',
          timeStart: timeStartStr,
          timeEnd: timeEndStr,
          timeZone: 'WIB',
          location: loc,
          status: status,
          notes: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          date: _selectedDate,
          repeat: _repeatWeekly,
        );

        await ScheduleRepository().updateSchedule(updatedSchedule);

        if (widget.onUpdated != null) {
          widget.onUpdated!(updatedSchedule);
        }
        if (widget.onCreated != null) {
          widget.onCreated!(updatedSchedule);
        }

        if (mounted) {
          PopUpPemberitahuan.meetingUpdated(context);
          Navigator.of(context).pop(updatedSchedule);
        }
      } else {
        final newSchedule = ScheduleModel(
          id: 'meeting_${DateTime.now().millisecondsSinceEpoch}',
          title: name,
          type: 'Meeting',
          timeStart: timeStartStr,
          timeEnd: timeEndStr,
          timeZone: 'WIB',
          location: loc,
          status: status,
          notes: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          date: _selectedDate,
          repeat: _repeatWeekly,
        );

        await ScheduleRepository().addSchedule(newSchedule);

        if (widget.onCreated != null) {
          widget.onCreated!(newSchedule);
        }

        if (mounted) {
          PopUpPemberitahuan.meetingCreated(context);
          Navigator.of(context).pop(newSchedule);
        }
      }
    } catch (_) {
      if (mounted) {
        PopUpPemberitahuan.teamWarning(
          context,
          title: 'Error',
          message: isEdit
              ? 'Failed to update meeting. Please try again.'
              : 'Failed to create meeting. Please try again.',
        );
      }
    }
  }

  Future<void> _handleDeleteMeeting() async {
    if (widget.existingSchedule == null) return;
    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: 'Delete Meeting?',
      message: 'Are you sure you want to delete this meeting? This action cannot be undone.',
    );
    if (confirmed != true) return;

    await ScheduleRepository().deleteSchedule(widget.existingSchedule!.id);

    if (mounted) {
      PopUpPemberitahuan.meetingDeleted(context);
      Navigator.of(context).pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 352,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFF323846),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 30,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title, Delete & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      isEdit ? 'Edit Meeting' : 'Create Meeting',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.07,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEdit) ...[
                        InkWell(
                          key: const ValueKey('delete_meeting_button'),
                          onTap: _handleDeleteMeeting,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: ShapeDecoration(
                              color: const Color(0x33FA6144),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFFA6144),
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      InkWell(
                        key: const ValueKey('close_create_meeting_button'),
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: ShapeDecoration(
                            color: const Color(0x33FA6144),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFFFA6144),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Meeting Name Field
              const Text(
                'Meeting Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.75,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.20,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: ShapeDecoration(
                  color: const Color(0xFF282D37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: TextField(
                  key: const ValueKey('create_meeting_name_input'),
                  controller: _nameController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Name meeting',
                    hintStyle: TextStyle(
                      color: Color(0xFF8E95A5),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Meeting Location Field
              const Text(
                'Location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.75,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.20,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: ShapeDecoration(
                  color: const Color(0xFF282D37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: TextField(
                  key: const ValueKey('create_meeting_location_input'),
                  controller: _locationController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Online / Google Meet, Discord, Room 204',
                    hintStyle: TextStyle(
                      color: Color(0xFF8E95A5),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Description (Optional)
              const Text(
                'Description (Optional)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.55,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.03,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: ShapeDecoration(
                  color: const Color(0xFF282D37),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFF282D37),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: TextField(
                  key: const ValueKey('create_meeting_desc_input'),
                  controller: _descController,
                  maxLines: 3,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Write a description here',
                    hintStyle: TextStyle(
                      color: Color(0xFF8E95A5),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Date & Time
              const Text(
                'Date & Time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.55,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.03,
                ),
              ),
              const SizedBox(height: 6),

              // Date Picker Button (Full Width)
              InkWell(
                key: const ValueKey('create_meeting_date_picker_button'),
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF282D37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _formatDate(_selectedDate),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: Color(0xFF8E95A5),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Time Row: Start Time & End Time (Estimated)
              Row(
                children: [
                  // Start Time Picker
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Time',
                          style: TextStyle(
                            color: Color(0xFF8E95A5),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          key: const ValueKey('create_meeting_time_picker_button'),
                          onTap: _pickStartTime,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF282D37),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    _formatTime(_startTime),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.access_time_rounded,
                                  color: Color(0xFF8E95A5),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // End Time (Estimated) Picker
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'End Time (Estimated)',
                          style: TextStyle(
                            color: Color(0xFF8E95A5),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          key: const ValueKey('create_meeting_end_time_picker_button'),
                          onTap: _pickEndTime,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF282D37),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    _formatTime(_endTime),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.timer_outlined,
                                  color: Color(0xFF8E95A5),
                                  size: 16,
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
              const SizedBox(height: 12),

              // Repeat Weekly Toggle Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: ShapeDecoration(
                  color: const Color(0xFF282D37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.repeat_rounded,
                            color: Color(0xFF8E95A5),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Repeat Weekly',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Recurs weekly',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        key: const ValueKey('create_meeting_repeat_weekly_switch'),
                        value: _repeatWeekly,
                        activeThumbColor: const Color(0xFFFA6144),
                        activeTrackColor: const Color(0xFFFA6144).withValues(alpha: 0.4),
                        inactiveThumbColor: const Color(0xFF8E95A5),
                        inactiveTrackColor: const Color(0xFF1F242D),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) {
                          setState(() {
                            _repeatWeekly = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('create_meeting_submit_button'),
                  onTap: _handleSave,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFA6144),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isEdit ? 'Save Changes' : 'Create Meeting',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}