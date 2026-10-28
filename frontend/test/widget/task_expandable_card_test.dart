import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/task/models/task_item_model.dart';
import 'package:impal_smart_todolist/presentation/features/task/widgets/task_expandable_card.dart';

void main() {
  final sampleTask = TaskItemModel(
    id: 'test_task_1',
    title: 'Tugas Besar Kecerdasan AI',
    priority: TaskPriorityLevel.high,
    durationBadge: '12h',
    subtitle: 'Team members',
    deadlineDate: DateTime(2026, 10, 11, 23, 59),
    formattedDeadline: 'Sat 11 Oct 2026, 23: 59 WIB',
    progressPercent: 98,
    memberAvatars: const [
      Color(0xFFF3A683),
      Color(0xFF786FA6),
      Color(0xFF63CDDA),
    ],
    tags: const [
      TaskTagModel(
        label: 'Kelompok',
        backgroundColor: Color(0xFF786FA6),
      ),
      TaskTagModel(
        label: 'Code',
        backgroundColor: Color(0xFF778BEB),
      ),
    ],
    groupMembers: const [
      'Andi sukamoto (Leader)',
      'Rayya Gemintang Nusasntarra',
      'Kafi Rijal Perkasa Situmorang',
    ],
    course: 'SSIF-04-REG • Software Testing & Implementation',
    dateCreated: 'Monday, 30 Sep 2026',
    centroidDefuzzification: 'z* = 28.6',
    centroidScale: 'scale(0-100)',
    warningNotice: '*This task is asigned to you, and you can’t delete',
  );

  testWidgets('TaskExpandableCard collapses and expands ("memanjang") smoothly on tap', (tester) async {
    bool editTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TaskExpandableCard(
              task: sampleTask,
              onEdit: () {
                editTapped = true;
              },
            ),
          ),
        ),
      ),
    );

    // Collapsed state: Title, badges, tags, and progress ring are visible
    expect(find.text('Tugas Besar Kecerdasan AI'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('12h'), findsOneWidget);
    expect(find.text('98%'), findsOneWidget);
    expect(find.text('Kelompok'), findsOneWidget);
    expect(find.text('Code'), findsOneWidget);

    // Tap the card to expand it ("memanjang")
    await tester.tap(find.text('Tugas Besar Kecerdasan AI'));
    await tester.pumpAndSettle();

    // Expanded state: Details are revealed
    expect(find.text('Group Member'), findsOneWidget);
    expect(find.text('• Andi sukamoto (Leader)'), findsOneWidget);
    expect(find.text('• Rayya Gemintang Nusasntarra'), findsOneWidget);
    expect(find.text('• Kafi Rijal Perkasa Situmorang'), findsOneWidget);
    expect(find.text('Course'), findsOneWidget);
    expect(find.text('SSIF-04-REG • Software Testing & Implementation'), findsOneWidget);
    expect(find.text('Date Created'), findsOneWidget);
    expect(find.text('Monday, 30 Sep 2026'), findsOneWidget);
    expect(find.text('Centeroid Defuzzyfication'), findsOneWidget);
    expect(find.text('z* = 28.6'), findsOneWidget);
    expect(find.text('scale(0-100)'), findsOneWidget);
    expect(find.text('*This task is asigned to you, and you can’t delete'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);

    // Tap "Edit" button
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(editTapped, isTrue);

    // Tap the card again to collapse back
    await tester.tap(find.text('Tugas Besar Kecerdasan AI'));
    await tester.pumpAndSettle();
  });
}

