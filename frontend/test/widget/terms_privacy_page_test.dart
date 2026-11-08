import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/auth/forgot_password_page.dart';
import 'package:impal_smart_todolist/presentation/features/auth/terms_privacy_page.dart';
import 'package:impal_smart_todolist/presentation/features/profile/profile_page.dart';

void main() {
  group('TermsPrivacyPage Widget Tests', () {
    testWidgets('renders register mode with close button, checkbox, and action buttons',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: TermsPrivacyPage(isFromRegister: true),
        ),
      );
      await tester.pumpAndSettle();

      // Check header bar
      expect(find.text('Terms & Privacy'), findsOneWidget);
      expect(find.text('v1.2 Active'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);

      // Check main title & sections
      expect(find.text('Terms of Service & Privacy'), findsOneWidget);
      expect(find.text('1. Acceptance of Terms'), findsOneWidget);
      expect(find.text('2. AI-Driven Recommendation Core'), findsOneWidget);
      expect(find.textContaining('Academic Advisory Note'), findsOneWidget);

      // Scroll down to check actions
      await tester.scrollUntilVisible(find.text('Decline'), 300);

      expect(
        find.text(
          'I have read and agree to the Terms of Service & Privacy Policy.',
        ),
        findsOneWidget,
      );
      expect(find.text('Decline'), findsOneWidget);
      expect(find.text('Accept & Continue'), findsOneWidget);
    });

    testWidgets('renders profile mode with back button and NO checkbox or action buttons',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: TermsPrivacyPage(isFromRegister: false),
        ),
      );
      await tester.pumpAndSettle();

      // Check header bar
      expect(find.text('Terms & Privacy'), findsOneWidget);
      expect(find.text('v1.2 Active'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      // Check main title & sections
      expect(find.text('Terms of Service & Privacy'), findsOneWidget);
      expect(find.text('1. Acceptance of Terms'), findsOneWidget);

      // Verify checkbox and actions are NOT present
      expect(
        find.text(
          'I have read and agree to the Terms of Service & Privacy Policy.',
        ),
        findsNothing,
      );
      expect(find.text('Decline'), findsNothing);
      expect(find.text('Accept & Continue'), findsNothing);
    });

    testWidgets('ProfilePage Change Password bottom sheet directs to ForgotPassword with pre-filled email',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(
            userName: 'Yoga Perkasa Didik',
            isStandalone: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Change Password
      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();

      // Verify modal appeared
      expect(find.text('Continue to Reset Password'), findsOneWidget);

      // Tap Continue to Reset Password
      await tester.tap(find.text('Continue to Reset Password'));
      await tester.pumpAndSettle();

      // Verify ForgotPassword page is opened with pre-filled email
      expect(find.byType(ForgotPassword), findsOneWidget);
      expect(
        find.text('yogaperkasa@student.telkomuniversity.ac.id'),
        findsOneWidget,
      );

      // Tap Send Recovery Code on ForgotPassword page
      await tester.tap(find.text('Send Recovery Code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Verify notification appeared stating code has been sent
      expect(find.text('Recovery Code Sent'), findsOneWidget);
    });
  });
}
