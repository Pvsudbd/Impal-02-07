import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/common_widgets/impal_schedule_card.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/models/schedule_model.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/models/schedule_repository.dart';
import 'package:impal_smart_todolist/presentation/features/team/widgets/team_schedule_section.dart';

void main() {
  group('TeamScheduleSection Card Width Tests', () {
    late ScheduleRepository repository;

    setUp(() {
      repository = ScheduleRepository();
      repository.init();
    });

    testWidgets('Schedule cards in TeamScheduleSection fill availableWidth matching Home',
        (tester) async {
      final testMeeting = ScheduleModel(
        id: 'team_meet_test_1',
        title: 'Weekly Standup IMPAL',
        type: 'Meeting',
        teamName: 'Kelompok IMPAL',
        location: 'Online / Google Meet',
        date: DateTime.now(),
        timeStart: '10:00',
        timeEnd: '11:00',
      );
      await repository.addSchedule(testMeeting);

      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TeamScheduleSection(
                isDashboard: true,
                onActionTap: () {},
                onEditSchedule: (_) {},
                onDeleteSchedule: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Screen width: 390. Horizontal padding: 20 * 2 = 40. Expected card width: 350.
      final scheduleCardFinder = find.byType(ImpalScheduleCard);
      expect(scheduleCardFinder, findsAtLeastNWidgets(1));

      final cardSize = tester.getSize(scheduleCardFinder.first);
      expect(cardSize.width, equals(350.0));

      // Cleanup
      await repository.deleteSchedule('team_meet_test_1');
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });
}

