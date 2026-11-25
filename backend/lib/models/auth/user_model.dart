import '../../config/db.dart';

typedef User = UserModel;
typedef StudentModel = UserModel;
typedef Student = UserModel;

class UserModel {
  final String idUser;
  final String name;
  final String email;
  final String? passwordHash;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.idUser,
    required this.name,
    required this.email,
    this.passwordHash,
    this.createdAt,
    this.updatedAt,
  });

  // Getter alias untuk backwards compatibility
  String get idStudent => idUser;

  factory UserModel.fromRow(Map<String, dynamic> row) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    return UserModel(
      idUser: row['id_user']?.toString() ?? '',
      name: row['name']?.toString() ?? '',
      email: row['email']?.toString() ?? '',
      passwordHash: row['password_hash']?.toString(),
      createdAt: parseDate(row['created_at']),
      updatedAt: parseDate(row['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'idStudent': idUser, // compatibility
      'name': name,
      'email': email,
    };
  }

  // Cari user berdasarkan email (Tabel users)
  static Future<UserModel?> findByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final results = await Database.query(
      'SELECT id_user, name, email, password_hash, created_at, updated_at '
      'FROM users WHERE LOWER(email) = :email LIMIT 1',
      {'email': normalizedEmail},
    );

    if (results.rows.isEmpty) return null;
    return UserModel.fromRow(results.rows.first.assoc());
  }

  // Cari user berdasarkan id_user (Tabel users)
  static Future<UserModel?> findById(String idUser) async {
    final results = await Database.query(
      'SELECT id_user, name, email, created_at, updated_at '
      'FROM users WHERE id_user = :idUser LIMIT 1',
      {'idUser': idUser},
    );

    if (results.rows.isEmpty) return null;
    return UserModel.fromRow(results.rows.first.assoc());
  }

  // Buat user baru (Tabel users)
  static Future<String> create({
    required String idUser,
    required String name,
    required String email,
    required String passwordHash,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    await Database.query(
      'INSERT INTO users (id_user, name, email, password_hash, created_at, updated_at) '
      'VALUES (:idUser, :name, :email, :passwordHash, NOW(), NOW())',
      {
        'idUser': idUser,
        'name': name.trim(),
        'email': normalizedEmail,
        'passwordHash': passwordHash,
      },
    );
    return idUser;
  }
}
