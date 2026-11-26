class MeetingSchedule {
  String _meetingId;
  String _groupId;
  String _title;
  String? _description;
  DateTime _startTime;
  String _platformLocation;

  MeetingSchedule({
    required String meetingId,
    String groupId = '',
    required String title,
    String? description,
    required DateTime startTime,
    required String platformLocation,
  })  : _meetingId = meetingId,
        _groupId = groupId,
        _title = title,
        _description = description,
        _startTime = startTime,
        _platformLocation = platformLocation;

  factory MeetingSchedule.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return MeetingSchedule(
      meetingId: json['id_meeting']?.toString() ?? '',
      groupId: json['id_group']?.toString() ?? json['groupId']?.toString() ?? '',
      title: json['meeting_title']?.toString() ?? json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      startTime: parseDate(json['start_time']),
      platformLocation: json['platform_location']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_meeting': _meetingId,
      'id_group': _groupId,
      'meeting_title': _title,
      'description': _description,
      'start_time': _startTime.toIso8601String(),
      'platform_location': _platformLocation,
    };
  }

  String get meetingId => _meetingId;
  String get groupId => _groupId;
  String get title => _title;
  String? get description => _description;
  DateTime get startTime => _startTime;
  String get platformLocation => _platformLocation;

  set groupId(String val) => _groupId = val;

  String getMeetingDetails() {
    return '$_title pada $_startTime di $_platformLocation';
  }
}
