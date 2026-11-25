import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'collections/agenda_collection.dart';
import 'collections/course_collection.dart';
import 'collections/group_collection.dart';
import 'collections/tag_collection.dart';
import 'collections/task_collection.dart';
import 'collections/todo_item_collection.dart';
import 'collections/user_collection.dart';

/// Service Singleton untuk mengelola basis data lokal Isar DB (Native IO: Android/Windows/macOS/Linux).
///
/// Menyediakan akses lokal 0ms (Offline-First) untuk seluruh fitur klien Flutter.
class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  Isar? _isar;

  /// Mengembalikan instance aktif Isar DB
  Isar get isar {
    if (_isar == null) {
      throw StateError(
        'IsarService belum diinisialisasi. Panggil await IsarService().init() terlebih dahulu.',
      );
    }
    return _isar!;
  }

  bool get isInitialized => _isar != null && _isar!.isOpen;

  /// Inisialisasi Isar DB saat aplikasi pertama kali dijalankan.
  Future<void> init() async {
    if (isInitialized) return;

    try {
      String? dirPath;
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        dirPath = dir.path;
      }

      _isar = await Isar.open(
        [
          TaskCollectionSchema,
          AgendaCollectionSchema,
          UserCollectionSchema,
          CourseCollectionSchema,
          TodoItemCollectionSchema,
          GroupCollectionSchema,
          TagCollectionSchema,
        ],
        directory: dirPath ?? '',
        name: 'impal_smart_todolist_db',
        inspector: kDebugMode,
      );

      debugPrint('[ISAR_SERVICE] Isar DB berhasil dibuka di: $dirPath');
    } catch (e) {
      debugPrint('[ISAR_SERVICE] Error saat inisialisasi Isar DB: $e');
      rethrow;
    }
  }

  // ─── KOLEKSI TASK (TUGAS) ──────────────────────────────────────────────────
  IsarCollection<TaskCollection> get taskCol => isar.collection<TaskCollection>();

  Future<List<TaskCollection>> getAllTasks(String idUser) async {
    return await taskCol
        .filter()
        .idUserEqualTo(idUser)
        .sortByDeadline()
        .findAll();
  }

  Stream<List<TaskCollection>> watchTasks(String idUser) {
    return taskCol
        .filter()
        .idUserEqualTo(idUser)
        .sortByDeadline()
        .watch(fireImmediately: true);
  }

  Future<void> saveTask(TaskCollection task) async {
    await isar.writeTxn(() async {
      await taskCol.put(task);
    });
  }

  Future<void> deleteTaskByRemoteId(String remoteId) async {
    await isar.writeTxn(() async {
      await taskCol.filter().remoteIdEqualTo(remoteId).deleteAll();
    });
  }

  Future<List<TaskCollection>> getUnsyncedTasks() async {
    return await taskCol.filter().isSyncedEqualTo(false).findAll();
  }

  // ─── KOLEKSI AGENDA (JADWAL) ───────────────────────────────────────────────
  IsarCollection<AgendaCollection> get agendaCol => isar.collection<AgendaCollection>();

  Future<List<AgendaCollection>> getAllAgendas(String idUser) async {
    return await agendaCol.filter().idUserEqualTo(idUser).findAll();
  }

  Stream<List<AgendaCollection>> watchAgendas(String idUser) {
    return agendaCol
        .filter()
        .idUserEqualTo(idUser)
        .watch(fireImmediately: true);
  }

  Future<void> saveAgenda(AgendaCollection agenda) async {
    await isar.writeTxn(() async {
      await agendaCol.put(agenda);
    });
  }

  Future<void> deleteAgendaByRemoteId(String remoteId) async {
    await isar.writeTxn(() async {
      await agendaCol.filter().remoteIdEqualTo(remoteId).deleteAll();
    });
  }

  Future<List<AgendaCollection>> getUnsyncedAgendas() async {
    return await agendaCol.filter().isSyncedEqualTo(false).findAll();
  }

  // ─── KOLEKSI USER (CACHE PROFIL) ───────────────────────────────────────────
  IsarCollection<UserCollection> get userCol => isar.collection<UserCollection>();

  Future<UserCollection?> getCachedUser(String idUser) async {
    return await userCol.filter().remoteIdEqualTo(idUser).findFirst();
  }

  Future<void> saveUserCache(UserCollection user) async {
    await isar.writeTxn(() async {
      await userCol.filter().remoteIdEqualTo(user.remoteId).deleteAll();
      await userCol.put(user);
    });
  }

  // ─── KOLEKSI CHECKLIST TO-DO ───────────────────────────────────────────────
  IsarCollection<TodoItemCollection> get todoCol => isar.collection<TodoItemCollection>();

  Future<List<TodoItemCollection>> getTodoItemsByDate(String idUser, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return await todoCol
        .filter()
        .idUserEqualTo(idUser)
        .and()
        .dateBetween(startOfDay, endOfDay)
        .findAll();
  }

  Future<void> toggleTodoItem(int localId) async {
    await isar.writeTxn(() async {
      final item = await todoCol.get(localId);
      if (item != null) {
        item.isDone = !item.isDone;
        item.updatedAt = DateTime.now();
        item.isSynced = false;
        item.syncAction = 'UPDATE';
        await todoCol.put(item);
      }
    });
  }

  // ─── KOLEKSI KELOMPOK (GROUPS) ─────────────────────────────────────────────
  IsarCollection<GroupCollection> get groupCol => isar.collection<GroupCollection>();

  Future<List<GroupCollection>> getAllGroups() async {
    return await groupCol.where().sortByCreatedAtDesc().findAll();
  }

  Stream<List<GroupCollection>> watchGroups() {
    return groupCol.where().sortByCreatedAtDesc().watch(fireImmediately: true);
  }

  Future<GroupCollection?> getGroupByRemoteId(String remoteId) async {
    return await groupCol.filter().remoteIdEqualTo(remoteId).findFirst();
  }

  Future<void> saveGroup(GroupCollection group) async {
    await isar.writeTxn(() async {
      await groupCol.put(group);
    });
  }

  Future<void> saveGroups(List<GroupCollection> groups) async {
    await isar.writeTxn(() async {
      await groupCol.putAll(groups);
    });
  }

  Future<void> updateGroupSize(String remoteId, int groupSize) async {
    await isar.writeTxn(() async {
      final group = await groupCol.filter().remoteIdEqualTo(remoteId).findFirst();
      if (group != null) {
        group.groupSize = groupSize < 1 ? 1 : groupSize;
        group.updatedAt = DateTime.now();
        await groupCol.put(group);
      }
    });
  }

  Future<void> deleteGroupByRemoteId(String remoteId) async {
    await isar.writeTxn(() async {
      await groupCol.filter().remoteIdEqualTo(remoteId).deleteAll();
    });
  }

  // ─── KOLEKSI CUSTOM TASK TAGS (TASK_TAGS) ─────────────────────────────────
  IsarCollection<TagCollection> get tagCol => isar.collection<TagCollection>();

  Future<List<TagCollection>> getAllTags(String idUser) async {
    return await tagCol.filter().idUserEqualTo(idUser).sortByLabel().findAll();
  }

  Stream<List<TagCollection>> watchTags(String idUser) {
    return tagCol
        .filter()
        .idUserEqualTo(idUser)
        .sortByLabel()
        .watch(fireImmediately: true);
  }

  Future<void> saveTag(TagCollection tag) async {
    await isar.writeTxn(() async {
      await tagCol.put(tag);
    });
  }

  Future<void> saveTags(List<TagCollection> tags) async {
    await isar.writeTxn(() async {
      await tagCol.putAll(tags);
    });
  }

  Future<void> deleteTagByRemoteId(String remoteId) async {
    await isar.writeTxn(() async {
      await tagCol.filter().remoteIdEqualTo(remoteId).deleteAll();
    });
  }

  Future<List<TagCollection>> getUnsyncedTags() async {
    return await tagCol.filter().isSyncedEqualTo(false).findAll();
  }

  // ─── PLATFORM-SAFE MAP HELPERS FOR SHARED REPOSITORIES ────────────────────
  Future<List<Map<String, dynamic>>> getCustomTagMaps(String idUser) async {
    final rows = await getAllTags(idUser);
    return rows
        .map((t) => {
              'id': t.remoteId,
              'label': t.label,
              'background_color': t.backgroundColor,
              'text_color': t.textColor,
              'is_default': t.isDefault,
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> getUnsyncedCustomTagMaps() async {
    final rows = await getUnsyncedTags();
    return rows
        .where((t) => !t.isDefault)
        .map((t) => {
              'id': t.remoteId,
              'label': t.label,
              'background_color': t.backgroundColor,
              'text_color': t.textColor,
              'is_default': t.isDefault,
            })
        .toList();
  }

  Future<void> saveCustomTagMap(
    Map<String, dynamic> tagMap, {
    required String idUser,
    required bool isSynced,
  }) async {
    final col = TagCollection()
      ..remoteId = (tagMap['id'] ?? '').toString()
      ..idUser = idUser
      ..label = (tagMap['label'] ?? '').toString()
      ..backgroundColor = (tagMap['background_color'] as num?)?.toInt() ?? 0xFF778BEB
      ..textColor = (tagMap['text_color'] as num?)?.toInt() ?? 0xFF1E296B
      ..isDefault = tagMap['is_default'] == true
      ..updatedAt = DateTime.now()
      ..isSynced = isSynced
      ..syncAction = isSynced ? null : 'INSERT';
    await saveTag(col);
  }

  Future<void> saveCustomTagMaps(
    List<Map<String, dynamic>> tagMaps, {
    required String idUser,
    required bool isSynced,
  }) async {
    final collections = tagMaps
        .map((tagMap) => TagCollection()
          ..remoteId = (tagMap['id'] ?? '').toString()
          ..idUser = idUser
          ..label = (tagMap['label'] ?? '').toString()
          ..backgroundColor = (tagMap['background_color'] as num?)?.toInt() ?? 0xFF778BEB
          ..textColor = (tagMap['text_color'] as num?)?.toInt() ?? 0xFF1E296B
          ..isDefault = tagMap['is_default'] == true
          ..updatedAt = DateTime.now()
          ..isSynced = isSynced
          ..syncAction = isSynced ? null : 'INSERT')
        .toList();
    if (collections.isNotEmpty) {
      await saveTags(collections);
    }
  }

  Future<Map<String, dynamic>?> getUserPreferencesMap(String idUser) async {
    if (!isInitialized) await init();
    final existing = await userCol.filter().remoteIdEqualTo(idUser).findFirst();
    final raw = existing?.preferencesJson;
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  Future<void> saveUserPreferencesMap(
    String idUser,
    Map<String, dynamic> preferences, {
    String? name,
    String? email,
    required bool isSynced,
  }) async {
    if (!isInitialized) await init();
    await isar.writeTxn(() async {
      final existing = await userCol.filter().remoteIdEqualTo(idUser).findFirst();
      final col = existing ?? UserCollection()
        ..remoteId = idUser
        ..name = name ?? ''
        ..email = email ?? '';
      if (name != null && name.isNotEmpty) col.name = name;
      if (email != null && email.isNotEmpty) col.email = email;
      col.preferencesJson = jsonEncode(preferences);
      col.updatedAt = DateTime.now();
      col.isSynced = isSynced;
      await userCol.put(col);
    });
  }

  // ─── UTILITY PEMBERSIHAN DATA SIKLUS HIDUP ─────────────────────────────────
  Future<void> clearAll() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }
}

