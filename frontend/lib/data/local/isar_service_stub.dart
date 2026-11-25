/// Web stub untuk [IsarService].
///
/// Isar 3.x menggunakan hash integer 64-bit dan C-FFI native yang tidak
/// kompatibel dengan compiler JavaScript Web (batas presisi integer 53-bit).
/// Pada platform Web, persistence mengandalkan PostgreSQL REST API & SharedPreferences.
class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  bool get isInitialized => false;

  Future<void> init() async {}

  Future<List<Map<String, dynamic>>> getCustomTagMaps(String idUser) async => const [];

  Future<List<Map<String, dynamic>>> getUnsyncedCustomTagMaps() async => const [];

  Future<void> saveCustomTagMap(
    Map<String, dynamic> tagMap, {
    required String idUser,
    required bool isSynced,
  }) async {}

  Future<void> saveCustomTagMaps(
    List<Map<String, dynamic>> tagMaps, {
    required String idUser,
    required bool isSynced,
  }) async {}

  Future<void> deleteTagByRemoteId(String remoteId) async {}

  Future<Map<String, dynamic>?> getUserPreferencesMap(String idUser) async => null;

  Future<void> saveUserPreferencesMap(
    String idUser,
    Map<String, dynamic> preferences, {
    String? name,
    String? email,
    required bool isSynced,
  }) async {}

  Future<void> clearAll() async {}
}

