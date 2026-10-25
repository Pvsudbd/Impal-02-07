import 'package:flutter/material.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../../common_widgets/impal_schedule_card.dart';
import 'models/schedule_model.dart';
import 'models/schedule_repository.dart';
import 'schedule_form_page.dart';
import 'pop_up_konfirmasi_delete.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';

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
  int _currentTab = 3; // Schedule tab index

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
          showBackButton:
              Navigator.of(context).canPop() || widget.onBackToHome != null,
          onBack: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomNavBar(),
        ),
      ],
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: const Color(0xFF282D37),
        body: SafeArea(
          top: true,
          bottom: false,
          child: content,
        ),
      );
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

  Widget _buildBottomNavBar() {
    return ImpalBottomNavBar(
      currentTab: _currentTab,
      onTabSelected: _onTabSelected,
    );
  }

  void _onTabSelected(int index) {
    if (index == 0) {
      if (widget.onBackToHome != null) {
        widget.onBackToHome!();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tasks section'), duration: Duration(seconds: 1)),
      );
    } else if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Teams section'), duration: Duration(seconds: 1)),
      );
    } else if (index == 3) {
      setState(() => _currentTab = 3);
    }
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
  String _selectedFilter = 'All'; // 'All', 'Today', 'Week', 'Month'
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

    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final monthNames = [
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
      'Dec'
    ];

    // Group items by normalized date (year, month, day)
    final dateMap = <DateTime, List<ScheduleModel>>{};
    for (final item in list) {
      final d = DateTime(item.date.year, item.date.month, item.date.day);
      if (!dateMap.containsKey(d)) {
        dateMap[d] = [];
      }
      dateMap[d]!.add(item);
    }

    // Sort dates chronologically: past days (top) -> Today -> future days (bottom)
    final sortedDates = dateMap.keys.toList()..sort((a, b) => a.compareTo(b));

    final groups = <_ScheduleDateGroup>[];
    for (final d in sortedDates) {
      final items = dateMap[d]!;

      // Sort items within this date: Overdue (0) -> Ongoing (1) -> Upcoming (2)
      // Then chronologically by startDateTime
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
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildFilterBar(),
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
                          _buildEmptyState()
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

  String _getUserInitials(String name) {
    if (name.trim().isEmpty) return 'JS';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _buildHeader() {
    final initials = _getUserInitials(widget.userName);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              if (widget.showBackButton) ...[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        widget.onBack ?? () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF323846),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: const Color(0xFF3B4150), width: 1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hi ${widget.userName}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Schedule',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFFFF7D65),
                        fontSize: 12.5,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF323846),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF3B4150), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              color: Color(0xFF8E95A5),
              fontSize: 13.5,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Today', 'Week', 'Month'];
    return Row(
      children: filters.map((f) {
        final isSelected = _selectedFilter == f;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: f != filters.last ? 8.0 : 0.0,
            ),
            child: InkWell(
              onTap: () => setState(() => _selectedFilter = f),
              borderRadius: BorderRadius.circular(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 25,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFA6144)
                      : const Color(0xFF323846),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    f,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF8E95A5),
                      fontSize: 11.5,
                      fontFamily: 'Inter',
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.1,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
          color: const Color(0xFFFA6144),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFA6144).withValues(alpha: 0.35),
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
              color: Color(0xFF8E95A5),
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF323846),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                color: Color(0xFF8E95A5),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Schedules Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You have no scheduled activities for this filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8E95A5),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
