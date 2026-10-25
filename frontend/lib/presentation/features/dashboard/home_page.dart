import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/top_toast.dart';
import '../auth/login_page.dart';
import '../jadwal/schedule_page.dart';
import '../jadwal/models/schedule_model.dart';
import '../jadwal/models/schedule_repository.dart';
import '../team/team_list_page.dart';

/// Aliases for flexibility
typedef Home = HomePage;

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({
    super.key,
    this.userName = 'Jarvis',
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    ScheduleRepository().init();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('is_logged_in', true);
      prefs.setString('auth_user', widget.userName);
    });
  }

  final List<ScheduleItem> _schedules = const [
    ScheduleItem(
      courseCode: 'UBXCCB2 - BAHASA INDONESIA',
      status: 'Ongoing',
      location: 'KTT B-106 • SSIF-04-REG-GAB02',
      time: '09:30 - 11:30 WIB',
    ),
  ];

  final List<CategoryItem> _categories = const [
    CategoryItem(name: 'College', count: '05 Tasks', icon: Icons.school_rounded),
    CategoryItem(name: 'Personal', count: '05 Tasks', icon: Icons.person_rounded),
  ];

  final List<TaskItem> _tasks = const [
    TaskItem(
      title: 'Wallet App Design',
      dueBadge: '6d',
      dueColor: Color(0xFF8FC7FF),
      dueTextColor: Color(0xFF1E3A8A),
      isUrgent: false,
      members: [Color(0xFFF3A683), Color(0xFF786FA6), Color(0xFF63CDDA)],
      progress: 0.46,
      deadline: 'Sat 11 Oct 2026, 23:59 WIB',
      tags: [
        TaskTag(label: 'Kelompok', bg: Color(0xFF786FA6), text: Color(0xFF382A72)),
        TaskTag(label: 'Figma', bg: Color(0xFF778BEB), text: Color(0xFF2E3E8C)),
      ],
    ),
    TaskItem(
      title: 'Tugas IMPAL Figma',
      subtitle: 'Membuat ui page kelompok',
      dueBadge: '6d',
      dueColor: Color(0xFF8FC7FF),
      dueTextColor: Color(0xFF1E3A8A),
      isUrgent: false,
      deadline: 'Sat 11 Oct 2026, 23:59 WIB',
      tags: [
        TaskTag(label: 'Personal', bg: Color(0xFF778BEB), text: Color(0xFF2E3E8C)),
        TaskTag(label: 'Figma', bg: Color(0xFF778BEB), text: Color(0xFF2E3E8C)),
      ],
    ),
    TaskItem(
      title: 'Dashboard & Mobile App',
      dueBadge: '4d',
      dueColor: Color(0xFFFF826E),
      dueTextColor: Colors.white,
      isUrgent: true,
      members: [
        Color(0xFFF3A683),
        Color(0xFF786FA6),
        Color(0xFF63CDDA),
        Color(0xFFE77F67),
        Color(0xFF778BEB),
      ],
      progress: 0.76,
      deadline: 'Sat 11 Oct 2026, 23:59 WIB',
      tags: [
        TaskTag(label: 'Kelompok', bg: Color(0xFF786FA6), text: Color(0xFF382A72)),
        TaskTag(label: 'Code', bg: Color(0xFF63CDDA), text: Color(0xFF1C636D)),
      ],
    ),
    TaskItem(
      title: 'Tugas IMPAL Frontend',
      subtitle: 'Membuat frontend page kelompok',
      dueBadge: '17d',
      dueColor: Color(0xFF8FC7FF),
      dueTextColor: Color(0xFF1E3A8A),
      isUrgent: false,
      deadline: 'Sat 11 Oct 2026, 23:59 WIB',
      tags: [
        TaskTag(label: 'Personal', bg: Color(0xFF778BEB), text: Color(0xFF2E3E8C)),
        TaskTag(label: 'Code', bg: Color(0xFF63CDDA), text: Color(0xFF1C636D)),
      ],
    ),
  ];

  void _onCategorySelected(String name) {
    setState(() {
      _selectedCategory = _selectedCategory == name ? 'All' : name;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF282D37),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
            color: Color(0xFF8E95A5),
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8E95A5), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFA6144),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              await prefs.remove('auth_user');
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  AuthFadeRoute(page: const Login()),
                );
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final dashboardContent = CustomScrollView(
      key: const ValueKey('home_dashboard_scroll'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 96),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeader(),
              const SizedBox(height: 16),
              _buildTodayScheduleSection(),
              const SizedBox(height: 16),
              _buildCategoriesSection(),
              const SizedBox(height: 16),
              _buildOngoingTaskSection(),
            ]),
          ),
        ),
      ],
    );

    final homeContent = Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final isSchedule = _currentTab == 3;
            final offset = Tween<Offset>(
              begin: isSchedule ? const Offset(0.20, 0) : const Offset(-0.20, 0),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
          child: _currentTab == 3
              ? ScheduleContentView(
                  key: const ValueKey('schedule_tab_content'),
                  userName: widget.userName,
                  showBackButton: true,
                  onBack: () => setState(() => _currentTab = 0),
                )
              : (_currentTab == 2
                  ? TeamListContentView(
                      key: const ValueKey('team_tab_content'),
                      userName: widget.userName,
                      showBackButton: true,
                      onBack: () => setState(() => _currentTab = 0),
                    )
                  : dashboardContent),
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
          child: homeContent,
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
                child: homeContent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Header: Hi Jarvis + 10 task pending + Avatar
  Widget _buildHeader() {
    final initials = widget.userName.length >= 2
        ? widget.userName.substring(0, 2).toUpperCase()
        : 'JS';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi ${widget.userName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              '10 task pending',
              style: TextStyle(
                color: Color(0xFFFF7D65),
                fontSize: 12.5,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: _showLogoutDialog,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF323846),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF434A59), width: 1.5),
              ),
              alignment: Alignment.center,
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
        ),
      ],
    );
  }

  // Section 1: Today's schedule
  Widget _buildTodayScheduleSection() {
    return ValueListenableBuilder<List<ScheduleModel>>(
      valueListenable: ScheduleRepository().schedulesNotifier,
      builder: (context, repoSchedules, _) {
        final List<Widget> cardWidgets = [];
        bool isHorizontal = false;

        if (repoSchedules.isNotEmpty) {
          final now = DateTime.now();
          final todayList = repoSchedules.where((s) {
            return s.date.year == now.year &&
                s.date.month == now.month &&
                s.date.day == now.day;
          }).toList();

          final itemsToShow = todayList.isNotEmpty ? todayList : repoSchedules;
          isHorizontal = itemsToShow.length > 1;

          for (int i = 0; i < itemsToShow.length; i++) {
            final isLast = i == itemsToShow.length - 1;
            cardWidgets.add(_buildRepoScheduleCard(
              itemsToShow[i],
              isHorizontal: isHorizontal,
              isLast: isLast,
            ));
          }
        } else if (_schedules.isNotEmpty) {
          isHorizontal = _schedules.length > 1;
          for (int i = 0; i < _schedules.length; i++) {
            final isLast = i == _schedules.length - 1;
            cardWidgets.add(_buildScheduleCard(
              _schedules[i],
              isHorizontal: isHorizontal,
              isLast: isLast,
            ));
          }
        }

        Widget scheduleContent;
        if (cardWidgets.isEmpty) {
          scheduleContent = Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF323846),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text(
              'No schedules for today',
              style: TextStyle(
                color: Color(0xFF8E95A5),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        } else if (isHorizontal) {
          scheduleContent = ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cardWidgets,
              ),
            ),
          );
        } else {
          scheduleContent = cardWidgets.first;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Today's schedule",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.04,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _onTabSelected(3),
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      color: Color(0xFFFF826E),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            scheduleContent,
          ],
        );
      },
    );
  }

  Widget _buildRepoScheduleCard(
    ScheduleModel schedule, {
    bool isHorizontal = false,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: () => _onTabSelected(3),
      child: Container(
        margin: EdgeInsets.only(
          right: isHorizontal ? (isLast ? 0 : 12) : 0,
          bottom: !isHorizontal ? (isLast ? 0 : 10) : 0,
        ),
        width: isHorizontal ? 285 : double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF323846),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                color: schedule.accentColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              schedule.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: schedule.status.toLowerCase() == 'ongoing'
                                  ? const Color(0xFFFF826E)
                                  : const Color(0xFF3B4150),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              schedule.status,
                              style: TextStyle(
                                color: schedule.status.toLowerCase() == 'ongoing'
                                    ? Colors.white
                                    : const Color(0xFF8E95A5),
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (schedule.location != null && schedule.location!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          schedule.location!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8E95A5),
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: schedule.accentColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.access_time_filled_rounded,
                              size: 10,
                              color: schedule.accentColor,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(
    ScheduleItem schedule, {
    bool isHorizontal = false,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: () => _onTabSelected(3),
      child: Container(
        margin: EdgeInsets.only(
          right: isHorizontal ? (isLast ? 0 : 12) : 0,
          bottom: !isHorizontal ? (isLast ? 0 : 10) : 0,
        ),
        width: isHorizontal ? 285 : double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF323846),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left primary colored accent stripe
              Container(
                width: 5,
                color: const Color(0xFFFF826E),
              ),
              // Card Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title & Ongoing Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              schedule.courseCode,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF826E),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              schedule.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Location info
                      Text(
                        schedule.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8E95A5),
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Time with Clock Icon
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF7D65),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.access_time_filled_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            schedule.time,
                            style: const TextStyle(
                              color: Color(0xFF8E95A5),
                              fontSize: 11,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
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
    );
  }

  // Section 2: Categories
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ..._categories.map((cat) {
              final isSelected = _selectedCategory == cat.name;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildCategoryCard(cat, isSelected),
                ),
              );
            }),
            // Add Category Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  showTopToast(context, 'Add category coming soon!');
                },
                child: Container(
                  width: 44,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF323846),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF434A59), width: 1),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF8E95A5),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(CategoryItem category, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onCategorySelected(category.name),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3D4556) : const Color(0xFF323846),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF7D65) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                category.count,
                style: const TextStyle(
                  color: Color(0xFF8E95A5),
                  fontSize: 11.5,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section 3: Ongoing Task
  Widget _buildOngoingTaskSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Ongoing Task',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.04,
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                showTopToast(context, 'Showing all ongoing tasks');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: Color(0xFFFF7D65),
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < _tasks.length; i++)
          RepaintBoundary(
            child: _buildTaskCard(_tasks[i], isLast: i == _tasks.length - 1),
          ),
      ],
    );
  }

  Widget _buildTaskCard(TaskItem task, {bool isLast = false}) {
    final isGroup = (task.members != null && task.members!.isNotEmpty) ||
        task.tags.any((t) => t.label.toLowerCase() == 'kelompok');
    final effectiveProgress = task.progress ?? (isGroup ? 0.46 : null);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration: BoxDecoration(
        color: const Color(0xFF323846),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Left Column: Title, Subtitle, Team members, Deadline, Tags
            Padding(
              padding: EdgeInsets.only(
                right: (isGroup && effectiveProgress != null) ? 56 : 46,
              ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),

                          // Subtitle if available
                          if (task.subtitle != null && task.subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              task.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF8E95A5),
                                fontSize: 11.5,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],

                          // Team members section (only for group tasks)
                          if (isGroup && task.members != null && task.members!.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            const Text(
                              'Team members',
                              style: TextStyle(
                                color: Color(0xFF8E95A5),
                                fontSize: 11,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildAvatarStack(task.members!),
                          ],

                          // Linear progress bar for non-group tasks (if specified)
                          if (!isGroup && task.progress != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Progress',
                                  style: TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(task.progress! * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Color(0xFF60A5FA),
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: task.progress,
                                minHeight: 5,
                                backgroundColor: const Color(0xFF282D37),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF60A5FA)),
                              ),
                            ),
                          ],

                          const SizedBox(height: 8),

                          // Deadline Row with Clock
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF826E).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.access_time_filled_rounded,
                                  size: 10,
                                  color: Color(0xFFFF826E),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  task.deadline,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 7),

                          // Tags row
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: task.tags.map((tag) => _buildTag(tag)).toList(),
                          ),
                        ],
                      ),
                    ),

                    // Top-Right Due Badge
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: task.isUrgent
                              ? const Color(0xFFFF826E)
                              : task.dueColor,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: task.isUrgent
                                ? const Color(0xFFFF826E)
                                : task.dueColor.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          task.dueBadge,
                          style: TextStyle(
                            color: task.isUrgent
                                ? Colors.white
                                : task.dueTextColor,
                            fontSize: 10,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // Vertically Centered Circular Progress for Group Tasks
                    if (isGroup && effectiveProgress != null)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        child: Center(
                          child: _buildCircularProgress(
                            effectiveProgress,
                            isUrgent: task.isUrgent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }

  Widget _buildAvatarStack(List<Color> colors) {
    const double size = 22.0;
    const double overlap = 14.0;
    final displayColors = colors.take(4).toList();
    final extraCount = colors.length - displayColors.length;

    return SizedBox(
      height: size,
      width: size +
          (displayColors.length - 1 + (extraCount > 0 ? 1 : 0)) * overlap,
      child: Stack(
        children: [
          for (int i = 0; i < displayColors.length; i++)
            Positioned(
              left: i * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: displayColors[i],
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF323846), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_rounded,
                  size: 11.5,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: displayColors.length * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFF434A59),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF323846), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extraCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(double progress, {bool isUrgent = false}) {
    final percent = (progress * 100).toInt();
    final progressColor = isUrgent
        ? const Color(0xFFFF826E)
        : const Color(0xFF55E6C1);

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3.6,
              strokeCap: StrokeCap.round,
              backgroundColor: const Color(0xFF232834),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              semanticsLabel: 'Task progress: $percent%',
            ),
          ),
          Text(
            '$percent%',
            style: TextStyle(
              color: progressColor,
              fontSize: 11.5,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(TaskTag tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tag.bg.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tag.label,
        style: TextStyle(
          color: tag.bg,
          fontSize: 10.5,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  // Scooped Bottom Navigation Bar matching Screenshot 2026-10-22 211916.png
  Widget _buildBottomNavBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const double barTop = 26.0;
    const double circleTop = 2.0;
    const double circleDiameter = 54.0;
    const double circleRadius = circleDiameter / 2; // 27.0
    const double circleCenterY = circleTop + circleRadius; // 29.0
    const double gap = 6.0; // 6 px gap wider than the circle
    const double notchRadius = circleRadius + gap; // 33.0 (concentric to circle)
    final totalHeight = barTop + 68.0 + bottomPadding;

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
                  // 1. Scooped Navbar Background
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

                  // 2. Inactive Tab Icons
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

                  // 3. Protruding Floating Coral Circle Button (nestled in scoop without overshooting)
                  Positioned(
                    left: activeCenterX - circleRadius,
                    top: 2.0, // Bottom sits at 56.0, scoop trough at 58.0 cradles it with 2px gap
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
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) => FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(scale: animation, child: child),
                            ),
                            child: Icon(
                              _getActiveIcon(_currentTab),
                              key: ValueKey<int>(_currentTab),
                              color: Colors.white,
                              size: 26,
                            ),
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
    setState(() => _currentTab = index);
    if (index == 1) {
      showTopToast(context, 'Tasks section');
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
        return Icons.checklist_rounded;
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
    const double cr = 5.0; // 5 px corner radius on top navbar edges

    final double R = notchRadius; // 33.0 (concentric to 27.0 radius circle, exactly 6px gap)
    const double r = 10.0; // smooth, gentle shoulder transition radius
    final double dY = (top + r) - circleCenterY;
    final double distSq = (R + r) * (R + r) - dY * dY;
    final double dX = distSq > 0 ? math.sqrt(distSq) : R;

    final double ratio = R / (R + r);
    final Offset pTanLeft = Offset(centerX - dX * ratio, circleCenterY + dY * ratio);
    final Offset pTanRight = Offset(centerX + dX * ratio, circleCenterY + dY * ratio);
    final double leftShoulderX = (centerX - dX).clamp(left + cr, right - cr);
    final double rightShoulderX = (centerX + dX).clamp(left + cr, right - cr);

    // 1. Recessed pocket behind the scoop (matches scaffold background so scrolled items don't bleed through)
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

    // 2. Build full navbar body path with circular cutout concentric to the button
    final path = Path();
    path.moveTo(left, bottom);
    path.lineTo(left, top + cr);

    // Top-left corner (5px)
    path.arcToPoint(
      Offset(left + cr, top),
      radius: const Radius.circular(cr),
    );
    path.lineTo(leftShoulderX, top);

    // Smooth shoulder down into circular arc cupping the circle with 6px gap
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

    // Line to top-right corner (5px)
    path.lineTo(right - cr, top);
    path.arcToPoint(
      Offset(right, top + cr),
      radius: const Radius.circular(cr),
    );

    path.lineTo(right, bottom);
    path.lineTo(left, bottom);
    path.close();

    // 3. Elevation drop shadow along navbar top contour
    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.35),
      14.0,
      false,
    );

    // 4. Fill navbar body
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // 5. Subtle refined top contour highlight
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

// Data Models
class ScheduleItem {
  final String courseCode;
  final String status;
  final String location;
  final String time;

  const ScheduleItem({
    required this.courseCode,
    required this.status,
    required this.location,
    required this.time,
  });

  factory ScheduleItem.fromModel(ScheduleModel model) {
    return ScheduleItem(
      courseCode: model.title,
      status: model.status,
      location: model.location ?? model.course ?? '',
      time: model.formattedTime,
    );
  }
}

class CategoryItem {
  final String name;
  final String count;
  final IconData icon;

  const CategoryItem({
    required this.name,
    required this.count,
    required this.icon,
  });
}

class TaskItem {
  final String title;
  final String? subtitle;
  final String dueBadge;
  final Color dueColor;
  final Color dueTextColor;
  final bool isUrgent;
  final List<Color>? members;
  final double? progress;
  final String deadline;
  final List<TaskTag> tags;

  const TaskItem({
    required this.title,
    this.subtitle,
    required this.dueBadge,
    required this.dueColor,
    required this.dueTextColor,
    required this.isUrgent,
    this.members,
    this.progress,
    required this.deadline,
    required this.tags,
  });
}

class TaskTag {
  final String label;
  final Color bg;
  final Color text;

  const TaskTag({
    required this.label,
    required this.bg,
    required this.text,
  });
}