import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/common_widgets/impal_search_bar.dart';

void main() {
  group('ImpalSearchBar Widget Tests', () {
    testWidgets('renders hint text and responds to user input', (tester) async {
      String changedText = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImpalSearchBar(
              hintText: 'Search tasks by title...',
              onChanged: (val) => changedText = val,
            ),
          ),
        ),
      );

      // Verify hintText is rendered
      expect(find.text('Search tasks by title...'), findsOneWidget);

      // Type "Database"
      await tester.enterText(find.byType(TextField), 'Database');
      await tester.pump();

      expect(changedText, 'Database');
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap clear icon
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(changedText, '');
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('renders initial value and triggers onClear callback', (tester) async {
      bool clearCalled = false;
      String changedText = 'Initial Query';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImpalSearchBar(
              initialValue: 'Initial Query',
              onChanged: (val) => changedText = val,
              onClear: () => clearCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Initial Query'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(clearCalled, isTrue);
      expect(changedText, '');
    });
  });
}
