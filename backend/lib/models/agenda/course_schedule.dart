import '../../config/db.dart';
import 'agenda.dart';

class CourseSchedule extends Agenda {
  final String courseCode;
  final String day;
  final String room;
  final String? idStudent;

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
    this.idStudent,
  });

  factory CourseSchedule.fromRow(Map<String, dynamic> row) {
    DateTime parseTime(String? raw) {
      if (raw == null || raw.isEmpty) return DateTime(1970, 1, 1, 0, 0);
      final parts = raw.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      return DateTime(1970, 1, 1, h, m);
    }

    return CourseSchedule(
      agendaId: row['id_agenda']?.toString() ?? '',
      idStudent: row['id_student']?.toString(),
      title: row['title']?.toString() ?? '',
      startTime: parseTime(row['start_time']?.toString()),
      endTime: parseTime(row['end_time']?.toString()),
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
      'idStudent': idStudent,
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
  static Future<List<CourseSchedule>> findByStudent(String idStudent) async {
    final results = await Database.query(
      '''
      SELECT a.id_agenda, a.id_student, a.title, a.start_time, a.end_time, a.agenda_type,
             cs.course_code, cs.day, cs.room
      FROM agenda a
      JOIN course_schedule cs ON a.id_agenda = cs.id_agenda
      WHERE a.id_student = :idStudent AND a.agenda_type = 'COURSE'
      ORDER BY FIELD(cs.day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
               a.start_time ASC
      ''',
      {'idStudent': idStudent},
    );

    return results.rows.map((r) => CourseSchedule.fromRow(r.assoc())).toList();
  }

  static Future<CourseSchedule?> findById(String idAgenda, String idStudent) async {
    final results = await Database.query(
      '''
      SELECT a.id_agenda, a.id_student, a.title, a.start_time, a.end_time, a.agenda_type,
             cs.course_code, cs.day, cs.room
      FROM agenda a
      JOIN course_schedule cs ON a.id_agenda = cs.id_agenda
      WHERE a.id_agenda = :idAgenda AND a.id_student = :idStudent
      LIMIT 1
      ''',
      {'idAgenda': idAgenda, 'idStudent': idStudent},
    );

    if (results.rows.isEmpty) return null;
    return CourseSchedule.fromRow(results.rows.first.assoc());
  }

  static Future<void> create({
    required String idAgenda,
    required String idStudent,
    required String title,
    required String startTime,
    required String endTime,
    required String courseCode,
    required String day,
    required String room,
  }) async {
    // Pastikan course ada di tabel course untuk menjaga FK
    await Database.query(
      '''
      INSERT INTO course (course_code, course_name, credits, lecturer)
      VALUES (:courseCode, :courseName, 3, 'Dosen Pengampu')
      ON DUPLICATE KEY UPDATE course_code = course_code
      ''',
      {'courseCode': courseCode, 'courseName': title},
    );

    // 1. Insert ke tabel superclass agenda
    await Database.query(
      '''
      INSERT INTO agenda (id_agenda, id_student, title, start_time, end_time, agenda_type)
      VALUES (:idAgenda, :idStudent, :title, :startTime, :endTime, 'COURSE')
      ''',
      {
        'idAgenda': idAgenda,
        'idStudent': idStudent,
        'title': title,
        'startTime': startTime,
        'endTime': endTime,
      },
    );

    // 2. Insert ke tabel subclass course_schedule
    await Database.query(
      '''
      INSERT INTO course_schedule (id_agenda, course_code, day, room)
      VALUES (:idAgenda, :courseCode, :day, :room)
      ''',
      {
        'idAgenda': idAgenda,
        'courseCode': courseCode,
        'day': day,
        'room': room,
      },
    );
  }

  static Future<void> update({
    required String idAgenda,
    required String idStudent,
    String? title,
    String? startTime,
    String? endTime,
    String? courseCode,
    String? day,
    String? room,
  }) async {
    if (courseCode != null) {
      await Database.query(
        '''
        INSERT INTO course (course_code, course_name, credits, lecturer)
        VALUES (:courseCode, :courseName, 3, 'Dosen Pengampu')
        ON DUPLICATE KEY UPDATE course_code = course_code
        ''',
        {'courseCode': courseCode, 'courseName': title ?? courseCode},
      );
    }

    if (title != null || startTime != null || endTime != null) {
      await Database.query(
        '''
        UPDATE agenda
        SET title = COALESCE(:title, title),
            start_time = COALESCE(:startTime, start_time),
            end_time = COALESCE(:endTime, end_time)
        WHERE id_agenda = :idAgenda AND id_student = :idStudent
        ''',
        {
          'idAgenda': idAgenda,
          'idStudent': idStudent,
          'title': title,
          'startTime': startTime,
          'endTime': endTime,
        },
      );
    }

    if (courseCode != null || day != null || room != null) {
      await Database.query(
        '''
        UPDATE course_schedule
        SET course_code = COALESCE(:courseCode, course_code),
            day = COALESCE(:day, day),
            room = COALESCE(:room, room)
        WHERE id_agenda = :idAgenda
        ''',
        {
          'idAgenda': idAgenda,
          'courseCode': courseCode,
          'day': day,
          'room': room,
        },
      );
    }
  }

  static Future<void> delete(String idAgenda, String idStudent) async {
    // ON DELETE CASCADE akan otomatis menghapus course_schedule ketika agenda dihapus
    await Database.query(
      'DELETE FROM agenda WHERE id_agenda = :idAgenda AND id_student = :idStudent',
      {'idAgenda': idAgenda, 'idStudent': idStudent},
    );
  }
}

