import 'package:flutter/material.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../dashboard/home_page.dart';
import '../jadwal/models/schedule_model.dart';
import '../jadwal/models/schedule_repository.dart';
import '../jadwal/pop_up_konfirmasi_delete.dart';
import '../jadwal/schedule_page.dart';
import 'create_task_team.dart';
import 'pop_up_create_meeting.dart';
import 'widgets/team_dashboard_header.dart';
import 'widgets/team_schedule_section.dart';
import 'widgets/team_task_card.dart';

export 'models/team_task_model.dart';

/// Aliases for backward compatibility with Figma export & routes
typedef DashboardKelompok = DashboardTeamPage;
typedef DashboardTeamPageAlias = DashboardTeamPage;

/// Standalone & embedded Team Dashboard Page
class DashboardTeamPage extends StatefulWidget {
  final String userName;
  final String teamName;
  final String teamCode;
  final List<Color> memberColors;
  final bool isStandalone;
  final VoidCallback? onBack;

  const DashboardTeamPage({
    super.key,
    this.userName = 'Jarvis',
    this.teamName = 'Kelompok IMPAL',
    this.teamCode = '7X29',
    this.memberColors = const [
      Color(0xFFF3A683),
      Color(0xFF786FA6),
      Color(0xFF63CDDA),
      Color(0xFFE77F67),
      Color(0xFF778BEB),
    ],
    this.isStandalone = true,
    this.onBack,
  });

  @override
  State<DashboardTeamPage> createState() => _DashboardTeamPageState();
}

class _DashboardTeamPageState extends State<DashboardTeamPage> {
  int _currentTab = 2; // Team tab active by default
  late List<TeamTaskModel> _tasks;

  @override
  void initState() {
    super.initState();
    ScheduleRepository().init();
    _tasks = [
      const TeamTaskModel(
        id: 'task_1',
        title: 'Membuat ui page kelompok',
        priority: TaskPriority.high,
        assignedTo: 'Yoga Perkasa Didik',
        assigneeColor: Color(0xFFF3A683),
        timeRange: '09:30 - 11:30 WIB',
      ),
      const TeamTaskModel(
        id: 'task_2',
        title: 'Membuat ui page home',
        priority: TaskPriority.medium,
        assignedTo: 'Ahmad Sahroni, Muhammad Kafi Rijal',
        assigneeColor: Color(0xFF63CDDA),
        assigneeColors: [Color(0xFF63CDDA), Color(0xFF786FA6)],
        timeRange: '09:30 - 11:30 WIB',
      ),
      const TeamTaskModel(
        id: 'task_3',
        title: 'Membuat ui form tugas',
        priority: TaskPriority.low,
        assignedTo: 'Yoga Perkasa Didik',
        assigneeColor: Color(0xFFF3A683),
        timeRange: '09:30 - 11:30 WIB',
      ),
    ];
  }

  Future<void> _openCreateMeeting() async {
    final result = await PopUpCreateMeeting.show(
      context,
      teamName: widget.teamName,
    );
    if (result != null && mounted) {
      PopUpPemberitahuan.meetingCreated(context);
    }
  }

  Future<void> _openEditSchedule(ScheduleModel schedule) async {
    final result = await PopUpCreateMeeting.showEdit(
      context,
      schedule: schedule,
      teamName: widget.teamName,
    );
    if (result != null && mounted) {
      PopUpPemberitahuan.meetingUpdated(context);
    }
  }

  Future<void> _deleteSchedule(ScheduleModel item) async {
    final isMeeting = item.type.toLowerCase() == 'meeting';
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

  Future<void> _openCreateTaskPage() async {
    final result = await Navigator.of(context).push<TeamTaskModel>(
      MaterialPageRoute(
        builder: (_) => CreateTaskTeamPage(
          onTaskCreated: (task) {
            setState(() {
              _tasks.insert(0, task);
            });
          },
        ),
      ),
    );
    if (result != null && mounted) {
      if (!_tasks.any((t) => t.id == result.id)) {
        setState(() {
          _tasks.insert(0, result);
        });
      }
    }
  }

  Future<void> _openEditTaskPage(TeamTaskModel task) async {
    final result = await Navigator.of(context).push<TeamTaskModel>(
      MaterialPageRoute(
        builder: (_) => CreateTaskTeamPage(
          existingTask: task,
          onTaskUpdated: (updatedTask) {
            setState(() {
              final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
              if (index != -1) {
                _tasks[index] = updatedTask;
              }
            });
          },
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        final index = _tasks.indexWhere((t) => t.id == result.id);
        if (index != -1) {
          _tasks[index] = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final dashboardScrollContent = CustomScrollView(
      key: const ValueKey('team_dashboard_scroll_view'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 96),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              TeamDashboardHeader(
                userName: widget.userName,
                teamName: widget.teamName,
                teamCode: widget.teamCode,
                memberColors: widget.memberColors,
                showBackButton: Navigator.of(context).canPop() || widget.onBack != null,
                onBack: widget.onBack,
              ),
              const SizedBox(height: 16),
              TeamScheduleSection(
                isDashboard: true,
                onActionTap: _openCreateMeeting,
                onEditSchedule: _openEditSchedule,
                onDeleteSchedule: _deleteSchedule,
              ),
              const SizedBox(height: 16),
              _buildTeamTaskSection(),
            ]),
          ),
        ),
      ],
    );

    final scaffoldContent = Stack(
      children: [
        dashboardScrollContent,
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
        body: SafeArea(top: true, bottom: false, child: scaffoldContent),
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
                  color: const Color(0xFF282D37),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x8C000000),
                      blurRadius: 50,
                      offset: Offset(0, 25),
                      spreadRadius: -12,
                    ),
                  ],
                ),
                child: scaffoldContent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamTaskSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'Team Task',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.04,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              key: const ValueKey('dashboard_create_task_button'),
              onTap: _openCreateTaskPage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFA6144),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '+ Create Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < _tasks.length; i++) ...[
          TeamTaskCard(
            task: _tasks[i],
            onTap: () => _openEditTaskPage(_tasks[i]),
          ),
          if (i < _tasks.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  void _onTabSelected(int index) {
    if (index == _currentTab) return;
    setState(() => _currentTab = index);

    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else if (index == 2) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SchedulePage(
            userName: widget.userName,
            isStandalone: true,
          ),
        ),
      );
    }
  }
}
