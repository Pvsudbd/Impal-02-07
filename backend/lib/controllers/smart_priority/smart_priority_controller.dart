import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../config/db.dart';
import '../../models/task/task.dart';
import '../../services/fuzzy_mamdani_service.dart';

class SmartPriorityController {
  static const _jsonHeaders = {'Content-Type': 'application/json'};
  static const _validLevels = {'HIGH', 'MEDIUM', 'LOW'};

  static String? _getUserId(Request req) {
    final user =
        (req.context['user'] ?? req.context['student']) as Map<String, dynamic>?;
    return (user?['idUser'] ?? user?['idStudent']) as String?;
  }

  static Response _unauthorized() {
    return Response(
      401,
      body: jsonEncode({'status': 'error', 'message': 'Unauthorized'}),
      headers: _jsonHeaders,
    );
  }

  static Future<({bool engineActive, bool explainabilityEnabled})> _loadPrefs(
    String idUser,
  ) async {
    try {
      final res = await Database.query(
        '''
        SELECT is_fuzzy_model_active, score_explainability_enabled
        FROM user_preferences
        WHERE id_user = :idUser
        LIMIT 1
        ''',
        {'idUser': idUser},
      );
      if (res.rows.isEmpty) {
        return (engineActive: true, explainabilityEnabled: true);
      }
      final row = res.rows.first.assoc();
      return (
        engineActive: row['is_fuzzy_model_active'] != false,
        explainabilityEnabled: row['score_explainability_enabled'] != false,
      );
    } catch (_) {
      return (engineActive: true, explainabilityEnabled: true);
    }
  }

  static List<Map<String, dynamic>> _rankAndFormat(
    List<Task> activeTasks, {
    DateTime? now,
    String? levelFilter,
  }) {
    final evaluated = activeTasks.map((t) {
      final eval = FuzzyMamdaniService.evaluate(
        deadline: t.deadline,
        gradeWeight: t.gradeWeight,
        now: now,
      );
      return (task: t, eval: eval);
    }).toList();

    evaluated.sort((a, b) {
      final byScore = b.eval.score.compareTo(a.eval.score);
      if (byScore != 0) return byScore;
      return a.task.deadline.compareTo(b.task.deadline);
    });

    final ranked = <Map<String, dynamic>>[];
    for (var i = 0; i < evaluated.length; i++) {
      final entry = evaluated[i];
      if (levelFilter != null && entry.eval.level != levelFilter) continue;

      final rank = i + 1;
      final levelDesc = entry.eval.level == 'HIGH'
          ? 'CRITICAL PRIORITY'
          : (entry.eval.level == 'MEDIUM'
              ? 'MODERATE PRIORITY'
              : 'LOW PRIORITY');

      final tagList = entry.task.tags;
      final categoryTag = tagList.isNotEmpty
          ? tagList.join(' • ')
          : (entry.task.courseName ?? 'Personal Task');

      ranked.add({
        'id': entry.task.taskId,
        'idTask': entry.task.taskId,
        'rank': rank,
        'rankLabel': '#$rank $levelDesc',
        'title': entry.task.taskTitle,
        'courseName': entry.task.courseName,
        'categoryTag': categoryTag,
        'deadline': entry.task.deadline.toIso8601String(),
        'gradeWeight': entry.task.gradeWeight,
        'isFuzzyAuto': entry.task.isFuzzyAuto,
        ...entry.eval.toJson(),
      });
    }
    return ranked;
  }

  // GET /api/smart-priority?level=HIGH|MEDIUM|LOW
  static Future<Response> getSmartPriority(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final rawLevel = req.url.queryParameters['level']?.trim().toUpperCase();
      if (rawLevel != null &&
          rawLevel.isNotEmpty &&
          !_validLevels.contains(rawLevel)) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Parameter level harus HIGH, MEDIUM, atau LOW.',
          }),
          headers: _jsonHeaders,
        );
      }

      final activeTasks = await Task.findByUser(idUser, isCompleted: false);
      final prefs = await _loadPrefs(idUser);
      final now = DateTime.now();

      final allRanked = _rankAndFormat(activeTasks, now: now);
      final filtered = (rawLevel != null && rawLevel.isNotEmpty)
          ? allRanked.where((e) => e['level'] == rawLevel).toList()
          : allRanked;

      final highCount = allRanked.where((e) => e['level'] == 'HIGH').length;
      final mediumCount = allRanked.where((e) => e['level'] == 'MEDIUM').length;
      final lowCount = allRanked.where((e) => e['level'] == 'LOW').length;

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'engineActive': prefs.engineActive,
          'scoreExplainabilityEnabled': prefs.explainabilityEnabled,
          'summary': {
            'total': allRanked.length,
            'high': highCount,
            'medium': mediumCount,
            'low': lowCount,
          },
          'count': filtered.length,
          'data': filtered,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[SMART_PRIORITY] getSmartPriority error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal menghitung peringkat prioritas Fuzzy.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // POST /api/smart-priority/evaluate
  static Future<Response> evaluatePreview(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final bodyText = await req.readAsString();
      if (bodyText.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Request body tidak boleh kosong.',
          }),
          headers: _jsonHeaders,
        );
      }

      final decoded = jsonDecode(bodyText);
      if (decoded is! Map<String, dynamic>) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Format JSON tidak valid.',
          }),
          headers: _jsonHeaders,
        );
      }

      final rawDeadline = decoded['deadline']?.toString().trim();
      final deadline =
          rawDeadline != null ? DateTime.tryParse(rawDeadline) : null;
      if (deadline == null) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Field deadline wajib diisi dengan format tanggal ISO8601 yang valid.',
          }),
          headers: _jsonHeaders,
        );
      }

      final rawWeight = decoded['gradeWeight'] ?? decoded['grade_weight'];
      final gradeWeight = rawWeight is num
          ? rawWeight.toDouble()
          : double.tryParse(rawWeight?.toString() ?? '');
      if (gradeWeight == null || gradeWeight < 0 || gradeWeight > 100) {
        return Response.badRequest(
          body: jsonEncode({
            'status': 'error',
            'message': 'Field gradeWeight harus bernilai antara 0 sampai 100.',
          }),
          headers: _jsonHeaders,
        );
      }

      final eval = FuzzyMamdaniService.evaluate(
        deadline: deadline,
        gradeWeight: gradeWeight,
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'data': eval.toJson(),
        }),
        headers: _jsonHeaders,
      );
    } on FormatException {
      return Response.badRequest(
        body: jsonEncode({
          'status': 'error',
          'message': 'Format JSON tidak valid.',
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[SMART_PRIORITY] evaluatePreview error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal mengevaluasi prioritas Fuzzy.',
        }),
        headers: _jsonHeaders,
      );
    }
  }

  // POST /api/smart-priority/recalculate
  static Future<Response> recalculateAll(Request req) async {
    try {
      final idUser = _getUserId(req);
      if (idUser == null) return _unauthorized();

      final updatedCount = await Task.recalculateAllForUser(idUser);
      final activeTasks = await Task.findByUser(idUser, isCompleted: false);
      final prefs = await _loadPrefs(idUser);
      final ranked = _rankAndFormat(activeTasks);

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Prioritas Fuzzy berhasil dihitung ulang.',
          'updatedCount': updatedCount,
          'engineActive': prefs.engineActive,
          'scoreExplainabilityEnabled': prefs.explainabilityEnabled,
          'data': ranked,
        }),
        headers: _jsonHeaders,
      );
    } catch (e, stack) {
      print('[SMART_PRIORITY] recalculateAll error: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal menghitung ulang prioritas Fuzzy.',
        }),
        headers: _jsonHeaders,
      );
    }
  }
}
