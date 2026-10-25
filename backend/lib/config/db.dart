import 'package:dotenv/dotenv.dart';
import 'package:mysql_client/mysql_client.dart';

class Database {
  static MySQLConnection? _connection;
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
  static String get dbName => _env['DB_NAME'] ?? 'db_manajemen_tugas';

  static Future<MySQLConnection> getConnection() async {
    init();
    if (_connection == null || !_connection!.connected) {
      _connection = await MySQLConnection.createConnection(
        host: _env['DB_HOST'] ?? 'localhost',
        port: int.tryParse(_env['DB_PORT'] ?? '3306') ?? 3306,
        userName: _env['DB_USER'] ?? 'admin',
        password: _env['DB_PASSWORD'] ?? 'password123',
        databaseName: dbName,
      );
      await _connection!.connect();
    }
    return _connection!;
  }

  static Future<IResultSet> query(String sql, [Map<String, dynamic>? params]) async {
    final conn = await getConnection();
    return await conn.execute(sql, params ?? {});
  }
}
