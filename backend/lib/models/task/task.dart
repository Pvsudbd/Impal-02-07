class Task {
  String _taskId;
  String _userId;
  String _courseCode;
  String _taskTitle;
  String _description;
  DateTime _deadline;
  double _gradeWeight;
  double _priorityScore;
  String _priority;
  bool _isFuzzyAuto;
  bool _isCompleted;

  Task({
    required String taskId,
    String userId = '',
    String courseCode = '',
    required String taskTitle,
    required String description,
    required DateTime deadline,
    required double gradeWeight,
    required double priorityScore,
    required String priority,
    required bool isFuzzyAuto,
    bool isCompleted = false,
  })  : _taskId = taskId,
        _userId = userId,
        _courseCode = courseCode,
        _taskTitle = taskTitle,
        _description = description,
        _deadline = deadline,
        _gradeWeight = gradeWeight,
        _priorityScore = priorityScore,
        _priority = priority,
        _isFuzzyAuto = isFuzzyAuto,
        _isCompleted = isCompleted;

  // Conversion for API JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return Task(
      taskId: json['id_task']?.toString() ?? '',
      userId: json['id_user']?.toString() ?? json['userId']?.toString() ?? '',
      courseCode: json['course_code']?.toString() ?? json['courseCode']?.toString() ?? '',
      taskTitle: json['task_title']?.toString() ?? json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      deadline: parseDate(json['deadline']),
      gradeWeight: (json['grade_weight'] as num?)?.toDouble() ?? 0.0,
      priorityScore: (json['priority_score'] as num?)?.toDouble() ?? 0.0,
      priority: json['priority']?.toString() ?? 'MEDIUM',
      isFuzzyAuto: json['is_fuzzy_auto'] == 1 || json['is_fuzzy_auto'] == true,
      isCompleted: json['is_completed'] == 1 || json['is_completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_task': _taskId,
      'id_user': _userId,
      'course_code': _courseCode,
      'task_title': _taskTitle,
      'description': _description,
      'deadline': _deadline.toIso8601String(),
      'grade_weight': _gradeWeight,
      'priority_score': _priorityScore,
      'priority': _priority,
      'is_fuzzy_auto': _isFuzzyAuto ? 1 : 0,
      'is_completed': _isCompleted ? 1 : 0,
    };
  }

  // Getters
  String get taskId => _taskId;
  String get userId => _userId;
  String get courseCode => _courseCode;
  String get taskTitle => _taskTitle;
  String get description => _description;
  DateTime get deadline => _deadline;
  double get gradeWeight => _gradeWeight;
  double get priorityScore => _priorityScore;
  String get priority => _priority;
  bool get isFuzzyAuto => _isFuzzyAuto;
  bool get isCompleted => _isCompleted;
  bool get isOverdue => _deadline.isBefore(DateTime.now());

  set userId(String val) => _userId = val;
  set courseCode(String val) => _courseCode = val;

  // Methods
  int calculateRemainingTime() {
    return _deadline.difference(DateTime.now()).inHours;
  }

  void setCompletionStatus(bool status) {
    _isCompleted = status;
  }

  void updateFuzzyPriority(double score, String level) {
    if (isOverdue) {
      _priorityScore = 0.0;
      _priority = 'LOW';
      _isFuzzyAuto = false;
      return;
    }
    _priorityScore = score;
    _priority = level;
  }
}
