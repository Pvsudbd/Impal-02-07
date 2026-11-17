import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/home_page.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_sidebar.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_top_header.dart';
import 'package:impal_smart_todolist/presentation/features/notifikasi/widgets/notification_bell_button.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/models/schedule_model.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/models/schedule_repository.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/schedule_page.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/widgets/desktop/desktop_schedule_control_bar.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/widgets/desktop/desktop_schedule_kpi_row.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/widgets/desktop/desktop_schedule_matrix_card.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/widgets/desktop/desktop_schedule_matrix_table.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/widgets/desktop/desktop_schedule_matrix_view.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/widgets/desktop/desktop_schedule_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ScheduleRepository().resetToDefault();
  });

  Widget buildHarness(Size size, {Widget? child}) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        home: child ?? const HomePage(userName: 'Jarvis', initialTab: 3),
      ),
    );
  }

  group('Desktop Schedule Matrix Tests', () {
    testWidgets(
        'renders exact FigCraft Desktop - Schedule Matrix (Weekly) at 1440x980 without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 980);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildHarness(const Size(1440, 980)));
      await tester.pumpAndSettle();

      expect(find.byType(DesktopSidebar), findsOneWidget);
      expect(find.byType(DesktopTopHeader), findsOneWidget);
      expect(find.byType(DesktopScheduleMatrixView), findsOneWidget);
      expect(find.byType(DesktopScheduleControlBar), findsOneWidget);
      expect(find.byType(DesktopScheduleKpiRow), findsOneWidget);
      expect(find.byType(DesktopScheduleMatrixTable), findsOneWidget);

      // Strict FigCraft Header parity (no notification bell on Schedule header)
      expect(find.byType(NotificationBellButton), findsNothing);
      expect(find.text('Weekly Schedule Matrix'), findsOneWidget);
      expect(
        find.text(
          'Track your weekly lectures, lab sessions, and group study meetings',
        ),
        findsOneWidget,
      );
      expect(find.text('+ Add Schedule'), findsOneWidget);
      expect(find.text('Search schedule or class...'), findsOneWidget);

      // Control & Filter Bar
      expect(find.text('All'), findsOneWidget);
      // 'Today' appears in View Switcher pill, ControlBar Today button, and Monday table header pill
      expect(find.text('Today'), findsNWidgets(3));
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Oct 12 – Oct 18, 2026'), findsOneWidget);
      expect(find.text('Week 8 • Odd Sem'), findsOneWidget);
      expect(find.text('Lecture'), findsWidgets);
      expect(find.text('Team'), findsWidgets);
      expect(find.text('Study / Lab'), findsOneWidget);

      // KPI Summary Row
      expect(find.text('15 Weekly Sessions'), findsOneWidget);
      expect(find.text('Total Scheduled This Week'), findsOneWidget);
      expect(find.text('2 Classes Today'), findsOneWidget);
      expect(find.text('1 Currently Ongoing'), findsOneWidget);
      expect(find.text('5 Team Meetings'), findsOneWidget);
      expect(find.text('IMPAL & Study Hub Sync'), findsOneWidget);
      expect(find.text('30 Study Hours'), findsOneWidget);
      expect(find.text('18 Active Credits (SKS)'), findsOneWidget);

      // Matrix Table Headers (7 columns Mon..Sun)
      expect(find.text('TIME'), findsOneWidget);
      expect(find.text('Mon, Oct 12'), findsOneWidget);
      expect(find.text('Tue, Oct 13'), findsOneWidget);
      expect(find.text('Wed, Oct 14'), findsOneWidget);
      expect(find.text('Thu, Oct 15'), findsOneWidget);
      expect(find.text('Fri, Oct 16'), findsOneWidget);
      expect(find.text('Sat, Oct 17'), findsOneWidget);
      expect(find.text('Sun, Oct 18'), findsOneWidget);

      // All 14 FigCraft Schedule Matrix Cards
      expect(find.byType(DesktopScheduleMatrixCard), findsNWidgets(14));
      expect(find.text('ALPRO & DATA'), findsOneWidget);
      expect(find.text('UBXCCB2 - B. INDONESIA'), findsOneWidget);
      expect(find.text('PENGUJIAN PL'), findsOneWidget);
      expect(find.text('KECERDASAN AI'), findsOneWidget);
      expect(find.text('B. INDONESIA'), findsOneWidget);
      expect(find.text('SPRINT REVIEW'), findsOneWidget);
      expect(find.text('MENTORING'), findsOneWidget);
      expect(find.text('REKAYASA PL'), findsOneWidget);
      expect(find.text('RESPONSI IMPAL'), findsOneWidget);
      expect(find.text('AI STUDY HUB'), findsOneWidget);
      expect(find.text('UI/UX DESIGN'), findsOneWidget);
      expect(find.text('MEETING IMPAL'), findsOneWidget);
      expect(find.text('SYNC LAPORAN'), findsOneWidget);
      expect(find.text('SPRINT 1 PREP'), findsOneWidget);

      // Verify single-row horizontal alignment in Control Bar
      final allRect =
          tester.getRect(find.byKey(const ValueKey('desktop_schedule_view_All')));
      final prevRect = tester
          .getRect(find.byKey(const ValueKey('desktop_schedule_prev_week')));
      final legendRect =
          tester.getRect(find.byKey(const ValueKey('desktop_legend_kuliah')));
      expect((allRect.center.dy - prevRect.center.dy).abs(), lessThan(4.0));
      expect((prevRect.center.dy - legendRect.center.dy).abs(), lessThan(4.0));
      expect(prevRect.left, greaterThan(allRect.right));
      expect(legendRect.left, greaterThan(prevRect.right));

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'supports Minimized Sidebar (80dp) and narrow desktop (1024x768) without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 980);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildHarness(const Size(1440, 980)));
      await tester.pumpAndSettle();

      await tester
          .tap(find.byKey(const ValueKey('desktop_sidebar_collapse_btn')));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(DesktopSidebar)).width, 80.0);
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpWidget(buildHarness(const Size(1024, 768)));
      await tester.pumpAndSettle();
      expect(find.byType(DesktopScheduleMatrixView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'supports week navigation, Today view focus, legend filter, search, and standalone SchedulePage on desktop',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 980);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildHarness(const Size(1440, 980)));
      await tester.pumpAndSettle();

      // Week navigation forward & reset
      await tester
          .tap(find.byKey(const ValueKey('desktop_schedule_next_week')));
      await tester.pump();
      expect(find.text('Oct 19 – Oct 25, 2026'), findsOneWidget);
      expect(find.text('Week 9 • Odd Sem'), findsOneWidget);

      await tester
          .tap(find.byKey(const ValueKey('desktop_schedule_today_btn')));
      await tester.pump();
      expect(find.text('Oct 12 – Oct 18, 2026'), findsOneWidget);
      expect(find.text('Week 8 • Odd Sem'), findsOneWidget);

      // View switcher: Today focuses Monday column only
      await tester
          .tap(find.byKey(const ValueKey('desktop_schedule_view_Today')));
      await tester.pump();
      expect(find.text('Mon, Oct 12'), findsOneWidget);
      expect(find.text('Tue, Oct 13'), findsNothing);

      await tester
          .tap(find.byKey(const ValueKey('desktop_schedule_view_Week')));
      await tester.pump();
      expect(find.text('Tue, Oct 13'), findsOneWidget);

      // Legend category toggle
      await tester.tap(find.byKey(const ValueKey('desktop_legend_kelompok')));
      await tester.pump();
      expect(find.text('MEETING IMPAL'), findsOneWidget);
      expect(find.text('SPRINT REVIEW'), findsOneWidget);
      expect(find.text('SYNC LAPORAN'), findsOneWidget);
      expect(find.text('ALPRO & DATA'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('desktop_legend_kelompok')));
      await tester.pump();
      expect(find.text('ALPRO & DATA'), findsOneWidget);

      // Top header search
      await tester.enterText(
        find.byKey(const ValueKey('desktop_search_field')),
        'SPRINT',
      );
      await tester.pump();
      expect(find.text('SPRINT REVIEW'), findsOneWidget);
      expect(find.text('MENTORING'), findsNothing);

      // Standalone SchedulePage on desktop renders DesktopScheduleMatrixView
      await tester.pumpWidget(
        buildHarness(
          const Size(1440, 980),
          child: const SchedulePage(userName: 'Jarvis', isStandalone: true),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DesktopScheduleMatrixView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'supports inline schedule alert toggle, delete confirmation with UNDO, and All directory',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1440, 980);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildHarness(const Size(1440, 980)));
        await tester.pumpAndSettle();

        final alertBtn = find.byKey(
          const ValueKey('desktop_schedule_alert_mtx_alpro_data'),
        );
        expect(alertBtn, findsOneWidget);
        await tester.tap(alertBtn);
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        final deleteBtn = find.byKey(
          const ValueKey('desktop_schedule_delete_mtx_alpro_data'),
        );
        expect(deleteBtn, findsOneWidget);
        await tester.tap(deleteBtn);
        await tester.pumpAndSettle();

        expect(find.text('Delete Schedule?'), findsOneWidget);
        await tester.tap(find.text('Delete'));
        await tester.pump();
        // Wait for PopUpPemberitahuan (2800ms + 280ms transition) to dismiss
        // while the 4s UNDO SnackBar remains active above the barrier.
        await tester.pump(const Duration(milliseconds: 3200));
        await tester.pump();
        expect(find.text('UNDO'), findsOneWidget);

        await tester.tap(find.text('UNDO'));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        expect(find.text('ALPRO & DATA'), findsOneWidget);

        await tester.tap(
          find.byKey(const ValueKey('desktop_schedule_view_All')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Schedule Directory (All)'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DesktopScheduleModal renders mobile-parity wording, top bell alert, and edit mode',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 980);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildHarness(
            const Size(1440, 980),
            child: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  key: const ValueKey('open_desktop_schedule_modal_btn'),
                  onPressed: () => DesktopScheduleModal.show(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const ValueKey('open_desktop_schedule_modal_btn')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Add Schedule'), findsOneWidget);
        expect(find.text('Alert On'), findsOneWidget);
        expect(find.text('Cancel'), findsNothing);
        expect(find.text('Create Schedule'), findsOneWidget);
        expect(find.text('2h Duration (Valid)'), findsOneWidget);

        await tester.tap(
          find.byKey(const ValueKey('desktop_schedule_type_Meeting')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Create Meeting'), findsWidgets);

        await tester.tap(
          find.byKey(const ValueKey('desktop_schedule_modal_close_btn')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Create Meeting'), findsNothing);

        final sample = ScheduleModel(
          id: 'sch_edit_1',
          title: 'UBXCCB2 - Bahasa Indonesia',
          type: 'Lecture',
          course: 'UBXCCB2 - Bahasa Indonesia',
          location: 'Gedung KTT Ruang B-106',
          date: DateTime(2026, 10, 12),
          timeStart: '09:30',
          timeEnd: '11:30',
          repeat: true,
        );
        await tester.pumpWidget(
          buildHarness(
            const Size(1440, 980),
            child: DesktopScheduleModal(schedule: sample),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Edit Schedule'), findsOneWidget);
        expect(find.text('Delete Schedule'), findsOneWidget);
        expect(find.text('Save Changes'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}

