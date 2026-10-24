import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/auth/login_page.dart';
import 'package:impal_smart_todolist/presentation/features/jadwal/schedule_page.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/home_page.dart';

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
    expect(find.text('Jadwal Kuliah'), findsOneWidget);

    // Tap back button to return to dashboard
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Back on dashboard
    expect(find.text("Today's schedule"), findsOneWidget);
  });
}
