import 'package:isar/isar.dart';

part 'todo_item_collection.g.dart';

/// Skema Isar DB untuk Item Checklist Harian (To-Do Items).
///
/// Mengacu pada Tabel 6 di DATABASE_REQUIREMENTS.md
@collection
class TodoItemCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String remoteId; // id_item (UUID v4 di PostgreSQL)

  late String idUser;
  late String activityTitle;
  String? notes;
  late DateTime date;
  late bool isDone;

  // Metadata Sinkronisasi (Offline-First)
  late DateTime updatedAt;
  late bool isSynced;
  String? syncAction; // 'INSERT', 'UPDATE', 'DELETE'
}
