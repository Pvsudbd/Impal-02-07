import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/home_page.dart';
import 'package:impal_smart_todolist/presentation/features/profile/models/user_profile_model.dart';
import 'package:impal_smart_todolist/presentation/features/profile/profile_page.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/detail_card_smart_priority.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/models/smart_priority_repository.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/smart_priority_page.dart';
import 'package:impal_smart_todolist/presentation/features/task/task_page.dart';

void main() {
  setUp(() {
    UserProfileRepository().toggleFuzzyModel(true);
    UserProfileRepository().toggleScoreExplainability(true);
  });

  Widget createWidgetForTesting(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('Smart Priority Widget Tests', () {
    testWidgets('SmartPriorityPage renders header, status card, and ranked task cards',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));

      await tester.pumpWidget(
        createWidgetForTesting(
          const SmartPriorityPage(userName: 'Yoga Perkasa'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('AI Smart Priority'), findsOneWidget);
      expect(find.text('Mamdani Fuzzy Logic Inference'), findsOneWidget);
      expect(find.text('YO'), findsOneWidget);

      // Verify Engine Status Card
      expect(find.text('Mamdani Inference Engine'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);

      // Verify Filter Chips
      expect(find.text('All Priorities (3)'), findsOneWidget);
      expect(find.text('High (1)'), findsOneWidget);
      expect(find.text('Medium (1)'), findsOneWidget);
      expect(find.text('Low (1)'), findsOneWidget);

      // Verify Priority Cards
      expect(find.text('#1 CRITICAL PRIORITY'), findsOneWidget);
      expect(find.text('AI Major Project - Sprint 2'), findsOneWidget);
      expect(find.text('87.5'), findsOneWidget);

      expect(find.text('#2 MODERATE PRIORITY'), findsOneWidget);
      expect(find.text('Bahasa Indonesia Essay Analysis'), findsOneWidget);
      expect(find.text('51.4'), findsOneWidget);

      expect(find.text('#3 LOW PRIORITY'), findsOneWidget);
      expect(find.text('IMPAL LMS Quiz Preparation'), findsOneWidget);
      expect(find.text('28.6'), findsOneWidget);

      // Verify "Inspect XAI Reason" text is removed as requested
      expect(find.text('Inspect XAI Reason'), findsNothing);

      // Verify Notification Bell is present to the left of avatar
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });

    testWidgets('Filter chip narrows down displayed tasks', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));

      await tester.pumpWidget(
        createWidgetForTesting(const SmartPriorityPage()),
      );
      await tester.pumpAndSettle();

      // Tap High (1) filter
      await tester.tap(find.text('High (1)'));
      await tester.pumpAndSettle();

      // Only #1 is visible, #2 and #3 are filtered out
      expect(find.text('AI Major Project - Sprint 2'), findsOneWidget);
      expect(find.text('Bahasa Indonesia Essay Analysis'), findsNothing);
      expect(find.text('IMPAL LMS Quiz Preparation'), findsNothing);
    });

    testWidgets('Tapping a priority card opens DetailCardSmartPriority XAI modal',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));

      await tester.pumpWidget(
        createWidgetForTesting(const SmartPriorityPage()),
      );
      await tester.pumpAndSettle();

      // Tap first task card
      await tester.tap(find.text('AI Major Project - Sprint 2'));
      await tester.pumpAndSettle();

      // Modal bottom sheet should be visible with XAI calculation details
      expect(find.byType(DetailCardSmartPriority), findsOneWidget);
      expect(find.text('1. INPUT PARAMETER FUZZIFICATION'), findsOneWidget);
      expect(find.text('2. CENTROID DEFUZZIFICATION'), findsOneWidget);
      expect(find.text('z* = 87.50'), findsOneWidget);
      expect(find.text('Why is this task Priority #1?'), findsOneWidget);

      // Scroll to Close button using the bottom sheet's scrollable
      await tester.scrollUntilVisible(
        find.text('Close'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Modal dismissed
      expect(find.byType(DetailCardSmartPriority), findsNothing);
    });

    testWidgets('HomePage displays AI Smart Priority Banner', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(userName: 'Yoga Perkasa'),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to reveal banner if needed
      await tester.scrollUntilVisible(
        find.text('AI Smart Priority'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Verify AI Smart Priority Banner in Home
      expect(find.text('AI Smart Priority'), findsOneWidget);
      expect(find.text('Mamdani Active'), findsOneWidget);
      expect(
        find.textContaining('AI Major Project'),
        findsWidgets,
      );
    });

    testWidgets('TaskPage displays Mamdani AI Priority Ranking shortcut',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));

      await tester.pumpWidget(
        const MaterialApp(
          home: TaskPage(userName: 'Yoga Perkasa'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('AI Smart Priority Ranking'),
        findsOneWidget,
      );
      expect(find.text('Mamdani CoG'), findsOneWidget);
    });

    testWidgets('ProfilePage Fuzzy Inference Model tile is interactive',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(userName: 'Yoga Perkasa Didik'),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to reveal Fuzzy tile
      await tester.scrollUntilVisible(
        find.text('Fuzzy Inference Model'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Fuzzy Inference Model'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsWidgets);
    });

    testWidgets(
        'Tapping Mamdani Inference Engine toggles between ACTIVE and INACTIVE',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));

      await tester.pumpWidget(
        createWidgetForTesting(const SmartPriorityPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE'), findsOneWidget);
      expect(SmartPriorityRepository.instance.isEngineActive, isTrue);

      // Tap engine status card to deactivate
      await tester.tap(find.text('Mamdani Inference Engine'));
      await tester.pumpAndSettle();

      expect(find.text('INACTIVE'), findsOneWidget);
      expect(SmartPriorityRepository.instance.isEngineActive, isFalse);
      expect(find.text('Mamdani Engine Inactive'), findsOneWidget);

      // Tap again to reactivate
      await tester.tap(find.text('Mamdani Inference Engine'));
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE'), findsOneWidget);
      expect(SmartPriorityRepository.instance.isEngineActive, isTrue);
      expect(find.text('Mamdani Engine Active'), findsOneWidget);
    });

    testWidgets(
        'Disabling XAI in profile prevents viewing XAI modal in SmartPriorityPage and shows disabled notice',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));

      // Turn OFF XAI explainability
      UserProfileRepository().toggleScoreExplainability(false);
      expect(SmartPriorityRepository.instance.isScoreExplainabilityActive, isFalse);

      await tester.pumpWidget(
        createWidgetForTesting(const SmartPriorityPage()),
      );
      await tester.pumpAndSettle();

      // Tap first task card
      await tester.tap(find.text('AI Major Project - Sprint 2'));
      await tester.pumpAndSettle();

      // Modal should NOT be opened
      expect(find.byType(DetailCardSmartPriority), findsNothing);

      // Warning popup should be displayed
      expect(find.text('XAI Disabled'), findsOneWidget);

      // Turn XAI back ON
      UserProfileRepository().toggleScoreExplainability(true);
      await tester.pumpAndSettle();

      // Tap again
      await tester.tap(find.text('AI Major Project - Sprint 2'));
      await tester.pumpAndSettle();

      // Modal is now displayed
      expect(find.byType(DetailCardSmartPriority), findsOneWidget);
    });
  });
}
