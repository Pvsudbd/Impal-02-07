import 'group_sub_task.dart';
import '../auth/user_model.dart';

class GroupTask {
  String _groupTaskId;
  String _groupId;
  String? _assignedToId;
  String _taskTitle;
  String _description;
  DateTime _deadline;
  double _gradeWeight;
  String _priority;
  bool _isFuzzyAuto;
  bool _isCompleted;
  User? _pic;
  final List<GroupSubTask> _subTasks = [];

  GroupTask({
    required String groupTaskId,
    String groupId = '',
    String? assignedToId,
    required String taskTitle,
    required String description,
    required DateTime deadline,
    required double gradeWeight,
    required String priority,
    required bool isFuzzyAuto,
    bool isCompleted = false,
  })  : _groupTaskId = groupTaskId,
        _groupId = groupId,
        _assignedToId = assignedToId,
        _taskTitle = taskTitle,
        _description = description,
        _deadline = deadline,
        _gradeWeight = gradeWeight,
        _priority = priority,
        _isFuzzyAuto = isFuzzyAuto,
        _isCompleted = isCompleted;

  factory GroupTask.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return GroupTask(
      groupTaskId: json['id_group_task']?.toString() ?? '',
      groupId: json['id_group']?.toString() ?? json['groupId']?.toString() ?? '',
      assignedToId: json['id_assigned_to']?.toString() ?? json['assignedToId']?.toString(),
      taskTitle: json['task_title']?.toString() ?? json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      deadline: parseDate(json['deadline']),
      gradeWeight: (json['grade_weight'] as num?)?.toDouble() ?? 0.0,
      priority: json['priority']?.toString() ?? 'MEDIUM',
      isFuzzyAuto: json['is_fuzzy_auto'] == 1 || json['is_fuzzy_auto'] == true,
      isCompleted: json['is_completed'] == 1 || json['is_completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_group_task': _groupTaskId,
      'id_group': _groupId,
      'id_assigned_to': _assignedToId,
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
  String get groupId => _groupId;
  String? get assignedToId => _assignedToId;
  String get taskTitle => _taskTitle;
  String get description => _description;
  DateTime get deadline => _deadline;
  double get gradeWeight => _gradeWeight;
  String get priority => _priority;
  bool get isFuzzyAuto => _isFuzzyAuto;
  bool get isCompleted => _isCompleted;
  User? get pic => _pic;
  List<GroupSubTask> get subTasks => _subTasks;

  set groupId(String val) => _groupId = val;
  set assignedToId(String? val) => _assignedToId = val;

  void assignPIC(User user) {
    _pic = user;
    _assignedToId = user.idUser;
  }

  void addSubTask(GroupSubTask subTask) {
    _subTasks.add(subTask);
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
