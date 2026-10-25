import 'group_member.dart';
import 'group_task.dart';
import 'meeting_schedule.dart';

class StudyGroup {
  String _groupId;
  String _groupName;
  String _description;
  String _inviteCode;
  final List<GroupMember> _members = [];
  final List<MeetingSchedule> _meetings = [];
  final List<GroupTask> _tasks = [];

  StudyGroup({
    required String groupId,
    required String groupName,
    required String description,
    required String inviteCode,
  })  : _groupId = groupId,
        _groupName = groupName,
        _description = description,
        _inviteCode = inviteCode;

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      groupId: json['id_group'] ?? '',
      groupName: json['group_name'] ?? '',
      description: json['description'] ?? '',
      inviteCode: json['invite_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_group': _groupId,
      'group_name': _groupName,
      'description': _description,
      'invite_code': _inviteCode,
    };
  }

  String get groupId => _groupId;
  String get groupName => _groupName;
  String get description => _description;
  String get inviteCode => _inviteCode;

  void createGroupTask(GroupTask task) {
    _tasks.add(task);
  }

  void createMeetingSchedule(MeetingSchedule meeting) {
    _meetings.add(meeting);
  }

  List<GroupMember> getMemberList() {
    return _members;
  }
}