import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../dashboard/home_page.dart';
import '../dashboard/widgets/home_header.dart';
import '../smart_system/models/smart_priority_repository.dart';
import '../smart_system/smart_priority_page.dart';
import '../team/dashboard_team_page.dart';
import '../team/models/team_model.dart';
import '../team/models/team_repository.dart';
import '../team/models/team_task_repository.dart';
import 'create_task.dart';
import 'models/task_repository.dart';
import 'widgets/task_expandable_card.dart';
import 'widgets/task_filter_bar.dart';
import 'widgets/task_timeline_summary.dart';

// Re-exports & Aliases for backward compatibility
export 'edit_task.dart';
export 'models/task_item_model.dart';
export 'widgets/task_expandable_card.dart';

typedef Task = TaskPage;

/// Main Task Page in IMPAL Smart Task Manager.
///
/// Can be used as a standalone screen or renders the shared Single Shell
/// HomePage with initialTab: 1 for smooth navbar sliding animations.
class TaskPage extends StatelessWidget {
  final String userName;
  final String userInitials;
  final bool isStandalone;

  const TaskPage({
    super.key,
    this.userName = 'Jarvis',
    this.userInitials = 'JS',
    this.isStandalone = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isStandalone) {
      return HomePage(userName: userName, initialTab: 1);
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            TaskContentView(
              userName: userName,
              userInitials: userInitials,
              showBackButton: false,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ImpalBottomNavBar(
                currentTab: 1,
                onTabSelected: (index) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => HomePage(
                        userName: userName,
                        initialTab: index,
                      ),
                    ),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable Task Content View embeddable into HomePage or standalone views.
///
/// Features:
/// - TaskHeader with greeting and pending counter
/// - Priority Timeline summary (3 High, 1 Medium, 2 Low)
/// - Compact TaskFilterBar (All, Today, Next 7 Days, Overdue)
/// - Add Task button navigating to CreateTaskPage
/// - Today Task list with Expandable Home-style Cards
class TaskContentView extends StatefulWidget {
  final String userName;
  final String userInitials;
  final bool showBackButton;
  final VoidCallback? onBack;

  const TaskContentView({
    super.key,
    this.userName = 'Jarvis',
    this.userInitials = 'JS',
    this.showBackButton = false,
    this.onBack,
  });

  @override
  State<TaskContentView> createState() => _TaskContentViewState();
}

class _TaskContentViewState extends State<TaskContentView> {
  final TaskRepository _repository = TaskRepository();
  final TeamTaskRepository _teamTaskRepository = TeamTaskRepository();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _firstActiveTaskKey = GlobalKey();
  String _selectedFilter = 'Today';
  String? _selectedPriority;
  bool _hasAutoScrolled = false;

  @override
  void initState() {
    super.initState();
    _repository.init();
    _repository.addListener(_onRepositoryChanged);
    _teamTaskRepository.init();
    _teamTaskRepository.addListener(_onRepositoryChanged);
    _triggerAutoScroll();
  }

  void _triggerAutoScroll() {
    if (_hasAutoScrolled) return;
    Future.delayed(const Duration(milliseconds: 240), () {
      if (!mounted || _hasAutoScrolled) return;
      if (_firstActiveTaskKey.currentContext != null) {
        Scrollable.ensureVisible(
          _firstActiveTaskKey.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          alignment: 0.22,
        );
        _hasAutoScrolled = true;
      }
    });
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    _teamTaskRepository.removeListener(_onRepositoryChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onRepositoryChanged() {
    if (mounted) setState(() {});
  }

  bool _isTeamTaskAssignedToCurrentUser(TeamTaskModel task) {
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

  TaskItemModel _convertTeamTaskToTaskItem(TeamTaskModel task) {
    final priorityLevel = task.priority == TaskPriority.high
        ? TaskPriorityLevel.high
        : (task.priority == TaskPriority.medium
            ? TaskPriorityLevel.medium
            : TaskPriorityLevel.low);

    return TaskItemModel(
      id: 'team_task_${task.id}',
      title: task.title,
      teamName: 'Kelompok IMPAL',
      priority: priorityLevel,
      durationBadge: task.effectiveDueBadge,
      durationBadgeColor: task.isUrgent
          ? const Color(0xFFFF7D65)
          : const Color(0xFF5B93FF),
      durationTextColor: Colors.white,
      subtitle: task.assignedTo,
      deadlineDate: task.deadline ?? DateTime(2026, 10, 18, 23, 59),
      formattedDeadline: 'Sun 18 Oct 2026, ${task.timeRange}',
      memberAvatars: task.colors,
      tags: const [
        TaskTagModel(
          label: 'Team',
          backgroundColor: Color(0xFF786FA6),
          textColor: Color(0xFF4A3C8C),
        ),
      ],
      groupMembers: [task.assignedTo],
      course: 'Kelompok IMPAL • 7X29',
      notes: task.description ?? '',
      isCompleted: task.isDone,
      isAssignedToUser: true,
      isCollegeTask: true,
      isAlertEnabled: task.isAlertEnabled,
    );
  }

  List<TaskItemModel> get _filteredTasks {
    // 1. Personal & College tasks, plus Team projects in TaskRepository assigned to user
    final repoTasks = _repository.tasks.where((t) {
      if (!t.isTeamTask) return true;
      return t.isAssignedToUser;
    }).toList();

    // 2. Team tasks from TeamTaskRepository assigned to current user
    final teamTasks = _teamTaskRepository
        .getTasks('7X29')
        .where(_isTeamTaskAssignedToCurrentUser)
        .map(_convertTeamTaskToTaskItem)
        .where((converted) => !repoTasks
            .any((r) => r.title.toLowerCase() == converted.title.toLowerCase()))
        .toList();

    var list = [...repoTasks, ...teamTasks];
    if (_selectedFilter == 'Next 7 Days') {
      list = list.where((t) => t.priority != TaskPriorityLevel.low).toList();
    } else if (_selectedFilter == 'Overdue') {
      list = list.where((t) => t.priority == TaskPriorityLevel.high).toList();
    }

    if (_selectedPriority != null) {
      list = list
          .where((t) =>
              t.priorityLabel.toLowerCase() ==
              _selectedPriority!.toLowerCase())
          .toList();
    }
    return list;
  }

  List<TaskItemModel> get _sortedTasks {
    final list = _filteredTasks;
    final completed = list.where((t) => t.isCompleted).toList();
    final active = list.where((t) => !t.isCompleted).toList();

    active.sort(TaskItemModel.compareTaskDeadlines);
    return [...completed, ...active];
  }

  Future<void> _openCreateTask() async {
    final newTask = await Navigator.of(context).push<TaskItemModel>(
      MaterialPageRoute(
        builder: (_) => CreateTaskPage(
          userInitials: widget.userInitials,
          onTaskCreated: (task) {
            _repository.addTask(task);
          },
        ),
      ),
    );

    if (newTask != null && mounted) {
      if (!_repository.tasks.any((t) => t.id == newTask.id)) {
        _repository.addTask(newTask);
      }
    }
  }

  Future<void> _openEditTask(TaskItemModel task) async {
    if (task.isTeamTask) {
      final team = TeamRepository().teams.firstWhere(
        (t) => task.title.toLowerCase().contains(t.name.toLowerCase().replaceAll('kelompok - ', '').trim()),
        orElse: () => TeamRepository().teams.isNotEmpty
            ? TeamRepository().teams.first
            : const TeamModel(
                id: '1',
                name: 'Kelompok - IMPAL',
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

    final updatedTask = await Navigator.of(context).push<TaskItemModel>(
      MaterialPageRoute(
        builder: (_) => EditTaskPage(
          task: task,
          userInitials: widget.userInitials,
          onTaskUpdated: (updated) {
            _repository.updateTask(updated);
          },
        ),
      ),
    );

    if (updatedTask != null && mounted) {
      _repository.updateTask(updatedTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    int highCount = 0;
    int mediumCount = 0;
    int lowCount = 0;

    final allPersonalAndAssigned = _repository.tasks.where((t) {
      if (!t.isTeamTask) return true;
      return t.isAssignedToUser;
    }).toList();

    final teamTasks = _teamTaskRepository
        .getTasks('7X29')
        .where(_isTeamTaskAssignedToCurrentUser)
        .map(_convertTeamTaskToTaskItem)
        .where((converted) => !allPersonalAndAssigned
            .any((r) => r.title.toLowerCase() == converted.title.toLowerCase()))
        .toList();

    for (final task in [...allPersonalAndAssigned, ...teamTasks]) {
      switch (task.priority) {
        case TaskPriorityLevel.high:
          highCount++;
          break;
        case TaskPriorityLevel.medium:
          mediumCount++;
          break;
        case TaskPriorityLevel.low:
          lowCount++;
          break;
      }
    }

    final tasks = _sortedTasks;
    final firstActiveId = tasks.where((t) => !t.isCompleted).map((t) => t.id).firstOrNull;

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Unified Home Header
              HomeHeader(
                userName: widget.userName,
                subtitle: 'Task',
              ),
              SizedBox(height: context.rSpacing(18)),

              // 2. Timeline Summary Cards (3 High, 1 Medium, 2 Low)
              TaskTimelineSummary(
                highCount: highCount,
                mediumCount: mediumCount,
                lowCount: lowCount,
                selectedPriority: _selectedPriority,
                onPrioritySelected: (p) => setState(() => _selectedPriority = p),
              ),
              SizedBox(height: context.rSpacing(10)),

              // AI Smart Priority Ranking Shortcut
              ListenableBuilder(
                listenable: SmartPriorityRepository.instance,
                builder: (context, _) {
                  final isEngineActive =
                      SmartPriorityRepository.instance.isEngineActive;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                SmartPriorityPage(userName: widget.userName),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.rSpacing(12),
                          vertical: context.rSpacing(9),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isEngineActive
                                  ? Icons.psychology_rounded
                                  : Icons.psychology_outlined,
                              size: context.rIcon(18),
                              color: isEngineActive
                                  ? AppColors.primary
                                  : const Color(0xFF64748B),
                            ),
                            SizedBox(width: context.rSpacing(8)),
                            Expanded(
                              child: Text(
                                'AI Smart Priority Ranking',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      context.rFont(12, min: 10.5, max: 13.5),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isEngineActive
                                    ? const Color(0xFF10B981)
                                        .withValues(alpha: 0.15)
                                    : const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                isEngineActive
                                    ? 'Mamdani CoG'
                                    : 'Mamdani Inactive',
                                style: TextStyle(
                                  color: isEngineActive
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF94A3B8),
                                  fontSize: context.rFont(10, min: 9, max: 11),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(width: context.rSpacing(6)),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: context.rIcon(12),
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: context.rSpacing(14)),

              // 3. Compact Filter Bar (All, Today, Next 7 Days, Overdue)
              TaskFilterBar(
                selectedFilter: _selectedFilter,
                onFilterSelected: (f) => setState(() => _selectedFilter = f),
              ),
              SizedBox(height: context.rSpacing(16)),

              // 4. "Add Task" Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const ValueKey('add_task_button'),
                  onPressed: _openCreateTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(15, min: 13, max: 17),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.rSpacing(20)),

              // 5. "Today Task" Section Title
              Text(
                'Today Task',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: context.rFont(18, min: 16, max: 22),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.20,
                ),
              ),
              SizedBox(height: context.rSpacing(12)),
            ]),
          ),
        ),

        // 6. Virtualized Task Cards List with smooth expansion using HomeTaskCard layout
        if (tasks.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.rSpacing(20),
                vertical: context.rSpacing(20),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: context.rSpacing(20),
                  vertical: context.rSpacing(28),
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle, width: 0.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    SizedBox(height: context.rSpacing(12)),
                    Text(
                      'No Tasks Found',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(16, min: 14, max: 18),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: context.rSpacing(6)),
                    Text(
                      'No tasks match the selected filter criteria.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: context.rFont(12, min: 11, max: 13),
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: context.rSpacing(14)),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = 'All';
                          _selectedPriority = null;
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Reset Filter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryAccent,
                        side: const BorderSide(
                          color: AppColors.primaryAccent,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: context.rSpacing(20),
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = tasks[index];
                  final isFirstActive = task.id == firstActiveId;
                  return Padding(
                    key: isFirstActive ? _firstActiveTaskKey : null,
                    padding: EdgeInsets.only(
                      bottom: context.rSpacing(10),
                    ),
                    child: TaskExpandableCard(
                      key: ValueKey('task_card_${task.id}'),
                      task: task,
                      isLast: index == tasks.length - 1,
                      onEdit: () => _openEditTask(task),
                      onToggleCompletion: () {
                        HapticFeedback.lightImpact();
                        final willComplete = !task.isCompleted;
                        if (task.id.startsWith('team_task_')) {
                          final realId = task.id.replaceFirst('team_task_', '');
                          _teamTaskRepository.toggleTaskDone('7X29', realId);
                        } else {
                          _repository.toggleTaskCompletion(task.id);
                        }
                        if (willComplete) {
                          PopUpPemberitahuan.taskCompleted(context, taskName: task.title);
                        } else {
                          PopUpPemberitahuan.taskReopened(context, taskName: task.title);
                        }
                      },
                    ),
                  );
                },
                childCount: tasks.length,
              ),
            ),
          ),

        // Bottom clearance for the scooped navigation bar
        SliverToBoxAdapter(
          child: SizedBox(height: context.rSpacing(100)),
        ),
      ],
    );
  }
}
