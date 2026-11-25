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

/// Wrapper around an active PostgreSQL transaction session.
class DbTransaction {
  final TxSession _tx;

  DbTransaction._(this._tx);

  Future<QueryResult> query(String sql, [Map<String, dynamic>? params]) {
    return Database._executeOn(_tx, sql, params);
  }
}

class Database {
  static Pool<void>? _pool;
  static late DotEnv _env;
  static bool _initialized = false;

  static void init() {
    if (!_initialized) {
      _env = DotEnv(includePlatformEnvironment: true)..load();
      _initialized = true;
    }
  }

  static String _requireEnv(String key) {
    init();
    final value = _env[key]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing required environment variable: $key. '
        'Copy .env.example to .env and configure it.',
      );
    }
    return value;
  }

  static String get envPort {
    init();
    return _env['PORT']?.trim().isNotEmpty == true ? _env['PORT']!.trim() : '3000';
  }

  static String get jwtSecret => _requireEnv('JWT_SECRET');
  static String get dbName => _requireEnv('DB_NAME');

  /// Returns the shared PostgreSQL connection pool, initializing it on first use.
  static Pool<void> getPool() {
    init();
    if (_pool == null) {
      final host = _requireEnv('DB_HOST');
      final portStr = _env['DB_PORT']?.trim();
      final port = int.tryParse(portStr ?? '5432') ?? 5432;
      final user = _requireEnv('DB_USER');
      final password = _requireEnv('DB_PASSWORD');
      final database = dbName;
      final maxConn = int.tryParse(_env['DB_POOL_MAX']?.trim() ?? '10') ?? 10;
      final sslMode = (_env['DB_SSL']?.trim().toLowerCase() == 'true')
          ? SslMode.require
          : SslMode.disable;

      _pool = Pool.withEndpoints(
        [
          Endpoint(
            host: host,
            port: port,
            database: database,
            username: user,
            password: password,
          ),
        ],
        settings: PoolSettings(
          maxConnectionCount: maxConn,
          sslMode: sslMode,
          connectTimeout: const Duration(seconds: 10),
          queryTimeout: const Duration(seconds: 15),
          idleCheckAfter: const Duration(seconds: 30),
        ),
      );
    }
    return _pool!;
  }

  static Future<QueryResult> _executeOn(
    Session session,
    String sql, [
    Map<String, dynamic>? params,
  ]) async {
    // Normalize backticks to double quotes and :param placeholders to @param
    var pgSql = sql.replaceAll('`', '"');

    final effectiveParams = <String, dynamic>{};
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

    if (effectiveParams.isNotEmpty) {
      final result = await session.execute(
        Sql.named(pgSql),
        parameters: effectiveParams,
      );
      final rows = result.map((r) => QueryRow(r.toColumnMap(), r.toList())).toList();
      return QueryResult(rows, affectedRows: result.affectedRows);
    } else {
      final result = await session.execute(pgSql);
      final rows = result.map((r) => QueryRow(r.toColumnMap(), r.toList())).toList();
      return QueryResult(rows, affectedRows: result.affectedRows);
    }
  }

  /// Executes a single SQL statement on the shared connection pool.
  static Future<QueryResult> query(String sql, [Map<String, dynamic>? params]) {
    return _executeOn(getPool(), sql, params);
  }

  /// Executes [action] atomically inside a PostgreSQL database transaction.
  static Future<T> transaction<T>(
    Future<T> Function(DbTransaction tx) action,
  ) {
    return getPool().runTx((txSession) => action(DbTransaction._(txSession)));
  }

  /// Closes the shared connection pool gracefully.
  static Future<void> close() async {
    await _pool?.close();
    _pool = null;
  }
}
