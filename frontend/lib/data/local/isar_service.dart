import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'collections/agenda_collection.dart';
import 'collections/course_collection.dart';
import 'collections/task_collection.dart';
import 'collections/todo_item_collection.dart';
import 'collections/user_collection.dart';

/// Service Singleton untuk mengelola basis data lokal Isar DB.
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

  /// Mengambil semua tugas pengguna yang tersimpan lokal (sorted by deadline)
  Future<List<TaskCollection>> getAllTasks(String idUser) async {
    return await taskCol
        .filter()
        .idUserEqualTo(idUser)
        .sortByDeadline()
        .findAll();
  }

  /// Watcher stream untuk UI reaktif: otomatis memancarkan data saat ada perubahan
  Stream<List<TaskCollection>> watchTasks(String idUser) {
    return taskCol
        .filter()
        .idUserEqualTo(idUser)
        .sortByDeadline()
        .watch(fireImmediately: true);
  }

  /// Menyimpan atau memperbarui tugas ke Isar DB
  Future<void> saveTask(TaskCollection task) async {
    await isar.writeTxn(() async {
      await taskCol.put(task);
    });
  }

  /// Menghapus tugas dari Isar DB berdasarkan remoteId
  Future<void> deleteTaskByRemoteId(String remoteId) async {
    await isar.writeTxn(() async {
      await taskCol.filter().remoteIdEqualTo(remoteId).deleteAll();
    });
  }

  /// Mengambil semua tugas yang belum tersinkronisasi ke server (isSynced == false)
  Future<List<TaskCollection>> getUnsyncedTasks() async {
    return await taskCol.filter().isSyncedEqualTo(false).findAll();
  }

  // ─── KOLEKSI AGENDA (JADWAL) ───────────────────────────────────────────────
  IsarCollection<AgendaCollection> get agendaCol => isar.collection<AgendaCollection>();

  /// Mengambil seluruh agenda harian pengguna
  Future<List<AgendaCollection>> getAllAgendas(String idUser) async {
    return await agendaCol.filter().idUserEqualTo(idUser).findAll();
  }

  /// Watcher stream untuk kalender harian reaktif
  Stream<List<AgendaCollection>> watchAgendas(String idUser) {
    return agendaCol
        .filter()
        .idUserEqualTo(idUser)
        .watch(fireImmediately: true);
  }

  /// Menyimpan atau memperbarui agenda ke Isar DB
  Future<void> saveAgenda(AgendaCollection agenda) async {
    await isar.writeTxn(() async {
      await agendaCol.put(agenda);
    });
  }

  /// Menghapus agenda berdasarkan remoteId
  Future<void> deleteAgendaByRemoteId(String remoteId) async {
    await isar.writeTxn(() async {
      await agendaCol.filter().remoteIdEqualTo(remoteId).deleteAll();
    });
  }

  /// Mengambil agenda yang belum tersinkronisasi ke server
  Future<List<AgendaCollection>> getUnsyncedAgendas() async {
    return await agendaCol.filter().isSyncedEqualTo(false).findAll();
  }

  // ─── KOLEKSI USER (CACHE PROFIL) ───────────────────────────────────────────
  IsarCollection<UserCollection> get userCol => isar.collection<UserCollection>();

  /// Mengambil cache profil pengguna aktif
  Future<UserCollection?> getCachedUser(String idUser) async {
    return await userCol.filter().remoteIdEqualTo(idUser).findFirst();
  }

  /// Menyimpan cache profil pengguna
  Future<void> saveUserCache(UserCollection user) async {
    await isar.writeTxn(() async {
      // Hapus cache lama jika ada
      await userCol.filter().remoteIdEqualTo(user.remoteId).deleteAll();
      await userCol.put(user);
    });
  }

  // ─── KOLEKSI CHECKLIST TO-DO ───────────────────────────────────────────────
  IsarCollection<TodoItemCollection> get todoCol => isar.collection<TodoItemCollection>();

  /// Mengambil daftar to-do item untuk tanggal tertentu
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

  /// Toggle status checklist to-do
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

  // ─── UTILITY PEMBERSIHAN DATA SIKLUS HIDUP ─────────────────────────────────
  /// Membersihkan seluruh database lokal (digunakan saat pengguna Logout)
  Future<void> clearAll() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }
}
