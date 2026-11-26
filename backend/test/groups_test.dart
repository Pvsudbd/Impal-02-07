import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import 'package:backend/config/db.dart';
import 'package:backend/controllers/auth/auth_controller.dart';
import 'package:backend/controllers/group/group_controller.dart';
import 'package:backend/middleware/auth/auth_middleware.dart';

void main() {
  final runId = DateTime.now().millisecondsSinceEpoch;
  final emailLeader = 'grp_leader_$runId@example.com';
  final emailMember = 'grp_member_$runId@example.com';
  final emailOutsider = 'grp_outsider_$runId@example.com';
  const password = 'Password123';

  final createdUserIds = <String>[];
  final createdGroupIds = <String>[];

  late String leaderId;
  late String memberId;
  late String outsiderId;
  late String tokenLeader;
  late String tokenMember;
  late String tokenOutsider;

  Request jsonRequest(
    String method,
    String path, {
    Object? body,
    String? token,
  }) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['authorization'] = 'Bearer $token';
    }
    return Request(
      method,
      Uri.parse('http://localhost:3000$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<Response> authed(Handler handler, Request req) async {
    return await checkAuthMiddleware()(handler)(req);
  }

  setUpAll(() async {
    Database.init();
    Database.getPool();

    Future<(String, String)> regAndLogin(String name, String email) async {
      final reg = await AuthController.register(
        jsonRequest('POST', '/api/auth/register', body: {
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      final uid = (jsonDecode(await reg.readAsString()) as Map<String, dynamic>)['idUser'] as String;
      createdUserIds.add(uid);

      final login = await AuthController.login(
        jsonRequest('POST', '/api/auth/login', body: {
          'email': email,
          'password': password,
        }),
      );
      final tok = (jsonDecode(await login.readAsString()) as Map<String, dynamic>)['token'] as String;
      return (uid, tok);
    }

    (leaderId, tokenLeader) = await regAndLogin('Leader A', emailLeader);
    (memberId, tokenMember) = await regAndLogin('Member B', emailMember);
    (outsiderId, tokenOutsider) = await regAndLogin('Outsider C', emailOutsider);
  });

  tearDownAll(() async {
    try {
      for (final gid in createdGroupIds) {
        await Database.query(
          'DELETE FROM group_sub_task WHERE id_group_task IN (SELECT id_group_task FROM group_task WHERE id_group = :gid)',
          {'gid': gid},
        );
        await Database.query('DELETE FROM group_task WHERE id_group = :gid', {'gid': gid});
        await Database.query('DELETE FROM group_milestone WHERE id_group = :gid', {'gid': gid});
        await Database.query('DELETE FROM meeting_schedule WHERE id_group = :gid', {'gid': gid});
        await Database.query('DELETE FROM group_member WHERE id_group = :gid', {'gid': gid});
        await Database.query('DELETE FROM "groups" WHERE id_group = :gid', {'gid': gid});
      }
      for (final uid in createdUserIds) {
        await Database.query('DELETE FROM users WHERE id_user = :uid', {'uid': uid});
      }
    } finally {
      await Database.close();
    }
  });

  group('Prioritas 2A: /api/groups End-to-End Flow, BOLA & Anti-Orphan', () {
    test('covers groups, invite join, BOLA, milestones, group tasks, subtasks, meetings, leave & orphan-free disband', () async {
      // 1. Create Group by Leader A
      final createRes = await authed(
        GroupController.createGroup,
        jsonRequest('POST', '/api/groups', token: tokenLeader, body: {
          'groupName': 'IMPAL Sprint Team $runId',
          'description': 'Collaboration test group',
        }),
      );
      expect(createRes.statusCode, 201);
      final groupData = (jsonDecode(await createRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final idGroup = groupData['idGroup'] as String;
      final inviteCode = groupData['inviteCode'] as String;
      createdGroupIds.add(idGroup);
      expect(groupData['idLeader'], leaderId);
      expect(groupData['groupSize'], 1);
      expect(groupData['myRole'], 'LEADER');
      expect(inviteCode, isNotEmpty);

      // 2. Join via Invite Code by Member B
      final invalidJoin = await authed(
        GroupController.joinGroup,
        jsonRequest('POST', '/api/groups/join', token: tokenMember, body: {
          'inviteCode': 'INVALID99',
        }),
      );
      expect(invalidJoin.statusCode, 404);

      final joinRes = await authed(
        GroupController.joinGroup,
        jsonRequest('POST', '/api/groups/join', token: tokenMember, body: {
          'inviteCode': inviteCode,
        }),
      );
      expect(joinRes.statusCode, 200);
      final joinedData = (jsonDecode(await joinRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      expect(joinedData['groupSize'], 2);
      expect(joinedData['myRole'], 'MEMBER');
      expect((joinedData['members'] as List<dynamic>).length, 2);

      // Duplicate join -> 409
      final dupJoin = await authed(
        GroupController.joinGroup,
        jsonRequest('POST', '/api/groups/join', token: tokenMember, body: {
          'inviteCode': inviteCode,
        }),
      );
      expect(dupJoin.statusCode, 409);

      // 3. BOLA checks: Outsider C blocked (403); Member B cannot update/disband (403)
      final outsiderDetail = await authed(
        (req) => GroupController.getGroupDetail(req, idGroup),
        jsonRequest('GET', '/api/groups/$idGroup', token: tokenOutsider),
      );
      expect(outsiderDetail.statusCode, 403);

      final outsiderTasks = await authed(
        (req) => GroupController.listGroupTasks(req, idGroup),
        jsonRequest('GET', '/api/groups/$idGroup/tasks', token: tokenOutsider),
      );
      expect(outsiderTasks.statusCode, 403);

      final memberUpdate = await authed(
        (req) => GroupController.updateGroup(req, idGroup),
        jsonRequest('PUT', '/api/groups/$idGroup', token: tokenMember, body: {
          'groupName': 'Hijacked Group',
        }),
      );
      expect(memberUpdate.statusCode, 403);

      final memberDisband = await authed(
        (req) => GroupController.disbandGroup(req, idGroup),
        jsonRequest('DELETE', '/api/groups/$idGroup', token: tokenMember),
      );
      expect(memberDisband.statusCode, 403);

      // 4. Milestones CRUD
      final msRes = await authed(
        (req) => GroupController.createMilestone(req, idGroup),
        jsonRequest('POST', '/api/groups/$idGroup/milestones', token: tokenLeader, body: {
          'title': 'Responsi 1',
          'description': 'Backend API milestone',
          'deadline': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        }),
      );
      expect(msRes.statusCode, 201);
      final msData = (jsonDecode(await msRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final idMilestone = msData['idMilestone'] as String;

      // 5. Group Tasks CRUD + assignee validation + auto-Fuzzy + completion authorization
      // Non-member assignee rejected (400)
      final badAssigneeRes = await authed(
        (req) => GroupController.createGroupTask(req, idGroup),
        jsonRequest('POST', '/api/groups/$idGroup/tasks', token: tokenLeader, body: {
          'title': 'Illegal Assignee Task',
          'deadline': DateTime.now().add(const Duration(hours: 12)).toIso8601String(),
          'idAssignedTo': outsiderId,
        }),
      );
      expect(badAssigneeRes.statusCode, 400);

      // Valid task assigned to Member B linked to milestone
      final taskLeaderRes = await authed(
        (req) => GroupController.createGroupTask(req, idGroup),
        jsonRequest('POST', '/api/groups/$idGroup/tasks', token: tokenLeader, body: {
          'title': 'Build Group Endpoint',
          'deadline': DateTime.now().add(const Duration(hours: 12)).toIso8601String(),
          'gradeWeight': 40,
          'isFuzzyAuto': true,
          'idAssignedTo': memberId,
          'idMilestone': idMilestone,
          'tags': ['Backend', 'API'],
        }),
      );
      expect(taskLeaderRes.statusCode, 201);
      final taskMemberData = (jsonDecode(await taskLeaderRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final idGroupTaskForMember = taskMemberData['idGroupTask'] as String;
      expect(taskMemberData['priority'], 'HIGH');
      expect(taskMemberData['tags'], ['Backend', 'API']);

      // Valid task assigned to Leader A -> Member B MUST get 403 if trying to complete Leader A's task
      final taskAssignedLeaderRes = await authed(
        (req) => GroupController.createGroupTask(req, idGroup),
        jsonRequest('POST', '/api/groups/$idGroup/tasks', token: tokenLeader, body: {
          'title': 'Leader Only Task',
          'deadline': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
          'gradeWeight': 20,
          'idAssignedTo': leaderId,
          'idMilestone': idMilestone,
        }),
      );
      expect(taskAssignedLeaderRes.statusCode, 201);
      final idGroupTaskForLeader = ((jsonDecode(await taskAssignedLeaderRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>)['idGroupTask'] as String;

      final forbiddenComplete = await authed(
        (req) => GroupController.toggleGroupTaskComplete(req, idGroup, idGroupTaskForLeader),
        jsonRequest('PATCH', '/api/groups/$idGroup/tasks/$idGroupTaskForLeader/complete', token: tokenMember),
      );
      expect(forbiddenComplete.statusCode, 403);

      // Member B CAN complete their own assigned task
      final memberComplete = await authed(
        (req) => GroupController.toggleGroupTaskComplete(req, idGroup, idGroupTaskForMember),
        jsonRequest('PATCH', '/api/groups/$idGroup/tasks/$idGroupTaskForMember/complete', token: tokenMember, body: {
          'isCompleted': true,
        }),
      );
      expect(memberComplete.statusCode, 200);

      // Verify Milestone progressPercent is 50% (1 of 2 tasks completed)
      final msListRes = await authed(
        (req) => GroupController.listMilestones(req, idGroup),
        jsonRequest('GET', '/api/groups/$idGroup/milestones', token: tokenLeader),
      );
      expect(msListRes.statusCode, 200);
      final msItem = ((jsonDecode(await msListRes.readAsString()) as Map<String, dynamic>)['data'] as List<dynamic>).first as Map<String, dynamic>;
      expect(msItem['totalTasks'], 2);
      expect(msItem['completedTasks'], 1);
      expect(msItem['progressPercent'], 50);

      // 6. Subtasks CRUD & toggle complete
      final subRes = await authed(
        (req) => GroupController.createSubTask(req, idGroup, idGroupTaskForMember),
        jsonRequest('POST', '/api/groups/$idGroup/tasks/$idGroupTaskForMember/subtasks', token: tokenLeader, body: {
          'subTaskTitle': 'Write GroupRepository',
          'deadline': DateTime.now().add(const Duration(hours: 6)).toIso8601String(),
          'gradeWeight': 15,
          'idAssignedTo': memberId,
        }),
      );
      expect(subRes.statusCode, 201);
      final idSubTask = ((jsonDecode(await subRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>)['idSubTask'] as String;

      final subToggle = await authed(
        (req) => GroupController.toggleSubTaskComplete(req, idGroup, idGroupTaskForMember, idSubTask),
        jsonRequest('PATCH', '/api/groups/$idGroup/tasks/$idGroupTaskForMember/subtasks/$idSubTask/complete', token: tokenMember, body: {
          'isCompleted': true,
        }),
      );
      expect(subToggle.statusCode, 200);
      expect(((jsonDecode(await subToggle.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>)['isCompleted'], true);

      // 7. Meetings CRUD
      final meetRes = await authed(
        (req) => GroupController.createMeeting(req, idGroup),
        jsonRequest('POST', '/api/groups/$idGroup/meetings', token: tokenLeader, body: {
          'meetingTitle': 'Weekly Sync IMPAL',
          'description': 'Demo API progress',
          'startTime': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
          'platformLocation': 'https://meet.google.com/impal-sync',
        }),
      );
      expect(meetRes.statusCode, 201);
      final idMeeting = ((jsonDecode(await meetRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>)['idMeeting'] as String;

      final meetUpdate = await authed(
        (req) => GroupController.updateMeeting(req, idGroup, idMeeting),
        jsonRequest('PUT', '/api/groups/$idGroup/meetings/$idMeeting', token: tokenMember, body: {
          'meetingTitle': 'Weekly Sync IMPAL Updated',
        }),
      );
      expect(meetUpdate.statusCode, 200);

      // 8. Leave constraints & orphan-free Disband
      final leaderLeaveBlocked = await authed(
        (req) => GroupController.leaveGroup(req, idGroup),
        jsonRequest('DELETE', '/api/groups/$idGroup/leave', token: tokenLeader),
      );
      expect(leaderLeaveBlocked.statusCode, 409);

      final memberLeave = await authed(
        (req) => GroupController.leaveGroup(req, idGroup),
        jsonRequest('DELETE', '/api/groups/$idGroup/leave', token: tokenMember),
      );
      expect(memberLeave.statusCode, 200);

      final detailAfterLeave = await authed(
        (req) => GroupController.getGroupDetail(req, idGroup),
        jsonRequest('GET', '/api/groups/$idGroup', token: tokenLeader),
      );
      expect(((jsonDecode(await detailAfterLeave.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>)['groupSize'], 1);

      final disbandRes = await authed(
        (req) => GroupController.disbandGroup(req, idGroup),
        jsonRequest('DELETE', '/api/groups/$idGroup', token: tokenLeader),
      );
      expect(disbandRes.statusCode, 200);

      // Verify zero orphan rows across all 6 tables
      for (final query in [
        'SELECT COUNT(*) FROM "groups" WHERE id_group = :gid',
        'SELECT COUNT(*) FROM group_member WHERE id_group = :gid',
        'SELECT COUNT(*) FROM group_milestone WHERE id_group = :gid',
        'SELECT COUNT(*) FROM group_task WHERE id_group = :gid',
        'SELECT COUNT(*) FROM meeting_schedule WHERE id_group = :gid',
      ]) {
        final check = await Database.query(query, {'gid': idGroup});
        expect(int.parse(check.rows.first.colAt(0).toString()), 0);
      }
      final subOrphan = await Database.query(
        'SELECT COUNT(*) FROM group_sub_task WHERE id_sub_task = :sid',
        {'sid': idSubTask},
      );
      expect(int.parse(subOrphan.rows.first.colAt(0).toString()), 0);
    });
  });
}
