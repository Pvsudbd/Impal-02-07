import 'package:flutter/material.dart';
import '../../../core/utils/top_toast.dart';
import 'models/schedule_model.dart';
import 'models/schedule_repository.dart';
import 'pop_up_konfirmasi_delete.dart';
import 'pop_up_konfirmasi_edit.dart';
import 'pop_up_schedule_deleted.dart';
import 'pop_up_schedule_updated.dart';

/// Aliases for backwards compatibility
typedef Edittask = EditTaskVar1;
typedef EditTask = EditTaskVar1;
typedef EditSchedule = EditTaskVar1;

/// Edit task screen (Variation 1)
class EditTaskVar1 extends StatelessWidget {
  final ScheduleModel? schedule;

  const EditTaskVar1({
    super.key,
    this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return EditTaskPage(schedule: schedule);
  }
}

/// Full interactive Edit Schedule page
class EditTaskPage extends StatefulWidget {
  final ScheduleModel? schedule;

  const EditTaskPage({
    super.key,
    this.schedule,
  });

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _courseController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;

  late String _selectedType;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _repeat;
  late String _scheduleId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final item = widget.schedule ??
        ScheduleRepository().schedules.firstOrNull ??
        ScheduleModel(
          id: 'sample_1',
          title: 'UBXCCB2 - BAHASA INDONESIA',
          type: 'Lecture',
          course: 'UBXCCB2 • BAHASA INDONESIA',
          location: 'KTT B-106 • SSIF-04-REG-GAB02',
          date: DateTime.now(),
          timeStart: '09:30',
          timeEnd: '11:30',
          notes: 'Tugas resume modul 7 penulisan daftar pustaka',
          repeat: true,
        );

    _scheduleId = item.id;
    _selectedType = item.type;
    _selectedDate = item.date;

    // Parse time
    final startParts = item.timeStart.split(':');
    final endParts = item.timeEnd.split(':');
    _startTime = TimeOfDay(
      hour: int.tryParse(startParts.firstOrNull ?? '9') ?? 9,
      minute: int.tryParse(startParts.length > 1 ? startParts[1] : '30') ?? 30,
    );
    _endTime = TimeOfDay(
      hour: int.tryParse(endParts.firstOrNull ?? '11') ?? 11,
      minute: int.tryParse(endParts.length > 1 ? endParts[1] : '30') ?? 30,
    );

    _repeat = item.repeat;

    _titleController = TextEditingController(text: item.title);
    _courseController = TextEditingController(text: item.course ?? '');
    _locationController = TextEditingController(text: item.location ?? '');
    _notesController = TextEditingController(text: item.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName ${dt.day} $monthName ${dt.year}';
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFA6144),
              onPrimary: Colors.white,
              surface: Color(0xFF282D37),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF282D37),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFA6144),
              onPrimary: Colors.white,
              surface: Color(0xFF282D37),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFA6144),
              onPrimary: Colors.white,
              surface: Color(0xFF282D37),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _handleUpdate() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      TopToast.show(
        context,
        message: 'Please enter a task title',
        type: ToastType.warning,
      );
      return;
    }

    final confirmed = await PopUpKonfirmasiEdit.show(context);
    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    final startHour = _startTime.hour.toString().padLeft(2, '0');
    final startMin = _startTime.minute.toString().padLeft(2, '0');
    final endHour = _endTime.hour.toString().padLeft(2, '0');
    final endMin = _endTime.minute.toString().padLeft(2, '0');

    final updated = ScheduleModel(
      id: _scheduleId,
      title: title,
      type: _selectedType,
      course: _selectedType == 'Lecture' ? _courseController.text.trim() : null,
      location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
      status: widget.schedule?.status ?? 'Upcoming',
      date: _selectedDate,
      timeStart: '$startHour:$startMin',
      timeEnd: '$endHour:$endMin',
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      repeat: _repeat,
    );

    await ScheduleRepository().updateSchedule(updated);

    if (mounted) {
      setState(() => _isSubmitting = false);
      await PopUpScheduleUpdated.show(
        context,
        title: 'Schedule Updated',
        message: 'Your schedule has been updated.\nSee your changes on your Schedule page.',
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await PopUpKonfirmasiDelete.show(context);
    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    await ScheduleRepository().deleteSchedule(_scheduleId);

    if (mounted) {
      setState(() => _isSubmitting = false);
      await PopUpScheduleDeleted.show(
        context,
        title: 'Schedule Deleted',
        message: 'Your schedule has been deleted.\nSee your changes on your Schedule page.',
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final content = Scaffold(
      backgroundColor: const Color(0xFF282D37),
      appBar: AppBar(
        backgroundColor: const Color(0xFF282D37),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
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
        actions: [
          IconButton(
            tooltip: 'Delete Schedule',
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFA6144), size: 22),
            onPressed: _isSubmitting ? null : _handleDelete,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 410),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF323846),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF3B4150), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 25,
                    offset: Offset(0, 15),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Schedule',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF282D37),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF3B4150), width: 1),
                          ),
                          child: Text(
                            widget.schedule?.status ?? 'Active',
                            style: const TextStyle(
                              color: Color(0xFFFF826E),
                              fontSize: 11,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Task Title
                    _buildLabel('Task Title'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _titleController,
                      hintText: 'e.g. Meet Impal Kelompok 7',
                    ),
                    const SizedBox(height: 16),

                    // Schedule Type
                    _buildLabel('Schedule Type'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeChip(
                            label: 'External',
                            isSelected: _selectedType == 'External',
                            onTap: () {
                              setState(() => _selectedType = 'External');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTypeChip(
                            label: 'Lecture',
                            isSelected: _selectedType == 'Lecture',
                            onTap: () {
                              setState(() => _selectedType = 'Lecture');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Course field (visible for Lecture)
                    if (_selectedType == 'Lecture') ...[
                      _buildLabel('Course / Mata Kuliah'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _courseController,
                        hintText: 'SSIF-04-REG • Software Testing & Implementation',
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Location / Room
                    _buildLabel('Location / Room'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _locationController,
                      hintText: _selectedType == 'Lecture'
                          ? 'KTT B-106 • SSIF-04-REG-GAB02'
                          : 'Google Meet / Discord / Offline',
                    ),
                    const SizedBox(height: 16),

                    // Date & Repeat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('Date'),
                        GestureDetector(
                          onTap: () => setState(() => _repeat = !_repeat),
                          child: Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: _repeat ? const Color(0xFFFA6144) : const Color(0xFF282D37),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _repeat ? const Color(0xFFFA6144) : const Color(0xFF3B4150),
                                    width: 1.5,
                                  ),
                                ),
                                child: _repeat
                                    ? const Icon(Icons.check, color: Colors.white, size: 13)
                                    : null,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Repeat weekly',
                                style: TextStyle(
                                  color: Color(0xFFD1D5DB),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF282D37),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF3B4150), width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xFF8E95A5),
                              size: 16,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _formatDate(_selectedDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF8E95A5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time Start - End
                    _buildLabel('Time Start - End'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _pickStartTime,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF282D37),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF3B4150), width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    color: Color(0xFF8E95A5),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatTimeOfDay(_startTime),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: _pickEndTime,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF282D37),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF3B4150), width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    color: Color(0xFF8E95A5),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatTimeOfDay(_endTime),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notes & Instructions
                    _buildLabel('Notes & Instructions'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF282D37),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF3B4150), width: 1),
                      ),
                      child: TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Add assignment details, room links, or topics here...',
                          hintStyle: TextStyle(color: Color(0xFF757575), fontSize: 13),
                          contentPadding: EdgeInsets.all(12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons: Edit and Delete
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFA6144),
                                elevation: 6,
                                shadowColor: const Color(0x77FA6144),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isSubmitting ? null : _handleUpdate,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Edit Schedule',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFA6144), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onPressed: _isSubmitting ? null : _handleDelete,
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFFA6144),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (isMobile) {
      return content;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E222B),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 410,
                maxHeight: 844,
              ),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF282D37),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x8C000000),
                      blurRadius: 40,
                      offset: Offset(0, 20),
                      spreadRadius: -6,
                    ),
                  ],
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFD1D5DB),
        fontSize: 12,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF282D37),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3B4150), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF757575), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTypeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFA6144) : const Color(0xFF282D37),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFA6144) : const Color(0xFF3B4150),
            width: 1,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x44FA6144),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}