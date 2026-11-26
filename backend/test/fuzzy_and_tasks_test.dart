import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import 'package:backend/config/db.dart';
import 'package:backend/controllers/auth/auth_controller.dart';
import 'package:backend/controllers/smart_priority/smart_priority_controller.dart';
import 'package:backend/controllers/task/task_controller.dart';
import 'package:backend/middleware/auth/auth_middleware.dart';
import 'package:backend/services/fuzzy_mamdani_service.dart';

void main() {
  final runId = DateTime.now().millisecondsSinceEpoch;
  final emailA = 'fuzzy_a_$runId@example.com';
  final emailB = 'fuzzy_b_$runId@example.com';
  const password = 'Password123';

  final createdUserIds = <String>[];
  late String userAId;
  late String userBId;
  late String tokenA;
  late String tokenB;

  Request jsonRequest(
    String method,
    String path, {
    Object? body,
    String? token,
  }) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['authorization'] = 'Bearer $token';
    }
    return Request(
      method,
      Uri.parse('http://localhost:3000$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<Response> authed(Handler handler, Request req) async {
    return await checkAuthMiddleware()(handler)(req);
  }

  group('Stage 1: FuzzyMamdaniService Mathematical Unit Tests', () {
    final fixedNow = DateTime(2026, 11, 26, 12, 0);

    test('urgent deadline (24h) + high weight (35%) yields HIGH with XAI fields', () {
      final result = FuzzyMamdaniService.evaluate(
        deadline: fixedNow.add(const Duration(hours: 24)),
        gradeWeight: 35.0,
        now: fixedNow,
      );

      expect(result.level, 'HIGH');
      expect(result.score, greaterThanOrEqualTo(65.0));
      expect(result.deadlineParam.membershipValues['Urgent'], closeTo(0.85, 0.01));
      expect(result.courseWeightParam.dominantTerm, 'High');
      expect(result.reasonExplanation, contains('Centroid (CoG)'));
      expect(result.firedRules, isNotEmpty);
    });

    test('overdue task (< 0h) + high weight produces maximum urgent membership and HIGH level', () {
      final result = FuzzyMamdaniService.evaluate(
        deadline: fixedNow.subtract(const Duration(hours: 10)),
        gradeWeight: 45.0,
        now: fixedNow,
      );

      expect(result.level, 'HIGH');
      expect(result.score, greaterThanOrEqualTo(80.0));
      expect(result.timeLeftText, contains('Overdue'));
      expect(result.deadlineParam.membershipValues['Urgent'], 1.0);
    });

    test('moderate deadline (120h) + medium weight (25%) yields MEDIUM around 50.0', () {
      final result = FuzzyMamdaniService.evaluate(
        deadline: fixedNow.add(const Duration(hours: 120)),
        gradeWeight: 25.0,
        now: fixedNow,
      );

      expect(result.level, 'MEDIUM');
      expect(result.score, closeTo(50.0, 2.0));
      expect(result.deadlineParam.dominantTerm, 'Moderate');
      expect(result.courseWeightParam.dominantTerm, 'Medium');
    });

    test('relaxed deadline (14 days) + low weight (10%) yields LOW', () {
      final result = FuzzyMamdaniService.evaluate(
        deadline: fixedNow.add(const Duration(days: 14)),
        gradeWeight: 10.0,
        now: fixedNow,
      );

      expect(result.level, 'LOW');
      expect(result.score, lessThan(38.0));
      expect(result.deadlineParam.dominantTerm, 'Relaxed');
      expect(result.courseWeightParam.dominantTerm, 'Low');
    });

    test('monotonicity: closer deadline and higher weight increase or preserve score', () {
      final relaxedLow = FuzzyMamdaniService.evaluate(
        deadline: fixedNow.add(const Duration(days: 12)),
        gradeWeight: 10.0,
        now: fixedNow,
      );
      final moderateMed = FuzzyMamdaniService.evaluate(
        deadline: fixedNow.add(const Duration(days: 5)),
        gradeWeight: 25.0,
        now: fixedNow,
      );
      final urgentHigh = FuzzyMamdaniService.evaluate(
        deadline: fixedNow.add(const Duration(hours: 6)),
        gradeWeight: 50.0,
        now: fixedNow,
      );

      expect(moderateMed.score, greaterThan(relaxedLow.score));
      expect(urgentHigh.score, greaterThan(moderateMed.score));
    });
  });

  group('Stages 2 & 3: /api/tasks CRUD & /api/smart-priority Integration', () {
    setUpAll(() async {
      Database.init();
      Database.getPool();

      final regA = await AuthController.register(
        jsonRequest('POST', '/api/auth/register', body: {
          'name': 'Fuzzy Test A',
          'email': emailA,
          'password': password,
        }),
      );
      userAId = (jsonDecode(await regA.readAsString()) as Map<String, dynamic>)['idUser'] as String;
      createdUserIds.add(userAId);

      final regB = await AuthController.register(
        jsonRequest('POST', '/api/auth/register', body: {
          'name': 'Fuzzy Test B',
          'email': emailB,
          'password': password,
        }),
      );
      userBId = (jsonDecode(await regB.readAsString()) as Map<String, dynamic>)['idUser'] as String;
      createdUserIds.add(userBId);

      final loginA = await AuthController.login(
        jsonRequest('POST', '/api/auth/login', body: {
          'email': emailA,
          'password': password,
        }),
      );
      tokenA = (jsonDecode(await loginA.readAsString()) as Map<String, dynamic>)['token'] as String;

      final loginB = await AuthController.login(
        jsonRequest('POST', '/api/auth/login', body: {
          'email': emailB,
          'password': password,
        }),
      );
      tokenB = (jsonDecode(await loginB.readAsString()) as Map<String, dynamic>)['token'] as String;
    });

    tearDownAll(() async {
      try {
        for (final idUser in createdUserIds) {
          await Database.query('DELETE FROM task WHERE id_user = :id', {'id': idUser});
          await Database.query('DELETE FROM course WHERE id_user = :id', {'id': idUser});
          await Database.query('DELETE FROM users WHERE id_user = :id', {'id': idUser});
        }
      } finally {
        await Database.close();
      }
    });

    test('creates tasks with auto-Fuzzy, enforces validation & BOLA, ranks via /api/smart-priority, toggles complete, recalculates, and auto-cleans custom course', () async {
      // 1. Invalid gradeWeight -> 400
      final badTaskRes = await authed(
        TaskController.createTask,
        jsonRequest('POST', '/api/tasks', token: tokenA, body: {
          'title': 'Bad Task',
          'deadline': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
          'gradeWeight': 150,
        }),
      );
      expect(badTaskRes.statusCode, 400);

      // 2. Create critical task (12h, 45%) with custom course
      final customCourseName = 'Fuzzy AI Course $runId';
      final criticalRes = await authed(
        TaskController.createTask,
        jsonRequest('POST', '/api/tasks', token: tokenA, body: {
          'title': 'Critical Fuzzy Task',
          'description': 'Final sprint report',
          'courseName': customCourseName,
          'deadline': DateTime.now().add(const Duration(hours: 12)).toIso8601String(),
          'gradeWeight': 45,
          'isFuzzyAuto': true,
          'tags': ['Assignment', 'IMPAL'],
        }),
      );
      expect(criticalRes.statusCode, 201);
      final criticalData = (jsonDecode(await criticalRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final criticalTaskId = criticalData['idTask'] as String;
      final customCourseId = criticalData['idCourse'] as String;
      expect(criticalData['priority'], 'HIGH');
      expect((criticalData['priorityScore'] as num).toDouble(), greaterThanOrEqualTo(65.0));
      expect(criticalData['tags'], ['Assignment', 'IMPAL']);

      // 3. Create relaxed low task (14 days, 10%)
      final lowRes = await authed(
        TaskController.createTask,
        jsonRequest('POST', '/api/tasks', token: tokenA, body: {
          'title': 'Relaxed Low Task',
          'deadline': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
          'gradeWeight': 10,
          'isFuzzyAuto': true,
        }),
      );
      expect(lowRes.statusCode, 201);
      final lowData = (jsonDecode(await lowRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final lowTaskId = lowData['idTask'] as String;
      expect(lowData['priority'], 'LOW');
      expect((lowData['priorityScore'] as num).toDouble(), lessThan(38.0));

      // 4. BOLA: User B cannot read, update, or delete User A's task
      final bolaGet = await authed(
        (req) => TaskController.getTask(req, criticalTaskId),
        jsonRequest('GET', '/api/tasks/$criticalTaskId', token: tokenB),
      );
      expect(bolaGet.statusCode, 404);

      final bolaDel = await authed(
        (req) => TaskController.deleteTask(req, criticalTaskId),
        jsonRequest('DELETE', '/api/tasks/$criticalTaskId', token: tokenB),
      );
      expect(bolaDel.statusCode, 404);

      // 5. GET /api/smart-priority ranks critical task #1 and low task #2
      final spRes = await authed(
        SmartPriorityController.getSmartPriority,
        jsonRequest('GET', '/api/smart-priority', token: tokenA),
      );
      expect(spRes.statusCode, 200);
      final spJson = jsonDecode(await spRes.readAsString()) as Map<String, dynamic>;
      final spData = spJson['data'] as List<dynamic>;
      expect(spData.length, 2);
      expect((spData[0] as Map<String, dynamic>)['idTask'], criticalTaskId);
      expect((spData[0] as Map<String, dynamic>)['rank'], 1);
      expect((spData[1] as Map<String, dynamic>)['idTask'], lowTaskId);
      expect((spData[1] as Map<String, dynamic>)['rank'], 2);

      // 6. POST /api/smart-priority/evaluate preview
      final evalRes = await authed(
        SmartPriorityController.evaluatePreview,
        jsonRequest('POST', '/api/smart-priority/evaluate', token: tokenA, body: {
          'deadline': DateTime.now().add(const Duration(hours: 120)).toIso8601String(),
          'gradeWeight': 25,
        }),
      );
      expect(evalRes.statusCode, 200);
      final evalData = (jsonDecode(await evalRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      expect(evalData['level'], 'MEDIUM');

      // 7. Update low task deadline to 8h and weight to 50% -> auto-Fuzzy updates to HIGH
      final updateLowRes = await authed(
        (req) => TaskController.updateTask(req, lowTaskId),
        jsonRequest('PUT', '/api/tasks/$lowTaskId', token: tokenA, body: {
          'deadline': DateTime.now().add(const Duration(hours: 8)).toIso8601String(),
          'gradeWeight': 50,
        }),
      );
      expect(updateLowRes.statusCode, 200);
      final updatedLowData = (jsonDecode(await updateLowRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      expect(updatedLowData['priority'], 'HIGH');

      // 8. Mark critical task completed -> excluded from /api/smart-priority active ranking
      final compRes = await authed(
        (req) => TaskController.toggleComplete(req, criticalTaskId),
        jsonRequest('PATCH', '/api/tasks/$criticalTaskId/complete', token: tokenA, body: {
          'isCompleted': true,
        }),
      );
      expect(compRes.statusCode, 200);

      final spAfterComp = await authed(
        SmartPriorityController.getSmartPriority,
        jsonRequest('GET', '/api/smart-priority', token: tokenA),
      );
      expect(spAfterComp.statusCode, 200);
      final activeAfterComp = (jsonDecode(await spAfterComp.readAsString()) as Map<String, dynamic>)['data'] as List<dynamic>;
      expect(activeAfterComp.length, 1);
      expect((activeAfterComp[0] as Map<String, dynamic>)['idTask'], lowTaskId);

      // 9. POST /api/smart-priority/recalculate updates active tasks in DB
      final recalcRes = await authed(
        SmartPriorityController.recalculateAll,
        jsonRequest('POST', '/api/smart-priority/recalculate', token: tokenA),
      );
      expect(recalcRes.statusCode, 200);
      final recalcJson = jsonDecode(await recalcRes.readAsString()) as Map<String, dynamic>;
      expect(recalcJson['updatedCount'], 1);

      // 10. Deleting criticalTaskId auto-cleans unused customCourseId
      final delCriticalRes = await authed(
        (req) => TaskController.deleteTask(req, criticalTaskId),
        jsonRequest('DELETE', '/api/tasks/$criticalTaskId', token: tokenA),
      );
      expect(delCriticalRes.statusCode, 200);

      final cleanedCourseCheck = await Database.query(
        'SELECT COUNT(*) FROM course WHERE id_course = :id',
        {'id': customCourseId},
      );
      expect(int.parse(cleanedCourseCheck.rows.first.colAt(0).toString()), 0);

      final delLowRes = await authed(
        (req) => TaskController.deleteTask(req, lowTaskId),
        jsonRequest('DELETE', '/api/tasks/$lowTaskId', token: tokenA),
      );
      expect(delLowRes.statusCode, 200);
    });
  });
}
