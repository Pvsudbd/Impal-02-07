class Task {
  String _taskId;
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
    required String taskTitle,
    required String description,
    required DateTime deadline,
    required double gradeWeight,
    required double priorityScore,
    required String priority,
    required bool isFuzzyAuto,
    bool isCompleted = false,
  })  : _taskId = taskId,
        _taskTitle = taskTitle,
        _description = description,
        _deadline = deadline,
        _gradeWeight = gradeWeight,
        _priorityScore = priorityScore,
        _priority = priority,
        _isFuzzyAuto = isFuzzyAuto,
        _isCompleted = isCompleted;

  // Conversion for API JSON (Node.js <-> Dart)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['id_task'] ?? '',
      taskTitle: json['task_title'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      deadline: DateTime.parse(json['deadline']),
      gradeWeight: (json['grade_weight'] as num?)?.toDouble() ?? 0.0,
      priorityScore: (json['priority_score'] as num?)?.toDouble() ?? 0.0,
      priority: json['priority'] ?? 'MEDIUM',
      isFuzzyAuto: json['is_fuzzy_auto'] == 1 || json['is_fuzzy_auto'] == true,
      isCompleted: json['is_completed'] == 1 || json['is_completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_task': _taskId,
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
  String get taskTitle => _taskTitle;
  String get description => _description;
  DateTime get deadline => _deadline;
  double get gradeWeight => _gradeWeight;
  double get priorityScore => _priorityScore;
  String get priority => _priority;
  bool get isFuzzyAuto => _isFuzzyAuto;
  bool get isCompleted => _isCompleted;

  // Methods
  int calculateRemainingTime() {
    return _deadline.difference(DateTime.now()).inHours;
  }

  void setCompletionStatus(bool status) {
    _isCompleted = status;
  }

  void updateFuzzyPriority(double score, String level) {
    _priorityScore = score;
    _priority = level;
  }
}