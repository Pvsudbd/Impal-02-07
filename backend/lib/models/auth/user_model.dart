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
      idUser: (row['id_user'] ?? row['id_student'])?.toString() ?? '',
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
    try {
      final results = await Database.query(
        'SELECT id_user, name, email, password_hash, created_at, updated_at FROM users WHERE email = :email LIMIT 1',
        {'email': email},
      );

      if (results.rows.isEmpty) return null;
      return UserModel.fromRow(results.rows.first.assoc());
    } catch (e) {
      // Fallback jika kolom primary key masih id_student
      if (e.toString().contains('id_user')) {
        final results = await Database.query(
          'SELECT id_student AS id_user, name, email, password_hash, created_at, updated_at FROM users WHERE email = :email LIMIT 1',
          {'email': email},
        );
        if (results.rows.isEmpty) return null;
        return UserModel.fromRow(results.rows.first.assoc());
      }
      rethrow;
    }
  }

  // Cari user berdasarkan id_user (Tabel users)
  static Future<UserModel?> findById(String idUser) async {
    try {
      final results = await Database.query(
        'SELECT id_user, name, email, created_at, updated_at FROM users WHERE id_user = :idUser LIMIT 1',
        {'idUser': idUser},
      );

      if (results.rows.isEmpty) return null;
      return UserModel.fromRow(results.rows.first.assoc());
    } catch (e) {
      if (e.toString().contains('id_user')) {
        final results = await Database.query(
          'SELECT id_student AS id_user, name, email, created_at, updated_at FROM users WHERE id_student = :idUser LIMIT 1',
          {'idUser': idUser},
        );
        if (results.rows.isEmpty) return null;
        return UserModel.fromRow(results.rows.first.assoc());
      }
      rethrow;
    }
  }

  // Buat user baru (Tabel users)
  static Future<String> create({
    required String idUser,
    required String name,
    required String email,
    required String passwordHash,
  }) async {
    try {
      await Database.query(
        'INSERT INTO users (id_user, name, email, password_hash) VALUES (:idUser, :name, :email, :passwordHash)',
        {
          'idUser': idUser,
          'name': name,
          'email': email,
          'passwordHash': passwordHash,
        },
      );
      return idUser;
    } catch (e) {
      if (e.toString().contains('id_user')) {
        await Database.query(
          'INSERT INTO users (id_student, name, email, password_hash) VALUES (:idUser, :name, :email, :passwordHash)',
          {
            'idUser': idUser,
            'name': name,
            'email': email,
            'passwordHash': passwordHash,
          },
        );
        return idUser;
      }
      rethrow;
    }
  }
}

