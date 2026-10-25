class GroupSubTask {
  String _subTaskId;
  String _subTaskTitle;
  String _description;
  DateTime _deadline;
  double _gradeWeight;
  bool _isCompleted;

  GroupSubTask({
    required String subTaskId,
    required String subTaskTitle,
    required String description,
    required DateTime deadline,
    required double gradeWeight,
    bool isCompleted = false,
  })  : _subTaskId = subTaskId,
        _subTaskTitle = subTaskTitle,
        _description = description,
        _deadline = deadline,
        _gradeWeight = gradeWeight,
        _isCompleted = isCompleted;

  factory GroupSubTask.fromJson(Map<String, dynamic> json) {
    return GroupSubTask(
      subTaskId: json['id_sub_task'] ?? '',
      subTaskTitle: json['sub_task_title'] ?? '',
      description: json['description'] ?? '',
      deadline: DateTime.parse(json['deadline']),
      gradeWeight: (json['grade_weight'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['is_completed'] == 1 || json['is_completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sub_task': _subTaskId,
      'sub_task_title': _subTaskTitle,
      'description': _description,
      'deadline': _deadline.toIso8601String(),
      'grade_weight': _gradeWeight,
      'is_completed': _isCompleted ? 1 : 0,
    };
  }

  String get subTaskId => _subTaskId;
  String get subTaskTitle => _subTaskTitle;
  String get description => _description;
  DateTime get deadline => _deadline;
  double get gradeWeight => _gradeWeight;
  bool get isCompleted => _isCompleted;

  void setCompletionStatus(bool status) {
    _isCompleted = status;
  }

  int calculateRemainingTime() {
    return _deadline.difference(DateTime.now()).inHours;
  }
}