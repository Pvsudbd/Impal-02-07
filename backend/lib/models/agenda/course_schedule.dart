import '../../config/db.dart';
import '../course/course_model.dart';
import 'agenda.dart';

class CourseSchedule extends Agenda {
  final String idCourse;
  final String courseName;
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
    required this.idCourse,
    required this.courseName,
    required this.day,
    required this.room,
    this.idUser,
    String? idStudent,
  }) : super();

  // Getter aliases for backwards compatibility
  String? get idStudent => idUser;
  String get course => courseName;

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

    final resolvedTitle = row['title']?.toString() ?? '';
    final resolvedCourseName =
        (row['course_name'] ?? row['title'])?.toString() ?? resolvedTitle;

    return CourseSchedule(
      agendaId: row['id_agenda']?.toString() ?? '',
      idUser: row['id_user']?.toString(),
      title: resolvedTitle,
      startTime: parseTime(row['start_time']),
      endTime: parseTime(row['end_time']),
      agendaType: 'COURSE',
      idCourse: row['id_course']?.toString() ?? '',
      courseName: resolvedCourseName,
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
      'idCourse': idCourse,
      'courseName': courseName,
      'course': courseName,
      'day': day,
      'room': room,
      'location': room,
      'repeat': true,
    };
  }

  String getScheduleDetails() {
    return '$title ($courseName) - $day di $room';
  }

  bool isToday(String dayName) {
    return day.toLowerCase() == dayName.toLowerCase();
  }

  static String _normalizeDay(String raw) {
    final lower = raw.trim().toLowerCase();
    switch (lower) {
      case 'monday':
      case 'senin':
        return 'Senin';
      case 'tuesday':
      case 'selasa':
        return 'Selasa';
      case 'wednesday':
      case 'rabu':
        return 'Rabu';
      case 'thursday':
      case 'kamis':
        return 'Kamis';
      case 'friday':
      case 'jumat':
        return 'Jumat';
      case 'saturday':
      case 'sabtu':
        return 'Sabtu';
      case 'sunday':
      case 'minggu':
        return 'Minggu';
      default:
        return raw.trim();
    }
  }

  // Database operations
  static Future<List<CourseSchedule>> findByUser(String idUser) async {
    const sql = '''
      SELECT a.id_agenda, a.id_user, a.title, a.start_time, a.end_time, a.agenda_type,
             cs.id_course, COALESCE(c.course_name, a.title) AS course_name,
             cs.day, cs.room
      FROM agenda a
      JOIN course_schedule cs ON a.id_agenda = cs.id_agenda
      LEFT JOIN course c ON cs.id_course = c.id_course
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

    final results = await Database.query(sql, {'idUser': idUser});
    return results.rows.map((r) => CourseSchedule.fromRow(r.assoc())).toList();
  }

  // Backwards compatible alias
  static Future<List<CourseSchedule>> findByStudent(String idStudent) =>
      findByUser(idStudent);

  static Future<CourseSchedule?> findById(String idAgenda, String idUser) async {
    const sql = '''
      SELECT a.id_agenda, a.id_user, a.title, a.start_time, a.end_time, a.agenda_type,
             cs.id_course, COALESCE(c.course_name, a.title) AS course_name,
             cs.day, cs.room
      FROM agenda a
      JOIN course_schedule cs ON a.id_agenda = cs.id_agenda
      LEFT JOIN course c ON cs.id_course = c.id_course
      WHERE a.id_agenda = :idAgenda AND a.id_user = :idUser
      LIMIT 1
    ''';

    final results = await Database.query(sql, {
      'idAgenda': idAgenda,
      'idUser': idUser,
    });
    if (results.rows.isEmpty) return null;
    return CourseSchedule.fromRow(results.rows.first.assoc());
  }

  /// Detects overlapping course schedules for the user on the same day.
  static Future<List<CourseSchedule>> findConflicts(
    String idUser,
    String day,
    String startTime,
    String endTime, {
    String? excludeIdAgenda,
  }) async {
    final normalizedDay = _normalizeDay(day);
    final params = <String, dynamic>{
      'idUser': idUser,
      'day': normalizedDay,
      'startTime': startTime,
      'endTime': endTime,
    };

    var sql = '''
      SELECT a.id_agenda, a.id_user, a.title, a.start_time, a.end_time, a.agenda_type,
             cs.id_course, COALESCE(c.course_name, a.title) AS course_name,
             cs.day, cs.room
      FROM agenda a
      JOIN course_schedule cs ON a.id_agenda = cs.id_agenda
      LEFT JOIN course c ON cs.id_course = c.id_course
      WHERE a.id_user = :idUser
        AND a.agenda_type = 'COURSE'
        AND cs.day = :day
        AND a.start_time < :endTime::time
        AND a.end_time > :startTime::time
    ''';

    if (excludeIdAgenda != null && excludeIdAgenda.isNotEmpty) {
      sql += ' AND a.id_agenda != :excludeIdAgenda';
      params['excludeIdAgenda'] = excludeIdAgenda;
    }

    sql += ' ORDER BY a.start_time ASC';
    final results = await Database.query(sql, params);
    return results.rows.map((r) => CourseSchedule.fromRow(r.assoc())).toList();
  }

  static Future<void> create({
    required String idAgenda,
    required String idUser,
    String? idStudent,
    required String title,
    required String startTime,
    required String endTime,
    String? idCourse,
    String? courseName,
    required String day,
    required String room,
  }) async {
    final agendaTitle = title.trim().length > 150
        ? title.trim().substring(0, 150)
        : title.trim();
    final effectiveCourseName =
        (courseName != null && courseName.trim().isNotEmpty)
            ? courseName.trim()
            : agendaTitle;
    final finalDay = _normalizeDay(day);
    final finalRoom = room.trim().length > 50
        ? room.trim().substring(0, 50)
        : room.trim();

    await Database.transaction((tx) async {
      final resolvedCourseId = await CourseModel.resolveOrCreateForSchedule(
        tx,
        idUser: idUser,
        idCourse: idCourse,
        courseName: effectiveCourseName,
      );

      await tx.query(
        '''
        INSERT INTO agenda (id_agenda, id_user, title, start_time, end_time, agenda_type, created_at, updated_at)
        VALUES (:idAgenda, :idUser, :title, :startTime::time, :endTime::time, 'COURSE', NOW(), NOW())
        ''',
        {
          'idAgenda': idAgenda,
          'idUser': idUser,
          'title': agendaTitle,
          'startTime': startTime,
          'endTime': endTime,
        },
      );

      await tx.query(
        '''
        INSERT INTO course_schedule (id_agenda, id_course, day, room)
        VALUES (:idAgenda, :idCourse, :day, :room)
        ''',
        {
          'idAgenda': idAgenda,
          'idCourse': resolvedCourseId,
          'day': finalDay,
          'room': finalRoom,
        },
      );
    });
  }

  static Future<void> update({
    required String idAgenda,
    required String idUser,
    String? idStudent,
    String? title,
    String? startTime,
    String? endTime,
    String? idCourse,
    String? courseName,
    String? day,
    String? room,
  }) async {
    // BOLA / IDOR Protection: verify ownership before update
    final existing = await findById(idAgenda, idUser);
    if (existing == null) {
      throw Exception('Jadwal kuliah tidak ditemukan atau bukan milik Anda.');
    }

    final normalizedDay = day != null ? _normalizeDay(day) : null;
    final safeTitle = title != null
        ? (title.trim().length > 150 ? title.trim().substring(0, 150) : title.trim())
        : null;
    final safeRoom = room != null
        ? (room.trim().length > 50 ? room.trim().substring(0, 50) : room.trim())
        : null;

    await Database.transaction((tx) async {
      String? resolvedCourseId;
      final hasIdCourse = idCourse != null && idCourse.trim().isNotEmpty;
      final hasCourseName = courseName != null && courseName.trim().isNotEmpty;
      if (hasIdCourse || hasCourseName) {
        resolvedCourseId = await CourseModel.resolveOrCreateForSchedule(
          tx,
          idUser: idUser,
          idCourse: idCourse,
          courseName: courseName,
        );
      }

      final agendaUpdates = <String>[];
      final agendaParams = <String, dynamic>{
        'idAgenda': idAgenda,
        'idUser': idUser,
      };

      if (safeTitle != null) {
        agendaUpdates.add('title = :title');
        agendaParams['title'] = safeTitle;
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
        agendaUpdates.add('updated_at = NOW()');
        await tx.query(
          'UPDATE agenda SET ${agendaUpdates.join(', ')} '
          'WHERE id_agenda = :idAgenda AND id_user = :idUser',
          agendaParams,
        );
      }

      final csUpdates = <String>[];
      final csParams = <String, dynamic>{'idAgenda': idAgenda};

      if (resolvedCourseId != null) {
        csUpdates.add('id_course = :idCourse');
        csParams['idCourse'] = resolvedCourseId;
      }
      if (normalizedDay != null) {
        csUpdates.add('day = :day');
        csParams['day'] = normalizedDay;
      }
      if (safeRoom != null) {
        csUpdates.add('room = :room');
        csParams['room'] = safeRoom;
      }

      if (csUpdates.isNotEmpty) {
        await tx.query(
          'UPDATE course_schedule SET ${csUpdates.join(', ')} '
          'WHERE id_agenda = :idAgenda',
          csParams,
        );
      }

      if (resolvedCourseId != null && resolvedCourseId != existing.idCourse) {
        await CourseModel.cleanupUnusedCustomCourse(
          tx,
          idCourse: existing.idCourse,
          idUser: idUser,
        );
      }
    });
  }

  static Future<void> delete(String idAgenda, String idUser) async {
    await Database.transaction((tx) async {
      final owned = await tx.query(
        '''
        SELECT cs.id_course
        FROM agenda a
        LEFT JOIN course_schedule cs ON a.id_agenda = cs.id_agenda
        WHERE a.id_agenda = :idAgenda AND a.id_user = :idUser
        LIMIT 1
        ''',
        {'idAgenda': idAgenda, 'idUser': idUser},
      );
      if (owned.rows.isEmpty) return;

      final oldCourseId = owned.rows.first.assoc()['id_course']?.toString();

      // Delete child first because legacy live DB tables lack ON DELETE CASCADE FK
      await tx.query(
        'DELETE FROM course_schedule WHERE id_agenda = :idAgenda',
        {'idAgenda': idAgenda},
      );
      await tx.query(
        'DELETE FROM agenda WHERE id_agenda = :idAgenda AND id_user = :idUser',
        {'idAgenda': idAgenda, 'idUser': idUser},
      );

      if (oldCourseId != null && oldCourseId.isNotEmpty) {
        await CourseModel.cleanupUnusedCustomCourse(
          tx,
          idCourse: oldCourseId,
          idUser: idUser,
        );
      }
    });
  }
}
