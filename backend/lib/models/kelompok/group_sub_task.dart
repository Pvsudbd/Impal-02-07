class GroupSubTask {
  String _subTaskId;
  String _groupTaskId;
  String _assignedToId;
  String _subTaskTitle;
  String _description;
  DateTime _deadline;
  double _gradeWeight;
  bool _isCompleted;

  GroupSubTask({
    required String subTaskId,
    String groupTaskId = '',
    String assignedToId = '',
    required String subTaskTitle,
    required String description,
    required DateTime deadline,
    required double gradeWeight,
    bool isCompleted = false,
  })  : _subTaskId = subTaskId,
        _groupTaskId = groupTaskId,
        _assignedToId = assignedToId,
        _subTaskTitle = subTaskTitle,
        _description = description,
        _deadline = deadline,
        _gradeWeight = gradeWeight,
        _isCompleted = isCompleted;

  factory GroupSubTask.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return GroupSubTask(
      subTaskId: json['id_sub_task']?.toString() ?? '',
      groupTaskId: json['id_group_task']?.toString() ?? json['groupTaskId']?.toString() ?? '',
      assignedToId: json['id_assigned_to']?.toString() ?? json['assignedToId']?.toString() ?? '',
      subTaskTitle: json['sub_task_title']?.toString() ?? json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      deadline: parseDate(json['deadline']),
      gradeWeight: (json['grade_weight'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['is_completed'] == 1 || json['is_completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sub_task': _subTaskId,
      'id_group_task': _groupTaskId,
      'id_assigned_to': _assignedToId,
      'sub_task_title': _subTaskTitle,
      'description': _description,
      'deadline': _deadline.toIso8601String(),
      'grade_weight': _gradeWeight,
      'is_completed': _isCompleted ? 1 : 0,
    };
  }

  String get subTaskId => _subTaskId;
  String get groupTaskId => _groupTaskId;
  String get assignedToId => _assignedToId;
  String get subTaskTitle => _subTaskTitle;
  String get description => _description;
  DateTime get deadline => _deadline;
  double get gradeWeight => _gradeWeight;
  bool get isCompleted => _isCompleted;

  set groupTaskId(String val) => _groupTaskId = val;
  set assignedToId(String val) => _assignedToId = val;

  void setCompletionStatus(bool status) {
    _isCompleted = status;
  }

  int calculateRemainingTime() {
    return _deadline.difference(DateTime.now()).inHours;
  }
}
