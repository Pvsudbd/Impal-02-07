import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../dashboard/home_page.dart';
import '../schedule/models/schedule_model.dart';
import '../schedule/models/schedule_repository.dart';
import '../schedule/pop_up_konfirmasi_delete.dart';
import 'create_task_team.dart';
import 'pop_up_create_meeting.dart';
import 'widgets/team_dashboard_header.dart';
import 'widgets/team_schedule_section.dart';
import 'widgets/team_task_card.dart';
import 'models/team_task_repository.dart';

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
  final int _currentTab = 2; // Team tab active by default
  final TeamTaskRepository _teamTaskRepository = TeamTaskRepository();
  final ScrollController _scrollController = ScrollController();
  bool _assignedToMeOnly = false;
  final GlobalKey _firstActiveTeamTaskKey = GlobalKey();
  bool _hasAutoScrolled = false;

  @override
  void initState() {
    super.initState();
    ScheduleRepository().init();
    _teamTaskRepository.init();
    _teamTaskRepository.addListener(_onRepositoryChanged);
    _triggerAutoScroll();
  }

  void _onRepositoryChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _teamTaskRepository.removeListener(_onRepositoryChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _triggerAutoScroll() {
    if (_hasAutoScrolled) return;
    Future.delayed(const Duration(milliseconds: 240), () {
      if (!mounted || _hasAutoScrolled) return;
      if (_firstActiveTeamTaskKey.currentContext != null) {
        Scrollable.ensureVisible(
          _firstActiveTeamTaskKey.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          alignment: 0.22,
        );
        _hasAutoScrolled = true;
      }
    });
  }

  bool _isAssignedToCurrentUser(TeamTaskModel task) {
    final userLower = widget.userName.toLowerCase();
    final assignedLower = task.assignedTo.toLowerCase();
    if (assignedLower.contains(userLower)) return true;
    if (userLower == 'jarvis' &&
        (assignedLower.contains('yoga') || assignedLower.contains('jarvis'))) {
      return true;
    }
    final parts = userLower.split(' ').where((s) => s.length > 2);
    for (final p in parts) {
      if (assignedLower.contains(p)) return true;
    }
    return false;
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
            _teamTaskRepository.addTask(widget.teamCode, task);
          },
        ),
      ),
    );
    if (result != null && mounted) {
      if (!_teamTaskRepository
          .getTasks(widget.teamCode)
          .any((t) => t.id == result.id)) {
        _teamTaskRepository.addTask(widget.teamCode, result);
      }
    }
  }

  Future<void> _openEditTaskPage(TeamTaskModel task) async {
    final result = await Navigator.of(context).push<TeamTaskModel>(
      MaterialPageRoute(
        builder: (_) => CreateTaskTeamPage(
          existingTask: task,
          onTaskUpdated: (updatedTask) {
            _teamTaskRepository.updateTask(widget.teamCode, updatedTask);
          },
        ),
      ),
    );
    if (result != null && mounted) {
      _teamTaskRepository.updateTask(widget.teamCode, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final dashboardScrollContent = CustomScrollView(
      key: const ValueKey('team_dashboard_scroll_view'),
      controller: _scrollController,
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
                onMembersTap: _showTeamMembersModal,
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

    // If embedded inside HomePage shell, return scroll content directly
    // to prevent duplicate Scaffolds, SafeAreas, and BottomNavBars
    if (!widget.isStandalone) {
      return dashboardScrollContent;
    }

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

  void _showTeamMembersModal() {
    final members = [
      {
        'name': 'Andi Sukamoto',
        'role': 'Team Leader',
        'color': const Color(0xFFF3A683),
        'email': 'andi@student.telkomuniversity.ac.id',
      },
      {
        'name': 'Rayya Gemintang',
        'role': 'UI/UX Designer',
        'color': const Color(0xFF786FA6),
        'email': 'rayya@student.telkomuniversity.ac.id',
      },
      {
        'name': 'Muhammad Kafi Rijal',
        'role': 'Frontend Engineer',
        'color': const Color(0xFF63CDDA),
        'email': 'kafi@student.telkomuniversity.ac.id',
      },
      {
        'name': 'Yoga Perkasa Didik',
        'role': 'Backend Engineer',
        'color': const Color(0xFFE77F67),
        'email': 'yoga@student.telkomuniversity.ac.id',
      },
      {
        'name': widget.userName,
        'role': 'Quality Assurance',
        'color': const Color(0xFF778BEB),
        'email': 'jarvis@student.telkomuniversity.ac.id',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF282D37),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF434A59),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Team Members (${members.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final m in members) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF323846),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B4150), width: 0.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: m['color'] as Color,
                      child: Text(
                        (m['name'] as String).substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m['email'] as String,
                            style: const TextStyle(
                              color: Color(0xFF8E95A5),
                              fontSize: 11,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (m['role'] as String).contains('Leader')
                            ? const Color(0xFFFF7D65).withValues(alpha: 0.15)
                            : const Color(0xFF5B93FF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        m['role'] as String,
                        style: TextStyle(
                          color: (m['role'] as String).contains('Leader')
                              ? const Color(0xFFFF7D65)
                              : const Color(0xFF5B93FF),
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssigneeFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF7D65) : const Color(0xFF323846),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF7D65) : const Color(0xFF3B4150),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF8E95A5),
            fontSize: 11,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamTaskSection() {
    final allTasks = _teamTaskRepository.getTasks(widget.teamCode);
    final filtered = _assignedToMeOnly
        ? allTasks.where(_isAssignedToCurrentUser).toList()
        : allTasks;

    final completed = filtered.where((t) => t.isDone).toList();
    final active = filtered.where((t) => !t.isDone).toList();
    active.sort(TeamTaskModel.compareTeamTaskDeadlines);
    final displayedTasks = [...completed, ...active];
    final firstActiveId = active.map((t) => t.id).firstOrNull;

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
        Row(
          children: [
            _buildAssigneeFilterChip(
              'All Tasks',
              !_assignedToMeOnly,
              () => setState(() => _assignedToMeOnly = false),
            ),
            const SizedBox(width: 8),
            _buildAssigneeFilterChip(
              'Assigned to Me',
              _assignedToMeOnly,
              () => setState(() => _assignedToMeOnly = true),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (displayedTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF323846),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No tasks assigned to you in this team.',
                style: TextStyle(
                  color: Color(0xFF8E95A5),
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          )
        else
          for (int i = 0; i < displayedTasks.length; i++) ...[
            TeamTaskCard(
              key: displayedTasks[i].id == firstActiveId
                  ? _firstActiveTeamTaskKey
                  : ValueKey('team_task_${displayedTasks[i].id}'),
              task: displayedTasks[i],
              isAssignedToCurrentUser:
                  _isAssignedToCurrentUser(displayedTasks[i]),
              onTap: () => _openEditTaskPage(displayedTasks[i]),
              onEdit: () => _openEditTaskPage(displayedTasks[i]),
              onToggleCompletion: () {
                HapticFeedback.lightImpact();
                final willComplete = !displayedTasks[i].isDone;
                _teamTaskRepository.toggleTaskCompletion(
                  teamCode: widget.teamCode,
                  taskId: displayedTasks[i].id,
                );
                if (willComplete) {
                  final allDone =
                      _teamTaskRepository.areAllTasksCompleted(widget.teamCode);
                  if (allDone) {
                    PopUpPemberitahuan.show(
                      context,
                      title: 'All Team Tasks Completed! 🎉',
                      message:
                          'All tasks in this dashboard are finished. Team Project is now marked completed!',
                      icon: Icons.celebration_rounded,
                      iconBgColor: const Color(0xFF10B981),
                    );
                  } else {
                    PopUpPemberitahuan.taskCompleted(context,
                        taskName: displayedTasks[i].title);
                  }
                } else {
                  PopUpPemberitahuan.taskReopened(context,
                      taskName: displayedTasks[i].title);
                }
              },
            ),
            if (i < displayedTasks.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }

  void _onTabSelected(int index) {
    if (index == _currentTab) {
      if (index == 2 && widget.onBack != null) {
        widget.onBack!();
      }
      return;
    }
    if (index == 2 && widget.onBack != null) {
      widget.onBack!();
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
