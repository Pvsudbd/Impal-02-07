import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'course_rubric_model.dart';

/// Operation status returned by [CourseRubricRepository] mutations.
class RubricMutationResult {
  final bool success;
  final String? errorMessage;

  const RubricMutationResult.ok()
      : success = true,
        errorMessage = null;

  const RubricMutationResult.error(this.errorMessage) : success = false;
}

/// Centralized Single Source of Truth repository managing Course Grading Rubrics
/// and their bidirectional sync to College Tasks and Teams.
///
/// Enforces a strict `<= 100%` cap per Course while allowing `< 100%` drafts.
class CourseRubricRepository extends ChangeNotifier {
  static final CourseRubricRepository _instance =
      CourseRubricRepository._internal();
  factory CourseRubricRepository() => _instance;

  CourseRubricRepository._internal() {
    _courses = List<CourseRubricModel>.from(_defaultCourses);
  }

  static const String _storageKey = 'saved_course_rubrics_v1';

  static const List<CourseRubricModel> _defaultCourses = [
    CourseRubricModel(
      id: 'course_impal',
      courseCode: 'SSIF-04-REG',
      courseName: 'Software Testing & Implementation',
      credits: 3,
      components: [
        RubricComponentModel(
          id: 'comp_impal_uts',
          name: 'Midterm (UTS)',
          weightPercent: 20,
          isPreset: true,
        ),
        RubricComponentModel(
          id: 'comp_impal_uas',
          name: 'Final Exam (UAS)',
          weightPercent: 20,
          isPreset: true,
        ),
        RubricComponentModel(
          id: 'comp_impal_quiz',
          name: 'Quiz',
          weightPercent: 15,
          isPreset: true,
        ),
        RubricComponentModel(
          id: 'comp_impal_task',
          name: 'Individual Task',
          weightPercent: 15,
          isPreset: true,
        ),
        RubricComponentModel(
          id: 'comp_impal_team',
          name: 'Team Project',
          weightPercent: 30,
          assignedTeamId: '1',
          assignedTeamName: 'IMPAL Team',
          isPreset: true,
        ),
      ],
    ),
    CourseRubricModel(
      id: 'course_ai',
      courseCode: 'AI-401',
      courseName: 'Artificial Intelligence',
      credits: 3,
      components: [
        RubricComponentModel(
          id: 'comp_ai_uts',
          name: 'Midterm (UTS)',
          weightPercent: 20,
          isPreset: true,
        ),
        RubricComponentModel(
          id: 'comp_ai_uas',
          name: 'Final Exam (UAS)',
          weightPercent: 25,
          isPreset: true,
        ),
        RubricComponentModel(
          id: 'comp_ai_quiz',
          name: 'Quiz',
          weightPercent: 10,
          isPreset: true,
        ),
        RubricComponentModel(
          id: 'comp_ai_sprint',
          name: 'Major Sprint Project',
          weightPercent: 35,
          assignedTeamId: '4',
          assignedTeamName: 'AI Project Team',
          isPreset: true,
        ),
      ],
    ),
    CourseRubricModel(
      id: 'course_ling',
      courseCode: 'LNG-204',
      courseName: 'Linguistics',
      credits: 2,
      components: [
        RubricComponentModel(
          id: 'comp_ling_uts',
          name: 'Midterm (UTS)',
          weightPercent: 25,
          isPreset: true,
        ),
        RubricComponentModel(
          id: 'comp_ling_uas',
          name: 'Final Exam (UAS)',
          weightPercent: 25,
          isPreset: true,
        ),
        RubricComponentModel(
          id: 'comp_ling_essay',
          name: 'Essay Assignment',
          weightPercent: 25,
          isPreset: true,
        ),
        RubricComponentModel(
          id: 'comp_ling_quiz',
          name: 'Quiz',
          weightPercent: 15,
          isPreset: true,
        ),
      ],
    ),
  ];

  late List<CourseRubricModel> _courses;
  bool _initialized = false;

  List<CourseRubricModel> get courses => List.unmodifiable(_courses);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = json.decode(raw) as List<dynamic>;
        _courses = decoded
            .map((item) =>
                CourseRubricModel.fromMap(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
        return;
      }
    } catch (_) {
      // Fallback safely to built-in fixtures when preferences are unavailable.
    }
    _courses = List<CourseRubricModel>.from(_defaultCourses);
    await _persist();
    notifyListeners();
  }

  /// Resets courses to defaults (handy for deterministic unit/widget tests).
  void resetToDefaults() {
    _initialized = false;
    _courses = List<CourseRubricModel>.from(_defaultCourses);
    notifyListeners();
  }

  CourseRubricModel? getCourseById(String? id) {
    if (id == null || id.trim().isEmpty) return null;
    for (final c in _courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Matches a Course from either its exact ID, `displayLabel`, `courseName`,
  /// or `courseCode` (for seamless integration with existing `TaskItemModel.course` strings).
  CourseRubricModel? findCourseByTextOrId(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final query = value.trim().toLowerCase();
    for (final c in _courses) {
      if (c.id.toLowerCase() == query ||
          c.displayLabel.toLowerCase() == query ||
          c.courseName.toLowerCase() == query ||
          c.courseCode.toLowerCase() == query) {
        return c;
      }
    }
    for (final c in _courses) {
      if (query.contains(c.courseName.toLowerCase()) ||
          (c.courseCode.isNotEmpty &&
              query.contains(c.courseCode.toLowerCase()))) {
        return c;
      }
    }
    return null;
  }

  RubricComponentModel? findComponent(String? courseId, String? componentId) {
    final course = getCourseById(courseId);
    if (course == null || componentId == null) return null;
    for (final comp in course.components) {
      if (comp.id == componentId) return comp;
    }
    return null;
  }

  /// Finds the linked `(course, component)` pair for a given Team by `teamId`,
  /// `teamCode`, or `teamName` (normalized against `Kelompok - ` / `Team` prefixes).
  LinkedTeamRubric? getLinkedRubricForTeam({
    String? teamId,
    String? teamName,
  }) {
    final normId = teamId?.trim().toLowerCase() ?? '';
    final normName = _normalizeTeamName(teamName);

    for (final course in _courses) {
      for (final comp in course.components) {
        final compId = comp.assignedTeamId?.trim().toLowerCase() ?? '';
        final compName = _normalizeTeamName(comp.assignedTeamName);

        if (normId.isNotEmpty && compId.isNotEmpty && normId == compId) {
          return LinkedTeamRubric(course: course, component: comp);
        }
        if (normName.isNotEmpty &&
            compName.isNotEmpty &&
            (normName == compName ||
                compName.contains(normName) ||
                normName.contains(compName))) {
          return LinkedTeamRubric(course: course, component: comp);
        }
      }
    }
    return null;
  }

  static String _normalizeTeamName(String? raw) {
    if (raw == null) return '';
    return raw
        .trim()
        .toLowerCase()
        .replaceAll('kelompok - ', '')
        .replaceAll('kelompok ', '')
        .replaceAll(' team', '')
        .trim();
  }

  Future<RubricMutationResult> addCourse({
    required String courseCode,
    required String courseName,
    int credits = 3,
    bool applyStandardPreset = false,
  }) async {
    final trimmedName = courseName.trim();
    if (trimmedName.isEmpty) {
      return const RubricMutationResult.error('Course name is required.');
    }
    final id = 'course_${DateTime.now().microsecondsSinceEpoch}';
    final components = applyStandardPreset
        ? CourseRubricModel.defaultPresetComponents(id)
        : const <RubricComponentModel>[];

    _courses = [
      CourseRubricModel(
        id: id,
        courseCode: courseCode.trim().toUpperCase(),
        courseName: trimmedName,
        credits: credits.clamp(1, 8),
        components: components,
      ),
      ..._courses,
    ];
    notifyListeners();
    await _persist();
    return const RubricMutationResult.ok();
  }

  Future<RubricMutationResult> updateCourse({
    required String courseId,
    required String courseCode,
    required String courseName,
    required int credits,
  }) async {
    final trimmedName = courseName.trim();
    if (trimmedName.isEmpty) {
      return const RubricMutationResult.error('Course name is required.');
    }
    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index == -1) {
      return const RubricMutationResult.error('Course not found.');
    }
    final updated = List<CourseRubricModel>.from(_courses);
    updated[index] = updated[index].copyWith(
      courseCode: courseCode.trim().toUpperCase(),
      courseName: trimmedName,
      credits: credits.clamp(1, 8),
    );
    _courses = updated;
    notifyListeners();
    await _persist();
    return const RubricMutationResult.ok();
  }

  Future<void> deleteCourse(String courseId) async {
    _courses = _courses.where((c) => c.id != courseId).toList();
    notifyListeners();
    await _persist();
  }

  Future<RubricMutationResult> applyPresetToCourse(String courseId) async {
    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index == -1) {
      return const RubricMutationResult.error('Course not found.');
    }
    final updated = List<CourseRubricModel>.from(_courses);
    updated[index] = updated[index].copyWith(
      components: CourseRubricModel.defaultPresetComponents(courseId),
    );
    _courses = updated;
    notifyListeners();
    await _persist();
    return const RubricMutationResult.ok();
  }

  Future<RubricMutationResult> addComponent({
    required String courseId,
    required String name,
    required int weightPercent,
    String? assignedTeamId,
    String? assignedTeamName,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const RubricMutationResult.error('Component name is required.');
    }
    if (weightPercent < 1 || weightPercent > 100) {
      return const RubricMutationResult.error(
        'Weight must be between 1% and 100%.',
      );
    }

    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index == -1) {
      return const RubricMutationResult.error('Course not found.');
    }

    final course = _courses[index];
    final nextTotal = course.totalAssignedPercent + weightPercent;
    if (nextTotal > 100) {
      return RubricMutationResult.error(
        'Total rubric weight cannot exceed 100% (remaining: ${course.remainingPercent}%).',
      );
    }

    final duplicateName = course.components.any(
      (c) => c.name.trim().toLowerCase() == trimmed.toLowerCase(),
    );
    if (duplicateName) {
      return RubricMutationResult.error(
        'Component "$trimmed" already exists in ${course.courseName}.',
      );
    }

    final compId = 'comp_${DateTime.now().microsecondsSinceEpoch}';
    final updatedCourses = _clearTeamMatches(
      _courses,
      teamId: assignedTeamId,
      teamName: assignedTeamName,
    );

    final target = updatedCourses[index];
    updatedCourses[index] = target.copyWith(
      components: [
        ...target.components,
        RubricComponentModel(
          id: compId,
          name: trimmed,
          weightPercent: weightPercent,
          assignedTeamId: assignedTeamId,
          assignedTeamName: assignedTeamName,
        ),
      ],
    );
    _courses = updatedCourses;
    notifyListeners();
    await _persist();
    return const RubricMutationResult.ok();
  }

  Future<RubricMutationResult> updateComponent({
    required String courseId,
    required String componentId,
    required String name,
    required int weightPercent,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const RubricMutationResult.error('Component name is required.');
    }
    if (weightPercent < 1 || weightPercent > 100) {
      return const RubricMutationResult.error(
        'Weight must be between 1% and 100%.',
      );
    }

    final courseIndex = _courses.indexWhere((c) => c.id == courseId);
    if (courseIndex == -1) {
      return const RubricMutationResult.error('Course not found.');
    }
    final course = _courses[courseIndex];
    final compIndex =
        course.components.indexWhere((c) => c.id == componentId);
    if (compIndex == -1) {
      return const RubricMutationResult.error('Rubric component not found.');
    }

    final otherTotal = course.components
        .where((c) => c.id != componentId)
        .fold<int>(0, (sum, c) => sum + c.weightPercent);
    if (otherTotal + weightPercent > 100) {
      return RubricMutationResult.error(
        'Total rubric weight cannot exceed 100% (max allowed: ${100 - otherTotal}%).',
      );
    }

    final duplicateName = course.components.any(
      (c) =>
          c.id != componentId &&
          c.name.trim().toLowerCase() == trimmed.toLowerCase(),
    );
    if (duplicateName) {
      return RubricMutationResult.error(
        'Component "$trimmed" already exists in ${course.courseName}.',
      );
    }

    final updatedComps = List<RubricComponentModel>.from(course.components);
    updatedComps[compIndex] = updatedComps[compIndex].copyWith(
      name: trimmed,
      weightPercent: weightPercent,
    );

    final updatedCourses = List<CourseRubricModel>.from(_courses);
    updatedCourses[courseIndex] = course.copyWith(components: updatedComps);
    _courses = updatedCourses;
    notifyListeners();
    await _persist();
    return const RubricMutationResult.ok();
  }

  Future<void> deleteComponent({
    required String courseId,
    required String componentId,
  }) async {
    final courseIndex = _courses.indexWhere((c) => c.id == courseId);
    if (courseIndex == -1) return;

    final updatedCourses = List<CourseRubricModel>.from(_courses);
    final target = updatedCourses[courseIndex];
    updatedCourses[courseIndex] = target.copyWith(
      components:
          target.components.where((c) => c.id != componentId).toList(),
    );
    _courses = updatedCourses;
    notifyListeners();
    await _persist();
  }

  /// Bidirectionally links [componentId] inside [courseId] to a Team.
  /// Automatically clears any previous link owned by the same team so a team
  /// always maps cleanly to a single rubric source without collisions.
  Future<RubricMutationResult> assignComponentToTeam({
    required String courseId,
    required String componentId,
    required String teamId,
    required String teamName,
  }) async {
    var updatedCourses = _clearTeamMatches(
      _courses,
      teamId: teamId,
      teamName: teamName,
    );

    final courseIndex = updatedCourses.indexWhere((c) => c.id == courseId);
    if (courseIndex == -1) {
      return const RubricMutationResult.error('Course not found.');
    }

    final targetCourse = updatedCourses[courseIndex];
    final compIndex =
        targetCourse.components.indexWhere((c) => c.id == componentId);
    if (compIndex == -1) {
      return const RubricMutationResult.error('Rubric component not found.');
    }

    final updatedComps =
        List<RubricComponentModel>.from(targetCourse.components);
    updatedComps[compIndex] = updatedComps[compIndex].copyWith(
      assignedTeamId: teamId,
      assignedTeamName: teamName,
    );
    updatedCourses[courseIndex] =
        targetCourse.copyWith(components: updatedComps);

    _courses = updatedCourses;
    notifyListeners();
    await _persist();
    return const RubricMutationResult.ok();
  }

  Future<void> clearTeamAssignment({
    String? teamId,
    String? teamName,
  }) async {
    _courses = _clearTeamMatches(
      _courses,
      teamId: teamId,
      teamName: teamName,
    );
    notifyListeners();
    await _persist();
  }

  List<CourseRubricModel> _clearTeamMatches(
    List<CourseRubricModel> source, {
    String? teamId,
    String? teamName,
  }) {
    final normId = teamId?.trim().toLowerCase() ?? '';
    final normName = _normalizeTeamName(teamName);
    if (normId.isEmpty && normName.isEmpty) {
      return List<CourseRubricModel>.from(source);
    }

    return source.map((course) {
      final updatedComps = course.components.map((comp) {
        final compId = comp.assignedTeamId?.trim().toLowerCase() ?? '';
        final compName = _normalizeTeamName(comp.assignedTeamName);
        final matchesId = normId.isNotEmpty && compId == normId;
        final matchesName = normName.isNotEmpty &&
            compName.isNotEmpty &&
            (compName == normName ||
                compName.contains(normName) ||
                normName.contains(compName));
        if (matchesId || matchesName) {
          return comp.copyWith(clearTeamAssignment: true);
        }
        return comp;
      }).toList();
      return course.copyWith(components: updatedComps);
    }).toList();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_courses.map((c) => c.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      // Ignore persistence errors in headless widget test environments.
    }
  }
}
