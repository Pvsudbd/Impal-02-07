import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/top_toast.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../jadwal/models/schedule_model.dart';
import '../jadwal/models/schedule_repository.dart';
import '../jadwal/pop_up_konfirmasi_delete.dart';
import '../jadwal/schedule_form_page.dart';
import '../jadwal/schedule_page.dart';
import '../team/dashboard_team_page.dart';
import '../team/pop_up_create_meeting.dart';
import '../team/team_list_page.dart';
import 'models/dashboard_models.dart';
import 'widgets/home_categories_section.dart';
import 'widgets/home_header.dart';
import 'widgets/home_schedule_section.dart';
import 'widgets/home_task_card.dart';

// Re-export dashboard models for backward compatibility
export 'models/dashboard_models.dart';

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
              HomeHeader(userName: widget.userName),
              const SizedBox(height: 16),
              HomeScheduleSection(
                fallbackSchedules: _schedules,
                onSeeAll: () => _onTabSelected(3),
                onEditSchedule: _openEditSchedule,
                onDeleteSchedule: _deleteSchedule,
              ),
              const SizedBox(height: 16),
              HomeCategoriesSection(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: _onCategorySelected,
              ),
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
            return FadeTransition(opacity: animation, child: child);
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
          child: ImpalBottomNavBar(
            currentTab: _currentTab,
            onTabSelected: _onTabSelected,
          ),
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
            child: HomeTaskCard(
              task: _tasks[i],
              isLast: i == _tasks.length - 1,
            ),
          ),
      ],
    );
  }
}
