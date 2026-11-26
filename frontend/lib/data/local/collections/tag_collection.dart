import 'package:isar/isar.dart';

part 'tag_collection.g.dart';

/// Skema Isar DB untuk Cache Custom Task Tags (`task_tags`).
///
/// Menyimpan custom tags per pengguna agar tersedia secara offline-first
/// lintas halaman maupun setelah aplikasi di-refresh.
@collection
class TagCollection {
  Id id = Isar.autoIncrement; // Local fast primary key

  @Index(unique: true)
  late String remoteId; // id_tag (UUID v4 di PostgreSQL)

  @Index()
  late String idUser;

  late String label;
  late int backgroundColor;
  late int textColor;
  late bool isDefault;

  // Metadata Sinkronisasi (Offline-First)
  late DateTime updatedAt;
  late bool isSynced;
  String? syncAction; // 'INSERT', 'UPDATE', 'DELETE'
}

