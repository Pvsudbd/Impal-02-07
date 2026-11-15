import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/home_page.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_sidebar.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_top_header.dart';
import 'package:impal_smart_todolist/presentation/features/notifikasi/widgets/notification_bell_button.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/models/schedule_repository.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/schedule_page.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/widgets/desktop/desktop_schedule_control_bar.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/widgets/desktop/desktop_schedule_kpi_row.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/widgets/desktop/desktop_schedule_matrix_card.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/widgets/desktop/desktop_schedule_matrix_table.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/widgets/desktop/desktop_schedule_matrix_view.dart';
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
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('12 Okt – 18 Okt 2026'), findsOneWidget);
      expect(find.text('Minggu 8 • Ganjil'), findsOneWidget);
      expect(find.text('Hari Ini'), findsNWidgets(2));
      expect(find.text('Study / Lab'), findsOneWidget);

      // KPI Summary Row
      expect(find.text('14 Sesi Kuliah'), findsOneWidget);
      expect(find.text('Total Jadwal Minggu Ini'), findsOneWidget);
      expect(find.text('2 Kelas Hari Ini'), findsOneWidget);
      expect(find.text('1 Sedang Berlangsung (Ongoing)'), findsOneWidget);
      expect(find.text('4 Pertemuan Tim'), findsOneWidget);
      expect(find.text('Meeting IMPAL & Study Hub'), findsOneWidget);
      expect(find.text('28 Jam Belajar'), findsOneWidget);
      expect(find.text('Beban 18 SKS Aktif'), findsOneWidget);

      // Matrix Table Headers
      expect(find.text('WAKTU'), findsOneWidget);
      expect(find.text('Senin, 12 Okt'), findsOneWidget);
      expect(find.text('Selasa, 13 Okt'), findsOneWidget);
      expect(find.text('Rabu, 14 Okt'), findsOneWidget);
      expect(find.text('Kamis, 15 Okt'), findsOneWidget);
      expect(find.text('Jumat, 16 Okt'), findsOneWidget);
      expect(find.text('Sabtu, 17 Okt'), findsOneWidget);

      // All 13 FigCraft Schedule Matrix Cards
      expect(find.byType(DesktopScheduleMatrixCard), findsNWidgets(13));
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
      expect(find.text('19 Okt – 25 Okt 2026'), findsOneWidget);
      expect(find.text('Minggu 9 • Ganjil'), findsOneWidget);

      await tester
          .tap(find.byKey(const ValueKey('desktop_schedule_today_btn')));
      await tester.pump();
      expect(find.text('12 Okt – 18 Okt 2026'), findsOneWidget);
      expect(find.text('Minggu 8 • Ganjil'), findsOneWidget);

      // View switcher: Today focuses Senin column only
      await tester
          .tap(find.byKey(const ValueKey('desktop_schedule_view_Today')));
      await tester.pump();
      expect(find.text('Senin, 12 Okt'), findsOneWidget);
      expect(find.text('Selasa, 13 Okt'), findsNothing);

      await tester
          .tap(find.byKey(const ValueKey('desktop_schedule_view_Week')));
      await tester.pump();
      expect(find.text('Selasa, 13 Okt'), findsOneWidget);

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
  });
}

