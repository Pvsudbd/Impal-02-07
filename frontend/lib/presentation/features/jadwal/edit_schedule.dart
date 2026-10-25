import 'package:flutter/material.dart';
import 'models/schedule_model.dart';
import 'models/schedule_repository.dart';
import 'pop_up_konfirmasi_edit.dart';
import 'pop_up_konfirmasi_delete.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../../common_widgets/impal_time_picker_dialog.dart';
import '../../common_widgets/impal_date_picker_dialog.dart';

/// Aliases for backwards compatibility
typedef EditScheduleVar1 = EditSchedule;
typedef EditScheduleVar2 = EditSchedule;
typedef EditTask = EditSchedule;
typedef EditTaskVar1 = EditSchedule;
typedef EditTaskVar2 = EditSchedule;
typedef Edittask = EditSchedule;
typedef EdittaskVar2 = EditSchedule;

/// Unified screen for editing an existing schedule (combining Variation 1 & 2)
class EditSchedule extends StatefulWidget {
  final ScheduleModel schedule;

  const EditSchedule({
    super.key,
    required this.schedule,
  });

  @override
  State<EditSchedule> createState() => _EditScheduleState();
}

class _EditScheduleState extends State<EditSchedule> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _courseController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  late String _selectedType;
  late String _selectedStatus;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _repeatWeekly;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    _titleController = TextEditingController(text: s.title);
    _courseController = TextEditingController(text: s.course ?? s.title);
    _locationController = TextEditingController(text: s.location ?? '');
    _notesController = TextEditingController(text: s.notes ?? '');

    _selectedType = s.type;
    _selectedStatus = s.status;
    _selectedDate = s.date;
    _repeatWeekly = s.repeat;

    _startTime = _parseTime(s.timeStart, const TimeOfDay(hour: 9, minute: 30));
    _endTime = _parseTime(s.timeEnd, const TimeOfDay(hour: 11, minute: 30));
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
    _courseController.dispose();
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
    final months = [
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await PopUpKonfirmasiEdit.show(context);
    if (confirmed != true) return;

    final updated = widget.schedule.copyWith(
      title: _titleController.text.trim(),
      type: _selectedType,
      status: _selectedStatus,
      course: _selectedType == 'Lecture' && _courseController.text.trim().isNotEmpty
          ? _courseController.text.trim()
          : (_courseController.text.trim().isNotEmpty
              ? _courseController.text.trim()
              : _titleController.text.trim()),
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : 'Classroom',
      date: _selectedDate,
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
  }

  Future<void> _deleteSchedule() async {
    final confirmed = await PopUpKonfirmasiDelete.show(context);
    if (confirmed != true) return;

    await ScheduleRepository().deleteSchedule(widget.schedule.id);

    if (mounted) {
      PopUpPemberitahuan.scheduleDeleted(context);
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282D37),
      appBar: AppBar(
        backgroundColor: const Color(0xFF282D37),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Edit Schedule',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFA6144)),
            tooltip: 'Delete Schedule',
            onPressed: _deleteSchedule,
          ),
          const SizedBox(width: 8),
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
                    // Status selector
                    const Text(
                      'Status',
                      style: TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusChip('Ongoing', const Color(0xFFFF826E)),
                        const SizedBox(width: 10),
                        _buildStatusChip('Upcoming', const Color(0xFF8E95A5)),
                        const SizedBox(width: 10),
                        _buildStatusChip('Completed', const Color(0xFF10B981)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Type
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
                            isSelected: _selectedType == 'Lecture',
                            onTap: () => setState(() => _selectedType = 'Lecture'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTypeButton(
                            title: 'External',
                            icon: Icons.event_rounded,
                            isSelected: _selectedType == 'External',
                            onTap: () => setState(() => _selectedType = 'External'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    const Text(
                      'Schedule Title',
                      style: TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'Title',
                      prefixIcon: Icons.menu_book_rounded,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Please enter title'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Course field (combining Variation 2 dynamically)
                    if (_selectedType == 'Lecture') ...[
                      const Text(
                        'Course',
                        style: TextStyle(
                          color: Color(0xFF8E95A5),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _courseController,
                        hint: 'e.g. SSIF-04-REG • Software Testing & Implementation',
                        prefixIcon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Location
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
                      hint: 'Location',
                      prefixIcon: Icons.location_on_rounded,
                    ),
                    const SizedBox(height: 16),

                    // Date
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                const SizedBox(width: 12),
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

                    // Time Duration
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
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

                    // Repeat weekly
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                              Icon(Icons.repeat_rounded, color: Color(0xFF8E95A5), size: 20),
                              SizedBox(width: 12),
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
                          Switch(
                            value: _repeatWeekly,
                            activeThumbColor: const Color(0xFFFA6144),
                            activeTrackColor: const Color(0xFFFA6144).withValues(alpha: 0.5),
                            onChanged: (val) => setState(() => _repeatWeekly = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    const Text(
                      'Notes',
                      style: TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _notesController,
                      hint: 'Add reminders, notes, or details...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
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
                        onPressed: _saveChanges,
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
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

  Widget _buildStatusChip(String label, Color color) {
    final isSelected = _selectedStatus.toLowerCase() == label.toLowerCase();
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : const Color(0xFF323846),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF3B4150),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : const Color(0xFF8E95A5),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
        padding: const EdgeInsets.symmetric(vertical: 12),
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
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFF323846),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF8E95A5), size: 18)
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
}
