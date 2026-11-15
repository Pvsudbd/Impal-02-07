import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/home_page.dart';
import 'package:impal_smart_todolist/presentation/features/notifikasi/widgets/notification_bell_button.dart';
import 'package:impal_smart_todolist/presentation/features/team/dashboard_team_page.dart';
import 'package:impal_smart_todolist/presentation/features/team/team_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> pumpAtSize(
    WidgetTester tester,
    Widget child,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: child,
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Desktop Group Directory (List Kelompok) Tests', () {
    testWidgets(
      'renders exact FigCraft Desktop - Group Directory at 1440x980 without overflow',
      (WidgetTester tester) async {
        final errors = <FlutterErrorDetails>[];
        final prevOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          errors.add(details);
          prevOnError?.call(details);
        };
        addTearDown(() => FlutterError.onError = prevOnError);

        await pumpAtSize(
          tester,
          const HomePage(userName: 'Rafiq', initialTab: 2),
          const Size(1440, 980),
        );

        expect(
          errors,
          isEmpty,
          reason: 'Expected 0 layout/overflow errors at 1440x980',
        );

        // Top header exact FigCraft copy and controls
        expect(find.text('Kelompok & Tim Belajar'), findsOneWidget);
        expect(
          find.text(
            'Kelola kelompok mata kuliah, jadwal meeting tim, dan progress kolaborasi',
          ),
          findsOneWidget,
        );
        expect(find.text('Cari kelompok, mata kuliah...'), findsOneWidget);
        expect(find.text('Join Team'), findsOneWidget);
        expect(find.text('+ Create Team'), findsOneWidget);
        expect(find.byType(NotificationBellButton), findsNothing);
        expect(find.text('⌘K'), findsNothing);

        // Sidebar Team Members badge
        expect(find.text('Team Members'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);

        // Left column: Team's Schedule banner
        expect(find.text("Team's Schedule"), findsOneWidget);
        expect(find.text('MEETING IMPAL'), findsOneWidget);
        expect(find.text('Discord • Group IMPAL'), findsOneWidget);
        expect(
          find.text(
            'Tomorrow 19:00 WIB • Agenda: Sprint 1 Review & UI Demo Prototype',
          ),
          findsOneWidget,
        );
        expect(find.text('Join Discord Voice'), findsOneWidget);

        // Left column: My Teams header + filter pills
        expect(find.text('My Teams (4 Aktif)'), findsOneWidget);
        expect(find.text('Semua Tim (4)'), findsOneWidget);
        expect(find.text('Mata Kuliah'), findsWidgets);
        expect(find.text('Projek Mandiri'), findsWidgets);
        expect(find.text('Kompetisi'), findsWidgets);

        // Verify compact horizontal Team's Schedule pill beside MEETING IMPAL
        final meetingRect = tester.getRect(find.text('MEETING IMPAL'));
        final discordTextRect = tester.getRect(
          find.text('Discord • Group IMPAL'),
        );
        expect(
          (discordTextRect.center.dy - meetingRect.center.dy).abs(),
          lessThan(4),
        );
        expect(discordTextRect.left, greaterThan(meetingRect.right));
        expect(discordTextRect.width, lessThan(240));

        // Verify compact horizontal My Teams filter pills (intrinsic widths side-by-side)
        final allFilterRect = tester.getRect(
          find.byKey(const ValueKey('desktop_team_filter_all')),
        );
        final mkFilterRect = tester.getRect(
          find.byKey(const ValueKey('desktop_team_filter_mataKuliah')),
        );
        final pmFilterRect = tester.getRect(
          find.byKey(const ValueKey('desktop_team_filter_projekMandiri')),
        );
        final kompFilterRect = tester.getRect(
          find.byKey(const ValueKey('desktop_team_filter_kompetisi')),
        );
        expect(
          (mkFilterRect.center.dy - allFilterRect.center.dy).abs(),
          lessThan(4),
        );
        expect(
          (pmFilterRect.center.dy - allFilterRect.center.dy).abs(),
          lessThan(4),
        );
        expect(
          (kompFilterRect.center.dy - allFilterRect.center.dy).abs(),
          lessThan(4),
        );
        expect(allFilterRect.right, lessThan(mkFilterRect.left));
        expect(mkFilterRect.right, lessThan(pmFilterRect.left));
        expect(pmFilterRect.right, lessThan(kompFilterRect.left));
        expect(allFilterRect.width, lessThan(200));
        expect(kompFilterRect.width, lessThan(200));

        // 4 team cards + codes + actions
        expect(find.text('Kelompok - IMPAL'), findsOneWidget);
        expect(find.text('Kelompok - IUM'), findsOneWidget);
        expect(find.text('Kelompok - Projek TIK'), findsOneWidget);
        expect(find.text('Kelompok - KA'), findsOneWidget);
        expect(find.text('Code:'), findsNWidgets(4));
        expect(find.text('7X29'), findsOneWidget);
        expect(find.text('3M81'), findsOneWidget);
        expect(find.text('9K20'), findsOneWidget);
        expect(find.text('4A12'), findsOneWidget);
        expect(find.text('Buka Workspace'), findsOneWidget);
        expect(find.text('Lihat Detail'), findsNWidgets(3));

        // Right panel widgets
        expect(find.text('Punya Kode Undangan Tim?'), findsOneWidget);
        expect(find.text('Gabung Kelompok'), findsOneWidget);
        expect(find.text('Tenggat Waktu Kelompok'), findsOneWidget);
        expect(find.text('Sprint 1 Review IMPAL'), findsOneWidget);
        expect(find.text('Laporan IUM Bab 2'), findsOneWidget);
        expect(find.text('Dataset KA Testing'), findsOneWidget);
        expect(find.text('Aktivitas Tim Terkini'), findsOneWidget);
      },
    );

    testWidgets(
      'supports minimized sidebar (80dp) and narrow desktop (1024x768) without overflow',
      (WidgetTester tester) async {
        final errors = <FlutterErrorDetails>[];
        final prevOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          errors.add(details);
          prevOnError?.call(details);
        };
        addTearDown(() => FlutterError.onError = prevOnError);

        await pumpAtSize(
          tester,
          const HomePage(userName: 'Rafiq', initialTab: 2),
          const Size(1440, 980),
        );

        // Collapse sidebar to 80 dp
        await tester.tap(find.byTooltip('Collapse sidebar'));
        await tester.pumpAndSettle();
        expect(find.text('Kelompok & Tim Belajar'), findsOneWidget);

        // Resize to narrow desktop 1024x768
        tester.view.physicalSize = const Size(1024, 768);
        await tester.pumpAndSettle();
        expect(find.text('Kelompok & Tim Belajar'), findsOneWidget);
        expect(
          errors,
          isEmpty,
          reason: 'Expected 0 overflow errors at 80dp sidebar and 1024x768',
        );
      },
    );

    testWidgets(
      'filters by category tabs and header search query',
      (WidgetTester tester) async {
        await pumpAtSize(
          tester,
          const HomePage(userName: 'Rafiq', initialTab: 2),
          const Size(1440, 980),
        );

        // Filter to Projek Mandiri
        await tester.tap(find.text('Projek Mandiri').first);
        await tester.pumpAndSettle();
        expect(find.text('Kelompok - Projek TIK'), findsOneWidget);
        expect(find.text('Kelompok - IMPAL'), findsNothing);
        expect(find.text('Kelompok - KA'), findsNothing);

        // Filter to Kompetisi (empty state + Show All Teams)
        await tester.tap(find.text('Kompetisi').first);
        await tester.pumpAndSettle();
        expect(find.text('No teams match your current filter'), findsOneWidget);
        expect(find.text('Kelompok - Projek TIK'), findsNothing);

        // Back to Semua Tim (4)
        await tester.tap(find.text('Semua Tim (4)'));
        await tester.pumpAndSettle();
        expect(find.text('Kelompok - IMPAL'), findsOneWidget);
        expect(find.text('Kelompok - Projek TIK'), findsOneWidget);

        // Header search
        await tester.enterText(
          find.byType(TextField).first,
          'Usability',
        );
        await tester.pumpAndSettle();
        expect(find.text('Kelompok - IUM'), findsOneWidget);
        expect(find.text('Kelompok - IMPAL'), findsNothing);
      },
    );

    testWidgets(
      'supports Join Team dialog, + Create Team dialog, inline code join, and card navigation',
      (WidgetTester tester) async {
        await pumpAtSize(
          tester,
          const HomePage(userName: 'Rafiq', initialTab: 2),
          const Size(1440, 980),
        );

        // 1. Inline Gabung Kelompok by invite code
        final inlineCodeField = find.byKey(
          const ValueKey('desktop_team_inline_code_input'),
        );
        await tester.enterText(inlineCodeField, '9B4K');
        await tester.tap(
          find.byKey(const ValueKey('desktop_team_inline_join_btn')),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Kelompok 9B4K'), findsOneWidget);
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        // 2. Top header Join Team dialog
        await tester.tap(find.text('Join Team'));
        await tester.pumpAndSettle();
        expect(find.text('Become Member'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Enter Code'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('close_join_team_button')));
        await tester.pumpAndSettle();

        // 3. Top header + Create Team dialog
        await tester.tap(find.text('+ Create Team'));
        await tester.pumpAndSettle();
        expect(find.text('Create Team'), findsNWidgets(2));
        await tester.enterText(
          find.widgetWithText(TextField, 'Enter team name'),
          'RPL Studio',
        );
        await tester.tap(
          find.byKey(const ValueKey('create_team_submit_button')),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Team Created'), findsOneWidget);
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('RPL Studio'), findsOneWidget);

        // 4. Open card workspace -> DashboardTeamPage
        await tester.tap(find.byKey(const ValueKey('desktop_team_open_dir_impal')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(find.byType(DashboardTeamPage), findsOneWidget);
      },
    );

    testWidgets(
      'redirects standalone TeamListPage to desktop Group Directory at 1440x980',
      (WidgetTester tester) async {
        await pumpAtSize(
          tester,
          const TeamListPage(userName: 'Rafiq', isStandalone: true),
          const Size(1440, 980),
        );

        expect(find.text('Kelompok & Tim Belajar'), findsOneWidget);
        expect(find.text('My Teams (4 Aktif)'), findsOneWidget);
      },
    );
  });
}
