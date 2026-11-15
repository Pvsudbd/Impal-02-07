import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../models/schedule_model.dart';
import '../../models/schedule_repository.dart';
import '../../schedule_form_page.dart';
import 'desktop_schedule_control_bar.dart';
import 'desktop_schedule_kpi_row.dart';
import 'desktop_schedule_matrix_card.dart';
import 'desktop_schedule_matrix_table.dart';

/// Desktop Weekly Schedule Matrix workspace matching FigCraft
/// `Desktop - Schedule Matrix (Weekly)` (node 2537, 1440x980).
class DesktopScheduleMatrixView extends StatefulWidget {
  final String searchQuery;

  const DesktopScheduleMatrixView({
    super.key,
    this.searchQuery = '',
  });

  @override
  State<DesktopScheduleMatrixView> createState() =>
      _DesktopScheduleMatrixViewState();
}

class _DesktopScheduleMatrixViewState extends State<DesktopScheduleMatrixView> {
  final ScheduleRepository _repo = ScheduleRepository();

  String _selectedView = 'Week';
  int _weekOffset = 0;
  ScheduleMatrixCategory? _selectedCategory;

  static final DateTime _baseWeekStart = DateTime(2026, 10, 12);

  static const List<String> _dayNamesId = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  static const List<String> _monthNamesId = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<ScheduleMatrixTimeSlot> _timeSlots = [
    ScheduleMatrixTimeSlot(startLabel: '08:00', endLabel: '09:30 WIB'),
    ScheduleMatrixTimeSlot(startLabel: '09:30', endLabel: '11:30 WIB'),
    ScheduleMatrixTimeSlot(startLabel: '11:30', endLabel: '13:30 WIB'),
    ScheduleMatrixTimeSlot(startLabel: '13:30', endLabel: '15:30 WIB'),
    ScheduleMatrixTimeSlot(startLabel: '15:30', endLabel: '17:30 WIB'),
    ScheduleMatrixTimeSlot(startLabel: '19:00', endLabel: '20:30 WIB'),
  ];

  /// Exact 13 weekly matrix items matching FigCraft `Desktop - Schedule Matrix (Weekly)` (node 2537).
  static const List<ScheduleMatrixItem> _figcraftBaseItems = [
    // Row 0: 08:00 - 09:30
    ScheduleMatrixItem(
      id: 'mtx_alpro_data',
      title: 'ALPRO & DATA',
      subtitle: 'KU1.02.04 • SIF-45',
      timeRange: '08:00 - 09:30 WIB',
      dayIndex: 4,
      slotIndex: 0,
      badgeLabel: 'Code',
      category: ScheduleMatrixCategory.kuliah,
    ),
    // Row 1: 09:30 - 11:30
    ScheduleMatrixItem(
      id: 'mtx_b_indo_ongoing',
      title: 'UBXCCB2 - B. INDONESIA',
      subtitle: 'KTT B-106 • SSIF-04-REG-GAB02',
      timeRange: '09:30 - 11:30 WIB',
      dayIndex: 0,
      slotIndex: 1,
      badgeLabel: 'Ongoing',
      category: ScheduleMatrixCategory.ongoing,
      isOngoing: true,
    ),
    ScheduleMatrixItem(
      id: 'mtx_pengujian_pl',
      title: 'PENGUJIAN PL',
      subtitle: 'KTT B-204 • SSIF-04',
      timeRange: '09:30 - 11:30 WIB',
      dayIndex: 1,
      slotIndex: 1,
      badgeLabel: 'Testing',
      category: ScheduleMatrixCategory.kuliah,
    ),
    ScheduleMatrixItem(
      id: 'mtx_kecerdasan_ai',
      title: 'KECERDASAN AI',
      subtitle: 'KU2.01.08 • SIF-45',
      timeRange: '09:30 - 11:30 WIB',
      dayIndex: 2,
      slotIndex: 1,
      badgeLabel: 'Kuliah',
      category: ScheduleMatrixCategory.kuliah,
    ),
    ScheduleMatrixItem(
      id: 'mtx_b_indo_kamis',
      title: 'B. INDONESIA',
      subtitle: 'KTT B-106 • SSIF-04',
      timeRange: '09:30 - 11:30 WIB',
      dayIndex: 3,
      slotIndex: 1,
      badgeLabel: 'Kuliah',
      category: ScheduleMatrixCategory.kuliah,
    ),
    ScheduleMatrixItem(
      id: 'mtx_sprint_review',
      title: 'SPRINT REVIEW',
      subtitle: 'Google Meet • Tim',
      timeRange: '10:00 - 11:30 WIB',
      dayIndex: 5,
      slotIndex: 1,
      badgeLabel: 'Kelompok',
      category: ScheduleMatrixCategory.kelompok,
    ),
    // Row 2: 11:30 - 13:30
    ScheduleMatrixItem(
      id: 'mtx_mentoring',
      title: 'MENTORING',
      subtitle: 'Ruang Dosen KU1',
      timeRange: '11:30 - 12:30 WIB',
      dayIndex: 2,
      slotIndex: 2,
      badgeLabel: 'Personal',
      category: ScheduleMatrixCategory.studyLab,
    ),
    // Row 3: 13:30 - 15:30
    ScheduleMatrixItem(
      id: 'mtx_rekayasa_pl',
      title: 'REKAYASA PL',
      subtitle: 'KU3.03.12 • SIF-45',
      timeRange: '13:30 - 15:30 WIB',
      dayIndex: 0,
      slotIndex: 3,
      badgeLabel: 'Kuliah',
      category: ScheduleMatrixCategory.kuliah,
    ),
    ScheduleMatrixItem(
      id: 'mtx_responsi_impal',
      title: 'RESPONSI IMPAL',
      subtitle: 'Lab RPL • Testing',
      timeRange: '13:30 - 15:30 WIB',
      dayIndex: 4,
      slotIndex: 3,
      badgeLabel: 'Testing',
      category: ScheduleMatrixCategory.kuliah,
    ),
    // Row 4: 15:30 - 17:30
    ScheduleMatrixItem(
      id: 'mtx_ai_study_hub',
      title: 'AI STUDY HUB',
      subtitle: 'Lab Cloud KU2',
      timeRange: '15:30 - 17:30 WIB',
      dayIndex: 2,
      slotIndex: 4,
      badgeLabel: 'Study',
      category: ScheduleMatrixCategory.studyLab,
    ),
    ScheduleMatrixItem(
      id: 'mtx_ui_ux_design',
      title: 'UI/UX DESIGN',
      subtitle: 'Lab TULT 03 • Desain',
      timeRange: '15:30 - 17:30 WIB',
      dayIndex: 3,
      slotIndex: 4,
      badgeLabel: 'Figma',
      category: ScheduleMatrixCategory.studyLab,
    ),
    // Row 5: 19:00 - 20:30
    ScheduleMatrixItem(
      id: 'mtx_meeting_impal',
      title: 'MEETING IMPAL',
      subtitle: 'Discord • Group IMPAL',
      timeRange: '19:00 - 20:30 WIB',
      dayIndex: 1,
      slotIndex: 5,
      badgeLabel: 'Kelompok',
      category: ScheduleMatrixCategory.kelompok,
    ),
    ScheduleMatrixItem(
      id: 'mtx_sync_laporan',
      title: 'SYNC LAPORAN',
      subtitle: 'Google Meet • Review',
      timeRange: '19:30 - 21:00 WIB',
      dayIndex: 3,
      slotIndex: 5,
      badgeLabel: 'Kelompok',
      category: ScheduleMatrixCategory.kelompok,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _repo.init();
  }

  DateTime get _activeWeekStart =>
      _baseWeekStart.add(Duration(days: _weekOffset * 7));

  String get _weekRangeLabel {
    final start = _activeWeekStart;
    final end = start.add(const Duration(days: 6));
    final startMonth = _monthNamesId[start.month - 1];
    final endMonth = _monthNamesId[end.month - 1];
    if (start.year == end.year) {
      return '${start.day} $startMonth – ${end.day} $endMonth ${end.year}';
    }
    return '${start.day} $startMonth ${start.year} – ${end.day} $endMonth ${end.year}';
  }

  String get _academicWeekLabel {
    final weekNumber = 8 + _weekOffset;
    final semester = weekNumber <= 16 ? 'Ganjil' : 'Genap';
    return 'Minggu $weekNumber • $semester';
  }

  List<ScheduleMatrixDayHeader> get _dayHeaders {
    final start = _activeWeekStart;
    return List.generate(6, (i) {
      final date = start.add(Duration(days: i));
      final month = _monthNamesId[date.month - 1];
      return ScheduleMatrixDayHeader(
        label: '${_dayNamesId[i]}, ${date.day} $month',
        isToday: _weekOffset == 0 && i == 0,
      );
    });
  }

  List<ScheduleMatrixItem> _buildAllItems(List<ScheduleModel> repoSchedules) {
    final items = List<ScheduleMatrixItem>.from(_figcraftBaseItems);
    final weekStart = DateTime(
      _activeWeekStart.year,
      _activeWeekStart.month,
      _activeWeekStart.day,
    );
    final weekEnd = weekStart.add(const Duration(days: 6));

    for (final s in repoSchedules) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      if (d.isBefore(weekStart) || d.isAfter(weekEnd)) continue;
      final dayIdx = d.weekday - 1; // Monday = 0 .. Saturday = 5
      if (dayIdx < 0 || dayIdx > 5) continue;

      final slotIdx = _mapTimeToSlotIndex(s.timeStart);
      final alreadyOccupied = items.any(
        (existing) =>
            existing.dayIndex == dayIdx && existing.slotIndex == slotIdx,
      );
      if (alreadyOccupied) continue;

      final isOngoing = s.status.toLowerCase() == 'ongoing';
      final isMeeting = s.type.toLowerCase() == 'meeting';
      final isExternal = s.type.toLowerCase() == 'external';

      items.add(
        ScheduleMatrixItem(
          id: 'repo_${s.id}',
          title: s.title.toUpperCase(),
          subtitle: s.location ?? s.course ?? 'Classroom',
          timeRange: s.formattedTime,
          dayIndex: dayIdx,
          slotIndex: slotIdx,
          badgeLabel: isOngoing
              ? 'Ongoing'
              : (isMeeting ? 'Kelompok' : (isExternal ? 'Study' : 'Kuliah')),
          category: isOngoing
              ? ScheduleMatrixCategory.ongoing
              : (isMeeting
                  ? ScheduleMatrixCategory.kelompok
                  : (isExternal
                      ? ScheduleMatrixCategory.studyLab
                      : ScheduleMatrixCategory.kuliah)),
          isOngoing: isOngoing,
          linkedSchedule: s,
        ),
      );
    }
    return items;
  }

  int _mapTimeToSlotIndex(String timeStart) {
    final parts = timeStart.trim().split(':');
    final h = int.tryParse(parts.first) ?? 9;
    if (h < 9) return 0;
    if (h < 11) return 1;
    if (h < 13) return 2;
    if (h < 15) return 3;
    if (h < 18) return 4;
    return 5;
  }

  List<ScheduleMatrixItem> _filterItems(List<ScheduleMatrixItem> source) {
    var list = source;
    if (_selectedCategory != null) {
      list = list.where((item) {
        if (_selectedCategory == ScheduleMatrixCategory.ongoing) {
          return item.isOngoing ||
              item.category == ScheduleMatrixCategory.ongoing;
        }
        return item.category == _selectedCategory;
      }).toList();
    }

    final q = widget.searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((item) {
        return item.title.toLowerCase().contains(q) ||
            item.subtitle.toLowerCase().contains(q) ||
            item.badgeLabel.toLowerCase().contains(q) ||
            item.timeRange.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  Future<void> _openCardSchedule(ScheduleMatrixItem item) async {
    final start = _activeWeekStart.add(Duration(days: item.dayIndex));
    final times = item.timeRange.replaceAll(' WIB', '').split(' - ');
    final timeStart = times.isNotEmpty ? times[0].trim() : '09:30';
    final timeEnd = times.length > 1 ? times[1].trim() : '11:30';

    final model = item.linkedSchedule ??
        ScheduleModel(
          id: item.id,
          title: item.title,
          type: item.category == ScheduleMatrixCategory.kelompok
              ? 'Meeting'
              : (item.category == ScheduleMatrixCategory.studyLab
                  ? 'External'
                  : 'Lecture'),
          course: item.title,
          location: item.subtitle,
          date: start,
          timeStart: timeStart,
          timeEnd: timeEnd,
        );

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ScheduleFormPage(schedule: model),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPad = context.screenWidth >= 1200 ? 32.0 : context.rSpacing(24);

    return ValueListenableBuilder<List<ScheduleModel>>(
      valueListenable: _repo.schedulesNotifier,
      builder: (context, repoSchedules, _) {
        final allItems = _buildAllItems(repoSchedules);
        final filteredItems = _filterItems(allItems);

        return SingleChildScrollView(
          key: const ValueKey('desktop_schedule_matrix_scroll'),
          padding: EdgeInsets.fromLTRB(horizontalPad, 16, horizontalPad, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DesktopScheduleControlBar(
                selectedView: _selectedView,
                weekRangeLabel: _weekRangeLabel,
                academicWeekLabel: _academicWeekLabel,
                selectedCategory: _selectedCategory,
                onViewChanged: (view) {
                  setState(() {
                    _selectedView = view;
                    if (view == 'Today') {
                      _weekOffset = 0;
                    }
                  });
                },
                onPreviousWeek: () => setState(() => _weekOffset--),
                onNextWeek: () => setState(() => _weekOffset++),
                onTodayPressed: () => setState(() {
                  _weekOffset = 0;
                  _selectedView = 'Week';
                }),
                onCategorySelected: (cat) =>
                    setState(() => _selectedCategory = cat),
              ),
              const SizedBox(height: 14),
              const DesktopScheduleKpiRow(
                totalSessionsCount: 14,
                todayClassesCount: 2,
                ongoingCount: 1,
                teamMeetingsCount: 4,
                studyHoursCount: 28,
                activeSksCount: 18,
              ),
              const SizedBox(height: 14),
              DesktopScheduleMatrixTable(
                dayHeaders: _dayHeaders,
                timeSlots: _timeSlots,
                items: filteredItems,
                focusedDayIndex: _selectedView == 'Today' ? 0 : null,
                onCardTap: _openCardSchedule,
              ),
            ],
          ),
        );
      },
    );
  }
}

