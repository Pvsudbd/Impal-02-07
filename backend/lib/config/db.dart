import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

class QueryRow {
  final Map<String, dynamic> _data;
  final List<dynamic> _columns;

  QueryRow(this._data, this._columns);

  Map<String, dynamic> assoc() => _data;
  dynamic colAt(int index) => (index >= 0 && index < _columns.length) ? _columns[index] : null;
  dynamic operator [](String key) => _data[key];
}

class QueryResult {
  final List<QueryRow> rows;
  final int affectedRows;

  QueryResult(this.rows, {this.affectedRows = 0});
}

class Database {
  static Connection? _connection;
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

  static Future<Connection> getConnection() async {
    init();
    if (_connection == null || !_connection!.isOpen) {
      final host = _env['DB_HOST'] ?? '172.22.245.175';
      final port = int.tryParse(_env['DB_PORT'] ?? '5432') ?? 5432;
      final user = _env['DB_USER'] ?? 'Todolist_Dev';
      final password = _env['DB_PASSWORD'] ?? 'ProjectImpal227';
      final database = dbName;
      final sslMode = (_env['DB_SSL']?.toLowerCase() == 'true')
          ? SslMode.require
          : SslMode.disable;

      _connection = await Connection.open(
        Endpoint(
          host: host,
          port: port,
          database: database,
          username: user,
          password: password,
        ),
        settings: ConnectionSettings(
          sslMode: sslMode,
        ),
      );
    }
    return _connection!;
  }

  static Future<QueryResult> query(String sql, [Map<String, dynamic>? params]) async {
    final conn = await getConnection();

    // Auto-normalize MySQL dialect into PostgreSQL dialect
    // 1. Ganti backtick `groups` menjadi double quote "groups"
    var pgSql = sql.replaceAll('`', '"');

    // 2. Normalisasi named parameter dari MySQL style (:param) ke PostgreSQL Sql.named style (@param)
    var effectiveParams = <String, dynamic>{};
    if (params != null && params.isNotEmpty) {
      for (final key in params.keys) {
        pgSql = pgSql.replaceAllMapped(
          RegExp('(?<!:):(?!:)$key\\b'),
          (_) => '@$key',
        );
      }
      for (final entry in params.entries) {
        if (pgSql.contains('@${entry.key}')) {
          effectiveParams[entry.key] = entry.value;
        }
      }
    }

    try {
      if (effectiveParams.isNotEmpty) {
        final result = await conn.execute(
          Sql.named(pgSql),
          parameters: effectiveParams,
        );
        final rows = result.map((r) => QueryRow(r.toColumnMap(), r.toList())).toList();
        return QueryResult(rows, affectedRows: result.affectedRows);
      } else {
        final result = await conn.execute(pgSql);
        final rows = result.map((r) => QueryRow(r.toColumnMap(), r.toList())).toList();
        return QueryResult(rows, affectedRows: result.affectedRows);
      }
    } catch (e) {
      // Re-connect jika koneksi terputus
      if (e.toString().contains('closed') || e.toString().contains('broken')) {
        _connection = null;
        final retryConn = await getConnection();
        if (effectiveParams.isNotEmpty) {
          final result = await retryConn.execute(
            Sql.named(pgSql),
            parameters: effectiveParams,
          );
          final rows = result.map((r) => QueryRow(r.toColumnMap(), r.toList())).toList();
          return QueryResult(rows, affectedRows: result.affectedRows);
        } else {
          final result = await retryConn.execute(pgSql);
          final rows = result.map((r) => QueryRow(r.toColumnMap(), r.toList())).toList();
          return QueryResult(rows, affectedRows: result.affectedRows);
        }
      }
      rethrow;
    }
  }
}
