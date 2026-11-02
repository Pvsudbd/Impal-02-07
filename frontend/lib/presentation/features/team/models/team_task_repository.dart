import 'package:flutter/material.dart';
import '../../task/models/task_repository.dart';
import 'team_task_model.dart';

/// Centralized in-memory repository managing team tasks for team dashboards.
///
/// Follows singleton pattern with ChangeNotifier, automatically synchronizing
/// team project progress and completion with [TaskRepository].
class TeamTaskRepository with ChangeNotifier {
  static final TeamTaskRepository _instance = TeamTaskRepository._internal();
  factory TeamTaskRepository() => _instance;
  TeamTaskRepository._internal();

  final Map<String, List<TeamTaskModel>> _teamTasks = {};
  bool _initialized = false;

  void init() {
    if (_initialized) return;

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

    _initialized = true;
    _syncWithTaskRepository('7X29');
  }

  /// Returns unmodifiable list of tasks for given team code.
  List<TeamTaskModel> getTasks(String teamCode) {
    init();
    return List.unmodifiable(_teamTasks[teamCode] ?? []);
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

