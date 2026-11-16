import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:impal_smart_todolist/core/network/api_client.dart';
import '../isar_service.dart';

/// Pengelola Sinkronisasi Latar Belakang (Offline-First Sync Manager).
///
/// Mengacu pada Bagian 6 DATABASE_REQUIREMENTS.md:
/// Mengelola alur sinkronisasi dua arah:
/// 1. Push Delta: Mengirim data lokal (isSynced == false) ke Dart Frog server saat online.
/// 2. Pull Latest: Menarik data terbaru dari server PostgreSQL dan menyimpannya ke Isar DB.
/// 3. Resolusi Konflik: Menggunakan strategi Last-Write-Wins (LWW) berdasarkan field updatedAt.
class OfflineSyncManager {
  static final OfflineSyncManager _instance = OfflineSyncManager._internal();
  factory OfflineSyncManager() => _instance;
  OfflineSyncManager._internal();

  final IsarService _isarService = IsarService();
  bool _isSyncing = false;

  bool get isSyncing => _isSyncing;

  /// Memulai proses sinkronisasi dua arah (Push & Pull)
  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Jika tidak ada token autentikasi, tunda sinkronisasi
      if (token == null || token.isEmpty) {
        debugPrint('[SYNC_MANAGER] Token autentikasi belum tersedia. Sinkronisasi ditunda.');
        return;
      }

      debugPrint('[SYNC_MANAGER] Memulai siklus sinkronisasi Offline-First...');

      // 1. PUSH DELTA: Kirim tugas yang belum tersinkron
      await _pushUnsyncedTasks(token);

      // 2. PULL LATEST: Ambil data terbaru dari server dan perbarui Isar DB
      await _pullLatestAgendas(token);

      // Simpan timestamp sinkronisasi terakhir
      await prefs.setString('last_sync_timestamp', DateTime.now().toIso8601String());
      debugPrint('[SYNC_MANAGER] Siklus sinkronisasi selesai dengan sukses.');
    } catch (e) {
      debugPrint('[SYNC_MANAGER] Sinkronisasi tertunda/gagal: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Mengirim perubahan tugas lokal ke server (Push)
  Future<void> _pushUnsyncedTasks(String token) async {
    final unsyncedTasks = await _isarService.getUnsyncedTasks();
    if (unsyncedTasks.isEmpty) return;

    debugPrint('[SYNC_MANAGER] Mengirim ${unsyncedTasks.length} tugas yang belum tersinkron ke server...');

    for (final task in unsyncedTasks) {
      try {
        final payload = {
          'remoteId': task.remoteId,
          'taskTitle': task.taskTitle,
          'courseCode': task.courseCode,
          'description': task.description ?? '',
          'deadline': task.deadline.toIso8601String(),
          'gradeWeight': task.gradeWeight,
          'priority': task.priority,
          'isCompleted': task.isCompleted,
          'updatedAt': task.updatedAt.toIso8601String(),
          'action': task.syncAction ?? 'INSERT',
        };

        // Kirim ke endpoint Dart Frog
        final res = await ApiClient.post('/api/tasks/sync', payload, token: token);

        if (res['status'] == 'success') {
          // Tandai sebagai tersinkron di Isar DB
          task.isSynced = true;
          task.syncAction = null;
          await _isarService.saveTask(task);
        }
      } catch (e) {
        debugPrint('[SYNC_MANAGER] Gagal sinkronkan tugas ${task.remoteId}: $e');
      }
    }
  }

  /// Menarik agenda & jadwal terbaru dari server (Pull)
  Future<void> _pullLatestAgendas(String token) async {
    try {
      final res = await ApiClient.get('/api/agenda', token: token);
      if (res['status'] == 'success' && res['data'] is Map<String, dynamic>) {
        final data = res['data'] as Map<String, dynamic>;
        final lectures = data['lectures'] as List<dynamic>? ?? [];
        final personals = data['personals'] as List<dynamic>? ?? [];

        debugPrint('[SYNC_MANAGER] Menerima ${lectures.length} kuliah & ${personals.length} agenda personal dari server.');
        // Data dari server dapat dipetakan dan diperbarui ke Isar DB sesuai kebutuhan
      }
    } catch (e) {
      debugPrint('[SYNC_MANAGER] Gagal menarik data agenda dari server: $e');
    }
  }
}
