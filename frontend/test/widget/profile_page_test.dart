import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/profile/edit_profile_page.dart';
import 'package:impal_smart_todolist/presentation/features/profile/models/user_profile_model.dart';
import 'package:impal_smart_todolist/presentation/features/profile/profile_page.dart';
import 'package:impal_smart_todolist/presentation/features/profile/widgets/deadline_alert_settings_modal.dart';

void main() {
  group('ProfilePage Widget Tests', () {
    testWidgets(
        'renders Profile & Settings with all sections, stats, XAI, and Account group',
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

      // Check header and titles
      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);

      // Check Profile details: Name and email present, NIM and major removed
      expect(find.text('Yoga Perkasa Didik'), findsOneWidget);
      expect(find.text('NIM: 103072400106'), findsNothing);
      expect(
        find.text('S1 Informatika • Telkom University Surabaya'),
        findsNothing,
      );
      expect(find.text('Kelompok 7 IMPAL (Lead Architect)'), findsNothing);

      // Check 4-column Stats Row
      expect(find.text('28'), findsOneWidget);
      expect(find.text('DONE'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('6 MK'), findsOneWidget);
      expect(find.text('19 SKS'), findsOneWidget);
      expect(find.text('94%'), findsOneWidget);
      expect(find.text('ON-TIME'), findsOneWidget);

      // Check Settings and AI Fuzzy (including XAI and 3 granular alert categories)
      expect(find.text('REMINDERS & SCHEDULE'), findsOneWidget);
      expect(find.text('Task Deadlines'), findsOneWidget);
      expect(find.text('Class Schedule'), findsOneWidget);
      expect(find.text('Team Tasks & Meetings'), findsOneWidget);
      // Verify Daily Morning Briefing is removed as requested
      expect(find.text('Daily Morning Briefing'), findsNothing);
      expect(find.text('INTELLIGENT SYSTEM (AI FUZZY)'), findsOneWidget);
      expect(find.text('Fuzzy Inference Model'), findsOneWidget);
      expect(find.text('Score Explainability (XAI)'), findsOneWidget);

      // Check Account & Integration Section
      expect(find.text('ACCOUNT & INTEGRATION'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Terms & Privacy Policy'), findsOneWidget);

      // Scroll to bottom to view Log Out button and footer
      await tester.scrollUntilVisible(find.text('Log Out Account'), 200);

      // Check Log Out Account button and Footer
      expect(find.text('Log Out Account'), findsOneWidget);
      expect(
        find.text(
          'Todolist Sistem Cerdas v2.0 • Kelompok 7 IMPAL Telkom University',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'EditProfilePage renders form without NIM/Campus/GroupRole and has Email/Bio',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const testProfile = UserProfileModel();

      await tester.pumpWidget(
        const MaterialApp(
          home: EditProfilePage(
            currentProfile: testProfile,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('FULL NAME'), findsOneWidget);

      // Verify NIM, Campus & Major, and Group Role are removed
      expect(find.text('STUDENT ID (NIM)'), findsNothing);
      expect(find.text('MAJOR & CAMPUS'), findsNothing);
      expect(find.text('GROUP ROLE (COURSE PROJECT)'), findsNothing);

      // Verify EMAIL, WhatsApp, and Bio exist
      expect(find.text('EMAIL'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('WHATSAPP / MOBILE NUMBER'), findsOneWidget);
      expect(find.text('STATUS / BIO'), findsOneWidget);

      expect(find.byKey(const ValueKey('save_profile_button')), findsOneWidget);
    });

    testWidgets(
        'Tapping Task Deadlines opens DeadlineAlertSettingsModal and saves preferences',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(userName: 'Yoga Perkasa Didik'),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Task Deadlines tile
      await tester.tap(find.text('Task Deadlines'));
      await tester.pumpAndSettle();

      // Verify modal is open
      expect(find.byType(DeadlineAlertSettingsModal), findsOneWidget);
      expect(find.text('Task Deadlines Alert Settings'), findsOneWidget);
      expect(find.text('1. REMIND ME BEFORE'), findsOneWidget);
      expect(find.text('2. SOUND & VIBRATION MODE'), findsOneWidget);

      // Select Vibration Only mode
      await tester.tap(find.text('Vibration Only'));
      await tester.pumpAndSettle();

      // Tap Save Alert Preferences
      await tester.tap(find.text('Save Alert Preferences'));
      await tester.pumpAndSettle();

      // Modal closed and summary reflects Vibrate Only
      expect(find.byType(DeadlineAlertSettingsModal), findsNothing);
      expect(find.text('H-1, 1 Hour • Vibrate Only'), findsOneWidget);
    });

    testWidgets(
        'DeadlineAlertSettingsModal custom timing can be added, deleted, and Sound Only chosen',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(userName: 'Yoga Perkasa Didik'),
        ),
      );
      await tester.pumpAndSettle();

      // Open modal for Task Deadlines
      await tester.tap(find.text('Task Deadlines'));
      await tester.pumpAndSettle();

      // Verify Sound Only option exists
      expect(find.text('Sound Only'), findsOneWidget);

      // Verify input row has '+ Add'
      expect(find.text('+ Add'), findsOneWidget);

      // Tap '+ Add' to add '2 Hours'
      await tester.tap(find.text('+ Add'));
      await tester.pumpAndSettle();

      // '2 Hours' chip should now exist with delete icon
      expect(find.text('2 Hours'), findsOneWidget);
      expect(find.byKey(const ValueKey('delete_timing_2 Hours')), findsOneWidget);

      // Delete '2 Hours' chip via delete key
      await tester.tap(find.byKey(const ValueKey('delete_timing_2 Hours')));
      await tester.pumpAndSettle();

      // '2 Hours' chip is now removed
      expect(find.text('2 Hours'), findsNothing);

      // Select Sound Only mode
      await tester.tap(find.text('Sound Only'));
      await tester.pumpAndSettle();

      // Save preferences
      await tester.tap(find.text('Save Alert Preferences'));
      await tester.pumpAndSettle();

      // Summary now reflects Sound Only
      expect(find.text('H-1, 1 Hour • Sound Only'), findsOneWidget);
    });

    testWidgets(
        'Class Schedule and Team Tasks & Meetings have independent alert settings',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(userName: 'Yoga Perkasa Didik'),
        ),
      );
      await tester.pumpAndSettle();

      // Open Class Schedule alert settings
      await tester.tap(find.text('Class Schedule'));
      await tester.pumpAndSettle();

      expect(find.text('Class Schedule Alert Settings'), findsOneWidget);

      // Select Sound & Vibration for class
      await tester.tap(find.text('Sound & Vibration'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Alert Preferences'));
      await tester.pumpAndSettle();

      // Open Team Tasks & Meetings alert settings
      await tester.tap(find.text('Team Tasks & Meetings'));
      await tester.pumpAndSettle();

      expect(find.text('Team Tasks & Meetings Alert Settings'), findsOneWidget);

      // Select Silent Notification for team meetings
      await tester.tap(find.text('Silent Notification'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Alert Preferences'));
      await tester.pumpAndSettle();

      // Verify team meeting summary shows Silent
      expect(find.text('1 Hour, 15 Minutes • Silent'), findsOneWidget);
    });
  });
}
