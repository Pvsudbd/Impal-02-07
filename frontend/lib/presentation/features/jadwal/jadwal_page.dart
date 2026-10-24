import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/utils/top_toast.dart';
import 'add_new_task_var1.dart';
import 'edit_task_var1.dart';
import 'models/schedule_model.dart';
import 'models/schedule_repository.dart';
import 'pop_up_konfirmasi_delete.dart';
import 'pop_up_schedule_deleted.dart';

/// Aliases for backwards compatibility
typedef JadwalKuliah = JadwalPage;
typedef SchedulePage = JadwalPage;

/// Main schedule page (Jadwal)
class JadwalPage extends StatefulWidget {
  final String userName;

  const JadwalPage({
    super.key,
    this.userName = 'Jarvis',
  });

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final ScheduleRepository _repository = ScheduleRepository();
  String _selectedFilter = 'All';
  int _currentTab = 3; // Schedule tab active

  final List<String> _filters = const ['All', 'Today', 'Week', 'Month'];

  @override
  void initState() {
    super.initState();
    _repository.init();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameWeek(DateTime date, DateTime now) {
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
    return date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(seconds: 1)));
  }

  bool _isSameMonth(DateTime date, DateTime now) {
    return date.year == now.year && date.month == now.month;
  }

  List<ScheduleModel> _getFilteredSchedules(List<ScheduleModel> all) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Today':
        return all.where((s) => _isSameDay(s.date, now)).toList();
      case 'Week':
        return all.where((s) => _isSameWeek(s.date, now)).toList();
      case 'Month':
        return all.where((s) => _isSameMonth(s.date, now)).toList();
      case 'All':
      default:
        return all;
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (_isSameDay(date, now)) {
      return 'Today ${date.day} ${months[date.month - 1]}';
    }
    if (_isSameDay(date, now.add(const Duration(days: 1)))) {
      return 'Tomorrow ${date.day} ${months[date.month - 1]}';
    }
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[date.weekday - 1];
    return '$dayName ${date.day} ${months[date.month - 1]}';
  }

  Map<String, List<ScheduleModel>> _groupByDate(List<ScheduleModel> list) {
    final Map<String, List<ScheduleModel>> groups = {};
    for (final s in list) {
      final header = _formatDateHeader(s.date);
      groups.putIfAbsent(header, () => []).add(s);
    }
    return groups;
  }

  Future<void> _navigateToAddSchedule() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const AddNewTaskPage(initialType: 'Lecture'),
      ),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _navigateToEditSchedule(ScheduleModel item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditTaskPage(schedule: item),
      ),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmDelete(ScheduleModel item) async {
    final confirmed = await PopUpKonfirmasiDelete.show(context);
    if (confirmed == true) {
      await _repository.deleteSchedule(item.id);
      if (mounted) {
        await PopUpScheduleDeleted.show(
          context,
          title: 'Schedule Deleted',
          message: 'Your schedule has been deleted.\nSee your changes on your Schedule page.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final pageContent = ValueListenableBuilder<List<ScheduleModel>>(
      valueListenable: _repository.schedulesNotifier,
      builder: (context, allSchedules, _) {
        final filteredSchedules = _getFilteredSchedules(allSchedules);
        final grouped = _groupByDate(filteredSchedules);

        return Stack(
          children: [
            CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(),
                      const SizedBox(height: 18),
                      _buildFilterTabs(allSchedules),
                      const SizedBox(height: 18),
                      _buildAddScheduleButton(),
                      const SizedBox(height: 22),
                      if (filteredSchedules.isEmpty)
                        _buildEmptyState()
                      else
                        ...grouped.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12, top: 4),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ...entry.value.map((s) => _buildScheduleCard(s)),
                              const SizedBox(height: 10),
                            ],
                          );
                        }),
                    ]),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavBar(),
            ),
          ],
        );
      },
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: const Color(0xFF282D37),
        body: SafeArea(
          top: true,
          bottom: false,
          child: pageContent,
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
                child: pageContent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Header matching the design system
  Widget _buildHeader() {
    final initials = widget.userName.length >= 2
        ? widget.userName.substring(0, 2).toUpperCase()
        : 'JS';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF323846),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF3B4150), width: 1),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi ${widget.userName}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Jadwal Kuliah',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFFFF7D65),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF323846),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF3B4150), width: 1),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF8E95A5),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Interactive Filter Tabs (All, Today, Week, Month)
  Widget _buildFilterTabs(List<ScheduleModel> allSchedules) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF282D37),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: InkWell(
                onTap: () => setState(() => _selectedFilter = filter),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFA6144)
                        : const Color(0xFF323846),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFA6144)
                          : const Color(0xFF3B4150),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Color(0x44FA6144),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF8E95A5),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // "Add Schedule" Button with coral glow
  Widget _buildAddScheduleButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFA6144),
          elevation: 6,
          shadowColor: const Color(0x66FA6144),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: _navigateToAddSchedule,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Add Schedule',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Schedule Card (Matching Figma pixel-perfect)
  Widget _buildScheduleCard(ScheduleModel schedule) {
    final isOngoing = schedule.status.toLowerCase() == 'ongoing';
    final accentColor = schedule.accentColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF323846),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B4150), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToEditSchedule(schedule),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left vertical accent bar
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: accentColor,
                  ),
                ),
                // Card contents
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + Status Badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                schedule.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isOngoing)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF826E),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Ongoing',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF282D37),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: const Color(0xFF3B4150),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  schedule.type,
                                  style: const TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 10,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Location / Class code
                        if (schedule.location != null &&
                            schedule.location!.isNotEmpty) ...[
                          Text(
                            schedule.location!,
                            style: const TextStyle(
                              color: Color(0xFF8E95A5),
                              fontSize: 11.5,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Time + Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: isOngoing
                                        ? const Color(0xFFFF7D65)
                                        : const Color(0xFF8E95A5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.access_time_filled,
                                    color: Colors.white,
                                    size: 9,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  schedule.formattedTime,
                                  style: const TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => _navigateToEditSchedule(schedule),
                                  borderRadius: BorderRadius.circular(6),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      color: Color(0xFF8E95A5),
                                      size: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => _confirmDelete(schedule),
                                  borderRadius: BorderRadius.circular(6),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      color: Color(0xFFFA6144),
                                      size: 16,
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
        ),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF323846).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B4150), width: 1),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_busy_rounded,
            color: Color(0xFF8E95A5),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'No schedule for "$_selectedFilter"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'You have no tasks or classes scheduled in this period.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8E95A5),
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _navigateToAddSchedule,
            icon: const Icon(Icons.add, color: Color(0xFFFA6144), size: 18),
            label: const Text(
              'Add New Schedule',
              style: TextStyle(
                color: Color(0xFFFA6144),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Curved scooped navbar matching HomePage
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
                        final opacity = (tabDistance).clamp(0.0, 1.0);

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
                              color: const Color(0xFFFA6144).withValues(alpha: 0.50),
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
      Navigator.of(context).maybePop();
    } else if (index == 1) {
      showTopToast(context, 'Tasks section');
    } else if (index == 2) {
      showTopToast(context, 'Kelompok section');
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
        return Icons.home_rounded;
    }
  }

  IconData _getInactiveIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_outlined;
      case 1:
        return Icons.checklist_outlined;
      case 2:
        return Icons.groups_outlined;
      case 3:
        return Icons.calendar_month_outlined;
      default:
        return Icons.home_outlined;
    }
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
    final Offset pTanLeft = Offset(centerX - dX * ratio, circleCenterY + dY * ratio);
    final Offset pTanRight = Offset(centerX + dX * ratio, circleCenterY + dY * ratio);
    final double leftShoulderX = (centerX - dX).clamp(left + cr, right - cr);
    final double rightShoulderX = (centerX + dX).clamp(left + cr, right - cr);

    final pocketPath = Path()
      ..moveTo(leftShoulderX, top)
      ..arcToPoint(
        pTanLeft,
        radius: const Radius.circular(r),
        clockwise: true,
      )
      ..arcToPoint(
        pTanRight,
        radius: Radius.circular(R),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(rightShoulderX, top),
        radius: const Radius.circular(r),
        clockwise: true,
      )
      ..close();

    final pocketPaint = Paint()
      ..color = const Color(0xFF282D37)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pocketPath, pocketPaint);

    final path = Path();
    path.moveTo(left, bottom);
    path.lineTo(left, top + cr);

    path.arcToPoint(
      Offset(left + cr, top),
      radius: const Radius.circular(cr),
    );
    path.lineTo(leftShoulderX, top);

    path.arcToPoint(
      pTanLeft,
      radius: const Radius.circular(r),
      clockwise: true,
    );
    path.arcToPoint(
      pTanRight,
      radius: Radius.circular(R),
      clockwise: false,
    );
    path.arcToPoint(
      Offset(rightShoulderX, top),
      radius: const Radius.circular(r),
      clockwise: true,
    );

    path.lineTo(right - cr, top);
    path.arcToPoint(
      Offset(right, top + cr),
      radius: const Radius.circular(cr),
    );

    path.lineTo(right, bottom);
    path.lineTo(left, bottom);
    path.close();

    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.35),
      14.0,
      false,
    );

    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    final topContour = Path();
    topContour.moveTo(left, top + cr);
    topContour.arcToPoint(
      Offset(left + cr, top),
      radius: const Radius.circular(cr),
    );
    topContour.lineTo(leftShoulderX, top);

    topContour.arcToPoint(
      pTanLeft,
      radius: const Radius.circular(r),
      clockwise: true,
    );
    topContour.arcToPoint(
      pTanRight,
      radius: Radius.circular(R),
      clockwise: false,
    );
    topContour.arcToPoint(
      Offset(rightShoulderX, top),
      radius: const Radius.circular(r),
      clockwise: true,
    );

    topContour.lineTo(right - cr, top);
    topContour.arcToPoint(
      Offset(right, top + cr),
      radius: const Radius.circular(cr),
    );

    final contourPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(topContour, contourPaint);
  }

  @override
  bool shouldRepaint(covariant _ScoopedNavBarPainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.barTop != barTop ||
        oldDelegate.circleCenterY != circleCenterY ||
        oldDelegate.notchRadius != notchRadius ||
        oldDelegate.barColor != barColor;
  }
}