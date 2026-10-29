import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../dashboard/home_page.dart';
import '../dashboard/widgets/home_header.dart';
import '../team/dashboard_team_page.dart';
import '../team/models/team_model.dart';
import '../team/models/team_repository.dart';
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
  String _selectedFilter = 'Today';

  @override
  void initState() {
    super.initState();
    _repository.init();
    _repository.addListener(_onRepositoryChanged);
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }

  void _onRepositoryChanged() {
    if (mounted) setState(() {});
  }

  List<TaskItemModel> get _filteredTasks {
    final all = _repository.tasks;
    if (_selectedFilter == 'All') return all;
    if (_selectedFilter == 'Today') {
      return all;
    }
    if (_selectedFilter == 'Next 7 Days') {
      return all.where((t) => t.priority != TaskPriorityLevel.low).toList();
    }
    if (_selectedFilter == 'Overdue') {
      return all.where((t) => t.priority == TaskPriorityLevel.high).toList();
    }
    return all;
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
    final counts = _repository.getPriorityCounts();
    final highCount = counts[TaskPriorityLevel.high] ?? 3;
    final mediumCount = counts[TaskPriorityLevel.medium] ?? 1;
    final lowCount = counts[TaskPriorityLevel.low] ?? 2;
    final tasks = _filteredTasks;

    return CustomScrollView(
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
              ),
              SizedBox(height: context.rSpacing(16)),

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
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(20),
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: context.rSpacing(10),
                  ),
                  child: TaskExpandableCard(
                    key: ValueKey('task_card_${task.id}'),
                    task: task,
                    isLast: index == tasks.length - 1,
                    onEdit: () => _openEditTask(task),
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
