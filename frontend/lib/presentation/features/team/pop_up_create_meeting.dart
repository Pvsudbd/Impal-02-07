import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../common_widgets/impal_date_picker_dialog.dart';
import '../../common_widgets/impal_time_picker_dialog.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../schedule/models/schedule_model.dart';
import '../schedule/models/schedule_repository.dart';
import '../profile/models/user_profile_model.dart';
import '../schedule/pop_up_konfirmasi_delete.dart';
import '../schedule/widgets/team_meeting_autocomplete.dart';

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
  late bool _isAlertEnabled;

  bool get isEdit => widget.existingSchedule != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSchedule;
    _isAlertEnabled = existing?.isAlertEnabled ?? true;
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
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      PopUpPemberitahuan.teamWarning(
        context,
        title: 'Incomplete Form',
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

    if (isEdit) {
      final updated = widget.existingSchedule!.copyWith(
        title: name,
        type: 'Meeting',
        location: location,
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
      Navigator.of(context).pop(updated);
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
      Navigator.of(context).pop(newSchedule);
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
        Navigator.of(context).pop(existing);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            tooltip: _isAlertEnabled ? 'Alert Active' : 'Alert Muted',
            icon: Icon(
              _isAlertEnabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_outlined,
              color: _isAlertEnabled
                  ? const Color(0xFFFBBF24)
                  : AppColors.textMuted,
            ),
            onPressed: () {
              setState(() => _isAlertEnabled = !_isAlertEnabled);
              final categoryConfig =
                  UserProfileRepository().profile.teamMeetingAlerts;
              PopUpPemberitahuan.show(
                context,
                title: _isAlertEnabled ? 'Meeting Alert Active' : 'Meeting Alert Muted',
                message: _isAlertEnabled
                    ? 'Meeting alerts enabled (Following Profile: ${categoryConfig.summary}).'
                    : 'Alerts muted for this meeting.',
                icon: _isAlertEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_outlined,
                iconBgColor: _isAlertEnabled
                    ? const Color(0xFF10B981)
                    : const Color(0xFF475569),
              );
            },
          ),
          if (isEdit) ...[
            IconButton(
              key: const ValueKey('delete_meeting_button'),
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.primary),
              onPressed: _handleDelete,
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
                  // 1. Meeting Title
                  const Text(
                    'Meeting Name',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    key: const ValueKey('create_meeting_name_input'),
                    controller: _nameController,
                    hint: 'e.g. Weekly Standup Kelompok IMPAL',
                    prefixIcon: Icons.groups_rounded,
                  ),

                  // 2. Team Meeting Checkbox & Autocomplete
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

                  // 3. Location
                  const Text(
                    'Location',
                    style: TextStyle(
                      color: AppColors.textMuted,
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
                      color: AppColors.textMuted,
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
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 18),
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
                          const Icon(Icons.edit_calendar_rounded, color: AppColors.primary, size: 18),
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
                                color: AppColors.textMuted,
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
                                  color: AppColors.bgCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, color: AppColors.textMuted, size: 18),
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
                                color: AppColors.textMuted,
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
                                  color: AppColors.bgCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, color: AppColors.textMuted, size: 18),
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
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.repeat_rounded, color: AppColors.textMuted, size: 18),
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
                            activeThumbColor: AppColors.primary,
                            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
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
                      color: AppColors.textMuted,
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
                        backgroundColor: AppColors.primary,
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

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return TextField(
      key: key,
      controller: controller,
      maxLines: maxLines,
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
