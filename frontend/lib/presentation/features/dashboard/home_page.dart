import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/top_toast.dart';
import '../auth/login_page.dart';
import '../jadwal/jadwal_page.dart';

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
        TaskTag(label: 'personal', bg: Color(0xFF778BEB), text: Color(0xFF2E3E8C)),
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
        TaskTag(label: 'personal', bg: Color(0xFF778BEB), text: Color(0xFF2E3E8C)),
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

    final homeContent = Stack(
      children: [
        CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  const SizedBox(height: 22),
                  _buildTodayScheduleSection(),
                  const SizedBox(height: 24),
                  _buildCategoriesSection(),
                  const SizedBox(height: 24),
                  _buildOngoingTaskSection(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's schedule",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.04,
          ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const JadwalPage()),
                );
              },
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
        const SizedBox(height: 12),
        ..._schedules.map((schedule) => _buildScheduleCard(schedule)),
      ],
    );
  }

  Widget _buildScheduleCard(ScheduleItem schedule) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const JadwalPage()),
        );
      },
      child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF323846),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Ongoing Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            schedule.courseCode,
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
                    const SizedBox(height: 6),
                    // Location info
                    Text(
                      schedule.location,
                      style: const TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 11,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
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
        const SizedBox(height: 12),
        Row(
          children: [
            ..._categories.map((cat) {
              final isSelected = _selectedCategory == cat.name;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
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
                  height: 68,
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
        borderRadius: BorderRadius.circular(18),
        onTap: () => _onCategorySelected(category.name),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3D4556) : const Color(0xFF323846),
            borderRadius: BorderRadius.circular(18),
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
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                category.count,
                style: const TextStyle(
                  color: Color(0xFF8E95A5),
                  fontSize: 12,
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
        const SizedBox(height: 12),
        ..._tasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: RepaintBoundary(child: _buildTaskCard(task)),
            )),
      ],
    );
  }

  Widget _buildTaskCard(TaskItem task) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF323846),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title + Due Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.8,
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
                  color: task.dueColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  task.dueBadge,
                  style: TextStyle(
                    color: task.dueTextColor,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // Subtitle if available
          if (task.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              task.subtitle!,
              style: const TextStyle(
                color: Color(0xFF8E95A5),
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          // Team members label if members exist
          if (task.members != null && task.members!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Team members',
              style: TextStyle(
                color: Color(0xFF8E95A5),
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Row 2: Avatars / Progress & Deadline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Avatars Stack or Info
              if (task.members != null && task.members!.isNotEmpty)
                _buildAvatarStack(task.members!)
              else
                const SizedBox.shrink(),

              // Circular Progress Indicator (if task has progress e.g. 76%)
              if (task.progress != null)
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: task.progress,
                        strokeWidth: 3.5,
                        backgroundColor: const Color(0xFF282D37),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF60A5FA)),
                      ),
                      Text(
                        '${(task.progress! * 100).toInt()}%',
                        style: const TextStyle(
                          color: Color(0xFF60A5FA),
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Deadline Row with Clock
          Row(
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF7D65),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.access_time_filled_rounded,
                  size: 9.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                task.deadline,
                style: const TextStyle(
                  color: Color(0xFF8E95A5),
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Tags Row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: task.tags.map((tag) => _buildTag(tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack(List<Color> colors) {
    return SizedBox(
      height: 26,
      width: (20 + (colors.length - 1) * 16).toDouble(),
      child: Stack(
        children: [
          for (int i = 0; i < colors.length; i++)
            Positioned(
              left: (i * 16).toDouble(),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF323846), width: 2),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person,
                  size: 13,
                  color: Colors.black38,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTag(TaskTag tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
      decoration: BoxDecoration(
        color: tag.bg.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tag.bg.withValues(alpha: 0.6), width: 1),
      ),
      child: Text(
        tag.label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 10,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
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
    } else if (index == 2) {
      showTopToast(context, 'Kelompok section');
    } else if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const JadwalPage()),
      ).then((_) {
        if (mounted) setState(() => _currentTab = 0);
      });
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