import 'package:dart_frog/dart_frog.dart';
import '../config/db.dart';

/// Dart Frog Middleware untuk Dependency Injection koneksi Database.
/// Menyediakan instance [Database] ke [RequestContext] yang dapat diakses melalui `context.read<Database>()`.
Middleware databaseProvider() {
  return provider<Database>((context) {
    Database.init();
    return Database();
  });
}

