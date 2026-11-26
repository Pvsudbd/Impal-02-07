import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/models/course_rubric_repository.dart';
import 'package:impal_smart_todolist/presentation/features/task/models/tag_model.dart';
import 'package:impal_smart_todolist/presentation/features/task/models/tag_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late TaskTagRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CourseRubricRepository().resetToDefaults();
    repo = TaskTagRepository();
    repo.resetToDefaults();
  });

  group('TaskTagRepository', () {
    test('provides seeded starter tags and resolves selected labels', () {
      expect(repo.tags.length, greaterThanOrEqualTo(4));
      expect(repo.findByLabel('figma'), isNotNull);

      final models = repo.toTaskTagModels(['Figma', 'Code', 'Figma']);
      expect(models.length, 2);
      expect(models.first.label, 'Figma');
    });

    test('blocks reserved root names, duplicates, and course name collisions', () async {
      final reserved = await repo.addTag(label: 'College');
      expect(reserved.success, isFalse);
      expect(reserved.errorMessage, contains('reserved'));

      final duplicate = await repo.addTag(label: 'FIGMA');
      expect(duplicate.success, isFalse);
      expect(duplicate.errorMessage, contains('already exists'));

      final courseCollision = await repo.addTag(label: 'Artificial Intelligence');
      expect(courseCollision.success, isFalse);
      expect(courseCollision.errorMessage, contains('Course'));
    });

    test('adds and deletes custom tags and supports JSON round-trip', () async {
      final res = await repo.addTag(
        label: 'Organization',
        colorPreset: TagColorPreset.byId('coral'),
      );
      expect(res.success, isTrue);
      expect(res.tag, isNotNull);
      expect(repo.findByLabel('organization'), isNotNull);

      final roundTrip = CustomTagModel.fromMap(res.tag!.toMap());
      expect(roundTrip.label, 'Organization');
      expect(roundTrip.isDefault, isFalse);

      await repo.deleteTag(res.tag!.id);
      expect(repo.findByLabel('Organization'), isNull);
    });
  });
}
