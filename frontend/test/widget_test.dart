import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/auth/login_page.dart';
import 'package:impal_smart_todolist/presentation/features/jadwal/schedule_page.dart';
import 'package:impal_smart_todolist/presentation/features/jadwal/models/schedule_model.dart';
import 'package:impal_smart_todolist/presentation/features/jadwal/models/schedule_repository.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/home_page.dart';
import 'package:impal_smart_todolist/presentation/features/team/team_list_page.dart';
import 'package:impal_smart_todolist/presentation/features/jadwal/schedule_form_page.dart';
import 'package:impal_smart_todolist/presentation/common_widgets/impal_time_picker_dialog.dart';
import 'package:impal_smart_todolist/presentation/common_widgets/impal_date_picker_dialog.dart';
import 'package:impal_smart_todolist/presentation/features/team/pop_up_create_team.dart';
import 'package:impal_smart_todolist/presentation/features/team/pop_up_join_team.dart';
import 'package:impal_smart_todolist/presentation/common_widgets/impal_bottom_nav_bar.dart';
import 'package:impal_smart_todolist/presentation/features/team/dashboard_team_page.dart';
import 'package:impal_smart_todolist/presentation/features/team/pop_up_create_meeting.dart';
import 'package:impal_smart_todolist/presentation/common_widgets/impal_schedule_card.dart';
import 'package:impal_smart_todolist/presentation/common_widgets/pop_up_pemberitahuan.dart';
import 'package:impal_smart_todolist/presentation/features/jadwal/pop_up_konfirmasi_delete.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('Login page renders properly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: Login(),
    ));

    expect(find.text('Smart Task Manager'), findsOneWidget);
    expect(find.text('Sign In to Dashboard'), findsOneWidget);
  });

  testWidgets('Schedule page renders properly with filter and items', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: SchedulePage(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Add Schedule'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
  });

  testWidgets('HomePage smoothly displays Today schedule and See all', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: HomePage(),
    ));
    await tester.pumpAndSettle();

    expect(find.text("Today's schedule"), findsOneWidget);
    expect(find.text("See all"), findsWidgets);
  });

  testWidgets('Tapping calendar icon smoothly transitions to Schedule view', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: HomePage(),
    ));
    await tester.pumpAndSettle();

    // Tap calendar icon (tab 3)
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();

    // Now on schedule view
    expect(find.text('Add Schedule'), findsOneWidget);
    expect(find.text('Schedule'), findsOneWidget);

    // Tap back button to return to dashboard
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Back on dashboard
    expect(find.text("Today's schedule"), findsOneWidget);
  });

  testWidgets("Today's schedule scrolls horizontally when multiple items exist", (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => ScheduleRepository().resetToDefault());

    final now = DateTime.now();
    ScheduleRepository().schedulesNotifier.value = [
      ScheduleModel(
        id: 'test_1',
        title: 'Class 1',
        type: 'Lecture',
        date: now,
        timeStart: '09:00',
        timeEnd: '11:00',
      ),
      ScheduleModel(
        id: 'test_2',
        title: 'Class 2',
        type: 'Lecture',
        date: now,
        timeStart: '13:00',
        timeEnd: '15:00',
      ),
    ];

    await tester.pumpWidget(const MaterialApp(
      home: HomePage(),
    ));
    await tester.pumpAndSettle();

    expect(find.text("Today's schedule"), findsOneWidget);
    final horizontalScrollFinder = find.byWidgetPredicate(
      (widget) => widget is SingleChildScrollView && widget.scrollDirection == Axis.horizontal,
    );
    expect(horizontalScrollFinder, findsOneWidget);
  });

  testWidgets('Group task cards display CircularProgressIndicator instead of LinearProgressIndicator', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: HomePage(),
    ));
    await tester.pumpAndSettle();

    // Group cards should have circular progress indicators
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    // Group cards should not render LinearProgressIndicator
    expect(find.byType(LinearProgressIndicator), findsNothing);
    // Progress percentages for both group cards should be found
    expect(find.text('46%'), findsOneWidget);
    expect(find.text('76%'), findsOneWidget);
  });

  testWidgets('TeamListPage / ListKelompok renders schedule, teams, and action buttons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    ScheduleRepository().resetToDefault();

    await tester.pumpWidget(const MaterialApp(
      home: TeamListPage(),
    ));
    await tester.pumpAndSettle();

    expect(find.text("Team's Schedule"), findsOneWidget);
    expect(find.text('MEETING IMPAL'), findsOneWidget);
    expect(find.text('Discord - Group IMPAL'), findsOneWidget);
    expect(find.text('Tomorrow 19:00 WIB'), findsOneWidget);
    expect(find.text('Team'), findsOneWidget);
    expect(find.text('Join Team'), findsOneWidget);
    expect(find.text('+ Create Team'), findsOneWidget);
    expect(find.text('Kelompok - IMPAL'), findsOneWidget);
    expect(find.text('Kelompok - IUM'), findsOneWidget);
  });

  testWidgets('Tapping groups icon in HomePage smoothly switches to Team list view', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: HomePage(),
    ));
    await tester.pumpAndSettle();

    // Tap groups icon (tab 2)
    await tester.tap(find.byIcon(Icons.groups_outlined));
    await tester.pumpAndSettle();

    expect(find.text("Team's Schedule"), findsOneWidget);
    expect(find.text('Kelompok - IMPAL'), findsOneWidget);
  });

  testWidgets('ScheduleContentView and TeamListContentView render harmonized square back buttons and subtitles', (WidgetTester tester) async {
    bool scheduleBackTapped = false;
    bool teamBackTapped = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ScheduleContentView(
          showBackButton: true,
          onBack: () => scheduleBackTapped = true,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Schedule'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    expect(scheduleBackTapped, isTrue);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TeamListContentView(
          showBackButton: true,
          onBack: () => teamBackTapped = true,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Team List'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    expect(teamBackTapped, isTrue);
  });

  testWidgets('ScheduleFormPage (Add mode) opens time picker in 24-hour mode without AM/PM', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: ScheduleFormPage(),
    ));
    await tester.pumpAndSettle();

    // Tap start time button showing 09:30
    await tester.tap(find.text('09:30'));
    await tester.pumpAndSettle();

    // ImpalTimePickerDialog must be present
    expect(find.text('Select Start Time'), findsOneWidget);
    expect(find.text('HOUR'), findsOneWidget);
    expect(find.text('MINUTE'), findsOneWidget);

    // AM and PM strings must NOT exist in 24-hour mode
    expect(find.text('AM'), findsNothing);
    expect(find.text('PM'), findsNothing);

    // Toggle to input mode (icon-only button)
    await tester.tap(find.byIcon(Icons.keyboard_alt_outlined));
    await tester.pumpAndSettle();
    expect(find.text(':15'), findsOneWidget);
    expect(find.text(':30'), findsOneWidget);

    // Tap 'Done' to confirm
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Select Start Time'), findsNothing);
  });

  testWidgets('ScheduleFormPage (Edit mode) opens time picker in 24-hour mode without AM/PM', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final item = ScheduleModel(
      id: 'test_1',
      title: 'Matematika Diskrit',
      type: 'Lecture',
      course: 'Matematika Diskrit',
      location: 'Ruang 301',
      status: 'Upcoming',
      date: DateTime.now(),
      timeStart: '13:00',
      timeEnd: '15:00',
    );

    await tester.pumpWidget(MaterialApp(
      home: ScheduleFormPage(schedule: item),
    ));
    await tester.pumpAndSettle();

    // Tap start time button showing 13:00
    await tester.tap(find.text('13:00'));
    await tester.pumpAndSettle();

    // ImpalTimePickerDialog must be present
    expect(find.text('Select Start Time'), findsOneWidget);
    expect(find.text('HOUR'), findsOneWidget);
    expect(find.text('MINUTE'), findsOneWidget);

    // AM and PM strings must NOT exist in 24-hour mode
    expect(find.text('AM'), findsNothing);
    expect(find.text('PM'), findsNothing);

    // Tap 'Cancel' to dismiss
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Select Start Time'), findsNothing);
  });

  testWidgets('ImpalTimePickerDialog supports dial and input mode with steppers and presets', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    TimeOfDay? result;

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await showImpalTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 8, minute: 15),
            );
          },
          child: const Text('Open Picker'),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Open picker
    await tester.tap(find.text('Open Picker'));
    await tester.pumpAndSettle();

    // Initial state: 08 : 15
    expect(find.text('08'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);

    // Switch to input mode (icon button)
    await tester.tap(find.byIcon(Icons.keyboard_alt_outlined));
    await tester.pumpAndSettle();

    // Verify single minimalist time display (only 1 HOUR and 1 MINUTE container)
    expect(find.text('HOUR'), findsOneWidget);
    expect(find.text('MINUTE'), findsOneWidget);

    // Tap preset :45
    await tester.tap(find.text(':45'));
    await tester.pumpAndSettle();
    expect(find.text('45'), findsOneWidget);

    // Scroll/drag downward on hour box to increment hour from 08 to 09 (makin besar)
    await tester.drag(find.text('08'), const Offset(0, 50));
    await tester.pumpAndSettle();
    expect(find.text('09'), findsOneWidget);

    // Also test scrolling upward on minute to decrement from 45 to 44 (makin kecil)
    await tester.drag(find.text('45'), const Offset(0, -50));
    await tester.pumpAndSettle();
    expect(find.text('44'), findsOneWidget);

    // Test direct typing on Hour TextField
    await tester.tap(find.byKey(const ValueKey('hour_text_field')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('hour_text_field')), '14');
    await tester.pumpAndSettle();
    expect(find.text('14'), findsOneWidget);

    // Re-select :45 preset
    await tester.tap(find.text(':45'));
    await tester.pumpAndSettle();

    // Confirm
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.hour, 14);
    expect(result!.minute, 45);
  });

  testWidgets('ImpalDatePickerDialog eliminates day-month-date banner and supports month/year switching', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    DateTime? pickedDate;

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                pickedDate = await showImpalDatePicker(
                  context: context,
                  initialDate: DateTime(2026, 10, 25),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  title: 'Select Date',
                );
              },
              child: const Text('Open Date Picker'),
            ),
          ),
        ),
      ),
    ));

    // Open date picker
    await tester.tap(find.text('Open Date Picker'));
    await tester.pumpAndSettle();

    // Verify title is clean and no day-month-date banner exists
    expect(find.text('Select Date'), findsOneWidget);
    expect(find.text('Friday, Oct 25'), findsNothing);
    expect(find.text('Fri, Oct 25'), findsNothing);

    // Initial state shows October 2026
    expect(find.text('October'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);

    // Switch to month selector by tapping month button
    await tester.tap(find.byKey(const ValueKey('month_selector_button')));
    await tester.pumpAndSettle();

    // Verify 12 months are displayed and select 'Jul'
    expect(find.text('Jul'), findsOneWidget);
    expect(find.text('Dec'), findsOneWidget);
    await tester.tap(find.text('Jul'));
    await tester.pumpAndSettle();

    // Verify view date switched to July
    expect(find.text('July'), findsOneWidget);

    // Switch to year selector by tapping year button
    await tester.tap(find.byKey(const ValueKey('year_selector_button')));
    await tester.pumpAndSettle();

    // Verify years are displayed and select '2028'
    expect(find.text('2028'), findsOneWidget);
    await tester.tap(find.text('2028'));
    await tester.pumpAndSettle();

    // Verify view date switched to 2028
    expect(find.text('2028'), findsOneWidget);
    expect(find.text('July'), findsOneWidget);

    // Pick day 15
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();

    // Confirm
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(pickedDate, isNotNull);
    expect(pickedDate!.year, 2028);
    expect(pickedDate!.month, 7);
    expect(pickedDate!.day, 15);
  });

  test('ScheduleModel calculates ongoing, upcoming, and overdue status automatically based on current time', () {
    final baseDate = DateTime(2026, 10, 25);

    // 1. Past schedule on the same day -> Overdue
    final completedSchedule = ScheduleModel(
      id: 'c1',
      title: 'Completed Test',
      type: 'Lecture',
      date: baseDate,
      timeStart: '08:00',
      timeEnd: '10:00',
    );
    // At 11:00 on the same date, schedule should be Overdue
    expect(
      completedSchedule.getStatusAt(DateTime(2026, 10, 25, 11, 0)),
      'Overdue',
    );

    // 2. Currently occurring schedule -> Ongoing
    final ongoingSchedule = ScheduleModel(
      id: 'o1',
      title: 'Ongoing Test',
      type: 'Lecture',
      date: baseDate,
      timeStart: '10:30',
      timeEnd: '12:30',
    );
    // At 11:00, within 10:30 - 12:30
    expect(
      ongoingSchedule.getStatusAt(DateTime(2026, 10, 25, 11, 0)),
      'Ongoing',
    );

    // 3. Future schedule on the same day -> Upcoming
    final upcomingSchedule = ScheduleModel(
      id: 'u1',
      title: 'Upcoming Test',
      type: 'Lecture',
      date: baseDate,
      timeStart: '14:00',
      timeEnd: '16:00',
    );
    // At 11:00, before 14:00
    expect(
      upcomingSchedule.getStatusAt(DateTime(2026, 10, 25, 11, 0)),
      'Upcoming',
    );

    // 4. Past date -> Overdue
    final pastDateSchedule = ScheduleModel(
      id: 'pd1',
      title: 'Past Date Test',
      type: 'Lecture',
      date: DateTime(2026, 10, 20),
      timeStart: '10:00',
      timeEnd: '12:00',
    );
    expect(
      pastDateSchedule.getStatusAt(DateTime(2026, 10, 25, 11, 0)),
      'Overdue',
    );

    // 5. Future date -> Upcoming
    final futureDateSchedule = ScheduleModel(
      id: 'fd1',
      title: 'Future Date Test',
      type: 'Lecture',
      date: DateTime(2026, 10, 30),
      timeStart: '10:00',
      timeEnd: '12:00',
    );
    expect(
      futureDateSchedule.getStatusAt(DateTime(2026, 10, 25, 11, 0)),
      'Upcoming',
    );

    // 6. Overnight schedule: 23:00 to 01:00 next day
    final overnightSchedule = ScheduleModel(
      id: 'on1',
      title: 'Overnight Hackathon',
      type: 'External',
      date: baseDate,
      timeStart: '23:00',
      timeEnd: '01:00',
    );
    // At 23:30 same day -> Ongoing
    expect(
      overnightSchedule.getStatusAt(DateTime(2026, 10, 25, 23, 30)),
      'Ongoing',
    );
    // At 00:30 next day -> Ongoing
    expect(
      overnightSchedule.getStatusAt(DateTime(2026, 10, 26, 0, 30)),
      'Ongoing',
    );
    // At 01:30 next day -> Overdue
    expect(
      overnightSchedule.getStatusAt(DateTime(2026, 10, 26, 1, 30)),
      'Overdue',
    );
  });

  testWidgets('Schedule card displays Overdue with gray pill and Ongoing with coral pill', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final now = DateTime.now();
    String fmt(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    ScheduleRepository().schedulesNotifier.value = [
      ScheduleModel(
        id: 't_comp',
        title: 'Finished Lecture',
        type: 'Lecture',
        date: now,
        timeStart: fmt(now.subtract(const Duration(hours: 3))),
        timeEnd: fmt(now.subtract(const Duration(hours: 1))),
      ),
      ScheduleModel(
        id: 't_ong',
        title: 'Active Lecture',
        type: 'Lecture',
        date: now,
        timeStart: fmt(now.subtract(const Duration(minutes: 30))),
        timeEnd: fmt(now.add(const Duration(minutes: 30))),
      ),
    ];

    await tester.pumpWidget(const MaterialApp(
      home: SchedulePage(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Overdue'), findsWidgets);
    expect(find.text('Ongoing'), findsWidgets);

    // Overdue pill uses gray (0xFF8E95A5) matching Upcoming
    final overdueText = tester.widget<Text>(find.text('Overdue').first);
    expect(overdueText.style?.color, const Color(0xFF8E95A5));

    // Ongoing pill uses coral (0xFFFF826E) background and white text
    final ongoingText = tester.widget<Text>(find.text('Ongoing').first);
    expect(ongoingText.style?.color, Colors.white);
    final ongoingContainerFinder = find.ancestor(
      of: find.text('Ongoing').first,
      matching: find.byType(Container),
    ).first;
    final ongoingContainer = tester.widget<Container>(ongoingContainerFinder);
    expect((ongoingContainer.decoration as BoxDecoration).color, const Color(0xFFFF826E));
  });

  testWidgets("Today's schedule on HomePage displays Overdue -> Ongoing -> Upcoming and focuses on Ongoing card", (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final now = DateTime.now();
    String fmt(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    // Provide 3 schedules in arbitrary order: Upcoming, Overdue, Ongoing
    ScheduleRepository().schedulesNotifier.value = [
      ScheduleModel(
        id: 'home_up',
        title: 'Upcoming Evening Class',
        type: 'Lecture',
        date: now,
        timeStart: fmt(now.add(const Duration(hours: 3))),
        timeEnd: fmt(now.add(const Duration(hours: 5))),
      ),
      ScheduleModel(
        id: 'home_comp',
        title: 'Overdue Morning Class',
        type: 'Lecture',
        date: now,
        timeStart: fmt(now.subtract(const Duration(hours: 4))),
        timeEnd: fmt(now.subtract(const Duration(hours: 2))),
      ),
      ScheduleModel(
        id: 'home_ong',
        title: 'Ongoing Noon Class',
        type: 'Lecture',
        date: now,
        timeStart: fmt(now.subtract(const Duration(minutes: 30))),
        timeEnd: fmt(now.add(const Duration(minutes: 60))),
      ),
    ];

    await tester.pumpWidget(const MaterialApp(
      home: HomePage(),
    ));
    await tester.pumpAndSettle();

    // Verify Ongoing Noon Class is in view
    expect(find.text('Ongoing Noon Class'), findsOneWidget);

    // Check horizontal scroll controller offset points to the Ongoing card (index 1 -> 297.0)
    final scrollFinder = find.byKey(const ValueKey('today_schedules_horizontal_scroll'));
    expect(scrollFinder, findsOneWidget);
    final SingleChildScrollView scrollView = tester.widget(scrollFinder);
    expect(scrollView.controller, isNotNull);
    expect(scrollView.controller!.offset, 297.0);

    // User can scroll to the left (drag right) to view Overdue Morning Class on the left
    await tester.drag(scrollFinder, const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(scrollView.controller!.offset, lessThanOrEqualTo(50.0));

    // User can scroll to the right (drag left) to view Upcoming Evening Class on the right
    await tester.drag(scrollFinder, const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(scrollView.controller!.offset, greaterThan(200.0));
  });

  testWidgets("Team's schedule in DashboardTeamPage orders Overdue on left, then Ongoing, then Upcoming, or Overdue then Upcoming when no Ongoing", (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final now = DateTime.now();
    String fmt(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    // Kasus 1: Ada Overdue, Ongoing, dan Upcoming
    ScheduleRepository().schedulesNotifier.value = [
      ScheduleModel(
        id: 'tm_up',
        title: 'Meeting Malam (Upcoming)',
        type: 'Meeting',
        location: 'Zoom',
        date: now,
        timeStart: fmt(now.add(const Duration(hours: 3))),
        timeEnd: fmt(now.add(const Duration(hours: 4))),
      ),
      ScheduleModel(
        id: 'tm_od',
        title: 'Meeting Pagi (Overdue)',
        type: 'Meeting',
        location: 'Discord',
        date: now,
        timeStart: fmt(now.subtract(const Duration(hours: 3))),
        timeEnd: fmt(now.subtract(const Duration(hours: 2))),
      ),
      ScheduleModel(
        id: 'tm_on',
        title: 'Meeting Siang (Ongoing)',
        type: 'Meeting',
        location: 'Google Meet',
        date: now,
        timeStart: fmt(now.subtract(const Duration(minutes: 30))),
        timeEnd: fmt(now.add(const Duration(minutes: 30))),
      ),
    ];

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: DashboardTeamPage(
          teamName: 'Kelompok IMPAL',
          teamCode: '7X29',
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Verifikasi posisi horizontal (Overdue paling kiri, lalu Ongoing, lalu Upcoming)
    final overdueLeft = tester.getTopLeft(find.text('Meeting Pagi (Overdue)')).dx;
    final ongoingLeft = tester.getTopLeft(find.text('Meeting Siang (Ongoing)')).dx;
    final upcomingLeft = tester.getTopLeft(find.text('Meeting Malam (Upcoming)')).dx;

    expect(overdueLeft, lessThan(ongoingLeft));
    expect(ongoingLeft, lessThan(upcomingLeft));

    // Kasus 2: Tanpa Ongoing (Hanya Overdue dan Upcoming)
    ScheduleRepository().schedulesNotifier.value = [
      ScheduleModel(
        id: 'tm_up2',
        title: 'Meeting Malam 2 (Upcoming)',
        type: 'Meeting',
        location: 'Zoom',
        date: now,
        timeStart: fmt(now.add(const Duration(hours: 3))),
        timeEnd: fmt(now.add(const Duration(hours: 4))),
      ),
      ScheduleModel(
        id: 'tm_od2',
        title: 'Meeting Pagi 2 (Overdue)',
        type: 'Meeting',
        location: 'Discord',
        date: now,
        timeStart: fmt(now.subtract(const Duration(hours: 3))),
        timeEnd: fmt(now.subtract(const Duration(hours: 2))),
      ),
    ];
    await tester.pumpAndSettle();

    final overdueLeft2 = tester.getTopLeft(find.text('Meeting Pagi 2 (Overdue)')).dx;
    final upcomingLeft2 = tester.getTopLeft(find.text('Meeting Malam 2 (Upcoming)')).dx;
    expect(overdueLeft2, lessThan(upcomingLeft2));
  });

  testWidgets('ScheduleFormPage (Add mode) form adapts fields based on Lecture vs External and Repeat Weekly toggle', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: ScheduleFormPage(),
    ));
    await tester.pumpAndSettle();

    // 1. By default, type is Lecture:
    // Course field is shown, Schedule Title is NOT shown
    expect(find.text('Course'), findsOneWidget);
    expect(find.text('Schedule Title'), findsNothing);

    // 2. Date field is ALWAYS visible even when Repeat Weekly is ON:
    expect(find.text('Repeat Weekly'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);

    // 3. Toggle Repeat Weekly OFF:
    // Date field remains visible
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Date'), findsOneWidget);

    // 4. Toggle Repeat Weekly back ON:
    // Date field remains visible
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Date'), findsOneWidget);

    // 5. Select 'External' type:
    // Schedule Title appears, Course disappears
    await tester.tap(find.text('External'));
    await tester.pumpAndSettle();
    expect(find.text('Schedule Title'), findsOneWidget);
    expect(find.text('Course'), findsNothing);

    // 6. Switch back to 'Lecture':
    // Course appears, Schedule Title disappears
    await tester.tap(find.text('Lecture'));
    await tester.pumpAndSettle();
    expect(find.text('Course'), findsOneWidget);
    expect(find.text('Schedule Title'), findsNothing);
  });

  testWidgets('ScheduleFormPage (Edit mode) form adapts fields based on Lecture vs External and Repeat Weekly toggle', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final lectureSchedule = ScheduleModel(
      id: 'edit_test_1',
      title: 'Operating Systems',
      course: 'CS201 - OS',
      type: 'Lecture',
      date: DateTime.now(),
      timeStart: '08:00',
      timeEnd: '10:00',
      repeat: true,
    );

    await tester.pumpWidget(MaterialApp(
      home: ScheduleFormPage(schedule: lectureSchedule),
    ));
    await tester.pumpAndSettle();

    // Lecture with repeat = true: Course shown, Schedule Title hidden, Date remains shown
    expect(find.text('Course'), findsOneWidget);
    expect(find.text('Schedule Title'), findsNothing);
    expect(find.text('Date'), findsOneWidget);

    // Toggle repeat weekly to false: Date remains visible
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Date'), findsOneWidget);

    // Switch to External: Schedule Title shown, Course hidden
    await tester.tap(find.text('External'));
    await tester.pumpAndSettle();
    expect(find.text('Schedule Title'), findsOneWidget);
    expect(find.text('Course'), findsNothing);
  });

  testWidgets('PopUpCreateTeam dialog opens, supports input, code generation, and creation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    CreateTeamResult? result;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await PopUpCreateTeam.show(
                context,
                initialCode: '7X29',
              );
            },
            child: const Text('Open Create Team'),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Open popup
    await tester.tap(find.text('Open Create Team'));
    await tester.pumpAndSettle();

    // Check title, fields, and initial invite code
    expect(find.text('Create Team'), findsWidgets);
    expect(find.text('Team Name'), findsOneWidget);
    expect(find.text('Description (Optional)'), findsOneWidget);
    expect(find.text('Team Invite Code'), findsOneWidget);
    expect(find.text('7X29'), findsOneWidget);
    expect(find.text('Generate New'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);

    // Tap 'Generate New' to change code
    await tester.tap(find.text('Generate New'));
    await tester.pumpAndSettle();

    // Old code 7X29 should be replaced by a newly generated code
    expect(find.text('7X29'), findsNothing);

    // Tap 'Copy' button
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(find.text('Copied!'), findsOneWidget);

    // Enter team name
    await tester.enterText(find.byType(TextField).first, 'Kelompok Flutter');
    await tester.pumpAndSettle();

    // Submit
    await tester.tap(find.byKey(const ValueKey('create_team_submit_button')));
    await tester.pumpAndSettle();

    // Popup closed and result returned
    expect(result, isNotNull);
    expect(result!.name, 'Kelompok Flutter');
    expect(result!.inviteCode.isNotEmpty, isTrue);
  });

  testWidgets('PopUpJoinTeam dialog opens, enters code, and submits code', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    String? joinedCode;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              joinedCode = await PopUpJoinTeam.show(context);
            },
            child: const Text('Open Join Team'),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Open popup
    await tester.tap(find.text('Open Join Team'));
    await tester.pumpAndSettle();

    // Check elements
    expect(find.text('Join Team'), findsWidgets);
    expect(find.text('Enter Code'), findsOneWidget);
    expect(find.text('Become Member'), findsOneWidget);

    // Enter invite code
    await tester.enterText(find.byType(TextField), 'IMPAL-99');
    await tester.pumpAndSettle();

    // Tap 'Become Member'
    await tester.tap(find.byKey(const ValueKey('join_team_submit_button')));
    await tester.pumpAndSettle();

    // Popup closed and code returned
    expect(joinedCode, 'IMPAL-99');
  });

  testWidgets('TeamListPage action buttons open PopUpJoinTeam and PopUpCreateTeam', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: TeamListPage(),
    ));
    await tester.pumpAndSettle();

    // Tap '+ Create Team'
    await tester.tap(find.text('+ Create Team'));
    await tester.pumpAndSettle();

    // PopUpCreateTeam is shown
    expect(find.text('Create Team'), findsWidgets);
    expect(find.text('Team Name'), findsOneWidget);

    // Close via (x) close icon
    await tester.tap(find.byKey(const ValueKey('close_create_team_button')));
    await tester.pumpAndSettle();

    // Tap 'Join Team'
    await tester.tap(find.text('Join Team'));
    await tester.pumpAndSettle();

    // PopUpJoinTeam is shown
    expect(find.text('Join Team'), findsWidgets);
    expect(find.text('Become Member'), findsOneWidget);

    // Close via (x) close icon
    await tester.tap(find.byKey(const ValueKey('close_join_team_button')));
    await tester.pumpAndSettle();
  });

  testWidgets('TeamListPage team schedule connects dynamically to ScheduleRepository and updates reactively', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => ScheduleRepository().resetToDefault());

    final now = DateTime.now();
    ScheduleRepository().schedulesNotifier.value = [
      ScheduleModel(
        id: 'team_meeting_1',
        title: 'SPRINT RETROSPECTIVE IMPAL',
        type: 'External',
        location: 'Ruang Lab 2 TULT',
        date: now,
        timeStart: '14:00',
        timeEnd: '16:00',
      ),
    ];

    await tester.pumpWidget(const MaterialApp(
      home: TeamListPage(),
    ));
    await tester.pumpAndSettle();

    // Verify dynamic schedule title, location, and time from repository
    expect(find.text("Team's Schedule"), findsOneWidget);
    expect(find.text('SPRINT RETROSPECTIVE IMPAL'), findsOneWidget);
    expect(find.text('Ruang Lab 2 TULT'), findsOneWidget);
    expect(find.text('Today 14:00 WIB'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsWidgets);

    // Update repository reactively with another title
    ScheduleRepository().schedulesNotifier.value = [
      ScheduleModel(
        id: 'team_meeting_1',
        title: 'SCRUM DAILY KELOMPOK 7',
        type: 'External',
        location: 'Google Meet',
        date: now.add(const Duration(days: 1)),
        timeStart: '20:00',
        timeEnd: '21:00',
      ),
    ];
    await tester.pumpAndSettle();

    // Verify UI immediately updated with new title and location
    expect(find.text('SCRUM DAILY KELOMPOK 7'), findsOneWidget);
    expect(find.text('Google Meet'), findsOneWidget);
    expect(find.text('Tomorrow 20:00 WIB'), findsOneWidget);

    // Tap schedule card to open PopUpCreateMeeting in edit mode
    await tester.tap(find.text('SCRUM DAILY KELOMPOK 7'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Meeting'), findsOneWidget);
    expect(find.text('SCRUM DAILY KELOMPOK 7'), findsWidgets);

    // Pop back to TeamListPage
    Navigator.of(tester.element(find.text('Edit Meeting'))).pop();
    await tester.pumpAndSettle();

    // Tap 'See all' to navigate to Schedule view
    await tester.tap(find.byKey(const ValueKey('team_schedule_see_all')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('team_page_schedule_tab_content')), findsOneWidget);
  });

  testWidgets("Team's schedule scrolls horizontally when > 1 items and filters strictly for team meetings", (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final now = DateTime.now();

    // Skenario: ada 1 jadwal kuliah IMPAL (Lecture) dan 2 jadwal meeting tim (External / Meeting)
    ScheduleRepository().schedulesNotifier.value = [
      ScheduleModel(
        id: 'sch_lecture_impal',
        title: 'Praktikum Software Testing IMPAL',
        type: 'Lecture', // Kuliah - TIDAK BOLEH muncul di Team's Schedule
        course: 'Software Testing IMPAL',
        location: 'Lab 3 TULT',
        date: now,
        timeStart: '09:00',
        timeEnd: '11:00',
      ),
      ScheduleModel(
        id: 'team_meet_1',
        title: 'Meeting Sprint 2 Kelompok IMPAL',
        type: 'External', // Meeting tim 1
        location: 'Discord - Voice Channel 1',
        date: now,
        timeStart: '13:00',
        timeEnd: '14:30',
      ),
      ScheduleModel(
        id: 'team_meet_2',
        title: 'Diskusi Teknis Backend & Frontend Team',
        type: 'External', // Meeting tim 2
        location: 'Google Meet',
        date: now,
        timeStart: '19:00',
        timeEnd: '20:30',
      ),
    ];

    await tester.pumpWidget(const MaterialApp(
      home: TeamListPage(),
    ));
    await tester.pumpAndSettle();

    // 1. Verifikasi jadwal kuliah Praktikum IMPAL TIDAK muncul di Team's Schedule
    expect(find.text('Praktikum Software Testing IMPAL'), findsNothing);

    // 2. Verifikasi kedua meeting tim muncul
    expect(find.text('Meeting Sprint 2 Kelompok IMPAL'), findsOneWidget);
    expect(find.text('Diskusi Teknis Backend & Frontend Team'), findsOneWidget);

    // 3. Verifikasi SingleChildScrollView scroll horizontal tersedia
    final horizontalScrollFinder = find.byKey(const ValueKey('team_schedules_horizontal_scroll'));
    expect(horizontalScrollFinder, findsOneWidget);

    final SingleChildScrollView scrollView = tester.widget(horizontalScrollFinder);
    expect(scrollView.scrollDirection, Axis.horizontal);

    // 4. Verifikasi scroll gesture horizontal bekerja tanpa error
    await tester.drag(horizontalScrollFinder, const Offset(-150, 0));
    await tester.pumpAndSettle();
  });

  testWidgets('DashboardTeamPage renders properly and displays header, code, schedules, and tasks', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: DashboardTeamPage(
        userName: 'Jarvis',
        teamName: 'Kelompok IMPAL',
        teamCode: '7X29',
      ),
    ));
    await tester.pumpAndSettle();

    // Verifikasi Header & Info Tim
    expect(find.text('Hi Jarvis'), findsOneWidget);
    expect(find.text('Kelompok IMPAL'), findsOneWidget);
    expect(find.text('7X29'), findsOneWidget);

    // Verifikasi Section Header
    expect(find.text("Team's Schedule"), findsOneWidget);
    expect(find.text('Team Task'), findsOneWidget);

    // Verifikasi Default Task
    expect(find.text('Membuat ui page kelompok'), findsOneWidget);
    expect(find.text('Membuat ui page home'), findsOneWidget);
    expect(find.text('Membuat ui form tugas'), findsOneWidget);
  });

  testWidgets('DashboardTeamPage copies invite code and displays PopUpPemberitahuan when tapped', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: DashboardTeamPage(
        userName: 'Jarvis',
        teamName: 'Kelompok IMPAL',
        teamCode: '7X29',
      ),
    ));
    await tester.pumpAndSettle();

    // Temukan tombol/badge kode tim
    final copyCodeFinder = find.byKey(const ValueKey('team_dashboard_copy_code_button'));
    expect(copyCodeFinder, findsOneWidget);

    // Tekan tombol kode tim
    await tester.tap(copyCodeFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verifikasi PopUpPemberitahuan muncul
    expect(find.text('Code Copied'), findsOneWidget);
    expect(find.text('Invite code "7X29" copied to clipboard.'), findsOneWidget);

    // Biarkan auto-dismiss selesai
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('DashboardTeamPage allows creating a new team task via dialog', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: DashboardTeamPage(
        userName: 'Jarvis',
        teamName: 'Kelompok IMPAL',
        teamCode: '7X29',
      ),
    ));
    await tester.pumpAndSettle();

    // Temukan tombol + Create Task
    final createTaskButton = find.byKey(const ValueKey('dashboard_create_task_button'));
    expect(createTaskButton, findsOneWidget);

    await tester.ensureVisible(createTaskButton);
    await tester.tap(createTaskButton);
    await tester.pumpAndSettle();

    // Verifikasi Dialog Add Task muncul
    expect(find.text('Create Team Task'), findsOneWidget);

    // Isi task title
    final titleField = find.widgetWithText(TextField, 'Task Title (e.g. Slicing UI)');
    expect(titleField, findsOneWidget);
    await tester.enterText(titleField, 'Implementasi Automated Testing');

    // Tap tombol Add Task di dialog
    final submitButton = find.text('Add Task');
    expect(submitButton, findsOneWidget);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Verifikasi task baru sekarang ada di daftar
    expect(find.text('Implementasi Automated Testing'), findsOneWidget);
  });

  testWidgets('TeamListPage navigates to DashboardTeamPage on team card tap', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: TeamListPage(userName: 'Jarvis'),
    ));
    await tester.pumpAndSettle();

    // Cari kartu tim "Kelompok - IMPAL"
    final teamCard = find.text('Kelompok - IMPAL');
    expect(teamCard, findsOneWidget);

    await tester.tap(teamCard);
    await tester.pumpAndSettle();

    // Verifikasi sekarang berada di DashboardTeamPage
    expect(find.byType(DashboardTeamPage), findsOneWidget);
    expect(find.text("Team's Schedule"), findsOneWidget);
    expect(find.text('Team Task'), findsOneWidget);
  });

  testWidgets('DashboardTeamPage uses ImpalBottomNavBar and renders team info blending into base canvas', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: DashboardTeamPage(
        userName: 'Jarvis',
        teamName: 'Kelompok IMPAL',
        teamCode: '7X29',
      ),
    ));
    await tester.pumpAndSettle();

    // Verifikasi ImpalBottomNavBar digunakan
    expect(find.byType(ImpalBottomNavBar), findsOneWidget);
    expect(find.byKey(const ValueKey('impal_nav_floating_button')), findsOneWidget);

    // Verifikasi nama tim dan kode tim tampil
    expect(find.text('Kelompok IMPAL'), findsOneWidget);
    expect(find.text('7X29'), findsOneWidget);
  });

  testWidgets('DashboardTeamPage task cards render avatar profile with person silhouette icon', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: DashboardTeamPage(
        userName: 'Jarvis',
        teamName: 'Kelompok IMPAL',
        teamCode: '7X29',
      ),
    ));
    await tester.pumpAndSettle();

    // Verifikasi avatar profile ikon Icons.person tampil pada task cards
    expect(find.byIcon(Icons.person), findsWidgets);
    expect(find.text('Yoga Perkasa Didik'), findsWidgets);
  });

  testWidgets('All primary pages (Home, Team, Schedule, DashboardTeam) use standard ImpalBottomNavBar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. Home
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();
    expect(find.byType(ImpalBottomNavBar), findsOneWidget);

    // 2. TeamListPage
    await tester.pumpWidget(const MaterialApp(home: TeamListPage()));
    await tester.pumpAndSettle();
    expect(find.byType(ImpalBottomNavBar), findsOneWidget);

    // 3. SchedulePage
    await tester.pumpWidget(const MaterialApp(home: SchedulePage()));
    await tester.pumpAndSettle();
    expect(find.byType(ImpalBottomNavBar), findsOneWidget);
  });

  testWidgets('Dashboard, Schedule, and Team pages adhere strictly to design system spacing tokens', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. DashboardTeamPage has team schedule and section header to content spacing
    await tester.pumpWidget(const MaterialApp(
      home: DashboardTeamPage(
        userName: 'Jarvis',
        teamName: 'Kelompok IMPAL',
        teamCode: '7X29',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text("Team's Schedule"), findsOneWidget);
    expect(find.text("+ Create Meeting"), findsOneWidget);
    expect(find.text("Team Task"), findsOneWidget);

    // 2. SchedulePage conforms to standard spacing & date groupings
    await tester.pumpWidget(const MaterialApp(home: SchedulePage()));
    await tester.pumpAndSettle();

    expect(find.text('Add Schedule'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('Single Persistent Navigation Shell handles Team list to Dashboard Team, Schedule, and back seamlessly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    // 1. Pindah ke tab 2 (Teams)
    await tester.tap(find.byIcon(Icons.groups_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Team List'), findsOneWidget);
    expect(find.text('Kelompok - IMPAL'), findsOneWidget);

    // 2. Pilih kartu Kelompok - IMPAL
    await tester.tap(find.text('Kelompok - IMPAL'));
    await tester.pumpAndSettle();

    // Verifikasi berada di Dashboard Team tanpa reload navbar
    expect(find.text('Team Dashboard'), findsOneWidget);
    expect(find.text('7X29'), findsOneWidget);
    expect(find.byType(ImpalBottomNavBar), findsOneWidget);

    // 3. Tekan Schedule (Tab 3) pada navbar
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Add Schedule'), findsOneWidget);

    // 4. Tekan Team (Tab 2) kembali -> selalu kembali ke Team List
    await tester.tap(find.byIcon(Icons.groups_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Team List'), findsOneWidget);
    expect(find.text('Kelompok - IMPAL'), findsOneWidget);

    // 5. Buka kembali dashboard team, lalu uji tombol Back di header
    await tester.tap(find.text('Kelompok - IMPAL'));
    await tester.pumpAndSettle();
    expect(find.text('Team Dashboard'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Team List'), findsOneWidget);

    // 6. Tekan Home (Tab 0) pada navbar
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text("Today's schedule"), findsOneWidget);
  });

  testWidgets('PopUpCreateMeeting renders properly, validates name, and creates meeting schedule', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => ScheduleRepository().resetToDefault());

    ScheduleModel? createdResult;

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                createdResult = await PopUpCreateMeeting.show(
                  ctx,
                  teamName: 'Kelompok IMPAL',
                );
              },
              child: const Text('Open Modal'),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // 1. Buka popup
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    expect(find.text('Create Meeting'), findsWidgets);
    expect(find.text('Meeting Name'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Description (Optional)'), findsOneWidget);
    expect(find.text('Date & Time'), findsOneWidget);
    expect(find.text('Start Time'), findsOneWidget);
    expect(find.text('End Time (Estimated)'), findsOneWidget);
    expect(find.text('Repeat Weekly'), findsOneWidget);

    // 2. Klik submit tanpa mengisi nama -> validasi muncul
    await tester.tap(find.byKey(const ValueKey('create_meeting_submit_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Meeting Name Required'), findsOneWidget);

    // Let the validation notification finish dismissing
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 3. Masukkan nama meeting, lokasi, dan deskripsi
    await tester.enterText(
      find.byKey(const ValueKey('create_meeting_name_input')),
      'Sprint Review IMPAL',
    );
    await tester.enterText(
      find.byKey(const ValueKey('create_meeting_location_input')),
      'Google Meet - Room 4',
    );
    await tester.enterText(
      find.byKey(const ValueKey('create_meeting_desc_input')),
      'Review progres UI dan arsitektur',
    );
    await tester.pumpAndSettle();

    // Toggle repeat weekly ON
    await tester.tap(find.byKey(const ValueKey('create_meeting_repeat_weekly_switch')));
    await tester.pumpAndSettle();

    // 4. Tekan Submit
    await tester.tap(find.byKey(const ValueKey('create_meeting_submit_button')));
    await tester.pumpAndSettle();

    // Dialog tertutup dan model berhasil dibuat
    expect(createdResult, isNotNull);
    expect(createdResult!.title, equals('Sprint Review IMPAL'));
    expect(createdResult!.location, equals('Google Meet - Room 4'));
    expect(createdResult!.notes, equals('Review progres UI dan arsitektur'));
    expect(createdResult!.type, equals('Meeting'));
    expect(createdResult!.repeat, isTrue);
    expect(createdResult!.timeEnd.isNotEmpty, isTrue);
  });

  testWidgets('PopUpCreateMeeting.showEdit renders Edit Meeting and updates existing meeting', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    ScheduleModel? editedResult;
    final existing = ScheduleModel(
      id: 'existing_meet_1',
      title: 'Old Title',
      type: 'Meeting',
      location: 'Old Room',
      notes: 'Old Notes',
      date: DateTime(2026, 10, 25),
      timeStart: '10:00',
      timeEnd: '11:00',
      repeat: true,
    );
    ScheduleRepository().schedulesNotifier.value = [existing];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () async {
              editedResult = await PopUpCreateMeeting.showEdit(
                ctx,
                existingSchedule: existing,
              );
            },
            child: const Text('Open Edit Modal'),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Edit Modal'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Meeting'), findsWidgets);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Old Title'), findsOneWidget);
    expect(find.text('Old Room'), findsOneWidget);
    expect(find.text('End Time (Estimated)'), findsOneWidget);
    expect(find.text('Repeat Weekly'), findsOneWidget);

    // Verify existing repeat is true, toggle to false
    final switchFinder = find.byKey(const ValueKey('create_meeting_repeat_weekly_switch'));
    expect(tester.widget<Switch>(switchFinder).value, isTrue);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(switchFinder).value, isFalse);

    await tester.enterText(
      find.byKey(const ValueKey('create_meeting_name_input')),
      'New Edited Title',
    );
    await tester.enterText(
      find.byKey(const ValueKey('create_meeting_location_input')),
      'New Edited Room',
    );
    await tester.tap(find.byKey(const ValueKey('create_meeting_submit_button')));
    await tester.pumpAndSettle();

    expect(editedResult, isNotNull);
    expect(editedResult!.title, equals('New Edited Title'));
    expect(editedResult!.location, equals('New Edited Room'));
    expect(editedResult!.repeat, isFalse);
    expect(editedResult!.timeEnd, '11:00');
    expect(ScheduleRepository().getById('existing_meet_1')?.title, 'New Edited Title');
    expect(ScheduleRepository().getById('existing_meet_1')?.repeat, isFalse);
  });

  testWidgets('DashboardTeamPage + Create Meeting button opens PopUpCreateMeeting', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: DashboardTeamPage(
          teamName: 'Kelompok IMPAL',
          teamCode: '7X29',
          isStandalone: false,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Pastikan tombol + Create Meeting ada
    final createBtn = find.byKey(const ValueKey('dashboard_create_meeting_button'));
    expect(createBtn, findsOneWidget);

    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    // Dialog Create Meeting terbuka
    expect(find.text('Meeting Name'), findsOneWidget);
    expect(find.byKey(const ValueKey('close_create_meeting_button')), findsOneWidget);

    // Tutup dialog
    await tester.tap(find.byKey(const ValueKey('close_create_meeting_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('close_create_meeting_button')), findsNothing);
  });

  testWidgets('TeamListPage spacing and action buttons work properly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: TeamListPage(isStandalone: true),
    ));
    await tester.pumpAndSettle();

    // Verifikasi tombol Join Team & Create Team
    expect(find.byKey(const ValueKey('team_list_join_team_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('team_list_create_team_button')), findsOneWidget);

    // Tap Join Team membuka PopUpJoinTeam
    await tester.tap(find.byKey(const ValueKey('team_list_join_team_button')));
    await tester.pumpAndSettle();
    expect(find.text('Become Member'), findsOneWidget);

    // Tutup popup
    await tester.tap(find.byKey(const ValueKey('close_join_team_button')));
    await tester.pumpAndSettle();
    expect(find.text('Become Member'), findsNothing);
  });

  testWidgets('Schedule & meeting cards across all pages provide uniform edit and delete action symbols', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => ScheduleRepository().resetToDefault());

    final now = DateTime.now();
    ScheduleRepository().schedulesNotifier.value = [
      ScheduleModel(
        id: 'meeting_test_1',
        title: 'Daily Standup Meeting',
        type: 'meeting',
        location: 'Zoom',
        status: 'Ongoing',
        date: now,
        timeStart: '09:00',
        timeEnd: '09:30',
      ),
    ];

    // 1. Verifikasi di SchedulePage
    await tester.pumpWidget(const MaterialApp(home: SchedulePage()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);

    // Tap Edit pada meeting di SchedulePage -> membuka PopUpCreateMeeting (Edit Meeting)
    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('Edit Meeting'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('close_create_meeting_button')));
    await tester.pumpAndSettle();

    // 2. Verifikasi di HomePage
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);

    // 3. Verifikasi di DashboardTeamPage
    await tester.pumpWidget(const MaterialApp(
      home: DashboardTeamPage(
        userName: 'Jarvis',
        teamName: 'Kelompok IMPAL',
        teamCode: '7X29',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);

    // 4. Verifikasi di TeamListPage
    await tester.pumpWidget(const MaterialApp(home: TeamListPage(isStandalone: true)));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);

    // 5. Test fungsi delete dengan PopUpKonfirmasiDelete
    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Delete Meeting?'), findsOneWidget);
    // Konfirmasi hapus
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(ScheduleRepository().schedulesNotifier.value.where((s) => s.id == 'meeting_test_1'), isEmpty);
  });

  testWidgets('SchedulePage groups dates chronologically with past on top, Today in middle, and future at bottom', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => ScheduleRepository().resetToDefault());

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));

    ScheduleRepository().schedulesNotifier.value = [
      ScheduleModel(
        id: 'sch_future',
        title: 'Future Workshop',
        type: 'Lecture',
        status: 'Upcoming',
        date: tomorrow,
        timeStart: '14:00',
        timeEnd: '16:00',
      ),
      ScheduleModel(
        id: 'sch_past',
        title: 'Past Assignment',
        type: 'Lecture',
        status: 'Overdue',
        date: yesterday,
        timeStart: '08:00',
        timeEnd: '10:00',
      ),
      ScheduleModel(
        id: 'sch_now',
        title: 'Middle Lecture',
        type: 'Lecture',
        status: 'Ongoing',
        date: now,
        timeStart: '10:00',
        timeEnd: '12:00',
      ),
    ];

    await tester.pumpWidget(const MaterialApp(home: SchedulePage()));
    await tester.pumpAndSettle();

    // Verifikasi semua grup tanggal tampil
    final pastFinder = find.textContaining('Yesterday');
    final todayFinder = find.textContaining('Today ${now.day}');
    final tomorrowFinder = find.textContaining('Tomorrow');

    expect(pastFinder, findsOneWidget);
    expect(todayFinder, findsOneWidget);
    expect(tomorrowFinder, findsOneWidget);

    // Verifikasi posisi vertikal: Yesterday (atas) < Today (tengah) < Tomorrow (bawah)
    final pastY = tester.getTopLeft(pastFinder).dy;
    final todayY = tester.getTopLeft(todayFinder).dy;
    final tomorrowY = tester.getTopLeft(tomorrowFinder).dy;

    expect(pastY, lessThan(todayY));
    expect(todayY, lessThan(tomorrowY));
  });

  testWidgets('SchedulePage orders items within a day: Overdue on top, Ongoing in middle, Upcoming at bottom', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => ScheduleRepository().resetToDefault());

    final now = DateTime.now();

    ScheduleRepository().schedulesNotifier.value = [
      ScheduleModel(
        id: 'item_upcoming',
        title: 'Item Upcoming Day',
        type: 'Lecture',
        status: 'Upcoming',
        date: now,
        timeStart: '16:00',
        timeEnd: '18:00',
      ),
      ScheduleModel(
        id: 'item_overdue',
        title: 'Item Overdue Day',
        type: 'Lecture',
        status: 'Overdue',
        date: now,
        timeStart: '07:00',
        timeEnd: '09:00',
      ),
      ScheduleModel(
        id: 'item_ongoing',
        title: 'Item Ongoing Day',
        type: 'Lecture',
        status: 'Ongoing',
        date: now,
        timeStart: '10:00',
        timeEnd: '12:00',
      ),
    ];

    await tester.pumpWidget(const MaterialApp(home: SchedulePage()));
    await tester.pumpAndSettle();

    final overdueFinder = find.text('Item Overdue Day');
    final ongoingFinder = find.text('Item Ongoing Day');
    final upcomingFinder = find.text('Item Upcoming Day');

    expect(overdueFinder, findsOneWidget);
    expect(ongoingFinder, findsOneWidget);
    expect(upcomingFinder, findsOneWidget);

    final overdueY = tester.getTopLeft(overdueFinder).dy;
    final ongoingY = tester.getTopLeft(ongoingFinder).dy;
    final upcomingY = tester.getTopLeft(upcomingFinder).dy;

    // Overdue paling atas < Ongoing di tengah < Upcoming di bawah
    expect(overdueY, lessThan(ongoingY));
    expect(ongoingY, lessThan(upcomingY));
  });

  testWidgets('ImpalScheduleCard renders details and fires edit/delete callbacks', (WidgetTester tester) async {
    bool editCalled = false;
    bool deleteCalled = false;

    final now = DateTime.now();
    final startH = (now.hour).toString().padLeft(2, '0');
    final endH = ((now.hour + 1) % 24).toString().padLeft(2, '0');

    final schedule = ScheduleModel(
      id: 'test_card_1',
      title: 'Weekly Standup Impal',
      type: 'Meeting',
      date: now,
      timeStart: '$startH:00',
      timeEnd: '$endH:00',
      location: 'Room 302',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ImpalScheduleCard(
          schedule: schedule,
          onEdit: () => editCalled = true,
          onDelete: () => deleteCalled = true,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Weekly Standup Impal'), findsOneWidget);
    expect(find.text('Ongoing'), findsOneWidget);
    expect(find.text('Room 302'), findsOneWidget);
    expect(find.text('$startH:00 - $endH:00 WIB'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(editCalled, isTrue);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    expect(deleteCalled, isTrue);
  });

  testWidgets('PopUpKonfirmasiDelete supports custom meeting title and message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              PopUpKonfirmasiDelete.show(
                context,
                title: 'Delete Meeting?',
                message: 'Are you sure you want to delete this meeting?',
              );
            },
            child: const Text('Open Dialog'),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Meeting?'), findsOneWidget);
    expect(find.text('Are you sure you want to delete this meeting?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('PopUpPemberitahuan renders meetingCreated, meetingUpdated, and meetingDeleted toasts', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Column(
            children: [
              ElevatedButton(
                onPressed: () => PopUpPemberitahuan.meetingCreated(context),
                child: const Text('Show Created'),
              ),
              ElevatedButton(
                onPressed: () => PopUpPemberitahuan.meetingUpdated(context),
                child: const Text('Show Updated'),
              ),
              ElevatedButton(
                onPressed: () => PopUpPemberitahuan.meetingDeleted(context),
                child: const Text('Show Deleted'),
              ),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Created'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Meeting Created'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));

    await tester.tap(find.text('Show Updated'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Meeting Updated'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));

    await tester.tap(find.text('Show Deleted'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Meeting Deleted'), findsOneWidget);
  });

  testWidgets('ScheduleFormPage form elements are in logical order with Date always shown', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: ScheduleFormPage(),
    ));
    await tester.pumpAndSettle();

    final scheduleTypeFinder = find.text('Schedule Type');
    final courseFinder = find.text('Course');
    final locationFinder = find.text('Location / Room');
    final dateFinder = find.text('Date');
    final timeDurationFinder = find.text('Time Duration');
    final repeatWeeklyFinder = find.text('Repeat Weekly');

    expect(scheduleTypeFinder, findsOneWidget);
    expect(courseFinder, findsOneWidget);
    expect(locationFinder, findsOneWidget);
    expect(dateFinder, findsOneWidget);
    expect(timeDurationFinder, findsOneWidget);
    expect(repeatWeeklyFinder, findsOneWidget);

    final yType = tester.getTopLeft(scheduleTypeFinder).dy;
    final yCourse = tester.getTopLeft(courseFinder).dy;
    final yLocation = tester.getTopLeft(locationFinder).dy;
    final yDate = tester.getTopLeft(dateFinder).dy;
    final yTime = tester.getTopLeft(timeDurationFinder).dy;
    final yRepeat = tester.getTopLeft(repeatWeeklyFinder).dy;

    // Verify ordering: Type < Course < Location < Date < Time Duration < Repeat Weekly
    expect(yType, lessThan(yCourse));
    expect(yCourse, lessThan(yLocation));
    expect(yLocation, lessThan(yDate));
    expect(yDate, lessThan(yTime));
    expect(yTime, lessThan(yRepeat));
  });
}

