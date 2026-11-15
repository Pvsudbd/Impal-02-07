import '../../config/db.dart';
import 'agenda.dart';

class PersonalSchedule extends Agenda {
  final DateTime date;
  final String category;
  final String? notes;
  final String? idUser;

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
    this.idUser,
    String? idStudent,
  }) : super();

  // Getter alias for backwards compatibility
  String? get idStudent => idUser;

  factory PersonalSchedule.fromRow(Map<String, dynamic> row) {
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

    DateTime parseDate(dynamic raw) {
      if (raw == null) return DateTime.now();
      if (raw is DateTime) return raw;
      final str = raw.toString().trim();
      return DateTime.tryParse(str) ?? DateTime.now();
    }

    return PersonalSchedule(
      agendaId: row['id_agenda']?.toString() ?? '',
      idUser: (row['id_user'] ?? row['id_student'])?.toString(),
      title: row['title']?.toString() ?? '',
      startTime: parseTime(row['start_time']),
      endTime: parseTime(row['end_time']),
      agendaType: 'PERSONAL',
      date: parseDate(row['date']),
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

    final catLower = category.toLowerCase();
    final locLower = location.toLowerCase();
    final resolvedType = (catLower == 'meeting' || locLower.contains('meet') || locLower.contains('zoom') || locLower.contains('team'))
        ? 'Meeting'
        : 'External';

    return {
      'id': agendaId,
      'idAgenda': agendaId,
      'idUser': idUser,
      'idStudent': idUser, // compatibility
      'title': title,
      'type': resolvedType,
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
  static Future<List<PersonalSchedule>> findByUser(String idUser) async {
    const sql = '''
      SELECT a.id_agenda, a.id_user, a.title, a.start_time, a.end_time, a.agenda_type,
             ps.date, ps.category, ps.location, ps.notes
      FROM agenda a
      JOIN personal_schedule ps ON a.id_agenda = ps.id_agenda
      WHERE a.id_user = :idUser AND a.agenda_type = 'PERSONAL'
      ORDER BY ps.date ASC, a.start_time ASC
    ''';

    try {
      final results = await Database.query(sql, {'idUser': idUser});
      return results.rows.map((r) => PersonalSchedule.fromRow(r.assoc())).toList();
    } catch (e) {
      if (e.toString().contains('id_user')) {
        final fallbackSql = sql.replaceAll('a.id_user', 'a.id_student');
        final results = await Database.query(fallbackSql, {'idUser': idUser});
        return results.rows.map((r) => PersonalSchedule.fromRow(r.assoc())).toList();
      }
      rethrow;
    }
  }

  // Backwards compatible alias
  static Future<List<PersonalSchedule>> findByStudent(String idStudent) => findByUser(idStudent);

  static Future<PersonalSchedule?> findById(String idAgenda, String idUser) async {
    const sql = '''
      SELECT a.id_agenda, a.id_user, a.title, a.start_time, a.end_time, a.agenda_type,
             ps.date, ps.category, ps.location, ps.notes
      FROM agenda a
      JOIN personal_schedule ps ON a.id_agenda = ps.id_agenda
      WHERE a.id_agenda = :idAgenda AND a.id_user = :idUser
      LIMIT 1
    ''';

    try {
      final results = await Database.query(sql, {'idAgenda': idAgenda, 'idUser': idUser});
      if (results.rows.isEmpty) return null;
      return PersonalSchedule.fromRow(results.rows.first.assoc());
    } catch (e) {
      if (e.toString().contains('id_user')) {
        final fallbackSql = sql.replaceAll('a.id_user', 'a.id_student');
        final results = await Database.query(fallbackSql, {'idAgenda': idAgenda, 'idUser': idUser});
        if (results.rows.isEmpty) return null;
        return PersonalSchedule.fromRow(results.rows.first.assoc());
      }
      rethrow;
    }
  }

  static Future<void> create({
    required String idAgenda,
    required String idUser,
    String? idStudent,
    required String title,
    required String startTime,
    required String endTime,
    required String date,
    required String category,
    String? location,
    String? notes,
  }) async {
    final userId = idUser;

    // 1. Insert ke tabel superclass agenda (prioritaskan id_student untuk skema PostgreSQL saat ini)
    try {
      await Database.query(
        '''
        INSERT INTO agenda (id_agenda, id_student, title, start_time, end_time, agenda_type)
        VALUES (:idAgenda, :idUser, :title, :startTime::time, :endTime::time, 'PERSONAL')
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
          VALUES (:idAgenda, :idUser, :title, :startTime::time, :endTime::time, 'PERSONAL')
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

    // 2. Insert ke tabel subclass personal_schedule
    await Database.query(
      '''
      INSERT INTO personal_schedule (id_agenda, date, category, location, notes)
      VALUES (:idAgenda, :date::date, :category, :location, :notes)
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
    required String idUser,
    String? idStudent,
    String? title,
    String? startTime,
    String? endTime,
    String? date,
    String? category,
    String? location,
    String? notes,
  }) async {
    final userId = idUser;

    // 🛡️ BOLA / IDOR Protection: Verifikasi kepemilikan agenda sebelum update
    final existing = await findById(idAgenda, userId);
    if (existing == null) {
      throw Exception('Jadwal personal tidak ditemukan atau bukan milik Anda.');
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

    final psUpdates = <String>[];
    final psParams = <String, dynamic>{
      'idAgenda': idAgenda,
      'idUser': userId,
    };

    if (date != null) {
      psUpdates.add('date = :date::date');
      psParams['date'] = date;
    }
    if (category != null) {
      psUpdates.add('category = :category');
      psParams['category'] = category;
    }
    if (location != null) {
      psUpdates.add('location = :location');
      psParams['location'] = location;
    }
    if (notes != null) {
      psUpdates.add('notes = :notes');
      psParams['notes'] = notes;
    }

    if (psUpdates.isNotEmpty) {
      try {
        await Database.query(
          'UPDATE personal_schedule SET ${psUpdates.join(', ')} WHERE id_agenda = :idAgenda AND id_agenda IN (SELECT id_agenda FROM agenda WHERE id_user = :idUser)',
          psParams,
        );
      } catch (e) {
        if (e.toString().contains('id_user')) {
          await Database.query(
            'UPDATE personal_schedule SET ${psUpdates.join(', ')} WHERE id_agenda = :idAgenda AND id_agenda IN (SELECT id_agenda FROM agenda WHERE id_student = :idUser)',
            psParams,
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
