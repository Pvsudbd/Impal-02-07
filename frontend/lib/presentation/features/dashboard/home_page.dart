import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/top_toast.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../../common_widgets/impal_schedule_card.dart';
import '../auth/login_page.dart';
import '../jadwal/schedule_page.dart';
import '../jadwal/schedule_form_page.dart';
import '../jadwal/pop_up_konfirmasi_delete.dart';
import '../jadwal/models/schedule_model.dart';
import '../jadwal/models/schedule_repository.dart';
import '../team/team_list_page.dart';
import '../team/dashboard_team_page.dart';
import '../team/pop_up_create_meeting.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';

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
  TeamModel? _selectedTeam;

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

  void _openEditSchedule(ScheduleModel item) async {
    if (item.type.trim().toLowerCase() == 'meeting') {
      await PopUpCreateMeeting.showEdit(context, existingSchedule: item);
    } else {
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => ScheduleFormPage(schedule: item)),
      );
    }
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
      await ScheduleRepository().deleteSchedule(item.id);
      if (mounted) {
        if (isMeeting) {
          PopUpPemberitahuan.meetingDeleted(context);
        } else {
          PopUpPemberitahuan.scheduleDeleted(context);
        }
      }
    }
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
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
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
                  ? (_selectedTeam != null
                      ? DashboardTeamPage(
                          key: ValueKey('team_dashboard_${_selectedTeam!.id}'),
                          userName: widget.userName,
                          teamName: _selectedTeam!.name,
                          teamCode: '7X29',
                          memberColors: _selectedTeam!.memberColors,
                          isStandalone: false,
                          onBack: () => setState(() => _selectedTeam = null),
                        )
                      : TeamListContentView(
                          key: const ValueKey('team_tab_content'),
                          userName: widget.userName,
                          showBackButton: true,
                          onBack: () => setState(() => _currentTab = 0),
                          onOpenSchedule: () => setState(() => _currentTab = 3),
                          onTeamSelected: (team) => setState(() => _selectedTeam = team),
                        ))
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
        final List<ScheduleModel> rawItems;
        if (repoSchedules.isNotEmpty) {
          final now = DateTime.now();
          final todayList = repoSchedules.where((s) {
            return s.date.year == now.year &&
                s.date.month == now.month &&
                s.date.day == now.day;
          }).toList();

          rawItems = todayList.isNotEmpty ? todayList : repoSchedules;
        } else {
          rawItems = [];
        }

        // Sort items: Overdue (0) -> Ongoing (1) -> Upcoming (2)
        // Or if Ongoing is absent: Overdue (0) -> Upcoming (2)
        // Then chronologically by start time
        final sortedItems = List<ScheduleModel>.from(rawItems);
        sortedItems.sort((a, b) {
          int statusWeight(String s) {
            final st = s.toLowerCase();
            if (st == 'overdue' || st == 'completed') return 0;
            if (st == 'ongoing') return 1;
            return 2; // Upcoming
          }

          final wA = statusWeight(a.status);
          final wB = statusWeight(b.status);
          if (wA != wB) return wA.compareTo(wB);

          final dtA = a.startDateTime ?? DateTime(2000);
          final dtB = b.startDateTime ?? DateTime(2000);
          return dtA.compareTo(dtB);
        });

        Widget scheduleContent;
        if (sortedItems.isEmpty && _schedules.isNotEmpty) {
          final isHorizontal = _schedules.length > 1;
          final cardWidgets = <Widget>[];
          for (int i = 0; i < _schedules.length; i++) {
            final isLast = i == _schedules.length - 1;
            cardWidgets.add(_buildScheduleCard(
              _schedules[i],
              isHorizontal: isHorizontal,
              isLast: isLast,
            ));
          }
          scheduleContent = isHorizontal
              ? ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: SingleChildScrollView(
                    key: const ValueKey('today_schedules_horizontal_scroll'),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    clipBehavior: Clip.none,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: cardWidgets,
                    ),
                  ),
                )
              : cardWidgets.first;
        } else if (sortedItems.isEmpty) {
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
        } else if (sortedItems.length == 1) {
          scheduleContent = _buildRepoScheduleCard(
            sortedItems.first,
            isHorizontal: false,
            isLast: true,
          );
        } else {
          scheduleContent = ImpalHorizontalScheduleList(
            key: const ValueKey('home_today_schedule_list'),
            scrollKey: const ValueKey('today_schedules_horizontal_scroll'),
            schedules: sortedItems,
            onCardTap: (s) => _onTabSelected(3),
            onEdit: (s) => _openEditSchedule(s),
            onDelete: (s) => _deleteSchedule(s),
          );
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
    return ImpalScheduleCard(
      schedule: schedule,
      isHorizontal: isHorizontal,
      isLast: isLast,
      onTap: () => _onTabSelected(3),
      onEdit: () => _openEditSchedule(schedule),
      onDelete: () => _deleteSchedule(schedule),
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
          borderRadius: BorderRadius.circular(12),
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
                          if (schedule.status.toLowerCase() == 'ongoing')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
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
                          else if (schedule.status.toLowerCase() == 'overdue' ||
                              schedule.status.toLowerCase() == 'completed')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8E95A5).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFF8E95A5).withValues(alpha: 0.35),
                                  width: 0.8,
                                ),
                              ),
                              child: const Text(
                                'Overdue',
                                style: TextStyle(
                                  color: Color(0xFF8E95A5),
                                  fontSize: 9.5,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.25,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8E95A5).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFF8E95A5).withValues(alpha: 0.35),
                                  width: 0.8,
                                ),
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

  // Scooped Bottom Navigation Bar using standard ImpalBottomNavBar
  Widget _buildBottomNavBar() {
    return ImpalBottomNavBar(
      currentTab: _currentTab,
      onTabSelected: _onTabSelected,
    );
  }

  void _onTabSelected(int index) {
    setState(() {
      if (index == 2 || _selectedTeam != null) {
        _selectedTeam = null;
      }
      _currentTab = index;
    });
    if (index == 1) {
      showTopToast(context, 'Tasks section');
    }
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