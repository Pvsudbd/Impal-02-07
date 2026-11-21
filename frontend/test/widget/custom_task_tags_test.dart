import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/home_page.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/models/course_rubric_repository.dart';
import 'package:impal_smart_todolist/presentation/features/task/models/tag_repository.dart';
import 'package:impal_smart_todolist/presentation/features/task/task_page.dart';
import 'package:impal_smart_todolist/presentation/features/task/widgets/desktop/desktop_personal_task_modal.dart';
import 'package:impal_smart_todolist/presentation/features/task/widgets/desktop/desktop_tasks_management_view.dart';
import 'package:impal_smart_todolist/presentation/features/team/models/team_task_model.dart';
import 'package:impal_smart_todolist/presentation/features/team/widgets/desktop/desktop_team_task_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'is_logged_in': true});
    CourseRubricRepository().resetToDefaults();
    TaskTagRepository().resetToDefaults();
  });

  void setViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('Custom Task Tags & Unified Filter Sync', () {
    testWidgets(
      'Mobile Home opens AddCustomTagDialog on + tap, adds tag, and filters cleanly',
      (tester) async {
        setViewport(tester, const Size(390, 844));

        await tester.pumpWidget(
          const MaterialApp(home: HomePage(userName: 'Jarvis')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('mobile_category_tab_all')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('mobile_category_tab_college')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('mobile_category_tab_personal')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('mobile_category_tab_team')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('tag_filter_horizontal_scroll')),
          findsOneWidget,
        );
        // Mobile must NOT display X buttons next to tag text (long-press instead).
        expect(
          find.byKey(const ValueKey('delete_custom_tag_tag_figma')),
          findsNothing,
        );

        final teamTab = find.byKey(const ValueKey('mobile_category_tab_team'));
        await Scrollable.ensureVisible(
          tester.element(teamTab),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(teamTab);
        await tester.pumpAndSettle();

        final collegeTab =
            find.byKey(const ValueKey('mobile_category_tab_college'));
        await Scrollable.ensureVisible(
          tester.element(collegeTab),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(collegeTab);
        await tester.pumpAndSettle();

        final allTab = find.byKey(const ValueKey('mobile_category_tab_all'));
        await Scrollable.ensureVisible(
          tester.element(allTab),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(allTab);
        await tester.pumpAndSettle();

        final addBtn = find.byKey(const ValueKey('mobile_add_category_btn'));
        expect(addBtn, findsOneWidget);
        await tester.tap(addBtn);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('custom_tag_name_input')),
          'Organization',
        );
        await tester.tap(find.byKey(const ValueKey('tag_color_coral')));
        await tester.tap(
          find.byKey(const ValueKey('confirm_add_custom_tag_btn')),
        );
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        expect(TaskTagRepository().findByLabel('Organization'), isNotNull);
        expect(find.text('Organization'), findsOneWidget);

        final figmaChip = find.byKey(const ValueKey('tag_filter_chip_tag_figma'));
        await Scrollable.ensureVisible(
          tester.element(figmaChip),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();

        await tester.tap(figmaChip);
        await tester.pumpAndSettle();

        expect(find.text('Wallet App Design'), findsOneWidget);
        expect(find.text('IMPAL Frontend Slicing'), findsNothing);

        // Long-press on Mobile deletes existing tag cleanly after confirmation
        final orgTag = TaskTagRepository().findByLabel('Organization')!;
        final orgChip = find.byKey(ValueKey('tag_filter_chip_${orgTag.id}'));
        await Scrollable.ensureVisible(
          tester.element(orgChip),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.longPress(orgChip);
        await tester.pumpAndSettle();
        expect(find.text('Delete Tag?'), findsOneWidget);
        await tester.tap(find.text('Delete').last);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(TaskTagRepository().findByLabel('Organization'), isNull);
      },
    );

    testWidgets(
      'Desktop Home quick filters sync with TaskTagRepository and filter tasks',
      (tester) async {
        setViewport(tester, const Size(1440, 900));

        await TaskTagRepository().addTag(label: 'Sprint');

        await tester.pumpWidget(
          const MaterialApp(home: HomePage(userName: 'Jarvis')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Team'), findsWidgets);
        expect(find.text('Sprint'), findsWidgets);
        expect(
          find.byKey(const ValueKey('desktop_delete_tag_tag_figma')),
          findsOneWidget,
        );

        await tester.tap(find.text('Code').first);
        await tester.pumpAndSettle();

        expect(find.text('IMPAL Frontend Slicing'), findsOneWidget);
      },
    );

    testWidgets(
      'DesktopPersonalTaskModal attaches multiple selected tags cleanly',
      (tester) async {
        setViewport(tester, const Size(1280, 820));

        TaskItemModel? desktopCreated;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DesktopPersonalTaskModal(
                onTaskCreated: (t) => desktopCreated = t,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('desktop_task_title_input')),
          'Design Wireframe & Backend API',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();

        final figmaChip = find.byKey(const ValueKey('task_tag_option_tag_figma'));
        await Scrollable.ensureVisible(
          tester.element(figmaChip),
          alignment: 0.3,
        );
        await tester.pumpAndSettle();
        await tester.tap(figmaChip);
        await tester.pumpAndSettle();

        final backendChip =
            find.byKey(const ValueKey('task_tag_option_tag_backend'));
        await Scrollable.ensureVisible(
          tester.element(backendChip),
          alignment: 0.3,
        );
        await tester.pumpAndSettle();
        await tester.tap(backendChip);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Create Task').last);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(desktopCreated, isNotNull);
        final labels = desktopCreated!.tags.map((t) => t.label).toList();
        expect(labels, containsAll(['Figma', 'Backend']));
      },
    );

    testWidgets(
      'Create Task forms support deleting existing tags (X on Desktop, long-press on Mobile)',
      (tester) async {
        // 1. Desktop Create Task Modal deletes tag via X button
        setViewport(tester, const Size(1280, 820));
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DesktopPersonalTaskModal()),
          ),
        );
        await tester.pumpAndSettle();

        final desktopDeleteResearch =
            find.byKey(const ValueKey('task_tag_delete_tag_research'));
        expect(desktopDeleteResearch, findsOneWidget);
        await Scrollable.ensureVisible(
          tester.element(desktopDeleteResearch),
          alignment: 0.3,
        );
        await tester.pumpAndSettle();
        await tester.tap(desktopDeleteResearch);
        await tester.pumpAndSettle();
        expect(find.text('Delete Tag?'), findsOneWidget);
        await tester.tap(find.text('Delete').last);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(TaskTagRepository().findByLabel('Research'), isNull);

        // 2. Mobile CreateTaskPage hides X button and deletes tag via long-press
        setViewport(tester, const Size(390, 844));
        await tester.pumpWidget(
          const MaterialApp(home: CreateTaskPage()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hold tag to delete'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('task_tag_delete_tag_code')),
          findsNothing,
        );

        final codeOption = find.byKey(const ValueKey('task_tag_option_tag_code'));
        await Scrollable.ensureVisible(
          tester.element(codeOption),
          alignment: 0.3,
        );
        await tester.pumpAndSettle();
        await tester.longPress(codeOption);
        await tester.pumpAndSettle();
        expect(find.text('Delete Tag?'), findsOneWidget);
        await tester.tap(find.text('Delete').last);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(TaskTagRepository().findByLabel('Code'), isNull);
      },
    );

    testWidgets(
      'DesktopTeamTaskModal attaches selected tags to TeamTaskModel',
      (tester) async {
        setViewport(tester, const Size(1280, 820));

        TeamTaskModel? createdTeamTask;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DesktopTeamTaskModal(
                teamCode: '7X29',
                teamName: 'IMPAL Team',
                onTaskCreated: (t) => createdTeamTask = t,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('desktop_team_task_name_input')),
          'Implement Auth Controller',
        );
        final codeTag = find.byKey(const ValueKey('task_tag_option_tag_code'));
        await tester.ensureVisible(codeTag);
        await tester.tap(codeTag);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Create Task').last);
        await tester.pumpAndSettle();

        expect(createdTeamTask, isNotNull);
        expect(createdTeamTask!.tags.map((t) => t.label), contains('Code'));
      },
    );

    testWidgets(
      'DesktopTasksManagementView & Mobile TaskPage filter cleanly by TagFilterStrip',
      (tester) async {
        setViewport(tester, const Size(1440, 900));

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DesktopTasksManagementView(userName: 'Jarvis'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('tag_filter_all')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('tag_filter_chip_tag_figma')),
          findsOneWidget,
        );

        setViewport(tester, const Size(390, 844));
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TaskContentView(userName: 'Jarvis'),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Auto-scroll in TaskContentView scrolls down to first active task; scroll back up to check TagFilterStrip
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, 500),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('tag_filter_all')), findsOneWidget);
      },
    );
  });
}
