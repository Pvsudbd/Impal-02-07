import 'dart:convert';
import 'dart:math' as math;
import 'package:uuid/uuid.dart';
import '../../config/db.dart';
import '../../services/fuzzy_mamdani_service.dart';

class GroupNotFoundException implements Exception {
  final String message;
  GroupNotFoundException([this.message = 'Kelompok atau item tidak ditemukan.']);
  @override
  String toString() => message;
}

class GroupForbiddenException implements Exception {
  final String message;
  GroupForbiddenException([
    this.message = 'Anda tidak memiliki izin untuk melakukan aksi ini.',
  ]);
  @override
  String toString() => message;
}

class GroupConflictException implements Exception {
  final String message;
  GroupConflictException([this.message = 'Terjadi konflik data kelompok.']);
  @override
  String toString() => message;
}

class GroupBadRequestException implements Exception {
  final String message;
  GroupBadRequestException([this.message = 'Data kelompok tidak valid.']);
  @override
  String toString() => message;
}

class GroupRepository {
  static const _uuid = Uuid();
  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is DateTime) return val;
    return DateTime.tryParse(val.toString()) ?? DateTime.now();
  }

  static String? _parseIso(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val.toIso8601String();
    return DateTime.tryParse(val.toString())?.toIso8601String() ??
        val.toString();
  }

  static int _toInt(dynamic val) => int.tryParse(val?.toString() ?? '0') ?? 0;

  static double _toDouble(dynamic val) =>
      double.tryParse(val?.toString() ?? '0') ?? 0.0;

  static bool _toBool(dynamic val) => val == 1 || val == true;

  static List<String> _parseTags(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (_) {}
    }
    return [];
  }

  static String _generateCode([int length = 6]) {
    final rng = math.Random.secure();
    return List.generate(
      length,
      (_) => _codeChars[rng.nextInt(_codeChars.length)],
    ).join();
  }

  static Future<String> _requireMembership(
    String idGroup,
    String idUser, {
    DbTransaction? tx,
  }) async {
    Future<QueryResult> run(String sql, Map<String, dynamic> params) =>
        tx != null ? tx.query(sql, params) : Database.query(sql, params);

    final groupRes = await run(
      'SELECT id_group FROM "groups" WHERE id_group = :idGroup LIMIT 1',
      {'idGroup': idGroup},
    );
    if (groupRes.rows.isEmpty) {
      throw GroupNotFoundException('Kelompok tidak ditemukan.');
    }

    final memberRes = await run(
      'SELECT role FROM group_member WHERE id_group = :idGroup AND id_user = :idUser LIMIT 1',
      {'idGroup': idGroup, 'idUser': idUser},
    );
    if (memberRes.rows.isEmpty) {
      throw GroupForbiddenException('Anda bukan anggota kelompok ini.');
    }

    return (memberRes.rows.first.assoc()['role']?.toString() ?? 'MEMBER')
        .toUpperCase();
  }

  static Future<void> _ensureMemberInGroup(
    DbTransaction tx,
    String idGroup,
    String idUser,
  ) async {
    final res = await tx.query(
      'SELECT id_member FROM group_member WHERE id_group = :idGroup AND id_user = :idUser LIMIT 1',
      {'idGroup': idGroup, 'idUser': idUser},
    );
    if (res.rows.isEmpty) {
      throw GroupBadRequestException(
        'Pengguna yang ditugaskan bukan anggota kelompok ini.',
      );
    }
  }

  static Future<void> _ensureMilestoneInGroup(
    DbTransaction tx,
    String idGroup,
    String idMilestone,
  ) async {
    final res = await tx.query(
      'SELECT id_milestone FROM group_milestone WHERE id_milestone = :idMilestone AND id_group = :idGroup LIMIT 1',
      {'idMilestone': idMilestone, 'idGroup': idGroup},
    );
    if (res.rows.isEmpty) {
      throw GroupBadRequestException(
        'Milestone tidak ditemukan pada kelompok ini.',
      );
    }
  }

  // ─── 1. GROUPS & MEMBERS ──────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> listForUser(
    String idUser, {
    String? query,
  }) async {
    final params = <String, dynamic>{'idUser': idUser};
    var searchClause = '';
    if (query != null && query.trim().isNotEmpty) {
      searchClause =
          'AND (LOWER(g.group_name) LIKE LOWER(:q) OR LOWER(COALESCE(g.description, \'\')) LIKE LOWER(:q))';
      params['q'] = '%${query.trim()}%';
    }

    final sql = '''
      SELECT
        g.id_group,
        g.id_leader,
        g.group_name,
        g.description,
        g.invite_code,
        g.group_size,
        g.created_at,
        gm.role AS my_role,
        (SELECT COUNT(*) FROM group_member gm2 WHERE gm2.id_group = g.id_group) AS member_count,
        (SELECT COUNT(*) FROM group_task gt WHERE gt.id_group = g.id_group AND gt.is_completed = 0) AS active_tasks_count,
        (SELECT COUNT(*) FROM meeting_schedule ms WHERE ms.id_group = g.id_group AND ms.start_time >= NOW()) AS upcoming_meetings_count
      FROM "groups" g
      JOIN group_member gm ON g.id_group = gm.id_group
      WHERE gm.id_user = :idUser $searchClause
      ORDER BY g.created_at DESC
    ''';

    final res = await Database.query(sql, params);
    return res.rows.map((r) {
      final row = r.assoc();
      return {
        'idGroup': row['id_group']?.toString() ?? '',
        'idLeader': row['id_leader']?.toString() ?? '',
        'groupName': row['group_name']?.toString() ?? '',
        'description': row['description']?.toString() ?? '',
        'inviteCode': row['invite_code']?.toString() ?? '',
        'groupSize': _toInt(row['group_size']),
        'memberCount': _toInt(row['member_count']),
        'myRole': (row['my_role']?.toString() ?? 'MEMBER').toUpperCase(),
        'activeTasksCount': _toInt(row['active_tasks_count']),
        'upcomingMeetingsCount': _toInt(row['upcoming_meetings_count']),
        'createdAt': _parseIso(row['created_at']),
      };
    }).toList();
  }

  static Future<Map<String, dynamic>> getDetail(
    String idGroup,
    String idUser,
  ) async {
    final role = await _requireMembership(idGroup, idUser);

    final groupRes = await Database.query(
      '''
      SELECT id_group, id_leader, group_name, description, invite_code, group_size, created_at
      FROM "groups"
      WHERE id_group = :idGroup
      LIMIT 1
      ''',
      {'idGroup': idGroup},
    );
    if (groupRes.rows.isEmpty) {
      throw GroupNotFoundException('Kelompok tidak ditemukan.');
    }
    final g = groupRes.rows.first.assoc();

    final membersRes = await Database.query(
      '''
      SELECT gm.id_member, gm.id_user, gm.role, gm.joined_at, u.name, u.email
      FROM group_member gm
      LEFT JOIN users u ON gm.id_user = u.id_user
      WHERE gm.id_group = :idGroup
      ORDER BY CASE UPPER(gm.role) WHEN 'LEADER' THEN 0 ELSE 1 END, gm.joined_at ASC
      ''',
      {'idGroup': idGroup},
    );

    final members = membersRes.rows.map((r) {
      final m = r.assoc();
      return {
        'idMember': m['id_member']?.toString() ?? '',
        'idUser': m['id_user']?.toString() ?? '',
        'name': m['name']?.toString() ?? '',
        'email': m['email']?.toString() ?? '',
        'role': (m['role']?.toString() ?? 'MEMBER').toUpperCase(),
        'joinedAt': _parseIso(m['joined_at']),
      };
    }).toList();

    return {
      'idGroup': g['id_group']?.toString() ?? '',
      'idLeader': g['id_leader']?.toString() ?? '',
      'groupName': g['group_name']?.toString() ?? '',
      'description': g['description']?.toString() ?? '',
      'inviteCode': g['invite_code']?.toString() ?? '',
      'groupSize': _toInt(g['group_size']),
      'myRole': role,
      'createdAt': _parseIso(g['created_at']),
      'members': members,
    };
  }

  static Future<Map<String, dynamic>> createGroup({
    required String idLeader,
    required String groupName,
    String description = '',
  }) async {
    final idGroup = _uuid.v4();
    final idMember = _uuid.v4();

    await Database.transaction((tx) async {
      var inviteCode = _generateCode(6);
      for (var attempt = 0; attempt < 5; attempt++) {
        final dup = await tx.query(
          'SELECT id_group FROM "groups" WHERE invite_code = :code LIMIT 1',
          {'code': inviteCode},
        );
        if (dup.rows.isEmpty) break;
        inviteCode = _generateCode(7);
      }

      await tx.query(
        '''
        INSERT INTO "groups" (id_group, id_leader, group_name, description, invite_code, created_at, group_size)
        VALUES (:idGroup, :idLeader, :groupName, :description, :inviteCode, NOW(), 1)
        ''',
        {
          'idGroup': idGroup,
          'idLeader': idLeader,
          'groupName': groupName.trim(),
          'description': description.trim(),
          'inviteCode': inviteCode,
        },
      );

      await tx.query(
        '''
        INSERT INTO group_member (id_member, id_group, id_user, role, joined_at)
        VALUES (:idMember, :idGroup, :idUser, 'LEADER', NOW())
        ''',
        {
          'idMember': idMember,
          'idGroup': idGroup,
          'idUser': idLeader,
        },
      );
    });

    return getDetail(idGroup, idLeader);
  }

  static Future<Map<String, dynamic>> updateGroup({
    required String idGroup,
    required String idUser,
    String? groupName,
    String? description,
  }) async {
    final role = await _requireMembership(idGroup, idUser);
    if (role != 'LEADER') {
      throw GroupForbiddenException(
        'Hanya ketua kelompok (LEADER) yang dapat mengubah info kelompok.',
      );
    }

    final updates = <String>[];
    final params = <String, dynamic>{'idGroup': idGroup};
    if (groupName != null) {
      updates.add('group_name = :groupName');
      params['groupName'] = groupName.trim();
    }
    if (description != null) {
      updates.add('description = :description');
      params['description'] = description.trim();
    }

    if (updates.isNotEmpty) {
      await Database.query(
        'UPDATE "groups" SET ${updates.join(', ')} WHERE id_group = :idGroup',
        params,
      );
    }

    return getDetail(idGroup, idUser);
  }

  static Future<Map<String, dynamic>> joinByInviteCode({
    required String idUser,
    required String inviteCode,
  }) async {
    final normalizedCode = inviteCode.trim().toUpperCase();
    late String idGroup;

    await Database.transaction((tx) async {
      final groupRes = await tx.query(
        'SELECT id_group FROM "groups" WHERE UPPER(invite_code) = :code LIMIT 1',
        {'code': normalizedCode},
      );
      if (groupRes.rows.isEmpty) {
        throw GroupNotFoundException('Kode undangan kelompok tidak ditemukan.');
      }
      idGroup = groupRes.rows.first.assoc()['id_group'].toString();

      final existingMember = await tx.query(
        'SELECT id_member FROM group_member WHERE id_group = :idGroup AND id_user = :idUser LIMIT 1',
        {'idGroup': idGroup, 'idUser': idUser},
      );
      if (existingMember.rows.isNotEmpty) {
        throw GroupConflictException(
          'Anda sudah terdaftar sebagai anggota kelompok ini.',
        );
      }

      await tx.query(
        '''
        INSERT INTO group_member (id_member, id_group, id_user, role, joined_at)
        VALUES (:idMember, :idGroup, :idUser, 'MEMBER', NOW())
        ''',
        {
          'idMember': _uuid.v4(),
          'idGroup': idGroup,
          'idUser': idUser,
        },
      );

      await tx.query(
        '''
        UPDATE "groups"
        SET group_size = (SELECT COUNT(*) FROM group_member WHERE id_group = :idGroup)
        WHERE id_group = :idGroup
        ''',
        {'idGroup': idGroup},
      );
    });

    return getDetail(idGroup, idUser);
  }

  static Future<void> leaveGroup({
    required String idGroup,
    required String idUser,
  }) async {
    await Database.transaction((tx) async {
      final role = await _requireMembership(idGroup, idUser, tx: tx);

      final countRes = await tx.query(
        'SELECT COUNT(*) FROM group_member WHERE id_group = :idGroup',
        {'idGroup': idGroup},
      );
      final totalMembers =
          countRes.rows.isNotEmpty ? _toInt(countRes.rows.first.colAt(0)) : 0;

      if (role == 'LEADER' && totalMembers > 1) {
        throw GroupConflictException(
          'Ketua kelompok tidak dapat keluar selagi masih ada anggota lain. Bubarkan kelompok atau hapus anggota terlebih dahulu.',
        );
      }

      if (totalMembers <= 1) {
        await _disbandGroupTx(tx, idGroup);
        return;
      }

      await tx.query(
        'DELETE FROM group_member WHERE id_group = :idGroup AND id_user = :idUser',
        {'idGroup': idGroup, 'idUser': idUser},
      );

      await tx.query(
        '''
        UPDATE "groups"
        SET group_size = (SELECT COUNT(*) FROM group_member WHERE id_group = :idGroup)
        WHERE id_group = :idGroup
        ''',
        {'idGroup': idGroup},
      );
    });
  }

  static Future<void> _disbandGroupTx(DbTransaction tx, String idGroup) async {
    // Child-first deletion across all 6 tables (legacy DB lacks ON DELETE CASCADE)
    await tx.query(
      '''
      DELETE FROM group_sub_task
      WHERE id_group_task IN (SELECT id_group_task FROM group_task WHERE id_group = :idGroup)
      ''',
      {'idGroup': idGroup},
    );
    await tx.query(
      'DELETE FROM group_task WHERE id_group = :idGroup',
      {'idGroup': idGroup},
    );
    await tx.query(
      'DELETE FROM group_milestone WHERE id_group = :idGroup',
      {'idGroup': idGroup},
    );
    await tx.query(
      'DELETE FROM meeting_schedule WHERE id_group = :idGroup',
      {'idGroup': idGroup},
    );
    await tx.query(
      'DELETE FROM group_member WHERE id_group = :idGroup',
      {'idGroup': idGroup},
    );
    await tx.query(
      'DELETE FROM "groups" WHERE id_group = :idGroup',
      {'idGroup': idGroup},
    );
  }

  static Future<void> disbandGroup({
    required String idGroup,
    required String idUser,
  }) async {
    await Database.transaction((tx) async {
      final role = await _requireMembership(idGroup, idUser, tx: tx);
      if (role != 'LEADER') {
        throw GroupForbiddenException(
          'Hanya ketua kelompok (LEADER) yang dapat membubarkan kelompok.',
        );
      }
      await _disbandGroupTx(tx, idGroup);
    });
  }

  // ─── 2. MILESTONES (group_milestone) ──────────────────────────────────────

  static Future<List<Map<String, dynamic>>> listMilestones(
    String idGroup,
    String idUser,
  ) async {
    await _requireMembership(idGroup, idUser);

    const sql = '''
      SELECT
        gm.id_milestone,
        gm.id_group,
        gm.title,
        gm.description,
        gm.deadline,
        gm.created_at,
        (SELECT COUNT(*) FROM group_task gt WHERE gt.id_milestone = gm.id_milestone) AS total_tasks,
        (SELECT COUNT(*) FROM group_task gt WHERE gt.id_milestone = gm.id_milestone AND gt.is_completed = 1) AS completed_tasks
      FROM group_milestone gm
      WHERE gm.id_group = :idGroup
      ORDER BY gm.deadline ASC
    ''';

    final res = await Database.query(sql, {'idGroup': idGroup});
    return res.rows.map((r) {
      final row = r.assoc();
      final total = _toInt(row['total_tasks']);
      final completed = _toInt(row['completed_tasks']);
      final progress = total > 0 ? ((completed / total) * 100).round() : 0;
      return {
        'idMilestone': row['id_milestone']?.toString() ?? '',
        'idGroup': row['id_group']?.toString() ?? '',
        'title': row['title']?.toString() ?? '',
        'description': row['description']?.toString() ?? '',
        'deadline': _parseIso(row['deadline']),
        'totalTasks': total,
        'completedTasks': completed,
        'progressPercent': progress,
        'createdAt': _parseIso(row['created_at']),
      };
    }).toList();
  }

  static Future<Map<String, dynamic>> createMilestone({
    required String idGroup,
    required String idUser,
    required String title,
    String description = '',
    required DateTime deadline,
  }) async {
    await _requireMembership(idGroup, idUser);
    final idMilestone = _uuid.v4();

    await Database.query(
      '''
      INSERT INTO group_milestone (id_milestone, id_group, title, description, deadline, created_at)
      VALUES (:idMilestone, :idGroup, :title, :description, :deadline::timestamp, NOW())
      ''',
      {
        'idMilestone': idMilestone,
        'idGroup': idGroup,
        'title': title.trim(),
        'description': description.trim(),
        'deadline': deadline.toIso8601String(),
      },
    );

    final all = await listMilestones(idGroup, idUser);
    return all.firstWhere((m) => m['idMilestone'] == idMilestone);
  }

  static Future<Map<String, dynamic>> updateMilestone({
    required String idGroup,
    required String idMilestone,
    required String idUser,
    String? title,
    String? description,
    DateTime? deadline,
  }) async {
    await _requireMembership(idGroup, idUser);

    final existing = await Database.query(
      'SELECT id_milestone FROM group_milestone WHERE id_milestone = :idMilestone AND id_group = :idGroup LIMIT 1',
      {'idMilestone': idMilestone, 'idGroup': idGroup},
    );
    if (existing.rows.isEmpty) {
      throw GroupNotFoundException('Milestone tidak ditemukan.');
    }

    final updates = <String>[];
    final params = <String, dynamic>{
      'idMilestone': idMilestone,
      'idGroup': idGroup,
    };
    if (title != null) {
      updates.add('title = :title');
      params['title'] = title.trim();
    }
    if (description != null) {
      updates.add('description = :description');
      params['description'] = description.trim();
    }
    if (deadline != null) {
      updates.add('deadline = :deadline::timestamp');
      params['deadline'] = deadline.toIso8601String();
    }

    if (updates.isNotEmpty) {
      await Database.query(
        'UPDATE group_milestone SET ${updates.join(', ')} WHERE id_milestone = :idMilestone AND id_group = :idGroup',
        params,
      );
    }

    final all = await listMilestones(idGroup, idUser);
    return all.firstWhere((m) => m['idMilestone'] == idMilestone);
  }

  static Future<void> deleteMilestone({
    required String idGroup,
    required String idMilestone,
    required String idUser,
  }) async {
    await Database.transaction((tx) async {
      await _requireMembership(idGroup, idUser, tx: tx);

      final existing = await tx.query(
        'SELECT id_milestone FROM group_milestone WHERE id_milestone = :idMilestone AND id_group = :idGroup LIMIT 1',
        {'idMilestone': idMilestone, 'idGroup': idGroup},
      );
      if (existing.rows.isEmpty) {
        throw GroupNotFoundException('Milestone tidak ditemukan.');
      }

      // Detach group_task references first to avoid dangling milestone links
      await tx.query(
        'UPDATE group_task SET id_milestone = NULL WHERE id_milestone = :idMilestone AND id_group = :idGroup',
        {'idMilestone': idMilestone, 'idGroup': idGroup},
      );

      await tx.query(
        'DELETE FROM group_milestone WHERE id_milestone = :idMilestone AND id_group = :idGroup',
        {'idMilestone': idMilestone, 'idGroup': idGroup},
      );
    });
  }

  // ─── 3. GROUP TASKS (group_task) ──────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> listGroupTasks(
    String idGroup,
    String idUser, {
    bool assignedToMe = false,
    String? idMilestone,
    bool? isCompleted,
  }) async {
    await _requireMembership(idGroup, idUser);

    final conditions = <String>['gt.id_group = :idGroup'];
    final params = <String, dynamic>{'idGroup': idGroup};

    if (assignedToMe) {
      conditions.add('gt.id_assigned_to = :idUser');
      params['idUser'] = idUser;
    }
    if (idMilestone != null && idMilestone.trim().isNotEmpty) {
      conditions.add('gt.id_milestone = :idMilestone');
      params['idMilestone'] = idMilestone.trim();
    }
    if (isCompleted != null) {
      conditions.add('gt.is_completed = :isCompleted');
      params['isCompleted'] = isCompleted ? 1 : 0;
    }

    final sql = '''
      SELECT
        gt.id_group_task,
        gt.id_group,
        gt.id_assigned_to,
        u.name AS assigned_name,
        gt.id_milestone,
        gm.title AS milestone_title,
        gt.task_title,
        gt.description,
        gt.deadline,
        gt.grade_weight,
        gt.priority,
        gt.is_fuzzy_auto,
        gt.is_completed,
        gt.tags,
        gt.created_at,
        gt.updated_at,
        (SELECT COUNT(*) FROM group_sub_task gs WHERE gs.id_group_task = gt.id_group_task) AS subtasks_total,
        (SELECT COUNT(*) FROM group_sub_task gs WHERE gs.id_group_task = gt.id_group_task AND gs.is_completed = 1) AS subtasks_completed
      FROM group_task gt
      LEFT JOIN users u ON gt.id_assigned_to = u.id_user
      LEFT JOIN group_milestone gm ON gt.id_milestone = gm.id_milestone
      WHERE ${conditions.join(' AND ')}
      ORDER BY gt.is_completed ASC, gt.deadline ASC
    ''';

    final res = await Database.query(sql, params);
    return res.rows.map((r) {
      final row = r.assoc();
      return {
        'idGroupTask': row['id_group_task']?.toString() ?? '',
        'idGroup': row['id_group']?.toString() ?? '',
        'idAssignedTo': row['id_assigned_to']?.toString(),
        'assignedToName': row['assigned_name']?.toString(),
        'idMilestone': row['id_milestone']?.toString(),
        'milestoneTitle': row['milestone_title']?.toString(),
        'title': row['task_title']?.toString() ?? '',
        'taskTitle': row['task_title']?.toString() ?? '',
        'description': row['description']?.toString() ?? '',
        'deadline': _parseIso(row['deadline']),
        'gradeWeight': _toDouble(row['grade_weight']),
        'priority': row['priority']?.toString() ?? 'MEDIUM',
        'isFuzzyAuto': _toBool(row['is_fuzzy_auto']),
        'isCompleted': _toBool(row['is_completed']),
        'tags': _parseTags(row['tags']),
        'subtasksTotal': _toInt(row['subtasks_total']),
        'subtasksCompleted': _toInt(row['subtasks_completed']),
        'createdAt': _parseIso(row['created_at']),
        'updatedAt': _parseIso(row['updated_at']),
      };
    }).toList();
  }

  static Future<Map<String, dynamic>> getGroupTaskById(
    String idGroup,
    String idGroupTask,
    String idUser,
  ) async {
    await _requireMembership(idGroup, idUser);

    final tasks = await listGroupTasks(idGroup, idUser);
    final match = tasks.where((t) => t['idGroupTask'] == idGroupTask).toList();
    if (match.isEmpty) {
      throw GroupNotFoundException('Tugas kelompok tidak ditemukan.');
    }
    return match.first;
  }

  static Future<Map<String, dynamic>> createGroupTask({
    required String idGroup,
    required String idUser,
    required String taskTitle,
    String description = '',
    required DateTime deadline,
    double gradeWeight = 20.0,
    bool isFuzzyAuto = true,
    String? manualPriority,
    String? idAssignedTo,
    String? idMilestone,
    List<String> tags = const [],
  }) async {
    final idGroupTask = _uuid.v4();
    final finalPriority = isFuzzyAuto
        ? FuzzyMamdaniService.evaluate(
            deadline: deadline,
            gradeWeight: gradeWeight,
          ).level
        : (manualPriority ?? 'MEDIUM').trim().toUpperCase();

    await Database.transaction((tx) async {
      await _requireMembership(idGroup, idUser, tx: tx);

      if (idAssignedTo != null && idAssignedTo.trim().isNotEmpty) {
        await _ensureMemberInGroup(tx, idGroup, idAssignedTo.trim());
      }
      if (idMilestone != null && idMilestone.trim().isNotEmpty) {
        await _ensureMilestoneInGroup(tx, idGroup, idMilestone.trim());
      }

      await tx.query(
        '''
        INSERT INTO group_task (
          id_group_task, id_group, id_assigned_to, id_milestone,
          task_title, description, deadline, grade_weight, priority,
          is_fuzzy_auto, is_completed, tags, created_at, updated_at
        )
        VALUES (
          :idGroupTask, :idGroup, :idAssignedTo, :idMilestone,
          :taskTitle, :description, :deadline::timestamp, :gradeWeight, :priority,
          :isFuzzyAuto, 0, :tags::jsonb, NOW(), NOW()
        )
        ''',
        {
          'idGroupTask': idGroupTask,
          'idGroup': idGroup,
          'idAssignedTo':
              (idAssignedTo != null && idAssignedTo.trim().isNotEmpty)
                  ? idAssignedTo.trim()
                  : null,
          'idMilestone':
              (idMilestone != null && idMilestone.trim().isNotEmpty)
                  ? idMilestone.trim()
                  : null,
          'taskTitle': taskTitle.trim(),
          'description': description.trim(),
          'deadline': deadline.toIso8601String(),
          'gradeWeight': gradeWeight,
          'priority': finalPriority,
          'isFuzzyAuto': isFuzzyAuto ? 1 : 0,
          'tags': jsonEncode(tags),
        },
      );
    });

    return getGroupTaskById(idGroup, idGroupTask, idUser);
  }

  static Future<Map<String, dynamic>> updateGroupTask({
    required String idGroup,
    required String idGroupTask,
    required String idUser,
    String? taskTitle,
    String? description,
    DateTime? deadline,
    double? gradeWeight,
    bool? isFuzzyAuto,
    String? manualPriority,
    String? idAssignedTo,
    bool clearAssignee = false,
    String? idMilestone,
    bool clearMilestone = false,
    bool? isCompleted,
    List<String>? tags,
  }) async {
    await Database.transaction((tx) async {
      await _requireMembership(idGroup, idUser, tx: tx);

      final existingRes = await tx.query(
        '''
        SELECT deadline, grade_weight, is_fuzzy_auto, priority
        FROM group_task
        WHERE id_group_task = :idGroupTask AND id_group = :idGroup
        LIMIT 1
        ''',
        {'idGroupTask': idGroupTask, 'idGroup': idGroup},
      );
      if (existingRes.rows.isEmpty) {
        throw GroupNotFoundException('Tugas kelompok tidak ditemukan.');
      }
      final existing = existingRes.rows.first.assoc();

      final effectiveDeadline = deadline ?? _parseDate(existing['deadline']);
      final effectiveWeight =
          gradeWeight ?? _toDouble(existing['grade_weight']);
      final effectiveFuzzy =
          isFuzzyAuto ?? _toBool(existing['is_fuzzy_auto']);

      String? computedPriority;
      if (effectiveFuzzy) {
        computedPriority = FuzzyMamdaniService.evaluate(
          deadline: effectiveDeadline,
          gradeWeight: effectiveWeight,
        ).level;
      } else if (manualPriority != null) {
        computedPriority = manualPriority.trim().toUpperCase();
      }

      if (!clearAssignee &&
          idAssignedTo != null &&
          idAssignedTo.trim().isNotEmpty) {
        await _ensureMemberInGroup(tx, idGroup, idAssignedTo.trim());
      }
      if (!clearMilestone &&
          idMilestone != null &&
          idMilestone.trim().isNotEmpty) {
        await _ensureMilestoneInGroup(tx, idGroup, idMilestone.trim());
      }

      final updates = <String>[];
      final params = <String, dynamic>{
        'idGroupTask': idGroupTask,
        'idGroup': idGroup,
      };

      if (taskTitle != null) {
        updates.add('task_title = :taskTitle');
        params['taskTitle'] = taskTitle.trim();
      }
      if (description != null) {
        updates.add('description = :description');
        params['description'] = description.trim();
      }
      if (deadline != null) {
        updates.add('deadline = :deadline::timestamp');
        params['deadline'] = deadline.toIso8601String();
      }
      if (gradeWeight != null) {
        updates.add('grade_weight = :gradeWeight');
        params['gradeWeight'] = gradeWeight;
      }
      if (isFuzzyAuto != null) {
        updates.add('is_fuzzy_auto = :isFuzzyAuto');
        params['isFuzzyAuto'] = isFuzzyAuto ? 1 : 0;
      }
      if (computedPriority != null) {
        updates.add('priority = :priority');
        params['priority'] = computedPriority;
      }
      if (clearAssignee) {
        updates.add('id_assigned_to = NULL');
      } else if (idAssignedTo != null) {
        updates.add('id_assigned_to = :idAssignedTo');
        params['idAssignedTo'] =
            idAssignedTo.trim().isEmpty ? null : idAssignedTo.trim();
      }
      if (clearMilestone) {
        updates.add('id_milestone = NULL');
      } else if (idMilestone != null) {
        updates.add('id_milestone = :idMilestone');
        params['idMilestone'] =
            idMilestone.trim().isEmpty ? null : idMilestone.trim();
      }
      if (isCompleted != null) {
        updates.add('is_completed = :isCompleted');
        params['isCompleted'] = isCompleted ? 1 : 0;
      }
      if (tags != null) {
        updates.add('tags = :tags::jsonb');
        params['tags'] = jsonEncode(tags);
      }

      if (updates.isNotEmpty) {
        updates.add('updated_at = NOW()');
        await tx.query(
          'UPDATE group_task SET ${updates.join(', ')} WHERE id_group_task = :idGroupTask AND id_group = :idGroup',
          params,
        );
      }
    });

    return getGroupTaskById(idGroup, idGroupTask, idUser);
  }

  static Future<Map<String, dynamic>> toggleGroupTaskComplete({
    required String idGroup,
    required String idGroupTask,
    required String idUser,
    bool? isCompleted,
  }) async {
    await Database.transaction((tx) async {
      final role = await _requireMembership(idGroup, idUser, tx: tx);

      final res = await tx.query(
        '''
        SELECT id_assigned_to, is_completed
        FROM group_task
        WHERE id_group_task = :idGroupTask AND id_group = :idGroup
        LIMIT 1
        ''',
        {'idGroupTask': idGroupTask, 'idGroup': idGroup},
      );
      if (res.rows.isEmpty) {
        throw GroupNotFoundException('Tugas kelompok tidak ditemukan.');
      }

      final row = res.rows.first.assoc();
      final assignedTo = row['id_assigned_to']?.toString();
      if (role != 'LEADER' &&
          assignedTo != null &&
          assignedTo.isNotEmpty &&
          assignedTo != idUser) {
        throw GroupForbiddenException(
          'Hanya anggota yang ditugaskan atau ketua kelompok yang dapat menyelesaikan tugas ini.',
        );
      }

      final nextVal = isCompleted ?? !_toBool(row['is_completed']);
      await tx.query(
        '''
        UPDATE group_task
        SET is_completed = :isCompleted, updated_at = NOW()
        WHERE id_group_task = :idGroupTask AND id_group = :idGroup
        ''',
        {
          'idGroupTask': idGroupTask,
          'idGroup': idGroup,
          'isCompleted': nextVal ? 1 : 0,
        },
      );
    });

    return getGroupTaskById(idGroup, idGroupTask, idUser);
  }

  static Future<void> deleteGroupTask({
    required String idGroup,
    required String idGroupTask,
    required String idUser,
  }) async {
    await Database.transaction((tx) async {
      await _requireMembership(idGroup, idUser, tx: tx);

      final res = await tx.query(
        'SELECT id_group_task FROM group_task WHERE id_group_task = :idGroupTask AND id_group = :idGroup LIMIT 1',
        {'idGroupTask': idGroupTask, 'idGroup': idGroup},
      );
      if (res.rows.isEmpty) {
        throw GroupNotFoundException('Tugas kelompok tidak ditemukan.');
      }

      await tx.query(
        'DELETE FROM group_sub_task WHERE id_group_task = :idGroupTask',
        {'idGroupTask': idGroupTask},
      );
      await tx.query(
        'DELETE FROM group_task WHERE id_group_task = :idGroupTask AND id_group = :idGroup',
        {'idGroupTask': idGroupTask, 'idGroup': idGroup},
      );
    });
  }

  // ─── 4. SUBTASKS (group_sub_task) ─────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> listSubTasks(
    String idGroup,
    String idGroupTask,
    String idUser,
  ) async {
    await _requireMembership(idGroup, idUser);

    final parent = await Database.query(
      'SELECT id_group_task FROM group_task WHERE id_group_task = :idGroupTask AND id_group = :idGroup LIMIT 1',
      {'idGroupTask': idGroupTask, 'idGroup': idGroup},
    );
    if (parent.rows.isEmpty) {
      throw GroupNotFoundException('Tugas kelompok tidak ditemukan.');
    }

    final res = await Database.query(
      '''
      SELECT
        gs.id_sub_task,
        gs.id_group_task,
        gs.id_assigned_to,
        u.name AS assigned_name,
        gs.sub_task_title,
        gs.description,
        gs.deadline,
        gs.grade_weight,
        gs.is_completed,
        gs.created_at,
        gs.updated_at
      FROM group_sub_task gs
      LEFT JOIN users u ON gs.id_assigned_to = u.id_user
      WHERE gs.id_group_task = :idGroupTask
      ORDER BY gs.is_completed ASC, gs.deadline ASC
      ''',
      {'idGroupTask': idGroupTask},
    );

    return res.rows.map((r) {
      final row = r.assoc();
      return {
        'idSubTask': row['id_sub_task']?.toString() ?? '',
        'idGroupTask': row['id_group_task']?.toString() ?? '',
        'idAssignedTo': row['id_assigned_to']?.toString(),
        'assignedToName': row['assigned_name']?.toString(),
        'subTaskTitle': row['sub_task_title']?.toString() ?? '',
        'description': row['description']?.toString() ?? '',
        'deadline': _parseIso(row['deadline']),
        'gradeWeight': _toDouble(row['grade_weight']),
        'isCompleted': _toBool(row['is_completed']),
        'createdAt': _parseIso(row['created_at']),
        'updatedAt': _parseIso(row['updated_at']),
      };
    }).toList();
  }

  static Future<Map<String, dynamic>> createSubTask({
    required String idGroup,
    required String idGroupTask,
    required String idUser,
    required String subTaskTitle,
    String description = '',
    required DateTime deadline,
    double gradeWeight = 10.0,
    String? idAssignedTo,
  }) async {
    final idSubTask = _uuid.v4();

    await Database.transaction((tx) async {
      await _requireMembership(idGroup, idUser, tx: tx);

      final parent = await tx.query(
        'SELECT id_group_task FROM group_task WHERE id_group_task = :idGroupTask AND id_group = :idGroup LIMIT 1',
        {'idGroupTask': idGroupTask, 'idGroup': idGroup},
      );
      if (parent.rows.isEmpty) {
        throw GroupNotFoundException('Tugas kelompok tidak ditemukan.');
      }

      if (idAssignedTo != null && idAssignedTo.trim().isNotEmpty) {
        await _ensureMemberInGroup(tx, idGroup, idAssignedTo.trim());
      }

      await tx.query(
        '''
        INSERT INTO group_sub_task (
          id_sub_task, id_group_task, id_assigned_to, sub_task_title,
          description, deadline, grade_weight, is_completed, created_at, updated_at
        )
        VALUES (
          :idSubTask, :idGroupTask, :idAssignedTo, :subTaskTitle,
          :description, :deadline::timestamp, :gradeWeight, 0, NOW(), NOW()
        )
        ''',
        {
          'idSubTask': idSubTask,
          'idGroupTask': idGroupTask,
          'idAssignedTo':
              (idAssignedTo != null && idAssignedTo.trim().isNotEmpty)
                  ? idAssignedTo.trim()
                  : null,
          'subTaskTitle': subTaskTitle.trim(),
          'description': description.trim(),
          'deadline': deadline.toIso8601String(),
          'gradeWeight': gradeWeight,
        },
      );
    });

    final all = await listSubTasks(idGroup, idGroupTask, idUser);
    return all.firstWhere((s) => s['idSubTask'] == idSubTask);
  }

  static Future<Map<String, dynamic>> toggleSubTaskComplete({
    required String idGroup,
    required String idGroupTask,
    required String idSubTask,
    required String idUser,
    bool? isCompleted,
  }) async {
    await Database.transaction((tx) async {
      final role = await _requireMembership(idGroup, idUser, tx: tx);

      final res = await tx.query(
        '''
        SELECT gs.id_assigned_to, gs.is_completed
        FROM group_sub_task gs
        JOIN group_task gt ON gs.id_group_task = gt.id_group_task
        WHERE gs.id_sub_task = :idSubTask
          AND gs.id_group_task = :idGroupTask
          AND gt.id_group = :idGroup
        LIMIT 1
        ''',
        {
          'idSubTask': idSubTask,
          'idGroupTask': idGroupTask,
          'idGroup': idGroup,
        },
      );
      if (res.rows.isEmpty) {
        throw GroupNotFoundException('Sub-tugas tidak ditemukan.');
      }

      final row = res.rows.first.assoc();
      final assignedTo = row['id_assigned_to']?.toString();
      if (role != 'LEADER' &&
          assignedTo != null &&
          assignedTo.isNotEmpty &&
          assignedTo != idUser) {
        throw GroupForbiddenException(
          'Hanya anggota yang ditugaskan atau ketua kelompok yang dapat menyelesaikan sub-tugas ini.',
        );
      }

      final nextVal = isCompleted ?? !_toBool(row['is_completed']);
      await tx.query(
        '''
        UPDATE group_sub_task
        SET is_completed = :isCompleted, updated_at = NOW()
        WHERE id_sub_task = :idSubTask AND id_group_task = :idGroupTask
        ''',
        {
          'idSubTask': idSubTask,
          'idGroupTask': idGroupTask,
          'isCompleted': nextVal ? 1 : 0,
        },
      );
    });

    final all = await listSubTasks(idGroup, idGroupTask, idUser);
    return all.firstWhere((s) => s['idSubTask'] == idSubTask);
  }

  static Future<void> deleteSubTask({
    required String idGroup,
    required String idGroupTask,
    required String idSubTask,
    required String idUser,
  }) async {
    await Database.transaction((tx) async {
      await _requireMembership(idGroup, idUser, tx: tx);

      final res = await tx.query(
        '''
        SELECT gs.id_sub_task
        FROM group_sub_task gs
        JOIN group_task gt ON gs.id_group_task = gt.id_group_task
        WHERE gs.id_sub_task = :idSubTask
          AND gs.id_group_task = :idGroupTask
          AND gt.id_group = :idGroup
        LIMIT 1
        ''',
        {
          'idSubTask': idSubTask,
          'idGroupTask': idGroupTask,
          'idGroup': idGroup,
        },
      );
      if (res.rows.isEmpty) {
        throw GroupNotFoundException('Sub-tugas tidak ditemukan.');
      }

      await tx.query(
        'DELETE FROM group_sub_task WHERE id_sub_task = :idSubTask AND id_group_task = :idGroupTask',
        {'idSubTask': idSubTask, 'idGroupTask': idGroupTask},
      );
    });
  }

  // ─── 5. MEETINGS (meeting_schedule) ───────────────────────────────────────

  static Future<List<Map<String, dynamic>>> listMeetings(
    String idGroup,
    String idUser,
  ) async {
    await _requireMembership(idGroup, idUser);

    final res = await Database.query(
      '''
      SELECT id_meeting, id_group, meeting_title, description, start_time, platform_location, created_at
      FROM meeting_schedule
      WHERE id_group = :idGroup
      ORDER BY start_time ASC
      ''',
      {'idGroup': idGroup},
    );

    return res.rows.map((r) {
      final row = r.assoc();
      return {
        'idMeeting': row['id_meeting']?.toString() ?? '',
        'idGroup': row['id_group']?.toString() ?? '',
        'meetingTitle': row['meeting_title']?.toString() ?? '',
        'description': row['description']?.toString() ?? '',
        'startTime': _parseIso(row['start_time']),
        'platformLocation': row['platform_location']?.toString() ?? '',
        'createdAt': _parseIso(row['created_at']),
      };
    }).toList();
  }

  static Future<Map<String, dynamic>> createMeeting({
    required String idGroup,
    required String idUser,
    required String meetingTitle,
    String description = '',
    required DateTime startTime,
    required String platformLocation,
  }) async {
    await _requireMembership(idGroup, idUser);
    final idMeeting = _uuid.v4();

    await Database.query(
      '''
      INSERT INTO meeting_schedule (
        id_meeting, id_group, meeting_title, description, start_time, platform_location, created_at
      )
      VALUES (
        :idMeeting, :idGroup, :meetingTitle, :description, :startTime::timestamp, :platformLocation, NOW()
      )
      ''',
      {
        'idMeeting': idMeeting,
        'idGroup': idGroup,
        'meetingTitle': meetingTitle.trim(),
        'description': description.trim(),
        'startTime': startTime.toIso8601String(),
        'platformLocation': platformLocation.trim(),
      },
    );

    final all = await listMeetings(idGroup, idUser);
    return all.firstWhere((m) => m['idMeeting'] == idMeeting);
  }

  static Future<Map<String, dynamic>> updateMeeting({
    required String idGroup,
    required String idMeeting,
    required String idUser,
    String? meetingTitle,
    String? description,
    DateTime? startTime,
    String? platformLocation,
  }) async {
    await _requireMembership(idGroup, idUser);

    final existing = await Database.query(
      'SELECT id_meeting FROM meeting_schedule WHERE id_meeting = :idMeeting AND id_group = :idGroup LIMIT 1',
      {'idMeeting': idMeeting, 'idGroup': idGroup},
    );
    if (existing.rows.isEmpty) {
      throw GroupNotFoundException('Jadwal rapat tidak ditemukan.');
    }

    final updates = <String>[];
    final params = <String, dynamic>{
      'idMeeting': idMeeting,
      'idGroup': idGroup,
    };

    if (meetingTitle != null) {
      updates.add('meeting_title = :meetingTitle');
      params['meetingTitle'] = meetingTitle.trim();
    }
    if (description != null) {
      updates.add('description = :description');
      params['description'] = description.trim();
    }
    if (startTime != null) {
      updates.add('start_time = :startTime::timestamp');
      params['startTime'] = startTime.toIso8601String();
    }
    if (platformLocation != null) {
      updates.add('platform_location = :platformLocation');
      params['platformLocation'] = platformLocation.trim();
    }

    if (updates.isNotEmpty) {
      await Database.query(
        'UPDATE meeting_schedule SET ${updates.join(', ')} WHERE id_meeting = :idMeeting AND id_group = :idGroup',
        params,
      );
    }

    final all = await listMeetings(idGroup, idUser);
    return all.firstWhere((m) => m['idMeeting'] == idMeeting);
  }

  static Future<void> deleteMeeting({
    required String idGroup,
    required String idMeeting,
    required String idUser,
  }) async {
    await _requireMembership(idGroup, idUser);

    final existing = await Database.query(
      'SELECT id_meeting FROM meeting_schedule WHERE id_meeting = :idMeeting AND id_group = :idGroup LIMIT 1',
      {'idMeeting': idMeeting, 'idGroup': idGroup},
    );
    if (existing.rows.isEmpty) {
      throw GroupNotFoundException('Jadwal rapat tidak ditemukan.');
    }

    await Database.query(
      'DELETE FROM meeting_schedule WHERE id_meeting = :idMeeting AND id_group = :idGroup',
      {'idMeeting': idMeeting, 'idGroup': idGroup},
    );
  }
}
