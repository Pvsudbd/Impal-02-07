class ToDoItem {
  String _itemId;
  String _activityTitle;
  String _notes;
  DateTime _date;
  bool _isDone;

  ToDoItem({
    required String itemId,
    required String activityTitle,
    required String notes,
    required DateTime date,
    bool isDone = false,
  })  : _itemId = itemId,
        _activityTitle = activityTitle,
        _notes = notes,
        _date = date,
        _isDone = isDone;

  factory ToDoItem.fromJson(Map<String, dynamic> json) {
    return ToDoItem(
      itemId: json['id_item'] ?? '',
      activityTitle: json['activity_title'] ?? '',
      notes: json['notes'] ?? '',
      date: DateTime.parse(json['date']),
      isDone: json['is_done'] == 1 || json['is_done'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_item': _itemId,
      'activity_title': _activityTitle,
      'notes': _notes,
      'date': _date.toIso8601String(),
      'is_done': _isDone ? 1 : 0,
    };
  }

  String get itemId => _itemId;
  String get activityTitle => _activityTitle;
  String get notes => _notes;
  DateTime get date => _date;
  bool get isDone => _isDone;

  void toggleStatus() {
    _isDone = !_isDone;
  }

  void updateActivity(String title, String notes) {
    _activityTitle = title;
    _notes = notes;
  }
}