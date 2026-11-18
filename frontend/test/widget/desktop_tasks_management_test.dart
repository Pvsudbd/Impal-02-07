import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/home_page.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_sidebar.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_task_grid_card.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_top_header.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/smart_priority_page.dart';
import 'package:impal_smart_todolist/presentation/features/task/models/task_repository.dart';
import 'package:impal_smart_todolist/presentation/features/task/task_page.dart';
import 'package:impal_smart_todolist/presentation/features/task/widgets/desktop/desktop_personal_task_modal.dart';
import 'package:impal_smart_todolist/presentation/features/task/widgets/desktop/desktop_task_filter_bar.dart';
import 'package:impal_smart_todolist/presentation/features/task/widgets/desktop/desktop_task_kpi_row.dart';
import 'package:impal_smart_todolist/presentation/features/task/widgets/desktop/desktop_tasks_management_view.dart';
import 'package:impal_smart_todolist/presentation/features/task/widgets/desktop/desktop_tasks_right_panel.dart';
import 'package:impal_smart_todolist/presentation/features/team/models/team_task_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TaskRepository().resetToDefaults();
    TeamTaskRepository().resetToDefaults();
  });

  Widget buildHarness(Size size, {Widget? child}) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        home: child ?? const HomePage(userName: 'Jarvis', initialTab: 1),
      ),
    );
  }

  group('Desktop Tasks Management Tests', () {
    testWidgets(
        'renders full 2-column Desktop Tasks Management layout at 1440x980 without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 980);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildHarness(const Size(1440, 980)));
      await tester.pumpAndSettle();

      expect(find.byType(DesktopSidebar), findsOneWidget);
      expect(find.byType(DesktopTopHeader), findsOneWidget);
      expect(find.byType(DesktopTasksManagementView), findsOneWidget);
      expect(find.byType(DesktopTaskKpiRow), findsOneWidget);
      expect(find.byType(DesktopTaskFilterBar), findsOneWidget);
      expect(find.byType(DesktopTasksRightPanel), findsOneWidget);

      expect(find.text('Tasks Management'), findsOneWidget);
      expect(find.text('+ Add New Task'), findsOneWidget);
      expect(find.text('Timeline'), findsOneWidget);
      expect(find.text('High'), findsWidgets);
      expect(find.text('Medium'), findsWidgets);
      expect(find.text('Low'), findsWidgets);
      expect(
        find.byKey(const ValueKey('desktop_ai_smart_priority_bar')),
        findsOneWidget,
      );
      expect(find.text('AI Smart Priority Ranking'), findsOneWidget);
      expect(find.text('Mamdani CoG'), findsOneWidget);
      expect(find.text('Today Tasks'), findsOneWidget);
      expect(find.text('Upcoming & Overdue Tasks'), findsOneWidget);
      expect(find.text('October 2026'), findsOneWidget);
      expect(find.text('Fuzzy Mamdani Priority Weight'), findsOneWidget);
      expect(find.text('Active Team Collaborators'), findsOneWidget);
      expect(find.text('Sort: Deadline ▾'), findsOneWidget);
      expect(find.text('Type: All ▾'), findsOneWidget);

      // Verify Row Filters Bar matches FigCraft hug-content & horizontal layout
      final filterBarRect = tester.getRect(find.byType(DesktopTaskFilterBar));
      final allRect =
          tester.getRect(find.byKey(const ValueKey('desktop_filter_All Tasks')));
      final todayRect =
          tester.getRect(find.byKey(const ValueKey('desktop_filter_Today')));
      final next7Rect = tester
          .getRect(find.byKey(const ValueKey('desktop_filter_Next 7 Days')));
      final overdueRect =
          tester.getRect(find.byKey(const ValueKey('desktop_filter_Overdue')));
      final sortRect =
          tester.getRect(find.byKey(const ValueKey('desktop_sort_dropdown')));
      final typeRect =
          tester.getRect(find.byKey(const ValueKey('desktop_type_dropdown')));

      // Pills must be hug-content (far narrower than the filter bar width)
      expect(allRect.width, lessThan(filterBarRect.width * 0.4));
      expect(todayRect.width, lessThan(filterBarRect.width * 0.4));
      expect(next7Rect.width, lessThan(filterBarRect.width * 0.4));
      expect(overdueRect.width, lessThan(filterBarRect.width * 0.4));

      // Dropdowns stay pinned to the right side of the filter bar Row (not stacked below)
      expect((sortRect.center.dy - typeRect.center.dy).abs(), lessThan(4.0));
      expect(sortRect.left, greaterThan(allRect.right));
      expect(typeRect.left, greaterThan(sortRect.right));

      expect(find.byType(DesktopTaskGridCard), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(DesktopTaskGridCard),
          matching: find.byIcon(Icons.check_rounded),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'supports minimized sidebar (80dp) and narrow desktop (1024x768) without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 980);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildHarness(const Size(1440, 980)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('desktop_sidebar_collapse_btn')));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(DesktopSidebar)).width, 80.0);
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpWidget(buildHarness(const Size(1024, 768)));
      await tester.pumpAndSettle();
      expect(find.byType(DesktopTasksManagementView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'filters by time pill, KPI priority, search query, and calendar date',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 980);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildHarness(const Size(1440, 980)));
      await tester.pumpAndSettle();

      // Filter pill switching (Today & Next 7 Days)
      await tester.tap(find.byKey(const ValueKey('desktop_filter_Next 7 Days')));
      await tester.pump();
      expect(find.text('Academic Advisory Consultation'), findsOneWidget);
      expect(find.text('AI System Final Project'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('desktop_filter_All Tasks')));
      await tester.pump();
      expect(find.text('AI System Final Project'), findsOneWidget);

      // KPI High Priority toggle filters down tasks cleanly
      await tester.tap(find.byKey(const ValueKey('desktop_kpi_high')));
      await tester.pump();
      expect(find.text('Priority: High'), findsOneWidget);
      expect(find.text('Linguistics Presentation Video'), findsNothing);
      expect(tester.takeException(), isNull);

      // Clear filter via chip
      await tester.tap(find.text('Priority: High'));
      await tester.pump();
      expect(find.text('Linguistics Presentation Video'), findsOneWidget);

      // Filter by calendar date (13 Oct has Academic Advisory Consultation)
      await tester.tap(find.byKey(const ValueKey('desktop_cal_day_2026_10_13')));
      await tester.pump();
      expect(find.text('Date: 13 Oct'), findsOneWidget);
      expect(find.text('Academic Advisory Consultation'), findsOneWidget);
      expect(find.text('AI System Final Project'), findsNothing);

      // Reset via calendar day re-tap
      await tester.tap(find.byKey(const ValueKey('desktop_cal_day_2026_10_13')));
      await tester.pump();
      expect(find.text('AI System Final Project'), findsOneWidget);

      // Calendar month navigation
      await tester.tap(find.byKey(const ValueKey('desktop_cal_next')));
      await tester.pump();
      expect(find.text('November 2026'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('desktop_cal_prev')));
      await tester.pump();
      expect(find.text('October 2026'), findsOneWidget);

      // Search box + empty state reset
      await tester.enterText(
        find.byKey(const ValueKey('desktop_search_field')),
        'UnknownTaskXYZ999',
      );
      await tester.pump();
      expect(find.text('Reset All Filters'), findsOneWidget);
      await tester.tap(find.text('Reset All Filters'));
      await tester.pump();
      expect(find.text('AI System Final Project'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'navigates to SmartPriorityPage, Schedule tab, and supports standalone TaskPage on desktop',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 980);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildHarness(const Size(1440, 980)));
      await tester.pumpAndSettle();

      // Open SmartPriorityPage from Fuzzy Mamdani widget
      await tester.ensureVisible(
        find.byKey(const ValueKey('desktop_fuzzy_mamdani_card')),
      );
      await tester.tap(find.byKey(const ValueKey('desktop_fuzzy_mamdani_card')));
      await tester.pumpAndSettle();
      expect(find.byType(SmartPriorityPage), findsOneWidget);

      Navigator.of(tester.element(find.byType(SmartPriorityPage))).pop();
      await tester.pumpAndSettle();

      // View Timeline Calendar -> switches to Schedule tab
      await tester.ensureVisible(
        find.byKey(const ValueKey('desktop_view_timeline_calendar_btn')),
      );
      await tester.tap(
        find.byKey(const ValueKey('desktop_view_timeline_calendar_btn')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Weekly Schedule Matrix'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Standalone TaskPage on desktop also renders desktop Tasks Management view
      await tester.pumpWidget(
        buildHarness(
          const Size(1440, 980),
          child: const TaskPage(userName: 'Jarvis', isStandalone: true),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DesktopTasksManagementView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'renders DesktopTaskFilterBar on a single horizontal row when width fits FigCraft proportions',
        (tester) async {
      // Simulate a wide enough viewport (1800dp) so even Ahem square glyphs
      // fit all 4 pills + 2 dropdowns on one line, verifying single-row Row(spaceBetween).
      tester.view.physicalSize = const Size(1800, 980);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildHarness(
          const Size(1800, 980),
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 1400,
                child: DesktopTaskFilterBar(
                  selectedTimeFilter: 'Today',
                  allCount: 10,
                  todayCount: 4,
                  next7DaysCount: 3,
                  overdueCount: 3,
                  sortBy: 'Deadline',
                  taskTypeFilter: 'All',
                  onTimeFilterSelected: (_) {},
                  onSortChanged: (_) {},
                  onTaskTypeChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final allRect =
          tester.getRect(find.byKey(const ValueKey('desktop_filter_All Tasks')));
      final todayRect =
          tester.getRect(find.byKey(const ValueKey('desktop_filter_Today')));
      final next7Rect = tester
          .getRect(find.byKey(const ValueKey('desktop_filter_Next 7 Days')));
      final overdueRect =
          tester.getRect(find.byKey(const ValueKey('desktop_filter_Overdue')));
      final sortRect =
          tester.getRect(find.byKey(const ValueKey('desktop_sort_dropdown')));
      final typeRect =
          tester.getRect(find.byKey(const ValueKey('desktop_type_dropdown')));

      expect(todayRect.left, greaterThan(allRect.right));
      expect(next7Rect.left, greaterThan(todayRect.right));
      expect(overdueRect.left, greaterThan(next7Rect.right));
      expect(sortRect.left, greaterThan(overdueRect.right));
      expect(typeRect.left, greaterThan(sortRect.right));

      expect((allRect.center.dy - todayRect.center.dy).abs(), lessThan(4.0));
      expect((todayRect.center.dy - next7Rect.center.dy).abs(), lessThan(4.0));
      expect((next7Rect.center.dy - overdueRect.center.dy).abs(), lessThan(4.0));
      expect((overdueRect.center.dy - sortRect.center.dy).abs(), lessThan(4.0));
      expect((sortRect.center.dy - typeRect.center.dy).abs(), lessThan(4.0));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'supports quick task completion, Completed Tasks section, and Type: Completed filter',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1440, 980);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildHarness(const Size(1440, 980)));
        await tester.pumpAndSettle();

        final quickCompleteBtn = find.byKey(
          const ValueKey('desktop_task_quick_complete_task_2'),
        );
        expect(quickCompleteBtn, findsOneWidget);
        await tester.ensureVisible(quickCompleteBtn);
        await tester.tap(quickCompleteBtn);
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(find.text('Completed Tasks'), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('desktop_type_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Completed').last);
        await tester.pumpAndSettle();
        expect(find.textContaining('Type: Completed'), findsOneWidget);

        // Restore task_2 back to active so repository state remains clean
        final reopenBtn = find.byKey(
          const ValueKey('desktop_task_quick_complete_task_2'),
        );
        expect(reopenBtn, findsOneWidget);
        await tester.ensureVisible(reopenBtn);
        await tester.tap(reopenBtn);
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'opens DesktopPersonalTaskModal from + Add New Task with mobile wording, Title Case, top bell alert, and collapsible Automatic priority options',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1440, 980);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildHarness(const Size(1440, 980)));
        await tester.pumpAndSettle();

        await tester.tap(find.text('+ Add New Task'));
        await tester.pumpAndSettle();

        final modalFinder = find.byType(DesktopPersonalTaskModal);
        expect(modalFinder, findsOneWidget);

        // Mobile Title Case wording (no ALL-CAPS FigCraft labels)
        Finder inModal(String text) =>
            find.descendant(of: modalFinder, matching: find.text(text));

        expect(inModal('Create Task'), findsNWidgets(2));
        expect(inModal('Task Details'), findsNothing);
        expect(inModal('Task Category'), findsOneWidget);
        expect(inModal('College Task'), findsOneWidget);
        expect(inModal('Personal'), findsOneWidget);
        expect(inModal('Task Title'), findsOneWidget);
        expect(inModal('Course'), findsOneWidget);
        expect(inModal('Submission Deadline'), findsOneWidget);
        expect(inModal('Task Grade Weight'), findsOneWidget);
        expect(inModal('Automatic'), findsOneWidget);
        expect(inModal('Notes & Instructions'), findsOneWidget);
        expect(inModal('Alert On'), findsOneWidget);

        // No FigCraft ALL-CAPS or bottom switch row
        expect(find.text('TASK NAME'), findsNothing);
        expect(find.text('SUBMISSION DEADLINE'), findsNothing);
        expect(
          find.textContaining('AUTOMATIC AI PRIORITY'),
          findsNothing,
        );
        expect(
          find.textContaining('Enable Deadline Reminder Alerts'),
          findsNothing,
        );

        // Automatic ON by default -> High/Medium/Low options are hidden (collapsed)
        expect(
          find
              .byKey(const ValueKey('desktop_task_priority_high'))
              .hitTestable(),
          findsNothing,
        );

        // Turn Automatic OFF -> High, Medium, Low appear and are selectable
        await tester.tap(
          find.byKey(const ValueKey('desktop_task_automatic_toggle')),
        );
        await tester.pumpAndSettle();
        expect(
          find
              .byKey(const ValueKey('desktop_task_priority_high'))
              .hitTestable(),
          findsOneWidget,
        );
        expect(
          find
              .byKey(const ValueKey('desktop_task_priority_medium'))
              .hitTestable(),
          findsOneWidget,
        );
        expect(
          find
              .byKey(const ValueKey('desktop_task_priority_low'))
              .hitTestable(),
          findsOneWidget,
        );
        await tester.tap(
          find.byKey(const ValueKey('desktop_task_priority_medium')),
        );
        await tester.pumpAndSettle();

        // Top bell Alert On -> Alert Off toggle
        await tester.tap(
          find.byKey(const ValueKey('desktop_task_modal_alert_toggle')),
        );
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('Alert Off'), findsOneWidget);

        // Category switch to Personal hides Course field
        await tester.tap(
          find.byKey(const ValueKey('desktop_task_category_personal')),
        );
        await tester.pumpAndSettle();
        expect(
          find
              .byKey(const ValueKey('desktop_task_course_input'))
              .hitTestable(),
          findsNothing,
        );

        // Compact 1024x768 check with zero overflow
        tester.view.physicalSize = const Size(1024, 768);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Enter title and submit new task
        await tester.enterText(
          find.byKey(const ValueKey('desktop_task_title_input')),
          'Desktop Modal Personal Task',
        );
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('submit_task_button')));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(modalFinder, findsNothing);
        expect(find.text('Desktop Modal Personal Task'), findsOneWidget);

        // Open existing personal task in Edit mode modal
        await tester.ensureVisible(find.text('Desktop Modal Personal Task'));
        await tester.tap(find.text('Desktop Modal Personal Task'));
        await tester.pumpAndSettle();
        expect(modalFinder, findsOneWidget);
        expect(inModal('Edit Task'), findsOneWidget);
        expect(inModal('Edit Task Details'), findsNothing);
        expect(inModal('Save Changes'), findsOneWidget);
        expect(inModal('Delete Task'), findsOneWidget);
        expect(find.byKey(const ValueKey('desktop_task_cancel_btn')), findsNothing);

        // Tap top-right close button to dismiss modal
        await tester.tap(
          find.byKey(const ValueKey('desktop_task_modal_close_btn')),
        );
        await tester.pumpAndSettle();
        expect(modalFinder, findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });
}

