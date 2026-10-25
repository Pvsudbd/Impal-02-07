import 'package:flutter/material.dart';
import 'models/schedule_model.dart';
import 'models/schedule_repository.dart';
import 'pop_up_make_schedule.dart';
import 'pop_up_konfirmasi_edit.dart';
import 'pop_up_konfirmasi_delete.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../../common_widgets/impal_time_picker_dialog.dart';
import '../../common_widgets/impal_date_picker_dialog.dart';

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
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'Lecture';
  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 30);
  bool _repeatWeekly = true;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      final s = widget.schedule!;
      _selectedType = s.type;
      _titleController.text = (s.type == 'Lecture' ? (s.course ?? s.title) : s.title);
      _locationController.text = s.location ?? '';
      _notesController.text = s.notes ?? '';
      _selectedDate = s.date;
      _repeatWeekly = s.repeat;
      _startTime = _parseTime(s.timeStart, const TimeOfDay(hour: 9, minute: 30));
      _endTime = _parseTime(s.timeEnd, const TimeOfDay(hour: 11, minute: 30));
    } else {
      _selectedType = widget.initialType ?? 'Lecture';
      _selectedDate = widget.initialDate ?? DateTime.now();
      _repeatWeekly = _selectedType == 'Lecture';
      _startTime = const TimeOfDay(hour: 9, minute: 30);
      _endTime = const TimeOfDay(hour: 11, minute: 30);
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
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
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
    final confirmed = await PopUpKonfirmasiDelete.show(context);
    if (confirmed != true) return;

    await ScheduleRepository().deleteSchedule(widget.schedule!.id);

    if (mounted) {
      PopUpPemberitahuan.scheduleDeleted(context);
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.isEdit;
    final enteredText = _titleController.text.trim();

    if (isEdit) {
      final confirmed = await PopUpKonfirmasiEdit.show(context);
      if (confirmed != true) return;

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
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : (_selectedType == 'Lecture' ? 'Classroom' : 'Online / Meeting'),
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
        PopUpPemberitahuan.scheduleUpdated(context);
        Navigator.of(context).pop(true);
      }
    } else {
      final confirmed = await PopUpMakeSchedule.show(context);
      if (confirmed != true) return;

      final scheduleDate = _selectedDate;

      final newSchedule = ScheduleModel(
        id: 'sch_${DateTime.now().millisecondsSinceEpoch}',
        title: enteredText,
        type: _selectedType,
        course: _selectedType == 'Lecture' ? enteredText : null,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : (_selectedType == 'Lecture' ? 'Classroom' : 'Online / Meeting'),
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
        PopUpPemberitahuan.scheduleCreated(context);
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;
    final isLecture = _selectedType == 'Lecture';

    return Scaffold(
      backgroundColor: const Color(0xFF282D37),
      appBar: AppBar(
        backgroundColor: const Color(0xFF282D37),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          isEdit ? 'Edit Schedule' : 'Add Schedule',
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
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFA6144)),
              tooltip: 'Delete Schedule',
              onPressed: _deleteSchedule,
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Schedule Type selector
                    const Text(
                      'Schedule Type',
                      style: TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeButton(
                            title: 'Lecture',
                            icon: Icons.school_rounded,
                            isSelected: isLecture,
                            onTap: () => setState(() => _selectedType = 'Lecture'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTypeButton(
                            title: 'External',
                            icon: Icons.event_rounded,
                            isSelected: !isLecture,
                            onTap: () => setState(() => _selectedType = 'External'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 2. Course (Lecture) / Schedule Title (External) field
                    Text(
                      isLecture ? 'Course' : 'Schedule Title',
                      style: const TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _titleController,
                      hint: isLecture
                          ? 'e.g. SSIF-04-REG • Software Testing & Implementation'
                          : 'e.g. Meet Impal Kelompok 7',
                      prefixIcon: isLecture ? Icons.school_outlined : Icons.menu_book_rounded,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? (isLecture ? 'Please enter course name' : 'Please enter schedule title')
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // 3. Room / Location
                    const Text(
                      'Location / Room',
                      style: TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _locationController,
                      hint: isLecture
                          ? 'e.g. KTT B-106 • SSIF-04-REG-GAB02'
                          : 'Location',
                      prefixIcon: Icons.location_on_rounded,
                    ),
                    const SizedBox(height: 16),

                    // 4. Date Picker (Always visible)
                    const Text(
                      'Date',
                      style: TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
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

                    // 5. Time Duration
                    const Text(
                      'Time Duration',
                      style: TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectStartTime,
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
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('-', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 18)),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: _selectEndTime,
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
                                    _formatTime(_endTime),
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 6. Repeat Weekly Switch
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

                    // 7. Notes (Optional)
                    const Text(
                      'Notes (Optional)',
                      style: TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFA6144),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submitForm,
                        child: Text(
                          isEdit ? 'Save Changes' : 'Create Schedule',
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
      ),
    );
  }

  Widget _buildTypeButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFA6144) : const Color(0xFF323846),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFA6144) : const Color(0xFF3B4150),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF8E95A5),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF8E95A5),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}


