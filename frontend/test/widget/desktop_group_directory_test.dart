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
        expect(find.text('Study Teams & Groups'), findsOneWidget);
        expect(
          find.text(
            'Manage course study teams, team meetings, and collaboration progress',
          ),
          findsOneWidget,
        );
        expect(find.text('Search study teams or courses...'), findsOneWidget);
        expect(find.text('Join Team'), findsOneWidget);
        expect(find.text('+ Create Team'), findsOneWidget);
        expect(find.byType(NotificationBellButton), findsOneWidget);
        expect(find.text('⌘K'), findsNothing);

        // Sidebar Team Members badge
        expect(find.text('Team Members'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);

        // Left column: 2-card Team's Schedule row + See all
        expect(find.text("Team's Schedule"), findsOneWidget);
        expect(find.text('See all'), findsOneWidget);
        expect(find.text('IMPAL Project Mentoring'), findsOneWidget);
        expect(find.text('Upcoming'), findsOneWidget);
        expect(
          find.text('Building B Conference Room, 2nd Floor'),
          findsOneWidget,
        );
        expect(find.text('Tomorrow • 10:00 - 11:30 WIB'), findsOneWidget);
        expect(find.text('MEETING IMPAL'), findsOneWidget);
        expect(find.text('Ongoing'), findsOneWidget);
        expect(find.text('Discord - Group IMPAL'), findsOneWidget);
        expect(find.text('Today • 19:00 - 20:30 WIB'), findsOneWidget);
        expect(find.text('Join Call'), findsOneWidget);

        // Left column: My Teams header + filter pills
        expect(find.text('My Teams (4 Active)'), findsOneWidget);
        expect(find.text('All Teams (4)'), findsOneWidget);
        expect(find.text('Courses'), findsOneWidget);
        expect(find.text('Personal Projects'), findsOneWidget);
        expect(find.text('Competitions'), findsOneWidget);

        // Verify side-by-side 2-card Team's Schedule row & compact Join Call pill
        final schCard1Rect = tester.getRect(
          find.byKey(const ValueKey('desktop_team_schedule_card_sch_4')),
        );
        final schCard2Rect = tester.getRect(
          find.byKey(const ValueKey('desktop_team_schedule_card_sch_3')),
        );
        final joinCallRect = tester.getRect(
          find.byKey(const ValueKey('desktop_team_join_discord_btn')),
        );
        expect(
          (schCard1Rect.center.dy - schCard2Rect.center.dy).abs(),
          lessThan(4),
        );
        expect(schCard2Rect.left, greaterThan(schCard1Rect.right));
        expect(joinCallRect.width, lessThan(180));

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
        expect(find.text('Open Workspace'), findsOneWidget);
        expect(find.text('View Details'), findsNWidgets(3));

        // Right panel widgets (inline invite code card removed)
        expect(find.text('Have a Team Invite Code?'), findsNothing);
        expect(find.text('Upcoming Team Deadlines'), findsOneWidget);
        expect(find.text('Sprint 1 Review IMPAL'), findsOneWidget);
        expect(find.text('Laporan IUM Bab 2'), findsOneWidget);
        expect(find.text('Dataset KA Testing'), findsOneWidget);
        expect(find.text('Recent Team Activity'), findsOneWidget);
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
        expect(find.text('Study Teams & Groups'), findsOneWidget);

        // Resize to narrow desktop 1024x768
        tester.view.physicalSize = const Size(1024, 768);
        await tester.pumpAndSettle();
        expect(find.text('Study Teams & Groups'), findsOneWidget);
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

        // Filter to Personal Projects
        await tester.tap(find.text('Personal Projects').first);
        await tester.pumpAndSettle();
        expect(find.text('Kelompok - Projek TIK'), findsOneWidget);
        expect(find.text('Kelompok - IMPAL'), findsNothing);
        expect(find.text('Kelompok - KA'), findsNothing);

        // Filter to Competitions (empty state + Show All Teams)
        await tester.tap(find.text('Competitions').first);
        await tester.pumpAndSettle();
        expect(find.text('No teams match your current filter'), findsOneWidget);
        expect(find.text('Kelompok - Projek TIK'), findsNothing);

        // Back to All Teams (4)
        await tester.tap(find.text('All Teams (4)'));
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

        // 1. Join Team dialog via top header button + dynamic Team Not Found / Team Found
        await tester.tap(find.text('Join Team').first);
        await tester.pumpAndSettle();
        expect(find.text('Join Team'), findsWidgets);
        expect(find.text('Join Workspace Now'), findsOneWidget);
        expect(find.text('TEAM FOUND'), findsNothing);
        expect(find.text('TEAM NOT FOUND'), findsNothing);
        expect(find.text('Cancel'), findsNothing);
        final codeField = find.byKey(const ValueKey('join_team_code_input'));
        expect(codeField, findsOneWidget);
        await tester.enterText(codeField, '0000');
        await tester.pumpAndSettle();
        expect(find.text('TEAM NOT FOUND'), findsOneWidget);
        await tester.enterText(codeField, '7X29');
        await tester.pumpAndSettle();
        expect(find.text('TEAM FOUND'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('join_team_submit_button')));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Team Joined'), findsOneWidget);
        await tester.pump(const Duration(seconds: 3));
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

        expect(find.text('Study Teams & Groups'), findsOneWidget);
        expect(find.text('My Teams (4 Active)'), findsOneWidget);
      },
    );

    testWidgets(
      'supports live Team Schedule controls and 2-column Desktop Group Workspace on DashboardTeamPage',
      (WidgetTester tester) async {
        await pumpAtSize(
          tester,
          const HomePage(userName: 'Rafiq', initialTab: 2),
          const Size(1440, 980),
        );

        expect(
          find.byKey(const ValueKey('desktop_team_schedule_see_all_btn')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('desktop_team_edit_meeting_btn')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('desktop_team_delete_meeting_btn')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('desktop_team_join_discord_btn')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey('desktop_team_open_dir_impal')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        expect(find.byType(DashboardTeamPage), findsOneWidget);
        expect(
          find.byKey(const ValueKey('desktop_workspace_members_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('desktop_workspace_sprint_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('desktop_workspace_resources_card')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Desktop Group Workspace (Kelompok IMPAL) Tests', () {
    testWidgets(
      'renders exact FigCraft Desktop - Group Workspace (Kelompok IMPAL) at 1440x980 & 1024x768 without overflow',
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

        await tester.tap(
          find.byKey(const ValueKey('desktop_team_open_dir_impal')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        expect(
          errors,
          isEmpty,
          reason: 'Expected 0 overflow/layout errors at 1440x980',
        );
        expect(find.byType(DashboardTeamPage), findsOneWidget);

        // Top Header: Breadcrumb + Subtitle + Search + Notification Bell + Voice Active Badge
        expect(
          find.byKey(const ValueKey('desktop_header_breadcrumb_parent')),
          findsOneWidget,
        );
        expect(find.text('Kelompok - IMPAL'), findsAtLeastNWidgets(1));
        expect(
          find.text('Implementasi & Pengujian Perangkat Lunak • SIF-45-02'),
          findsOneWidget,
        );
        expect(find.text('Search tasks in workspace...'), findsOneWidget);
        expect(find.byType(NotificationBellButton), findsOneWidget);
        expect(find.text('Voice Active (3 Online)'), findsOneWidget);

        // Left Column: Group Hero Workspace + Meeting Card + Team Tasks
        expect(
          find.byKey(const ValueKey('desktop_workspace_hero_card')),
          findsOneWidget,
        );
        expect(find.text('Kelompok IMPAL'), findsOneWidget);
        expect(find.text('SIF-45'), findsOneWidget);
        expect(find.text('Code:'), findsOneWidget);
        expect(find.text('7X29'), findsOneWidget);
        expect(find.text('+ Create Meeting'), findsNWidgets(2));
        expect(find.text('+ Create Task'), findsOneWidget);
        expect(find.text('5 Team Members'), findsOneWidget);

        // Hero top-row pills & buttons must hug their content width and stay on one row
        final sifRect = tester.getRect(
          find
              .ancestor(
                of: find.text('SIF-45'),
                matching: find.byType(Container),
              )
              .first,
        );
        final createMeetingRect = tester.getRect(
          find.byKey(const ValueKey('dashboard_create_meeting_button')),
        );
        final createTaskRect = tester.getRect(
          find.byKey(const ValueKey('dashboard_create_task_button')),
        );
        expect(sifRect.width, lessThan(80));
        expect(createMeetingRect.width, lessThan(260));
        expect(createTaskRect.width, lessThan(240));
        expect(createMeetingRect.right, lessThan(createTaskRect.left));
        expect(
          (sifRect.center.dy - createTaskRect.center.dy).abs(),
          lessThan(10),
        );

        expect(
          find.byKey(const ValueKey('desktop_workspace_meeting_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(
            const ValueKey('desktop_workspace_section_create_meeting_btn'),
          ),
          findsOneWidget,
        );
        expect(find.text("Team's Schedule"), findsOneWidget);
        expect(find.text('IMPAL Project Mentoring'), findsOneWidget);
        expect(find.text('MEETING IMPAL'), findsOneWidget);
        expect(find.text('Discord - Group IMPAL'), findsOneWidget);
        expect(find.text('Join Call'), findsOneWidget);

        final wsSchCard1Rect = tester.getRect(
          find.byKey(const ValueKey('desktop_team_schedule_card_sch_4')),
        );
        final wsSchCard2Rect = tester.getRect(
          find.byKey(const ValueKey('desktop_team_schedule_card_sch_3')),
        );
        final joinMeetingBtnRect = tester.getRect(
          find.byKey(const ValueKey('desktop_workspace_join_meeting_btn')),
        );
        expect(
          (wsSchCard1Rect.center.dy - wsSchCard2Rect.center.dy).abs(),
          lessThan(4),
        );
        expect(wsSchCard2Rect.left, greaterThan(wsSchCard1Rect.right));
        expect(joinMeetingBtnRect.width, lessThan(180));

        expect(find.text('Milestones'), findsNothing);
        expect(find.textContaining('Team Tasks ('), findsOneWidget);
        expect(find.textContaining('All ('), findsOneWidget);
        expect(find.textContaining('High ('), findsOneWidget);
        expect(find.textContaining('Medium ('), findsOneWidget);
        expect(find.textContaining('Low ('), findsOneWidget);
        expect(find.text('Assigned to Me'), findsNothing);

        final tasksHeaderRect = tester.getRect(
          find.textContaining('Team Tasks ('),
        );
        final filterAllRect = tester.getRect(
          find.byKey(const ValueKey('desktop_workspace_filter_all')),
        );
        expect(
          (tasksHeaderRect.center.dy - filterAllRect.center.dy).abs(),
          lessThan(8),
        );

        // 2-column grid at 1440x980: first two task cards align on same horizontal row
        final card1Rect = tester.getRect(
          find.byKey(const ValueKey('desktop_team_task_task_1')),
        );
        final card2Rect = tester.getRect(
          find.byKey(const ValueKey('desktop_team_task_task_2')),
        );
        expect((card1Rect.top - card2Rect.top).abs(), lessThan(4));
        expect(card1Rect.right, lessThan(card2Rect.left));

        // Right Column: Members + Sprint 1 Progress + Resources
        expect(find.text('Team Members (5)'), findsOneWidget);
        expect(find.text('Jarvis S.'), findsOneWidget);
        expect(find.text('Ahmad Sahroni'), findsOneWidget);
        expect(find.text('QA & Software Tester'), findsOneWidget);
        expect(find.text('Sprint 1 Progress'), findsOneWidget);
        expect(find.text('6 of 8 Tasks Completed'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('desktop_workspace_sprint_card')),
            matching: find.text('75%'),
          ),
          findsOneWidget,
        );
        expect(find.text('Next Milestone Target:'), findsOneWidget);
        expect(
          find.text('Testing & Code Freeze (Tomorrow, 18:00 WIB)'),
          findsOneWidget,
        );
        expect(find.text('Team Resources & Documents'), findsOneWidget);
        expect(find.text('GitHub Repository'), findsOneWidget);
        expect(find.text('Figma Spec Design'), findsOneWidget);
        expect(find.text('Discord Voice & Chat'), findsOneWidget);

        // Priority filter works cleanly
        await tester.tap(
          find.byKey(const ValueKey('desktop_workspace_filter_high')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Create team UI page'), findsOneWidget);
        expect(find.text('Create home UI page'), findsNothing);
        await tester.tap(
          find.byKey(const ValueKey('desktop_workspace_filter_all')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Create home UI page'), findsOneWidget);

        // Narrow desktop 1024x768 check with 0 overflow
        tester.view.physicalSize = const Size(1024, 768);
        await tester.pumpAndSettle();
        expect(
          errors,
          isEmpty,
          reason: 'Expected 0 overflow errors at 1024x768',
        );

        // Reset to 1440x980 & test centered desktop Team Members modal
        tester.view.physicalSize = const Size(1440, 980);
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('desktop_workspace_manage_members_btn')),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('desktop_team_members_dialog')),
          findsOneWidget,
        );
        expect(find.text('Team Members (5)'), findsNWidgets(2));
        await tester.tap(
          find.byKey(const ValueKey('desktop_team_members_close_btn')),
        );
        await tester.pumpAndSettle();

        // Click 'Team Members' breadcrumb to return to Group Directory
        await tester.tap(
          find.byKey(const ValueKey('desktop_header_breadcrumb_parent')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Study Teams & Groups'), findsOneWidget);
      },
    );

    testWidgets(
      'renders full desktop workspace shell when DashboardTeamPage isStandalone is true',
      (WidgetTester tester) async {
        await pumpAtSize(
          tester,
          const DashboardTeamPage(
            userName: 'Jarvis',
            teamName: 'Kelompok IMPAL',
            teamCode: '7X29',
            isStandalone: true,
          ),
          const Size(1440, 980),
        );

        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Categories'), findsNothing);
        expect(
          find.byKey(const ValueKey('desktop_workspace_hero_card')),
          findsOneWidget,
        );
        expect(find.text('Voice Active (3 Online)'), findsOneWidget);
        expect(find.text('Sprint 1 Progress'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'opens DesktopTeamTaskModal from + Create Task and task card edit on desktop',
      (WidgetTester tester) async {
        await pumpAtSize(
          tester,
          const DashboardTeamPage(
            userName: 'Jarvis',
            teamName: 'Kelompok IMPAL',
            teamCode: '7X29',
            isStandalone: true,
          ),
          const Size(1440, 980),
        );

        // Open Create Team Task Modal
        await tester.tap(
          find.byKey(const ValueKey('dashboard_create_task_button')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Create Team Task'), findsOneWidget);
        expect(find.text('Team Task Details'), findsNothing);
        expect(find.text('Task Name'), findsOneWidget);
        expect(find.text('Description'), findsOneWidget);
        expect(find.text('Submission Deadline'), findsOneWidget);
        expect(find.text('Task Grade Weight'), findsNothing);
        expect(find.text('Course Grade Weight'), findsNothing);
        expect(find.text('Assign To'), findsOneWidget);
        expect(find.text('Milestone (Optional)'), findsOneWidget);
        expect(find.text('Alert On'), findsOneWidget);
        expect(find.text('Cancel'), findsNothing);

        // Select second team member & enter task name & submit
        await tester.tap(
          find.byKey(const ValueKey('desktop_team_task_member_member_2')),
        );
        await tester.enterText(
          find.byKey(const ValueKey('desktop_team_task_name_input')),
          'FigCraft Team Modal QA',
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const ValueKey('desktop_team_task_submit_btn')),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('FigCraft Team Modal QA'), findsOneWidget);

        // Open Edit Mode from existing task card edit button
        await tester.tap(
          find.byKey(const ValueKey('desktop_team_task_edit_task_1')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Edit Team Task'), findsOneWidget);
        expect(find.text('Delete Task'), findsOneWidget);
        expect(find.text('Save Changes'), findsOneWidget);

        await tester.tap(
          find.byKey(const ValueKey('desktop_team_task_modal_close_btn')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Edit Team Task'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'opens DesktopTeamMeetingModal from + Create Meeting on desktop without Cancel',
      (WidgetTester tester) async {
        await pumpAtSize(
          tester,
          const DashboardTeamPage(
            userName: 'Jarvis',
            teamName: 'Kelompok IMPAL',
            teamCode: '7X29',
            isStandalone: true,
          ),
          const Size(1440, 980),
        );

        await tester.tap(
          find.byKey(const ValueKey('dashboard_create_meeting_button')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);
        expect(find.text('Create Meeting'), findsWidgets);
        expect(find.text('Meeting Details'), findsNothing);
        expect(find.text('Meeting Name'), findsOneWidget);
        expect(find.text('Team Meeting'), findsNothing);
        expect(find.text('Location'), findsOneWidget);
        expect(find.text('Date & Time'), findsOneWidget);
        expect(find.text('Start Time'), findsOneWidget);
        expect(find.text('End Time (Estimated)'), findsOneWidget);
        expect(find.text('Repeat Weekly'), findsOneWidget);
        expect(find.text('Meeting Link / URL (Optional)'), findsOneWidget);
        expect(find.text('Description (Optional)'), findsOneWidget);
        final desktopDescFieldTop = tester
            .getTopLeft(find.byKey(const ValueKey('create_meeting_desc_input')))
            .dy;
        final desktopDescIconTop =
            tester.getTopLeft(find.byIcon(Icons.notes_rounded)).dy;
        expect((desktopDescIconTop - desktopDescFieldTop).abs(), lessThan(18));
        expect(find.text('Alert On'), findsOneWidget);
        expect(find.text('Cancel'), findsNothing);

        await tester.tap(
          find.byKey(const ValueKey('close_create_meeting_button')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        expect(tester.takeException(), isNull);

        // Mobile DashboardTeamPage also hides Team Meeting checkbox
        await pumpAtSize(
          tester,
          const DashboardTeamPage(
            userName: 'Jarvis',
            teamName: 'Kelompok IMPAL',
            teamCode: '7X29',
            isStandalone: true,
          ),
          const Size(390, 844),
        );
        await tester.tap(
          find.byKey(const ValueKey('dashboard_create_meeting_button')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Meeting Name'), findsOneWidget);
        expect(find.text('Team Meeting'), findsNothing);
        final mobileDescFieldTop = tester
            .getTopLeft(find.byKey(const ValueKey('create_meeting_desc_input')))
            .dy;
        final mobileDescIconTop =
            tester.getTopLeft(find.byIcon(Icons.notes_rounded)).dy;
        expect((mobileDescIconTop - mobileDescFieldTop).abs(), lessThan(18));
        expect(tester.takeException(), isNull);
      },
    );
  });
}
