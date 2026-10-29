import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/home_header.dart';
import 'package:impal_smart_todolist/presentation/features/notifikasi/models/notification_model.dart';
import 'package:impal_smart_todolist/presentation/features/notifikasi/models/notification_repository.dart';
import 'package:impal_smart_todolist/presentation/features/notifikasi/notifikasi_page.dart';
import 'package:impal_smart_todolist/presentation/features/notifikasi/widgets/notification_card.dart';

void main() {
  setUp(() {
    NotificationRepository.instance.reset();
  });

  Widget createWidgetForTesting(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('Notifikasi & Bell Tests', () {
    testWidgets('HomeHeader renders notification bell with unread badge to the left of avatar',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        createWidgetForTesting(
          const HomeHeader(userName: 'Yoga Perkasa'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify bell icon is present
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // Verify unread count badge shows '3'
      expect(find.text('3'), findsOneWidget);

      // Verify profile initials are also present
      expect(find.text('YO'), findsOneWidget);
    });

    testWidgets('NotifikasiPage renders header, banner, and compact cards in English',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));

      await tester.pumpWidget(
        createWidgetForTesting(const NotifikasiPage()),
      );
      await tester.pumpAndSettle();

      // Verify English Header
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('3 New'), findsOneWidget);
      expect(find.text('Mark Read'), findsOneWidget);

      // Verify Scheduler Banner
      expect(
        find.textContaining('Background Scheduler Active'),
        findsOneWidget,
      );

      // Verify Filter chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Deadlines'), findsOneWidget);
      expect(find.text('Classes'), findsOneWidget);

      // Verify Date Groups
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('YESTERDAY'), findsOneWidget);

      // Verify Notification titles in English
      expect(
        find.text('Submission: SKPL Document & Group 7 Model Diagram'),
        findsOneWidget,
      );

      // Verify initially compact state shows "Details"
      expect(find.text('Details'), findsWidgets);
    });

    testWidgets('Tapping NotificationCard expands it, reveals full description and action button',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));

      final sampleNotif = NotificationModel(
        id: 'test-1',
        category: NotificationCategory.deadline,
        categoryLabel: 'UBXCCB2 • IMPAL',
        statusTag: 'Due in 4 Hours',
        statusTagColor: const Color(0xFFFF7D65),
        title: 'Submission: SKPL Document & Group 7 Model Diagram',
        description: 'Submission deadline on Telkom University LMS portal closes tonight at 23:59 WIB.',
        timestamp: '12m ago • 09:15 WIB',
        dateGroup: 'TODAY',
        dateFormatted: 'Saturday, Oct 24, 2026',
        actionLabel: 'View Task →',
        actionType: NotificationActionType.viewTask,
        accentColor: const Color(0xFFFF5E4D),
        icon: Icons.warning_amber_rounded,
        isRead: false,
      );

      await tester.pumpWidget(
        createWidgetForTesting(
          NotificationCard(notification: sampleNotif),
        ),
      );
      await tester.pumpAndSettle();

      // In compact state, action button "View Task →" is not visible
      expect(find.text('View Task →'), findsNothing);
      expect(find.text('Details'), findsOneWidget);

      // Tap card to expand
      await tester.tap(find.byType(NotificationCard));
      await tester.pumpAndSettle();

      // Now action button "View Task →" and description should appear
      expect(find.text('View Task →'), findsOneWidget);
      expect(
        find.text('Submission deadline on Telkom University LMS portal closes tonight at 23:59 WIB.'),
        findsOneWidget,
      );
    });

    testWidgets('Tapping Mark Read marks all as read and updates unread badge',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1000));

      await tester.pumpWidget(
        createWidgetForTesting(const NotifikasiPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('3 New'), findsOneWidget);

      // Tap Mark Read
      await tester.tap(find.text('Mark Read'));
      await tester.pumpAndSettle();

      // Badge '3 New' disappears
      expect(find.text('3 New'), findsNothing);
      expect(NotificationRepository.instance.unreadCount, 0);
    });
  });
}

