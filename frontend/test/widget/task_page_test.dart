import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/task/task_page.dart';
import 'package:impal_smart_todolist/presentation/features/task/models/task_repository.dart';

void main() {
  setUp(() {
    TaskRepository().resetToDefaults();
  });

  testWidgets('TaskPage strictly excludes team tasks and renders only non-team tasks across all categories', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TaskPage(userName: 'Jarvis', userInitials: 'JS'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Team Tasks are NOT displayed on TaskPage
    expect(find.text('AI System Final Project'), findsNothing);
    expect(find.text('Paragraph Text Analysis'), findsNothing);

    // Verify Non-Team Tasks ARE displayed (both College and Personal categories)
    expect(find.text('Linguistics Presentation Video'), findsOneWidget);
    expect(find.text('Mobile App Testing Report'), findsOneWidget);
    expect(find.text('Academic Advisory Consultation'), findsOneWidget);

    // Verify Timeline summary counter displays only non-team tasks
    // In default mock: task_4 (high=1), task_2 (med=1), task_5 (low=1)
    final repo = TaskRepository();
    final counts = repo.getPriorityCounts(nonTeamOnly: true);
    expect(counts[TaskPriorityLevel.high], equals(1));
    expect(counts[TaskPriorityLevel.medium], equals(1));
    expect(counts[TaskPriorityLevel.low], equals(1));
  });
}

