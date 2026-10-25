import '../../config/db.dart';

typedef Student = StudentModel;

class StudentModel {
  final String idStudent;
  final String name;
  final String email;
  final String? passwordHash;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudentModel({
    required this.idStudent,
    required this.name,
    required this.email,
    this.passwordHash,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentModel.fromRow(Map<String, dynamic> row) {
    return StudentModel(
      idStudent: row['id_student']?.toString() ?? '',
      name: row['name']?.toString() ?? '',
      email: row['email']?.toString() ?? '',
      passwordHash: row['password_hash']?.toString(),
      createdAt: row['created_at'] is DateTime ? row['created_at'] as DateTime : null,
      updatedAt: row['updated_at'] is DateTime ? row['updated_at'] as DateTime : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idStudent': idStudent,
      'name': name,
      'email': email,
    };
  }

  // Cari student berdasarkan email
  static Future<StudentModel?> findByEmail(String email) async {
    final results = await Database.query(
      'SELECT id_student, name, email, password_hash, created_at, updated_at FROM student WHERE email = ? LIMIT 1',
      [email],
    );

    if (results.isEmpty) return null;
    return StudentModel.fromRow(results.first.fields);
  }

  // Cari student berdasarkan id_student
  static Future<StudentModel?> findById(String idStudent) async {
    final results = await Database.query(
      'SELECT id_student, name, email, created_at, updated_at FROM student WHERE id_student = ? LIMIT 1',
      [idStudent],
    );

    if (results.isEmpty) return null;
    return StudentModel.fromRow(results.first.fields);
  }

  // Buat student baru
  static Future<String> create({
    required String idStudent,
    required String name,
    required String email,
    required String passwordHash,
  }) async {
    await Database.query(
      'INSERT INTO student (id_student, name, email, password_hash) VALUES (?, ?, ?, ?)',
      [idStudent, name, email, passwordHash],
    );
    return idStudent;
  }
}
