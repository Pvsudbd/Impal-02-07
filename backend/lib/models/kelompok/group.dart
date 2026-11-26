import 'group_member.dart';
import 'group_task.dart';
import 'meeting_schedule.dart';

typedef StudyGroup = Group;
typedef GroupModel = Group;

class Group {
  String _groupId;
  String _leaderId;
  String _groupName;
  String _description;
  String _inviteCode;
  final List<GroupMember> _members = [];
  final List<MeetingSchedule> _meetings = [];
  final List<GroupTask> _tasks = [];

  Group({
    required String groupId,
    required String groupName,
    required String description,
    required String inviteCode,
    String leaderId = '',
  })  : _groupId = groupId,
        _leaderId = leaderId,
        _groupName = groupName,
        _description = description,
        _inviteCode = inviteCode;

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['id_group'] ?? '',
      leaderId: json['id_leader'] ?? json['leader_id'] ?? json['id_user'] ?? '',
      groupName: json['group_name'] ?? '',
      description: json['description'] ?? '',
      inviteCode: json['invite_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_group': _groupId,
      'id_leader': _leaderId,
      'group_name': _groupName,
      'description': _description,
      'invite_code': _inviteCode,
    };
  }

  String get groupId => _groupId;
  String get leaderId => _leaderId;
  String get groupName => _groupName;
  String get description => _description;
  String get inviteCode => _inviteCode;

  set leaderId(String val) => _leaderId = val;

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

