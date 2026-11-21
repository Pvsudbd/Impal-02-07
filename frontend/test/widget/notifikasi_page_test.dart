import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_top_header.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/home_header.dart';
import 'package:impal_smart_todolist/presentation/features/notifikasi/models/notification_model.dart';
import 'package:impal_smart_todolist/presentation/features/notifikasi/models/notification_repository.dart';
import 'package:impal_smart_todolist/presentation/features/notifikasi/notifikasi_page.dart';
import 'package:impal_smart_todolist/presentation/features/notifikasi/widgets/desktop_notification_popover.dart';
import 'package:impal_smart_todolist/presentation/features/notifikasi/widgets/notification_bell_button.dart';
import 'package:impal_smart_todolist/presentation/features/notifikasi/widgets/notification_card.dart';
import 'package:impal_smart_todolist/presentation/features/team/widgets/team_dashboard_header.dart';

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

    testWidgets('TeamDashboardHeader renders notification bell to the left of avatar',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        createWidgetForTesting(
          const TeamDashboardHeader(
            userName: 'Yoga Perkasa',
            teamName: 'Kelompok - IMPAL',
            teamCode: '7X29',
            memberColors: [Colors.blue],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('YP'), findsOneWidget);
    });

    testWidgets(
      'Desktop NotificationBellButton opens anchored top-right scrollable popover and supports Mark Read & action dialogs',
      (tester) async {
        await tester.binding.setSurfaceSize(null);
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          createWidgetForTesting(
            DesktopTopHeader(
              searchQuery: '',
              onSearchChanged: (_) {},
              onAddTaskTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        final bellFinder = find.byType(NotificationBellButton);
        expect(bellFinder, findsOneWidget);
        final bellRect = tester.getRect(bellFinder);

        await tester.tap(bellFinder);
        await tester.pumpAndSettle();

        expect(find.byType(NotifikasiPage), findsNothing);
        final popoverFinder = find.byType(DesktopNotificationPopover);
        expect(popoverFinder, findsOneWidget);

        // Must be positioned below the bell in the top-right, NOT centered
        final popoverRect = tester.getRect(popoverFinder);
        expect(popoverRect.top, greaterThanOrEqualTo(bellRect.bottom));
        expect(popoverRect.right, greaterThan(1000.0));

        // Full notification content + scrollable container present
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('3 New'), findsOneWidget);
        expect(
          find.textContaining('Background Scheduler Active'),
          findsOneWidget,
        );
        expect(find.byType(Scrollbar), findsOneWidget);

        // Mark Read works directly inside the popover
        await tester.tap(find.byKey(const ValueKey('desktop_notif_mark_read_btn')));
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
        expect(NotificationRepository.instance.unreadCount, 0);

        // Scroll down to notif-4 inside the popover, expand it, and tap 'AI Reason (XAI)' -> opens centered Dialog
        final notif4 = find.byKey(const ValueKey('notif-4'));
        await tester.scrollUntilVisible(
          notif4,
          180.0,
          scrollable: find
              .descendant(of: popoverFinder, matching: find.byType(Scrollable))
              .last,
        );
        await tester.pumpAndSettle();
        await tester.tap(notif4);
        await tester.pumpAndSettle();

        await tester.drag(
          find
              .descendant(of: popoverFinder, matching: find.byType(Scrollable))
              .last,
          const Offset(0, -160),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('AI Reason (XAI)'));
        await tester.pumpAndSettle();

        expect(find.byType(DesktopNotificationPopover), findsNothing);
        expect(find.text('AI Fuzzy Reason (XAI)'), findsOneWidget);
        expect(find.byType(Dialog), findsOneWidget);

        await tester.tap(find.text('Understood'));
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);

        // Re-open popover and dismiss by tapping outside on the left side
        await tester.tap(bellFinder);
        await tester.pumpAndSettle();
        expect(find.byType(DesktopNotificationPopover), findsOneWidget);

        await tester.tapAt(const Offset(100, 300));
        await tester.pumpAndSettle();
        expect(find.byType(DesktopNotificationPopover), findsNothing);
      },
    );
  });
}

