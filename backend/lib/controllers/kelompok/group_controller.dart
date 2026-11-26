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
      final idLeader = groupRow['id_leader']?.toString();

      // 2. Cek apakah user adalah leader grup atau sudah terdaftar di group_member
      if (idLeader != null && idLeader == idUser) {
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

      // 4. Sinkronkan group_size (jumlah anggota aktual) jika kolom tersedia
      try {
        await Database.query(
          '''
          UPDATE "groups" g
          SET group_size = GREATEST(
            COALESCE((
              SELECT COUNT(*)::INT
              FROM group_member gm
              WHERE gm.id_group::text = g.id_group::text
            ), 0),
            1
          )
          WHERE g.id_group::text = @idGroup
          ''',
          {'idGroup': idGroup},
        );
      } catch (_) {}

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

    // Fallback: cari berdasarkan name / email jika uid adalah nama atau email
    final nameQueries = [
      'SELECT id_user, name, email FROM users WHERE LOWER(name) = LOWER(@uid) LIMIT 1',
      'SELECT id_user, name, email FROM users WHERE LOWER(email) = LOWER(@uid) LIMIT 1',
      'SELECT id_user, name, email FROM users WHERE name ILIKE @likeUid LIMIT 1',
      'SELECT id_user, name, email FROM users WHERE email ILIKE @likeUid LIMIT 1',
    ];
    for (final q in nameQueries) {
      try {
        final res = await Database.query(q, {'uid': uid, 'likeUid': '%$uid%'});
        if (res.rows.isNotEmpty) {
          return res.rows.first.assoc();
        }
      } catch (_) {}
    }

    return null;
  }

  // Helper resolusi penanggung jawab (assignee) task kelompok secara robust
  static Future<String?> _resolveAssignedUser(String? input, {String? idGroup}) async {
    if (input == null) return null;
    final trimmed = input.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'unassigned') return null;

    // 1. Jika multi assignee (dipisah koma), ambil token pertama (PIC utama)
    final candidate = trimmed.contains(',') ? trimmed.split(',').first.trim() : trimmed;
    if (candidate.isEmpty || candidate.toLowerCase() == 'unassigned') return null;

    // 2. Bersihkan prefix umum jika ada (misal: "member_", "leader_", "mem_", "user_")
    String cleanId = candidate;
    for (final prefix in ['member_', 'leader_', 'mem_', 'user_']) {
      if (cleanId.toLowerCase().startsWith(prefix)) {
        cleanId = cleanId.substring(prefix.length).trim();
        break;
      }
    }

    // 3. Cari user via ID langsung atau nama
    final byId = await _findUserById(cleanId.isNotEmpty ? cleanId : candidate);
    if (byId != null && byId['id_user'] != null) {
      return byId['id_user']?.toString();
    }

    // 4. Periksa apakah candidate adalah id_member di tabel group_member
    try {
      final gm = await Database.query(
        'SELECT id_user FROM group_member WHERE id_member::text = @mid LIMIT 1',
        {'mid': candidate},
      );
      if (gm.rows.isNotEmpty) {
        final uid = gm.rows.first['id_user']?.toString();
        if (uid != null && uid.isNotEmpty) return uid;
      }
    } catch (_) {}

    // 5. Jika idGroup tersedia, cari anggota grup yang namanya cocok
    if (idGroup != null && idGroup.isNotEmpty) {
      try {
        final gmUsers = await Database.query('''
          SELECT u.id_user, u.name, u.email
          FROM group_member gm
          JOIN users u ON gm.id_user::text = u.id_user::text
          WHERE gm.id_group::text = @gid
        ''', {'gid': idGroup});
        for (final row in gmUsers.rows) {
          final uName = row['name']?.toString().toLowerCase() ?? '';
          final candLower = candidate.toLowerCase();
          if (uName.isNotEmpty && (uName == candLower || uName.contains(candLower) || candLower.contains(uName))) {
            return row['id_user']?.toString();
          }
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

      // Ambil milestone kelompok
      QueryResult milestonesQuery;
      try {
        milestonesQuery = await Database.query('''
          SELECT * FROM group_milestone
          WHERE id_group::text = @idGroup
          ORDER BY deadline ASC
        ''', {'idGroup': realIdGroup});
      } catch (_) {
        milestonesQuery = await Database.query('SELECT 1 WHERE 1=0');
      }

      final List<Map<String, dynamic>> milestoneList = [];
      for (final mRow in milestonesQuery.rows) {
        final idMilestone = mRow['id_milestone']?.toString();
        List<String> taskIds = [];
        if (idMilestone != null && idMilestone.isNotEmpty) {
          try {
            final tRes = await Database.query(
              'SELECT id_group_task FROM group_task WHERE id_milestone::text = @idMilestone',
              {'idMilestone': idMilestone},
            );
            taskIds = tRes.rows.map((r) => r['id_group_task']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
          } catch (_) {}
        }
        final rowData = Map<String, dynamic>.from(mRow.assoc());
        rowData['task_ids'] = taskIds;
        milestoneList.add(_serializeRow(rowData));
      }

      return Response.ok(
        jsonEncode(_toJsonSafe({
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
            'milestones': milestoneList,
          },
        })),
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
        WHERE id_group::text = @idGroup OR id_group::text = @rawId
        ORDER BY start_time ASC
      ''', {'idGroup': realIdGroup, 'rawId': idGroup});

      return Response.ok(
        jsonEncode(_toJsonSafe({
          'status': 'success',
          'count': results.rows.length,
          'data': results.rows.map((r) => r.assoc()).toList(),
        })),
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

      final frontendMeetingId = (body['id_meeting'] ?? body['id'])?.toString().trim();
      final idMeeting = (frontendMeetingId != null && frontendMeetingId.isNotEmpty) ? frontendMeetingId : _uuid.v4();

      final existingMeeting = await Database.query(
        'SELECT id_meeting FROM meeting_schedule WHERE id_meeting::text = @id LIMIT 1',
        {'id': idMeeting},
      );

      if (existingMeeting.rows.isNotEmpty) {
        await Database.query('''
          UPDATE meeting_schedule
          SET id_group = @idGroup,
              meeting_title = @title,
              description = @description,
              start_time = @startTime::timestamp,
              platform_location = @location
          WHERE id_meeting::text = @idMeeting
        ''', {
          'idMeeting': idMeeting,
          'idGroup': realIdGroup,
          'title': title,
          'description': description,
          'startTime': startTime,
          'location': platformLocation,
        });
      } else {
        await Database.query('''
          INSERT INTO meeting_schedule (id_meeting, id_group, meeting_title, description, start_time, platform_location, created_at)
          VALUES (@idMeeting, @idGroup, @title, @description, @startTime::timestamp, @location, CURRENT_TIMESTAMP)
        ''', {
          'idMeeting': idMeeting,
          'idGroup': realIdGroup,
          'title': title,
          'description': description,
          'startTime': startTime,
          'location': platformLocation,
        });
      }

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

  // PUT /api/groups/<idGroup>/meetings/<idMeeting>
  static Future<Response> updateMeeting(Request req, String idGroup, String idMeeting) async {
    try {
      final group = await _findGroupRecord(idGroup);
      final realIdGroup = group?['id_group']?.toString() ?? idGroup;

      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final title = (body['meeting_title'] ?? body['title'])?.toString().trim();
      final description = body['description']?.toString();
      final startTime = body['start_time']?.toString() ?? body['date']?.toString();
      final platformLocation = (body['platform_location'] ?? body['location'])?.toString().trim();

      final updates = <String>[];
      final params = <String, dynamic>{
        'idMeeting': idMeeting,
        'idGroup': realIdGroup,
      };

      if (title != null && title.isNotEmpty) {
        updates.add('meeting_title = @title');
        params['title'] = title;
      }
      if (description != null) {
        updates.add('description = @desc');
        params['desc'] = description;
      }
      if (startTime != null && startTime.isNotEmpty) {
        updates.add('start_time = @startTime::timestamp');
        params['startTime'] = startTime;
      }
      if (platformLocation != null && platformLocation.isNotEmpty) {
        updates.add('platform_location = @loc');
        params['loc'] = platformLocation;
      }

      if (updates.isNotEmpty) {
        final sql = '''
          UPDATE meeting_schedule
          SET ${updates.join(', ')}
          WHERE id_meeting::text = @idMeeting AND (id_group::text = @idGroup OR id_group::text = @rawGroup)
        ''';
        params['rawGroup'] = idGroup;
        await Database.query(sql, params);
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Meeting updated successfully',
          'data': {'id_meeting': idMeeting},
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] updateMeeting error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // DELETE /api/groups/<idGroup>/meetings/<idMeeting>
  static Future<Response> deleteMeeting(Request req, String idGroup, String idMeeting) async {
    try {
      final group = await _findGroupRecord(idGroup);
      final realIdGroup = group?['id_group']?.toString() ?? idGroup;

      await Database.query('''
        DELETE FROM meeting_schedule
        WHERE id_meeting::text = @idMeeting AND (id_group::text = @idGroup OR id_group::text = @rawGroup)
      ''', {
        'idMeeting': idMeeting,
        'idGroup': realIdGroup,
        'rawGroup': idGroup,
      });

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Meeting deleted successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] deleteMeeting error: $e\n$stack');
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
        LEFT JOIN users u ON gt.id_assigned_to::text = u.id_user::text
        WHERE gt.id_group::text = @idGroup OR gt.id_group::text = @rawId
        ORDER BY gt.deadline ASC
      ''', {'idGroup': realIdGroup, 'rawId': idGroup});

      return Response.ok(
        jsonEncode(_toJsonSafe({
          'status': 'success',
          'count': tasksQuery.rows.length,
          'data': tasksQuery.rows.map((r) => r.assoc()).toList(),
        })),
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
      
      // Sanitasi batasan VARCHAR(6) pada kolom priority
      var priority = (body['priority']?.toString() ?? 'MEDIUM').toUpperCase().trim();
      if (priority.length > 6) {
        if (priority.contains('HIGH')) {
          priority = 'HIGH';
        } else if (priority.contains('LOW')) {
          priority = 'LOW';
        } else {
          priority = 'MEDIUM';
        }
      }

      final assignedTo = (body['id_assigned_to'] ?? body['assigned_to'])?.toString();
      final idMilestone = (body['id_milestone'] ?? body['milestone_id'])?.toString();
      final frontendTaskId = (body['id_group_task'] ?? body['id'])?.toString().trim() ?? '';
      final idGroupTask = frontendTaskId.isNotEmpty ? frontendTaskId : _uuid.v4();

      if (taskTitle == null || taskTitle.isEmpty) {
        return Response(400,
            body: jsonEncode({'status': 'error', 'message': 'Task title is required'}),
            headers: {'Content-Type': 'application/json'});
      }

      // Validasi id_milestone terhadap tabel group_milestone agar tidak memicu foreign key violation (23503)
      String? effectiveMilestoneId;
      if (idMilestone != null && idMilestone.trim().isNotEmpty) {
        final cleanMid = idMilestone.trim();
        final mCheck = await Database.query(
          'SELECT id_milestone FROM group_milestone WHERE id_milestone::text = @mid LIMIT 1',
          {'mid': cleanMid},
        );
        if (mCheck.rows.isNotEmpty) {
          effectiveMilestoneId = cleanMid;
        } else {
          // Cari jika milestone tersimpan di grup yang sama berdasarkan title atau id
          final mGroupCheck = await Database.query(
            'SELECT id_milestone FROM group_milestone WHERE id_group::text = @gid AND (id_milestone::text = @mid OR title::text = @mid) LIMIT 1',
            {'gid': realIdGroup, 'mid': cleanMid},
          );
          if (mGroupCheck.rows.isNotEmpty) {
            effectiveMilestoneId = mGroupCheck.rows.first['id_milestone']?.toString();
          }
        }
      }

      // Validasi assignedTo (toleran terhadap id_assigned_to, assigned_to string nama/email, atau ID member)
      final effectiveAssignedTo = await _resolveAssignedUser(assignedTo, idGroup: realIdGroup);

      final isCompleted = (body['is_completed'] == 1 || body['is_completed'] == true || body['is_completed'] == 'true') ? 1 : 0;

      // Cek apakah task sudah ada (check-then-insert/update) untuk menghindari error 42P10
      // karena PostgreSQL tidak memiliki unique constraint pada id_group_task
      final existingTask = await Database.query(
        'SELECT id_group_task FROM group_task WHERE id_group_task::text = @id LIMIT 1',
        {'id': idGroupTask},
      );

      if (existingTask.rows.isNotEmpty) {
        await Database.query('''
          UPDATE group_task
          SET id_group = @idGroup,
              id_assigned_to = @assignedTo,
              task_title = @title,
              description = @desc,
              deadline = @deadline::timestamp,
              grade_weight = @weight,
              priority = @priority,
              id_milestone = @idMilestone,
              is_completed = @isCompleted,
              updated_at = CURRENT_TIMESTAMP
          WHERE id_group_task::text = @idGroupTask
        ''', {
          'idGroupTask': idGroupTask,
          'idGroup': realIdGroup,
          'assignedTo': effectiveAssignedTo,
          'title': taskTitle,
          'desc': description,
          'deadline': deadline,
          'weight': gradeWeight,
          'priority': priority,
          'idMilestone': effectiveMilestoneId,
          'isCompleted': isCompleted,
        });
      } else {
        await Database.query('''
          INSERT INTO group_task (
            id_group_task, id_group, id_assigned_to, task_title, description,
            deadline, grade_weight, priority, id_milestone, is_fuzzy_auto,
            is_completed, created_at, updated_at
          ) VALUES (
            @idGroupTask, @idGroup, @assignedTo, @title, @desc,
            @deadline::timestamp, @weight, @priority, @idMilestone, 0,
            @isCompleted, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
          )
        ''', {
          'idGroupTask': idGroupTask,
          'idGroup': realIdGroup,
          'assignedTo': effectiveAssignedTo,
          'title': taskTitle,
          'desc': description,
          'deadline': deadline,
          'weight': gradeWeight,
          'priority': priority,
          'idMilestone': effectiveMilestoneId,
          'isCompleted': isCompleted,
        });
      }

      if (body['tags'] is List) {
        try {
          await Database.query(
            'UPDATE group_task SET tags = @tags::jsonb WHERE id_group_task::text = @idGroupTask',
            {'tags': jsonEncode(body['tags']), 'idGroupTask': idGroupTask},
          );
        } catch (_) {}
      }

      return Response(201,
        body: jsonEncode({
          'status': 'success',
          'message': 'Group task created successfully',
          'data': {
            'id_group_task': idGroupTask,
            'id_group': realIdGroup,
            'id_assigned_to': effectiveAssignedTo,
            'task_title': taskTitle,
            'deadline': deadline,
            'grade_weight': gradeWeight,
            'priority': priority,
            'id_milestone': effectiveMilestoneId,
            'is_completed': isCompleted,
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

  // PUT /api/groups/<idGroup>/tasks/<idTask>
  static Future<Response> updateGroupTask(Request req, String idGroup, String idTask) async {
    try {
      final group = await _findGroupRecord(idGroup);
      final realIdGroup = group?['id_group']?.toString() ?? idGroup;

      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final taskTitle = (body['task_title'] ?? body['title'])?.toString().trim();
      final description = body['description']?.toString();
      final deadline = body['deadline']?.toString();
      final gradeWeight = (body['grade_weight'] as num?)?.toDouble();

      String? priority;
      if (body['priority'] != null) {
        priority = body['priority'].toString().toUpperCase().trim();
        if (priority.length > 6) {
          if (priority.contains('HIGH')) {
            priority = 'HIGH';
          } else if (priority.contains('LOW')) {
            priority = 'LOW';
          } else {
            priority = 'MEDIUM';
          }
        }
      }

      final assignedTo = (body['id_assigned_to'] ?? body['assigned_to'])?.toString();
      final idMilestone = (body['id_milestone'] ?? body['milestone_id'])?.toString();
      final isCompleted = body['is_completed'] != null
          ? ((body['is_completed'] == 1 || body['is_completed'] == true || body['is_completed'] == 'true') ? 1 : 0)
          : null;

      String? effectiveMilestoneId;
      if (idMilestone != null && idMilestone.trim().isNotEmpty) {
        final cleanMid = idMilestone.trim();
        final mCheck = await Database.query(
          'SELECT id_milestone FROM group_milestone WHERE id_milestone::text = @mid LIMIT 1',
          {'mid': cleanMid},
        );
        if (mCheck.rows.isNotEmpty) {
          effectiveMilestoneId = cleanMid;
        }
      }

      final effectiveAssignedTo = await _resolveAssignedUser(assignedTo, idGroup: realIdGroup);

      final updates = <String>[];
      final params = <String, dynamic>{
        'idTask': idTask,
        'idGroup': realIdGroup,
      };

      if (taskTitle != null && taskTitle.isNotEmpty) {
        updates.add('task_title = @title');
        params['title'] = taskTitle;
      }
      if (description != null) {
        updates.add('description = @desc');
        params['desc'] = description;
      }
      if (deadline != null && deadline.isNotEmpty) {
        updates.add('deadline = @deadline::timestamp');
        params['deadline'] = deadline;
      }
      if (gradeWeight != null) {
        updates.add('grade_weight = @weight');
        params['weight'] = gradeWeight;
      }
      if (priority != null) {
        updates.add('priority = @priority');
        params['priority'] = priority;
      }
      if (body.containsKey('id_milestone') || body.containsKey('milestone_id')) {
        updates.add('id_milestone = @idMilestone');
        params['idMilestone'] = effectiveMilestoneId;
      }
      if (body.containsKey('id_assigned_to') || body.containsKey('assigned_to')) {
        updates.add('id_assigned_to = @assignedTo');
        params['assignedTo'] = effectiveAssignedTo;
      }
      if (isCompleted != null) {
        updates.add('is_completed = @isCompleted');
        params['isCompleted'] = isCompleted;
      }

      updates.add('updated_at = CURRENT_TIMESTAMP');

      if (updates.isNotEmpty) {
        final sql = '''
          UPDATE group_task
          SET ${updates.join(', ')}
          WHERE id_group_task::text = @idTask
        ''';
        try {
          await Database.query(sql, params);
        } catch (e) {
          if (isCompleted != null &&
              (e.toString().contains('boolean') || e.toString().contains('42804'))) {
            params['isCompleted'] = isCompleted == 1;
            await Database.query(sql, params);
          } else {
            rethrow;
          }
        }
      }

      if (body['tags'] is List) {
        try {
          await Database.query(
            'UPDATE group_task SET tags = @tags::jsonb WHERE id_group_task::text = @idTask',
            {'tags': jsonEncode(body['tags']), 'idTask': idTask},
          );
        } catch (_) {}
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Group task updated successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] updateGroupTask error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // DELETE /api/groups/<idGroup>/tasks/<idTask>
  static Future<Response> deleteGroupTask(Request req, String idGroup, String idTask) async {
    try {
      await Database.query(
        'DELETE FROM group_task WHERE id_group_task::text = @idTask',
        {'idTask': idTask},
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Group task deleted successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] deleteGroupTask error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // PATCH /api/groups/<idGroup>/tasks/<idTask>/toggle
  static Future<Response> toggleGroupTask(Request req, String idGroup, String idTask) async {
    try {
      try {
        await Database.query('''
          UPDATE group_task
          SET is_completed = CASE WHEN is_completed = 1 THEN 0 ELSE 1 END,
              updated_at = CURRENT_TIMESTAMP
          WHERE id_group_task::text = @idTask
        ''', {'idTask': idTask});
      } catch (e) {
        if (e.toString().contains('boolean') || e.toString().contains('42804')) {
          await Database.query('''
            UPDATE group_task
            SET is_completed = NOT COALESCE(is_completed, FALSE),
                updated_at = CURRENT_TIMESTAMP
            WHERE id_group_task::text = @idTask
          ''', {'idTask': idTask});
        } else {
          rethrow;
        }
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Group task completion toggled successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] toggleGroupTask error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // ─── 7. MILESTONE KELOMPOK (GROUP MILESTONES) ──────────────────────────────
  // GET /api/groups/<idGroup>/milestones
  static Future<Response> getGroupMilestones(Request req, String idGroup) async {
    try {
      final group = await _findGroupRecord(idGroup);
      final realIdGroup = group?['id_group']?.toString() ?? idGroup;

      QueryResult results;
      try {
        results = await Database.query('''
          SELECT * FROM group_milestone
          WHERE id_group::text = @idGroup
          ORDER BY deadline ASC
        ''', {'idGroup': realIdGroup});
      } catch (_) {
        results = await Database.query('SELECT 1 WHERE 1=0');
      }

      final List<Map<String, dynamic>> milestoneList = [];
      for (final mRow in results.rows) {
        final idMilestone = mRow['id_milestone']?.toString();
        List<String> taskIds = [];
        if (idMilestone != null && idMilestone.isNotEmpty) {
          try {
            final tRes = await Database.query(
              'SELECT id_group_task FROM group_task WHERE id_milestone::text = @idMilestone',
              {'idMilestone': idMilestone},
            );
            taskIds = tRes.rows.map((r) => r['id_group_task']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
          } catch (_) {}
        }
        final rowData = Map<String, dynamic>.from(mRow.assoc());
        rowData['task_ids'] = taskIds;
        milestoneList.add(_serializeRow(rowData));
      }

      return Response.ok(
        jsonEncode(_toJsonSafe({
          'status': 'success',
          'count': milestoneList.length,
          'data': milestoneList,
        })),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] getGroupMilestones error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // POST /api/groups/<idGroup>/milestones
  static Future<Response> createGroupMilestone(Request req, String idGroup) async {
    try {
      final group = await _findGroupRecord(idGroup);
      final realIdGroup = group?['id_group']?.toString() ?? idGroup;

      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final title = (body['title'] ?? body['milestone_title'])?.toString().trim();
      final description = body['description']?.toString();
      final deadline = body['deadline']?.toString() ?? DateTime.now().add(const Duration(days: 7)).toIso8601String();
      final taskIds = (body['task_ids'] ?? body['taskIds']) as List<dynamic>?;

      if (title == null || title.isEmpty) {
        return Response(400,
            body: jsonEncode({'status': 'error', 'message': 'Milestone title is required'}),
            headers: {'Content-Type': 'application/json'});
      }

      final idMilestone = (body['id'] ?? body['id_milestone'])?.toString() ?? _uuid.v4();
      final existingMilestone = await Database.query(
        'SELECT id_milestone FROM group_milestone WHERE id_milestone::text = @idMilestone LIMIT 1',
        {'idMilestone': idMilestone},
      );

      if (existingMilestone.rows.isNotEmpty) {
        await Database.query(
          '''
          UPDATE group_milestone
          SET title = @title,
              description = @description,
              deadline = @deadline::timestamptz
          WHERE id_milestone::text = @idMilestone
          ''',
          {
            'idMilestone': idMilestone,
            'title': title,
            'description': description,
            'deadline': deadline,
          },
        );
      } else {
        await Database.query(
          '''
          INSERT INTO group_milestone (id_milestone, id_group, title, description, deadline, created_at)
          VALUES (@idMilestone, @idGroup, @title, @description, @deadline::timestamptz, CURRENT_TIMESTAMP)
          ''',
          {
            'idMilestone': idMilestone,
            'idGroup': realIdGroup,
            'title': title,
            'description': description,
            'deadline': deadline,
          },
        );
      }

      // Update task associations if taskIds provided
      if (taskIds != null && taskIds.isNotEmpty) {
        for (final tid in taskIds) {
          try {
            await Database.query(
              'UPDATE group_task SET id_milestone = @idMilestone WHERE id_group_task::text = @tid',
              {'idMilestone': idMilestone, 'tid': tid.toString()},
            );
          } catch (_) {}
        }
      }

      return Response(201,
        body: jsonEncode(_toJsonSafe({
          'status': 'success',
          'message': 'Milestone created successfully',
          'data': {
            'id_milestone': idMilestone,
            'id': idMilestone,
            'id_group': realIdGroup,
            'title': title,
            'description': description,
            'deadline': deadline,
            'task_ids': taskIds?.map((e) => e.toString()).toList() ?? [],
          },
        })),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] createGroupMilestone error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // PUT /api/groups/<idGroup>/milestones/<idMilestone>
  static Future<Response> updateGroupMilestone(Request req, String idGroup, String idMilestone) async {
    try {
      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final title = (body['title'] ?? body['milestone_title'])?.toString().trim();
      final description = body['description']?.toString();
      final deadline = body['deadline']?.toString();
      final taskIds = (body['task_ids'] ?? body['taskIds']) as List<dynamic>?;

      final updates = <String>[];
      final params = <String, dynamic>{'idMilestone': idMilestone};

      if (title != null && title.isNotEmpty) {
        updates.add('title = @title');
        params['title'] = title;
      }
      if (description != null) {
        updates.add('description = @description');
        params['description'] = description;
      }
      if (deadline != null && deadline.isNotEmpty) {
        updates.add('deadline = @deadline::timestamptz');
        params['deadline'] = deadline;
      }

      if (updates.isNotEmpty) {
        final sql = 'UPDATE group_milestone SET ${updates.join(', ')} WHERE id_milestone::text = @idMilestone';
        await Database.query(sql, params);
      }

      if (taskIds != null) {
        try {
          await Database.query(
            'UPDATE group_task SET id_milestone = NULL WHERE id_milestone::text = @idMilestone',
            {'idMilestone': idMilestone},
          );
          for (final tid in taskIds) {
            await Database.query(
              'UPDATE group_task SET id_milestone = @idMilestone WHERE id_group_task::text = @tid',
              {'idMilestone': idMilestone, 'tid': tid.toString()},
            );
          }
        } catch (_) {}
      }

      return Response.ok(
        jsonEncode(_toJsonSafe({
          'status': 'success',
          'message': 'Milestone updated successfully',
        })),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] updateGroupMilestone error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // DELETE /api/groups/<idGroup>/milestones/<idMilestone>
  static Future<Response> deleteGroupMilestone(Request req, String idGroup, String idMilestone) async {
    try {
      try {
        await Database.query(
          'UPDATE group_task SET id_milestone = NULL WHERE id_milestone::text = @idMilestone',
          {'idMilestone': idMilestone},
        );
      } catch (_) {}

      await Database.query(
        'DELETE FROM group_milestone WHERE id_milestone::text = @idMilestone',
        {'idMilestone': idMilestone},
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Milestone deleted successfully',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('[GROUPS] deleteGroupMilestone error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
