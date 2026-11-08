import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';
import '../../config/db.dart';

/// Model representing a Student's Profile and academic methods per Class Diagram.
/// Class Diagram reference: `Student` in `Class_Diagram.md`
/// Database table reference: `student` in `Entity_Relationship_Diagram.md`
class ProfileModel {
  static const _uuid = Uuid();

  final String idStudent;
  final String name;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Academic Statistics
  final int tasksDoneCount;
  final int tasksPendingCount;
  final int schedulesCount;
  final int coursesCount;
  final int groupsCount;

  ProfileModel({
    required this.idStudent,
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

  Map<String, dynamic> toJson() {
    return {
      'idStudent': idStudent,
      'studentId': idStudent,
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

  // ─── GET STUDENT PROFILE BY ID ─────────────────────────────────────────────
  static Future<ProfileModel?> getProfile(String idStudent) async {
    final results = await Database.query(
      'SELECT id_student, name, email, created_at, updated_at FROM student WHERE id_student = :idStudent LIMIT 1',
      {'idStudent': idStudent},
    );

    if (results.rows.isEmpty) return null;
    final row = results.rows.first.assoc();

    int tasksDone = 0;
    int tasksPending = 0;
    int schedules = 0;
    int courses = 0;
    int groups = 0;

    // Hitung statistik tugas jika tabel task tersedia
    try {
      final taskDoneRes = await Database.query(
        'SELECT COUNT(*) AS total FROM task WHERE id_student = :idStudent AND is_completed = 1',
        {'idStudent': idStudent},
      );
      if (taskDoneRes.rows.isNotEmpty) {
        tasksDone = int.tryParse(taskDoneRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
      }

      final taskPendingRes = await Database.query(
        'SELECT COUNT(*) AS total FROM task WHERE id_student = :idStudent AND is_completed = 0',
        {'idStudent': idStudent},
      );
      if (taskPendingRes.rows.isNotEmpty) {
        tasksPending = int.tryParse(taskPendingRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
      }
    } catch (_) {}

    // Hitung statistik jadwal & kuliah
    try {
      final schedRes = await Database.query(
        'SELECT COUNT(*) AS total FROM agenda WHERE id_student = :idStudent',
        {'idStudent': idStudent},
      );
      if (schedRes.rows.isNotEmpty) {
        schedules = int.tryParse(schedRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
      }

      final courseRes = await Database.query(
        'SELECT COUNT(DISTINCT cs.course_code) AS total FROM course_schedule cs JOIN agenda a ON cs.id_agenda = a.id_agenda WHERE a.id_student = :idStudent',
        {'idStudent': idStudent},
      );
      if (courseRes.rows.isNotEmpty) {
        courses = int.tryParse(courseRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
      }
    } catch (_) {}

    // Hitung grup yang diikuti
    try {
      final groupRes = await Database.query(
        'SELECT COUNT(*) AS total FROM group_member WHERE id_student = :idStudent',
        {'idStudent': idStudent},
      );
      if (groupRes.rows.isNotEmpty) {
        groups = int.tryParse(groupRes.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
      }
    } catch (_) {}

    return ProfileModel(
      idStudent: row['id_student']?.toString() ?? '',
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
    String idStudent, {
    required String name,
    String? email,
  }) async {
    final params = <String, dynamic>{
      'idStudent': idStudent,
      'name': name.trim(),
    };

    String sql = 'UPDATE student SET name = :name';
    if (email != null && email.trim().isNotEmpty) {
      // 🛡️ Verifikasi keunikan email sebelum update
      final existing = await Database.query(
        'SELECT id_student FROM student WHERE email = :email AND id_student != :idStudent LIMIT 1',
        {'email': email.trim(), 'idStudent': idStudent},
      );
      if (existing.rows.isNotEmpty) {
        throw Exception('Email sudah digunakan oleh akun mahasiswa lain.');
      }
      sql += ', email = :email';
      params['email'] = email.trim();
    }
    sql += ', updated_at = NOW() WHERE id_student = :idStudent';

    await Database.query(sql, params);
    return true;
  }

  // ─── CHANGE PASSWORD ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> changePassword(
    String idStudent, {
    required String currentPassword,
    required String newPassword,
  }) async {
    final results = await Database.query(
      'SELECT password_hash FROM student WHERE id_student = :idStudent LIMIT 1',
      {'idStudent': idStudent},
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
      'UPDATE student SET password_hash = :newHash, updated_at = NOW() WHERE id_student = :idStudent',
      {
        'idStudent': idStudent,
        'newHash': newHash,
      },
    );

    return {'success': true, 'message': 'Password berhasil diperbarui.'};
  }

  // ─── CLASS DIAGRAM METHOD: viewDailyAgenda(date: Date) ─────────────────────
  static Future<List<Map<String, dynamic>>> viewDailyAgenda(
    String idStudent,
    DateTime date,
  ) async {
    final dateStr = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = days[date.weekday - 1];

    final sql = '''
      SELECT 
        a.id_agenda,
        a.title,
        TIME_FORMAT(a.start_time, '%H:%i') AS start_time,
        TIME_FORMAT(a.end_time, '%H:%i') AS end_time,
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
      WHERE a.id_student = :idStudent
        AND (ps.date = :dateStr OR (a.agenda_type = 'COURSE' AND cs.day = :dayName))
      ORDER BY a.start_time ASC
    ''';

    final results = await Database.query(sql, {
      'idStudent': idStudent,
      'dateStr': dateStr,
      'dayName': dayName,
    });

    return results.rows.map((r) => r.assoc()).toList();
  }

  // ─── CLASS DIAGRAM METHOD: viewCourseSchedule() ────────────────────────────
  static Future<List<Map<String, dynamic>>> viewCourseSchedule(String idStudent) async {
    final sql = '''
      SELECT 
        a.id_agenda,
        a.title,
        TIME_FORMAT(a.start_time, '%H:%i') AS start_time,
        TIME_FORMAT(a.end_time, '%H:%i') AS end_time,
        cs.course_code,
        cs.day,
        cs.room,
        c.course_name,
        c.credits,
        c.lecturer
      FROM course_schedule cs
      JOIN agenda a ON cs.id_agenda = a.id_agenda
      LEFT JOIN course c ON cs.course_code = c.course_code
      WHERE a.id_student = :idStudent
      ORDER BY FIELD(cs.day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'), a.start_time ASC
    ''';

    final results = await Database.query(sql, {'idStudent': idStudent});
    return results.rows.map((r) => r.assoc()).toList();
  }

  // ─── CLASS DIAGRAM METHOD: viewRemainingTasks() ────────────────────────────
  static Future<List<Map<String, dynamic>>> viewRemainingTasks(String idStudent) async {
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
        WHERE id_student = :idStudent AND is_completed = 0
        ORDER BY deadline ASC
      ''';

      final results = await Database.query(sql, {'idStudent': idStudent});
      return results.rows.map((r) => r.assoc()).toList();
    } catch (_) {
      return [];
    }
  }

  // ─── CLASS DIAGRAM METHOD: joinGroup(inviteCode: String) ───────────────────
  static Future<Map<String, dynamic>> joinGroup(
    String idStudent,
    String inviteCode,
  ) async {
    try {
      final groupRes = await Database.query(
        'SELECT id_group, group_name FROM study_group WHERE invite_code = :inviteCode LIMIT 1',
        {'inviteCode': inviteCode.trim().toUpperCase()},
      );

      if (groupRes.rows.isEmpty) {
        return {'success': false, 'message': 'Kode undangan kelompok tidak ditemukan.'};
      }

      final groupRow = groupRes.rows.first.assoc();
      final idGroup = groupRow['id_group']?.toString() ?? '';
      final groupName = groupRow['group_name']?.toString() ?? '';

      // Cek apakah sudah bergabung
      final memberCheck = await Database.query(
        'SELECT id_member FROM group_member WHERE id_group = :idGroup AND id_student = :idStudent LIMIT 1',
        {'idGroup': idGroup, 'idStudent': idStudent},
      );

      if (memberCheck.rows.isNotEmpty) {
        return {'success': false, 'message': 'Anda sudah terdaftar sebagai anggota kelompok ini.'};
      }

      final idMember = _uuid.v4();
      await Database.query(
        'INSERT INTO group_member (id_member, id_group, id_student, role, joined_at) VALUES (:idMember, :idGroup, :idStudent, :role, NOW())',
        {
          'idMember': idMember,
          'idGroup': idGroup,
          'idStudent': idStudent,
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
      return {
        'success': false,
        'message': 'Gagal bergabung ke kelompok: $e',
      };
    }
  }
}

