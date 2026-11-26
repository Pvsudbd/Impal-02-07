class ToDoItem {
  String _itemId;
  String _userId;
  String _activityTitle;
  String _notes;
  DateTime _date;
  bool _isDone;

  ToDoItem({
    required String itemId,
    String userId = '',
    required String activityTitle,
    required String notes,
    required DateTime date,
    bool isDone = false,
  })  : _itemId = itemId,
        _userId = userId,
        _activityTitle = activityTitle,
        _notes = notes,
        _date = date,
        _isDone = isDone;

  factory ToDoItem.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return ToDoItem(
      itemId: json['id_item']?.toString() ?? '',
      userId: json['id_user']?.toString() ?? json['userId']?.toString() ?? '',
      activityTitle: json['activity_title']?.toString() ?? json['title']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      date: parseDate(json['date']),
      isDone: json['is_done'] == 1 || json['is_done'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_item': _itemId,
      'id_user': _userId,
      'activity_title': _activityTitle,
      'notes': _notes,
      'date': _date.toIso8601String(),
      'is_done': _isDone ? 1 : 0,
    };
  }

  String get itemId => _itemId;
  String get userId => _userId;
  String get activityTitle => _activityTitle;
  String get notes => _notes;
  DateTime get date => _date;
  bool get isDone => _isDone;

  set userId(String val) => _userId = val;

  void toggleStatus() {
    _isDone = !_isDone;
  }

  void updateActivity(String title, String notes) {
    _activityTitle = title;
    _notes = notes;
  }
}
