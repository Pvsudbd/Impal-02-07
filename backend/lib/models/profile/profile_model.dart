import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';
import '../../config/db.dart';

/// Thrown when updating profile email conflicts with another existing user.
class DuplicateEmailException implements Exception {
  final String message;

  DuplicateEmailException([
    this.message = 'Email sudah digunakan oleh akun lain.',
  ]);

  @override
  String toString() => message;
}

/// Model representing a User's Profile and academic/task methods per Class Diagram.
/// Class Diagram reference: `User` in `Class_Diagram.md`
/// Database table reference: `users` and `groups` in `Entity_Relationship_Diagram.md`
class ProfileModel {
  static const _uuid = Uuid();

  final String idUser;
  final String name;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Academic & Activity Statistics
  final int tasksDoneCount;
  final int tasksPendingCount;
  final int schedulesCount;
  final int coursesCount;
  final int groupsCount;

  ProfileModel({
    required this.idUser,
    required this.name,
    required this.email,
    this.createdAt,
    this.updatedAt,
    this.tasksDoneCount = 0,
    this.tasksPendingCount = 0,
    this.schedulesCount = 0,
    this.coursesCount = 0,
    this.groupsCount = 0,
  });

  // Getter aliases for backwards compatibility
  String get idStudent => idUser;
  String get studentId => idUser;
  String get userId => idUser;

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'userId': idUser,
      'idStudent': idUser,
      'studentId': idUser,
      'name': name,
      'fullName': name,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'statistics': {
        'tasksDoneCount': tasksDoneCount,
        'tasksPendingCount': tasksPendingCount,
        'schedulesCount': schedulesCount,
        'coursesCount': coursesCount,
        'groupsCount': groupsCount,
      },
    };
  }

  static Map<String, dynamic> _serializeRow(Map<String, dynamic> row) {
    return row.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key, value.toIso8601String());
      }
      return MapEntry(key, value);
    });
  }

  // ─── GET USER PROFILE BY ID (Single Aggregated Query) ──────────────────────
  static Future<ProfileModel?> getProfile(String idUser) async {
    const sql = '''
      SELECT
        u.id_user,
        u.name,
        u.email,
        u.created_at,
        u.updated_at,
        (SELECT COUNT(*) FROM task t WHERE t.id_user = u.id_user AND t.is_completed = 1) AS tasks_done,
        (SELECT COUNT(*) FROM task t WHERE t.id_user = u.id_user AND t.is_completed = 0) AS tasks_pending,
        (SELECT COUNT(*) FROM agenda a WHERE a.id_user = u.id_user) AS schedules_count,
        (
          SELECT COUNT(DISTINCT cs.id_course)
          FROM course_schedule cs
          JOIN agenda a ON cs.id_agenda = a.id_agenda
          WHERE a.id_user = u.id_user
        ) AS courses_count,
        (SELECT COUNT(*) FROM group_member gm WHERE gm.id_user = u.id_user) AS groups_count
      FROM users u
      WHERE u.id_user = :idUser
      LIMIT 1
    ''';

    final results = await Database.query(sql, {'idUser': idUser});
    if (results.rows.isEmpty) return null;

    final row = results.rows.first.assoc();
    int toInt(dynamic val) => int.tryParse(val?.toString() ?? '0') ?? 0;

    return ProfileModel(
      idUser: row['id_user']?.toString() ?? '',
      name: row['name']?.toString() ?? '',
      email: row['email']?.toString() ?? '',
      createdAt: row['created_at'] != null
          ? DateTime.tryParse(row['created_at'].toString())
          : null,
      updatedAt: row['updated_at'] != null
          ? DateTime.tryParse(row['updated_at'].toString())
          : null,
      tasksDoneCount: toInt(row['tasks_done']),
      tasksPendingCount: toInt(row['tasks_pending']),
      schedulesCount: toInt(row['schedules_count']),
      coursesCount: toInt(row['courses_count']),
      groupsCount: toInt(row['groups_count']),
    );
  }

  // ─── UPDATE PROFILE (NAME & EMAIL) ─────────────────────────────────────────
  static Future<bool> updateProfile(
    String idUser, {
    required String name,
    String? email,
  }) async {
    final params = <String, dynamic>{
      'idUser': idUser,
      'name': name.trim(),
    };

    var sql = 'UPDATE users SET name = :name';
    if (email != null && email.trim().isNotEmpty) {
      final normalizedEmail = email.trim().toLowerCase();
      final existing = await Database.query(
        'SELECT id_user FROM users WHERE LOWER(email) = :email AND id_user != :idUser LIMIT 1',
        {'email': normalizedEmail, 'idUser': idUser},
      );
      if (existing.rows.isNotEmpty) {
        throw DuplicateEmailException();
      }
      sql += ', email = :email';
      params['email'] = normalizedEmail;
    }

    sql += ', updated_at = NOW() WHERE id_user = :idUser';
    await Database.query(sql, params);
    return true;
  }

  // ─── CHANGE PASSWORD ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> changePassword(
    String idUser, {
    required String currentPassword,
    required String newPassword,
  }) async {
    final results = await Database.query(
      'SELECT password_hash FROM users WHERE id_user = :idUser LIMIT 1',
      {'idUser': idUser},
    );
    if (results.rows.isEmpty) {
      return {'success': false, 'message': 'User tidak ditemukan.'};
    }

    final hash = results.rows.first.assoc()['password_hash']?.toString() ?? '';
    final isMatch = BCrypt.checkpw(currentPassword, hash);
    if (!isMatch) {
      return {'success': false, 'message': 'Password saat ini salah.'};
    }

    final newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
    await Database.query(
      'UPDATE users SET password_hash = :newHash, updated_at = NOW() WHERE id_user = :idUser',
      {'idUser': idUser, 'newHash': newHash},
    );

    return {'success': true, 'message': 'Password berhasil diperbarui.'};
  }

  // ─── CLASS DIAGRAM METHOD: viewDailyAgenda(date: Date) ─────────────────────
  static Future<List<Map<String, dynamic>>> viewDailyAgenda(
    String idUser,
    DateTime date,
  ) async {
    final dateStr =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayName = days[date.weekday - 1];
    const daysIndo = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final dayIndo = daysIndo[date.weekday - 1];

    const sql = '''
      SELECT 
        a.id_agenda,
        a.title,
        TO_CHAR(a.start_time, 'HH24:MI') AS start_time,
        TO_CHAR(a.end_time, 'HH24:MI') AS end_time,
        a.agenda_type,
        cs.id_course,
        c.course_name,
        cs.day,
        cs.room,
        TO_CHAR(ps.date, 'YYYY-MM-DD') AS date,
        ps.category,
        ps.location,
        ps.notes
      FROM agenda a
      LEFT JOIN course_schedule cs ON a.id_agenda = cs.id_agenda
      LEFT JOIN course c ON cs.id_course = c.id_course
      LEFT JOIN personal_schedule ps ON a.id_agenda = ps.id_agenda
      WHERE a.id_user = :idUser
        AND (ps.date = :dateStr::date OR (a.agenda_type = 'COURSE' AND (cs.day = :dayName OR cs.day = :dayIndo)))
      ORDER BY a.start_time ASC
    ''';

    final results = await Database.query(sql, {
      'idUser': idUser,
      'dateStr': dateStr,
      'dayName': dayName,
      'dayIndo': dayIndo,
    });
    return results.rows.map((r) => _serializeRow(r.assoc())).toList();
  }

  // ─── CLASS DIAGRAM METHOD: viewCourseSchedule() ────────────────────────────
  static Future<List<Map<String, dynamic>>> viewCourseSchedule(
    String idUser,
  ) async {
    const sql = '''
      SELECT 
        a.id_agenda,
        a.title,
        TO_CHAR(a.start_time, 'HH24:MI') AS start_time,
        TO_CHAR(a.end_time, 'HH24:MI') AS end_time,
        cs.id_course,
        cs.day,
        cs.room,
        c.course_name,
        c.credits
      FROM course_schedule cs
      JOIN agenda a ON cs.id_agenda = a.id_agenda
      LEFT JOIN course c ON cs.id_course = c.id_course
      WHERE a.id_user = :idUser
      ORDER BY CASE cs.day
        WHEN 'Monday' THEN 1 WHEN 'Senin' THEN 1
        WHEN 'Tuesday' THEN 2 WHEN 'Selasa' THEN 2
        WHEN 'Wednesday' THEN 3 WHEN 'Rabu' THEN 3
        WHEN 'Thursday' THEN 4 WHEN 'Kamis' THEN 4
        WHEN 'Friday' THEN 5 WHEN 'Jumat' THEN 5
        WHEN 'Saturday' THEN 6 WHEN 'Sabtu' THEN 6
        WHEN 'Sunday' THEN 7 WHEN 'Minggu' THEN 7
        ELSE 8 END, a.start_time ASC
    ''';

    final results = await Database.query(sql, {'idUser': idUser});
    return results.rows.map((r) => _serializeRow(r.assoc())).toList();
  }

  // ─── CLASS DIAGRAM METHOD: viewRemainingTasks() ────────────────────────────
  static Future<List<Map<String, dynamic>>> viewRemainingTasks(
    String idUser,
  ) async {
    const sql = '''
      SELECT 
        t.id_task,
        t.task_title,
        t.description,
        t.deadline,
        t.grade_weight,
        t.priority_score,
        t.priority,
        t.is_fuzzy_auto,
        t.is_completed,
        t.id_course,
        c.course_name
      FROM task t
      LEFT JOIN course c ON t.id_course = c.id_course
      WHERE t.id_user = :idUser AND t.is_completed = 0
      ORDER BY t.deadline ASC
    ''';

    final results = await Database.query(sql, {'idUser': idUser});
    return results.rows.map((r) => _serializeRow(r.assoc())).toList();
  }

  // ─── CLASS DIAGRAM METHOD: joinGroup(inviteCode: String) ───────────────────
  static Future<Map<String, dynamic>> joinGroup(
    String idUser,
    String inviteCode,
  ) async {
    try {
      final groupRes = await Database.query(
        'SELECT id_group, group_name FROM "groups" WHERE invite_code = :inviteCode LIMIT 1',
        {'inviteCode': inviteCode.trim().toUpperCase()},
      );

      if (groupRes.rows.isEmpty) {
        return {
          'success': false,
          'message': 'Kode undangan kelompok tidak ditemukan.',
        };
      }

      final groupRow = groupRes.rows.first.assoc();
      final idGroup = groupRow['id_group']?.toString() ?? '';
      final groupName = groupRow['group_name']?.toString() ?? '';

      final memberCheck = await Database.query(
        'SELECT id_member FROM group_member WHERE id_group = :idGroup AND id_user = :idUser LIMIT 1',
        {'idGroup': idGroup, 'idUser': idUser},
      );

      if (memberCheck.rows.isNotEmpty) {
        return {
          'success': false,
          'message': 'Anda sudah terdaftar sebagai anggota kelompok ini.',
        };
      }

      final idMember = _uuid.v4();
      await Database.query(
        'INSERT INTO group_member (id_member, id_group, id_user, role, joined_at) '
        'VALUES (:idMember, :idGroup, :idUser, :role, NOW())',
        {
          'idMember': idMember,
          'idGroup': idGroup,
          'idUser': idUser,
          'role': 'MEMBER',
        },
      );

      return {
        'success': true,
        'message': 'Berhasil bergabung ke kelompok $groupName.',
        'data': {
          'idMember': idMember,
          'idGroup': idGroup,
          'groupName': groupName,
          'role': 'MEMBER',
        },
      };
    } catch (e) {
      print('[PROFILE] joinGroup error: $e');
      return {
        'success': false,
        'message': 'Gagal bergabung ke kelompok.',
      };
    }
  }
}
