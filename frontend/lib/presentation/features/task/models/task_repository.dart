import 'package:flutter/foundation.dart';
import 'task_item_model.dart';

/// In-memory repository managing tasks across the IMPAL application.
///
/// Follows singleton pattern similar to ScheduleRepository & TeamRepository.
class TaskRepository with ChangeNotifier {
  static final TaskRepository _instance = TaskRepository._internal();
  factory TaskRepository() => _instance;
  TaskRepository._internal();

  final List<TaskItemModel> _tasks = [];
  bool _initialized = false;

  List<TaskItemModel> get tasks => List.unmodifiable(_tasks);

  void init() {
    if (_initialized) return;
    _tasks.clear();
    _tasks.addAll(TaskItemModel.defaultTasks);
    _initialized = true;
  }

  void addTask(TaskItemModel task) {
    _tasks.insert(0, task);
    notifyListeners();
  }

  void updateTask(TaskItemModel updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Toggles completion status of a task by its ID.
  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      notifyListeners();
    }
  }

  /// Completes a task dismissed from Homepage and ensures it exists in repository.
  void completeTaskFromHome(TaskItemModel homeTask) {
    final index = _tasks.indexWhere((t) => t.id == homeTask.id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: true);
    } else {
      _tasks.insert(0, homeTask.copyWith(isCompleted: true));
    }
    notifyListeners();
  }

  /// Automatically synchronizes completion status and progress percentage of team project tasks.
  void syncTeamProjectStatus({
    required bool isCompleted,
    required int progressPercent,
  }) {
    bool changed = false;
    for (int i = 0; i < _tasks.length; i++) {
      if (_tasks[i].isTeamTask) {
        _tasks[i] = _tasks[i].copyWith(
          isCompleted: isCompleted,
          progressPercent: progressPercent,
        );
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Calculates counts by priority level for timeline counters.
  Map<TaskPriorityLevel, int> getPriorityCounts({bool nonTeamOnly = false}) {
    int high = 0;
    int med = 0;
    int low = 0;

    final targetList =
        nonTeamOnly ? _tasks.where((t) => !t.isTeamTask) : _tasks;

    for (final task in targetList) {
      switch (task.priority) {
        case TaskPriorityLevel.high:
          high++;
          break;
        case TaskPriorityLevel.medium:
          med++;
          break;
        case TaskPriorityLevel.low:
          low++;
          break;
      }
    }

    return {
      TaskPriorityLevel.high: high,
      TaskPriorityLevel.medium: med,
      TaskPriorityLevel.low: low,
    };
  }
}

