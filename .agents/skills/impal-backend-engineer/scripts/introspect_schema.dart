import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

/// Read-only PostgreSQL schema introspection tool for Impal-02-07.
///
/// Run from `Impal-02-07/backend`:
///   dart run --packages=.dart_tool/package_config.json ../.agents/skills/impal-backend-engineer/scripts/introspect_schema.dart
///   dart run --packages=.dart_tool/package_config.json ../.agents/skills/impal-backend-engineer/scripts/introspect_schema.dart --write
Future<void> main(List<String> args) async {
  final shouldWrite = args.contains('--write');

  final envFile = File('.env');
  if (!envFile.existsSync()) {
    stderr.writeln('Error: .env not found in ${Directory.current.path}');
    exit(1);
  }

  final env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
  final host = env['DB_HOST']?.trim() ?? '';
  final port = int.tryParse(env['DB_PORT']?.trim() ?? '5432') ?? 5432;
  final database = env['DB_NAME']?.trim() ?? '';
  final username = env['DB_USER']?.trim() ?? '';
  final password = env['DB_PASSWORD']?.trim() ?? '';
  final sslMode = env['DB_SSL']?.trim().toLowerCase() == 'true'
      ? SslMode.require
      : SslMode.disable;

  if (host.isEmpty || database.isEmpty || username.isEmpty || password.isEmpty) {
    stderr.writeln('Error: Missing DB_* variables in .env');
    exit(1);
  }

  final conn = await Connection.open(
    Endpoint(
      host: host,
      port: port,
      database: database,
      username: username,
      password: password,
    ),
    settings: ConnectionSettings(
      sslMode: sslMode,
      connectTimeout: const Duration(seconds: 10),
    ),
  );

  try {
    final colRows = await conn.execute('''
      SELECT table_name, column_name, data_type, character_maximum_length, is_nullable, column_default
      FROM information_schema.columns
      WHERE table_schema = 'public'
      ORDER BY table_name, ordinal_position
    ''');

    final idxRows = await conn.execute('''
      SELECT tablename, indexname
      FROM pg_indexes
      WHERE schemaname = 'public'
      ORDER BY tablename, indexname
    ''');

    final tables = <String, List<Map<String, String>>>{};
    for (final r in colRows) {
      final table = r[0].toString();
      final col = r[1].toString();
      final type = r[2].toString();
      final maxLen = r[3]?.toString();
      final nullable = r[4].toString();
      final def = r[5]?.toString();

      final fullType = maxLen != null ? '$type($maxLen)' : type;
      tables.putIfAbsent(table, () => []).add({
        'column': col,
        'type': fullType,
        'nullable': nullable,
        'default': def ?? '',
      });
    }

    final indexes = <String, List<String>>{};
    for (final r in idxRows) {
      indexes.putIfAbsent(r[0].toString(), () => []).add(r[1].toString());
    }

    final buf = StringBuffer();
    buf.writeln('# Live PostgreSQL Schema Snapshot (`$database`)');
    buf.writeln();
    buf.writeln(
      '> Generated from live PostgreSQL (`$host:$port`) via `scripts/introspect_schema.dart`.',
    );
    buf.writeln(
      '> Always re-run `dart run ../.agents/skills/impal-backend-engineer/scripts/introspect_schema.dart --write` from `Impal-02-07/backend` after team schema updates.',
    );
    buf.writeln();
    buf.writeln('## Critical Schema Gotchas');
    buf.writeln();
    buf.writeln('1. **User Foreign Key:** Every user-owned table uses `id_user` (never `id_student`).');
    buf.writeln('2. **Integer Flags (`0`/`1`):** `task.is_completed`, `task.is_fuzzy_auto`, `group_task.is_completed`, `group_task.is_fuzzy_auto`, `group_sub_task.is_completed`, `notification.is_read`, `todo_item.is_done` are `integer` (use `= 1` / `= 0`, never `IS TRUE`).');
    buf.writeln("3. **Priority Length:** `task.priority` and `group_task.priority` are `character varying(6)` (`HIGH`, `MEDIUM`, `LOW` — `'VERY HIGH'` does NOT fit!).");
    buf.writeln('4. **No Legacy Cascade FKs:** Legacy tables lack `ON DELETE CASCADE` FKs in live DB — always delete children explicitly inside `Database.transaction`.');
    buf.writeln('5. **No Default Timestamps on Legacy Tables:** `users.created_at/updated_at` and `agenda.created_at/updated_at` have `default = null` — set `NOW()` explicitly in `INSERT`/`UPDATE`.');
    buf.writeln();
    buf.writeln('---');
    buf.writeln();
    buf.writeln('## Tables (${tables.length})');
    buf.writeln();

    var idx = 1;
    for (final entry in tables.entries) {
      final table = entry.key;
      buf.writeln('### $idx. `$table`');
      for (final c in entry.value) {
        final defPart = c['default']!.isNotEmpty ? ', default=`${c['default']}`' : '';
        buf.writeln(
          '- `${c['column']}`: `${c['type']}` (nullable=${c['nullable']}$defPart)',
        );
      }
      final tableIdxs = indexes[table];
      if (tableIdxs != null && tableIdxs.isNotEmpty) {
        buf.writeln('- Indexes: ${tableIdxs.map((i) => '`$i`').join(', ')}');
      }
      buf.writeln();
      idx++;
    }

    if (shouldWrite) {
      final target = File(
        '../.agents/skills/impal-backend-engineer/references/live_schema_snapshot.md',
      );
      target.parent.createSync(recursive: true);
      target.writeAsStringSync(buf.toString());
      stdout.writeln('Updated ${target.path} (${tables.length} tables).');
    } else {
      stdout.writeln('Introspected ${tables.length} tables from $database:');
      for (final entry in tables.entries) {
        stdout.writeln('  - ${entry.key} (${entry.value.length} columns)');
      }
      stdout.writeln('Run with --write to regenerate live_schema_snapshot.md.');
    }
  } finally {
    await conn.close();
  }
}
