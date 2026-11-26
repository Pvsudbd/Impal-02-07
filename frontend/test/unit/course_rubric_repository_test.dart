import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/models/course_rubric_model.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/models/course_rubric_repository.dart';

void main() {
  late CourseRubricRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = CourseRubricRepository();
    repo.resetToDefaults();
  });

  group('CourseRubricRepository', () {
    test('loads default courses with accurate total and remaining percentages', () {
      expect(repo.courses, isNotEmpty);
      final impal = repo.getCourseById('course_impal');
      expect(impal, isNotNull);
      expect(impal!.totalAssignedPercent, 100);
      expect(impal.remainingPercent, 0);
      expect(impal.isComplete, isTrue);

      final ling = repo.getCourseById('course_ling');
      expect(ling, isNotNull);
      expect(ling!.totalAssignedPercent, 90);
      expect(ling.remainingPercent, 10);
      expect(ling.isComplete, isFalse);
    });

    test('enforces strict <= 100% cap when adding and updating components', () async {
      // Linguistics starts at 90% -> remaining 10%
      final overResult = await repo.addComponent(
        courseId: 'course_ling',
        name: 'Responsi',
        weightPercent: 15,
      );
      expect(overResult.success, isFalse);
      expect(overResult.errorMessage, contains('100%'));

      final okResult = await repo.addComponent(
        courseId: 'course_ling',
        name: 'Responsi',
        weightPercent: 10,
      );
      expect(okResult.success, isTrue);
      final ling = repo.getCourseById('course_ling')!;
      expect(ling.totalAssignedPercent, 100);
      expect(ling.components.any((c) => c.name == 'Responsi'), isTrue);

      final responsi = ling.components.firstWhere((c) => c.name == 'Responsi');
      final updateOver = await repo.updateComponent(
        courseId: 'course_ling',
        componentId: responsi.id,
        name: 'Responsi',
        weightPercent: 25,
      );
      expect(updateOver.success, isFalse);
    });

    test('prevents duplicate component names inside the same course', () async {
      final res = await repo.addComponent(
        courseId: 'course_ling',
        name: 'quiz',
        weightPercent: 5,
      );
      expect(res.success, isFalse);
      expect(res.errorMessage, contains('already exists'));
    });

    test('supports bidirectional team assignment without collisions', () async {
      // Default IMPAL Team is linked to course_impal -> comp_impal_team
      final initialLink = repo.getLinkedRubricForTeam(
        teamId: '1',
        teamName: 'IMPAL Team',
      );
      expect(initialLink, isNotNull);
      expect(initialLink!.component.id, 'comp_impal_team');
      expect(initialLink.component.weightPercent, 30);

      // Re-assign IMPAL Team to another component clears previous team link
      final res = await repo.assignComponentToTeam(
        courseId: 'course_ai',
        componentId: 'comp_ai_quiz',
        teamId: '1',
        teamName: 'IMPAL Team',
      );
      expect(res.success, isTrue);

      final oldComp = repo.findComponent('course_impal', 'comp_impal_team');
      expect(oldComp!.isAssignedToTeam, isFalse);

      final newLink = repo.getLinkedRubricForTeam(
        teamId: '1',
        teamName: 'Kelompok IMPAL',
      );
      expect(newLink, isNotNull);
      expect(newLink!.course.id, 'course_ai');
      expect(newLink.component.id, 'comp_ai_quiz');

      await repo.clearTeamAssignment(teamId: '1', teamName: 'IMPAL Team');
      expect(
        repo.getLinkedRubricForTeam(teamId: '1', teamName: 'IMPAL Team'),
        isNull,
      );
    });

    test('persists and restores courses via SharedPreferences JSON round-trip', () async {
      await repo.addCourse(
        courseCode: 'CS-301',
        courseName: 'Distributed Systems',
        credits: 4,
        applyStandardPreset: true,
      );

      final added = repo.findCourseByTextOrId('Distributed Systems');
      expect(added, isNotNull);
      expect(added!.credits, 4);
      expect(added.totalAssignedPercent, 100);
      expect(added.components.length, 5);

      // Verify model round-trip
      final restored = CourseRubricModel.fromMap(added.toMap());
      expect(restored.courseCode, 'CS-301');
      expect(restored.components.length, 5);
    });
  });
}
