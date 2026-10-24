import 'package:dotenv/dotenv.dart';
import 'package:mysql1/mysql1.dart';

class Database {
  static MySqlConnection? _connection;
  static late final DotEnv _env;
  static bool _initialized = false;

  static void init() {
    if (!_initialized) {
      _env = DotEnv(includePlatformEnvironment: true)..load();
      _initialized = true;
    }
  }

  static String get envPort => _env['PORT'] ?? '3000';
  static String get jwtSecret => _env['JWT_SECRET'] ?? 'impal07_secret_key_ganti_ini_di_production';

  static ConnectionSettings get settings {
    init();
    return ConnectionSettings(
      host: _env['DB_HOST'] ?? 'localhost',
      port: int.tryParse(_env['DB_PORT'] ?? '3306') ?? 3306,
      user: _env['DB_USER'] ?? 'admin',
      password: _env['DB_PASSWORD'] ?? 'password123',
      db: _env['DB_NAME'] ?? 'db_manajemen_tugas',
    );
  }

  static Future<MySqlConnection> getConnection() async {
    try {
      if (_connection == null) {
        _connection = await MySqlConnection.connect(settings);
      }
      return _connection!;
    } catch (e) {
      // Reconnect if connection was closed
      _connection = await MySqlConnection.connect(settings);
      return _connection!;
    }
  }

  static Future<Results> query(String sql, [List<Object?>? values]) async {
    final conn = await getConnection();
    return await conn.query(sql, values);
  }
}
