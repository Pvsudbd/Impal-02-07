import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/models/schedule_model.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/models/schedule_repository.dart';

void main() {
  group('Schedule Conflict & Virtual URL Tests', () {
    late ScheduleRepository repository;

    setUp(() {
      repository = ScheduleRepository();
      repository.init();
    });

    test('ScheduleModel correctly exposes meetingUrl and hasMeetingUrl', () {
      final itemWithUrl = ScheduleModel(
        id: 'test_1',
        title: 'Project Standup',
        type: 'Meeting',
        date: DateTime(2026, 11, 10),
        timeStart: '10:00',
        timeEnd: '11:00',
        meetingUrl: 'https://meet.google.com/abc-defg-hij',
      );

      final itemWithoutUrl = ScheduleModel(
        id: 'test_2',
        title: 'Class Lecture',
        type: 'Lecture',
        date: DateTime(2026, 11, 10),
        timeStart: '13:00',
        timeEnd: '15:00',
      );

      expect(itemWithUrl.hasMeetingUrl, isTrue);
      expect(itemWithUrl.meetingUrl, 'https://meet.google.com/abc-defg-hij');

      expect(itemWithoutUrl.hasMeetingUrl, isFalse);
      expect(itemWithoutUrl.meetingUrl, isNull);
    });

    test('findConflicts detects overlapping intervals on the same day', () async {
      final baseDate = DateTime(2026, 11, 15);

      // Add a base schedule: 09:00 - 11:00
      final baseSchedule = ScheduleModel(
        id: 'conf_base',
        title: 'Software Verification',
        type: 'Lecture',
        date: baseDate,
        timeStart: '09:00',
        timeEnd: '11:00',
      );
      await repository.addSchedule(baseSchedule);

      // 1. Overlapping partially (10:00 - 12:00) -> CONFLICT
      final overlapConflicts = repository.findConflicts(
        date: baseDate,
        timeStart: '10:00',
        timeEnd: '12:00',
      );
      expect(overlapConflicts.any((c) => c.id == 'conf_base'), isTrue);

      // 2. Contained completely (09:30 - 10:30) -> CONFLICT
      final containedConflicts = repository.findConflicts(
        date: baseDate,
        timeStart: '09:30',
        timeEnd: '10:30',
      );
      expect(containedConflicts.any((c) => c.id == 'conf_base'), isTrue);

      // 3. Adjacent before (08:00 - 09:00) -> NO CONFLICT
      final beforeConflicts = repository.findConflicts(
        date: baseDate,
        timeStart: '08:00',
        timeEnd: '09:00',
      );
      expect(beforeConflicts.any((c) => c.id == 'conf_base'), isFalse);

      // 4. Adjacent after (11:00 - 12:00) -> NO CONFLICT
      final afterConflicts = repository.findConflicts(
        date: baseDate,
        timeStart: '11:00',
        timeEnd: '12:00',
      );
      expect(afterConflicts.any((c) => c.id == 'conf_base'), isFalse);

      // 5. Overlapping hours but on a different day -> NO CONFLICT
      final diffDayConflicts = repository.findConflicts(
        date: baseDate.add(const Duration(days: 1)),
        timeStart: '09:30',
        timeEnd: '10:30',
      );
      expect(diffDayConflicts.any((c) => c.id == 'conf_base'), isFalse);

      // 6. Exclude own ID during edit -> NO CONFLICT
      final selfEditConflicts = repository.findConflicts(
        date: baseDate,
        timeStart: '09:00',
        timeEnd: '11:00',
        excludeId: 'conf_base',
      );
      expect(selfEditConflicts.any((c) => c.id == 'conf_base'), isFalse);

      // Clean up
      await repository.deleteSchedule('conf_base');
    });
  });
}
