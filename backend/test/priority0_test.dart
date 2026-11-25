import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'package:backend/config/db.dart';
import 'package:backend/controllers/agenda/agenda_controller.dart';
import 'package:backend/controllers/auth/auth_controller.dart';
import 'package:backend/controllers/course/course_controller.dart';
import 'package:backend/controllers/profile/profile_controller.dart';
import 'package:backend/middleware/auth/auth_middleware.dart';

void main() {
  const uuid = Uuid();
  final runId = DateTime.now().millisecondsSinceEpoch;
  final emailA = 'p0test_a_$runId@example.com';
  final emailB = 'p0test_b_$runId@example.com';
  const password = 'Password123';
  final testCourseId = uuid.v4();
  final createdUserIds = <String>[];
  final createdAgendaIds = <String>[];
  final createdCourseIds = <String>[testCourseId];
  final createdTaskIds = <String>[];

  late String userAId;
  late String userBId;
  late String tokenA;
  late String tokenB;

  Request jsonRequest(
    String method,
    String path, {
    Object? body,
    String? rawBody,
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
      body: rawBody ?? (body != null ? jsonEncode(body) : null),
    );
  }

  Future<Response> authed(
    Handler handler,
    Request req,
  ) async {
    return await checkAuthMiddleware()(handler)(req);
  }

  setUpAll(() {
    Database.init();
    Database.getPool();
  });

  tearDownAll(() async {
    try {
      for (final idTask in createdTaskIds) {
        await Database.query(
          'DELETE FROM task WHERE id_task = :id',
          {'id': idTask},
        );
      }
      for (final idAgenda in createdAgendaIds) {
        await Database.query(
          'DELETE FROM course_schedule WHERE id_agenda = :id',
          {'id': idAgenda},
        );
        await Database.query(
          'DELETE FROM personal_schedule WHERE id_agenda = :id',
          {'id': idAgenda},
        );
        await Database.query(
          'DELETE FROM agenda WHERE id_agenda = :id',
          {'id': idAgenda},
        );
      }
      for (final idUser in createdUserIds) {
        await Database.query(
          'DELETE FROM task WHERE id_user = :id',
          {'id': idUser},
        );
        await Database.query(
          'DELETE FROM course_schedule WHERE id_agenda IN (SELECT id_agenda FROM agenda WHERE id_user = :id)',
          {'id': idUser},
        );
        await Database.query(
          'DELETE FROM personal_schedule WHERE id_agenda IN (SELECT id_agenda FROM agenda WHERE id_user = :id)',
          {'id': idUser},
        );
        await Database.query(
          'DELETE FROM agenda WHERE id_user = :id',
          {'id': idUser},
        );
        await Database.query(
          'DELETE FROM course WHERE id_user = :id',
          {'id': idUser},
        );
        await Database.query(
          'DELETE FROM users WHERE id_user = :id',
          {'id': idUser},
        );
      }
      for (final idCourse in createdCourseIds) {
        await Database.query(
          'DELETE FROM course WHERE id_course = :id',
          {'id': idCourse},
        );
      }
    } finally {
      await Database.close();
    }
  });

  group('Priority 0 Auth Validation & Login', () {
    test('rejects invalid registration payloads with 400', () async {
      final badEmailRes = await AuthController.register(
        jsonRequest('POST', '/api/auth/register', body: {
          'name': 'Test',
          'email': 'invalid-email',
          'password': password,
        }),
      );
      expect(badEmailRes.statusCode, 400);

      final shortPwRes = await AuthController.register(
        jsonRequest('POST', '/api/auth/register', body: {
          'name': 'Test',
          'email': 'short_$runId@example.com',
          'password': '123',
        }),
      );
      expect(shortPwRes.statusCode, 400);

      final spacePwRes = await AuthController.register(
        jsonRequest('POST', '/api/auth/register', body: {
          'name': 'Test',
          'email': 'space_$runId@example.com',
          'password': 'pass word',
        }),
      );
      expect(spacePwRes.statusCode, 400);

      final malformedRes = await AuthController.register(
        jsonRequest('POST', '/api/auth/register', rawBody: '{not-json'),
      );
      expect(malformedRes.statusCode, 400);
    });

    test('registers users, rejects case-insensitive duplicate (409), and logs in', () async {
      final regA = await AuthController.register(
        jsonRequest('POST', '/api/auth/register', body: {
          'name': 'Priority Zero A',
          'email': emailA,
          'password': password,
        }),
      );
      expect(regA.statusCode, 201);
      final regABody = jsonDecode(await regA.readAsString()) as Map<String, dynamic>;
      userAId = regABody['idUser'] as String;
      createdUserIds.add(userAId);

      // Case-insensitive duplicate email -> 409 Conflict
      final dupRes = await AuthController.register(
        jsonRequest('POST', '/api/auth/register', body: {
          'name': 'Dup',
          'email': emailA.toUpperCase(),
          'password': password,
        }),
      );
      expect(dupRes.statusCode, 409);

      final regB = await AuthController.register(
        jsonRequest('POST', '/api/auth/register', body: {
          'name': 'Priority Zero B',
          'email': emailB,
          'password': password,
        }),
      );
      expect(regB.statusCode, 201);
      userBId = (jsonDecode(await regB.readAsString()) as Map<String, dynamic>)['idUser'] as String;
      createdUserIds.add(userBId);

      final loginA = await AuthController.login(
        jsonRequest('POST', '/api/auth/login', body: {
          'email': emailA.toUpperCase(),
          'password': password,
        }),
      );
      expect(loginA.statusCode, 200);
      tokenA = (jsonDecode(await loginA.readAsString()) as Map<String, dynamic>)['token'] as String;

      final loginB = await AuthController.login(
        jsonRequest('POST', '/api/auth/login', body: {
          'email': emailB,
          'password': password,
        }),
      );
      expect(loginB.statusCode, 200);
      tokenB = (jsonDecode(await loginB.readAsString()) as Map<String, dynamic>)['token'] as String;
    });
  });

  group('Priority 0 Profile Aggregation & Email Uniqueness', () {
    test('reads integer 0/1 task counts accurately and returns 409 on duplicate email', () async {
      await Database.query(
        '''
        INSERT INTO course (id_course, id_user, course_name, credits, created_at, updated_at)
        VALUES (:idCourse, :uid, :courseName, 3, NOW(), NOW())
        ''',
        {
          'idCourse': testCourseId,
          'uid': userAId,
          'courseName': 'P0 Course $runId',
        },
      );

      final doneTaskId = uuid.v4();
      final pendingTaskId = uuid.v4();
      createdTaskIds.addAll([doneTaskId, pendingTaskId]);

      await Database.query(
        '''
        INSERT INTO task (id_task, id_user, id_course, task_title, deadline, grade_weight, priority_score, priority, is_fuzzy_auto, is_completed, created_at, updated_at)
        VALUES
          (:doneId, :uid, :idCourse, 'Done Task', NOW() + INTERVAL '1 day', 20, 50, 'MEDIUM', 1, 1, NOW(), NOW()),
          (:pendId, :uid, :idCourse, 'Pending Task', NOW() + INTERVAL '2 days', 30, 80, 'HIGH', 1, 0, NOW(), NOW())
        ''',
        {
          'doneId': doneTaskId,
          'pendId': pendingTaskId,
          'uid': userAId,
          'idCourse': testCourseId,
        },
      );

      final profRes = await authed(
        ProfileController.getProfile,
        jsonRequest('GET', '/api/profile', token: tokenA),
      );
      expect(profRes.statusCode, 200);
      final profJson = jsonDecode(await profRes.readAsString()) as Map<String, dynamic>;
      final stats = (profJson['data'] as Map<String, dynamic>)['statistics'] as Map<String, dynamic>;
      expect(stats['tasksDoneCount'], 1);
      expect(stats['tasksPendingCount'], 1);

      final remRes = await authed(
        ProfileController.viewRemainingTasks,
        jsonRequest('GET', '/api/profile/remaining-tasks', token: tokenA),
      );
      expect(remRes.statusCode, 200);
      final remJson = jsonDecode(await remRes.readAsString()) as Map<String, dynamic>;
      expect(remJson['total'], 1);

      final badUpdate = await authed(
        ProfileController.updateProfile,
        jsonRequest('PUT', '/api/profile', token: tokenA, body: {
          'name': 'Updated Name',
          'email': 'not-an-email',
        }),
      );
      expect(badUpdate.statusCode, 400);

      final dupUpdate = await authed(
        ProfileController.updateProfile,
        jsonRequest('PUT', '/api/profile', token: tokenA, body: {
          'name': 'Updated Name',
          'email': emailB,
        }),
      );
      expect(dupUpdate.statusCode, 409);
    });
  });

  group('Priority 0 Agenda CRUD, Validation, BOLA & Orphan-Free Delete', () {
    test('CourseSchedule CRUD, id_course resolution, case-insensitive reuse, BOLA, and clean delete', () async {
      final courseNameOne = 'P0 Algo $runId';
      final invalidTimeRes = await authed(
        AgendaController.createCourseSchedule,
        jsonRequest('POST', '/api/agenda/course', token: tokenA, body: {
          'title': 'Invalid Time Course',
          'timeStart': '11:00',
          'timeEnd': '09:00',
          'course': courseNameOne,
          'day': 'Monday',
          'room': 'R101',
        }),
      );
      expect(invalidTimeRes.statusCode, 400);

      final createRes = await authed(
        AgendaController.createCourseSchedule,
        jsonRequest('POST', '/api/agenda/course', token: tokenA, body: {
          'title': 'Algoritma Pemrograman',
          'timeStart': '08:00',
          'timeEnd': '10:00',
          'course': courseNameOne,
          'day': 'Monday',
          'room': 'KTT-201',
        }),
      );
      expect(createRes.statusCode, 201);
      final createdData = (jsonDecode(await createRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final agendaId = createdData['idAgenda'] as String;
      final createdCourseId = createdData['idCourse'] as String;
      createdAgendaIds.add(agendaId);
      createdCourseIds.add(createdCourseId);
      expect(createdData['day'], 'Senin');
      expect(createdCourseId, isNotEmpty);
      expect(createdData['courseName'], courseNameOne);
      expect(createdData['course'], courseNameOne);

      // Case-insensitive reuse of existing course
      final reuseRes = await authed(
        AgendaController.createCourseSchedule,
        jsonRequest('POST', '/api/agenda/course', token: tokenA, body: {
          'title': 'Algoritma Pemrograman',
          'timeStart': '13:00',
          'timeEnd': '15:00',
          'course': courseNameOne.toUpperCase(),
          'day': 'Wednesday',
          'room': 'KTT-202',
        }),
      );
      expect(reuseRes.statusCode, 201);
      final reuseData = (jsonDecode(await reuseRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final reuseAgendaId = reuseData['idAgenda'] as String;
      createdAgendaIds.add(reuseAgendaId);
      expect(reuseData['idCourse'], createdCourseId);

      // Delete second schedule before deleting course
      final delReuseRes = await authed(
        (req) => AgendaController.deleteCourseSchedule(req, reuseAgendaId),
        jsonRequest('DELETE', '/api/agenda/course/$reuseAgendaId', token: tokenA),
      );
      expect(delReuseRes.statusCode, 200);

      // BOLA: User B cannot update or delete User A's course schedule
      final bolaPut = await authed(
        (req) => AgendaController.updateCourseSchedule(req, agendaId),
        jsonRequest('PUT', '/api/agenda/course/$agendaId', token: tokenB, body: {'title': 'Hacked'}),
      );
      expect(bolaPut.statusCode, 404);

      final bolaDel = await authed(
        (req) => AgendaController.deleteCourseSchedule(req, agendaId),
        jsonRequest('DELETE', '/api/agenda/course/$agendaId', token: tokenB),
      );
      expect(bolaDel.statusCode, 404);

      // Update with new course name, English day, and startTime/endTime aliases
      final updatedCourseName = 'P0 Algo Lanjut $runId';
      final updateRes = await authed(
        (req) => AgendaController.updateCourseSchedule(req, agendaId),
        jsonRequest('PUT', '/api/agenda/course/$agendaId', token: tokenA, body: {
          'title': 'Algoritma Lanjut',
          'startTime': '09:00',
          'endTime': '11:30',
          'course': updatedCourseName,
          'day': 'Tuesday',
          'room': 'KTT-302',
        }),
      );
      expect(updateRes.statusCode, 200);
      final updatedData = (jsonDecode(await updateRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final updatedCourseId = updatedData['idCourse'] as String;
      createdCourseIds.add(updatedCourseId);
      expect(updatedData['day'], 'Selasa');
      expect(updatedData['courseName'], updatedCourseName);
      expect(updatedData['course'], updatedCourseName);
      expect(updatedData['timeStart'], '09:00');
      expect(updatedData['timeEnd'], '11:30');

      // Delete and verify zero orphan rows in both agenda & course_schedule
      final delRes = await authed(
        (req) => AgendaController.deleteCourseSchedule(req, agendaId),
        jsonRequest('DELETE', '/api/agenda/course/$agendaId', token: tokenA),
      );
      expect(delRes.statusCode, 200);

      final parentCheck = await Database.query(
        'SELECT COUNT(*) FROM agenda WHERE id_agenda = :id',
        {'id': agendaId},
      );
      final childCheck = await Database.query(
        'SELECT COUNT(*) FROM course_schedule WHERE id_agenda = :id',
        {'id': agendaId},
      );
      expect(int.parse(parentCheck.rows.first.colAt(0).toString()), 0);
      expect(int.parse(childCheck.rows.first.colAt(0).toString()), 0);
    });

    test('PersonalSchedule CRUD and orphan-free delete', () async {
      final createRes = await authed(
        AgendaController.createPersonalSchedule,
        jsonRequest('POST', '/api/agenda/personal', token: tokenA, body: {
          'title': 'Sprint Sync',
          'type': 'Meeting',
          'timeStart': '13:00',
          'timeEnd': '14:00',
          'date': '2026-11-26',
          'location': 'https://meet.google.com/abc-defg',
        }),
      );
      expect(createRes.statusCode, 201);
      final createdData = (jsonDecode(await createRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final agendaId = createdData['idAgenda'] as String;
      createdAgendaIds.add(agendaId);
      expect(createdData['type'], 'Meeting');

      final delRes = await authed(
        (req) => AgendaController.deletePersonalSchedule(req, agendaId),
        jsonRequest('DELETE', '/api/agenda/personal/$agendaId', token: tokenA),
      );
      expect(delRes.statusCode, 200);

      final parentCheck = await Database.query(
        'SELECT COUNT(*) FROM agenda WHERE id_agenda = :id',
        {'id': agendaId},
      );
      final childCheck = await Database.query(
        'SELECT COUNT(*) FROM personal_schedule WHERE id_agenda = :id',
        {'id': agendaId},
      );
      expect(int.parse(parentCheck.rows.first.colAt(0).toString()), 0);
      expect(int.parse(childCheck.rows.first.colAt(0).toString()), 0);
    });
  });

  group('Course Catalog & 30 Custom Course Quota (/api/courses)', () {
    test('lists, creates, rejects duplicate (409), edits in place, enforces BOLA, guards in-use delete, and enforces 30-course quota', () async {
      final listRes = await authed(
        CourseController.listCourses,
        jsonRequest('GET', '/api/courses', token: tokenB),
      );
      expect(listRes.statusCode, 200);
      final listJson = jsonDecode(await listRes.readAsString()) as Map<String, dynamic>;
      expect(listJson['maxCustomCourses'], 30);
      expect(listJson['data'], isA<List<dynamic>>());

      final alphaName = 'Custom Course Alpha $runId';
      final createRes = await authed(
        CourseController.createCourse,
        jsonRequest('POST', '/api/courses', token: tokenB, body: {
          'courseName': alphaName,
          'credits': 3,
        }),
      );
      expect(createRes.statusCode, 201);
      final createData = (jsonDecode(await createRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final customId = createData['idCourse'] as String;
      createdCourseIds.add(customId);
      expect(createData['isCustom'], true);
      expect(createData['idUser'], userBId);

      // Case-insensitive duplicate -> 409
      final dupRes = await authed(
        CourseController.createCourse,
        jsonRequest('POST', '/api/courses', token: tokenB, body: {
          'courseName': alphaName.toUpperCase(),
        }),
      );
      expect(dupRes.statusCode, 409);

      // Edit in place -> 200
      final editedName = 'Custom Course Edited $runId';
      final putRes = await authed(
        (req) => CourseController.updateCourse(req, customId),
        jsonRequest('PUT', '/api/courses/$customId', token: tokenB, body: {
          'courseName': editedName,
          'credits': 4,
        }),
      );
      expect(putRes.statusCode, 200);
      final putData = (jsonDecode(await putRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      expect(putData['idCourse'], customId);
      expect(putData['courseName'], editedName);
      expect(putData['credits'], 4);

      // BOLA: User A cannot edit or delete User B's custom course
      final bolaPut = await authed(
        (req) => CourseController.updateCourse(req, customId),
        jsonRequest('PUT', '/api/courses/$customId', token: tokenA, body: {
          'courseName': 'Hijacked',
        }),
      );
      expect(bolaPut.statusCode, 404);

      final bolaDel = await authed(
        (req) => CourseController.deleteCourse(req, customId),
        jsonRequest('DELETE', '/api/courses/$customId', token: tokenA),
      );
      expect(bolaDel.statusCode, 404);

      // Create schedule referencing customId -> delete blocked (409) until schedule is removed
      final schedRes = await authed(
        AgendaController.createCourseSchedule,
        jsonRequest('POST', '/api/agenda/course', token: tokenB, body: {
          'title': 'Kuliah Custom',
          'timeStart': '10:00',
          'timeEnd': '12:00',
          'idCourse': customId,
          'day': 'Thursday',
          'room': 'R202',
        }),
      );
      expect(schedRes.statusCode, 201);
      final schedAgendaId = ((jsonDecode(await schedRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>)['idAgenda'] as String;
      createdAgendaIds.add(schedAgendaId);

      final blockedDel = await authed(
        (req) => CourseController.deleteCourse(req, customId),
        jsonRequest('DELETE', '/api/courses/$customId', token: tokenB),
      );
      expect(blockedDel.statusCode, 409);

      final delSchedRes = await authed(
        (req) => AgendaController.deleteCourseSchedule(req, schedAgendaId),
        jsonRequest('DELETE', '/api/agenda/course/$schedAgendaId', token: tokenB),
      );
      expect(delSchedRes.statusCode, 200);

      final allowedDel = await authed(
        (req) => CourseController.deleteCourse(req, customId),
        jsonRequest('DELETE', '/api/courses/$customId', token: tokenB),
      );
      expect(allowedDel.statusCode, 200);

      // Seed 29 custom courses for User B, verify 30th succeeds (201) and 31st fails (400)
      for (var i = 1; i <= 29; i++) {
        final seedId = uuid.v4();
        createdCourseIds.add(seedId);
        await Database.query(
          '''
          INSERT INTO course (id_course, id_user, course_name, credits, created_at, updated_at)
          VALUES (:idCourse, :idUser, :name, 3, NOW(), NOW())
          ''',
          {
            'idCourse': seedId,
            'idUser': userBId,
            'name': 'Quota Seed $i $runId',
          },
        );
      }

      final thirtiethRes = await authed(
        CourseController.createCourse,
        jsonRequest('POST', '/api/courses', token: tokenB, body: {
          'courseName': 'Quota 30th $runId',
        }),
      );
      expect(thirtiethRes.statusCode, 201);
      final thirtiethId = ((jsonDecode(await thirtiethRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>)['idCourse'] as String;
      createdCourseIds.add(thirtiethId);

      final thirtyFirstRes = await authed(
        CourseController.createCourse,
        jsonRequest('POST', '/api/courses', token: tokenB, body: {
          'courseName': 'Quota 31st $runId',
        }),
      );
      expect(thirtyFirstRes.statusCode, 400);

      // Auto-create via CourseSchedule must also obey the 30-course quota
      final thirtyFirstSchedRes = await authed(
        AgendaController.createCourseSchedule,
        jsonRequest('POST', '/api/agenda/course', token: tokenB, body: {
          'title': 'Quota Overflow Schedule',
          'timeStart': '14:00',
          'timeEnd': '16:00',
          'course': 'Quota Overflow Course $runId',
          'day': 'Friday',
          'room': 'R303',
        }),
      );
      expect(thirtyFirstSchedRes.statusCode, 400);
    });
  });

  group('Priority 0 Pool Concurrency', () {
    test('handles 10 concurrent queries via Pool without connection errors', () async {
      final results = await Future.wait(
        List.generate(10, (i) => Database.query('SELECT :n::int AS val', {'n': i})),
      );
      for (var i = 0; i < 10; i++) {
        expect(results[i].rows.first.colAt(0), i);
      }
    });
  });
}
