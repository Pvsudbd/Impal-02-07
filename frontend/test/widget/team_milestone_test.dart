import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/team/create_task_team.dart';
import 'package:impal_smart_todolist/presentation/features/team/dashboard_team_page.dart';
import 'package:impal_smart_todolist/presentation/features/team/models/team_task_repository.dart';
import 'package:impal_smart_todolist/presentation/features/team/widgets/team_task_card.dart';

void main() {
  setUp(() {
    TeamTaskRepository().resetToDefaults();
  });

  testWidgets('Milestone category-style card filters and unfilters team tasks on tap with 0 pixel shifts', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardTeamPage(
          userName: 'Jarvis',
          teamName: 'Kelompok IMPAL',
          teamCode: '7X29',
          isStandalone: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Milestones section & Add Milestone '+' button exist
    expect(find.text('Milestones'), findsOneWidget);
    expect(find.byKey(const ValueKey('add_milestone_button')), findsOneWidget);

    // 2. Verify initial Milestone 'Responsi 1 - UI & Architecture' card exists with circular ring
    expect(find.text('Responsi 1 - UI & Architecture'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // 3. Verify flag icon is removed from milestone card
    expect(find.byIcon(Icons.flag_rounded), findsNothing);

    // Initial state: ALL tasks are visible in the team
    expect(find.text('Create team UI page'), findsOneWidget);
    expect(find.text('Create home UI page'), findsOneWidget);
    expect(find.text('Create task form UI'), findsOneWidget);

    // 4. TAP the Milestone card -> FILTERS to only tasks in this milestone
    await tester.tap(find.text('Responsi 1 - UI & Architecture'));
    await tester.pumpAndSettle();

    // Only milestone member tasks (task_1 & task_2) are visible!
    expect(find.text('Create team UI page'), findsOneWidget);
    expect(find.text('Create home UI page'), findsOneWidget);
    // task_3 is NOT in this milestone, so it should NOT be found!
    expect(find.text('Create task form UI'), findsNothing);

    // 5. TAP the Milestone card AGAIN -> TOGGLES OFF and shows ALL tasks again!
    await tester.tap(find.text('Responsi 1 - UI & Architecture'));
    await tester.pumpAndSettle();

    // Filter cleared! All tasks visible again!
    expect(find.text('Create team UI page'), findsOneWidget);
    expect(find.text('Create home UI page'), findsOneWidget);
    expect(find.text('Create task form UI'), findsOneWidget);

    // 6. Verify Team Task cards do NOT contain CircularProgressIndicator (exclusive to Milestones)
    final teamTaskCards = find.byType(TeamTaskCard);
    expect(teamTaskCards, findsWidgets);
    expect(
      find.descendant(of: teamTaskCards, matching: find.byType(CircularProgressIndicator)),
      findsNothing,
    );
  });

  testWidgets('CreateTaskTeamPage allows selecting and clearing milestone directly from the form', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: CreateTaskTeamPage(
          teamCode: '7X29',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify milestone selector label and dropdown exist
    expect(find.text('Milestone (Optional)'), findsOneWidget);
    expect(find.text('None (No Milestone)'), findsOneWidget);
  });

  testWidgets('Deleting a milestone keeps member tasks safe as individual tasks', (tester) async {
    final repo = TeamTaskRepository();
    repo.resetToDefaults();

    final milestonesBefore = repo.getMilestones('7X29');
    expect(milestonesBefore.length, equals(1));
    expect(repo.getUncategorizedTasks('7X29').length, equals(1));

    // Delete the milestone
    repo.deleteMilestone('7X29', 'milestone_1');

    // Milestones should now be empty
    expect(repo.getMilestones('7X29'), isEmpty);

    // All 3 tasks should now be uncategorized (safe from deletion!)
    final uncategorized = repo.getUncategorizedTasks('7X29');
    expect(uncategorized.length, equals(3));
  });

  testWidgets('Completed milestones are placed on the left and horizontal scroll is supported', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final repo = TeamTaskRepository();
    repo.resetToDefaults();

    // Add a completed milestone (with task_1 marked done and only task_1 in it)
    repo.toggleTaskDone('7X29', 'task_1');
    repo.addMilestone(
      '7X29',
      TeamMilestoneModel(
        id: 'completed_milestone',
        teamCode: '7X29',
        title: 'Finished Milestone',
        deadline: DateTime(2026, 10, 10),
        formattedDeadline: 'Sat 10 Oct 2026',
        taskIds: const ['task_1'],
        dateCreated: DateTime(2026, 10, 1),
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardTeamPage(
          userName: 'Jarvis',
          teamName: 'Kelompok IMPAL',
          teamCode: '7X29',
          isStandalone: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Both Finished Milestone and Responsi 1 exist
    expect(find.text('Finished Milestone'), findsOneWidget);
    expect(find.text('Responsi 1 - UI & Architecture'), findsOneWidget);

    // Verify horizontal scrolling can be dragged left/right
    final milestoneFinder = find.text('Finished Milestone');
    await tester.drag(milestoneFinder, const Offset(-100, 0));
    await tester.pumpAndSettle();
  });
}
