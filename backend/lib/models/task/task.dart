import 'dart:convert';
import '../../config/db.dart';
import '../../services/fuzzy_mamdani_service.dart';
import '../course/course_model.dart';

class Task {
  String _taskId;
  String? _idUser;
  String? _idCourse;
  String? _courseName;
  String _taskTitle;
  String _description;
  DateTime _deadline;
  double _gradeWeight;
  double _priorityScore;
  String _priority;
  bool _isFuzzyAuto;
  bool _isCompleted;
  List<dynamic> _tags;
  DateTime? _createdAt;
  DateTime? _updatedAt;

  Task({
    required String taskId,
    String? idUser,
    String? idCourse,
    String? courseName,
    required String taskTitle,
    required String description,
    required DateTime deadline,
    required double gradeWeight,
    required double priorityScore,
    required String priority,
    required bool isFuzzyAuto,
    bool isCompleted = false,
    List<dynamic> tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : _taskId = taskId,
        _idUser = idUser,
        _idCourse = idCourse,
        _courseName = courseName,
        _taskTitle = taskTitle,
        _description = description,
        _deadline = deadline,
        _gradeWeight = gradeWeight,
        _priorityScore = priorityScore,
        _priority = priority,
        _isFuzzyAuto = isFuzzyAuto,
        _isCompleted = isCompleted,
        _tags = List<dynamic>.from(tags),
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  static List<dynamic> _parseTags(dynamic raw) {
    List<dynamic> normalizeList(List items) {
      final result = <dynamic>[];
      for (final item in items) {
        if (item is Map) {
          result.add(Map<String, dynamic>.from(item));
        } else {
          final text = item.toString().trim();
          if (text.isNotEmpty) result.add(text);
        }
      }
      return result;
    }

    if (raw == null) return [];
    if (raw is List) {
      return normalizeList(raw);
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return normalizeList(decoded);
        }
      } catch (_) {}
    }
    return [];
  }

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is DateTime) return val;
    return DateTime.tryParse(val.toString()) ?? DateTime.now();
  }

  static DateTime? _parseNullableDate(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    return DateTime.tryParse(val.toString());
  }

  factory Task.fromRow(Map<String, dynamic> row) {
    return Task(
      taskId: row['id_task']?.toString() ?? '',
      idUser: row['id_user']?.toString(),
      idCourse: row['id_course']?.toString(),
      courseName: row['course_name']?.toString(),
      taskTitle: row['task_title']?.toString() ?? '',
      description: row['description']?.toString() ?? '',
      deadline: _parseDate(row['deadline']),
      gradeWeight: double.tryParse(row['grade_weight']?.toString() ?? '0') ?? 0.0,
      priorityScore:
          double.tryParse(row['priority_score']?.toString() ?? '0') ?? 0.0,
      priority: row['priority']?.toString() ?? 'MEDIUM',
      isFuzzyAuto: row['is_fuzzy_auto'] == 1 || row['is_fuzzy_auto'] == true,
      isCompleted: row['is_completed'] == 1 || row['is_completed'] == true,
      tags: _parseTags(row['tags']),
      createdAt: _parseNullableDate(row['created_at']),
      updatedAt: _parseNullableDate(row['updated_at']),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: (json['idTask'] ?? json['id_task'] ?? '').toString(),
      idUser: (json['idUser'] ?? json['id_user'])?.toString(),
      idCourse: (json['idCourse'] ?? json['id_course'])?.toString(),
      courseName: (json['courseName'] ?? json['course_name'])?.toString(),
      taskTitle:
          (json['taskTitle'] ?? json['task_title'] ?? json['title'] ?? '')
              .toString(),
      description: (json['description'] ?? '').toString(),
      deadline: _parseDate(json['deadline']),
      gradeWeight:
          ((json['gradeWeight'] ?? json['grade_weight']) as num?)?.toDouble() ??
              0.0,
      priorityScore:
          ((json['priorityScore'] ?? json['priority_score']) as num?)
                  ?.toDouble() ??
              0.0,
      priority: (json['priority'] ?? 'MEDIUM').toString(),
      isFuzzyAuto: (json['isFuzzyAuto'] ?? json['is_fuzzy_auto']) == 1 ||
          (json['isFuzzyAuto'] ?? json['is_fuzzy_auto']) == true,
      isCompleted: (json['isCompleted'] ?? json['is_completed']) == 1 ||
          (json['isCompleted'] ?? json['is_completed']) == true,
      tags: _parseTags(json['tags']),
      createdAt: _parseNullableDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseNullableDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _taskId,
      'idTask': _taskId,
      'id_task': _taskId,
      'idUser': _idUser,
      'id_user': _idUser,
      'idCourse': _idCourse,
      'id_course': _idCourse,
      'course': _courseName,
      'courseName': _courseName,
      'course_name': _courseName,
      'title': _taskTitle,
      'taskTitle': _taskTitle,
      'task_title': _taskTitle,
      'description': _description,
      'deadline': _deadline.toIso8601String(),
      'gradeWeight': _gradeWeight,
      'grade_weight': _gradeWeight,
      'priorityScore': _priorityScore,
      'priority_score': _priorityScore,
      'priority': _priority,
      'isFuzzyAuto': _isFuzzyAuto,
      'is_fuzzy_auto': _isFuzzyAuto ? 1 : 0,
      'isCompleted': _isCompleted,
      'is_completed': _isCompleted ? 1 : 0,
      'tags': _tags,
      'createdAt': _createdAt?.toIso8601String(),
      'updatedAt': _updatedAt?.toIso8601String(),
    };
  }

  // Getters
  String get taskId => _taskId;
  String? get idUser => _idUser;
  String? get idCourse => _idCourse;
  String? get courseName => _courseName;
  String get taskTitle => _taskTitle;
  String get description => _description;
  DateTime get deadline => _deadline;
  double get gradeWeight => _gradeWeight;
  double get priorityScore => _priorityScore;
  String get priority => _priority;
  bool get isFuzzyAuto => _isFuzzyAuto;
  bool get isCompleted => _isCompleted;
  List<dynamic> get tags => List.unmodifiable(_tags);
  DateTime? get createdAt => _createdAt;
  DateTime? get updatedAt => _updatedAt;

  // Methods
  int calculateRemainingTime() {
    return _deadline.difference(DateTime.now()).inHours;
  }

  void setCompletionStatus(bool status) {
    _isCompleted = status;
  }

  void updateFuzzyPriority(double score, String level) {
    _priorityScore = score;
    _priority = level;
  }

  static Future<List<Task>> findByUser(
    String idUser, {
    bool? isCompleted,
    String? priority,
    String? idCourse,
    String? query,
  }) async {
    final conditions = <String>['t.id_user = :idUser'];
    final params = <String, dynamic>{'idUser': idUser};

    if (isCompleted != null) {
      conditions.add('t.is_completed = :isCompleted');
      params['isCompleted'] = isCompleted ? 1 : 0;
    }

    if (priority != null && priority.trim().isNotEmpty) {
      conditions.add('UPPER(t.priority) = UPPER(:priority)');
      params['priority'] = priority.trim();
    }

    if (idCourse != null && idCourse.trim().isNotEmpty) {
      conditions.add('t.id_course = :idCourse');
      params['idCourse'] = idCourse.trim();
    }

    if (query != null && query.trim().isNotEmpty) {
      conditions.add(
        '(LOWER(t.task_title) LIKE LOWER(:q) OR LOWER(COALESCE(t.description, \'\')) LIKE LOWER(:q) OR LOWER(COALESCE(c.course_name, \'\')) LIKE LOWER(:q))',
      );
      params['q'] = '%${query.trim()}%';
    }

    final sql = '''
      SELECT
        t.id_task,
        t.id_user,
        t.id_course,
        c.course_name,
        t.task_title,
        t.description,
        t.deadline,
        t.grade_weight,
        t.priority_score,
        t.priority,
        t.is_fuzzy_auto,
        t.is_completed,
        t.tags,
        t.created_at,
        t.updated_at
      FROM task t
      LEFT JOIN course c ON t.id_course = c.id_course
      WHERE ${conditions.join(' AND ')}
      ORDER BY t.is_completed ASC, t.deadline ASC
    ''';

    final results = await Database.query(sql, params);
    return results.rows.map((r) => Task.fromRow(r.assoc())).toList();
  }

  static Future<Task?> findById(String idTask, String idUser) async {
    const sql = '''
      SELECT
        t.id_task,
        t.id_user,
        t.id_course,
        c.course_name,
        t.task_title,
        t.description,
        t.deadline,
        t.grade_weight,
        t.priority_score,
        t.priority,
        t.is_fuzzy_auto,
        t.is_completed,
        t.tags,
        t.created_at,
        t.updated_at
      FROM task t
      LEFT JOIN course c ON t.id_course = c.id_course
      WHERE t.id_task = :idTask AND t.id_user = :idUser
      LIMIT 1
    ''';

    final results = await Database.query(sql, {
      'idTask': idTask,
      'idUser': idUser,
    });
    if (results.rows.isEmpty) return null;
    return Task.fromRow(results.rows.first.assoc());
  }

  static Future<Task> create({
    required String idTask,
    required String idUser,
    String? idCourse,
    String? courseName,
    required String taskTitle,
    String description = '',
    required DateTime deadline,
    double gradeWeight = 20.0,
    bool isFuzzyAuto = true,
    String? manualPriority,
    double? manualPriorityScore,
    List<dynamic> tags = const [],
  }) async {
    final safeTitle = taskTitle.trim().length > 150
        ? taskTitle.trim().substring(0, 150)
        : taskTitle.trim();

    late String finalPriority;
    late double finalScore;
    if (isFuzzyAuto) {
      final eval = FuzzyMamdaniService.evaluate(
        deadline: deadline,
        gradeWeight: gradeWeight,
      );
      finalScore = eval.score;
      finalPriority = eval.level;
    } else {
      finalPriority = (manualPriority ?? 'MEDIUM').trim().toUpperCase();
      finalScore = manualPriorityScore ??
          (finalPriority == 'HIGH'
              ? 80.0
              : (finalPriority == 'LOW' ? 25.0 : 50.0));
    }

    await Database.transaction((tx) async {
      String? resolvedCourseId;
      final hasIdCourse = idCourse != null && idCourse.trim().isNotEmpty;
      final hasCourseName = courseName != null && courseName.trim().isNotEmpty;
      if (hasIdCourse || hasCourseName) {
        resolvedCourseId = await CourseModel.resolveOrCreateForSchedule(
          tx,
          idUser: idUser,
          idCourse: idCourse,
          courseName: courseName,
        );
      }

      await tx.query(
        '''
        INSERT INTO task (
          id_task, id_user, id_course, task_title, description,
          deadline, grade_weight, priority_score, priority,
          is_fuzzy_auto, is_completed, tags, created_at, updated_at
        )
        VALUES (
          :idTask, :idUser, :idCourse, :taskTitle, :description,
          :deadline::timestamp, :gradeWeight, :priorityScore, :priority,
          :isFuzzyAuto, 0, :tags::jsonb, NOW(), NOW()
        )
        ''',
        {
          'idTask': idTask,
          'idUser': idUser,
          'idCourse': resolvedCourseId,
          'taskTitle': safeTitle,
          'description': description,
          'deadline': deadline.toIso8601String(),
          'gradeWeight': gradeWeight,
          'priorityScore': finalScore,
          'priority': finalPriority,
          'isFuzzyAuto': isFuzzyAuto ? 1 : 0,
          'tags': jsonEncode(tags),
        },
      );
    });

    final created = await findById(idTask, idUser);
    if (created == null) {
      throw StateError('Failed to reload created task.');
    }
    return created;
  }

  static Future<Task?> update({
    required String idTask,
    required String idUser,
    String? idCourse,
    String? courseName,
    bool clearCourse = false,
    String? taskTitle,
    String? description,
    DateTime? deadline,
    double? gradeWeight,
    bool? isFuzzyAuto,
    String? manualPriority,
    double? manualPriorityScore,
    bool? isCompleted,
    List<dynamic>? tags,
  }) async {
    final existing = await findById(idTask, idUser);
    if (existing == null) return null;

    final effectiveDeadline = deadline ?? existing.deadline;
    final effectiveWeight = gradeWeight ?? existing.gradeWeight;
    final effectiveFuzzy = isFuzzyAuto ?? existing.isFuzzyAuto;

    double? computedScore;
    String? computedPriority;

    if (effectiveFuzzy) {
      final eval = FuzzyMamdaniService.evaluate(
        deadline: effectiveDeadline,
        gradeWeight: effectiveWeight,
      );
      computedScore = eval.score;
      computedPriority = eval.level;
    } else if (manualPriority != null || manualPriorityScore != null) {
      computedPriority =
          (manualPriority ?? existing.priority).trim().toUpperCase();
      computedScore = manualPriorityScore ?? existing.priorityScore;
    }

    await Database.transaction((tx) async {
      String? resolvedCourseId;
      var updateCourseCol = false;

      if (clearCourse) {
        resolvedCourseId = null;
        updateCourseCol = true;
      } else {
        final hasIdCourse = idCourse != null && idCourse.trim().isNotEmpty;
        final hasCourseName = courseName != null && courseName.trim().isNotEmpty;
        if (hasIdCourse || hasCourseName) {
          resolvedCourseId = await CourseModel.resolveOrCreateForSchedule(
            tx,
            idUser: idUser,
            idCourse: idCourse,
            courseName: courseName,
          );
          updateCourseCol = true;
        }
      }

      final updates = <String>[];
      final params = <String, dynamic>{
        'idTask': idTask,
        'idUser': idUser,
      };

      if (updateCourseCol) {
        updates.add('id_course = :idCourse');
        params['idCourse'] = resolvedCourseId;
      }
      if (taskTitle != null) {
        final trimmed = taskTitle.trim();
        updates.add('task_title = :taskTitle');
        params['taskTitle'] =
            trimmed.length > 150 ? trimmed.substring(0, 150) : trimmed;
      }
      if (description != null) {
        updates.add('description = :description');
        params['description'] = description;
      }
      if (deadline != null) {
        updates.add('deadline = :deadline::timestamp');
        params['deadline'] = deadline.toIso8601String();
      }
      if (gradeWeight != null) {
        updates.add('grade_weight = :gradeWeight');
        params['gradeWeight'] = gradeWeight;
      }
      if (isFuzzyAuto != null) {
        updates.add('is_fuzzy_auto = :isFuzzyAuto');
        params['isFuzzyAuto'] = isFuzzyAuto ? 1 : 0;
      }
      if (computedScore != null) {
        updates.add('priority_score = :priorityScore');
        params['priorityScore'] = computedScore;
      }
      if (computedPriority != null) {
        updates.add('priority = :priority');
        params['priority'] = computedPriority;
      }
      if (isCompleted != null) {
        updates.add('is_completed = :isCompleted');
        params['isCompleted'] = isCompleted ? 1 : 0;
      }
      if (tags != null) {
        updates.add('tags = :tags::jsonb');
        params['tags'] = jsonEncode(tags);
      }

      if (updates.isNotEmpty) {
        updates.add('updated_at = NOW()');
        await tx.query(
          'UPDATE task SET ${updates.join(', ')} '
          'WHERE id_task = :idTask AND id_user = :idUser',
          params,
        );
      }

      final oldCourseId = existing.idCourse;
      if (updateCourseCol &&
          oldCourseId != null &&
          oldCourseId.isNotEmpty &&
          oldCourseId != resolvedCourseId) {
        await CourseModel.cleanupUnusedCustomCourse(
          tx,
          idCourse: oldCourseId,
          idUser: idUser,
        );
      }
    });

    return findById(idTask, idUser);
  }

  static Future<Task?> setCompleted(
    String idTask,
    String idUser,
    bool isCompleted,
  ) async {
    final result = await Database.query(
      '''
      UPDATE task
      SET is_completed = :isCompleted, updated_at = NOW()
      WHERE id_task = :idTask AND id_user = :idUser
      ''',
      {
        'idTask': idTask,
        'idUser': idUser,
        'isCompleted': isCompleted ? 1 : 0,
      },
    );
    if (result.affectedRows == 0) return null;
    return findById(idTask, idUser);
  }

  static Future<bool> delete(String idTask, String idUser) async {
    return Database.transaction((tx) async {
      final owned = await tx.query(
        'SELECT id_course FROM task WHERE id_task = :idTask AND id_user = :idUser LIMIT 1',
        {'idTask': idTask, 'idUser': idUser},
      );
      if (owned.rows.isEmpty) return false;

      final oldCourseId = owned.rows.first.assoc()['id_course']?.toString();

      await tx.query(
        'DELETE FROM task WHERE id_task = :idTask AND id_user = :idUser',
        {'idTask': idTask, 'idUser': idUser},
      );

      if (oldCourseId != null && oldCourseId.isNotEmpty) {
        await CourseModel.cleanupUnusedCustomCourse(
          tx,
          idCourse: oldCourseId,
          idUser: idUser,
        );
      }
      return true;
    });
  }

  /// Recalculates Fuzzy Mamdani score & level for all active auto-fuzzy tasks
  /// belonging to [idUser] inside a single transaction.
  static Future<int> recalculateAllForUser(String idUser) async {
    return Database.transaction((tx) async {
      final rowsRes = await tx.query(
        '''
        SELECT id_task, deadline, grade_weight
        FROM task
        WHERE id_user = :idUser AND is_completed = 0 AND is_fuzzy_auto = 1
        ''',
        {'idUser': idUser},
      );

      var updatedCount = 0;
      final now = DateTime.now();

      for (final row in rowsRes.rows) {
        final data = row.assoc();
        final idTask = data['id_task']?.toString() ?? '';
        if (idTask.isEmpty) continue;

        final deadline = _parseDate(data['deadline']);
        final gradeWeight =
            double.tryParse(data['grade_weight']?.toString() ?? '0') ?? 0.0;
        final eval = FuzzyMamdaniService.evaluate(
          deadline: deadline,
          gradeWeight: gradeWeight,
          now: now,
        );

        await tx.query(
          '''
          UPDATE task
          SET priority_score = :score, priority = :priority, updated_at = NOW()
          WHERE id_task = :idTask AND id_user = :idUser
          ''',
          {
            'idTask': idTask,
            'idUser': idUser,
            'score': eval.score,
            'priority': eval.level,
          },
        );
        updatedCount++;
      }

      return updatedCount;
    });
  }
}
