import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import 'task_item_model.dart';

/// Centralized repository managing tasks across the IMPAL application.
///
/// Follows singleton pattern similar to ScheduleRepository & TeamRepository.
/// Supports both local state management and remote PostgreSQL Dart Frog API synchronization.
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
    _initialized = true;
  }

  /// Resets tasks to default fixtures (useful for widget tests).
  void resetToDefaults() {
    _initialized = false;
    _tasks.clear();
    _tasks.addAll(TaskItemModel.defaultTasks);
    _initialized = true;
    notifyListeners();
  }

  /// Clears repository state upon logout to prevent multi-account data leakage.
  void clear() {
    _tasks.clear();
    _initialized = false;
    notifyListeners();
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('jwt_token');
      debugPrint('[TASK_REPO] _getToken: ${token != null && token.isNotEmpty ? "Token found (${token.length} chars)" : "NO TOKEN FOUND in SharedPreferences!"}');
      return token;
    } catch (e) {
      debugPrint('[TASK_REPO] _getToken error: $e');
      return null;
    }
  }

  /// Synchronizes tasks from backend REST API (GET /api/task).
  Future<void> fetchTasksFromApi() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      debugPrint('[TASK_REPO] fetchTasksFromApi: No token found, keeping local data.');
      return;
    }

    try {
      debugPrint('[TASK_REPO] fetchTasksFromApi: Calling GET /api/task');
      final res = await ApiClient.get('/api/task', token: token);
      debugPrint('[TASK_REPO] fetchTasksFromApi response: status=${res['status']}, count=${res['count']}');
      if (res['status'] == 'success' && res['data'] is List) {
        final List<dynamic> raw = res['data'];
        final fetched = raw
            .map((item) => TaskItemModel.fromBackendJson(item as Map<String, dynamic>))
            .toList();

        _tasks.clear();
        _tasks.addAll(fetched);
        _initialized = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[TASK_REPO] fetchTasksFromApi error: $e');
    }
  }

  /// Adds a task to local memory.
  void addTask(TaskItemModel task) {
    _tasks.insert(0, task);
    notifyListeners();
  }

  /// Creates a new task on the backend (POST /api/task).
  /// Throws Exception on failure so the UI form can display accurate feedback.
  Future<TaskItemModel?> createTaskApi(TaskItemModel task) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      debugPrint('[TASK_REPO] No auth token found! User must log in.');
      throw Exception('Session token not found. Please sign in again.');
    }

    try {
      final payload = task.toBackendJson();
      debugPrint('[TASK_REPO] Sending POST /api/task with payload: $payload');
      final res = await ApiClient.post(
        '/api/task',
        payload,
        token: token,
      );
      debugPrint('[TASK_REPO] Response from /api/task: $res');

      if (res['status'] == 'success' && res['data'] != null) {
        final created = TaskItemModel.fromBackendJson(res['data'] as Map<String, dynamic>);
        _tasks.insert(0, created);
        notifyListeners();
        return created;
      } else {
        final msg = res['message']?.toString() ?? 'Server failed to save task';
        debugPrint('[TASK_REPO] Server rejected task: $msg');
        throw Exception(msg);
      }
    } catch (e) {
      debugPrint('[TASK_REPO] createTaskApi error: $e');
      rethrow;
    }
  }

  /// Updates a task in local memory.
  void updateTask(TaskItemModel updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  /// Updates a task on backend (PUT /api/task/<id>) and local memory.
  Future<bool> updateTaskApi(TaskItemModel updatedTask) async {
    final token = await _getToken();
    if (token != null && token.isNotEmpty && !updatedTask.id.startsWith('team_task_')) {
      try {
        final res = await ApiClient.put(
          '/api/task/${updatedTask.id}',
          updatedTask.toBackendJson(),
          token: token,
        );
        if (res['status'] == 'success') {
          final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
          if (index != -1) {
            _tasks[index] = updatedTask;
            notifyListeners();
          }
          return true;
        } else {
          throw Exception(res['message']?.toString() ?? 'Failed to update task');
        }
      } catch (e) {
        debugPrint('[TASK_REPO] updateTaskApi error: $e');
        rethrow;
      }
    }

    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
    return true;
  }

  /// Deletes a task from local memory.
  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Deletes a task from backend (DELETE /api/task/<id>) and local memory.
  Future<bool> deleteTaskApi(String id) async {
    final token = await _getToken();
    if (token != null && token.isNotEmpty && !id.startsWith('team_task_')) {
      try {
        final res = await ApiClient.delete('/api/task/$id', token: token);
        if (res['status'] == 'success') {
          _tasks.removeWhere((t) => t.id == id);
          notifyListeners();
          return true;
        } else {
          throw Exception(res['message']?.toString() ?? 'Failed to delete task');
        }
      } catch (e) {
        debugPrint('[TASK_REPO] deleteTaskApi error: $e');
        rethrow;
      }
    }

    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    return true;
  }

  /// Toggles completion status of a task by its ID with immediate API sync.
  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      notifyListeners();

      final token = await _getToken();
      if (token != null && token.isNotEmpty && !id.startsWith('team_task_')) {
        try {
          await ApiClient.put('/api/task/$id/toggle', {}, token: token);
        } catch (e) {
          debugPrint('[TASK_REPO] toggleTaskCompletion error: $e');
        }
      }
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

    _getToken().then((token) {
      if (token != null && token.isNotEmpty && !homeTask.id.startsWith('team_task_')) {
        ApiClient.put('/api/task/${homeTask.id}/toggle', {}, token: token).catchError((_) => <String, dynamic>{});
      }
    });
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
  /// If [userAssignedOnly] is true, includes all non-team tasks and only team tasks assigned to user.
  Map<TaskPriorityLevel, int> getPriorityCounts({
    bool nonTeamOnly = false,
    bool userAssignedOnly = true,
  }) {
    int high = 0;
    int med = 0;
    int low = 0;

    final targetList = nonTeamOnly
        ? _tasks.where((t) => !t.isTeamTask)
        : (userAssignedOnly
            ? _tasks.where((t) => !t.isTeamTask || t.isAssignedToUser)
            : _tasks);

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
