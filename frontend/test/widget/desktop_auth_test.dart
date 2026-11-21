import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/auth/forgot_password_page.dart';
import 'package:impal_smart_todolist/presentation/features/auth/login_page.dart';
import 'package:impal_smart_todolist/presentation/features/auth/regist_page.dart';
import 'package:impal_smart_todolist/presentation/features/auth/reset_password_page.dart';
import 'package:impal_smart_todolist/presentation/features/auth/terms_privacy_page.dart';
import 'package:impal_smart_todolist/presentation/features/auth/verification_code_page.dart';
import 'package:impal_smart_todolist/presentation/features/auth/widgets/otp_boxes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> setDesktopViewport(
    WidgetTester tester, {
    Size size = const Size(1440, 980),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('Desktop Split-Screen Auth & Recovery Flow Tests', () {
    testWidgets(
      'Login renders 60/40 Desktop split-screen at 1440x980 and 1024x768 with zero overflow',
      (tester) async {
        await setDesktopViewport(tester, size: const Size(1440, 980));

        await tester.pumpWidget(const MaterialApp(home: Login()));
        await tester.pumpAndSettle();

        expect(find.text('INTELLIGENT DECISION SUPPORT'), findsOneWidget);
        expect(find.textContaining('Prioritization System'), findsWidgets);
        expect(find.text('Fuzzy-AHP Engine'), findsOneWidget);
        expect(
          find.text('IMPAL Group 7 • Telkom University © 2026'),
          findsOneWidget,
        );
        expect(find.text('Authentication page'), findsOneWidget);
        expect(find.text('Remember my account'), findsOneWidget);
        expect(find.text('Sign In to Dashboard'), findsOneWidget);
        expect(
          find.text('Protected by Telkom University Academic Auth'),
          findsOneWidget,
        );
        expect(find.text('v2.4.0'), findsOneWidget);

        // Verify narrow desktop (1024x768) does not overflow
        await setDesktopViewport(tester, size: const Size(1024, 768));
        await tester.pumpAndSettle();
        expect(find.text('Sign In to Dashboard'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Register & onboarding Terms & Privacy use Desktop split-screen shell cleanly',
      (tester) async {
        await setDesktopViewport(tester, size: const Size(1440, 980));

        await tester.pumpWidget(const MaterialApp(home: Login()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Register Now'));
        await tester.pumpAndSettle();

        expect(find.byType(Register), findsOneWidget);
        expect(find.text('Create Account'), findsOneWidget);
        expect(find.text('INTELLIGENT DECISION SUPPORT'), findsOneWidget);
        expect(find.text('Authentication page'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Open onboarding Terms & Privacy from Register checkbox
        await tester.tap(find.text('Terms of Service'));
        await tester.pumpAndSettle();

        expect(find.byType(TermsPrivacyPage), findsOneWidget);
        expect(find.text('INTELLIGENT DECISION SUPPORT'), findsOneWidget);
        expect(find.text('Terms of Service & Privacy'), findsOneWidget);
        expect(find.text('1. Acceptance of Terms'), findsOneWidget);
        expect(find.text('Decline'), findsOneWidget);
        expect(find.text('Accept & Continue'), findsOneWidget);

        // Agree and accept
        await tester.tap(
          find.text(
            'I have read and agree to the Terms of Service & Privacy Policy.',
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Accept & Continue'));
        await tester.pumpAndSettle();

        expect(find.byType(Register), findsOneWidget);
      },
    );

    testWidgets(
      'Complete recovery flow: ForgotPassword -> VerificationCodePage -> ResetPasswordPage -> Login on Desktop',
      (tester) async {
        await setDesktopViewport(tester, size: const Size(1024, 768));

        await tester.pumpWidget(const MaterialApp(home: Login()));
        await tester.pumpAndSettle();

        // 1. Open Forgot Password
        await tester.tap(find.text('Forgot password?'));
        await tester.pumpAndSettle();

        expect(find.byType(ForgotPassword), findsOneWidget);
        expect(find.text('INTELLIGENT DECISION SUPPORT'), findsOneWidget);
        expect(find.text('Forgot Password?'), findsOneWidget);
        expect(find.text('Send to Email'), findsOneWidget);
        expect(find.text('Send 6-Digit Code via SMS'), findsOneWidget);

        await tester.enterText(
          find.byType(TextField).first,
          'yogaperkakas@student.telkomuniversity.ac.id',
        );
        final sendRecoveryBtn = find.text('Send Recovery Code');
        await tester.ensureVisible(sendRecoveryBtn);
        await tester.tap(sendRecoveryBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();

        // 2. Now on VerificationCodePage inside Desktop Split Shell
        expect(find.byType(VerificationCodePage), findsOneWidget);
        expect(find.text('INTELLIGENT DECISION SUPPORT'), findsOneWidget);
        expect(find.text('Enter Verification Code'), findsOneWidget);
        expect(
          find.textContaining('yogaperkakas@student.telkomuniversity.ac.id'),
          findsWidgets,
        );
        expect(find.text('6-Digit OTP Verification Code'), findsOneWidget);
        expect(find.text('Resend Code'), findsOneWidget);

        // Verify all 6 OTP boxes are strictly 1:1 square and uniform in size
        final otpContainers = find.descendant(
          of: find.byType(OtpBoxes),
          matching: find.byType(AnimatedContainer),
        );
        expect(otpContainers, findsNWidgets(6));
        final firstSize = tester.getSize(otpContainers.at(0));
        for (int i = 0; i < 6; i++) {
          final boxSize = tester.getSize(otpContainers.at(i));
          expect(boxSize.width, closeTo(boxSize.height, 0.01));
          expect(boxSize.width, closeTo(firstSize.width, 0.01));
          expect(boxSize.height, closeTo(firstSize.height, 0.01));
        }

        // Enter 6-digit OTP across the 6 OTP boxes
        final otpFields = find.byType(TextField);
        expect(otpFields, findsNWidgets(6));
        for (int i = 0; i < 6; i++) {
          await tester.enterText(otpFields.at(i), '${i + 1}');
        }
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1100));
        await tester.pumpAndSettle();

        // 3. Now on ResetPasswordPage inside Desktop Split Shell
        expect(find.byType(ResetPasswordPage), findsOneWidget);
        expect(find.text('INTELLIGENT DECISION SUPPORT'), findsOneWidget);
        expect(find.text('Reset Your Password'), findsOneWidget);
        expect(find.text('New Password'), findsOneWidget);
        expect(find.text('Confirm New Password'), findsOneWidget);

        final pwdFields = find.byType(TextField);
        expect(pwdFields, findsNWidgets(2));
        await tester.enterText(pwdFields.at(0), 'YogaCerdas#2026!');
        await tester.enterText(pwdFields.at(1), 'YogaCerdas#2026!');
        await tester.pumpAndSettle();

        expect(find.text('Strong (92%)'), findsOneWidget);
        expect(find.text('Match'), findsOneWidget);

        // 4. Save new password -> returns to Login
        final saveBtn = find.text('Save Password & Sign In');
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1800));
        await tester.pumpAndSettle();

        expect(find.byType(Login), findsOneWidget);
        expect(find.text('Sign In to Dashboard'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
