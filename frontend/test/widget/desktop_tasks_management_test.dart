import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/home_page.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_sidebar.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_task_grid_card.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_top_header.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/smart_priority_page.dart';
import 'package:impal_smart_todolist/presentation/features/task/models/task_repository.dart';
import 'package:impal_smart_todolist/presentation/features/task/task_page.dart';
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
      expect(find.text('HIGH PRIORITY'), findsOneWidget);
      expect(find.text('MEDIUM PRIORITY'), findsOneWidget);
      expect(find.text('LOW PRIORITY'), findsOneWidget);
      expect(find.text('TOTAL TASKS'), findsOneWidget);
      expect(find.text('Today Tasks'), findsOneWidget);
      expect(find.text('Upcoming & Overdue Tasks'), findsOneWidget);
      expect(find.text('October 2026'), findsOneWidget);
      expect(find.text('Fuzzy Mamdani Priority Weight'), findsOneWidget);
      expect(find.text('Active Team Collaborators'), findsOneWidget);
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
      expect(find.text('Schedule Matrix'), findsOneWidget);
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
  });
}

