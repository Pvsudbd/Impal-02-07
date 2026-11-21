import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../../team/pop_up_create_meeting.dart';
import '../../models/schedule_model.dart';
import '../../models/schedule_repository.dart';
import '../../pop_up_konfirmasi_delete.dart';
import 'desktop_schedule_control_bar.dart';
import 'desktop_schedule_kpi_row.dart';
import 'desktop_schedule_matrix_card.dart';
import 'desktop_schedule_matrix_table.dart';
import 'desktop_schedule_modal.dart';

/// Desktop Weekly Schedule Matrix workspace matching FigCraft
/// `Desktop - Schedule Matrix (Weekly)` (node 2537, 1440x980) with full mobile parity:
/// alert toggling, delete confirmation + UNDO, multi-schedule slot support,
/// and All/Month full directory view.
class DesktopScheduleMatrixView extends StatefulWidget {
  final String searchQuery;
  final VoidCallback? onResetSearch;

  const DesktopScheduleMatrixView({
    super.key,
    this.searchQuery = '',
    this.onResetSearch,
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

  final Set<String> _deletedBaseIds = <String>{};
  final Set<String> _mutedBaseIds = <String>{};

  static const Set<String> _defaultRepoIds = {
    'sch_1',
    'sch_2',
    'sch_3',
    'sch_4',
    'sch_5',
  };

  static final DateTime _baseWeekStart = DateTime(2026, 10, 12);

  static const List<String> _dayShortEn = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _monthNamesEn = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<ScheduleMatrixTimeSlot> _timeSlots = [
    ScheduleMatrixTimeSlot(startLabel: '08:00', endLabel: '09:30 WIB'),
    ScheduleMatrixTimeSlot(startLabel: '09:30', endLabel: '11:30 WIB'),
    ScheduleMatrixTimeSlot(startLabel: '11:30', endLabel: '13:30 WIB'),
    ScheduleMatrixTimeSlot(startLabel: '13:30', endLabel: '15:30 WIB'),
    ScheduleMatrixTimeSlot(startLabel: '15:30', endLabel: '17:30 WIB'),
    ScheduleMatrixTimeSlot(startLabel: '19:00', endLabel: '20:30 WIB'),
  ];

  /// Exact 14 weekly matrix items matching FigCraft `Desktop - Schedule Matrix (Weekly)` (node 2739).
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
      badgeLabel: 'Lecture',
      category: ScheduleMatrixCategory.kuliah,
    ),
    ScheduleMatrixItem(
      id: 'mtx_b_indo_kamis',
      title: 'B. INDONESIA',
      subtitle: 'KTT B-106 • SSIF-04',
      timeRange: '09:30 - 11:30 WIB',
      dayIndex: 3,
      slotIndex: 1,
      badgeLabel: 'Lecture',
      category: ScheduleMatrixCategory.kuliah,
    ),
    ScheduleMatrixItem(
      id: 'mtx_sprint_review',
      title: 'SPRINT REVIEW',
      subtitle: 'Google Meet • Tim',
      timeRange: '10:00 - 11:30 WIB',
      dayIndex: 5,
      slotIndex: 1,
      badgeLabel: 'Team',
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
      badgeLabel: 'Lecture',
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
      badgeLabel: 'Team',
      category: ScheduleMatrixCategory.kelompok,
    ),
    ScheduleMatrixItem(
      id: 'mtx_sync_laporan',
      title: 'SYNC LAPORAN',
      subtitle: 'Google Meet • Review',
      timeRange: '19:30 - 21:00 WIB',
      dayIndex: 3,
      slotIndex: 5,
      badgeLabel: 'Team',
      category: ScheduleMatrixCategory.kelompok,
    ),
    ScheduleMatrixItem(
      id: 'mtx_sprint_prep',
      title: 'SPRINT 1 PREP',
      subtitle: 'Discord • Team IMPAL',
      timeRange: '19:00 - 20:30 WIB',
      dayIndex: 6,
      slotIndex: 5,
      badgeLabel: 'Team',
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
    final startMonth = _monthNamesEn[start.month - 1];
    final endMonth = _monthNamesEn[end.month - 1];
    if (start.year == end.year) {
      return '$startMonth ${start.day} – $endMonth ${end.day}, ${end.year}';
    }
    return '$startMonth ${start.day}, ${start.year} – $endMonth ${end.day}, ${end.year}';
  }

  String get _academicWeekLabel {
    final weekNumber = (8 + _weekOffset).clamp(1, 32);
    final semester = weekNumber <= 16 ? 'Odd Sem' : 'Even Sem';
    return 'Week $weekNumber • $semester';
  }

  List<ScheduleMatrixDayHeader> _dayHeadersFor(List<ScheduleMatrixItem> items) {
    final start = _activeWeekStart;
    return List.generate(7, (i) {
      final date = start.add(Duration(days: i));
      final month = _monthNamesEn[date.month - 1];
      return ScheduleMatrixDayHeader(
        label: '${_dayShortEn[i]}, $month ${date.day}',
        isToday: _weekOffset == 0 && i == 0,
      );
    });
  }

  List<ScheduleMatrixItem> _buildAllItems(List<ScheduleModel> repoSchedules) {
    final items = _figcraftBaseItems
        .where((item) => !_deletedBaseIds.contains(item.id))
        .map(
          (item) => item.copyWith(
            isAlertEnabled: !_mutedBaseIds.contains(item.id),
          ),
        )
        .toList();

    final weekStart = DateTime(
      _activeWeekStart.year,
      _activeWeekStart.month,
      _activeWeekStart.day,
    );
    final weekEnd = weekStart.add(const Duration(days: 6));

    for (final s in repoSchedules) {
      if (_defaultRepoIds.contains(s.id) ||
          s.id == 'mock_ongoing_impal' ||
          s.id == 'mock_upcoming_Basdat') {
        continue;
      }
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      if (_selectedView == 'Week' || _selectedView == 'Today') {
        if (d.isBefore(weekStart) || d.isAfter(weekEnd)) continue;
      }
      final dayIdx = d.weekday - 1; // Monday = 0 .. Sunday = 6
      if (dayIdx < 0 || dayIdx > 6) continue;

      final slotIdx = _mapTimeToSlotIndex(s.timeStart);
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
              : (isMeeting ? 'Team' : (isExternal ? 'Study' : 'Lecture')),
          category: isOngoing
              ? ScheduleMatrixCategory.ongoing
              : (isMeeting
                  ? ScheduleMatrixCategory.kelompok
                  : (isExternal
                      ? ScheduleMatrixCategory.studyLab
                      : ScheduleMatrixCategory.kuliah)),
          isOngoing: isOngoing,
          notes: s.notes,
          teamName: s.teamName,
          statusLabel: s.status,
          isAlertEnabled: s.isAlertEnabled,
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
            item.timeRange.toLowerCase().contains(q) ||
            (item.notes?.toLowerCase().contains(q) ?? false);
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
          isAlertEnabled: item.isAlertEnabled,
        );

    await _openScheduleModelEditor(model);
  }

  Future<void> _openScheduleModelEditor(ScheduleModel model) async {
    if (model.type.trim().toLowerCase() == 'meeting') {
      await PopUpCreateMeeting.showEdit(context, existingSchedule: model);
    } else {
      await DesktopScheduleModal.show(context, schedule: model);
    }
  }

  Future<void> _handleDeleteItem(ScheduleMatrixItem item) async {
    final isMeeting = item.category == ScheduleMatrixCategory.kelompok ||
        (item.linkedSchedule?.type.trim().toLowerCase() == 'meeting');
    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: isMeeting ? 'Delete Meeting?' : 'Delete Schedule?',
      message:
          'Are you sure you want to delete "${item.title}"? This action cannot be undone.',
    );
    if (confirmed != true || !mounted) return;

    final linked = item.linkedSchedule;
    if (linked != null && _repo.getById(linked.id) != null) {
      await _repo.deleteSchedule(linked.id);
      if (!mounted) return;
      _showDeleteFeedbackAndUndo(
        isMeeting: isMeeting,
        onUndo: () => _repo.addSchedule(linked),
      );
      return;
    }

    setState(() => _deletedBaseIds.add(item.id));
    _showDeleteFeedbackAndUndo(
      isMeeting: isMeeting,
      onUndo: () {
        if (mounted) {
          setState(() => _deletedBaseIds.remove(item.id));
        }
      },
    );
  }

  Future<void> _handleDeleteRepoModel(ScheduleModel model) async {
    final isMeeting = model.type.trim().toLowerCase() == 'meeting';
    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: isMeeting ? 'Delete Meeting?' : 'Delete Schedule?',
      message:
          'Are you sure you want to delete "${model.title}"? This action cannot be undone.',
    );
    if (confirmed != true || !mounted) return;

    await _repo.deleteSchedule(model.id);
    if (!mounted) return;
    _showDeleteFeedbackAndUndo(
      isMeeting: isMeeting,
      onUndo: () => _repo.addSchedule(model),
    );
  }

  void _showDeleteFeedbackAndUndo({
    required bool isMeeting,
    required VoidCallback onUndo,
  }) {
    if (isMeeting) {
      PopUpPemberitahuan.meetingDeleted(context);
    } else {
      PopUpPemberitahuan.scheduleDeleted(context);
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(
            isMeeting ? 'Meeting deleted' : 'Schedule deleted',
            style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
          ),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.primaryAccent,
            onPressed: onUndo,
          ),
        ),
      );
    }
  }

  Future<void> _handleToggleAlertItem(ScheduleMatrixItem item) async {
    final linked = item.linkedSchedule;
    if (linked != null && _repo.getById(linked.id) != null) {
      await _toggleRepoModelAlert(linked);
      return;
    }

    final bool isNowActive = _mutedBaseIds.contains(item.id);
    setState(() {
      if (isNowActive) {
        _mutedBaseIds.remove(item.id);
      } else {
        _mutedBaseIds.add(item.id);
      }
    });

    PopUpPemberitahuan.show(
      context,
      title: isNowActive ? 'Schedule Alert Active' : 'Schedule Alert Muted',
      message: isNowActive
          ? 'Reminders enabled for "${item.title}".'
          : 'Reminders muted for "${item.title}".',
      icon: isNowActive
          ? Icons.notifications_active_rounded
          : Icons.notifications_off_outlined,
      iconBgColor: isNowActive
          ? PopUpPemberitahuan.positiveColor
          : PopUpPemberitahuan.neutralColor,
    );
  }

  Future<void> _toggleRepoModelAlert(ScheduleModel model) async {
    final updated = model.copyWith(isAlertEnabled: !model.isAlertEnabled);
    await _repo.updateSchedule(updated);
    if (!mounted) return;
    PopUpPemberitahuan.show(
      context,
      title: updated.isAlertEnabled
          ? 'Schedule Alert Active'
          : 'Schedule Alert Muted',
      message: updated.isAlertEnabled
          ? 'Reminders enabled for "${updated.title}".'
          : 'Reminders muted for "${updated.title}".',
      icon: updated.isAlertEnabled
          ? Icons.notifications_active_rounded
          : Icons.notifications_off_outlined,
      iconBgColor: updated.isAlertEnabled
          ? PopUpPemberitahuan.positiveColor
          : PopUpPemberitahuan.neutralColor,
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

        final addedRepo = repoSchedules
            .where((s) => !_defaultRepoIds.contains(s.id))
            .toList();
        final deletedDefaultRepoCount = _defaultRepoIds
            .where((id) => !repoSchedules.any((s) => s.id == id))
            .length;
        final deletedBaseItems = _figcraftBaseItems
            .where((i) => _deletedBaseIds.contains(i.id))
            .toList();
        final deletedTeamCount = deletedBaseItems
            .where((i) => i.category == ScheduleMatrixCategory.kelompok)
            .length;
        final deletedOngoingCount =
            deletedBaseItems.where((i) => i.isOngoing).length;
        final deletedTodayCount =
            deletedBaseItems.where((i) => i.dayIndex == 0).length;
        final addedTeamCount = addedRepo
            .where((s) => s.type.toLowerCase() == 'meeting')
            .length;
        final addedOngoingCount = addedRepo
            .where((s) => s.status.toLowerCase() == 'ongoing')
            .length;

        final totalSessions = (15 -
                _deletedBaseIds.length -
                deletedDefaultRepoCount +
                addedRepo.length)
            .clamp(0, 999);
        final todayClasses = (2 - deletedTodayCount).clamp(0, 99);
        final ongoingCount =
            (1 - deletedOngoingCount + addedOngoingCount).clamp(0, 99);
        final teamMeetings =
            (5 - deletedTeamCount + addedTeamCount).clamp(0, 99);
        final studyHours = (totalSessions * 2).clamp(0, 999);

        final showDirectory =
            _selectedView == 'All' || _selectedView == 'Month';

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
              DesktopScheduleKpiRow(
                totalSessionsCount: totalSessions,
                todayClassesCount: todayClasses,
                ongoingCount: ongoingCount,
                teamMeetingsCount: teamMeetings,
                studyHoursCount: studyHours,
                activeSksCount: 18,
              ),
              const SizedBox(height: 14),
              if (widget.searchQuery.trim().isNotEmpty && filteredItems.isEmpty)
                _buildEmptySearchBanner()
              else
                DesktopScheduleMatrixTable(
                  dayHeaders: _dayHeadersFor(filteredItems),
                  timeSlots: _timeSlots,
                  items: filteredItems,
                  focusedDayIndex: _selectedView == 'Today' ? 0 : null,
                  onCardTap: _openCardSchedule,
                  onDeleteCard: _handleDeleteItem,
                  onToggleAlertCard: _handleToggleAlertItem,
                ),
              if (showDirectory) ...[
                const SizedBox(height: 20),
                _buildScheduleDirectorySection(repoSchedules),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptySearchBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_busy_rounded,
            size: 32,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 10),
          Text(
            'No schedules match "${widget.searchQuery.trim()}"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try searching another course, room, or reset the search query.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          if (widget.onResetSearch != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              key: const ValueKey('desktop_schedule_clear_search_btn'),
              onPressed: widget.onResetSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Clear Search',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleDirectorySection(List<ScheduleModel> repoSchedules) {
    final q = widget.searchQuery.trim().toLowerCase();
    final filteredRepo = repoSchedules.where((s) {
      if (_selectedCategory != null) {
        final isOngoing = s.status.toLowerCase() == 'ongoing';
        final isMeeting = s.type.toLowerCase() == 'meeting';
        final isExternal = s.type.toLowerCase() == 'external';
        switch (_selectedCategory!) {
          case ScheduleMatrixCategory.ongoing:
            if (!isOngoing) return false;
          case ScheduleMatrixCategory.kelompok:
            if (!isMeeting) return false;
          case ScheduleMatrixCategory.studyLab:
            if (!isExternal) return false;
          case ScheduleMatrixCategory.kuliah:
            if (isMeeting || isExternal || isOngoing) return false;
        }
      }
      if (q.isNotEmpty) {
        return s.title.toLowerCase().contains(q) ||
            (s.location?.toLowerCase().contains(q) ?? false) ||
            (s.notes?.toLowerCase().contains(q) ?? false) ||
            (s.course?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();

    return Container(
      key: const ValueKey('desktop_schedule_directory_section'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Schedule Directory ($_selectedView)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${filteredRepo.length} live',
                  style: const TextStyle(
                    color: AppColors.primaryAccent,
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (filteredRepo.isEmpty)
            const Text(
              'No live schedules match the current filter.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < filteredRepo.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _ScheduleDirectoryRow(
                    schedule: filteredRepo[i],
                    onEdit: () => _openScheduleModelEditor(filteredRepo[i]),
                    onDelete: () => _handleDeleteRepoModel(filteredRepo[i]),
                    onToggleAlert: () =>
                        _toggleRepoModelAlert(filteredRepo[i]),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ScheduleDirectoryRow extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAlert;

  const _ScheduleDirectoryRow({
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAlert,
  });

  @override
  Widget build(BuildContext context) {
    final d = schedule.date;
    final dateText =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    final infoBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              schedule.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: schedule.statusColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                schedule.status,
                style: TextStyle(
                  color: schedule.statusColor,
                  fontSize: 10,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          '$dateText • ${schedule.formattedTime} • ${schedule.location ?? schedule.type}${schedule.notes != null && schedule.notes!.trim().isNotEmpty ? ' • ${schedule.notes}' : ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11.5,
            fontFamily: 'Inter',
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );

    final actionButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: ValueKey('desktop_dir_alert_${schedule.id}'),
          tooltip: schedule.isAlertEnabled ? 'Mute alert' : 'Enable alert',
          onPressed: onToggleAlert,
          icon: Icon(
            schedule.isAlertEnabled
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            size: 18,
            color: schedule.isAlertEnabled
                ? AppColors.primaryAccent
                : AppColors.textMuted,
          ),
        ),
        IconButton(
          key: ValueKey('desktop_dir_edit_${schedule.id}'),
          tooltip: 'Edit schedule',
          onPressed: onEdit,
          icon: const Icon(
            Icons.edit_outlined,
            size: 18,
            color: Colors.white,
          ),
        ),
        IconButton(
          key: ValueKey('desktop_dir_delete_${schedule.id}'),
          tooltip: 'Delete schedule',
          onPressed: onDelete,
          icon: const Icon(
            Icons.delete_outline_rounded,
            size: 18,
            color: AppColors.error,
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 380;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 4,
                          height: 36,
                          decoration: BoxDecoration(
                            color: schedule.accentColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: infoBlock),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: actionButtons,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: 4,
                      height: 36,
                      decoration: BoxDecoration(
                        color: schedule.accentColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: infoBlock),
                    const SizedBox(width: 8),
                    actionButtons,
                  ],
                ),
        );
      },
    );
  }
}

