import 'package:uuid/uuid.dart';
import '../../config/db.dart';

/// Thrown when a user attempts to exceed the 30 custom courses quota.
class CourseLimitExceededException implements Exception {
  final String message;

  CourseLimitExceededException([
    this.message =
        'Batas maksimal 30 mata kuliah kustom per pengguna telah tercapai.',
  ]);

  @override
  String toString() => message;
}

/// Thrown when a course name conflicts with an existing global or user course.
class DuplicateCourseException implements Exception {
  final String message;

  DuplicateCourseException([
    this.message = 'Mata kuliah dengan nama tersebut sudah ada.',
  ]);

  @override
  String toString() => message;
}

/// Thrown when attempting to delete a custom course still referenced by schedules.
class CourseInUseException implements Exception {
  final String message;

  CourseInUseException([
    this.message =
        'Mata kuliah tidak dapat dihapus karena masih digunakan pada jadwal.',
  ]);

  @override
  String toString() => message;
}

/// Thrown when a course does not exist or is not owned/accessible by the user.
class CourseNotFoundException implements Exception {
  final String message;

  CourseNotFoundException([
    this.message = 'Mata kuliah tidak ditemukan.',
  ]);

  @override
  String toString() => message;
}

class CourseModel {
  static const _uuid = Uuid();
  static const int maxCustomCoursesPerUser = 30;

  final String idCourse;
  final String? idUser;
  final String courseName;
  final int credits;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CourseModel({
    required this.idCourse,
    this.idUser,
    required this.courseName,
    required this.credits,
    this.createdAt,
    this.updatedAt,
  });

  bool get isCustom => idUser != null;

  factory CourseModel.fromRow(Map<String, dynamic> row) {
    DateTime? parseTs(dynamic raw) {
      if (raw == null) return null;
      if (raw is DateTime) return raw;
      return DateTime.tryParse(raw.toString());
    }

    return CourseModel(
      idCourse: row['id_course']?.toString() ?? '',
      idUser: row['id_user']?.toString(),
      courseName: row['course_name']?.toString() ?? '',
      credits: int.tryParse(row['credits']?.toString() ?? '3') ?? 3,
      createdAt: parseTs(row['created_at']),
      updatedAt: parseTs(row['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCourse': idCourse,
      'idUser': idUser,
      'courseName': courseName,
      'credits': credits,
      'isCustom': isCustom,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static Future<List<CourseModel>> findAllForUser(
    String idUser, {
    String? query,
    String? scope,
  }) async {
    final normalizedScope = scope?.trim().toLowerCase();
    final conditions = <String>[];
    final params = <String, dynamic>{};

    if (normalizedScope == 'mine') {
      conditions.add('id_user = :idUser');
      params['idUser'] = idUser;
    } else if (normalizedScope == 'global') {
      conditions.add('id_user IS NULL');
    } else {
      conditions.add('(id_user IS NULL OR id_user = :idUser)');
      params['idUser'] = idUser;
    }

    final trimmedQuery = query?.trim();
    if (trimmedQuery != null && trimmedQuery.isNotEmpty) {
      conditions.add('LOWER(course_name) LIKE LOWER(:q)');
      params['q'] = '%$trimmedQuery%';
    }

    final sql = '''
      SELECT id_course, id_user, course_name, credits, created_at, updated_at
      FROM course
      WHERE ${conditions.join(' AND ')}
      ORDER BY (id_user IS NULL) ASC, LOWER(course_name) ASC
    ''';

    final results = await Database.query(sql, params);
    return results.rows.map((r) => CourseModel.fromRow(r.assoc())).toList();
  }

  static Future<int> countCustomByUser(
    String idUser, {
    DbTransaction? tx,
  }) async {
    const sql = 'SELECT COUNT(*) FROM course WHERE id_user = :idUser';
    final params = {'idUser': idUser};
    final result =
        tx != null ? await tx.query(sql, params) : await Database.query(sql, params);
    if (result.rows.isEmpty) return 0;
    return int.tryParse(result.rows.first.colAt(0)?.toString() ?? '0') ?? 0;
  }

  static Future<String> resolveOrCreateForSchedule(
    DbTransaction tx, {
    required String idUser,
    String? idCourse,
    String? courseName,
    int credits = 3,
  }) async {
    final cleanIdCourse = idCourse?.trim();
    if (cleanIdCourse != null && cleanIdCourse.isNotEmpty) {
      final found = await tx.query(
        '''
        SELECT id_course
        FROM course
        WHERE id_course = :idCourse AND (id_user IS NULL OR id_user = :idUser)
        LIMIT 1
        ''',
        {'idCourse': cleanIdCourse, 'idUser': idUser},
      );
      if (found.rows.isEmpty) {
        throw CourseNotFoundException();
      }
      return cleanIdCourse;
    }

    final rawName = courseName?.trim() ?? '';
    if (rawName.isEmpty) {
      throw ArgumentError('Nama mata kuliah wajib diisi.');
    }
    final safeName = rawName.length > 100 ? rawName.substring(0, 100) : rawName;

    final existing = await tx.query(
      '''
      SELECT id_course
      FROM course
      WHERE LOWER(TRIM(course_name)) = LOWER(:name)
        AND (id_user = :idUser OR id_user IS NULL)
      ORDER BY (id_user IS NULL) ASC
      LIMIT 1
      ''',
      {'name': safeName, 'idUser': idUser},
    );
    if (existing.rows.isNotEmpty) {
      return existing.rows.first.assoc()['id_course'].toString();
    }

    final customCount = await countCustomByUser(idUser, tx: tx);
    if (customCount >= maxCustomCoursesPerUser) {
      throw CourseLimitExceededException();
    }

    final newId = _uuid.v4();
    await tx.query(
      '''
      INSERT INTO course (id_course, id_user, course_name, credits, created_at, updated_at)
      VALUES (:idCourse, :idUser, :courseName, :credits, NOW(), NOW())
      ''',
      {
        'idCourse': newId,
        'idUser': idUser,
        'courseName': safeName,
        'credits': credits,
      },
    );
    return newId;
  }

  static Future<CourseModel> createCustom({
    required String idUser,
    required String courseName,
    int credits = 3,
  }) async {
    final trimmedName = courseName.trim();
    final safeName =
        trimmedName.length > 100 ? trimmedName.substring(0, 100) : trimmedName;

    return await Database.transaction((tx) async {
      final duplicate = await tx.query(
        '''
        SELECT id_course
        FROM course
        WHERE LOWER(TRIM(course_name)) = LOWER(:name)
          AND (id_user = :idUser OR id_user IS NULL)
        LIMIT 1
        ''',
        {'name': safeName, 'idUser': idUser},
      );
      if (duplicate.rows.isNotEmpty) {
        throw DuplicateCourseException();
      }

      final customCount = await countCustomByUser(idUser, tx: tx);
      if (customCount >= maxCustomCoursesPerUser) {
        throw CourseLimitExceededException();
      }

      final newId = _uuid.v4();
      final inserted = await tx.query(
        '''
        INSERT INTO course (id_course, id_user, course_name, credits, created_at, updated_at)
        VALUES (:idCourse, :idUser, :courseName, :credits, NOW(), NOW())
        RETURNING id_course, id_user, course_name, credits, created_at, updated_at
        ''',
        {
          'idCourse': newId,
          'idUser': idUser,
          'courseName': safeName,
          'credits': credits,
        },
      );

      return CourseModel.fromRow(inserted.rows.first.assoc());
    });
  }

  static Future<CourseModel> updateCustom({
    required String idCourse,
    required String idUser,
    String? courseName,
    int? credits,
  }) async {
    return await Database.transaction((tx) async {
      final owned = await tx.query(
        '''
        SELECT id_course, id_user, course_name, credits, created_at, updated_at
        FROM course
        WHERE id_course = :idCourse AND id_user = :idUser
        LIMIT 1
        ''',
        {'idCourse': idCourse, 'idUser': idUser},
      );
      if (owned.rows.isEmpty) {
        throw CourseNotFoundException(
          'Mata kuliah kustom tidak ditemukan atau bukan milik Anda.',
        );
      }

      final updates = <String>[];
      final params = <String, dynamic>{
        'idCourse': idCourse,
        'idUser': idUser,
      };

      if (courseName != null) {
        final trimmedName = courseName.trim();
        final safeName =
            trimmedName.length > 100 ? trimmedName.substring(0, 100) : trimmedName;

        final duplicate = await tx.query(
          '''
          SELECT id_course
          FROM course
          WHERE LOWER(TRIM(course_name)) = LOWER(:name)
            AND (id_user = :idUser OR id_user IS NULL)
            AND id_course != :idCourse
          LIMIT 1
          ''',
          {'name': safeName, 'idUser': idUser, 'idCourse': idCourse},
        );
        if (duplicate.rows.isNotEmpty) {
          throw DuplicateCourseException();
        }

        updates.add('course_name = :courseName');
        params['courseName'] = safeName;
      }

      if (credits != null) {
        updates.add('credits = :credits');
        params['credits'] = credits;
      }

      if (updates.isEmpty) {
        return CourseModel.fromRow(owned.rows.first.assoc());
      }

      updates.add('updated_at = NOW()');
      final updated = await tx.query(
        '''
        UPDATE course
        SET ${updates.join(', ')}
        WHERE id_course = :idCourse AND id_user = :idUser
        RETURNING id_course, id_user, course_name, credits, created_at, updated_at
        ''',
        params,
      );

      return CourseModel.fromRow(updated.rows.first.assoc());
    });
  }

  static Future<void> deleteCustom({
    required String idCourse,
    required String idUser,
  }) async {
    await Database.transaction((tx) async {
      final owned = await tx.query(
        '''
        SELECT id_course
        FROM course
        WHERE id_course = :idCourse AND id_user = :idUser
        LIMIT 1
        ''',
        {'idCourse': idCourse, 'idUser': idUser},
      );
      if (owned.rows.isEmpty) {
        throw CourseNotFoundException(
          'Mata kuliah kustom tidak ditemukan atau bukan milik Anda.',
        );
      }

      final inUseRes = await tx.query(
        'SELECT COUNT(*) FROM course_schedule WHERE id_course = :idCourse',
        {'idCourse': idCourse},
      );
      final inUseCount = int.tryParse(
            inUseRes.rows.isNotEmpty
                ? inUseRes.rows.first.colAt(0)?.toString() ?? '0'
                : '0',
          ) ??
          0;
      if (inUseCount > 0) {
        throw CourseInUseException();
      }

      await tx.query(
        'DELETE FROM course WHERE id_course = :idCourse AND id_user = :idUser',
        {'idCourse': idCourse, 'idUser': idUser},
      );
    });
  }
}
