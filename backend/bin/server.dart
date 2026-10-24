import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import '../lib/config/db.dart';
import '../lib/routes/auth/auth_routes.dart';

void main(List<String> args) async {
  Database.init();

  final app = Router();

  // Root route - cek server hidup
  app.get('/', (Request request) {
    return Response.ok(
      jsonEncode({'message': 'Backend Impal-02-07 (Dart Shelf) berjalan!'}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Test DB connection
  app.get('/test-db', (Request request) async {
    try {
      final results = await Database.query('SELECT COUNT(*) FROM student');
      final total = results.isNotEmpty ? results.first[0] : 0;
      return Response.ok(
        jsonEncode({
          'status': 'success',
          'message': 'Koneksi ke database berhasil!',
          'database': Database.settings.db,
          'totalStudents': total,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': 'Gagal konek ke database',
          'detail': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Test get tables
  app.get('/tables', (Request request) async {
    try {
      final results = await Database.query('SHOW TABLES');
      final tables = results.map((r) => r.values?.first?.toString() ?? '').toList();
      return Response.ok(
        jsonEncode({
          'status': 'success',
          'database': Database.settings.db,
          'tables': tables,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'error',
          'message': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Mount Auth routes under /api/auth
  app.mount('/api/auth/', AuthRoutes().router);

  // Global Pipeline with CORS & Logger
  final handler = const Pipeline().addMiddleware(corsHeaders()).addMiddleware(logRequests()).addHandler(app);

  final port = int.tryParse(Database.envPort) ?? 3000;
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);

  print('========================================================');
  print('🚀 Backend Dart (Shelf) berjalan di http://localhost:${server.port}');
  print('📊 Test DB : http://localhost:${server.port}/test-db');
  print('📋 Tabel   : http://localhost:${server.port}/tables');
  print('🔐 Auth    : http://localhost:${server.port}/api/auth/login');
  print('========================================================');
}
