import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../lib/config/db.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    final results = await Database.query(
      "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename",
    );
    final tables = results.rows.map((r) => r.colAt(0)?.toString() ?? '').toList();
    return Response.json(
      body: {
        'status': 'success',
        'framework': 'Dart Frog',
        'database': Database.dbName,
        'tables': tables,
      },
    );
  } catch (e) {
    print('[TABLES] error: $e');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'framework': 'Dart Frog',
        'message': 'Gagal mengambil daftar tabel database.',
      },
    );
  }
}
