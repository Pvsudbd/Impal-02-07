import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/profile/edit_profile_page.dart';
import 'package:impal_smart_todolist/presentation/features/profile/models/user_profile_model.dart';
import 'package:impal_smart_todolist/presentation/features/profile/profile_page.dart';
import 'package:impal_smart_todolist/presentation/features/profile/widgets/daily_briefing_settings_modal.dart';
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

      // Check Settings and AI Fuzzy (including XAI and alert categories + Daily Morning Briefing)
      expect(find.text('REMINDERS & SCHEDULE'), findsOneWidget);
      expect(find.text('Task Deadlines'), findsOneWidget);
      expect(find.text('Schedule Alerts'), findsOneWidget);
      expect(find.text('Team Alerts'), findsOneWidget);
      expect(find.text('Daily Morning Briefing'), findsOneWidget);
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
      expect(find.text('REMIND ME BEFORE'), findsOneWidget);
      expect(find.text('SOUND & VIBRATION MODE'), findsOneWidget);

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
        'Schedule Alerts and Team Alerts have segmented sub-tabs and independent configurations',
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

      // Open Schedule Alerts settings
      await tester.tap(find.text('Schedule Alerts'));
      await tester.pumpAndSettle();

      expect(find.text('Schedule Alerts Settings'), findsOneWidget);
      expect(find.text('Lecture Schedule'), findsWidgets);
      expect(find.text('External Schedule'), findsOneWidget);

      // Tap External Schedule tab
      await tester.tap(find.text('External Schedule'));
      await tester.pumpAndSettle();

      // Select Sound Only for External Schedule
      await tester.tap(find.text('Sound Only'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Alert Preferences'));
      await tester.pumpAndSettle();

      // Open Team Alerts settings
      await tester.tap(find.text('Team Alerts'));
      await tester.pumpAndSettle();

      expect(find.text('Team Alerts Settings'), findsOneWidget);
      expect(find.text('Team Tasks'), findsWidgets);
      expect(find.text('Team Meetings'), findsOneWidget);

      // Select Silent for Team Tasks
      await tester.tap(find.text('Silent'));
      await tester.pumpAndSettle();

      // Tap Team Meetings tab
      await tester.tap(find.text('Team Meetings'));
      await tester.pumpAndSettle();

      // Select Sound & Vibration for Team Meetings
      await tester.tap(find.text('Sound & Vibration'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Alert Preferences'));
      await tester.pumpAndSettle();

      // Verify team summary reflects new independent configs
      expect(find.textContaining('Tasks: H-1 (Silent) • Meetings: 1 Hour (Sound & Vibrate)'), findsOneWidget);
    });

    testWidgets(
        'DailyBriefingSettingsModal opens, configures topics, and updates briefing settings',
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

      // Open Daily Morning Briefing settings
      await tester.tap(find.text('Daily Morning Briefing'));
      await tester.pumpAndSettle();

      expect(find.byType(DailyBriefingSettingsModal), findsOneWidget);
      expect(find.text('BRIEFING DELIVERY TIME'), findsOneWidget);
      expect(find.text('NOTIFICATION DISPLAY FORMAT'), findsOneWidget);
      expect(find.text('INCLUDED BRIEFING TOPICS'), findsOneWidget);
      expect(find.text('Change Time'), findsOneWidget);
      expect(find.text('Detailed Agenda (Recommended)'), findsOneWidget);
      expect(find.text('Compact Summary'), findsOneWidget);

      // Verify all 5 topics are displayed
      expect(find.text('Personal Tasks'), findsOneWidget);
      expect(find.text('Lecture Schedule'), findsOneWidget);
      expect(find.text('External Schedule'), findsOneWidget);
      expect(find.text('Team Tasks'), findsOneWidget);
      expect(find.text('Team Meetings'), findsOneWidget);

      // Tap Compact Summary format
      await tester.tap(find.text('Compact Summary'));
      await tester.pumpAndSettle();

      // Toggle off Team Meetings
      await tester.tap(find.text('Team Meetings'));
      await tester.pumpAndSettle();

      // Save preferences
      await tester.tap(find.text('Save Briefing Preferences'));
      await tester.pumpAndSettle();

      expect(find.byType(DailyBriefingSettingsModal), findsNothing);
      // Summary updates with Compact format reflected
      expect(find.textContaining('07:00 WIB'), findsOneWidget);
      expect(find.textContaining('Compact'), findsOneWidget);
    });

    test('AlertSoundVibrationMode has verified intuitive icon mappings', () {
      expect(AlertSoundVibrationMode.soundAndVibrate.icon, Icons.notifications_active_rounded);
      expect(AlertSoundVibrationMode.soundOnly.icon, Icons.volume_up_rounded);
      expect(AlertSoundVibrationMode.vibrationOnly.icon, Icons.vibration_rounded);
      expect(AlertSoundVibrationMode.silent.icon, Icons.notifications_off_outlined);
    });
  });
}
