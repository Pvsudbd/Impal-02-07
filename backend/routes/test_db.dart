import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../lib/config/db.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    final results = await Database.query('SELECT COUNT(*) AS total FROM users');
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
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'status': 'error',
        'framework': 'Dart Frog',
        'message': 'Gagal terhubung ke database server: $e',
      },
    );
  }
}

