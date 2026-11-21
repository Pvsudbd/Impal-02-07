import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import '../../config/db.dart';

/// Controller untuk mengelola Kelompok (Groups), Anggota Tim, Rapat, dan Tugas Kelompok.
///
/// Mematuhi spesifikasi PostgreSQL 15+ 3NF pada DATABASE_REQUIREMENTS.md
class GroupController {
  static const _uuid = Uuid();

  /// Konversi semua DateTime dalam Map ke String ISO 8601 agar bisa di-jsonEncode
  static dynamic _toJsonSafe(dynamic v) {
    if (v is DateTime) return v.toIso8601String();
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), _toJsonSafe(val)));
    if (v is List) return v.map(_toJsonSafe).toList();
    return v;
  }

  static Map<String, dynamic> _serializeRow(Map<String, dynamic> row) {
    return row.map((k, v) => MapEntry(k, _toJsonSafe(v)));
  }

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
      QueryResult results;
      try {
        results = await Database.query('''
          SELECT DISTINCT g.id_group, g.id_leader, g.group_name, g.description, g.invite_code, g.created_at
          FROM "groups" g
          LEFT JOIN group_member gm ON g.id_group::text = gm.id_group::text
          WHERE g.id_leader::text = @idUser OR gm.id_user::text = @idUser
          ORDER BY g.created_at DESC
        ''', {'idUser': idUser});
      } catch (e) {
        if (e.toString().contains('id_user') || e.toString().contains('gm.id_user')) {
          results = await Database.query('''
            SELECT DISTINCT g.id_group, g.id_leader, g.group_name, g.description, g.invite_code, g.created_at
            FROM "groups" g
            LEFT JOIN group_member gm ON g.id_group::text = gm.id_group::text
            WHERE g.id_leader::text = @idUser OR gm.id_student::text = @idUser
            ORDER BY g.created_at DESC
          ''', {'idUser': idUser});
        } else {
          rethrow;
        }
      }
      final List<Map<String, dynamic>> groupsData = [];

      for (final row in results.rows) {
        final idGroup = row['id_group']?.toString() ?? '';

        // Hitung jumlah anggota untuk setiap kelompok
        final countRes = await Database.query(
          'SELECT COUNT(*) AS total FROM group_member WHERE id_group::text = @idGroup',
          {'idGroup': idGroup},
        );
        final memberCount = countRes.rows.isNotEmpty
            ? int.tryParse(countRes.rows.first['total']?.toString() ?? '1') ?? 1
            : 1;

        groupsData.add({
          'id_group': idGroup,
          'id': idGroup,
          'id_leader': row['id_leader']?.toString(),
          'group_name': row['group_name']?.toString(),
          'name': row['group_name']?.toString(),
          'description': row['description']?.toString(),
          'invite_code': row['invite_code']?.toString(),
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

      // Generate kode jika tidak disediakan atau cek keunikan (maksimal 10 karakter untuk VARCHAR(10))
      if (inviteCode == null || inviteCode.isEmpty) {
        inviteCode = _uuid.v4().replaceAll('-', '').substring(0, 6).toUpperCase();
      } else if (inviteCode.length > 10) {
        inviteCode = inviteCode.substring(0, 10).toUpperCase();
      }

      // Validasi keunikan invite_code di PostgreSQL
      final existingCode = await Database.query(
        'SELECT id_group FROM "groups" WHERE invite_code = @code',
        {'code': inviteCode},
      );
      if (existingCode.rows.isNotEmpty) {
        inviteCode = _uuid.v4().replaceAll('-', '').substring(0, 6).toUpperCase();
      }

      // Standar UUID 36 karakter (VARCHAR(36)), tanpa prefix 'grp_' agar tidak melebihi VARCHAR(36)
      final idGroup = _uuid.v4();

      // 1. Insert ke tabel groups
      final insertGroupSql = '''
        INSERT INTO "groups" (id_group, id_leader, group_name, description, invite_code, created_at)
        VALUES (@idGroup, @idLeader, @groupName, @description, @inviteCode, CURRENT_TIMESTAMP)
      ''';

      await Database.query(insertGroupSql, {
        'idGroup': idGroup,
        'idLeader': idUser,
        'groupName': groupName,
        'description': description,
        'inviteCode': inviteCode,
      });

      // 2. Otomatis tambahkan pencipta sebagai LEADER di tabel group_member (UUID 36 karakter)
      final idMember = _uuid.v4();
      try {
        await Database.query(
          '''
          INSERT INTO group_member (id_member, id_group, id_user, role, joined_at)
          VALUES (@idMember, @idGroup, @idUser, 'LEADER', CURRENT_TIMESTAMP)
          ''',
          {
            'idMember': idMember,
            'idGroup': idGroup,
            'idUser': idUser,
          },
        );
      } catch (e) {
        if (e.toString().contains('id_user')) {
          await Database.query(
            '''
            INSERT INTO group_member (id_member, id_group, id_student, role, joined_at)
            VALUES (@idMember, @idGroup, @idUser, 'LEADER', CURRENT_TIMESTAMP)
            ''',
            {
              'idMember': idMember,
              'idGroup': idGroup,
              'idUser': idUser,
            },
          );
        } else {
          rethrow;
        }
      }

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
      QueryResult memberCheck;
      try {
        memberCheck = await Database.query(
          'SELECT id_member FROM group_member WHERE id_group::text = @idGroup AND id_user::text = @idUser',
          {'idGroup': idGroup, 'idUser': idUser},
        );
      } catch (e) {
        if (e.toString().contains('id_user')) {
          memberCheck = await Database.query(
            'SELECT id_member FROM group_member WHERE id_group::text = @idGroup AND id_student::text = @idUser',
            {'idGroup': idGroup, 'idUser': idUser},
          );
        } else {
          rethrow;
        }
      }

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

      // 3. Tambahkan ke group_member (UUID 36 karakter)
      final idMember = _uuid.v4();
      try {
        await Database.query(
          '''
          INSERT INTO group_member (id_member, id_group, id_user, role, joined_at)
          VALUES (@idMember, @idGroup, @idUser, 'MEMBER', CURRENT_TIMESTAMP)
          ''',
          {
            'idMember': idMember,
            'idGroup': idGroup,
            'idUser': idUser,
          },
        );
      } catch (e) {
        if (e.toString().contains('id_user')) {
          await Database.query(
            '''
            INSERT INTO group_member (id_member, id_group, id_student, role, joined_at)
            VALUES (@idMember, @idGroup, @idUser, 'MEMBER', CURRENT_TIMESTAMP)
            ''',
            {
              'idMember': idMember,
              'idGroup': idGroup,
              'idUser': idUser,
            },
          );
        } else {
          rethrow;
        }
      }

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

  // Helper untuk mencari grup berdasarkan id_group UUID, invite_code, atau group_name
  static Future<Map<String, dynamic>?> _findGroupRecord(String idOrCode) async {
    try {
      final res = await Database.query(
        '''
        SELECT * FROM "groups" 
        WHERE id_group::text = @val 
           OR UPPER(invite_code) = UPPER(@val) 
           OR LOWER(group_name) = LOWER(@val) 
        LIMIT 1
        ''',
        {'val': idOrCode},
      );
      if (res.rows.isNotEmpty) {
        return res.rows.first.assoc();
      }
    } catch (e) {
      print('[GROUPS] _findGroupRecord error: $e');
    }
    return null;
  }

  // Helper mencari profil user secara toleran terhadap skema id_user / id_student dan name / nama
  static Future<Map<String, dynamic>?> _findUserById(String uid) async {
    final queries = [
      'SELECT id_user, name, email FROM users WHERE id_user::text = @uid LIMIT 1',
      'SELECT id_student AS id_user, name, email FROM users WHERE id_student::text = @uid LIMIT 1',
      'SELECT id_user, nama AS name, email FROM users WHERE id_user::text = @uid LIMIT 1',
      'SELECT id_student AS id_user, nama AS name, email FROM users WHERE id_student::text = @uid LIMIT 1',
      'SELECT id_user, username AS name, email FROM users WHERE id_user::text = @uid LIMIT 1',
      'SELECT id_student AS id_user, username AS name, email FROM users WHERE id_student::text = @uid LIMIT 1',
    ];
    for (final q in queries) {
      try {
        final res = await Database.query(q, {'uid': uid});
        if (res.rows.isNotEmpty) {
          return res.rows.first.assoc();
        }
      } catch (_) {}
    }
    return null;
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

      // Ambil data kelompok (support id_group UUID, invite_code, atau group_name)
      final group = await _findGroupRecord(idGroup);

      if (group == null) {
        return Response(404,
            body: jsonEncode({'status': 'error', 'message': 'Group not found'}),
            headers: {'Content-Type': 'application/json'});
      }

      final realIdGroup = group['id_group']?.toString() ?? idGroup;
      final idLeader = group['id_leader']?.toString();

      // Ambil seluruh anggota terdaftar dari group_member
      List<Map<String, dynamic>> memberList = [];
      try {
        final gmRes = await Database.query(
          'SELECT * FROM group_member WHERE id_group::text = @idGroup',
          {'idGroup': realIdGroup},
        );
        print('[GROUPS] getGroupDetails found ${gmRes.rows.length} member rows for group $realIdGroup');
        for (final gmRow in gmRes.rows) {
          final uid = (gmRow['id_user'] ?? gmRow['id_student'] ?? gmRow['member_id'])?.toString();
          if (uid != null && uid.isNotEmpty) {
            final uRow = await _findUserById(uid);
            final rawRole = gmRow['role']?.toString().toUpperCase() ?? 'MEMBER';
            final isGroupLeader = (idLeader != null && uid == idLeader) || rawRole == 'LEADER';
            final rawJoinedAt = gmRow['joined_at'] ?? gmRow['joined_date'];
            memberList.add({
              'id_member': gmRow['id_member']?.toString() ?? 'mem_$uid',
              'role': isGroupLeader ? 'LEADER' : 'MEMBER',
              'joined_at': rawJoinedAt is DateTime ? rawJoinedAt.toIso8601String() : rawJoinedAt?.toString(),
              'id_user': uRow?['id_user']?.toString() ?? uid,
              'name': uRow?['name']?.toString() ?? uid,
              'email': uRow?['email']?.toString() ?? '',
            });
          }
        }
      } catch (e) {
        print('[GROUPS] getGroupDetails fetch group_member error: $e');
      }

      // Pastikan leader (pencipta kelompok) selalu masuk jika belum terdaftar di group_member
      if (idLeader != null && idLeader.isNotEmpty) {
        final leaderIndex = memberList.indexWhere((m) =>
            m['id_user']?.toString() == idLeader ||
            m['id_member']?.toString() == idLeader);
        if (leaderIndex != -1) {
          memberList[leaderIndex]['role'] = 'LEADER';
        } else {
          final lr = await _findUserById(idLeader);
          final rawCreatedAt = group['created_at'];
          memberList.insert(0, {
            'id_member': 'leader_$idLeader',
            'role': 'LEADER',
            'joined_at': rawCreatedAt is DateTime ? rawCreatedAt.toIso8601String() : rawCreatedAt?.toString(),
            'id_user': lr?['id_user']?.toString() ?? idLeader,
            'name': lr?['name']?.toString() ?? 'Team Leader',
            'email': lr?['email']?.toString() ?? '',
          });
        }
      }

      // Pastikan selain idLeader memiliki role MEMBER
      if (idLeader != null && idLeader.isNotEmpty) {
        for (final m in memberList) {
          if (m['id_user']?.toString() != idLeader && m['role'] == 'LEADER') {
            m['role'] = 'MEMBER';
          }
        }
      }

      // Sort: LEADER selalu paling atas, lalu member
      memberList.sort((a, b) {
        if (a['role'] == 'LEADER' && b['role'] != 'LEADER') return -1;
        if (b['role'] == 'LEADER' && a['role'] != 'LEADER') return 1;
        return (a['name']?.toString() ?? '').compareTo(b['name']?.toString() ?? '');
      });

      // Ambil rapat kelompok
      QueryResult meetingsQuery;
      try {
        meetingsQuery = await Database.query('''
          SELECT * FROM meeting_schedule
          WHERE id_group::text = @idGroup
          ORDER BY start_time ASC
        ''', {'idGroup': realIdGroup});
      } catch (_) {
        meetingsQuery = await Database.query('SELECT 1 WHERE 1=0');
      }

      // Ambil tugas kelompok
      QueryResult tasksQuery;
      try {
        tasksQuery = await Database.query('''
          SELECT gt.*, u.name AS pic_name
          FROM group_task gt
          LEFT JOIN users u ON gt.id_assigned_to::text = u.id_user::text
          WHERE gt.id_group::text = @idGroup
          ORDER BY gt.deadline ASC
        ''', {'idGroup': realIdGroup});
      } catch (_) {
        try {
          tasksQuery = await Database.query('''
            SELECT gt.*, u.name AS pic_name
            FROM group_task gt
            LEFT JOIN users u ON gt.id_assigned_to::text = u.id_student::text
            WHERE gt.id_group::text = @idGroup
            ORDER BY gt.deadline ASC
          ''', {'idGroup': realIdGroup});
        } catch (_) {
          tasksQuery = await Database.query('SELECT 1 WHERE 1=0');
        }
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'data': {
            'id_group': group['id_group']?.toString(),
            'group_name': group['group_name']?.toString(),
            'description': group['description']?.toString(),
            'invite_code': group['invite_code']?.toString(),
            'id_leader': group['id_leader']?.toString(),
            'members': memberList.map(_serializeRow).toList(),
            'meetings': meetingsQuery.rows.map((r) => _serializeRow(r.assoc())).toList(),
            'tasks': tasksQuery.rows.map((r) => _serializeRow(r.assoc())).toList(),
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
      final group = await _findGroupRecord(idGroup);
      final realIdGroup = group?['id_group']?.toString() ?? idGroup;

      final results = await Database.query('''
        SELECT * FROM meeting_schedule
        WHERE id_group = @idGroup
        ORDER BY start_time ASC
      ''', {'idGroup': realIdGroup});

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
      final group = await _findGroupRecord(idGroup);
      final realIdGroup = group?['id_group']?.toString() ?? idGroup;

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

      final idMeeting = _uuid.v4();
      final sql = '''
        INSERT INTO meeting_schedule (id_meeting, id_group, meeting_title, description, start_time, platform_location, created_at)
        VALUES (@idMeeting, @idGroup, @title, @description, @startTime::timestamptz, @location, CURRENT_TIMESTAMP)
      ''';

      await Database.query(sql, {
        'idMeeting': idMeeting,
        'idGroup': realIdGroup,
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
            'id_group': realIdGroup,
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
      final group = await _findGroupRecord(idGroup);
      final realIdGroup = group?['id_group']?.toString() ?? idGroup;

      final tasksQuery = await Database.query('''
        SELECT gt.*, u.name AS pic_name
        FROM group_task gt
        LEFT JOIN users u ON gt.id_assigned_to = u.id_user
        WHERE gt.id_group = @idGroup
        ORDER BY gt.deadline ASC
      ''', {'idGroup': realIdGroup});

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
      final group = await _findGroupRecord(idGroup);
      final realIdGroup = group?['id_group']?.toString() ?? idGroup;

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

      final idGroupTask = _uuid.v4();
      final sql = '''
        INSERT INTO group_task (id_group_task, id_group, id_assigned_to, task_title, description, deadline, grade_weight, priority, is_completed, created_at, updated_at)
        VALUES (@idGroupTask, @idGroup, @assignedTo, @title, @desc, @deadline::timestamptz, @weight, @priority, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      ''';

      await Database.query(sql, {
        'idGroupTask': idGroupTask,
        'idGroup': realIdGroup,
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
            'id_group': realIdGroup,
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
