import 'package:flutter/material.dart';
import '../../task/models/task_item_model.dart';
import '../../task/models/task_repository.dart';
import 'team_milestone_model.dart';
import 'team_task_model.dart';

export 'team_milestone_model.dart';

/// Centralized in-memory repository managing team tasks and milestones for team dashboards.
///
/// Follows singleton pattern with ChangeNotifier, automatically synchronizing
/// team project progress and completion with [TaskRepository].
class TeamTaskRepository with ChangeNotifier {
  static final TeamTaskRepository _instance = TeamTaskRepository._internal();
  factory TeamTaskRepository() => _instance;
  TeamTaskRepository._internal();

  final Map<String, List<TeamTaskModel>> _teamTasks = {};
  final Map<String, List<TeamMilestoneModel>> _teamMilestones = {};
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _teamTasks.clear();
    _teamMilestones.clear();
    _initialized = true;
  }

  void _seedDefaultFixtures() {
    _teamTasks['7X29'] = [
      const TeamTaskModel(
        id: 'task_1',
        title: 'Create team UI page',
        priority: TaskPriority.high,
        assignedTo: 'Yoga Perkasa Didik',
        assigneeColor: Color(0xFFF3A683),
        timeRange: '09:30 - 11:30 WIB',
        dueBadge: '12h',
        isDone: false,
      ),
      const TeamTaskModel(
        id: 'task_2',
        title: 'Create home UI page',
        priority: TaskPriority.medium,
        assignedTo: 'Ahmad Sahroni, Muhammad Kafi Rijal',
        assigneeColor: Color(0xFF63CDDA),
        assigneeColors: [Color(0xFF63CDDA), Color(0xFF786FA6)],
        timeRange: '09:30 - 11:30 WIB',
        dueBadge: '18h',
        isDone: false,
      ),
      const TeamTaskModel(
        id: 'task_3',
        title: 'Create task form UI',
        priority: TaskPriority.low,
        assignedTo: 'Yoga Perkasa Didik',
        assigneeColor: Color(0xFFF3A683),
        timeRange: '09:30 - 11:30 WIB',
        dueBadge: '2d',
        isDone: false,
      ),
    ];

    _teamMilestones['7X29'] = [
      TeamMilestoneModel(
        id: 'milestone_1',
        teamCode: '7X29',
        title: 'Responsi 1 - UI & Architecture',
        description: 'Implementation of team dashboard layout and responsiveness.',
        deadline: DateTime(2026, 10, 18, 23, 59),
        formattedDeadline: 'Sat 18 Oct 2026, 23: 59 WIB',
        dueBadge: '6d',
        taskIds: const ['task_1', 'task_2'],
        dateCreated: DateTime(2026, 10, 1),
      ),
    ];
  }

  /// Resets repository to default mock fixtures (useful for unit tests).
  void resetToDefaults() {
    _initialized = false;
    _teamTasks.clear();
    _teamMilestones.clear();
    _seedDefaultFixtures();
    _initialized = true;
    _syncWithTaskRepository('7X29');
    notifyListeners();
  }

  /// Returns unmodifiable list of tasks for given team code.
  List<TeamTaskModel> getTasks(String teamCode) {
    init();
    return List.unmodifiable(_teamTasks[teamCode] ?? []);
  }

  /// Returns unmodifiable list of milestones for given team code.
  List<TeamMilestoneModel> getMilestones(String teamCode) {
    init();
    return List.unmodifiable(_teamMilestones[teamCode] ?? []);
  }

  /// Returns tasks belonging to a specific milestone.
  List<TeamTaskModel> getTasksForMilestone(String teamCode, String milestoneId) {
    init();
    final milestones = _teamMilestones[teamCode] ?? [];
    final milestone = milestones.where((m) => m.id == milestoneId).firstOrNull;
    if (milestone == null) return [];
    final allTasks = getTasks(teamCode);
    return milestone.getMemberTasks(allTasks);
  }

  /// Returns tasks that are not assigned to any milestone in this team.
  List<TeamTaskModel> getUncategorizedTasks(String teamCode) {
    init();
    final allTasks = getTasks(teamCode);
    final milestones = _teamMilestones[teamCode] ?? [];
    final assignedTaskIds = <String>{};
    for (final m in milestones) {
      assignedTaskIds.addAll(m.taskIds);
    }
    return allTasks.where((t) => !assignedTaskIds.contains(t.id)).toList();
  }

  /// Adds a new milestone.
  void addMilestone(String teamCode, TeamMilestoneModel milestone) {
    init();
    final list = _teamMilestones.putIfAbsent(teamCode, () => []);
    list.insert(0, milestone);
    notifyListeners();
  }

  /// Updates an existing milestone.
  void updateMilestone(String teamCode, TeamMilestoneModel updated) {
    init();
    final list = _teamMilestones[teamCode];
    if (list != null) {
      final index = list.indexWhere((m) => m.id == updated.id);
      if (index != -1) {
        list[index] = updated;
        notifyListeners();
      }
    }
  }

  /// Finds which milestone contains this task id, if any.
  TeamMilestoneModel? getMilestoneForTask(String teamCode, String taskId) {
    init();
    final list = _teamMilestones[teamCode] ?? [];
    return list.where((m) => m.taskIds.contains(taskId)).firstOrNull;
  }

  /// Sets or clears the milestone association for a task.
  void setTaskMilestone({
    required String teamCode,
    required String taskId,
    String? milestoneId,
  }) {
    init();
    final list = _teamMilestones[teamCode];
    if (list != null) {
      bool changed = false;
      for (int i = 0; i < list.length; i++) {
        final m = list[i];
        final contains = m.taskIds.contains(taskId);
        if (m.id == milestoneId && !contains) {
          final updatedIds = List<String>.from(m.taskIds)..add(taskId);
          list[i] = m.copyWith(taskIds: updatedIds);
          changed = true;
        } else if (m.id != milestoneId && contains) {
          final updatedIds = List<String>.from(m.taskIds)..remove(taskId);
          list[i] = m.copyWith(taskIds: updatedIds);
          changed = true;
        }
      }
      if (changed) {
        notifyListeners();
      }
    }
  }

  /// Deletes a milestone without deleting its member tasks.
  void deleteMilestone(String teamCode, String milestoneId) {
    init();
    final list = _teamMilestones[teamCode];
    if (list != null) {
      list.removeWhere((m) => m.id == milestoneId);
      notifyListeners();
    }
  }

  /// Checks if all team tasks under given team code are finished.
  bool areAllTasksCompleted(String teamCode) {
    init();
    final tasks = _teamTasks[teamCode];
    if (tasks == null || tasks.isEmpty) return false;
    return tasks.every((t) => t.isDone);
  }

  /// Calculates percentage of completed tasks (0 - 100).
  int getCompletionPercentage(String teamCode) {
    init();
    final tasks = _teamTasks[teamCode];
    if (tasks == null || tasks.isEmpty) return 0;
    final done = tasks.where((t) => t.isDone).length;
    return ((done / tasks.length) * 100).round();
  }

  /// Toggles completion of a specific team task and automatically syncs project status.
  void toggleTaskCompletion({
    required String teamCode,
    required String taskId,
  }) {
    init();
    final list = _teamTasks[teamCode];
    if (list != null) {
      final index = list.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        list[index] = list[index].copyWith(isDone: !list[index].isDone);
        _syncWithTaskRepository(teamCode);
        notifyListeners();
      }
    }
  }

  /// Convenience alias for [toggleTaskCompletion].
  void toggleTaskDone(String teamCode, String taskId) {
    toggleTaskCompletion(teamCode: teamCode, taskId: taskId);
  }

  /// Adds a new team task.
  void addTask(String teamCode, TeamTaskModel task) {
    init();
    final list = _teamTasks.putIfAbsent(teamCode, () => []);
    list.insert(0, task);
    _syncWithTaskRepository(teamCode);
    notifyListeners();
  }

  /// Updates an existing team task.
  void updateTask(String teamCode, TeamTaskModel updatedTask) {
    init();
    final list = _teamTasks[teamCode];
    if (list != null) {
      final index = list.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        list[index] = updatedTask;
        _syncWithTaskRepository(teamCode);
        notifyListeners();
      }
    }
  }

  /// Deletes a team task.
  void deleteTask(String teamCode, String taskId) {
    init();
    final list = _teamTasks[teamCode];
    if (list != null) {
      list.removeWhere((t) => t.id == taskId);
      _syncWithTaskRepository(teamCode);
      notifyListeners();
    }
  }

  /// Returns true when [task] is assigned to [userName].
  bool isTaskAssignedToUser(TeamTaskModel task, String userName) {
    final userLower = userName.toLowerCase();
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

  /// Converts team tasks assigned to [userName] into [TaskItemModel] items
  /// not already duplicated by title in [existingRepoTasks].
  List<TaskItemModel> getAssignedTaskItemsForUser(
    String userName,
    List<TaskItemModel> existingRepoTasks, {
    String teamCode = '7X29',
  }) {
    return getTasks(teamCode)
        .where((t) => isTaskAssignedToUser(t, userName))
        .map(_convertTeamTaskToTaskItem)
        .where(
          (converted) => !existingRepoTasks.any(
            (r) => r.title.toLowerCase() == converted.title.toLowerCase(),
          ),
        )
        .toList();
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

  /// Private helper to automatically synchronize group task state in TaskRepository.
  void _syncWithTaskRepository(String teamCode) {
    final allDone = areAllTasksCompleted(teamCode);
    final percentage = getCompletionPercentage(teamCode);
    TaskRepository().syncTeamProjectStatus(
      isCompleted: allDone,
      progressPercent: percentage,
    );
  }
}

