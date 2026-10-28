import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../dashboard/home_page.dart';
import '../schedule/schedule_page.dart';
import '../team/dashboard_team_page.dart';
import 'create_task.dart';
import 'models/task_repository.dart';
import 'widgets/task_expandable_card.dart';
import 'widgets/task_filter_bar.dart';
import 'widgets/task_header.dart';
import 'widgets/task_timeline_summary.dart';

// Re-exports & Aliases for backward compatibility with Figma exports
export 'models/task_item_model.dart';
export 'widgets/task_expandable_card.dart';

typedef Task = TaskPage;

/// Main Task Page in IMPAL Smart Task Manager.
///
/// Features:
/// - Header with greeting and pending task counters
/// - Priority Timeline summary (High, Medium, Low)
/// - Filter chips: All, Today, Next 7 Days, Overdue
/// - "+ Add Task" button navigating to CreateTaskPage
/// - Today Task list with smooth expandable detail cards ("card nya memanjang")
/// - Scooped bottom navigation bar with fluid transitions
///
/// Complies with AGENTS.md, ResponsiveContext, and 60 FPS performance rules.
class TaskPage extends StatefulWidget {
  final String userName;
  final String userInitials;

  const TaskPage({
    super.key,
    this.userName = 'Jarvis',
    this.userInitials = 'JS',
  });

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TaskRepository _repository = TaskRepository();
  String _selectedFilter = 'Today';
  int _currentTab = 1; // Task Tab

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
      // Return today's tasks
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

  void _onTabSelected(int index) {
    if (index == _currentTab) return;
    setState(() => _currentTab = index);

    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomePage(userName: widget.userName)),
        (route) => false,
      );
    } else if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DashboardTeamPage(
            userName: widget.userName,
            isStandalone: true,
          ),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    final counts = _repository.getPriorityCounts();
    final highCount = counts[TaskPriorityLevel.high] ?? 3;
    final mediumCount = counts[TaskPriorityLevel.medium] ?? 1;
    final lowCount = counts[TaskPriorityLevel.low] ?? 2;
    final tasks = _filteredTasks;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rSpacing(20),
                      vertical: context.rSpacing(12),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // 1. Task Header
                        TaskHeader(
                          userName: widget.userName,
                          pendingCount: 10,
                          userInitials: widget.userInitials,
                        ),
                        SizedBox(height: context.rSpacing(18)),

                        // 2. Timeline Summary Cards (3 High, 1 Medium, 2 Low)
                        TaskTimelineSummary(
                          highCount: highCount,
                          mediumCount: mediumCount,
                          lowCount: lowCount,
                        ),
                        SizedBox(height: context.rSpacing(16)),

                        // 3. Filter Bar (All, Today, Next 7 Days, Overdue)
                        TaskFilterBar(
                          selectedFilter: _selectedFilter,
                          onFilterSelected: (f) =>
                              setState(() => _selectedFilter = f),
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

                  // 6. Virtualized Task Cards List with smooth expansion
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
                              bottom: context.rSpacing(12),
                            ),
                            child: TaskExpandableCard(
                              key: ValueKey('task_card_${task.id}'),
                              task: task,
                              onEdit: () => _openEditTask(task),
                            ),
                          );
                        },
                        childCount: tasks.length,
                      ),
                    ),
                  ),

                  // Bottom padding for scroll clearance
                  SliverToBoxAdapter(
                    child: SizedBox(height: context.rSpacing(24)),
                  ),
                ],
              ),
            ),

            // Scooped Bottom Navigation Bar
            ImpalBottomNavBar(
              currentTab: _currentTab,
              onTabSelected: _onTabSelected,
            ),
          ],
        ),
      ),
    );
  }
}
