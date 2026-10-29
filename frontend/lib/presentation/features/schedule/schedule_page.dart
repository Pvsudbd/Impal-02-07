import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../../common_widgets/impal_schedule_card.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../dashboard/home_page.dart';
import 'models/schedule_model.dart';
import 'models/schedule_repository.dart';
import 'pop_up_konfirmasi_delete.dart';
import 'schedule_form_page.dart';
import 'widgets/schedule_empty_state.dart';
import 'widgets/schedule_filter_bar.dart';
import 'widgets/schedule_header.dart';

/// Aliases for backwards compatibility
typedef JadwalKuliah = SchedulePage;
typedef JadwalPage = SchedulePage;

/// Full standalone Schedule page
class SchedulePage extends StatefulWidget {
  final String userName;
  final bool isStandalone;
  final VoidCallback? onBackToHome;

  const SchedulePage({
    super.key,
    this.userName = 'Jarvis',
    this.isStandalone = true,
    this.onBackToHome,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ScheduleRepository _repo = ScheduleRepository();
  int _currentTab = 3;

  @override
  void initState() {
    super.initState();
    _repo.init();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isStandalone) {
      return ScheduleContentView(
        userName: widget.userName,
        showBackButton: false,
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final content = Stack(
      children: [
        ScheduleContentView(
          userName: widget.userName,
          showBackButton: false,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ImpalBottomNavBar(
            currentTab: _currentTab,
            onTabSelected: _onTabSelected,
          ),
        ),
      ],
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(top: true, bottom: false, child: content),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E222B),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 410, maxHeight: 844),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
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

  void _onTabSelected(int index) {
    if (index == 3) {
      setState(() => _currentTab = 3);
      return;
    }
    if (widget.onBackToHome != null && index == 0) {
      widget.onBackToHome!();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomePage(
          userName: widget.userName,
          initialTab: index,
        ),
      ),
      (route) => false,
    );
  }
}

/// Reusable Schedule Content View that can be embedded into HomePage or used standalone
class ScheduleContentView extends StatefulWidget {
  final String userName;
  final bool showBackButton;
  final VoidCallback? onBack;

  const ScheduleContentView({
    super.key,
    this.userName = 'Jarvis',
    this.showBackButton = false,
    this.onBack,
  });

  @override
  State<ScheduleContentView> createState() => _ScheduleContentViewState();
}

class _ScheduleDateGroup {
  final DateTime date;
  final String header;
  final bool isToday;
  final List<ScheduleModel> items;

  _ScheduleDateGroup({
    required this.date,
    required this.header,
    required this.isToday,
    required this.items,
  });
}

class _ScheduleContentViewState extends State<ScheduleContentView> {
  final ScheduleRepository _repo = ScheduleRepository();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _todayTargetKey = GlobalKey();
  String _selectedFilter = 'All';
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    _repo.init();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTodayOrOngoing() {
    if (!mounted || !_scrollController.hasClients) return;
    final ctx = _todayTargetKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openAddSchedule() {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ScheduleFormPage()),
    );
  }

  void _openEditSchedule(ScheduleModel item) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ScheduleFormPage(schedule: item)),
    );
  }

  Future<void> _deleteSchedule(ScheduleModel item) async {
    final isMeeting = item.type.trim().toLowerCase() == 'meeting';
    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: isMeeting ? 'Delete Meeting?' : 'Delete Schedule?',
      message: isMeeting
          ? 'Are you sure you want to delete this meeting? This action cannot be undone.'
          : 'Are you sure you want to delete this schedule? This action cannot be undone.',
    );
    if (confirmed == true) {
      await _repo.deleteSchedule(item.id);
      if (mounted) {
        if (isMeeting) {
          PopUpPemberitahuan.meetingDeleted(context);
        } else {
          PopUpPemberitahuan.scheduleDeleted(context);
        }
      }
    }
  }

  List<ScheduleModel> _filterSchedules(List<ScheduleModel> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_selectedFilter == 'Today') {
      return list.where((s) {
        final d = DateTime(s.date.year, s.date.month, s.date.day);
        return d.isAtSameMomentAs(today);
      }).toList();
    } else if (_selectedFilter == 'Week') {
      final endOfWeek = today.add(const Duration(days: 7));
      return list.where((s) {
        final d = DateTime(s.date.year, s.date.month, s.date.day);
        return !d.isBefore(today) && d.isBefore(endOfWeek);
      }).toList();
    } else if (_selectedFilter == 'Month') {
      return list.where((s) {
        return s.date.month == now.month && s.date.year == now.year;
      }).toList();
    }

    return list;
  }

  List<_ScheduleDateGroup> _groupByDate(List<ScheduleModel> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final dateMap = <DateTime, List<ScheduleModel>>{};
    for (final item in list) {
      final d = DateTime(item.date.year, item.date.month, item.date.day);
      if (!dateMap.containsKey(d)) {
        dateMap[d] = [];
      }
      dateMap[d]!.add(item);
    }

    final sortedDates = dateMap.keys.toList()..sort((a, b) => a.compareTo(b));

    final groups = <_ScheduleDateGroup>[];
    for (final d in sortedDates) {
      final items = dateMap[d]!;

      items.sort((a, b) {
        int statusWeight(String s) {
          final st = s.toLowerCase();
          if (st == 'overdue' || st == 'completed') return 0;
          if (st == 'ongoing') return 1;
          return 2;
        }

        final wA = statusWeight(a.status);
        final wB = statusWeight(b.status);
        if (wA != wB) return wA.compareTo(wB);

        final dtA = a.startDateTime ?? DateTime(2000);
        final dtB = b.startDateTime ?? DateTime(2000);
        return dtA.compareTo(dtB);
      });

      final isToday = d.isAtSameMomentAs(today);
      String header;
      if (isToday) {
        header = 'Today ${d.day} ${monthNames[d.month - 1]}';
      } else if (d.isAtSameMomentAs(yesterday)) {
        header = 'Yesterday ${d.day} ${monthNames[d.month - 1]}';
      } else if (d.isAtSameMomentAs(tomorrow)) {
        header = 'Tomorrow ${d.day} ${monthNames[d.month - 1]}';
      } else {
        final dayName = dayNames[d.weekday - 1];
        header = '$dayName ${d.day} ${monthNames[d.month - 1]}';
      }

      groups.add(_ScheduleDateGroup(
        date: d,
        header: header,
        isToday: isToday,
        items: items,
      ));
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ScheduleModel>>(
      valueListenable: _repo.schedulesNotifier,
      builder: (context, allSchedules, _) {
        final filteredList = _filterSchedules(allSchedules);
        final groups = _groupByDate(filteredList);

        String? todayOngoingId;
        bool hasTodayGroup = false;
        for (final group in groups) {
          if (group.isToday) {
            hasTodayGroup = true;
            for (final item in group.items) {
              if (item.status.toLowerCase() == 'ongoing') {
                todayOngoingId = item.id;
                break;
              }
            }
            break;
          }
        }

        if (!_didInitialScroll) {
          _didInitialScroll = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToTodayOrOngoing();
          });
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                children: [
                  ScheduleHeader(
                    userName: widget.userName,
                    subtitle: 'Schedule',
                    showBackButton: widget.showBackButton,
                    onBack: widget.onBack,
                  ),
                  const SizedBox(height: 16),
                  ScheduleFilterBar(
                    selectedFilter: _selectedFilter,
                    onFilterChanged: (f) => setState(() => _selectedFilter = f),
                  ),
                  const SizedBox(height: 14),
                  _buildAddScheduleButton(),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (groups.isEmpty)
                          const ScheduleEmptyState()
                        else
                          ...groups.asMap().entries.map((indexedEntry) {
                            final index = indexedEntry.key;
                            final group = indexedEntry.value;
                            final shouldAttachHeaderKey =
                                group.isToday && todayOngoingId == null && hasTodayGroup;
                            return _buildScheduleGroup(
                              group,
                              isFirstGroup: index == 0,
                              todayOngoingId: todayOngoingId,
                              attachTodayHeaderKey: shouldAttachHeaderKey,
                            );
                          }),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddScheduleButton() {
    return InkWell(
      onTap: _openAddSchedule,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 19),
            SizedBox(width: 8),
            Text(
              'Add Schedule',
              style: TextStyle(
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
    );
  }

  Widget _buildScheduleGroup(
    _ScheduleDateGroup group, {
    bool isFirstGroup = false,
    String? todayOngoingId,
    bool attachTodayHeaderKey = false,
  }) {
    return Column(
      key: attachTodayHeaderKey ? _todayTargetKey : null,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isFirstGroup ? 4 : 14, bottom: 8),
          child: Text(
            group.header,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13.5,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        for (int i = 0; i < group.items.length; i++)
          ImpalScheduleCard(
            schedule: group.items[i],
            isLast: i == group.items.length - 1,
            targetKey: (group.items[i].id == todayOngoingId) ? _todayTargetKey : null,
            onEdit: () => _openEditSchedule(group.items[i]),
            onDelete: () => _deleteSchedule(group.items[i]),
          ),
      ],
    );
  }
}
