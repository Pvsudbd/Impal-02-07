import 'package:flutter/foundation.dart';

/// Represents a single graded assessment category within a Course's rubric
/// (e.g. Midterm (UTS) 20%, Quiz 15%, Team Project 30%).
@immutable
class RubricComponentModel {
  final String id;
  final String name;
  final int weightPercent;
  final String? assignedTeamId;
  final String? assignedTeamName;
  final bool isPreset;

  const RubricComponentModel({
    required this.id,
    required this.name,
    required this.weightPercent,
    this.assignedTeamId,
    this.assignedTeamName,
    this.isPreset = false,
  });

  bool get isAssignedToTeam =>
      (assignedTeamId != null && assignedTeamId!.trim().isNotEmpty) ||
      (assignedTeamName != null && assignedTeamName!.trim().isNotEmpty);

  RubricComponentModel copyWith({
    String? id,
    String? name,
    int? weightPercent,
    String? assignedTeamId,
    String? assignedTeamName,
    bool clearTeamAssignment = false,
    bool? isPreset,
  }) {
    return RubricComponentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      weightPercent: weightPercent ?? this.weightPercent,
      assignedTeamId:
          clearTeamAssignment ? null : (assignedTeamId ?? this.assignedTeamId),
      assignedTeamName: clearTeamAssignment
          ? null
          : (assignedTeamName ?? this.assignedTeamName),
      isPreset: isPreset ?? this.isPreset,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight_percent': weightPercent,
      'assigned_team_id': assignedTeamId,
      'assigned_team_name': assignedTeamName,
      'is_preset': isPreset,
    };
  }

  factory RubricComponentModel.fromMap(Map<String, dynamic> map) {
    return RubricComponentModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      weightPercent: (map['weight_percent'] as num?)?.toInt() ?? 0,
      assignedTeamId: map['assigned_team_id']?.toString(),
      assignedTeamName: map['assigned_team_name']?.toString(),
      isPreset: map['is_preset'] == true,
    );
  }
}

/// Represents a Course (Mata Kuliah) and its complete Grading Rubric breakdown.
@immutable
class CourseRubricModel {
  final String id;
  final String courseCode;
  final String courseName;
  final int credits;
  final List<RubricComponentModel> components;

  const CourseRubricModel({
    required this.id,
    required this.courseCode,
    required this.courseName,
    this.credits = 3,
    this.components = const [],
  });

  /// Canonical display label matching College Task forms (e.g. `IMPAL • Software Testing & Implementation`).
  String get displayLabel => courseCode.trim().isEmpty
      ? courseName
      : '$courseCode • $courseName';

  /// Sum of all assessment component percentages assigned in this course.
  int get totalAssignedPercent =>
      components.fold<int>(0, (sum, item) => sum + item.weightPercent);

  /// Remaining unallocated percentage up to 100%.
  int get remainingPercent => (100 - totalAssignedPercent).clamp(0, 100);

  /// Whether total allocated percentage equals exactly 100%.
  bool get isComplete => totalAssignedPercent == 100;

  CourseRubricModel copyWith({
    String? id,
    String? courseCode,
    String? courseName,
    int? credits,
    List<RubricComponentModel>? components,
  }) {
    return CourseRubricModel(
      id: id ?? this.id,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      credits: credits ?? this.credits,
      components: components ?? this.components,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_code': courseCode,
      'course_name': courseName,
      'credits': credits,
      'components': components.map((c) => c.toMap()).toList(),
    };
  }

  factory CourseRubricModel.fromMap(Map<String, dynamic> map) {
    final rawComponents = map['components'] as List<dynamic>? ?? const [];
    return CourseRubricModel(
      id: (map['id'] ?? '').toString(),
      courseCode: (map['course_code'] ?? '').toString(),
      courseName: (map['course_name'] ?? '').toString(),
      credits: (map['credits'] as num?)?.toInt() ?? 3,
      components: rawComponents
          .map((item) =>
              RubricComponentModel.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Generates editable starter components totaling 100% for quick course setup.
  static List<RubricComponentModel> defaultPresetComponents(String courseId) {
    return [
      RubricComponentModel(
        id: '${courseId}_uts',
        name: 'Midterm (UTS)',
        weightPercent: 25,
        isPreset: true,
      ),
      RubricComponentModel(
        id: '${courseId}_uas',
        name: 'Final Exam (UAS)',
        weightPercent: 25,
        isPreset: true,
      ),
      RubricComponentModel(
        id: '${courseId}_quiz',
        name: 'Quiz',
        weightPercent: 15,
        isPreset: true,
      ),
      RubricComponentModel(
        id: '${courseId}_assignment',
        name: 'Assignment',
        weightPercent: 15,
        isPreset: true,
      ),
      RubricComponentModel(
        id: '${courseId}_team_project',
        name: 'Team Project',
        weightPercent: 20,
        isPreset: true,
      ),
    ];
  }
}

/// Pair linking a Course with a specific Assessment Component (used by Team sync).
@immutable
class LinkedTeamRubric {
  final CourseRubricModel course;
  final RubricComponentModel component;

  const LinkedTeamRubric({
    required this.course,
    required this.component,
  });
}
