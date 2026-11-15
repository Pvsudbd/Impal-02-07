import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';
import '../../config/db.dart';

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

  // ─── GET USER PROFILE BY ID ───────────────────────────────────────────────
  static Future<ProfileModel?> getProfile(String idUser) async {
    Map<String, dynamic> row;
    try {
      final results = await Database.query(
        'SELECT id_user, name, email, created_at, updated_at FROM users WHERE id_user = :idUser LIMIT 1',
        {'idUser': idUser},
      );
      if (results.rows.isEmpty) return null;
      row = results.rows.first.assoc();
    } catch (e) {
      if (e.toString().contains('id_user')) {
        final results = await Database.query(
          'SELECT id_student AS id_user, name, email, created_at, updated_at FROM users WHERE id_student = :idUser LIMIT 1',
          {'idUser': idUser},
        );
        if (results.rows.isEmpty) return null;
        row = results.rows.first.assoc();
      } else {
        rethrow;
      }
    }

    int tasksDone = 0;
    int tasksPending = 0;
    int schedules = 0;
    int courses = 0;
    int groups = 0;

    // Hitung statistik tugas jika tabel task tersedia
    try {
      var taskDoneRes = await Database.query(
        'SELECT COUNT(*) AS total FROM task WHERE id_user = :idUser AND is_completed IS TRUE',
        {'idUser': idUser},
      );
      if (taskDoneRes.rows.isNotEmpty) {
        tasksDone = int.tryParse(taskDoneRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
      }
    } catch (_) {
      try {
        var taskDoneRes = await Database.query(
          'SELECT COUNT(*) AS total FROM task WHERE id_student = :idUser AND is_completed IS TRUE',
          {'idUser': idUser},
        );
        if (taskDoneRes.rows.isNotEmpty) {
          tasksDone = int.tryParse(taskDoneRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
        }
      } catch (_) {}
    }

    try {
      var taskPendingRes = await Database.query(
        'SELECT COUNT(*) AS total FROM task WHERE id_user = :idUser AND is_completed IS NOT TRUE',
        {'idUser': idUser},
      );
      if (taskPendingRes.rows.isNotEmpty) {
        tasksPending = int.tryParse(taskPendingRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
      }
    } catch (_) {
      try {
        var taskPendingRes = await Database.query(
          'SELECT COUNT(*) AS total FROM task WHERE id_student = :idUser AND is_completed IS NOT TRUE',
          {'idUser': idUser},
        );
        if (taskPendingRes.rows.isNotEmpty) {
          tasksPending = int.tryParse(taskPendingRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
        }
      } catch (_) {}
    }

    // Hitung statistik jadwal & kuliah
    try {
      var schedRes = await Database.query(
        'SELECT COUNT(*) AS total FROM agenda WHERE id_user = :idUser',
        {'idUser': idUser},
      );
      if (schedRes.rows.isNotEmpty) {
        schedules = int.tryParse(schedRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
      }
    } catch (_) {
      try {
        var schedRes = await Database.query(
          'SELECT COUNT(*) AS total FROM agenda WHERE id_student = :idUser',
          {'idUser': idUser},
        );
        if (schedRes.rows.isNotEmpty) {
          schedules = int.tryParse(schedRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
        }
      } catch (_) {}
    }

    try {
      var courseRes = await Database.query(
        'SELECT COUNT(DISTINCT cs.course_code) AS total FROM course_schedule cs JOIN agenda a ON cs.id_agenda = a.id_agenda WHERE a.id_user = :idUser',
        {'idUser': idUser},
      );
      if (courseRes.rows.isNotEmpty) {
        courses = int.tryParse(courseRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
      }
    } catch (_) {
      try {
        var courseRes = await Database.query(
          'SELECT COUNT(DISTINCT cs.course_code) AS total FROM course_schedule cs JOIN agenda a ON cs.id_agenda = a.id_agenda WHERE a.id_student = :idUser',
          {'idUser': idUser},
        );
        if (courseRes.rows.isNotEmpty) {
          courses = int.tryParse(courseRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
        }
      } catch (_) {}
    }

    // Hitung grup yang diikuti
    try {
      var groupRes = await Database.query(
        'SELECT COUNT(*) AS total FROM group_member WHERE id_user = :idUser',
        {'idUser': idUser},
      );
      if (groupRes.rows.isNotEmpty) {
        groups = int.tryParse(groupRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
      }
    } catch (_) {
      try {
        var groupRes = await Database.query(
          'SELECT COUNT(*) AS total FROM group_member WHERE id_student = :idUser',
          {'idUser': idUser},
        );
        if (groupRes.rows.isNotEmpty) {
          groups = int.tryParse(groupRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
        }
      } catch (_) {}
    }

    return ProfileModel(
      idUser: (row['id_user'] ?? row['id_student'])?.toString() ?? '',
      name: row['name']?.toString() ?? '',
      email: row['email']?.toString() ?? '',
      createdAt: row['created_at'] != null ? DateTime.tryParse(row['created_at'].toString()) : null,
      updatedAt: row['updated_at'] != null ? DateTime.tryParse(row['updated_at'].toString()) : null,
      tasksDoneCount: tasksDone,
      tasksPendingCount: tasksPending,
      schedulesCount: schedules,
      coursesCount: courses,
      groupsCount: groups,
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

    String sql = 'UPDATE users SET name = :name';
    if (email != null && email.trim().isNotEmpty) {
      // 🛡️ Verifikasi keunikan email sebelum update
      try {
        final existing = await Database.query(
          'SELECT id_user FROM users WHERE email = :email AND id_user != :idUser LIMIT 1',
          {'email': email.trim(), 'idUser': idUser},
        );
        if (existing.rows.isNotEmpty) {
          throw Exception('Email sudah digunakan oleh akun lain.');
        }
      } catch (e) {
        if (e.toString().contains('id_user')) {
          final existing = await Database.query(
            'SELECT id_student FROM users WHERE email = :email AND id_student != :idUser LIMIT 1',
            {'email': email.trim(), 'idUser': idUser},
          );
          if (existing.rows.isNotEmpty) {
            throw Exception('Email sudah digunakan oleh akun lain.');
          }
        } else {
          rethrow;
        }
      }
      sql += ', email = :email';
      params['email'] = email.trim();
    }

    try {
      sql += ', updated_at = NOW() WHERE id_user = :idUser';
      await Database.query(sql, params);
    } catch (e) {
      if (e.toString().contains('id_user')) {
        final fallbackSql = sql.replaceAll('WHERE id_user = :idUser', 'WHERE id_student = :idUser');
        await Database.query(fallbackSql, params);
      } else {
        rethrow;
      }
    }
    return true;
  }

  // ─── CHANGE PASSWORD ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> changePassword(
    String idUser, {
    required String currentPassword,
    required String newPassword,
  }) async {
    String hash;
    try {
      final results = await Database.query(
        'SELECT password_hash FROM users WHERE id_user = :idUser LIMIT 1',
        {'idUser': idUser},
      );
      if (results.rows.isEmpty) {
        return {'success': false, 'message': 'User tidak ditemukan.'};
      }
      hash = results.rows.first.assoc()['password_hash']?.toString() ?? '';
    } catch (e) {
      if (e.toString().contains('id_user')) {
        final results = await Database.query(
          'SELECT password_hash FROM users WHERE id_student = :idUser LIMIT 1',
          {'idUser': idUser},
        );
        if (results.rows.isEmpty) {
          return {'success': false, 'message': 'User tidak ditemukan.'};
        }
        hash = results.rows.first.assoc()['password_hash']?.toString() ?? '';
      } else {
        rethrow;
      }
    }

    final isMatch = BCrypt.checkpw(currentPassword, hash);
    if (!isMatch) {
      return {'success': false, 'message': 'Password saat ini salah.'};
    }

    final newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
    try {
      await Database.query(
        'UPDATE users SET password_hash = :newHash, updated_at = NOW() WHERE id_user = :idUser',
        {
          'idUser': idUser,
          'newHash': newHash,
        },
      );
    } catch (e) {
      if (e.toString().contains('id_user')) {
        await Database.query(
          'UPDATE users SET password_hash = :newHash, updated_at = NOW() WHERE id_student = :idUser',
          {
            'idUser': idUser,
            'newHash': newHash,
          },
        );
      } else {
        rethrow;
      }
    }

    return {'success': true, 'message': 'Password berhasil diperbarui.'};
  }

  // ─── CLASS DIAGRAM METHOD: viewDailyAgenda(date: Date) ─────────────────────
  static Future<List<Map<String, dynamic>>> viewDailyAgenda(
    String idUser,
    DateTime date,
  ) async {
    final dateStr = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = days[date.weekday - 1];
    const daysIndo = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final dayIndo = daysIndo[date.weekday - 1];

    final sql = '''
      SELECT 
        a.id_agenda,
        a.title,
        TO_CHAR(a.start_time, 'HH24:MI') AS start_time,
        TO_CHAR(a.end_time, 'HH24:MI') AS end_time,
        a.agenda_type,
        cs.course_code,
        cs.day,
        cs.room,
        ps.date,
        ps.category,
        ps.location,
        ps.notes
      FROM agenda a
      LEFT JOIN course_schedule cs ON a.id_agenda = cs.id_agenda
      LEFT JOIN personal_schedule ps ON a.id_agenda = ps.id_agenda
      WHERE a.id_user = :idUser
        AND (ps.date = :dateStr::date OR (a.agenda_type = 'COURSE' AND (cs.day = :dayName OR cs.day = :dayIndo)))
      ORDER BY a.start_time ASC
    ''';

    try {
      final results = await Database.query(sql, {
        'idUser': idUser,
        'dateStr': dateStr,
        'dayName': dayName,
        'dayIndo': dayIndo,
      });
      return results.rows.map((r) => r.assoc()).toList();
    } catch (e) {
      if (e.toString().contains('id_user')) {
        final fallbackSql = sql.replaceAll('a.id_user = :idUser', 'a.id_student = :idUser');
        final results = await Database.query(fallbackSql, {
          'idUser': idUser,
          'dateStr': dateStr,
          'dayName': dayName,
          'dayIndo': dayIndo,
        });
        return results.rows.map((r) => r.assoc()).toList();
      }
      rethrow;
    }
  }

  // ─── CLASS DIAGRAM METHOD: viewCourseSchedule() ────────────────────────────
  static Future<List<Map<String, dynamic>>> viewCourseSchedule(String idUser) async {
    final sql = '''
      SELECT 
        a.id_agenda,
        a.title,
        TO_CHAR(a.start_time, 'HH24:MI') AS start_time,
        TO_CHAR(a.end_time, 'HH24:MI') AS end_time,
        cs.course_code,
        cs.day,
        cs.room,
        c.course_name,
        c.credits,
        c.lecturer
      FROM course_schedule cs
      JOIN agenda a ON cs.id_agenda = a.id_agenda
      LEFT JOIN course c ON cs.course_code = c.course_code
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

    try {
      final results = await Database.query(sql, {'idUser': idUser});
      return results.rows.map((r) => r.assoc()).toList();
    } catch (e) {
      if (e.toString().contains('id_user')) {
        final fallbackSql = sql.replaceAll('a.id_user = :idUser', 'a.id_student = :idUser');
        final results = await Database.query(fallbackSql, {'idUser': idUser});
        return results.rows.map((r) => r.assoc()).toList();
      }
      rethrow;
    }
  }

  // ─── CLASS DIAGRAM METHOD: viewRemainingTasks() ────────────────────────────
  static Future<List<Map<String, dynamic>>> viewRemainingTasks(String idUser) async {
    try {
      final sql = '''
        SELECT 
          id_task,
          task_title,
          description,
          deadline,
          grade_weight,
          priority_score,
          priority,
          is_fuzzy_auto,
          is_completed,
          course_code
        FROM task
        WHERE id_user = :idUser AND is_completed IS NOT TRUE
        ORDER BY deadline ASC
      ''';

      try {
        final results = await Database.query(sql, {'idUser': idUser});
        return results.rows.map((r) => r.assoc()).toList();
      } catch (e) {
        if (e.toString().contains('id_user')) {
          final fallbackSql = sql.replaceAll('id_user = :idUser', 'id_student = :idUser');
          final results = await Database.query(fallbackSql, {'idUser': idUser});
          return results.rows.map((r) => r.assoc()).toList();
        }
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  // ─── CLASS DIAGRAM METHOD: joinGroup(inviteCode: String) ───────────────────
  static Future<Map<String, dynamic>> joinGroup(
    String idUser,
    String inviteCode,
  ) async {
    try {
      // Query ke tabel `groups` (MySQL reserved word wrapped in backticks)
      final groupRes = await Database.query(
        'SELECT id_group, group_name FROM `groups` WHERE invite_code = :inviteCode LIMIT 1',
        {'inviteCode': inviteCode.trim().toUpperCase()},
      );

      if (groupRes.rows.isEmpty) {
        return {'success': false, 'message': 'Kode undangan kelompok tidak ditemukan.'};
      }

      final groupRow = groupRes.rows.first.assoc();
      final idGroup = groupRow['id_group']?.toString() ?? '';
      final groupName = groupRow['group_name']?.toString() ?? '';

      // Cek apakah sudah bergabung
      bool isJoined = false;
      try {
        final memberCheck = await Database.query(
          'SELECT id_member FROM group_member WHERE id_group = :idGroup AND id_user = :idUser LIMIT 1',
          {'idGroup': idGroup, 'idUser': idUser},
        );
        isJoined = memberCheck.rows.isNotEmpty;
      } catch (e) {
        if (e.toString().contains('id_user')) {
          final memberCheck = await Database.query(
            'SELECT id_member FROM group_member WHERE id_group = :idGroup AND id_student = :idUser LIMIT 1',
            {'idGroup': idGroup, 'idUser': idUser},
          );
          isJoined = memberCheck.rows.isNotEmpty;
        } else {
          rethrow;
        }
      }

      if (isJoined) {
        return {'success': false, 'message': 'Anda sudah terdaftar sebagai anggota kelompok ini.'};
      }

      final idMember = _uuid.v4();
      try {
        await Database.query(
          'INSERT INTO group_member (id_member, id_group, id_user, role, joined_at) VALUES (:idMember, :idGroup, :idUser, :role, NOW())',
          {
            'idMember': idMember,
            'idGroup': idGroup,
            'idUser': idUser,
            'role': 'MEMBER',
          },
        );
      } catch (e) {
        if (e.toString().contains('id_user')) {
          await Database.query(
            'INSERT INTO group_member (id_member, id_group, id_student, role, joined_at) VALUES (:idMember, :idGroup, :idUser, :role, NOW())',
            {
              'idMember': idMember,
              'idGroup': idGroup,
              'idUser': idUser,
              'role': 'MEMBER',
            },
          );
        } else {
          rethrow;
        }
      }

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
      return {
        'success': false,
        'message': 'Gagal bergabung ke kelompok: $e',
      };
    }
  }
}
