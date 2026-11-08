import '../../config/db.dart';
import 'agenda.dart';

class PersonalSchedule extends Agenda {
  final DateTime date;
  final String category;
  final String? notes;
  final String? idStudent;

  PersonalSchedule({
    required super.agendaId,
    required super.title,
    required super.startTime,
    required super.endTime,
    required super.agendaType,
    super.location = '',
    required this.date,
    required this.category,
    this.notes,
    this.idStudent,
  });

  factory PersonalSchedule.fromRow(Map<String, dynamic> row) {
    DateTime parseTime(String? raw) {
      if (raw == null || raw.isEmpty) return DateTime(1970, 1, 1, 0, 0);
      final parts = raw.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      return DateTime(1970, 1, 1, h, m);
    }

    DateTime parseDate(String? raw) {
      if (raw == null || raw.isEmpty) return DateTime.now();
      return DateTime.tryParse(raw) ?? DateTime.now();
    }

    return PersonalSchedule(
      agendaId: row['id_agenda']?.toString() ?? '',
      idStudent: row['id_student']?.toString(),
      title: row['title']?.toString() ?? '',
      startTime: parseTime(row['start_time']?.toString()),
      endTime: parseTime(row['end_time']?.toString()),
      agendaType: 'PERSONAL',
      date: parseDate(row['date']?.toString()),
      category: row['category']?.toString() ?? 'Personal',
      location: row['location']?.toString() ?? '',
      notes: row['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    String fmt(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    String fmtDate(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return {
      'id': agendaId,
      'idAgenda': agendaId,
      'idStudent': idStudent,
      'title': title,
      'type': 'External',
      'agendaType': agendaType,
      'timeStart': fmt(startTime),
      'timeEnd': fmt(endTime),
      'timezone': 'WIB',
      'timeZone': 'WIB',
      'date': fmtDate(date),
      'category': category,
      'location': location,
      'notes': notes,
      'repeat': false,
    };
  }

  String getAgendaDetails() {
    return '[$category] $title: ${notes ?? ''}';
  }

  // Database operations
  static Future<List<PersonalSchedule>> findByStudent(String idStudent) async {
    final results = await Database.query(
      '''
      SELECT a.id_agenda, a.id_student, a.title, a.start_time, a.end_time, a.agenda_type,
             ps.date, ps.category, ps.location, ps.notes
      FROM agenda a
      JOIN personal_schedule ps ON a.id_agenda = ps.id_agenda
      WHERE a.id_student = :idStudent AND a.agenda_type = 'PERSONAL'
      ORDER BY ps.date ASC, a.start_time ASC
      ''',
      {'idStudent': idStudent},
    );

    return results.rows.map((r) => PersonalSchedule.fromRow(r.assoc())).toList();
  }

  static Future<PersonalSchedule?> findById(String idAgenda, String idStudent) async {
    final results = await Database.query(
      '''
      SELECT a.id_agenda, a.id_student, a.title, a.start_time, a.end_time, a.agenda_type,
             ps.date, ps.category, ps.location, ps.notes
      FROM agenda a
      JOIN personal_schedule ps ON a.id_agenda = ps.id_agenda
      WHERE a.id_agenda = :idAgenda AND a.id_student = :idStudent
      LIMIT 1
      ''',
      {'idAgenda': idAgenda, 'idStudent': idStudent},
    );

    if (results.rows.isEmpty) return null;
    return PersonalSchedule.fromRow(results.rows.first.assoc());
  }

  static Future<void> create({
    required String idAgenda,
    required String idStudent,
    required String title,
    required String startTime,
    required String endTime,
    required String date,
    required String category,
    String? location,
    String? notes,
  }) async {
    // 1. Insert ke tabel superclass agenda
    await Database.query(
      '''
      INSERT INTO agenda (id_agenda, id_student, title, start_time, end_time, agenda_type)
      VALUES (:idAgenda, :idStudent, :title, :startTime, :endTime, 'PERSONAL')
      ''',
      {
        'idAgenda': idAgenda,
        'idStudent': idStudent,
        'title': title,
        'startTime': startTime,
        'endTime': endTime,
      },
    );

    // 2. Insert ke tabel subclass personal_schedule
    await Database.query(
      '''
      INSERT INTO personal_schedule (id_agenda, date, category, location, notes)
      VALUES (:idAgenda, :date, :category, :location, :notes)
      ''',
      {
        'idAgenda': idAgenda,
        'date': date,
        'category': category,
        'location': location ?? '',
        'notes': notes ?? '',
      },
    );
  }

  static Future<void> update({
    required String idAgenda,
    required String idStudent,
    String? title,
    String? startTime,
    String? endTime,
    String? date,
    String? category,
    String? location,
    String? notes,
  }) async {
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

    if (date != null || category != null || location != null || notes != null) {
      await Database.query(
        '''
        UPDATE personal_schedule
        SET date = COALESCE(:date, date),
            category = COALESCE(:category, category),
            location = COALESCE(:location, location),
            notes = COALESCE(:notes, notes)
        WHERE id_agenda = :idAgenda
        ''',
        {
          'idAgenda': idAgenda,
          'date': date,
          'category': category,
          'location': location,
          'notes': notes,
        },
      );
    }
  }

  static Future<void> delete(String idAgenda, String idStudent) async {
    await Database.query(
      'DELETE FROM agenda WHERE id_agenda = :idAgenda AND id_student = :idStudent',
      {'idAgenda': idAgenda, 'idStudent': idStudent},
    );
  }
}

