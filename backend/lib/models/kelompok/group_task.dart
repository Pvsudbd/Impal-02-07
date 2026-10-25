import 'group_sub_task.dart';
import 'student.dart';

class GroupTask {
  String _groupTaskId;
  String _taskTitle;
  String _description;
  DateTime _deadline;
  double _gradeWeight;
  String _priority;
  bool _isFuzzyAuto;
  bool _isCompleted;
  Student? _pic;
  final List<GroupSubTask> _subTasks = [];

  GroupTask({
    required String groupTaskId,
    required String taskTitle,
    required String description,
    required DateTime deadline,
    required double gradeWeight,
    required String priority,
    required bool isFuzzyAuto,
    bool isCompleted = false,
  })  : _groupTaskId = groupTaskId,
        _taskTitle = taskTitle,
        _description = description,
        _deadline = deadline,
        _gradeWeight = gradeWeight,
        _priority = priority,
        _isFuzzyAuto = isFuzzyAuto,
        _isCompleted = isCompleted;

  factory GroupTask.fromJson(Map<String, dynamic> json) {
    return GroupTask(
      groupTaskId: json['id_group_task'] ?? '',
      taskTitle: json['task_title'] ?? '',
      description: json['description'] ?? '',
      deadline: DateTime.parse(json['deadline']),
      gradeWeight: (json['grade_weight'] as num?)?.toDouble() ?? 0.0,
      priority: json['priority'] ?? 'MEDIUM',
      isFuzzyAuto: json['is_fuzzy_auto'] == 1 || json['is_fuzzy_auto'] == true,
      isCompleted: json['is_completed'] == 1 || json['is_completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_group_task': _groupTaskId,
      'task_title': _taskTitle,
      'description': _description,
      'deadline': _deadline.toIso8601String(),
      'grade_weight': _gradeWeight,
      'priority': _priority,
      'is_fuzzy_auto': _isFuzzyAuto ? 1 : 0,
      'is_completed': _isCompleted ? 1 : 0,
    };
  }

  String get groupTaskId => _groupTaskId;
  String get taskTitle => _taskTitle;
  String get description => _description;
  DateTime get deadline => _deadline;
  double get gradeWeight => _gradeWeight;
  String get priority => _priority;
  bool get isFuzzyAuto => _isFuzzyAuto;
  bool get isCompleted => _isCompleted;
  Student? get pic => _pic;

  void assignPIC(Student student) {
    _pic = student;
  }

  void setCompletionStatus(bool status) {
    _isCompleted = status;
  }

  int calculateRemainingTime() {
    return _deadline.difference(DateTime.now()).inHours;
  }

  double getTotalSubTaskWeight() {
    return _subTasks.fold(0.0, (sum, item) => sum + item.gradeWeight);
  }
}