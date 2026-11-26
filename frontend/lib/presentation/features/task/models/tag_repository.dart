import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/network/api_client.dart';
import '../../../../data/local/isar_service.dart';
import '../../smart_system/models/course_rubric_repository.dart';
import 'tag_model.dart';
import 'task_item_model.dart';

/// Operation result returned by [TaskTagRepository].
class TagMutationResult {
  final bool success;
  final CustomTagModel? tag;
  final String? errorMessage;

  const TagMutationResult.ok(this.tag)
      : success = true,
        errorMessage = null;

  const TagMutationResult.error(this.errorMessage)
      : success = false,
        tag = null;
}

/// Centralized Single Source of Truth repository managing Custom Task Tags
/// across Dashboard Home (Mobile & Desktop), Tasks Page, and Task/Team Forms.
///
/// Persists custom tags across PostgreSQL (/api/tags), Isar DB (on native IO),
/// and SharedPreferences fallback.
class TaskTagRepository extends ChangeNotifier {
  static final TaskTagRepository _instance = TaskTagRepository._internal();
  factory TaskTagRepository() => _instance;

  TaskTagRepository._internal() {
    _tags = List<CustomTagModel>.from(_defaultTags);
  }

  static const String _storageKey = 'saved_task_tags_v1';
  static const _uuid = Uuid();

  static const Set<String> _reservedRootLabels = {
    'all',
    'college',
    'personal',
    'team',
    'completed',
    'task',
  };

  static const List<CustomTagModel> _defaultTags = [
    CustomTagModel(
      id: 'tag_figma',
      label: 'Figma',
      backgroundColor: Color(0xFF778BEB),
      textColor: Color(0xFF1E296B),
      isDefault: true,
    ),
    CustomTagModel(
      id: 'tag_code',
      label: 'Code',
      backgroundColor: Color(0xFF63CDDA),
      textColor: Color(0xFF144D56),
      isDefault: true,
    ),
    CustomTagModel(
      id: 'tag_backend',
      label: 'Backend',
      backgroundColor: Color(0xFFFA6144),
      textColor: Colors.white,
      isDefault: true,
    ),
    CustomTagModel(
      id: 'tag_research',
      label: 'Research',
      backgroundColor: Color(0xFF6EE7B7),
      textColor: Color(0xFF064E3B),
      isDefault: true,
    ),
  ];

  late List<CustomTagModel> _tags;
  bool _initialized = false;

  List<CustomTagModel> get tags => List.unmodifiable(_tags);

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token') ?? prefs.getString('jwt_token');
    } catch (_) {
      return null;
    }
  }

  Future<String> _getActiveUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawId = prefs.getString('id_user') ??
          prefs.getString('id_student') ??
          prefs.getString('user_id');
      if (rawId != null && rawId.trim().isNotEmpty) return rawId.trim();
      final rawAuthUser = prefs.getString('auth_user');
      if (rawAuthUser != null && rawAuthUser.trim().isNotEmpty) {
        return rawAuthUser.trim();
      }
    } catch (_) {}
    return 'local_user';
  }

  List<CustomTagModel> _mergeWithDefaults(List<CustomTagModel> customOrSaved) {
    final merged = <CustomTagModel>[];
    final seenLabels = <String>{};
    for (final d in _defaultTags) {
      final match = customOrSaved
          .where((t) => t.label.trim().toLowerCase() == d.label.toLowerCase())
          .firstOrNull;
      if (match != null) {
        merged.add(match);
        seenLabels.add(match.label.trim().toLowerCase());
      } else {
        merged.add(d);
        seenLabels.add(d.label.toLowerCase());
      }
    }
    for (final item in customOrSaved) {
      final norm = item.label.trim().toLowerCase();
      if (norm.isNotEmpty && seenLabels.add(norm)) {
        merged.add(item);
      }
    }
    return merged;
  }

  Future<void> init() async {
    if (!_initialized) {
      _initialized = true;
      List<CustomTagModel> loaded = [];

      if (!kIsWeb && !IsarService().isInitialized) {
        try {
          await IsarService().init();
        } catch (_) {}
      }

      // 1. Baca dari Isar DB jika sudah terinisialisasi (Offline-First Native)
      if (IsarService().isInitialized) {
        try {
          final idUser = await _getActiveUserId();
          final isarTagMaps = await IsarService().getCustomTagMaps(idUser);
          if (isarTagMaps.isNotEmpty) {
            loaded = isarTagMaps.map(CustomTagModel.fromMap).toList();
          }
        } catch (_) {}
      }

      // 2. Fallback / gabung dengan SharedPreferences
      if (loaded.isEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final raw = prefs.getString(_storageKey);
          if (raw != null && raw.isNotEmpty) {
            final decoded = json.decode(raw) as List<dynamic>;
            loaded = decoded
                .map((item) => CustomTagModel.fromMap(item as Map<String, dynamic>))
                .toList();
          }
        } catch (_) {}
      }

      _tags = loaded.isNotEmpty
          ? _mergeWithDefaults(loaded)
          : List<CustomTagModel>.from(_defaultTags);
      await _persistLocal();
      notifyListeners();
    }

    // 3. Sinkronisasi dengan Backend PostgreSQL (GET /api/tags)
    await fetchTagsFromApi();
  }

  /// Menarik daftar custom tags milik user dari Backend PostgreSQL (/api/tags)
  Future<void> fetchTagsFromApi() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;

    try {
      if (IsarService().isInitialized) {
        final unsyncedMaps = await IsarService().getUnsyncedCustomTagMaps();
        for (final m in unsyncedMaps) {
          await _pushCreateTag(CustomTagModel.fromMap(m), token: token);
        }
      }

      final res = await ApiClient.get('/api/tags', token: token);
      if (res['status'] == 'success' && res['data'] is List) {
        final List<dynamic> raw = res['data'];
        final serverTags = raw
            .whereType<Map>()
            .map((item) => CustomTagModel.fromMap(Map<String, dynamic>.from(item)))
            .where((t) => t.label.trim().isNotEmpty)
            .toList();

        _tags = _mergeWithDefaults(serverTags);
        await _persistLocal(markSynced: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[TAG_REPO] fetchTagsFromApi error: $e');
    }
  }

  void resetToDefaults() {
    _initialized = false;
    _tags = List<CustomTagModel>.from(_defaultTags);
    notifyListeners();
  }

  void clear() {
    _initialized = false;
    _tags = List<CustomTagModel>.from(_defaultTags);
    notifyListeners();
  }

  CustomTagModel? findByLabel(String label) {
    final norm = label.trim().toLowerCase();
    for (final tag in _tags) {
      if (tag.label.trim().toLowerCase() == norm) return tag;
    }
    return null;
  }

  /// Resolves a list of selected label strings into typed [TaskTagModel] items.
  List<TaskTagModel> toTaskTagModels(Iterable<String> selectedLabels) {
    final seen = <String>{};
    final result = <TaskTagModel>[];
    for (final raw in selectedLabels) {
      final clean = raw.trim();
      final lower = clean.toLowerCase();
      if (clean.isEmpty || !seen.add(lower)) continue;
      final existing = findByLabel(clean);
      if (existing != null) {
        result.add(existing.toTaskTagModel());
      } else {
        final fallbackPreset = TagColorPreset.presets.first;
        result.add(
          TaskTagModel(
            label: clean,
            backgroundColor: fallbackPreset.backgroundColor,
            textColor: fallbackPreset.textColor,
          ),
        );
      }
    }
    return result;
  }

  /// Validates and creates a new custom tag, preventing duplicates and
  /// collisions with root category filters (`All`, `College`, `Personal`)
  /// or active Course names/codes in [CourseRubricRepository].
  Future<TagMutationResult> addTag({
    required String label,
    TagColorPreset? colorPreset,
  }) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      return const TagMutationResult.error('Tag name is required.');
    }
    if (trimmed.length > 24) {
      return const TagMutationResult.error(
        'Tag name must be 24 characters or fewer.',
      );
    }

    final lower = trimmed.toLowerCase();
    if (_reservedRootLabels.contains(lower)) {
      return TagMutationResult.error(
        '"$trimmed" is a reserved category filter name.',
      );
    }

    final collidesCourse = CourseRubricRepository().courses.any(
          (c) =>
              c.courseName.trim().toLowerCase() == lower ||
              c.courseCode.trim().toLowerCase() == lower ||
              c.displayLabel.trim().toLowerCase() == lower,
        );
    if (collidesCourse) {
      return TagMutationResult.error(
        '"$trimmed" matches an existing Course. Manage Courses under Smart Priority.',
      );
    }

    if (findByLabel(trimmed) != null) {
      return TagMutationResult.error('Tag "$trimmed" already exists.');
    }

    final preset = colorPreset ?? TagColorPreset.presets.first;
    final created = CustomTagModel(
      id: _uuid.v4(),
      label: trimmed,
      backgroundColor: preset.backgroundColor,
      textColor: preset.textColor,
      isDefault: false,
    );

    _tags = [..._tags, created];
    notifyListeners();
    await _persistLocal(markSynced: false);
    await _pushCreateTag(created);
    return TagMutationResult.ok(created);
  }

  Future<void> _pushCreateTag(CustomTagModel tag, {String? token}) async {
    final activeToken = token ?? await _getToken();
    if (activeToken == null || activeToken.isEmpty) return;

    try {
      final res = await ApiClient.post(
        '/api/tags',
        tag.toMap(),
        token: activeToken,
      );
      if (res['status'] == 'success' && res['data'] is Map) {
        final serverTag = CustomTagModel.fromMap(
          Map<String, dynamic>.from(res['data'] as Map),
        );
        final idx = _tags.indexWhere(
          (t) => t.id == tag.id || t.label.toLowerCase() == serverTag.label.toLowerCase(),
        );
        if (idx != -1) {
          _tags = List<CustomTagModel>.from(_tags)..[idx] = serverTag;
          notifyListeners();
        }
        await _persistTagToIsar(serverTag, isSynced: true);
        await _persistSharedPrefs();
      }
    } catch (e) {
      debugPrint('[TAG_REPO] _pushCreateTag error: $e');
    }
  }

  Future<void> deleteTag(String id) async {
    _tags = _tags.where((t) => t.id != id).toList();
    notifyListeners();
    await _persistSharedPrefs();
    if (IsarService().isInitialized) {
      try {
        await IsarService().deleteTagByRemoteId(id);
      } catch (_) {}
    }

    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await ApiClient.delete('/api/tags/${Uri.encodeComponent(id)}', token: token);
      } catch (e) {
        debugPrint('[TAG_REPO] deleteTag API error: $e');
      }
    }
  }

  Future<void> _persistTagToIsar(
    CustomTagModel tag, {
    required bool isSynced,
  }) async {
    if (!IsarService().isInitialized) return;
    try {
      final idUser = await _getActiveUserId();
      await IsarService().saveCustomTagMap(
        tag.toMap(),
        idUser: idUser,
        isSynced: isSynced,
      );
    } catch (_) {}
  }

  Future<void> _persistSharedPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_tags.map((t) => t.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      // Ignore persistence errors in headless widget test environments.
    }
  }

  Future<void> _persistLocal({bool markSynced = false}) async {
    await _persistSharedPrefs();
    if (!IsarService().isInitialized) return;
    try {
      final idUser = await _getActiveUserId();
      final customMaps = _tags
          .where((t) => !t.isDefault)
          .map((t) => t.toMap())
          .toList();
      if (customMaps.isNotEmpty) {
        await IsarService().saveCustomTagMaps(
          customMaps,
          idUser: idUser,
          isSynced: markSynced,
        );
      }
    } catch (_) {}
  }
}
