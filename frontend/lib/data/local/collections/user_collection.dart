import 'package:isar/isar.dart';

part 'user_collection.g.dart';

/// Skema Isar DB untuk Cache Sesi Profil Pengguna Aktif.
///
/// PERINGATAN KEAMANAN (Cybersecurity & AppSec):
/// Password hash DILARANG KERAS disimpan di Isar DB lokal!
@collection
class UserCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String remoteId; // id_user (UUID v4 di PostgreSQL)

  late String name;
  late String email;
  String? studentId;
  String? majorCampus;
  String? phoneNumber;
  String? bio;

  // Metadata Sinkronisasi (Offline-First)
  late DateTime updatedAt;
  late bool isSynced;
}
