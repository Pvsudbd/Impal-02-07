import '../../config/db.dart';
import 'agenda.dart';

class CourseSchedule extends Agenda {
  final String courseCode;
  final String day;
  final String room;
  final String? idUser;

  CourseSchedule({
    required super.agendaId,
    required super.title,
    required super.startTime,
    required super.endTime,
    required super.agendaType,
    super.location = '',
    required this.courseCode,
    required this.day,
    required this.room,
    this.idUser,
    String? idStudent,
  }) : super();

  // Getter alias for backwards compatibility
  String? get idStudent => idUser;

  factory CourseSchedule.fromRow(Map<String, dynamic> row) {
    DateTime parseTime(dynamic raw) {
      if (raw == null) return DateTime(1970, 1, 1, 0, 0);
      if (raw is DateTime) return DateTime(1970, 1, 1, raw.hour, raw.minute);
      try {
        final dynamic obj = raw;
        final int? h = obj.hour as int?;
        final int? m = obj.minute as int?;
        if (h != null && m != null) {
          return DateTime(1970, 1, 1, h, m);
        }
      } catch (_) {}
      final str = raw.toString().trim();
      final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(str);
      if (timeMatch != null) {
        final h = int.tryParse(timeMatch.group(1)!) ?? 0;
        final m = int.tryParse(timeMatch.group(2)!) ?? 0;
        return DateTime(1970, 1, 1, h, m);
      }
      return DateTime(1970, 1, 1, 0, 0);
    }

    return CourseSchedule(
      agendaId: row['id_agenda']?.toString() ?? '',
      idUser: (row['id_user'] ?? row['id_student'])?.toString(),
      title: row['title']?.toString() ?? '',
      startTime: parseTime(row['start_time']),
      endTime: parseTime(row['end_time']),
      agendaType: 'COURSE',
      courseCode: row['course_code']?.toString() ?? '',
      day: row['day']?.toString() ?? '',
      room: row['room']?.toString() ?? '',
      location: row['room']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    String fmt(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return {
      'id': agendaId,
      'idAgenda': agendaId,
      'idUser': idUser,
      'idStudent': idUser, // compatibility
      'title': title,
      'type': 'Lecture',
      'agendaType': agendaType,
      'timeStart': fmt(startTime),
      'timeEnd': fmt(endTime),
      'timezone': 'WIB',
      'timeZone': 'WIB',
      'course': courseCode,
      'courseCode': courseCode,
      'day': day,
      'room': room,
      'location': room,
      'repeat': true,
    };
  }

  String getScheduleDetails() {
    return '$title ($courseCode) - $day di $room';
  }

  bool isToday(String dayName) {
    return day.toLowerCase() == dayName.toLowerCase();
  }

  // Database operations
  static Future<List<CourseSchedule>> findByUser(String idUser) async {
    const sql = '''
      SELECT a.id_agenda, a.id_user, a.title, a.start_time, a.end_time, a.agenda_type,
             cs.course_code, cs.day, cs.room
      FROM agenda a
      JOIN course_schedule cs ON a.id_agenda = cs.id_agenda
      WHERE a.id_user = :idUser AND a.agenda_type = 'COURSE'
      ORDER BY CASE cs.day
        WHEN 'Monday' THEN 1 WHEN 'Senin' THEN 1
        WHEN 'Tuesday' THEN 2 WHEN 'Selasa' THEN 2
        WHEN 'Wednesday' THEN 3 WHEN 'Rabu' THEN 3
        WHEN 'Thursday' THEN 4 WHEN 'Kamis' THEN 4
        WHEN 'Friday' THEN 5 WHEN 'Jumat' THEN 5
        WHEN 'Saturday' THEN 6 WHEN 'Sabtu' THEN 6
        WHEN 'Sunday' THEN 7 WHEN 'Minggu' THEN 7
        ELSE 8 END,
        a.start_time ASC
    ''';

    try {
      final results = await Database.query(sql, {'idUser': idUser});
      return results.rows.map((r) => CourseSchedule.fromRow(r.assoc())).toList();
    } catch (e) {
      if (e.toString().contains('id_user')) {
        final fallbackSql = sql.replaceAll('a.id_user', 'a.id_student');
        final results = await Database.query(fallbackSql, {'idUser': idUser});
        return results.rows.map((r) => CourseSchedule.fromRow(r.assoc())).toList();
      }
      rethrow;
    }
  }

  // Backwards compatible alias
  static Future<List<CourseSchedule>> findByStudent(String idStudent) => findByUser(idStudent);

  static Future<CourseSchedule?> findById(String idAgenda, String idUser) async {
    const sql = '''
      SELECT a.id_agenda, a.id_user, a.title, a.start_time, a.end_time, a.agenda_type,
             cs.course_code, cs.day, cs.room
      FROM agenda a
      JOIN course_schedule cs ON a.id_agenda = cs.id_agenda
      WHERE a.id_agenda = :idAgenda AND a.id_user = :idUser
      LIMIT 1
    ''';

    try {
      final results = await Database.query(sql, {'idAgenda': idAgenda, 'idUser': idUser});
      if (results.rows.isEmpty) return null;
      return CourseSchedule.fromRow(results.rows.first.assoc());
    } catch (e) {
      if (e.toString().contains('id_user')) {
        final fallbackSql = sql.replaceAll('a.id_user', 'a.id_student');
        final results = await Database.query(fallbackSql, {'idAgenda': idAgenda, 'idUser': idUser});
        if (results.rows.isEmpty) return null;
        return CourseSchedule.fromRow(results.rows.first.assoc());
      }
      rethrow;
    }
  }

  static String _normalizeDay(String raw) {
    final lower = raw.trim().toLowerCase();
    switch (lower) {
      case 'monday': return 'Senin';
      case 'tuesday': return 'Selasa';
      case 'wednesday': return 'Rabu';
      case 'thursday': return 'Kamis';
      case 'friday': return 'Jumat';
      case 'saturday': return 'Sabtu';
      case 'sunday': return 'Minggu';
      default: return raw.trim();
    }
  }

  static Future<void> create({
    required String idAgenda,
    required String idUser,
    String? idStudent,
    required String title,
    required String startTime,
    required String endTime,
    required String courseCode,
    required String day,
    required String room,
  }) async {
    final userId = idUser;

    // Pastikan courseCode aman dan tidak melebihi kapasitas kolom VARCHAR(20)
    final safeCode = (courseCode.trim().isEmpty ? 'GEN-${DateTime.now().millisecondsSinceEpoch % 10000}' : courseCode.trim());
    final finalCode = safeCode.length > 20 ? safeCode.substring(0, 20) : safeCode;
    final finalTitle = title.length > 100 ? title.substring(0, 100) : title;
    final finalDay = _normalizeDay(day);

    // Pastikan course ada di tabel course tanpa ON CONFLICT (menghindari error 42P10)
    final existingCourse = await Database.query(
      'SELECT course_code FROM course WHERE course_code = :courseCode LIMIT 1',
      {'courseCode': finalCode},
    );
    if (existingCourse.rows.isEmpty) {
      await Database.query(
        '''
        INSERT INTO course (course_code, course_name, credits, lecturer)
        VALUES (:courseCode, :courseName, 3, 'Dosen Pengampu')
        ''',
        {'courseCode': finalCode, 'courseName': finalTitle},
      );
    }

    // 1. Insert ke tabel superclass agenda (prioritaskan id_student untuk skema PostgreSQL saat ini)
    try {
      await Database.query(
        '''
        INSERT INTO agenda (id_agenda, id_student, title, start_time, end_time, agenda_type)
        VALUES (:idAgenda, :idUser, :title, :startTime::time, :endTime::time, 'COURSE')
        ''',
        {
          'idAgenda': idAgenda,
          'idUser': userId,
          'title': title,
          'startTime': startTime,
          'endTime': endTime,
        },
      );
    } catch (e) {
      if (e.toString().contains('id_student')) {
        await Database.query(
          '''
          INSERT INTO agenda (id_agenda, id_user, title, start_time, end_time, agenda_type)
          VALUES (:idAgenda, :idUser, :title, :startTime::time, :endTime::time, 'COURSE')
          ''',
          {
            'idAgenda': idAgenda,
            'idUser': userId,
            'title': title,
            'startTime': startTime,
            'endTime': endTime,
          },
        );
      } else {
        rethrow;
      }
    }

    // 2. Insert ke tabel subclass course_schedule
    await Database.query(
      '''
      INSERT INTO course_schedule (id_agenda, course_code, day, room)
      VALUES (:idAgenda, :courseCode, :day, :room)
      ''',
      {
        'idAgenda': idAgenda,
        'courseCode': finalCode,
        'day': finalDay,
        'room': room,
      },
    );
  }

  static Future<void> update({
    required String idAgenda,
    required String idUser,
    String? idStudent,
    String? title,
    String? startTime,
    String? endTime,
    String? courseCode,
    String? day,
    String? room,
  }) async {
    final userId = idUser;

    // 🛡️ BOLA / IDOR Protection: Verifikasi kepemilikan agenda sebelum update
    final existing = await findById(idAgenda, userId);
    if (existing == null) {
      throw Exception('Jadwal kuliah tidak ditemukan atau bukan milik Anda.');
    }

    if (courseCode != null) {
      final safeCode = courseCode.trim().length > 20 ? courseCode.trim().substring(0, 20) : courseCode.trim();
      final existingCourse = await Database.query(
        'SELECT course_code FROM course WHERE course_code = :courseCode LIMIT 1',
        {'courseCode': safeCode},
      );
      if (existingCourse.rows.isEmpty) {
        await Database.query(
          '''
          INSERT INTO course (course_code, course_name, credits, lecturer)
          VALUES (:courseCode, :courseName, 3, 'Dosen Pengampu')
          ''',
          {'courseCode': safeCode, 'courseName': (title ?? safeCode).length > 100 ? (title ?? safeCode).substring(0, 100) : (title ?? safeCode)},
        );
      }
    }

    final agendaUpdates = <String>[];
    final agendaParams = <String, dynamic>{
      'idAgenda': idAgenda,
      'idUser': userId,
    };

    if (title != null) {
      agendaUpdates.add('title = :title');
      agendaParams['title'] = title;
    }
    if (startTime != null) {
      agendaUpdates.add('start_time = :startTime::time');
      agendaParams['startTime'] = startTime;
    }
    if (endTime != null) {
      agendaUpdates.add('end_time = :endTime::time');
      agendaParams['endTime'] = endTime;
    }

    if (agendaUpdates.isNotEmpty) {
      try {
        await Database.query(
          'UPDATE agenda SET ${agendaUpdates.join(', ')} WHERE id_agenda = :idAgenda AND id_user = :idUser',
          agendaParams,
        );
      } catch (e) {
        if (e.toString().contains('id_user')) {
          await Database.query(
            'UPDATE agenda SET ${agendaUpdates.join(', ')} WHERE id_agenda = :idAgenda AND id_student = :idUser',
            agendaParams,
          );
        } else {
          rethrow;
        }
      }
    }

    final csUpdates = <String>[];
    final csParams = <String, dynamic>{
      'idAgenda': idAgenda,
      'idUser': userId,
    };

    if (courseCode != null) {
      csUpdates.add('course_code = :courseCode');
      csParams['courseCode'] = courseCode;
    }
    if (day != null) {
      csUpdates.add('day = :day');
      csParams['day'] = day;
    }
    if (room != null) {
      csUpdates.add('room = :room');
      csParams['room'] = room;
    }

    if (csUpdates.isNotEmpty) {
      try {
        await Database.query(
          'UPDATE course_schedule SET ${csUpdates.join(', ')} WHERE id_agenda = :idAgenda AND id_agenda IN (SELECT id_agenda FROM agenda WHERE id_user = :idUser)',
          csParams,
        );
      } catch (e) {
        if (e.toString().contains('id_user')) {
          await Database.query(
            'UPDATE course_schedule SET ${csUpdates.join(', ')} WHERE id_agenda = :idAgenda AND id_agenda IN (SELECT id_agenda FROM agenda WHERE id_student = :idUser)',
            csParams,
          );
        } else {
          rethrow;
        }
      }
    }
  }

  static Future<void> delete(String idAgenda, String idUser) async {
    try {
      await Database.query(
        'DELETE FROM agenda WHERE id_agenda = :idAgenda AND id_user = :idUser',
        {'idAgenda': idAgenda, 'idUser': idUser},
      );
    } catch (e) {
      if (e.toString().contains('id_user')) {
        await Database.query(
          'DELETE FROM agenda WHERE id_agenda = :idAgenda AND id_student = :idUser',
          {'idAgenda': idAgenda, 'idUser': idUser},
        );
      } else {
        rethrow;
      }
    }
  }
}
