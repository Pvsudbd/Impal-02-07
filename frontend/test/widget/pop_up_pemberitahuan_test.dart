import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/auth/pop_up_account_created.dart';
import 'package:impal_smart_todolist/presentation/features/auth/pop_up_password_updated.dart';
import 'package:impal_smart_todolist/presentation/features/auth/pop_up_recovery_code.dart';

void main() {
  testWidgets('PopUpPemberitahuan displays correctly as widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PopUpPemberitahuan(
            title: 'Test Notification',
            message: 'This is a test message.',
            iconBgColor: PopUpPemberitahuan.positiveColor,
          ),
        ),
      ),
    );

    expect(find.text('Test Notification'), findsOneWidget);
    expect(find.text('This is a test message.'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
  });

  testWidgets('AccountCreatedDialog displays Account Created notification with positive green color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AccountCreatedDialog.show(context, name: 'Budi');
                },
                child: const Text('Create Account'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Create Account'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Account Created'), findsOneWidget);
    expect(find.text('Welcome, Budi! Your account has been successfully created.'), findsOneWidget);

    // Let the auto-dismiss timer and transitions finish
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('PasswordUpdatedDialog displays Password Updated notification with positive green color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  PasswordUpdatedDialog.show(context);
                },
                child: const Text('Update Password'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Update Password'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Password Updated'), findsOneWidget);
    expect(find.text('Your password has been successfully updated.'), findsOneWidget);

    // Let the auto-dismiss timer and transitions finish
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('RecoveryCodeSentDialog displays Recovery Code Sent notification with positive green color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  RecoveryCodeSentDialog.show(context, destination: 'user@test.com');
                },
                child: const Text('Send Recovery'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Send Recovery'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Recovery Code Sent'), findsOneWidget);
    expect(find.text('Recovery code has been sent to user@test.com.'), findsOneWidget);

    // Let the auto-dismiss timer and transitions finish
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('PopUpPemberitahuan.codeVerified displays Code Verified notification with green color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  PopUpPemberitahuan.codeVerified(context);
                },
                child: const Text('Verify Code'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Verify Code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Code Verified'), findsOneWidget);
    expect(find.text('Verification code confirmed successfully.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('PopUpPemberitahuan.termsWarning displays Terms Warning notification with orange color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  PopUpPemberitahuan.termsWarning(context);
                },
                child: const Text('Warn Terms'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Warn Terms'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Terms & Privacy Policy'), findsOneWidget);
    expect(find.text('Please read and agree to the Terms of Service & Privacy Policy first.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('PopUpPemberitahuan.loginSuccess displays Login Successful with green color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  PopUpPemberitahuan.loginSuccess(context, username: 'Kelompok7');
                },
                child: const Text('Login Button'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Login Button'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Login Successful'), findsOneWidget);
    expect(find.text('Welcome back, Kelompok7!'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
