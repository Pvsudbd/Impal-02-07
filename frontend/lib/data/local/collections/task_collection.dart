import 'package:isar/isar.dart';

part 'task_collection.g.dart';

/// Skema Isar DB untuk Tugas Personal & Rekomendasi Prioritas Fuzzy.
///
/// Mengacu pada Bagian 4.A DATABASE_REQUIREMENTS.md
@collection
class TaskCollection {
  Id id = Isar.autoIncrement; // Local fast primary key

  @Index(unique: true)
  late String remoteId; // id_task (UUID v4 di PostgreSQL)

  late String idUser;
  late String courseCode;
  late String taskTitle;
  String? description;
  late DateTime deadline;
  late double gradeWeight;
  late double priorityScore;
  late String priority; // 'VERY HIGH', 'HIGH', 'MEDIUM', 'LOW'
  late bool isFuzzyAuto;
  late bool isCompleted;

  // Metadata Sinkronisasi (Offline-First)
  late DateTime updatedAt;
  late bool isSynced;
  String? syncAction; // 'INSERT', 'UPDATE', 'DELETE'
}
