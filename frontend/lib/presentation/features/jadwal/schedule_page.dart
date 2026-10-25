import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'models/schedule_model.dart';
import 'models/schedule_repository.dart';
import 'add_new_schedule.dart';
import 'edit_schedule.dart';
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
    const double barTop = 18.0;
    const double totalHeight = 86.0;
    const double circleDiameter = 54.0;
    const double circleRadius = circleDiameter / 2;
    const double circleCenterY = 29.0;
    const double notchRadius = 33.0;

    return SizedBox(
      height: totalHeight,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: _currentTab.toDouble()),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        builder: (context, animValue, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final tabWidth = width / 4;
              final activeCenterX = (animValue + 0.5) * tabWidth;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: Size(width, totalHeight),
                    painter: _ScoopedNavBarPainter(
                      centerX: activeCenterX,
                      barTop: barTop,
                      circleCenterY: circleCenterY,
                      notchRadius: notchRadius,
                      barColor: const Color(0xFF323846),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: barTop,
                    height: 68.0,
                    child: Row(
                      children: List.generate(4, (index) {
                        final tabDistance = (animValue - index).abs();
                        final opacity = tabDistance.clamp(0.0, 1.0);

                        return Expanded(
                          child: InkWell(
                            onTap: () => _onTabSelected(index),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Center(
                              child: Opacity(
                                opacity: opacity,
                                child: Icon(
                                  _getInactiveIcon(index),
                                  color: const Color(0xFF8E95A5),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Positioned(
                    left: activeCenterX - circleRadius,
                    top: 2.0,
                    child: GestureDetector(
                      onTap: () => _onTabSelected(_currentTab),
                      child: Container(
                        width: circleDiameter,
                        height: circleDiameter,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFF7253),
                              Color(0xFFFA6144),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFA6144)
                                  .withValues(alpha: 0.50),
                              blurRadius: 18,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _getActiveIcon(_currentTab),
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
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

  IconData _getActiveIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.checklist_rounded;
      case 2:
        return Icons.groups_rounded;
      case 3:
        return Icons.calendar_month_rounded;
      default:
        return Icons.calendar_month_rounded;
    }
  }

  IconData _getInactiveIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_outlined;
      case 1:
        return Icons.checklist_rounded;
      case 2:
        return Icons.groups_outlined;
      case 3:
        return Icons.calendar_month_outlined;
      default:
        return Icons.calendar_month_outlined;
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

class _ScheduleContentViewState extends State<ScheduleContentView> {
  final ScheduleRepository _repo = ScheduleRepository();
  String _selectedFilter = 'All'; // 'All', 'Today', 'Week', 'Month'

  @override
  void initState() {
    super.initState();
    _repo.init();
  }

  void _openAddSchedule() {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddNewSchedule()),
    );
  }

  void _openEditSchedule(ScheduleModel item) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditSchedule(schedule: item)),
    );
  }

  Future<void> _deleteSchedule(ScheduleModel item) async {
    final confirmed = await PopUpKonfirmasiDelete.show(context);
    if (confirmed == true) {
      await _repo.deleteSchedule(item.id);
      if (mounted) {
        PopUpPemberitahuan.scheduleDeleted(context);
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

  Map<String, List<ScheduleModel>> _groupByDate(List<ScheduleModel> list) {
    final map = <String, List<ScheduleModel>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
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

    for (final item in list) {
      final d = DateTime(item.date.year, item.date.month, item.date.day);
      String header;
      if (d.isAtSameMomentAs(today)) {
        header = 'Today ${d.day} ${monthNames[d.month - 1]}';
      } else if (d.isAtSameMomentAs(tomorrow)) {
        header = 'Tomorrow ${d.day} ${monthNames[d.month - 1]}';
      } else {
        final dayName = dayNames[d.weekday - 1];
        header = '$dayName ${d.day} ${monthNames[d.month - 1]}';
      }

      if (!map.containsKey(header)) {
        map[header] = [];
      }
      map[header]!.add(item);
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ScheduleModel>>(
      valueListenable: _repo.schedulesNotifier,
      builder: (context, allSchedules, _) {
        final filteredList = _filterSchedules(allSchedules);
        final grouped = _groupByDate(filteredList);

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 96),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildFilterBar(),
                  const SizedBox(height: 14),
                  _buildAddScheduleButton(),
                  const SizedBox(height: 14),
                  if (grouped.isEmpty)
                    _buildEmptyState()
                  else
                    ...grouped.entries.toList().asMap().entries.map((indexedEntry) {
                      final index = indexedEntry.key;
                      final entry = indexedEntry.value;
                      return _buildScheduleGroup(entry.key, entry.value,
                          isFirstGroup: index == 0);
                    }),
                ]),
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

  Widget _buildScheduleGroup(String dateHeader, List<ScheduleModel> items,
      {bool isFirstGroup = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isFirstGroup ? 4 : 14, bottom: 8),
          child: Text(
            dateHeader,
            style: const TextStyle(
              color: Color(0xFF8E95A5),
              fontSize: 13.5,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        for (int i = 0; i < items.length; i++)
          _buildScheduleCard(items[i], isLast: i == items.length - 1),
      ],
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule, {bool isLast = false}) {
    final isOngoing = schedule.status.toLowerCase() == 'ongoing';
    final isUpcoming = schedule.status.toLowerCase() == 'upcoming';
    final accentColor =
        isUpcoming ? const Color(0xFF8E95A5) : schedule.accentColor;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration: BoxDecoration(
        color: const Color(0xFF323846),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Accent Strip: Coral for ongoing, 8E95A5 for upcoming
            Container(
              width: 4,
              color: accentColor,
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: Title + Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            schedule.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isOngoing)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF826E),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Ongoing',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.25,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isUpcoming
                                  ? const Color(0xFF8E95A5)
                                      .withValues(alpha: 0.15)
                                  : const Color(0xFF3B4150),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              schedule.status,
                              style: const TextStyle(
                                color: Color(0xFF8E95A5),
                                fontSize: 9.5,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.25,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (schedule.location != null &&
                        schedule.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              schedule.location!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF8E95A5),
                                fontSize: 11.5,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.05,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    // Time row & action icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.access_time_filled_rounded,
                                  color: accentColor,
                                  size: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              schedule.formattedTime,
                              style: const TextStyle(
                                color: Color(0xFF8E95A5),
                                fontSize: 11.5,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.05,
                              ),
                            ),
                          ],
                        ),
                        // Quick actions (Edit & Delete)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _openEditSchedule(schedule),
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.all(3.5),
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF8E95A5),
                                  size: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => _deleteSchedule(schedule),
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.all(3.5),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFF8E95A5),
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

class _ScoopedNavBarPainter extends CustomPainter {
  final double centerX;
  final double barTop;
  final double circleCenterY;
  final double notchRadius;
  final Color barColor;

  const _ScoopedNavBarPainter({
    required this.centerX,
    required this.barTop,
    required this.circleCenterY,
    required this.notchRadius,
    required this.barColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double left = 0;
    final double right = size.width;
    final double top = barTop;
    final double bottom = size.height;
    const double cr = 5.0;

    final double R = notchRadius;
    const double r = 10.0;
    final double dY = (top + r) - circleCenterY;
    final double distSq = (R + r) * (R + r) - dY * dY;
    final double dX = distSq > 0 ? math.sqrt(distSq) : R;

    final double ratio = R / (R + r);
    final Offset pTanLeft =
        Offset(centerX - dX * ratio, circleCenterY + dY * ratio);
    final Offset pTanRight =
        Offset(centerX + dX * ratio, circleCenterY + dY * ratio);
    final double leftShoulderX = (centerX - dX).clamp(left + cr, right - cr);
    final double rightShoulderX = (centerX + dX).clamp(left + cr, right - cr);

    final Path path = Path();
    path.moveTo(left, top + cr);
    path.quadraticBezierTo(left, top, left + cr, top);

    if (leftShoulderX > left + cr) {
      path.lineTo(leftShoulderX, top);
      path.quadraticBezierTo(
        leftShoulderX + (centerX - leftShoulderX) * 0.35,
        top,
        pTanLeft.dx,
        pTanLeft.dy,
      );
    } else {
      path.lineTo(pTanLeft.dx, pTanLeft.dy);
    }

    final Rect notchRect = Rect.fromCircle(
      center: Offset(centerX, circleCenterY),
      radius: R,
    );
    final double startAngle =
        math.atan2(pTanLeft.dy - circleCenterY, pTanLeft.dx - centerX);
    final double endAngle =
        math.atan2(pTanRight.dy - circleCenterY, pTanRight.dx - centerX);
    double sweep = endAngle - startAngle;
    if (sweep < 0) sweep += 2 * math.pi;

    path.arcTo(notchRect, startAngle, sweep, false);

    if (rightShoulderX < right - cr) {
      path.quadraticBezierTo(
        rightShoulderX - (rightShoulderX - centerX) * 0.35,
        top,
        rightShoulderX,
        top,
      );
      path.lineTo(right - cr, top);
    } else {
      path.lineTo(right - cr, top);
    }

    path.quadraticBezierTo(right, top, right, top + cr);
    path.lineTo(right, bottom);
    path.lineTo(left, bottom);
    path.close();

    final Paint paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScoopedNavBarPainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.barColor != barColor ||
        oldDelegate.notchRadius != notchRadius;
  }
}
