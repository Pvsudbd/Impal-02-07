import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/auth/login_page.dart';
import 'package:impal_smart_todolist/presentation/features/jadwal/schedule_page.dart';
import 'package:impal_smart_todolist/presentation/features/jadwal/models/schedule_model.dart';
import 'package:impal_smart_todolist/presentation/features/jadwal/models/schedule_repository.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/home_page.dart';
import 'package:impal_smart_todolist/presentation/features/team/team_list_page.dart';
import 'package:impal_smart_todolist/presentation/features/jadwal/add_new_schedule.dart';
import 'package:impal_smart_todolist/presentation/features/jadwal/edit_schedule.dart';
import 'package:impal_smart_todolist/presentation/common_widgets/impal_time_picker_dialog.dart';

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

  testWidgets('AddNewSchedule opens time picker in 24-hour mode without AM/PM', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(
      home: AddNewSchedule(),
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

  testWidgets('EditSchedule opens time picker in 24-hour mode without AM/PM', (WidgetTester tester) async {
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
      home: EditSchedule(schedule: item),
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
}

