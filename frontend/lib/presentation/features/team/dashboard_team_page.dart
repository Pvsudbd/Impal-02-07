import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/responsive_context.dart';
import '../../../core/widgets/desktop_slide_drawer_pane.dart';
import '../../../core/widgets/unfocus_on_tap.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../auth/login_page.dart';
import '../dashboard/home_page.dart';
import '../dashboard/widgets/desktop/desktop_sidebar.dart';
import '../dashboard/widgets/desktop/desktop_top_header.dart';
import '../schedule/models/schedule_model.dart';
import '../schedule/models/schedule_repository.dart';
import '../schedule/pop_up_konfirmasi_delete.dart';
import '../smart_system/models/course_rubric_repository.dart';
import '../smart_system/widgets/course_rubric_modals.dart';
import '../task/models/task_repository.dart';
import 'create_task_team.dart';
import 'pop_up_create_meeting.dart';
import 'widgets/desktop/desktop_group_workspace_view.dart';
import 'widgets/desktop/desktop_team_meeting_modal.dart';
import 'widgets/desktop/desktop_team_task_modal.dart';
import 'widgets/pop_up_create_milestone.dart';
import 'widgets/team_dashboard_header.dart';
import 'widgets/team_milestones_section.dart';
import 'widgets/team_schedule_section.dart';
import 'widgets/team_task_card.dart';
import 'models/team_repository.dart';
import 'models/team_task_repository.dart';

export 'models/team_task_model.dart';

/// Aliases for backward compatibility with Figma export & routes
typedef DashboardKelompok = DashboardTeamPage;
typedef DashboardTeamPageAlias = DashboardTeamPage;

/// Which inline right slide drawer is currently active on Desktop Group Workspace.
enum DesktopTeamDrawerMode { none, createTask, createMeeting }

/// Standalone & embedded Team Dashboard Page
class DashboardTeamPage extends StatefulWidget {
  final String userName;
  final String teamName;
  final String teamCode;
  final String? teamId;
  final String searchQuery;
  final List<Color> memberColors;
  final bool isStandalone;
  final VoidCallback? onBack;
  final DesktopTeamDrawerMode? desktopDrawerMode;
  final ValueChanged<DesktopTeamDrawerMode>? onDesktopDrawerModeChanged;

  const DashboardTeamPage({
    super.key,
    this.userName = 'Jarvis',
    this.teamName = 'Kelompok IMPAL',
    this.teamCode = '7X29',
    this.teamId,
    this.searchQuery = '',
    this.memberColors = const [
      Color(0xFFF3A683),
      Color(0xFF786FA6),
      Color(0xFF63CDDA),
      Color(0xFFE77F67),
      Color(0xFF778BEB),
    ],
    this.isStandalone = true,
    this.onBack,
    this.desktopDrawerMode,
    this.onDesktopDrawerModeChanged,
  });

  @override
  State<DashboardTeamPage> createState() => _DashboardTeamPageState();
}

class _DashboardTeamPageState extends State<DashboardTeamPage> {
  final int _currentTab = 2; // Team tab active by default
  final TeamTaskRepository _teamTaskRepository = TeamTaskRepository();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _milestonesScrollController = ScrollController();
  bool _assignedToMeOnly = false;
  bool _isSidebarCollapsed = false;
  DesktopTeamDrawerMode _desktopDrawerMode = DesktopTeamDrawerMode.none;
  String _standaloneSearchQuery = '';
  String? _selectedMilestoneId;
  List<TeamMemberModel> _teamMembers = [];
  final GlobalKey _firstActiveTeamTaskKey = GlobalKey();
  final GlobalKey _firstActiveMilestoneKey = GlobalKey();
  final GlobalKey _desktopFirstActiveMilestoneKey = GlobalKey();
  bool _hasAutoScrolled = false;
  Timer? _autoScrollTimer;

  String get _teamLookupKey =>
      (widget.teamId != null && widget.teamId!.isNotEmpty)
          ? widget.teamId!
          : (widget.teamCode.isNotEmpty ? widget.teamCode : widget.teamName);

  void _toggleMilestoneSelection(String milestoneId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedMilestoneId == milestoneId) {
        _selectedMilestoneId = null; // Toggle off: show all tasks!
      } else {
        _selectedMilestoneId = milestoneId; // Filter to this milestone!
      }
    });
  }

  @override
  void initState() {
    super.initState();
    ScheduleRepository().init();
    _teamTaskRepository.init();
    _teamTaskRepository.addListener(_onRepositoryChanged);
    _teamTaskRepository.fetchMeetingsFromApi(_teamLookupKey, targetTeamName: widget.teamName);
    _teamTaskRepository.fetchMilestonesFromApi(_teamLookupKey);
    _teamTaskRepository.fetchTasksFromApi(_teamLookupKey);
    _teamMembers = TeamRepository().getCachedMembers(
      _teamLookupKey,
      fallbackUserName: widget.userName,
    );
    TeamRepository().fetchGroupMembers(
      _teamLookupKey,
      fallbackUserName: widget.userName,
    ).then((members) {
      if (mounted && members.isNotEmpty) {
        setState(() => _teamMembers = members);
      }
    });
    _triggerAutoScroll();
  }

  @override
  void didUpdateWidget(covariant DashboardTeamPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.teamCode != widget.teamCode || oldWidget.teamId != widget.teamId) {
      _desktopDrawerMode = DesktopTeamDrawerMode.none;
      _teamTaskRepository.fetchMeetingsFromApi(_teamLookupKey, targetTeamName: widget.teamName);
      _teamTaskRepository.fetchMilestonesFromApi(_teamLookupKey);
      _teamTaskRepository.fetchTasksFromApi(_teamLookupKey);
      _teamMembers = TeamRepository().getCachedMembers(
        _teamLookupKey,
        fallbackUserName: widget.userName,
      );
      TeamRepository().fetchGroupMembers(
        _teamLookupKey,
        fallbackUserName: widget.userName,
      ).then((members) {
        if (mounted && members.isNotEmpty) {
          setState(() => _teamMembers = members);
        }
      });
    }
  }

  void _onRepositoryChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _teamTaskRepository.removeListener(_onRepositoryChanged);
    _scrollController.dispose();
    _milestonesScrollController.dispose();
    super.dispose();
  }

  void _triggerAutoScroll() {
    if (_hasAutoScrolled) return;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer(const Duration(milliseconds: 240), () {
      if (!mounted || _hasAutoScrolled || context.isDesktop) return;
      if (_firstActiveTeamTaskKey.currentContext != null) {
        Scrollable.ensureVisible(
          _firstActiveTeamTaskKey.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          alignment: 0.22,
        );
        _hasAutoScrolled = true;
      }
      // Auto-scroll horizontal milestone bar to first active milestone
      // so completed milestones remain to the left and user scrolls left to see them
      if (_firstActiveMilestoneKey.currentContext != null) {
        final milestones = _teamTaskRepository.getMilestones(_teamLookupKey);
        final allTasks = _teamTaskRepository.getTasks(_teamLookupKey);
        final hasCompleted = milestones.any((m) => m.isAllCompleted(allTasks));
        if (hasCompleted) {
          Scrollable.ensureVisible(
            _firstActiveMilestoneKey.currentContext!,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            alignment: 0.0,
          );
        }
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

  DesktopTeamDrawerMode get _effectiveDrawerMode =>
      widget.desktopDrawerMode ?? _desktopDrawerMode;

  void _setDrawerMode(DesktopTeamDrawerMode next) {
    if (widget.onDesktopDrawerModeChanged != null) {
      widget.onDesktopDrawerModeChanged!(next);
      return;
    }
    if (mounted) {
      setState(() => _desktopDrawerMode = next);
    }
  }

  Future<void> _openCreateMeeting() async {
    if (context.isDesktop) {
      _setDrawerMode(
        _effectiveDrawerMode == DesktopTeamDrawerMode.createMeeting
            ? DesktopTeamDrawerMode.none
            : DesktopTeamDrawerMode.createMeeting,
      );
      return;
    }
    final result = await PopUpCreateMeeting.show(
      context,
      teamName: widget.teamName,
      showTeamMeetingOption: false,
    );
    if (result != null && mounted) {
      PopUpPemberitahuan.meetingCreated(context);
      _teamTaskRepository.fetchMeetingsFromApi(_teamLookupKey, targetTeamName: widget.teamName);
    }
  }

  Future<void> _openEditSchedule(ScheduleModel schedule) async {
    final result = await PopUpCreateMeeting.showEdit(
      context,
      schedule: schedule,
      teamName: widget.teamName,
      showTeamMeetingOption: false,
    );
    if (result != null && mounted) {
      PopUpPemberitahuan.meetingUpdated(context);
      _teamTaskRepository.fetchMeetingsFromApi(_teamLookupKey, targetTeamName: widget.teamName);
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
      if (isMeeting) {
        await _teamTaskRepository.deleteMeeting(_teamLookupKey, item.id);
      } else {
        await ScheduleRepository().deleteSchedule(item.id);
      }
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
    if (context.isDesktop) {
      _setDrawerMode(
        _effectiveDrawerMode == DesktopTeamDrawerMode.createTask
            ? DesktopTeamDrawerMode.none
            : DesktopTeamDrawerMode.createTask,
      );
      return;
    }
    final result = await Navigator.of(context).push<TeamTaskModel>(
      MaterialPageRoute(
        builder: (_) => CreateTaskTeamPage(
          userName: widget.userName,
          teamCode: _teamLookupKey,
          teamName: widget.teamName,
          groupMembers: _teamMembers,
          onTaskCreated: (task) {
            _teamTaskRepository.addTask(_teamLookupKey, task);
          },
        ),
      ),
    );
    if (result != null && mounted) {
      if (!_teamTaskRepository
          .getTasks(_teamLookupKey)
          .any((t) => t.id == result.id)) {
        _teamTaskRepository.addTask(_teamLookupKey, result);
      }
    }
  }

  Future<void> _openEditTaskPage(TeamTaskModel task) async {
    if (context.isDesktop) {
      await DesktopTeamTaskModal.show(
        context,
        existingTask: task,
        teamCode: _teamLookupKey,
        teamName: widget.teamName,
        userName: widget.userName,
        groupMembers: _teamMembers,
        onTaskUpdated: (updatedTask) {
          _teamTaskRepository.updateTask(_teamLookupKey, updatedTask);
        },
      );
      return;
    }
    final result = await Navigator.of(context).push<TeamTaskModel>(
      MaterialPageRoute(
        builder: (_) => CreateTaskTeamPage(
          existingTask: task,
          userName: widget.userName,
          teamCode: _teamLookupKey,
          teamName: widget.teamName,
          groupMembers: _teamMembers,
          onTaskUpdated: (updatedTask) {
            _teamTaskRepository.updateTask(_teamLookupKey, updatedTask);
          },
        ),
      ),
    );
    if (result != null && mounted) {
      _teamTaskRepository.updateTask(_teamLookupKey, result);
    }
  }

  Future<void> _openCreateMilestone() async {
    await PopUpCreateMilestone.show(
      context,
      teamCode: _teamLookupKey,
    );
  }

  Future<void> _openEditMilestone(TeamMilestoneModel milestone) async {
    await PopUpCreateMilestone.show(
      context,
      teamCode: _teamLookupKey,
      existingMilestone: milestone,
    );
  }

  Future<void> _deleteMilestone(TeamMilestoneModel milestone) async {
    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: 'Delete Milestone?',
      message:
          'Are you sure you want to delete "${milestone.title}"? Member tasks will remain in the dashboard.',
    );
    if (confirmed == true && mounted) {
      _teamTaskRepository.deleteMilestone(_teamLookupKey, milestone.id);
      if (widget.teamCode.isNotEmpty && widget.teamCode != _teamLookupKey) {
        _teamTaskRepository.deleteMilestone(widget.teamCode, milestone.id);
      }
      PopUpPemberitahuan.milestoneDeleted(context, title: milestone.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (context.isDesktop) {
      final desktopWorkspaceBody = DesktopGroupWorkspaceView(
        userName: widget.userName,
        teamName: widget.teamName,
        teamCode: _teamLookupKey,
        groupMembers: _teamMembers,
        searchQuery: widget.isStandalone
            ? _standaloneSearchQuery
            : widget.searchQuery,
        memberColors: _teamMembers.length > 1
            ? _teamMembers.map((m) => m.avatarColor).toList()
            : (widget.memberColors.length > 1
                ? widget.memberColors
                : (_teamMembers.isNotEmpty
                    ? _teamMembers.map((m) => m.avatarColor).toList()
                    : widget.memberColors)),
        milestones: _teamTaskRepository.getMilestones(_teamLookupKey),
        allTasks: _teamTaskRepository.getTasks(_teamLookupKey),
        selectedMilestoneId: _selectedMilestoneId,
        assignedToMeOnly: _assignedToMeOnly,
        scrollController: _scrollController,
        milestonesScrollController: _milestonesScrollController,
        firstActiveMilestoneKey: _desktopFirstActiveMilestoneKey,
        onMilestoneSelected: _toggleMilestoneSelection,
        onAddMilestone: _openCreateMilestone,
        onEditMilestone: _openEditMilestone,
        onDeleteMilestone: _deleteMilestone,
        onAssignedToMeChanged: (val) =>
            setState(() => _assignedToMeOnly = val),
        onCreateMeeting: _openCreateMeeting,
        onCreateTask: _openCreateTaskPage,
        onEditTask: _openEditTaskPage,
        onToggleTaskCompletion: _handleTaskToggleCompletion,
        onEditSchedule: _openEditSchedule,
        onDeleteSchedule: _deleteSchedule,
        onMembersTap: _showTeamMembersModal,
        isAssignedToCurrentUser: _isAssignedToCurrentUser,
        meetings: _teamTaskRepository.getMeetings(_teamLookupKey),
      );

      final drawerMode = _effectiveDrawerMode;
      final Widget? activeDrawer = switch (drawerMode) {
        DesktopTeamDrawerMode.createTask => DesktopTeamTaskModal(
            key: const ValueKey('desktop_team_task_slide_drawer'),
            teamCode: _teamLookupKey,
            teamName: widget.teamName,
            userName: widget.userName,
            groupMembers: _teamMembers,
            embeddedPanel: true,
            onClose: () => _setDrawerMode(DesktopTeamDrawerMode.none),
            onTaskCreated: (task) {
              _teamTaskRepository.addTask(_teamLookupKey, task);
              _setDrawerMode(DesktopTeamDrawerMode.none);
            },
          ),
        DesktopTeamDrawerMode.createMeeting => DesktopTeamMeetingModal(
            key: const ValueKey('desktop_team_meeting_slide_drawer'),
            teamName: widget.teamName,
            showTeamMeetingOption: false,
            embeddedPanel: true,
            onClose: () => _setDrawerMode(DesktopTeamDrawerMode.none),
            onCreated: (_) {
              _setDrawerMode(DesktopTeamDrawerMode.none);
              _teamTaskRepository.fetchMeetingsFromApi(_teamLookupKey, targetTeamName: widget.teamName);
            },
          ),
        DesktopTeamDrawerMode.none => null,
      };

      final workspaceWithDrawer = DesktopSlideDrawerPane(
        isOpen: drawerMode != DesktopTeamDrawerMode.none,
        content: desktopWorkspaceBody,
        drawer: activeDrawer,
      );

      if (!widget.isStandalone) {
        return workspaceWithDrawer;
      }

      return _buildStandaloneDesktopShell(context, workspaceWithDrawer);
    }

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
                memberColors: _teamMembers.length > 1
                    ? _teamMembers.map((m) => m.avatarColor).toList()
                    : (widget.memberColors.length > 1
                        ? widget.memberColors
                        : (_teamMembers.isNotEmpty
                            ? _teamMembers.map((m) => m.avatarColor).toList()
                            : widget.memberColors)),
                showBackButton: Navigator.of(context).canPop() || widget.onBack != null,
                onBack: widget.onBack,
                onMembersTap: _showTeamMembersModal,
              ),
              const SizedBox(height: 12),
              _buildMobileTeamRubricSyncBanner(context),
              const SizedBox(height: 16),
              TeamScheduleSection(
                isDashboard: true,
                teamName: widget.teamName,
                teamCode: _teamLookupKey,
                meetings: _teamTaskRepository.getMeetings(_teamLookupKey),
                onActionTap: _openCreateMeeting,
                onEditSchedule: _openEditSchedule,
                onDeleteSchedule: _deleteSchedule,
              ),
              const SizedBox(height: 16),
              TeamMilestonesSection(
                milestones: _teamTaskRepository.getMilestones(_teamLookupKey),
                allTasks: _teamTaskRepository.getTasks(_teamLookupKey),
                selectedMilestoneId: _selectedMilestoneId,
                onMilestoneSelected: _toggleMilestoneSelection,
                onAddMilestone: _openCreateMilestone,
                onEditMilestone: _openEditMilestone,
                onDeleteMilestone: _deleteMilestone,
                scrollController: _milestonesScrollController,
                firstActiveMilestoneKey: _firstActiveMilestoneKey,
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

  void _navigateStandaloneToTab(int tabIndex) {
    if (tabIndex == 2 && widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (tabIndex == 2 && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomePage(
          userName: widget.userName,
          initialTab: tabIndex,
        ),
      ),
      (route) => false,
    );
  }

  void _showStandaloneLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
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
            color: AppColors.textMuted,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              await prefs.remove('auth_token');
              await prefs.remove('jwt_token');
              await prefs.remove('auth_user');
              TeamRepository().clear();
              TaskRepository().clear();
              TeamTaskRepository().clear();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  AuthFadeRoute(page: const Login()),
                );
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandaloneDesktopShell(
    BuildContext context,
    Widget workspaceBody,
  ) {
    final pendingTaskCount =
        TaskRepository().tasks.where((t) => !t.isCompleted).length;
    final scheduleCount = ScheduleRepository().schedulesNotifier.value.length;

    return UnfocusOnTap(
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Row(
          children: [
            DesktopSidebar(
              activeDestination: DesktopNavDestination.teamMembers,
              isCollapsed: _isSidebarCollapsed,
              onToggleCollapse: () {
                setState(() => _isSidebarCollapsed = !_isSidebarCollapsed);
              },
              onDestinationSelected: (destination) {
                switch (destination) {
                  case DesktopNavDestination.dashboard:
                    _navigateStandaloneToTab(0);
                  case DesktopNavDestination.tasks:
                    _navigateStandaloneToTab(1);
                  case DesktopNavDestination.teamMembers:
                    _navigateStandaloneToTab(2);
                  case DesktopNavDestination.schedule:
                    _navigateStandaloneToTab(3);
                  case DesktopNavDestination.smartPriority:
                    _navigateStandaloneToTab(5);
                }
              },
              userName: widget.userName,
              scheduleCount: scheduleCount,
              pendingTaskCount: pendingTaskCount,
              onProfileTap: () => _navigateStandaloneToTab(4),
              onLogoutTap: _showStandaloneLogoutDialog,
            ),
            Expanded(
              child: Column(
                children: [
                  DesktopTopHeader(
                    breadcrumbParent: 'Team Members',
                    onBreadcrumbParentTap: () => _navigateStandaloneToTab(2),
                    title: widget.teamName,
                    subtitle:
                        'Implementasi & Pengujian Perangkat Lunak • SIF-45-02',
                    searchQuery: _standaloneSearchQuery,
                    searchHint: 'Search tasks in workspace...',
                    searchBgColor: AppColors.bgSidebar,
                    showLeadingSearchIcon: true,
                    showShortcutHint: false,
                    showNotificationBell: true,
                    horizontalPadding:
                        context.screenWidth < 1200 ? 24 : 32,
                    addButtonLabel: '+ Create Task',
                    addButtonColor: AppColors.primaryAccent,
                    addButtonKey: const ValueKey('dashboard_create_task_button'),
                    onSearchChanged: (value) {
                      setState(() => _standaloneSearchQuery = value);
                    },
                    onAddTaskTap: _openCreateTaskPage,
                  ),
                  Expanded(child: workspaceBody),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTeamMembersModal() {
    List<TeamMemberModel> currentModalMembers = _teamMembers.isNotEmpty
        ? _teamMembers
        : TeamRepository().getCachedMembers(
            _teamLookupKey,
            fallbackUserName: widget.userName,
          );

    List<Map<String, dynamic>> mapMembers(List<TeamMemberModel> rawList) {
      if (rawList.isNotEmpty) {
        return rawList.map((m) => {
          'name': m.name,
          'role': m.role.toLowerCase() == 'leader'
              ? 'Team Leader'
              : (m.role.isNotEmpty ? m.role : 'Member'),
          'color': m.avatarColor,
          'email': m.email.isNotEmpty
              ? m.email
              : '${m.name.toLowerCase().replaceAll(' ', '.')}@student.telkomuniversity.ac.id',
        }).toList();
      }
      return [
        {
          'name': widget.userName.isNotEmpty ? widget.userName : 'You',
          'role': 'Team Leader',
          'color': const Color(0xFFF3A683),
          'email':
              '${widget.userName.toLowerCase().replaceAll(' ', '.')}@student.telkomuniversity.ac.id',
        },
      ];
    }

    Widget buildMemberList(List<Map<String, dynamic>> members) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
      );
    }

    void triggerFetch(void Function(void Function()) setModalState) {
      TeamRepository()
          .fetchGroupMembers(_teamLookupKey, fallbackUserName: widget.userName)
          .then((fresh) {
        if (fresh.isNotEmpty) {
          if (mounted) {
            setState(() => _teamMembers = fresh);
          }
          setModalState(() {
            currentModalMembers = fresh;
          });
        }
      });
    }

    if (currentModalMembers.length <= 1) {
      TeamRepository()
          .fetchGroupMembers(_teamLookupKey, fallbackUserName: widget.userName)
          .then((fresh) {
        if (mounted && fresh.isNotEmpty) {
          setState(() => _teamMembers = fresh);
        }
      });
    }

    if (context.isDesktop) {
      showDialog<void>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setModalState) {
            if (currentModalMembers.length <= 1) {
              triggerFetch(setModalState);
            }
            final members = mapMembers(currentModalMembers);
            return Dialog(
              key: const ValueKey('desktop_team_members_dialog'),
              backgroundColor: AppColors.bgDialog,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.borderSubtle, width: 1),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460, maxHeight: 580),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          IconButton(
                            key: const ValueKey('desktop_team_members_close_btn'),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: SingleChildScrollView(child: buildMemberList(members)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          if (currentModalMembers.length <= 1) {
            triggerFetch(setModalState);
          }
          final members = mapMembers(currentModalMembers);
          return Container(
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
                buildMemberList(members),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileTeamRubricSyncBanner(BuildContext context) {
    return ListenableBuilder(
      listenable: CourseRubricRepository(),
      builder: (context, _) {
        final linked = CourseRubricRepository().getLinkedRubricForTeam(
          teamId: widget.teamCode,
          teamName: widget.teamName,
        );
        final isLinked = linked != null;

        return Material(
          color: isLinked
              ? const Color(0xFF4A90E2).withValues(alpha: 0.12)
              : const Color(0xFF323846),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            key: const ValueKey('mobile_team_sync_rubric_btn'),
            onTap: () => AssignRubricToTeamDialog.showForTeam(
              context,
              teamId: widget.teamCode,
              teamName: widget.teamName,
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLinked
                      ? const Color(0xFF4A90E2).withValues(alpha: 0.45)
                      : const Color(0xFF3B4150),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.grading_rounded,
                    size: 18,
                    color: isLinked
                        ? const Color(0xFF60A5FA)
                        : AppColors.primaryAccent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isLinked
                          ? 'Rubric: ${linked.course.courseCode.isNotEmpty ? linked.course.courseCode : linked.course.courseName} • ${linked.component.name} (${linked.component.weightPercent}%)'
                          : 'Link Course Grading Rubric',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isLinked ? const Color(0xFF93C5FD) : Colors.white,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isLinked ? 'Sync' : 'Assign',
                    style: const TextStyle(
                      color: AppColors.primaryAccent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  void _handleTaskToggleCompletion(TeamTaskModel task) {
    HapticFeedback.lightImpact();
    final willComplete = !task.isDone;
    _teamTaskRepository.toggleTaskCompletion(
      teamCode: _teamLookupKey,
      taskId: task.id,
    );
    if (willComplete) {
      final allDone =
          _teamTaskRepository.areAllTasksCompleted(_teamLookupKey);
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
        PopUpPemberitahuan.taskCompleted(context, taskName: task.title);
      }
    } else {
      PopUpPemberitahuan.taskReopened(context, taskName: task.title);
    }
  }

  Widget _buildTeamTaskSection() {
    final allTasks = _teamTaskRepository.getTasks(_teamLookupKey);
    final milestones = _teamTaskRepository.getMilestones(_teamLookupKey);

    final selectedMilestone = _selectedMilestoneId != null
        ? milestones.where((m) => m.id == _selectedMilestoneId).firstOrNull
        : null;

    final targetTasks = selectedMilestone != null
        ? selectedMilestone.getMemberTasks(allTasks)
        : allTasks;

    final filtered = _assignedToMeOnly
        ? targetTasks.where(_isAssignedToCurrentUser).toList()
        : targetTasks;

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
        const SizedBox(height: 12),
        if (displayedTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF323846),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                selectedMilestone != null
                    ? (_assignedToMeOnly
                        ? 'No tasks assigned to you in "${selectedMilestone.title}".'
                        : 'No tasks added to "${selectedMilestone.title}" yet.')
                    : (_assignedToMeOnly
                        ? 'No tasks assigned to you in this team.'
                        : 'No team tasks found in this dashboard.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
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
              onToggleCompletion: () =>
                  _handleTaskToggleCompletion(displayedTasks[i]),
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
