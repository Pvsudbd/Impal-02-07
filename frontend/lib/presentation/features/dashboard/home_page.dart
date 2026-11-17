import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../core/utils/responsive_context.dart';
import '../../../core/widgets/unfocus_on_tap.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../auth/login_page.dart';
import '../profile/models/user_profile_model.dart';
import '../profile/widgets/desktop/desktop_profile_modals.dart';
import '../profile/widgets/desktop/desktop_profile_settings_view.dart';
import '../schedule/models/schedule_model.dart';
import '../schedule/models/schedule_repository.dart';
import '../schedule/pop_up_konfirmasi_delete.dart';
import '../schedule/schedule_form_page.dart';
import '../schedule/schedule_page.dart';
import '../schedule/widgets/desktop/desktop_schedule_matrix_view.dart';
import '../schedule/widgets/desktop/desktop_schedule_modal.dart';
import '../smart_system/models/smart_priority_repository.dart';
import '../smart_system/smart_priority_page.dart';
import '../task/models/task_repository.dart';
import '../task/task_page.dart';
import '../task/widgets/desktop/desktop_personal_task_modal.dart';
import '../task/widgets/desktop/desktop_tasks_management_view.dart';
import '../team/dashboard_team_page.dart';
import '../team/models/desktop_team_directory_models.dart';
import '../team/pop_up_create_meeting.dart';
import '../team/pop_up_create_team.dart';
import '../team/pop_up_join_team.dart';
import '../team/team_list_page.dart';
import '../team/widgets/desktop/desktop_group_directory_view.dart';
import '../team/widgets/desktop/desktop_group_workspace_view.dart';
import 'models/dashboard_models.dart';
import 'widgets/desktop/desktop_hero_focus_card.dart';
import 'widgets/desktop/desktop_ongoing_tasks_section.dart';
import 'widgets/desktop/desktop_sidebar.dart';
import 'widgets/desktop/desktop_stats_panel.dart';
import 'widgets/desktop/desktop_top_header.dart';
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
  final int initialTab;

  const HomePage({
    super.key,
    this.userName = 'Jarvis',
    this.initialTab = 0,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentTab;
  String _selectedCategory = 'All';
  TeamModel? _selectedTeam;
  String _selectedTeamCode = '7X29';
  bool _isSidebarCollapsed = false;
  String _desktopSearchQuery = '';
  late final List<DesktopTeamCardData> _desktopTeams =
      List<DesktopTeamCardData>.of(DesktopTeamDirectoryFixtures.defaultTeams);

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    ScheduleRepository().init();
    TaskRepository().init();
    UserProfileRepository().init(userName: widget.userName);
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

  final List<TaskItem> _tasks = [
    const TaskItem(
      id: 'home_task_1',
      title: 'Wallet App Design',
      dueBadge: '6d',
      dueColor: Color(0xFF5B93FF),
      dueTextColor: Colors.white,
      isUrgent: false,
      members: [Color(0xFFF3A683), Color(0xFF786FA6), Color(0xFF63CDDA)],
      progress: 0.46,
      deadline: 'Sat 11 Oct 2026, 23:59 WIB',
      tags: [
        TaskTag(label: 'Team', bg: Color(0xFF786FA6), text: Color(0xFF382A72)),
        TaskTag(label: 'Figma', bg: Color(0xFF778BEB), text: Color(0xFF2E3E8C)),
      ],
      groupMembers: [
        'Andi sukamoto (Leader)',
        'Rayya Gemintang Nusasntarra',
        'Kafi Rijal Perkasa Situmorang',
      ],
      course: 'SSIF-04-REG • Software Testing & Implementation',
      dateCreated: 'Monday, 30 Sep 2026',
      centroidDefuzzification: 'z* = 28.6',
      centroidScale: 'scale(0-100)',
      warningNotice: '*This task is asigned to you, and you can’t delete',
      isCollegeTask: true,
    ),
    const TaskItem(
      id: 'home_task_2',
      title: 'IMPAL Figma Design',
      subtitle: 'Create team UI page',
      dueBadge: '6d',
      dueColor: Color(0xFF5B93FF),
      dueTextColor: Colors.white,
      isUrgent: false,
      deadline: 'Sat 11 Oct 2026, 23:59 WIB',
      tags: [
        TaskTag(label: 'Personal', bg: Color(0xFF778BEB), text: Color(0xFF2E3E8C)),
        TaskTag(label: 'Figma', bg: Color(0xFF778BEB), text: Color(0xFF2E3E8C)),
      ],
      groupMembers: [
        'Personal Task • Jarvis',
      ],
      course: 'SSIF-04-REG • Software Testing & Implementation',
      dateCreated: 'Tuesday, 01 Oct 2026',
      centroidDefuzzification: 'z* = 34.2',
      centroidScale: 'scale(0-100)',
      warningNotice: '*This task is asigned to you, and you can’t delete',
      isCollegeTask: false,
    ),
    const TaskItem(
      id: 'home_task_3',
      title: 'Dashboard & Mobile App',
      dueBadge: '4d',
      dueColor: Color(0xFFFF7D65),
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
        TaskTag(label: 'Team', bg: Color(0xFF786FA6), text: Color(0xFF382A72)),
        TaskTag(label: 'Code', bg: Color(0xFF63CDDA), text: Color(0xFF1C636D)),
      ],
      groupMembers: [
        'Andi sukamoto (Leader)',
        'Rayya Gemintang Nusasntarra',
        'Kafi Rijal Perkasa Situmorang',
      ],
      course: 'SSIF-04-REG • Software Testing & Implementation',
      dateCreated: 'Wednesday, 02 Oct 2026',
      centroidDefuzzification: 'z* = 78.4',
      centroidScale: 'scale(0-100)',
      warningNotice: '*This task is asigned to you, and you can’t delete',
      isCollegeTask: true,
    ),
    const TaskItem(
      id: 'home_task_4',
      title: 'IMPAL Frontend Slicing',
      subtitle: 'Dashboard UI implementation',
      dueBadge: '17d',
      dueColor: Color(0xFF5B93FF),
      dueTextColor: Colors.white,
      isUrgent: false,
      deadline: 'Sat 11 Oct 2026, 23:59 WIB',
      tags: [
        TaskTag(label: 'Personal', bg: Color(0xFF778BEB), text: Color(0xFF2E3E8C)),
        TaskTag(label: 'Code', bg: Color(0xFF63CDDA), text: Color(0xFF1C636D)),
      ],
      groupMembers: [
        'Personal Task • Jarvis',
      ],
      course: 'SSIF-04-REG • Software Testing & Implementation',
      dateCreated: 'Thursday, 03 Oct 2026',
      centroidDefuzzification: 'z* = 19.8',
      centroidScale: 'scale(0-100)',
      warningNotice: '*This task is asigned to you, and you can’t delete',
      isCollegeTask: false,
    ),
  ];

  void _onCategorySelected(String name) {
    setState(() {
      _selectedCategory = _selectedCategory == name ? 'All' : name;
    });
  }

  void _onTabSelected(int index) {
    if (index == _currentTab && _selectedTeam == null) return;
    setState(() {
      if (index != 2 || _selectedTeam != null) {
        _selectedTeam = null;
      }
      _currentTab = index;
    });
  }

  void _openEditSchedule(ScheduleModel item) async {
    if (item.type.trim().toLowerCase() == 'meeting') {
      await PopUpCreateMeeting.showEdit(context, existingSchedule: item);
    } else if (context.isDesktop) {
      await DesktopScheduleModal.show(context, schedule: item);
    } else {
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => ScheduleFormPage(schedule: item)),
      );
    }
  }

  void _toggleScheduleAlert(ScheduleModel item) {
    final updated = item.copyWith(isAlertEnabled: !item.isAlertEnabled);
    ScheduleRepository().updateSchedule(updated);
    PopUpPemberitahuan.show(
      context,
      title: updated.isAlertEnabled ? 'Schedule Alert Active' : 'Schedule Alert Muted',
      message: updated.isAlertEnabled
          ? 'Reminders enabled for "${updated.title}".'
          : 'Reminders muted for "${updated.title}".',
      icon: updated.isAlertEnabled
          ? Icons.notifications_active_rounded
          : Icons.notifications_off_outlined,
      iconBgColor: updated.isAlertEnabled
          ? PopUpPemberitahuan.positiveColor
          : PopUpPemberitahuan.neutralColor,
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
      await ScheduleRepository().deleteSchedule(item.id);
      if (mounted) {
        if (isMeeting) {
          PopUpPemberitahuan.meetingDeleted(context);
        } else {
          PopUpPemberitahuan.scheduleDeleted(context);
        }
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 4),
            backgroundColor: const Color(0xFF323846),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Text(
              isMeeting ? 'Meeting deleted' : 'Schedule deleted',
              style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
            ),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: const Color(0xFFFF7D65),
              onPressed: () {
                ScheduleRepository().addSchedule(item);
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _openEditTask(TaskItem item) async {
    if (item.isTeamTask) {
      final team = TeamRepository().teams.firstWhere(
        (t) => item.title.toLowerCase().contains(
              t.name.toLowerCase().replaceAll('kelompok - ', '').replaceAll(' team', '').trim(),
            ),
        orElse: () => TeamRepository().teams.isNotEmpty
            ? TeamRepository().teams.first
            : const TeamModel(
                id: '1',
                name: 'IMPAL Team',
                memberColors: [
                  Color(0xFFF3A683),
                  Color(0xFF786FA6),
                  Color(0xFF63CDDA),
                ],
              ),
      );

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DashboardTeamPage(
            userName: widget.userName,
            teamName: team.name,
            teamCode: '7X29',
            memberColors: team.memberColors,
            isStandalone: true,
          ),
        ),
      );
      return;
    }

    final updatedModel = context.isDesktop
        ? await DesktopPersonalTaskModal.show(
            context,
            task: item.toTaskItemModel(),
            userInitials: _userInitials,
            onTaskDeleted: () {
              if (!mounted) return;
              setState(() {
                _tasks.removeWhere(
                  (t) =>
                      (t.id.isNotEmpty && t.id == item.id) ||
                      t.title == item.title,
                );
              });
            },
          )
        : await Navigator.of(context).push<TaskItemModel>(
            MaterialPageRoute(
              builder: (_) => EditTaskPage(
                task: item.toTaskItemModel(),
                userInitials: _userInitials,
              ),
            ),
          );

    if (updatedModel != null && mounted) {
      setState(() {
        final index = _tasks.indexWhere(
          (t) => (t.id.isNotEmpty && t.id == updatedModel.id) || t.title == item.title,
        );
        if (index != -1) {
          _tasks[index] = TaskItem.fromTaskItemModel(updatedModel);
        }
      });
      PopUpPemberitahuan.taskUpdated(context, taskName: updatedModel.title);
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
                onToggleAlert: _toggleScheduleAlert,
              ),
              const SizedBox(height: 16),
              HomeCategoriesSection(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: _onCategorySelected,
              ),
              const SizedBox(height: 16),
              _buildAiSmartPriorityBanner(),
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
                  showBackButton: false,
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
                          showBackButton: false,
                          onOpenSchedule: () => setState(() => _currentTab = 3),
                          onTeamSelected: (team) => setState(() => _selectedTeam = team),
                        ))
                  : (_currentTab == 1
                      ? TaskContentView(
                          key: const ValueKey('task_tab_content'),
                          userName: widget.userName,
                          showBackButton: false,
                        )
                      : dashboardContent)),
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

    final canPop = _currentTab == 0 && _selectedTeam == null;
    final wrappedHomeContent = PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedTeam != null) {
          setState(() => _selectedTeam = null);
        } else if (_currentTab != 0) {
          _onTabSelected(0);
        }
      },
      child: homeContent,
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: const Color(0xFF282D37),
        body: SafeArea(
          top: true,
          bottom: false,
          child: wrappedHomeContent,
        ),
      );
    }

    if (context.isDesktop) {
      return _buildDesktopShell(context, canPop);
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
                child: wrappedHomeContent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiSmartPriorityBanner() {
    return ListenableBuilder(
      listenable: SmartPriorityRepository.instance,
      builder: (context, _) {
        final repo = SmartPriorityRepository.instance;
        final isEngineActive = repo.isEngineActive;
        final topPriority = repo.topPriority;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF323846),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SmartPriorityPage(userName: widget.userName),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isEngineActive
                            ? const Color(0xFFFA6144)
                            : const Color(0xFF475569),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          isEngineActive
                              ? Icons.psychology_rounded
                              : Icons.psychology_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Flexible(
                                child: Text(
                                  'AI Smart Priority',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isEngineActive
                                      ? const Color(0xFF10B981)
                                          .withValues(alpha: 0.15)
                                      : const Color(0xFF334155),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: isEngineActive
                                        ? const Color(0xFF10B981)
                                            .withValues(alpha: 0.4)
                                        : const Color(0xFF64748B),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  isEngineActive
                                      ? 'Mamdani Active'
                                      : 'Mamdani Inactive',
                                  style: TextStyle(
                                    color: isEngineActive
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF94A3B8),
                                    fontSize: 9.5,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            !isEngineActive
                                ? 'AI prioritization is currently paused'
                                : (topPriority != null
                                    ? '#1 ${topPriority.title} (${topPriority.score.toStringAsFixed(1)} High)'
                                    : 'Mamdani Centroid Defuzzification Active'),
                            overflow: TextOverflow.ellipsis,
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
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFFFF7D65),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTaskCompleted(TaskItem task) {
    HapticFeedback.lightImpact();
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id || (t.id.isEmpty && t.title == task.title));
    });
    TaskRepository().completeTaskFromHome(task.toTaskItemModel());
    PopUpPemberitahuan.taskCompleted(context, taskName: task.title);
  }

  Widget _buildOngoingTaskSection() {
    final activeTasks = _tasks.where((t) => !t.isCompleted).toList();
    final displayedTasks = _selectedCategory == 'All'
        ? activeTasks
        : _selectedCategory.toLowerCase() == 'college'
            ? activeTasks.where((t) => t.isCollegeTask).toList()
            : activeTasks.where((t) => !t.isCollegeTask).toList();

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
                _onTabSelected(1);
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
        if (displayedTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: AppColors.textMuted,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'No ongoing tasks in $_selectedCategory',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          )
        else
          for (int i = 0; i < displayedTasks.length; i++)
            RepaintBoundary(
              child: HomeTaskCard(
                key: ValueKey('home_task_${displayedTasks[i].id.isNotEmpty ? displayedTasks[i].id : displayedTasks[i].title}'),
                task: displayedTasks[i],
                isLast: i == displayedTasks.length - 1,
                onEdit: () => _openEditTask(displayedTasks[i]),
                onDismissed: () => _handleTaskCompleted(displayedTasks[i]),
              ),
            ),
      ],
    );
  }

  String get _userInitials => widget.userName.trim().length >= 2
      ? widget.userName.trim().substring(0, 2).toUpperCase()
      : 'JS';

  Future<void> _openCreateTask() async {
    final newTask = context.isDesktop
        ? await DesktopPersonalTaskModal.show(
            context,
            userInitials: _userInitials,
            onTaskCreated: (task) {
              TaskRepository().addTask(task);
            },
          )
        : await Navigator.of(context).push<TaskItemModel>(
            MaterialPageRoute(
              builder: (_) => CreateTaskPage(
                userInitials: _userInitials,
                onTaskCreated: (task) {
                  TaskRepository().addTask(task);
                },
              ),
            ),
          );

    if (newTask != null && mounted) {
      if (!TaskRepository().tasks.any((t) => t.id == newTask.id)) {
        TaskRepository().addTask(newTask);
      }
      setState(() {
        _tasks.insert(0, TaskItem.fromTaskItemModel(newTask));
      });
    }
  }

  Future<void> _openCreateSchedule() async {
    if (context.isDesktop) {
      await DesktopScheduleModal.show(context);
      return;
    }
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const ScheduleFormPage(),
      ),
    );
  }

  void _handleJoinTeamByCode(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    if (code.length < 4) {
      PopUpPemberitahuan.teamWarning(
        context,
        title: 'Invalid Invite Code',
        message: 'Please enter a valid 4+ character team invite code.',
      );
      return;
    }

    final existing = _desktopTeams
        .where((team) => team.inviteCode.toUpperCase() == code)
        .toList();
    if (existing.isNotEmpty) {
      PopUpPemberitahuan.teamJoined(
        context,
        teamName: existing.first.name,
        inviteCode: code,
      );
      return;
    }

    final newCard = DesktopTeamCardData(
      id: 'team_joined_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Kelompok $code',
      subtitle: 'Tim kolaborasi via kode undangan $code',
      badgeLabel: 'Mata Kuliah',
      badgeBgColor: const Color(0xFF47373B),
      badgeTextColor: AppColors.primaryAccent,
      category: TeamDirectoryCategory.mataKuliah,
      members: [
        TeamMemberAvatar(
          initials: widget.userName.isNotEmpty
              ? widget.userName[0].toUpperCase()
              : 'R',
          bgColor: AppColors.primaryAccent,
        ),
      ],
      completedTasks: 1,
      totalTasks: 5,
      progressColor: AppColors.primaryAccent,
      percentTextColor: AppColors.primaryAccent,
      inviteCode: code,
      isPrimaryAction: true,
    );

    setState(() {
      _desktopTeams.add(newCard);
    });
    TeamRepository().addTeam(newCard.toTeamModel());

    PopUpPemberitahuan.teamJoined(
      context,
      teamName: newCard.name,
      inviteCode: code,
    );
  }

  Future<void> _openJoinTeamDialog() async {
    final code = await PopUpJoinTeam.show(context);
    if (!mounted || code == null) return;
    _handleJoinTeamByCode(code);
  }

  Future<void> _openCreateTeamDialog() async {
    final result = await PopUpCreateTeam.show(context);
    if (!mounted || result == null) return;

    final newCard = DesktopTeamCardData(
      id: 'team_created_${DateTime.now().millisecondsSinceEpoch}',
      name: result.name,
      subtitle: result.description.isNotEmpty
          ? result.description
          : 'Kelompok kolaborasi baru',
      badgeLabel: 'Mata Kuliah',
      badgeBgColor: const Color(0xFF47373B),
      badgeTextColor: AppColors.primaryAccent,
      category: TeamDirectoryCategory.mataKuliah,
      members: [
        TeamMemberAvatar(
          initials: widget.userName.isNotEmpty
              ? widget.userName[0].toUpperCase()
              : 'R',
          bgColor: AppColors.primaryAccent,
        ),
      ],
      completedTasks: 0,
      totalTasks: 5,
      progressColor: AppColors.primaryAccent,
      percentTextColor: AppColors.primaryAccent,
      inviteCode: result.inviteCode,
      isPrimaryAction: true,
    );

    setState(() {
      _desktopTeams.add(newCard);
    });
    TeamRepository().addTeam(newCard.toTeamModel());

    PopUpPemberitahuan.teamCreated(
      context,
      teamName: result.name,
      inviteCode: result.inviteCode,
    );
  }

  void _showDesktopLogoutDialog() {
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

  DesktopNavDestination get _activeDesktopDestination {
    switch (_currentTab) {
      case 1:
        return DesktopNavDestination.tasks;
      case 2:
        return DesktopNavDestination.teamMembers;
      case 3:
        return DesktopNavDestination.schedule;
      case 4:
        return DesktopNavDestination.settings;
      default:
        return DesktopNavDestination.dashboard;
    }
  }

  (String, String) get _desktopHeaderCopy {
    switch (_currentTab) {
      case 1:
        return (
          'Tasks Management',
          'Organize, prioritize, and track your academic assignments',
        );
      case 2:
        if (_selectedTeam != null) {
          return (
            _selectedTeam!.name,
            'Implementasi & Pengujian Perangkat Lunak • SIF-45-02',
          );
        }
        return (
          'Study Teams & Groups',
          'Manage course study teams, team meetings, and collaboration progress',
        );
      case 3:
        return (
          'Weekly Schedule Matrix',
          'Track your weekly lectures, lab sessions, and group study meetings',
        );
      case 4:
        return (
          'Profile & Settings',
          'Kelola identitas mahasiswa, preferensi sistem cerdas AI, dan keamanan akun',
        );
      default:
        return (
          'Dashboard Overview',
          'Stay productive and keep track of your ongoing courses & tasks',
        );
    }
  }

  void _onDesktopDestinationSelected(DesktopNavDestination destination) {
    switch (destination) {
      case DesktopNavDestination.dashboard:
        _onTabSelected(0);
      case DesktopNavDestination.schedule:
        _onTabSelected(3);
      case DesktopNavDestination.tasks:
        _onTabSelected(1);
      case DesktopNavDestination.teamMembers:
        _onTabSelected(2);
      case DesktopNavDestination.settings:
        _onTabSelected(4);
    }
  }

  Widget _buildVoiceActiveBadge(BuildContext context) {
    return const DesktopVoiceActiveBadge();
  }

  Widget _buildDesktopShell(BuildContext context, bool canPop) {
    final activeTasks = _tasks.where((t) => !t.isCompleted).toList();
    final completedCount = _tasks.where((t) => t.isCompleted).length;
    final repoTasks = TaskRepository().tasks;
    final totalPendingCount = repoTasks.isNotEmpty
        ? repoTasks.where((t) => !t.isCompleted).length
        : activeTasks.length;

    final scheduleCount = ScheduleRepository().schedulesNotifier.value.isNotEmpty
        ? ScheduleRepository().schedulesNotifier.value.length
        : _schedules.length;

    final (headerTitle, headerSubtitle) = _desktopHeaderCopy;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedTeam != null) {
          setState(() => _selectedTeam = null);
        } else if (_currentTab != 0) {
          _onTabSelected(0);
        }
      },
      child: UnfocusOnTap(
        child: Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: Row(
            children: [
              DesktopSidebar(
                activeDestination: _activeDesktopDestination,
                isCollapsed: _isSidebarCollapsed,
                onToggleCollapse: () {
                  setState(() => _isSidebarCollapsed = !_isSidebarCollapsed);
                },
                onDestinationSelected: _onDesktopDestinationSelected,
                userName: widget.userName,
                scheduleCount: scheduleCount,
                pendingTaskCount: totalPendingCount,
                teamCount: _desktopTeams.length,
                onProfileTap: () => _onTabSelected(4),
                onLogoutTap: _showDesktopLogoutDialog,
              ),
              Expanded(
                child: Column(
                  children: [
                    Builder(
                      builder: (_) {
                        final isGroupDirectoryRoot =
                            _currentTab == 2 && _selectedTeam == null;
                        final isGroupWorkspace =
                            _currentTab == 2 && _selectedTeam != null;
                        final isProfileSettings = _currentTab == 4;
                        return DesktopTopHeader(
                          title: headerTitle,
                          subtitle: headerSubtitle,
                          breadcrumbParent:
                              isGroupWorkspace ? 'Team Members' : null,
                          onBreadcrumbParentTap: isGroupWorkspace
                              ? () => setState(() {
                                    _selectedTeam = null;
                                    _desktopSearchQuery = '';
                                  })
                              : null,
                          searchQuery: _desktopSearchQuery,
                          searchHint: isProfileSettings
                              ? 'Search settings...'
                              : (isGroupDirectoryRoot
                                  ? 'Search study teams or courses...'
                                  : (isGroupWorkspace
                                      ? 'Search tasks in workspace...'
                                      : (_currentTab == 3
                                          ? 'Search schedule or class...'
                                          : 'Search tasks or courses...'))),
                          searchBgColor: (isGroupDirectoryRoot ||
                                  isGroupWorkspace ||
                                  isProfileSettings)
                              ? AppColors.bgSidebar
                              : AppColors.bgCard,
                          showLeadingSearchIcon: isGroupDirectoryRoot ||
                              isGroupWorkspace ||
                              isProfileSettings,
                          showShortcutHint:
                              !isGroupDirectoryRoot && !isGroupWorkspace,
                          addButtonLabel: isProfileSettings
                              ? 'Edit Profile'
                              : (isGroupDirectoryRoot
                                  ? '+ Create Team'
                                  : (_currentTab == 3
                                      ? '+ Add Schedule'
                                      : (_currentTab == 1
                                          ? '+ Add New Task'
                                          : '+ Add Task'))),
                          addButtonColor: (isGroupDirectoryRoot ||
                                  isProfileSettings)
                              ? AppColors.primaryAccent
                              : AppColors.primary,
                          secondaryButtonLabel:
                              isGroupDirectoryRoot ? 'Join Team' : null,
                          secondaryButtonIcon: isGroupDirectoryRoot
                              ? Icons.group_add_outlined
                              : null,
                          onSecondaryButtonTap: isGroupDirectoryRoot
                              ? _openJoinTeamDialog
                              : null,
                          showNotificationBell: _currentTab != 3 &&
                              !isProfileSettings,
                          titleFontSize: isGroupDirectoryRoot ? 18 : 22,
                          horizontalPadding: (isGroupDirectoryRoot ||
                                  isGroupWorkspace ||
                                  isProfileSettings)
                              ? (context.screenWidth < 1200 ? 24 : 32)
                              : 28,
                          customRightAction: isGroupWorkspace
                              ? _buildVoiceActiveBadge(context)
                              : null,
                          onSearchChanged: (value) {
                            setState(() => _desktopSearchQuery = value);
                          },
                          onAddTaskTap: isProfileSettings
                              ? () => DesktopEditProfileModal.show(
                                    context,
                                    profile: UserProfileRepository().profile,
                                  )
                              : (isGroupDirectoryRoot
                                  ? _openCreateTeamDialog
                                  : (_currentTab == 3
                                      ? _openCreateSchedule
                                      : _openCreateTask)),
                        );
                      },
                    ),
                    Expanded(
                      child: _buildDesktopBody(
                        context,
                        activeTasks: activeTasks,
                        completedCount: completedCount,
                        totalPendingCount: totalPendingCount,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopBody(
    BuildContext context, {
    required List<TaskItem> activeTasks,
    required int completedCount,
    required int totalPendingCount,
  }) {
    if (_currentTab == 1) {
      return DesktopTasksManagementView(
        key: const ValueKey('desktop_tasks_management_view'),
        userName: widget.userName,
        searchQuery: _desktopSearchQuery,
        onOpenScheduleTimeline: () => _onTabSelected(3),
        onOpenTeamDashboard: (team) {
          setState(() {
            _selectedTeam = team;
            _desktopSearchQuery = '';
            _currentTab = 2;
          });
        },
        onResetSearch: () => setState(() => _desktopSearchQuery = ''),
      );
    }

    if (_currentTab == 4) {
      return DesktopProfileSettingsView(
        key: const ValueKey('desktop_profile_settings_view'),
        searchQuery: _desktopSearchQuery,
        fallbackUserName: widget.userName,
      );
    }

    if (_currentTab == 3) {
      return DesktopScheduleMatrixView(
        key: const ValueKey('desktop_schedule_matrix_view'),
        searchQuery: _desktopSearchQuery,
        onResetSearch: () => setState(() => _desktopSearchQuery = ''),
      );
    }

    if (_currentTab != 0) {
      if (_selectedTeam == null) {
        return DesktopGroupDirectoryView(
          key: const ValueKey('desktop_team_tab'),
          searchQuery: _desktopSearchQuery,
          teams: _desktopTeams,
          onJoinByCode: _handleJoinTeamByCode,
          onOpenScheduleTap: () => _onTabSelected(3),
          onTeamSelected: (team) {
            final match = _desktopTeams
                .where((item) => item.id == team.id)
                .toList();
            setState(() {
              _selectedTeam = team;
              _desktopSearchQuery = '';
              _selectedTeamCode =
                  match.isNotEmpty ? match.first.inviteCode : '7X29';
            });
          },
        );
      }

      return DashboardTeamPage(
        key: ValueKey('desktop_team_dashboard_${_selectedTeam!.id}'),
        userName: widget.userName,
        teamName: _selectedTeam!.name,
        teamCode: _selectedTeamCode,
        searchQuery: _desktopSearchQuery,
        memberColors: _selectedTeam!.memberColors,
        isStandalone: false,
        onBack: () => setState(() {
          _selectedTeam = null;
          _desktopSearchQuery = '';
        }),
      );
    }

    // Apply category + desktop search filters
    var filteredTasks = _selectedCategory == 'All'
        ? activeTasks
        : _selectedCategory.toLowerCase() == 'college'
            ? activeTasks.where((t) => t.isCollegeTask).toList()
            : activeTasks.where((t) => !t.isCollegeTask).toList();

    final query = _desktopSearchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      filteredTasks = filteredTasks.where((t) {
        return t.title.toLowerCase().contains(query) ||
            (t.subtitle?.toLowerCase().contains(query) ?? false) ||
            t.course.toLowerCase().contains(query) ||
            t.tags.any((tag) => tag.label.toLowerCase().contains(query));
      }).toList();
    }

    final featuredTask = activeTasks.isNotEmpty
        ? activeTasks.first
        : const TaskItem(
            id: 'hero_fallback',
            title: 'Wallet App Design',
            subtitle: 'Interactive Prototype & Component Architecture',
            dueBadge: '6d',
            dueColor: Color(0xFF5B93FF),
            dueTextColor: Colors.white,
            isUrgent: false,
            progress: 0.46,
            deadline: 'Sat 11 Oct 2026, 23:59 WIB',
            tags: [],
          );

    // Compute live KPI metrics
    final progressItems = activeTasks.where((t) => t.progress != null).toList();
    final avgProgress = progressItems.isEmpty
        ? 57
        : ((progressItems.fold<double>(0, (sum, t) => sum + t.progress!) /
                    progressItems.length) *
                100)
            .round();
    final urgentCount = activeTasks.where((t) {
      if (t.isUrgent) return true;
      final days = int.tryParse(t.dueBadge.replaceAll(RegExp(r'[^0-9]'), ''));
      return days != null && days < 6;
    }).length;
    final collegeCount = activeTasks.where((t) => t.isCollegeTask).length;
    final personalCount = activeTasks.where((t) => !t.isCollegeTask).length;

    return SingleChildScrollView(
      key: const ValueKey('desktop_homepage_scroll'),
      padding: EdgeInsets.fromLTRB(
        context.rSpacing(28),
        context.rSpacing(22),
        context.rSpacing(28),
        context.rSpacing(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DesktopHeroFocusCard(
                  featuredTask: featuredTask,
                  onContinueTap: () => _openEditTask(featuredTask),
                ),
                const SizedBox(height: 24),
                DesktopOngoingTasksSection(
                  tasks: filteredTasks,
                  totalPendingCount: totalPendingCount,
                  collegeCount: collegeCount,
                  personalCount: personalCount,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (cat) {
                    setState(() => _selectedCategory = cat);
                  },
                  onSeeAllTap: () => _onTabSelected(1),
                  onTaskTap: _openEditTask,
                  onTaskToggleComplete: _handleTaskCompleted,
                  onClearFilterTap: () {
                    setState(() {
                      _selectedCategory = 'All';
                      _desktopSearchQuery = '';
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: context.screenWidth < 1200 ? 310 : 350,
            child: DesktopStatsPanel(
              fallbackSchedule: _schedules.first,
              avgProgressPercent: avgProgress,
              pendingCount: totalPendingCount,
              completedCount: completedCount,
              urgentDeadlineCount: urgentCount,
              collegeTaskCount: collegeCount,
              personalTaskCount: personalCount,
              onScheduleSeeAllTap: () => _onTabSelected(3),
              onEditSchedule: _openEditSchedule,
              onDeleteSchedule: _deleteSchedule,
              onToggleScheduleAlert: _toggleScheduleAlert,
              onSmartPriorityTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SmartPriorityPage(userName: widget.userName),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
