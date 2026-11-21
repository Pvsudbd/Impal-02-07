import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
class TaskTagRepository extends ChangeNotifier {
  static final TaskTagRepository _instance = TaskTagRepository._internal();
  factory TaskTagRepository() => _instance;

  TaskTagRepository._internal() {
    _tags = List<CustomTagModel>.from(_defaultTags);
  }

  static const String _storageKey = 'saved_task_tags_v1';

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

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = json.decode(raw) as List<dynamic>;
        _tags = decoded
            .map(
              (item) => CustomTagModel.fromMap(item as Map<String, dynamic>),
            )
            .toList();
        notifyListeners();
        return;
      }
    } catch (_) {
      // Safe fallback in headless test environments.
    }
    _tags = List<CustomTagModel>.from(_defaultTags);
    await _persist();
    notifyListeners();
  }

  void resetToDefaults() {
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
      id: 'tag_${DateTime.now().microsecondsSinceEpoch}',
      label: trimmed,
      backgroundColor: preset.backgroundColor,
      textColor: preset.textColor,
      isDefault: false,
    );

    _tags = [..._tags, created];
    notifyListeners();
    await _persist();
    return TagMutationResult.ok(created);
  }

  Future<void> deleteTag(String id) async {
    _tags = _tags.where((t) => t.id != id).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_tags.map((t) => t.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      // Ignore persistence errors in headless widget test environments.
    }
  }
}
