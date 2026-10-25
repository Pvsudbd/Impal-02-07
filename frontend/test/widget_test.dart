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

void main() {
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

  test('ScheduleModel calculates ongoing, upcoming, and completed status automatically based on current time', () {
    final baseDate = DateTime(2026, 10, 25);

    // 1. Past schedule on the same day -> Completed
    final completedSchedule = ScheduleModel(
      id: 'c1',
      title: 'Completed Test',
      type: 'Lecture',
      date: baseDate,
      timeStart: '08:00',
      timeEnd: '10:00',
    );
    // At 11:00 on the same date, schedule should be Completed
    expect(
      completedSchedule.getStatusAt(DateTime(2026, 10, 25, 11, 0)),
      'Completed',
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

    // 4. Past date -> Completed
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
      'Completed',
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
    // At 01:30 next day -> Completed
    expect(
      overnightSchedule.getStatusAt(DateTime(2026, 10, 26, 1, 30)),
      'Completed',
    );
  });

  testWidgets('Schedule card displays Completed with green pill and Ongoing with coral pill', (WidgetTester tester) async {
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

    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Ongoing'), findsWidgets);
  });

  testWidgets("Today's schedule on HomePage displays Completed -> Ongoing -> Upcoming and focuses on Ongoing card", (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final now = DateTime.now();
    String fmt(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    // Provide 3 schedules in arbitrary order: Upcoming, Completed, Ongoing
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
        title: 'Completed Morning Class',
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

    // Verify Ongoing Noon Class is rendered
    expect(find.text('Ongoing Noon Class'), findsOneWidget);

    // Check horizontal scroll controller offset points to the Ongoing card (index 1 -> 297.0)
    final scrollFinder = find.byKey(const ValueKey('today_schedules_horizontal_scroll'));
    expect(scrollFinder, findsOneWidget);
    final SingleChildScrollView scrollView = tester.widget(scrollFinder);
    expect(scrollView.controller, isNotNull);
    expect(scrollView.controller!.offset, 297.0);

    // User can scroll to the left (drag right) to view Completed Morning Class
    await tester.drag(scrollFinder, const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(scrollView.controller!.offset, lessThanOrEqualTo(50.0));

    // User can scroll to the right (drag left) to view Upcoming Evening Class
    await tester.drag(scrollFinder, const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(scrollView.controller!.offset, greaterThan(200.0));
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

    // 2. By default, Repeat Weekly is ON:
    // Date field is NOT shown
    expect(find.text('Repeat Weekly'), findsOneWidget);
    expect(find.text('Date'), findsNothing);

    // 3. Toggle Repeat Weekly OFF:
    // Date field now appears
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Date'), findsOneWidget);

    // 4. Toggle Repeat Weekly back ON:
    // Date field disappears
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Date'), findsNothing);

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

    // Lecture with repeat = true: Course shown, Schedule Title hidden, Date hidden
    expect(find.text('Course'), findsOneWidget);
    expect(find.text('Schedule Title'), findsNothing);
    expect(find.text('Date'), findsNothing);

    // Toggle repeat weekly to false: Date should appear
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Date'), findsOneWidget);

    // Switch to External: Schedule Title shown, Course hidden
    await tester.tap(find.text('External'));
    await tester.pumpAndSettle();
    expect(find.text('Schedule Title'), findsOneWidget);
    expect(find.text('Course'), findsNothing);
  });
}

