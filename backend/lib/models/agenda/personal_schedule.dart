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
      idUser: row['id_user']?.toString(),
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
    final resolvedType = (catLower == 'meeting' ||
            locLower.contains('meet') ||
            locLower.contains('zoom') ||
            locLower.contains('team'))
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

    final results = await Database.query(sql, {'idUser': idUser});
    return results.rows.map((r) => PersonalSchedule.fromRow(r.assoc())).toList();
  }

  // Backwards compatible alias
  static Future<List<PersonalSchedule>> findByStudent(String idStudent) =>
      findByUser(idStudent);

  static Future<PersonalSchedule?> findById(
    String idAgenda,
    String idUser,
  ) async {
    const sql = '''
      SELECT a.id_agenda, a.id_user, a.title, a.start_time, a.end_time, a.agenda_type,
             ps.date, ps.category, ps.location, ps.notes
      FROM agenda a
      JOIN personal_schedule ps ON a.id_agenda = ps.id_agenda
      WHERE a.id_agenda = :idAgenda AND a.id_user = :idUser
      LIMIT 1
    ''';

    final results = await Database.query(sql, {
      'idAgenda': idAgenda,
      'idUser': idUser,
    });
    if (results.rows.isEmpty) return null;
    return PersonalSchedule.fromRow(results.rows.first.assoc());
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
    final safeTitle = title.trim().length > 150
        ? title.trim().substring(0, 150)
        : title.trim();
    final safeCategory = category.trim().length > 50
        ? category.trim().substring(0, 50)
        : category.trim();
    final rawLocation = (location ?? '').trim();
    final safeLocation = rawLocation.length > 100
        ? rawLocation.substring(0, 100)
        : rawLocation;

    await Database.transaction((tx) async {
      await tx.query(
        '''
        INSERT INTO agenda (id_agenda, id_user, title, start_time, end_time, agenda_type, created_at, updated_at)
        VALUES (:idAgenda, :idUser, :title, :startTime::time, :endTime::time, 'PERSONAL', NOW(), NOW())
        ''',
        {
          'idAgenda': idAgenda,
          'idUser': idUser,
          'title': safeTitle,
          'startTime': startTime,
          'endTime': endTime,
        },
      );

      await tx.query(
        '''
        INSERT INTO personal_schedule (id_agenda, date, category, location, notes)
        VALUES (:idAgenda, :date::date, :category, :location, :notes)
        ''',
        {
          'idAgenda': idAgenda,
          'date': date,
          'category': safeCategory,
          'location': safeLocation,
          'notes': notes ?? '',
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
    String? date,
    String? category,
    String? location,
    String? notes,
  }) async {
    // BOLA / IDOR Protection: verify ownership before update
    final existing = await findById(idAgenda, idUser);
    if (existing == null) {
      throw Exception('Jadwal personal tidak ditemukan atau bukan milik Anda.');
    }

    final safeTitle = title != null
        ? (title.trim().length > 150 ? title.trim().substring(0, 150) : title.trim())
        : null;
    final safeCategory = category != null
        ? (category.trim().length > 50 ? category.trim().substring(0, 50) : category.trim())
        : null;
    final safeLocation = location != null
        ? (location.trim().length > 100 ? location.trim().substring(0, 100) : location.trim())
        : null;

    await Database.transaction((tx) async {
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

      final psUpdates = <String>[];
      final psParams = <String, dynamic>{'idAgenda': idAgenda};

      if (date != null) {
        psUpdates.add('date = :date::date');
        psParams['date'] = date;
      }
      if (safeCategory != null) {
        psUpdates.add('category = :category');
        psParams['category'] = safeCategory;
      }
      if (safeLocation != null) {
        psUpdates.add('location = :location');
        psParams['location'] = safeLocation;
      }
      if (notes != null) {
        psUpdates.add('notes = :notes');
        psParams['notes'] = notes;
      }

      if (psUpdates.isNotEmpty) {
        await tx.query(
          'UPDATE personal_schedule SET ${psUpdates.join(', ')} '
          'WHERE id_agenda = :idAgenda',
          psParams,
        );
      }
    });
  }

  static Future<void> delete(String idAgenda, String idUser) async {
    await Database.transaction((tx) async {
      final owned = await tx.query(
        'SELECT id_agenda FROM agenda WHERE id_agenda = :idAgenda AND id_user = :idUser LIMIT 1',
        {'idAgenda': idAgenda, 'idUser': idUser},
      );
      if (owned.rows.isEmpty) return;

      // Delete child first because legacy live DB tables lack ON DELETE CASCADE FK
      await tx.query(
        'DELETE FROM personal_schedule WHERE id_agenda = :idAgenda',
        {'idAgenda': idAgenda},
      );
      await tx.query(
        'DELETE FROM agenda WHERE id_agenda = :idAgenda AND id_user = :idUser',
        {'idAgenda': idAgenda, 'idUser': idUser},
      );
    });
  }
}
