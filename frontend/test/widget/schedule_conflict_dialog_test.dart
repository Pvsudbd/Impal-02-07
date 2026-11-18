import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/models/schedule_model.dart';
import 'package:impal_smart_todolist/presentation/features/schedule/pop_up_schedule_conflict_dialog.dart';

void main() {
  group('PopUpScheduleConflictDialog Widget Tests', () {
    testWidgets('renders conflict dialog with non-yellow border and handles Save Anyway',
        (tester) async {
      bool? dialogResult;

      final dummyConflict = ScheduleModel(
        id: 'sch_conflict_1',
        title: 'Algoritma Pemrograman',
        type: 'Lecture',
        date: DateTime(2026, 11, 15),
        timeStart: '09:30',
        timeEnd: '11:30',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await PopUpScheduleConflictDialog.show(
                    context,
                    conflicts: [dummyConflict],
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify title & conflict info rendered
      expect(find.text('Schedule Conflict Detected'), findsOneWidget);
      expect(find.text('Overlaps with:'), findsOneWidget);
      expect(find.text('Algoritma Pemrograman'), findsOneWidget);

      // Verify border color of the conflict details box is slate (0xFF3B4150) and NOT yellow
      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final box = widget.decoration as BoxDecoration;
          if (box.border != null && box.border is Border) {
            final border = box.border as Border;
            return border.top.color == const Color(0xFF3B4150);
          }
        }
        return false;
      });
      expect(containerFinder, findsAtLeastNWidgets(1));

      // Tap "Save Anyway"
      await tester.tap(find.text('Save Anyway'));
      await tester.pumpAndSettle();

      // Verify returned true
      expect(dialogResult, isTrue);
    });

    testWidgets('handles Adjust Time cancellation', (tester) async {
      bool? dialogResult;

      final dummyConflict = ScheduleModel(
        id: 'sch_conflict_2',
        title: 'Sistem Operasi',
        type: 'Lecture',
        date: DateTime(2026, 11, 15),
        timeStart: '13:30',
        timeEnd: '15:30',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await PopUpScheduleConflictDialog.show(
                    context,
                    conflicts: [dummyConflict],
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap "Adjust Time"
      await tester.tap(find.text('Adjust Time'));
      await tester.pumpAndSettle();

      // Verify returned false
      expect(dialogResult, isFalse);
    });
  });
}

