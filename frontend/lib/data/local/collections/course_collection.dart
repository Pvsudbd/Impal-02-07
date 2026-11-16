import 'package:isar/isar.dart';

part 'course_collection.g.dart';

/// Skema Isar DB untuk Cache Master Mata Kuliah / Modul.
///
/// Digunakan untuk dropdown mata kuliah saat pembuatan tugas & jadwal offline.
@collection
class CourseCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String courseCode; // Primary Key kode matkul (misal: SSIF-04-REG)

  late String courseName;
  late int credits;
  late String lecturer;

  late DateTime updatedAt;
}
