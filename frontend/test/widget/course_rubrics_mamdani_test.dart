import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/core/theme/app_colors.dart';
import 'package:impal_smart_todolist/core/widgets/desktop_slide_drawer_pane.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/home_page.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/detail_card_smart_priority.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/models/course_rubric_repository.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/smart_priority_page.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/widgets/course_rubric_modals.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/widgets/smart_priority_task_card.dart';
import 'package:impal_smart_todolist/presentation/features/task/create_task.dart';
import 'package:impal_smart_todolist/presentation/features/task/widgets/desktop/desktop_personal_task_modal.dart';
import 'package:impal_smart_todolist/presentation/features/team/dashboard_team_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'is_logged_in': true});
    CourseRubricRepository().resetToDefaults();
  });

  void setViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('Course Grading Rubrics & Mamdani Sync Flows', () {
    testWidgets(
      'DesktopSidebar navigates to Smart Priority & renders Course Grading Rubrics',
      (tester) async {
        setViewport(tester, const Size(1440, 900));

        await tester.pumpWidget(
          const MaterialApp(
            home: HomePage(userName: 'Jarvis'),
          ),
        );
        await tester.pumpAndSettle();

        final navItem = find.byKey(const ValueKey('desktop_nav_smart_priority'));
        expect(navItem, findsOneWidget);

        await tester.tap(navItem);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('desktop_smart_priority_view')),
          findsOneWidget,
        );
        expect(find.text('Course Grading Rubrics'), findsOneWidget);
        expect(find.text('Mamdani Inference Engine'), findsOneWidget);
        expect(find.text('Midterm (UTS)'), findsOneWidget);
        expect(find.text('Team Project'), findsOneWidget);
      },
    );

    testWidgets(
      'Adding a rubric component automatically surfaces in CreateTaskPage',
      (tester) async {
        setViewport(tester, const Size(390, 844));

        // Add custom component "Responsi" (10%) to Linguistics
        final addRes = await CourseRubricRepository().addComponent(
          courseId: 'course_ling',
          name: 'Responsi',
          weightPercent: 10,
        );
        expect(addRes.success, isTrue);

        TaskItemModel? createdTask;
        await tester.pumpWidget(
          MaterialApp(
            home: CreateTaskPage(
              onTaskCreated: (t) => createdTask = t,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Switch course chip to Linguistics
        final lingChip =
            find.byKey(const ValueKey('task_course_chip_course_ling'));
        expect(lingChip, findsOneWidget);
        await tester.ensureVisible(lingChip);
        await tester.tap(lingChip);
        await tester.pumpAndSettle();

        // Verify newly added component "Responsi" auto-appears!
        expect(find.text('Responsi'), findsOneWidget);
        expect(find.text('10%'), findsOneWidget);
        expect(find.text('Essay Assignment'), findsOneWidget);

        // Select Responsi and enter task title
        await tester.tap(find.text('Responsi'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextFormField).first,
          'Linguistics Week 5 Responsi',
        );

        final submitFinder = find.text('Create Task').last;
        await tester.ensureVisible(submitFinder);
        await tester.tap(submitFinder);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(createdTask, isNotNull);
        expect(createdTask!.rubricComponentName, 'Responsi');
        expect(createdTask!.gradeWeightPercent, 10);
      },
    );

    testWidgets(
      'DesktopPersonalTaskModal dynamically updates rubric categories per Course',
      (tester) async {
        setViewport(tester, const Size(1280, 800));

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DesktopPersonalTaskModal(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Default IMPAL course components appear under Task Grade Weight (Automatic ON)
        expect(find.text('Midterm (UTS)'), findsOneWidget);
        expect(find.text('Team Project'), findsOneWidget);

        // Switch course to AI
        final aiChip = find.byKey(const ValueKey('desktop_task_course_course_ai'));
        await tester.ensureVisible(aiChip);
        await tester.tap(aiChip);
        await tester.pumpAndSettle();

        expect(find.text('Major Sprint Project'), findsOneWidget);
        expect(find.text('35%'), findsOneWidget);
      },
    );

    testWidgets(
      'Mobile SmartPriorityPage supports Course Rubrics tab switching cleanly',
      (tester) async {
        setViewport(tester, const Size(390, 844));

        await tester.pumpWidget(
          const MaterialApp(
            home: SmartPriorityPage(userName: 'Jarvis'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('smart_tab_ranking')), findsOneWidget);
        expect(find.byKey(const ValueKey('smart_tab_rubrics')), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('smart_tab_rubrics')));
        await tester.pumpAndSettle();

        expect(find.text('Course Grading Rubrics'), findsOneWidget);
        expect(find.text('Midterm (UTS)'), findsOneWidget);
      },
    );

    testWidgets(
      'Desktop & Mobile DashboardTeamPage syncs rubric bidirectionally with CourseRubricRepository',
      (tester) async {
        setViewport(tester, const Size(1440, 900));

        await tester.pumpWidget(
          const MaterialApp(
            home: DashboardTeamPage(
              userName: 'Jarvis',
              teamName: 'IMPAL Team',
              teamCode: '7X29',
              isStandalone: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final syncBtn =
            find.byKey(const ValueKey('desktop_workspace_sync_rubric_btn'));
        expect(syncBtn, findsOneWidget);
        expect(find.textContaining('Team Project (30%)'), findsOneWidget);

        await tester.tap(syncBtn);
        await tester.pumpAndSettle();

        expect(find.byType(AssignRubricToTeamDialog), findsOneWidget);
      },
    );

    testWidgets(
      'Mobile SmartPriorityPage opens DetailCardSmartPriority bottom sheet on card tap',
      (tester) async {
        setViewport(tester, const Size(390, 844));

        await tester.pumpWidget(
          const MaterialApp(
            home: SmartPriorityPage(userName: 'Jarvis'),
          ),
        );
        await tester.pumpAndSettle();

        final firstCard = find.byType(SmartPriorityTaskCard).first;
        expect(find.byType(DetailCardSmartPriority), findsNothing);

        await tester.ensureVisible(firstCard);
        await tester.tap(firstCard);
        await tester.pumpAndSettle();

        expect(find.byType(DetailCardSmartPriority), findsOneWidget);
        expect(find.text('1. INPUT PARAMETER FUZZIFICATION'), findsOneWidget);
        expect(find.text('2. CENTROID DEFUZZIFICATION'), findsOneWidget);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        expect(find.byType(DetailCardSmartPriority), findsNothing);
      },
    );

    testWidgets(
      'Desktop Home Smart Priority banner navigates to DesktopSmartPriorityView & drops down card XAI details inline',
      (tester) async {
        setViewport(tester, const Size(1440, 980));

        await tester.pumpWidget(
          const MaterialApp(
            home: HomePage(userName: 'Jarvis'),
          ),
        );
        await tester.pumpAndSettle();

        final banner =
            find.byKey(const ValueKey('desktop_ai_smart_priority_banner'));
        expect(banner, findsOneWidget);
        await tester.ensureVisible(banner);
        await tester.tap(banner);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('desktop_smart_priority_view')),
          findsOneWidget,
        );
        expect(find.byType(SmartPriorityPage), findsNothing);

        final firstDesktopCard = find.byType(SmartPriorityTaskCard).first;
        expect(find.text('1. INPUT PARAMETER FUZZIFICATION'), findsNothing);

        await tester.ensureVisible(firstDesktopCard);
        await tester.tap(firstDesktopCard);
        await tester.pumpAndSettle();

        expect(find.byType(DetailCardSmartPriority), findsNothing);
        expect(find.text('1. INPUT PARAMETER FUZZIFICATION'), findsOneWidget);
        expect(find.text('2. CENTROID DEFUZZIFICATION'), findsOneWidget);

        await tester.tap(firstDesktopCard);
        await tester.pumpAndSettle();

        expect(find.text('1. INPUT PARAMETER FUZZIFICATION'), findsNothing);
      },
    );

    testWidgets(
      'Desktop Smart Priority renders single header + Add Course button that opens inline slide drawer without overflow at 1440x980 & 1024x768',
      (tester) async {
        setViewport(tester, const Size(1440, 980));

        await tester.pumpWidget(
          const MaterialApp(
            home: HomePage(userName: 'Jarvis', initialTab: 5),
          ),
        );
        await tester.pumpAndSettle();

        // Only header + Add Course button is rendered (no duplicate inside CourseRubricManagerPanel)
        expect(find.byKey(const ValueKey('rubric_add_course_btn')), findsNothing);
        expect(find.text('+ Add Course'), findsOneWidget);

        final slidePaneFinder = find.byType(DesktopSlideDrawerPane);
        expect(slidePaneFinder, findsOneWidget);
        expect(tester.widget<DesktopSlideDrawerPane>(slidePaneFinder).isOpen, isFalse);

        await tester.tap(find.text('+ Add Course'));
        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsNothing);
        expect(tester.widget<DesktopSlideDrawerPane>(slidePaneFinder).isOpen, isTrue);

        final drawerFinder =
            find.byKey(const ValueKey('desktop_add_course_slide_drawer'));
        expect(drawerFinder, findsOneWidget);
        expect(tester.getSize(drawerFinder).width, 440.0);

        final codeField = tester.widget<TextField>(
          find.descendant(
            of: find.byKey(const ValueKey('course_code_field')),
            matching: find.byType(TextField),
          ),
        );
        expect(codeField.decoration?.fillColor, AppColors.bgCard);

        // When Add Course drawer opens, Course Grading Rubrics moves below Mamdani ranking
        final rankingTop =
            tester.getTopLeft(find.text('Mamdani Inference Engine')).dy;
        final rubricsTop =
            tester.getTopLeft(find.text('Course Grading Rubrics')).dy;
        expect(rankingTop, lessThan(rubricsTop));

        // Main Smart Priority workspace stays interactive while drawer is open
        final highFilterFinder = find.textContaining('High (');
        await tester.ensureVisible(highFilterFinder);
        await tester.tap(highFilterFinder);
        await tester.pumpAndSettle();
        expect(tester.widget<DesktopSlideDrawerPane>(slidePaneFinder).isOpen, isTrue);

        // Create a new course via drawer and verify drawer closes + course appears
        await tester.enterText(
          find.byKey(const ValueKey('course_code_field')),
          'CS301',
        );
        await tester.enterText(
          find.byKey(const ValueKey('course_name_field')),
          'Cloud Architecture',
        );
        await tester.tap(find.byKey(const ValueKey('save_course_btn')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();

        expect(tester.widget<DesktopSlideDrawerPane>(slidePaneFinder).isOpen, isFalse);
        expect(find.textContaining('Cloud Architecture'), findsWidgets);

        // Verify compact 1024x768 desktop with drawer open renders with 0 overflow
        setViewport(tester, const Size(1024, 768));
        await tester.pumpWidget(
          const MaterialApp(
            home: HomePage(
              key: ValueKey('sp_home_1024'),
              userName: 'Jarvis',
              initialTab: 5,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('+ Add Course'));
        await tester.pumpAndSettle();

        expect(tester.getSize(drawerFinder).width, 380.0);
        expect(tester.takeException(), isNull);

        // Verify ultrawide / 1920x1080 monitor ALSO stacks Course Grading Rubrics below when drawer is open
        setViewport(tester, const Size(1920, 1080));
        await tester.pumpWidget(
          const MaterialApp(
            home: HomePage(
              key: ValueKey('sp_home_1920'),
              userName: 'Jarvis',
              initialTab: 5,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('+ Add Course'));
        await tester.pumpAndSettle();

        expect(
          tester.getTopLeft(find.text('Mamdani Inference Engine')).dy,
          lessThan(tester.getTopLeft(find.text('Course Grading Rubrics')).dy),
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
