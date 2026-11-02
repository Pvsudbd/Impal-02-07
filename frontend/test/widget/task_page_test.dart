import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/task/task_page.dart';
import 'package:impal_smart_todolist/presentation/features/task/models/task_repository.dart';
import 'package:impal_smart_todolist/presentation/features/team/models/team_task_repository.dart';

void main() {
  setUp(() {
    TaskRepository().resetToDefaults();
    TeamTaskRepository().resetToDefaults();
  });

  testWidgets('TaskPage renders personal tasks and user-assigned team tasks, while excluding team tasks assigned to others', (tester) async {
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

    // Verify Team Tasks assigned to OTHER members are NOT displayed on TaskPage
    expect(find.text('Paragraph Text Analysis'), findsNothing);
    expect(find.text('Create home UI page'), findsNothing);

    // Verify Team Tasks ASSIGNED TO CURRENT USER (Jarvis / Yoga) ARE displayed with Team Name under title and no profile avatars
    expect(find.text('AI System Final Project'), findsOneWidget);
    expect(find.text('Create team UI page'), findsOneWidget);
    expect(find.text('Kelompok IMPAL'), findsWidgets);
    expect(find.byIcon(Icons.person_rounded), findsNothing);

    // Verify Non-Team Tasks ARE displayed (both College and Personal categories)
    expect(find.text('Linguistics Presentation Video'), findsOneWidget);
    expect(find.text('Mobile App Testing Report'), findsOneWidget);
  });
}


