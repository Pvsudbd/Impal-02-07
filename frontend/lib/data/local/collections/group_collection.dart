import 'package:isar/isar.dart';

part 'group_collection.g.dart';

/// Skema Isar DB untuk Cache Kelompok / Tim Kolaboratif (`groups`).
///
/// Mengacu pada Tabel `groups` di DATABASE_REQUIREMENTS.md dan Entity_Relationship_Diagram.md
@collection
class GroupCollection {
  Id id = Isar.autoIncrement; // Local fast primary key

  @Index(unique: true)
  late String remoteId; // id_group (UUID v4 di PostgreSQL)

  late String idLeader;
  late String groupName;
  String? description;

  @Index()
  late String inviteCode;

  late int groupSize; // Jumlah anggota aktual pada kelompok (minimal 1)
  late DateTime createdAt;

  // Metadata Sinkronisasi (Offline-First)
  late DateTime updatedAt;
  late bool isSynced;
  String? syncAction; // 'INSERT', 'UPDATE', 'DELETE'
}

