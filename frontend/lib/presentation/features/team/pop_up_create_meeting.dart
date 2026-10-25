import 'package:flutter/material.dart';
import '../../common_widgets/impal_date_picker_dialog.dart';
import '../../common_widgets/impal_time_picker_dialog.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../jadwal/models/schedule_model.dart';
import '../jadwal/models/schedule_repository.dart';
import '../jadwal/pop_up_konfirmasi_delete.dart';
import 'models/team_repository.dart';

/// Aliases for backwards compatibility with routes & components
typedef FormCreateMeeting = PopUpCreateMeeting;
typedef PopUpEditMeeting = PopUpCreateMeeting;
typedef FormEditMeeting = PopUpCreateMeeting;
typedef MeetingFormPage = PopUpCreateMeeting;
typedef CreateMeetingPage = PopUpCreateMeeting;
typedef EditMeetingPage = PopUpCreateMeeting;

/// Screen page for creating or editing a meeting matching the Add Schedule design
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

  /// Helper to open the Create Meeting screen as a full Page
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
    return Navigator.of(context).push<ScheduleModel>(
      MaterialPageRoute(
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
      ),
    );
  }

  /// Helper to open the Edit Meeting screen for an existing schedule
  static Future<ScheduleModel?> showEdit(
    BuildContext context, {
    ScheduleModel? schedule,
    ScheduleModel? existingSchedule,
    String? teamName,
    ValueChanged<ScheduleModel>? onUpdated,
  }) {
    final target = schedule ?? existingSchedule;
    assert(target != null, 'Either schedule or existingSchedule must be provided');
    return Navigator.of(context).push<ScheduleModel>(
      MaterialPageRoute(
        builder: (ctx) => PopUpCreateMeeting(
          existingSchedule: target,
          teamName: teamName,
          onUpdated: onUpdated,
        ),
      ),
    );
  }

  @override
  State<PopUpCreateMeeting> createState() => _PopUpCreateMeetingState();
}

class _PopUpCreateMeetingState extends State<PopUpCreateMeeting> {
  late final TextEditingController _nameController;
  late final TextEditingController _teamController;
  late final TextEditingController _locationController;
  late final TextEditingController _descController;
  late bool _isTeamMeeting;
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
      _isTeamMeeting = (existing.teamName != null && existing.teamName!.isNotEmpty) ||
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
    _descController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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

      final teamNameValue = (_isTeamMeeting && _teamController.text.trim().isNotEmpty)
          ? _teamController.text.trim()
          : null;

      final inputLoc = _locationController.text.trim();
      final loc = inputLoc.isNotEmpty
          ? inputLoc
          : (teamNameValue != null
              ? 'Team $teamNameValue / Online'
              : (widget.teamName != null && widget.teamName!.isNotEmpty
                  ? 'Team ${widget.teamName} / Online'
                  : 'Online / Google Meet'));

      if (isEdit && widget.existingSchedule != null) {
        final updatedSchedule = widget.existingSchedule!.copyWith(
          title: name,
          type: 'Meeting',
          timeStart: timeStartStr,
          timeEnd: timeEndStr,
          timeZone: 'WIB',
          location: loc,
          teamName: teamNameValue,
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
          teamName: teamNameValue,
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

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFF323846),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF8E95A5), size: 18)
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 12 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B4150)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B4150)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFA6144), width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final joinedTeams = TeamRepository().joinedTeamNames;
    final currentQuery = _teamController.text.trim().toLowerCase();
    final teamSuggestions = joinedTeams.where((t) {
      if (currentQuery.isEmpty) return true;
      return t.toLowerCase().contains(currentQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF282D37),
      appBar: AppBar(
        backgroundColor: const Color(0xFF282D37),
        elevation: 0,
        leading: IconButton(
          key: const ValueKey('close_create_meeting_button'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          isEdit ? 'Edit Meeting' : 'Create Meeting',
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
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFA6144)),
              tooltip: 'Delete Meeting',
              onPressed: _handleDeleteMeeting,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Meeting Name
                  const Text(
                    'Meeting Name',
                    style: TextStyle(
                      color: Color(0xFF8E95A5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    key: const ValueKey('create_meeting_name_input'),
                    controller: _nameController,
                    hint: 'e.g. Weekly Standup Kelompok IMPAL',
                    prefixIcon: Icons.groups_outlined,
                  ),
                  const SizedBox(height: 14),

                  // 2. Team Meeting Checkbox & Autocomplete
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isTeamMeeting = !_isTeamMeeting;
                        if (!_isTeamMeeting) {
                          _teamController.clear();
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: _isTeamMeeting,
                              activeColor: const Color(0xFFFA6144),
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: const BorderSide(
                                color: Color(0xFF8E95A5),
                                width: 1.5,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _isTeamMeeting = val ?? false;
                                  if (!_isTeamMeeting) {
                                    _teamController.clear();
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Team Meeting',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isTeamMeeting) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Team Name',
                      style: TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _teamController,
                      hint: 'Type team name (e.g. Kelompok - IMPAL)',
                      prefixIcon: Icons.group_work_rounded,
                      onChanged: (_) => setState(() {}),
                    ),
                    if (teamSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF232832),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF3B4150),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  color: Color(0xFFFA6144),
                                  size: 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Joined Teams (Tap to select):',
                                  style: TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: teamSuggestions.map((tName) {
                                final isChosen = _teamController.text
                                        .trim()
                                        .toLowerCase() ==
                                    tName.toLowerCase();
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _teamController.text = tName;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isChosen
                                          ? const Color(0xFFFA6144)
                                          : const Color(0xFF323846),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isChosen
                                            ? const Color(0xFFFA6144)
                                            : const Color(0xFF3B4150),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.group_rounded,
                                          color: isChosen
                                              ? Colors.white
                                              : const Color(0xFF8E95A5),
                                          size: 13,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          tName,
                                          style: TextStyle(
                                            color: isChosen
                                                ? Colors.white
                                                : const Color(0xFFE5E7EB),
                                            fontSize: 12,
                                            fontWeight: isChosen
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),

                  // 3. Location
                  const Text(
                    'Location',
                    style: TextStyle(
                      color: Color(0xFF8E95A5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    key: const ValueKey('create_meeting_location_input'),
                    controller: _locationController,
                    hint: 'e.g. Ruang Rapat / Google Meet / Discord',
                    prefixIcon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 16),

                  // 4. Date & Time Section Header
                  const Text(
                    'Date & Time',
                    style: TextStyle(
                      color: Color(0xFF8E95A5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    key: const ValueKey('create_meeting_date_picker_button'),
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF323846),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF3B4150)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, color: Color(0xFF8E95A5), size: 18),
                              const SizedBox(width: 10),
                              Text(
                                _formatDate(_selectedDate),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.edit_calendar_rounded, color: Color(0xFFFA6144), size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Start Time & End Time
                  Row(
                    children: [
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
                            const SizedBox(height: 8),
                            InkWell(
                              key: const ValueKey('create_meeting_time_picker_button'),
                              onTap: _pickStartTime,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF323846),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF3B4150)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, color: Color(0xFF8E95A5), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatTime(_startTime),
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
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
                            const SizedBox(height: 8),
                            InkWell(
                              key: const ValueKey('create_meeting_end_time_picker_button'),
                              onTap: _pickEndTime,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF323846),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF3B4150)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, color: Color(0xFF8E95A5), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatTime(_endTime),
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
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
                  const SizedBox(height: 16),

                  // 5. Repeat Weekly Switch
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF323846),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3B4150)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.repeat_rounded, color: Color(0xFF8E95A5), size: 18),
                            SizedBox(width: 10),
                            Text(
                              'Repeat Weekly',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Transform.scale(
                          scale: 0.82,
                          child: Switch(
                            key: const ValueKey('create_meeting_repeat_weekly_switch'),
                            value: _repeatWeekly,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            activeThumbColor: const Color(0xFFFA6144),
                            activeTrackColor: const Color(0xFFFA6144).withValues(alpha: 0.5),
                            onChanged: (val) => setState(() => _repeatWeekly = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. Description (Optional)
                  const Text(
                    'Description (Optional)',
                    style: TextStyle(
                      color: Color(0xFF8E95A5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    key: const ValueKey('create_meeting_desc_input'),
                    controller: _descController,
                    hint: 'Write meeting agenda, topics, or notes here...',
                    maxLines: 3,
                    prefixIcon: Icons.notes_rounded,
                  ),
                  const SizedBox(height: 24),

                  // 7. Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      key: const ValueKey('create_meeting_submit_button'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFA6144),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _handleSave,
                      child: Text(
                        isEdit ? 'Save Changes' : 'Create Meeting',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.15,
                        ),
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
    );
  }
}