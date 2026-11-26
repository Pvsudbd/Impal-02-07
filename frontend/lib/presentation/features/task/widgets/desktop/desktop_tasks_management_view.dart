import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../dashboard/models/dashboard_models.dart';
import '../../../dashboard/widgets/desktop/desktop_task_grid_card.dart';
import '../../../smart_system/models/smart_priority_repository.dart';
import '../../../smart_system/smart_priority_page.dart';
import '../../../team/dashboard_team_page.dart';
import '../../../team/models/team_model.dart';
import '../../../team/models/team_repository.dart';
import '../../../team/models/team_task_repository.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../edit_task.dart';
import '../../models/tag_repository.dart';
import '../../models/task_repository.dart';
import '../task_tag_picker.dart';
import 'desktop_personal_task_modal.dart';
import 'desktop_task_filter_bar.dart';
import 'desktop_task_kpi_row.dart';
import 'desktop_tasks_right_panel.dart';

enum _TaskScheduleBucket { today, upcoming, overdue }

/// Desktop 2-column Tasks Management workspace matching FigCraft
/// `Desktop - Tasks Management` (node 2069, 1440x980).
class DesktopTasksManagementView extends StatefulWidget {
  final String userName;
  final String userInitials;
  final String searchQuery;
  final VoidCallback? onOpenScheduleTimeline;
  final VoidCallback? onOpenSmartPriority;
  final ValueChanged<TeamModel>? onOpenTeamDashboard;
  final VoidCallback? onResetSearch;

  const DesktopTasksManagementView({
    super.key,
    required this.userName,
    this.userInitials = 'JS',
    this.searchQuery = '',
    this.onOpenScheduleTimeline,
    this.onOpenSmartPriority,
    this.onOpenTeamDashboard,
    this.onResetSearch,
  });

  @override
  State<DesktopTasksManagementView> createState() =>
      _DesktopTasksManagementViewState();
}

class _DesktopTasksManagementViewState
    extends State<DesktopTasksManagementView> {
  final TaskRepository _taskRepo = TaskRepository();
  final TeamTaskRepository _teamTaskRepo = TeamTaskRepository();
  final SmartPriorityRepository _smartRepo = SmartPriorityRepository.instance;

  String _selectedTimeFilter = 'All Tasks';
  TaskPriorityLevel? _selectedPriority;
  String? _selectedTagFilter;
  String _sortBy = 'Deadline';
  String _taskTypeFilter = 'All';
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _taskRepo.init();
    _teamTaskRepo.init();
    TaskTagRepository().init();
    _taskRepo.addListener(_onDataChanged);
    _teamTaskRepo.addListener(_onDataChanged);
    _smartRepo.addListener(_onDataChanged);

    final initialTasks = _mergedAllTasks;
    if (initialTasks.isNotEmpty) {
      final firstDate = initialTasks.first.deadlineDate;
      _focusedMonth = DateTime(firstDate.year, firstDate.month, 1);
    } else {
      final now = DateTime.now();
      _focusedMonth = DateTime(now.year, now.month, 1);
    }
  }

  @override
  void dispose() {
    _taskRepo.removeListener(_onDataChanged);
    _teamTaskRepo.removeListener(_onDataChanged);
    _smartRepo.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  List<TaskItemModel> get _mergedAllTasks {
    final repoTasks = _taskRepo.tasks
        .where((t) => !t.isTeamTask || t.isAssignedToUser)
        .toList();
    final teamTasks = _teamTaskRepo.getAssignedTaskItemsForUser(
      widget.userName,
      repoTasks,
    );
    return [...repoTasks, ...teamTasks];
  }

  _TaskScheduleBucket _classifyBucket(TaskItemModel task) {
    final badge = task.durationBadge.trim().toLowerCase();
    if (badge == 'overdue') {
      return _TaskScheduleBucket.overdue;
    }
    if (badge.endsWith('h') || badge == '<1h' || badge == '0d') {
      return _TaskScheduleBucket.today;
    }
    final now = DateTime.now();
    final d = task.deadlineDate;
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return _TaskScheduleBucket.today;
    }
    return _TaskScheduleBucket.upcoming;
  }

  List<TaskItemModel> _applyFiltersAndSort(List<TaskItemModel> source) {
    var list = List<TaskItemModel>.from(source);

    if (_selectedTimeFilter == 'Today') {
      list = list
          .where((t) => _classifyBucket(t) == _TaskScheduleBucket.today)
          .toList();
    } else if (_selectedTimeFilter == 'Next 7 Days') {
      list = list
          .where((t) => _classifyBucket(t) == _TaskScheduleBucket.upcoming)
          .toList();
    } else if (_selectedTimeFilter == 'Overdue') {
      list = list
          .where((t) => _classifyBucket(t) == _TaskScheduleBucket.overdue)
          .toList();
    }

    if (_selectedPriority != null) {
      list = list.where((t) => t.priority == _selectedPriority).toList();
    }

    if (_taskTypeFilter == 'College') {
      list = list.where((t) => t.isCollegeTask && !t.isTeamTask).toList();
    } else if (_taskTypeFilter == 'Personal') {
      list = list.where((t) => !t.isCollegeTask && !t.isTeamTask).toList();
    } else if (_taskTypeFilter == 'Team') {
      list = list.where((t) => t.isTeamTask).toList();
    } else if (_taskTypeFilter == 'Completed') {
      list = list.where((t) => t.isCompleted).toList();
    }

    if (_selectedDate != null) {
      list = list.where((t) {
        final d = t.deadlineDate;
        return d.year == _selectedDate!.year &&
            d.month == _selectedDate!.month &&
            d.day == _selectedDate!.day;
      }).toList();
    }

    if (_selectedTagFilter != null) {
      final tq = _selectedTagFilter!.trim().toLowerCase();
      list = list
          .where(
            (t) => t.tags.any((tag) => tag.label.trim().toLowerCase() == tq),
          )
          .toList();
    }

    final query = widget.searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((t) {
        return t.title.toLowerCase().contains(query) ||
            (t.subtitle?.toLowerCase().contains(query) ?? false) ||
            t.course.toLowerCase().contains(query) ||
            (t.teamName?.toLowerCase().contains(query) ?? false) ||
            t.tags.any((tag) => tag.label.toLowerCase().contains(query));
      }).toList();
    }

    final completed = list.where((t) => t.isCompleted).toList();
    final active = list.where((t) => !t.isCompleted).toList();

    switch (_sortBy) {
      case 'Priority':
        active.sort((a, b) {
          final pCmp = a.priority.index.compareTo(b.priority.index);
          return pCmp != 0 ? pCmp : TaskItemModel.compareTaskDeadlines(a, b);
        });
      case 'Title':
        active.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      default:
        active.sort(TaskItemModel.compareTaskDeadlines);
    }

    return [...active, ...completed];
  }

  String? get _activeExtraFilterLabel {
    final parts = <String>[];
    if (_selectedPriority != null) {
      final pName = switch (_selectedPriority!) {
        TaskPriorityLevel.high => 'High',
        TaskPriorityLevel.medium => 'Medium',
        TaskPriorityLevel.low => 'Low',
      };
      parts.add('Priority: $pName');
    }
    if (_selectedDate != null) {
      parts.add('Date: ${DateFormat('d MMM').format(_selectedDate!)}');
    }
    if (_selectedTagFilter != null) {
      parts.add('Tag: $_selectedTagFilter');
    }
    if (parts.isEmpty) return null;
    return parts.join(' • ');
  }

  void _clearExtraFilters() {
    setState(() {
      _selectedPriority = null;
      _selectedDate = null;
      _selectedTagFilter = null;
      _selectedTimeFilter = 'All Tasks';
      _taskTypeFilter = 'All';
    });
    widget.onResetSearch?.call();
  }

  TeamModel _resolveTeamForTask(TaskItemModel task) {
    final teams = TeamRepository().teams;
    return teams.firstWhere(
      (t) => task.title.toLowerCase().contains(
            t.name.toLowerCase().replaceAll('team', '').trim(),
          ),
      orElse: () => teams.isNotEmpty
          ? teams.first
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
  }

  Future<void> _handleTaskTap(TaskItemModel task) async {
    if (task.isTeamTask) {
      final team = _resolveTeamForTask(task);
      if (widget.onOpenTeamDashboard != null) {
        widget.onOpenTeamDashboard!(team);
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DashboardTeamPage(
            userName: widget.userName,
            teamName: team.name,
            teamId: team.id,
            teamCode: (team.inviteCode != null && team.inviteCode!.isNotEmpty)
                ? team.inviteCode!
                : team.id,
            memberColors: team.memberColors,
            isStandalone: true,
          ),
        ),
      );
      return;
    }

    final updated = await DesktopPersonalTaskModal.show(
      context,
      task: task,
      userInitials: widget.userInitials,
      onTaskUpdated: _taskRepo.updateTask,
    );

    if (updated != null && mounted) {
      _taskRepo.updateTask(updated);
    }
  }

  void _handleToggleTaskCompletion(TaskItemModel task) {
    final bool willBeCompleted = !task.isCompleted;
    if (task.id.startsWith('team_task_')) {
      final realId = task.id.replaceFirst('team_task_', '');
      _teamTaskRepo.toggleTaskDone('7X29', realId);
    } else {
      _taskRepo.toggleTaskCompletion(task.id);
    }

    if (willBeCompleted) {
      PopUpPemberitahuan.taskCompleted(context, taskName: task.title);
    } else {
      PopUpPemberitahuan.taskReopened(context, taskName: task.title);
    }
  }

  List<DesktopCollaboratorSummary> _buildCollaborators() {
    final teamTasks = _teamTaskRepo.getTasks('7X29');
    if (teamTasks.isEmpty) return const [];

    final seen = <String>{};
    final summaries = <DesktopCollaboratorSummary>[];

    for (final t in teamTasks) {
      final firstAssignee = t.assignedTo.split(',').first.trim();
      if (firstAssignee.isEmpty || seen.contains(firstAssignee)) continue;
      seen.add(firstAssignee);

      final parts = firstAssignee.split(' ').where((p) => p.isNotEmpty).toList();
      final initials = parts.length >= 2
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : firstAssignee
              .substring(0, firstAssignee.length >= 2 ? 2 : 1)
              .toUpperCase();

      final (badgeBg, badgeText) = switch (t.priority) {
        TaskPriority.high => (const Color(0xFF63CDDA), const Color(0xFF0E4D56)),
        TaskPriority.medium => (
            AppColors.purpleAccent,
            const Color(0xFFFFFFFF),
          ),
        TaskPriority.low => (const Color(0xFF778BEB), const Color(0xFFFFFFFF)),
      };

      final roleLabel = switch (t.priority) {
        TaskPriority.high => 'Coding',
        TaskPriority.medium => 'Review',
        TaskPriority.low => 'Design',
      };

      summaries.add(
        DesktopCollaboratorSummary(
          initials: initials,
          name: firstAssignee,
          taskSubtitle: t.title,
          roleLabel: roleLabel,
          avatarColor: t.assigneeColor,
          badgeBg: badgeBg,
          badgeTextColor: badgeText,
        ),
      );
    }

    return summaries.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = _mergedAllTasks;
    final activeTasks = allTasks.where((t) => !t.isCompleted).toList();

    final highCount =
        activeTasks.where((t) => t.priority == TaskPriorityLevel.high).length;
    final mediumCount =
        activeTasks.where((t) => t.priority == TaskPriorityLevel.medium).length;
    final lowCount =
        activeTasks.where((t) => t.priority == TaskPriorityLevel.low).length;

    final todayAllCount = allTasks
        .where((t) => _classifyBucket(t) == _TaskScheduleBucket.today)
        .length;
    final next7DaysAllCount = allTasks
        .where((t) => _classifyBucket(t) == _TaskScheduleBucket.upcoming)
        .length;
    final overdueAllCount = allTasks
        .where((t) => _classifyBucket(t) == _TaskScheduleBucket.overdue)
        .length;

    final filtered = _applyFiltersAndSort(allTasks);
    final activeFiltered = filtered.where((t) => !t.isCompleted).toList();
    final completedFiltered = filtered.where((t) => t.isCompleted).toList();

    final todayTasks = activeFiltered
        .where((t) => _classifyBucket(t) == _TaskScheduleBucket.today)
        .toList();
    final upcomingTasks = activeFiltered
        .where((t) => _classifyBucket(t) != _TaskScheduleBucket.today)
        .toList();

    final deadlineDates = allTasks
        .map(
          (t) => DateTime(
            t.deadlineDate.year,
            t.deadlineDate.month,
            t.deadlineDate.day,
          ),
        )
        .toSet();

    final showTodaySection =
        _selectedTimeFilter == 'All Tasks' || _selectedTimeFilter == 'Today';
    final showUpcomingSection = _selectedTimeFilter == 'All Tasks' ||
        _selectedTimeFilter == 'Next 7 Days' ||
        _selectedTimeFilter == 'Overdue';

    final pad = context.rSpacing(24);
    final colGap = context.rSpacing(24);

    final mainWorkspace = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                DesktopTaskKpiRow(
                  highCount: highCount,
                  mediumCount: mediumCount,
                  lowCount: lowCount,
                  totalCount: allTasks.length,
                  todayDueCount: todayAllCount,
                  selectedPriority: _selectedPriority,
                  onPriorityTap: (priority) {
                    setState(() => _selectedPriority = priority);
                  },
                  onSmartPriorityTap: () {
                    if (widget.onOpenSmartPriority != null) {
                      widget.onOpenSmartPriority!();
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            SmartPriorityPage(userName: widget.userName),
                      ),
                    );
                  },
                ),
                SizedBox(height: context.rSpacing(18)),
                DesktopTaskFilterBar(
                  selectedTimeFilter: _selectedTimeFilter,
                  allCount: allTasks.length,
                  todayCount: todayAllCount,
                  next7DaysCount: next7DaysAllCount,
                  overdueCount: overdueAllCount,
                  sortBy: _sortBy,
                  taskTypeFilter: _taskTypeFilter,
                  activeExtraFilterLabel: _activeExtraFilterLabel,
                  onTimeFilterSelected: (f) {
                    setState(() => _selectedTimeFilter = f);
                  },
                  onSortChanged: (s) => setState(() => _sortBy = s),
                  onTaskTypeChanged: (t) => setState(() => _taskTypeFilter = t),
                  onClearExtraFilter: _clearExtraFilters,
                ),
                SizedBox(height: context.rSpacing(10)),
                TagFilterStrip(
                  selectedTag: _selectedTagFilter,
                  includeAllOption: true,
                  showAddButton: true,
                  onTagSelected: (tag) =>
                      setState(() => _selectedTagFilter = tag),
                ),
                SizedBox(height: context.rSpacing(20)),

                if (filtered.isEmpty)
                  _EmptyDesktopTasksState(onReset: _clearExtraFilters)
                else ...[
                  if (_taskTypeFilter != 'Completed') ...[
                    if (showTodaySection) ...[
                      _TaskSectionHeader(
                        title: 'Today Tasks',
                        countLabel:
                            '${todayTasks.length} ${todayTasks.length == 1 ? 'Task' : 'Tasks'}',
                        rightLabel:
                            'Due ${DateFormat('EEEE, d MMM yyyy').format(DateTime.now())}',
                      ),
                      SizedBox(height: context.rSpacing(14)),
                      if (todayTasks.isEmpty)
                        const _SectionEmptyPlaceholder(
                          message:
                              'No tasks scheduled for today under current filters.',
                        )
                      else
                        _DesktopTaskGrid(
                          tasks: todayTasks,
                          onTaskTap: _handleTaskTap,
                          onToggleComplete: _handleToggleTaskCompletion,
                        ),
                      if (showUpcomingSection)
                        SizedBox(height: context.rSpacing(22)),
                    ],
                    if (showUpcomingSection) ...[
                      _TaskSectionHeader(
                        title: _selectedTimeFilter == 'Overdue'
                            ? 'Overdue Tasks'
                            : 'Upcoming & Overdue Tasks',
                        countLabel:
                            '${upcomingTasks.length} ${upcomingTasks.length == 1 ? 'Task' : 'Tasks'}',
                        actionLabel: 'View Timeline Calendar →',
                        onActionTap: widget.onOpenScheduleTimeline,
                      ),
                      SizedBox(height: context.rSpacing(14)),
                      if (upcomingTasks.isEmpty)
                        const _SectionEmptyPlaceholder(
                          message:
                              'No upcoming or overdue tasks match your current filters.',
                        )
                      else
                        _DesktopTaskGrid(
                          tasks: upcomingTasks,
                          onTaskTap: _handleTaskTap,
                          onToggleComplete: _handleToggleTaskCompletion,
                        ),
                    ],
                  ],
                  if (completedFiltered.isNotEmpty) ...[
                    if (_taskTypeFilter != 'Completed')
                      SizedBox(height: context.rSpacing(22)),
                    _TaskSectionHeader(
                      title: 'Completed Tasks',
                      countLabel:
                          '${completedFiltered.length} ${completedFiltered.length == 1 ? 'Task' : 'Tasks'}',
                    ),
                    SizedBox(height: context.rSpacing(14)),
                    _DesktopTaskGrid(
                      tasks: completedFiltered,
                      onTaskTap: _handleTaskTap,
                      onToggleComplete: _handleToggleTaskCompletion,
                    ),
                  ],
                ],
      ],
    );

    final rightPanel = DesktopTasksRightPanel(
      focusedMonth: _focusedMonth,
      selectedDate: _selectedDate,
      deadlineDates: deadlineDates,
      todayDeadlineCount: todayAllCount,
      onPreviousMonth: () {
        setState(() {
          _focusedMonth = DateTime(
            _focusedMonth.year,
            _focusedMonth.month - 1,
            1,
          );
        });
      },
      onNextMonth: () {
        setState(() {
          _focusedMonth = DateTime(
            _focusedMonth.year,
            _focusedMonth.month + 1,
            1,
          );
        });
      },
      onDateSelected: (date) {
        setState(() {
          if (_selectedDate != null &&
              _selectedDate!.year == date.year &&
              _selectedDate!.month == date.month &&
              _selectedDate!.day == date.day) {
            _selectedDate = null;
          } else {
            _selectedDate = date;
          }
        });
      },
      topPriority: _smartRepo.topPriority,
      isFuzzyEngineActive: _smartRepo.isEngineActive,
      onFuzzyCardTap: () {
        if (widget.onOpenSmartPriority != null) {
          widget.onOpenSmartPriority!();
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SmartPriorityPage(userName: widget.userName),
          ),
        );
      },
      collaborators: _buildCollaborators(),
      onCollaboratorTap: (_) {
        final team = TeamRepository().teams.isNotEmpty
            ? TeamRepository().teams.first
            : const TeamModel(
                id: '1',
                name: 'IMPAL Team',
                memberColors: [
                  Color(0xFFF3A683),
                  Color(0xFF786FA6),
                  Color(0xFF63CDDA),
                ],
              );
        if (widget.onOpenTeamDashboard != null) {
          widget.onOpenTeamDashboard!(team);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DashboardTeamPage(
                userName: widget.userName,
                teamName: team.name,
                teamId: team.id,
                teamCode: (team.inviteCode != null && team.inviteCode!.isNotEmpty)
                    ? team.inviteCode!
                    : team.id,
                memberColors: team.memberColors,
                isStandalone: true,
              ),
            ),
          );
        }
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 900.0;
        final rightPanelWidth = constraints.maxWidth >= 1120 ? 348.0 : 300.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: sideBySide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: mainWorkspace),
                    SizedBox(width: colGap),
                    SizedBox(width: rightPanelWidth, child: rightPanel),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    mainWorkspace,
                    SizedBox(height: colGap),
                    rightPanel,
                  ],
                ),
        );
      },
    );
  }
}

class _TaskSectionHeader extends StatelessWidget {
  final String title;
  final String countLabel;
  final String? rightLabel;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _TaskSectionHeader({
    required this.title,
    required this.countLabel,
    this.rightLabel,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 6,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(17, min: 15, max: 19),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  countLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          if (actionLabel != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                key: const ValueKey('desktop_view_timeline_calendar_btn'),
                onTap: onActionTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12.5,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            )
          else if (rightLabel != null)
            Text(
              rightLabel!,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: context.rFont(12, min: 11, max: 13),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

class _DesktopTaskGrid extends StatelessWidget {
  final List<TaskItemModel> tasks;
  final ValueChanged<TaskItemModel> onTaskTap;
  final ValueChanged<TaskItemModel>? onToggleComplete;

  const _DesktopTaskGrid({
    required this.tasks,
    required this.onTaskTap,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final gap = context.rSpacing(16);

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 520.0;
        if (!twoColumns) {
          return Column(
            children: [
              for (int i = 0; i < tasks.length; i++) ...[
                DesktopTaskGridCard(
                  task: TaskItem.fromTaskItemModel(tasks[i]),
                  priorityLabel: tasks[i].priorityLabel,
                  priorityBgColor: tasks[i].priorityBadgeColor,
                  priorityTextColor: tasks[i].priorityTextColor,
                  onTap: () => onTaskTap(tasks[i]),
                  onToggleComplete: onToggleComplete != null
                      ? () => onToggleComplete!(tasks[i])
                      : null,
                ),
                if (i < tasks.length - 1) SizedBox(height: gap),
              ],
            ],
          );
        }

        final cardWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final task in tasks)
              SizedBox(
                width: cardWidth,
                child: DesktopTaskGridCard(
                  task: TaskItem.fromTaskItemModel(task),
                  priorityLabel: task.priorityLabel,
                  priorityBgColor: task.priorityBadgeColor,
                  priorityTextColor: task.priorityTextColor,
                  onTap: () => onTaskTap(task),
                  onToggleComplete: onToggleComplete != null
                      ? () => onToggleComplete!(task)
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SectionEmptyPlaceholder extends StatelessWidget {
  final String message;

  const _SectionEmptyPlaceholder({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(18),
        vertical: context.rSpacing(20),
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _EmptyDesktopTasksState extends StatelessWidget {
  final VoidCallback onReset;

  const _EmptyDesktopTasksState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(24),
        vertical: context.rSpacing(36),
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 0.9),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.filter_alt_off_rounded,
              color: AppColors.primaryAccent,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No Matching Tasks',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(16, min: 14, max: 18),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try clearing the active filter, priority, search keyword, or selected calendar date.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reset All Filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryAccent,
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
