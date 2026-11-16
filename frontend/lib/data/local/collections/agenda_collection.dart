import 'package:isar/isar.dart';

part 'agenda_collection.g.dart';

/// Skema Isar DB untuk Agenda Terpadu (Kuliah mingguan & Agenda kegiatan personal).
///
/// Mengacu pada Bagian 4.B DATABASE_REQUIREMENTS.md
@collection
class AgendaCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String remoteId; // id_agenda (UUID v4 di PostgreSQL)

  late String idUser;
  late String title;
  late String startTime; // '08:00:00'
  late String endTime; // '10:30:00'
  late String agendaType; // 'COURSE' atau 'PERSONAL'

  // Spesialisasi CourseSchedule
  String? courseCode;
  String? day;
  String? room;

  // Spesialisasi PersonalSchedule
  DateTime? date;
  String? category;
  String? location;
  String? notes;

  // Metadata Sinkronisasi (Offline-First)
  late DateTime updatedAt;
  late bool isSynced;
  String? syncAction; // 'INSERT', 'UPDATE', 'DELETE'
}
