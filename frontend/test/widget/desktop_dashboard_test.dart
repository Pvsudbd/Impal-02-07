import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/home_page.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_hero_focus_card.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_ongoing_tasks_section.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_sidebar.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_stats_panel.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_top_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildHarness(Size size) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: const MaterialApp(
        home: HomePage(userName: 'Jarvis'),
      ),
    );
  }

  group('Desktop Homepage Dashboard Tests', () {
    testWidgets('renders full FigCraft desktop layout at 1440x980 without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 980);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildHarness(const Size(1440, 980)));
      await tester.pumpAndSettle();

      expect(find.byType(DesktopSidebar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DesktopSidebar),
          matching: find.text('Categories'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(DesktopSidebar),
          matching: find.text('Settings'),
        ),
        findsNothing,
      );
      expect(find.byType(DesktopTopHeader), findsOneWidget);
      expect(find.byType(DesktopHeroFocusCard), findsOneWidget);
      expect(find.byType(DesktopOngoingTasksSection), findsOneWidget);
      expect(find.byType(DesktopStatsPanel), findsOneWidget);

      expect(find.text('Dashboard Overview'), findsOneWidget);
      expect(find.text('Ongoing Tasks'), findsOneWidget);
      expect(find.text("Today's Schedule"), findsOneWidget);
      expect(find.text('Dashboard Statistics'), findsOneWidget);
      expect(find.text('Task Load Distribution'), findsOneWidget);
      expect(find.text('Weekly Productivity'), findsOneWidget);
      expect(find.text('Continue Task ↗'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('collapses and expands sidebar smoothly without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 980);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildHarness(const Size(1440, 980)));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(DesktopSidebar)).width, 260.0);

      await tester.tap(find.byKey(const ValueKey('desktop_sidebar_collapse_btn')));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(DesktopSidebar)).width, 80.0);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey('desktop_sidebar_collapse_btn')));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(DesktopSidebar)).width, 260.0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('filters ongoing tasks via top header search box',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 980);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildHarness(const Size(1440, 980)));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('desktop_search_field')),
        'Frontend',
      );
      await tester.pump();

      expect(find.text('IMPAL Frontend Slicing'), findsOneWidget);
      expect(find.text('IMPAL Figma Design'), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('desktop_search_field')),
        'NonExistentQueryXYZ',
      );
      await tester.pump();

      expect(find.text('Reset Filter'), findsOneWidget);
      await tester.tap(find.text('Reset Filter'));
      await tester.pump();

      expect(find.text('IMPAL Figma Design'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('switches sidebar destinations and falls back cleanly at mobile/tablet',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildHarness(const Size(1024, 768)));
      await tester.pumpAndSettle();
      expect(find.byType(DesktopSidebar), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Switch to Tasks tab via sidebar
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      expect(find.text('Tasks Management'), findsOneWidget);
      expect(find.byType(DesktopSidebar), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Switch back to Dashboard
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard Overview'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tablet fallback check (768dp)
      tester.view.physicalSize = const Size(768, 1024);
      await tester.pumpWidget(buildHarness(const Size(768, 1024)));
      await tester.pumpAndSettle();
      expect(find.byType(DesktopSidebar), findsNothing);
      expect(tester.takeException(), isNull);

      // Standard mobile fallback check (390dp)
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpWidget(buildHarness(const Size(390, 844)));
      await tester.pumpAndSettle();
      expect(find.byType(DesktopSidebar), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'supports expandable task card details, AI Smart Priority banner, and custom category button',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1440, 980);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildHarness(const Size(1440, 980)));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('desktop_ai_smart_priority_banner')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('desktop_add_category_btn')),
          findsOneWidget,
        );

        final firstExpandBtn = find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key as ValueKey<String>).value.startsWith(
                    'desktop_task_expand_',
                  ),
        );
        expect(firstExpandBtn, findsWidgets);
        await tester.ensureVisible(firstExpandBtn.first);
        await tester.tap(firstExpandBtn.first);
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Centeroid Defuzzyfication'),
          findsOneWidget,
        );
        expect(find.textContaining('Date Created'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'opens + Add Task as non-blocking inline right slide drawer on Dashboard Overview',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1440, 980);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildHarness(const Size(1440, 980)));
        await tester.pumpAndSettle();

        final scrollFinder =
            find.byKey(const ValueKey('desktop_homepage_scroll'));
        final beforeWidth = tester.getRect(scrollFinder).width;

        await tester.tap(find.text('+ Add Task'));
        await tester.pumpAndSettle();

        final drawerFinder =
            find.byKey(const ValueKey('desktop_task_slide_drawer'));
        expect(drawerFinder, findsOneWidget);
        expect(find.byType(Dialog), findsNothing);

        final afterRect = tester.getRect(scrollFinder);
        final drawerRect = tester.getRect(drawerFinder);
        expect(afterRect.width, lessThan(beforeWidth));
        expect(drawerRect.right, 1440.0);
        expect(drawerRect.left, closeTo(afterRect.right, 0.5));

        // Bento layout verification: Today's Schedule | Dashboard Statistics side-by-side
        final todayScheduleRect = tester.getRect(find.text("Today's Schedule"));
        final statsHeaderRect =
            tester.getRect(find.text('Dashboard Statistics'));
        expect(
          (todayScheduleRect.top - statsHeaderRect.top).abs(),
          lessThan(6),
        );
        expect(todayScheduleRect.right, lessThan(statsHeaderRect.left));

        // Dashboard remains interactive while Add Task drawer is open
        final collegeFilter = find.descendant(
          of: find.byType(DesktopOngoingTasksSection),
          matching: find.text('College'),
        );
        await tester.ensureVisible(collegeFilter);
        await tester.tap(collegeFilter);
        await tester.pumpAndSettle();
        expect(drawerFinder, findsOneWidget);

        // Compact 1024x768 check with zero overflow
        tester.view.physicalSize = const Size(1024, 768);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Create task and verify drawer slides closed cleanly
        await tester.enterText(
          find.byKey(const ValueKey('desktop_task_title_input')),
          'Dashboard Slide Drawer Task',
        );
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('submit_task_button')));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(drawerFinder, findsNothing);
        tester.view.physicalSize = const Size(1440, 980);
        await tester.pumpAndSettle();
        expect(tester.getRect(scrollFinder).width, equals(beforeWidth));
        expect(tester.takeException(), isNull);
      },
    );
  });
}

