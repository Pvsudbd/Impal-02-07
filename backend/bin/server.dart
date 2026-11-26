import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../lib/config/db.dart';
import '../lib/middleware/cors_middleware.dart';
import '../lib/middleware/database_provider.dart';
import '../lib/routes/auth/auth_routes.dart';
import '../lib/routes/agenda/agenda_routes.dart';
import '../lib/routes/course/course_routes.dart';
import '../lib/routes/kelompok/group_routes.dart';
import '../lib/routes/notifications/notification_routes.dart';
import '../lib/routes/profile/profile_routes.dart';
import '../lib/routes/smart_priority/smart_priority_routes.dart';
import '../lib/routes/tags/tag_routes.dart';
import '../lib/routes/task/task_routes.dart';
import '../lib/routes/todo/todo_routes.dart';

void main(List<String> args) async {
  Database.init();
  Database.getPool();

  final app = Router();

  // ─── ROOT ENDPOINT ────────────────────────────────────────────────────────
  app.get('/', (RequestContext context) {
    return Response.json(
      body: {
        'status': 'success',
        'framework': 'Dart Frog',
        'version': '1.2.6',
        'message':
            'Backend Impal-02-07 (Dart Frog REST API) berjalan dengan sukses!',
        'endpoints': {
          'root': '/',
          'testDb': '/test-db',
          'tables': '/tables',
          'auth': '/api/auth',
          'agenda': '/api/agenda',
          'courses': '/api/courses',
          'tasks': '/api/tasks',
          'task': '/api/task',
          'todo': '/api/todo',
          'tags': '/api/tags',
          'notifications': '/api/notifications',
          'smartPriority': '/api/smart-priority',
          'groups': '/api/groups',
          'team': '/api/team',
          'course': '/api/agenda/course',
          'personal': '/api/agenda/personal',
          'profile': '/api/profile',
        },
      },
    );
  });

  // ─── TEST DB CONNECTION ───────────────────────────────────────────────────
  app.get('/test-db', (RequestContext context) async {
    try {
      final results =
          await Database.query('SELECT COUNT(*) AS total FROM users');
      final total = results.rows.isNotEmpty ? results.rows.first.colAt(0) : 0;
      return Response.json(
        body: {
          'status': 'success',
          'framework': 'Dart Frog',
          'message': 'Koneksi ke database PostgreSQL berhasil!',
          'database': Database.dbName,
          'totalUsers': total,
          'totalStudents': total,
        },
      );
    } catch (e) {
      print('[SERVER] DB connection error: $e');
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'status': 'error',
          'framework': 'Dart Frog',
          'message': 'Gagal terhubung ke database server.',
        },
      );
    }
  });

  // ─── TEST GET TABLES ──────────────────────────────────────────────────────
  app.get('/tables', (RequestContext context) async {
    try {
      final results = await Database.query(
        "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename",
      );
      final tables =
          results.rows.map((r) => r.colAt(0)?.toString() ?? '').toList();
      return Response.json(
        body: {
          'status': 'success',
          'framework': 'Dart Frog',
          'database': Database.dbName,
          'tables': tables,
        },
      );
    } catch (e) {
      print('[SERVER] Get tables error: $e');
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'status': 'error',
          'framework': 'Dart Frog',
          'message': 'Gagal mengambil daftar tabel database.',
        },
      );
    }
  });

  // ─── MOUNT SUB-ROUTERS ────────────────────────────────────────────────────
  // 1. Mount Auth routes under /api/auth
  app.mount('/api/auth', fromShelfHandler(AuthRoutes().router));

  // 2. Mount Agenda routes under /api/agenda
  app.mount('/api/agenda', fromShelfHandler(AgendaRoutes().router));

  // 3. Mount Course catalog routes under /api/courses
  app.mount('/api/courses', fromShelfHandler(CourseRoutes().router));

  // 4. Mount Task CRUD routes under /api/tasks and /api/task
  final taskRoutes = fromShelfHandler(TaskRoutes().router);
  app.mount('/api/tasks', taskRoutes);
  app.mount('/api/task', taskRoutes);

  // 5. Mount Smart Priority Fuzzy XAI routes under /api/smart-priority
  app.mount(
    '/api/smart-priority',
    fromShelfHandler(SmartPriorityRoutes().router),
  );

  // 6. Mount Groups / Team routes under /api/groups and /api/team
  final groupRoutes = fromShelfHandler(GroupRoutes().router);
  app.mount('/api/groups', groupRoutes);
  app.mount('/api/team', groupRoutes);

  // 7. Mount Todo routes under /api/todo
  app.mount('/api/todo', fromShelfHandler(TodoRoutes().router));

  // 8. Mount Tag routes under /api/tags and /api/v1/tags
  final tagRoutes = fromShelfHandler(TagRoutes().router);
  app.mount('/api/tags', tagRoutes);
  app.mount('/api/v1/tags', tagRoutes);

  // 9. Mount Notification routes under /api/notifications and /api/v1/notifications
  final notificationRoutes = fromShelfHandler(NotificationRoutes().router);
  app.mount('/api/notifications', notificationRoutes);
  app.mount('/api/v1/notifications', notificationRoutes);

  // 10. Mount Profile routes under /api/profile, /api/user, and /api/student
  final profileRoutes = fromShelfHandler(ProfileRoutes().router);
  app.mount('/api/profile', profileRoutes);
  app.mount('/api/user', profileRoutes);
  app.mount('/api/student', profileRoutes);

  // ─── GLOBAL DART FROG PIPELINE ────────────────────────────────────────────
  final handler = const Pipeline()
      .addMiddleware(corsMiddleware())
      .addMiddleware(requestLogger())
      .addMiddleware(databaseProvider())
      .addHandler(app.call);

  final port = int.tryParse(Database.envPort) ?? 3000;
  final server = await serve(handler, InternetAddress.anyIPv4, port);

  try {
    ProcessSignal.sigint.watch().listen((_) async {
      await server.close(force: true);
      await Database.close();
      exit(0);
    });
  } catch (_) {
    // Signal watching may be unsupported in some embedded runners
  }

  print('========================================================');
  print('🚀 Backend Dart Frog berjalan di http://localhost:${server.port}');
  print('📊 Test DB : http://localhost:${server.port}/test-db');
  print('📋 Tabel   : http://localhost:${server.port}/tables');
  print('🔐 Auth    : http://localhost:${server.port}/api/auth/login');
  print('📚 Courses : http://localhost:${server.port}/api/courses');
  print('📝 Tasks   : http://localhost:${server.port}/api/tasks');
  print('🧠 FuzzyAI : http://localhost:${server.port}/api/smart-priority');
  print('👥 Groups  : http://localhost:${server.port}/api/groups');
  print('📅 Jadwal  : http://localhost:${server.port}/api/agenda');
  print('📅 Kuliah  : http://localhost:${server.port}/api/agenda/course');
  print('📅 Personal: http://localhost:${server.port}/api/agenda/personal');
  print('👤 Profil  : http://localhost:${server.port}/api/profile');
  print('👤 User    : http://localhost:${server.port}/api/user');
  print('========================================================');
}
