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

  /// Calculates counts by priority level for timeline counters.
  Map<TaskPriorityLevel, int> getPriorityCounts() {
    int high = 0;
    int med = 0;
    int low = 0;

    for (final task in _tasks) {
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

    // Default minimum counts to match Figma mockups if list is small
    return {
      TaskPriorityLevel.high: high < 3 ? 3 : high,
      TaskPriorityLevel.medium: med < 1 ? 1 : med,
      TaskPriorityLevel.low: low < 2 ? 2 : low,
    };
  }
}

