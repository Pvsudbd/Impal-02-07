import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import '../../config/db.dart';

/// Controller untuk mengelola Kelompok (Groups), Anggota Tim, Rapat, dan Tugas Kelompok.
///
/// Mematuhi spesifikasi PostgreSQL 15+ 3NF pada DATABASE_REQUIREMENTS.md
class GroupController {
  static const _uuid = Uuid();

  // Helper mengambil idUser dari token JWT yang telah diverifikasi middleware
  static String? _getUserId(Request req) {
    final user = (req.context['user'] ?? req.context['student']) as Map<String, dynamic>?;
    return (user?['idUser'] ?? user?['idStudent']) as String?;
  }

  // ─── 1. DAFTAR KELOMPOK PENGGUNA ──────────────────────────────────────────
  // GET /api/groups
  static Future<Response> getUserGroups(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      // Query seluruh kelompok di mana user adalah leader ATAU anggota terdaftar
      final sql = '''
        SELECT DISTINCT g.id_group, g.id_leader, g.group_name, g.description, g.invite_code, g.created_at
        FROM "groups" g
        LEFT JOIN group_member gm ON g.id_group = gm.id_group
        WHERE g.id_leader = @idUser OR gm.id_user = @idUser
        ORDER BY g.created_at DESC
      ''';

      final results = await Database.query(sql, {'idUser': idUser});
      final List<Map<String, dynamic>> groupsData = [];

      for (final row in results.rows) {
        final idGroup = row['id_group']?.toString() ?? '';

        // Hitung jumlah anggota untuk setiap kelompok
        final countRes = await Database.query(
          'SELECT COUNT(*) AS total FROM group_member WHERE id_group = @idGroup',
          {'idGroup': idGroup},
        );
        final memberCount = countRes.rows.isNotEmpty
            ? int.tryParse(countRes.rows.first['total']?.toString() ?? '1') ?? 1
            : 1;

        groupsData.add({
          'id_group': idGroup,
          'id': idGroup,
          'id_leader': row['id_leader'],
          'group_name': row['group_name'],
          'name': row['group_name'],
          'description': row['description'],
          'invite_code': row['invite_code'],
          'member_count': memberCount,
          'membersLabel': '$memberCount members',
        });
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'count': groupsData.length,
          'data': groupsData,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] getUserGroups error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── 2. BUAT KELOMPOK BARU (CREATE TEAM) ───────────────────────────────────
  // POST /api/groups
  static Future<Response> createGroup(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final groupName = (body['group_name'] ?? body['name'])?.toString().trim();
      final description = (body['description'] ?? '')?.toString().trim();
      var inviteCode = body['invite_code']?.toString().trim();

      if (groupName == null || groupName.isEmpty) {
        return Response(400,
            body: jsonEncode({'status': 'error', 'message': 'Group name is required'}),
            headers: {'Content-Type': 'application/json'});
      }

      // Generate kode jika tidak disediakan atau cek keunikan
      if (inviteCode == null || inviteCode.isEmpty) {
        inviteCode = _uuid.v4().substring(0, 6).toUpperCase();
      }

      // Validasi keunikan invite_code di PostgreSQL
      final existingCode = await Database.query(
        'SELECT id_group FROM "groups" WHERE invite_code = @code',
        {'code': inviteCode},
      );
      if (existingCode.rows.isNotEmpty) {
        inviteCode = '${inviteCode}_${_uuid.v4().substring(0, 3).toUpperCase()}';
      }

      final idGroup = 'grp_${_uuid.v4()}';

      // 1. Insert ke tabel groups
      final insertGroupSql = '''
        INSERT INTO "groups" (id_group, id_leader, group_name, description, invite_code, created_at, updated_at)
        VALUES (@idGroup, @idLeader, @groupName, @description, @inviteCode, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      ''';

      await Database.query(insertGroupSql, {
        'idGroup': idGroup,
        'idLeader': idUser,
        'groupName': groupName,
        'description': description,
        'inviteCode': inviteCode,
      });

      // 2. Otomatis tambahkan pencipta sebagai LEADER di tabel group_member
      final idMember = 'mem_${_uuid.v4()}';
      final insertMemberSql = '''
        INSERT INTO group_member (id_member, id_group, id_user, role, joined_at)
        VALUES (@idMember, @idGroup, @idUser, 'LEADER', CURRENT_TIMESTAMP)
      ''';

      await Database.query(insertMemberSql, {
        'idMember': idMember,
        'idGroup': idGroup,
        'idUser': idUser,
      });

      return Response(201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Team created successfully',
          'data': {
            'id_group': idGroup,
            'id': idGroup,
            'id_leader': idUser,
            'group_name': groupName,
            'name': groupName,
            'description': description,
            'invite_code': inviteCode,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] createGroup error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── 3. GABUNG KELOMPOK DENGAN KODE (JOIN TEAM) ────────────────────────────
  // POST /api/groups/join
  static Future<Response> joinGroup(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final inviteCode = (body['invite_code'] ?? body['code'])?.toString().trim().toUpperCase();

      if (inviteCode == null || inviteCode.isEmpty) {
        return Response(400,
            body: jsonEncode({'status': 'error', 'message': 'Invite code is required'}),
            headers: {'Content-Type': 'application/json'});
      }

      // 1. Cek apakah invite code benar-benar ada di database
      final groupQuery = await Database.query(
        'SELECT * FROM "groups" WHERE UPPER(invite_code) = @code',
        {'code': inviteCode},
      );

      if (groupQuery.rows.isEmpty) {
        return Response(404,
            body: jsonEncode({
              'status': 'error',
              'message': 'Invalid team invite code. Team not found.',
            }),
            headers: {'Content-Type': 'application/json'});
      }

      final groupRow = groupQuery.rows.first;
      final idGroup = groupRow['id_group'].toString();
      final groupName = groupRow['group_name'].toString();

      // 2. Cek apakah user sudah terdaftar di kelompok ini
      final memberCheck = await Database.query(
        'SELECT id_member FROM group_member WHERE id_group = @idGroup AND id_user = @idUser',
        {'idGroup': idGroup, 'idUser': idUser},
      );

      if (memberCheck.rows.isNotEmpty) {
        return Response(400,
            body: jsonEncode({
              'status': 'error',
              'message': 'You are already a member of this team.',
              'data': {
                'id_group': idGroup,
                'group_name': groupName,
              },
            }),
            headers: {'Content-Type': 'application/json'});
      }

      // 3. Tambahkan ke group_member
      final idMember = 'mem_${_uuid.v4()}';
      final insertMemberSql = '''
        INSERT INTO group_member (id_member, id_group, id_user, role, joined_at)
        VALUES (@idMember, @idGroup, @idUser, 'MEMBER', CURRENT_TIMESTAMP)
      ''';

      await Database.query(insertMemberSql, {
        'idMember': idMember,
        'idGroup': idGroup,
        'idUser': idUser,
      });

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Successfully joined team "$groupName"',
          'data': {
            'id_group': idGroup,
            'id': idGroup,
            'group_name': groupName,
            'name': groupName,
            'invite_code': inviteCode,
            'role': 'MEMBER',
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] joinGroup error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── 4. DETAIL KELOMPOK (MEMBERS, MEETINGS, TASKS) ─────────────────────────
  // GET /api/groups/<idGroup>
  static Future<Response> getGroupDetails(Request req, String idGroup) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) {
        return Response(401,
            body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'});
      }

      // Ambil data kelompok
      final groupQuery = await Database.query(
        'SELECT * FROM "groups" WHERE id_group = @idGroup',
        {'idGroup': idGroup},
      );

      if (groupQuery.rows.isEmpty) {
        return Response(404,
            body: jsonEncode({'status': 'error', 'message': 'Group not found'}),
            headers: {'Content-Type': 'application/json'});
      }

      final group = groupQuery.rows.first;

      // Ambil anggota
      final membersQuery = await Database.query('''
        SELECT gm.id_member, gm.role, gm.joined_at, u.id_user, u.name, u.email
        FROM group_member gm
        JOIN users u ON gm.id_user = u.id_user
        WHERE gm.id_group = @idGroup
        ORDER BY gm.role DESC, gm.joined_at ASC
      ''', {'idGroup': idGroup});

      // Ambil rapat kelompok
      final meetingsQuery = await Database.query('''
        SELECT * FROM meeting_schedule
        WHERE id_group = @idGroup
        ORDER BY start_time ASC
      ''', {'idGroup': idGroup});

      // Ambil tugas kelompok
      final tasksQuery = await Database.query('''
        SELECT gt.*, u.name AS pic_name
        FROM group_task gt
        LEFT JOIN users u ON gt.id_assigned_to = u.id_user
        WHERE gt.id_group = @idGroup
        ORDER BY gt.deadline ASC
      ''', {'idGroup': idGroup});

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'data': {
            'id_group': group['id_group'],
            'group_name': group['group_name'],
            'description': group['description'],
            'invite_code': group['invite_code'],
            'id_leader': group['id_leader'],
            'members': membersQuery.rows.map((r) => r.assoc()).toList(),
            'meetings': meetingsQuery.rows.map((r) => r.assoc()).toList(),
            'tasks': tasksQuery.rows.map((r) => r.assoc()).toList(),
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] getGroupDetails error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── 5. RAPAT KELOMPOK (MEETINGS) ──────────────────────────────────────────
  // GET /api/groups/<idGroup>/meetings
  static Future<Response> getGroupMeetings(Request req, String idGroup) async {
    try {
      final results = await Database.query('''
        SELECT * FROM meeting_schedule
        WHERE id_group = @idGroup
        ORDER BY start_time ASC
      ''', {'idGroup': idGroup});

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'count': results.rows.length,
          'data': results.rows.map((r) => r.assoc()).toList(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/groups/<idGroup>/meetings
  static Future<Response> createMeeting(Request req, String idGroup) async {
    try {
      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final title = (body['meeting_title'] ?? body['title'])?.toString().trim();
      final description = body['description']?.toString();
      final startTime = body['start_time']?.toString() ?? DateTime.now().toIso8601String();
      final platformLocation = (body['platform_location'] ?? body['location'])?.toString().trim() ?? 'Google Meet';

      if (title == null || title.isEmpty) {
        return Response(400,
            body: jsonEncode({'status': 'error', 'message': 'Meeting title is required'}),
            headers: {'Content-Type': 'application/json'});
      }

      final idMeeting = 'meet_${_uuid.v4()}';
      final sql = '''
        INSERT INTO meeting_schedule (id_meeting, id_group, meeting_title, description, start_time, platform_location, created_at)
        VALUES (@idMeeting, @idGroup, @title, @description, @startTime::timestamptz, @location, CURRENT_TIMESTAMP)
      ''';

      await Database.query(sql, {
        'idMeeting': idMeeting,
        'idGroup': idGroup,
        'title': title,
        'description': description,
        'startTime': startTime,
        'location': platformLocation,
      });

      return Response(201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Meeting created successfully',
          'data': {
            'id_meeting': idMeeting,
            'id_group': idGroup,
            'meeting_title': title,
            'description': description,
            'start_time': startTime,
            'platform_location': platformLocation,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] createMeeting error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── 6. TUGAS KELOMPOK (GROUP TASKS) ───────────────────────────────────────
  // GET /api/groups/<idGroup>/tasks
  static Future<Response> getGroupTasks(Request req, String idGroup) async {
    try {
      final tasksQuery = await Database.query('''
        SELECT gt.*, u.name AS pic_name
        FROM group_task gt
        LEFT JOIN users u ON gt.id_assigned_to = u.id_user
        WHERE gt.id_group = @idGroup
        ORDER BY gt.deadline ASC
      ''', {'idGroup': idGroup});

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'count': tasksQuery.rows.length,
          'data': tasksQuery.rows.map((r) => r.assoc()).toList(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/groups/<idGroup>/tasks
  static Future<Response> createGroupTask(Request req, String idGroup) async {
    try {
      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final taskTitle = (body['task_title'] ?? body['title'])?.toString().trim();
      final description = body['description']?.toString() ?? '';
      final deadline = body['deadline']?.toString() ?? DateTime.now().toIso8601String();
      final gradeWeight = (body['grade_weight'] as num?)?.toDouble() ?? 0.0;
      final priority = body['priority']?.toString() ?? 'MEDIUM';
      final assignedTo = body['id_assigned_to']?.toString();

      if (taskTitle == null || taskTitle.isEmpty) {
        return Response(400,
            body: jsonEncode({'status': 'error', 'message': 'Task title is required'}),
            headers: {'Content-Type': 'application/json'});
      }

      final idGroupTask = 'gtask_${_uuid.v4()}';
      final sql = '''
        INSERT INTO group_task (id_group_task, id_group, id_assigned_to, task_title, description, deadline, grade_weight, priority, is_completed, created_at, updated_at)
        VALUES (@idGroupTask, @idGroup, @assignedTo, @title, @desc, @deadline::timestamptz, @weight, @priority, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      ''';

      await Database.query(sql, {
        'idGroupTask': idGroupTask,
        'idGroup': idGroup,
        'assignedTo': assignedTo,
        'title': taskTitle,
        'desc': description,
        'deadline': deadline,
        'weight': gradeWeight,
        'priority': priority,
      });

      return Response(201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Group task created successfully',
          'data': {
            'id_group_task': idGroupTask,
            'id_group': idGroup,
            'task_title': taskTitle,
            'deadline': deadline,
            'grade_weight': gradeWeight,
            'priority': priority,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] createGroupTask error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
