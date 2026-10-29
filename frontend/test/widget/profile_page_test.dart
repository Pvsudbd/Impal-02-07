import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/profile/edit_profile_page.dart';
import 'package:impal_smart_todolist/presentation/features/profile/models/user_profile_model.dart';
import 'package:impal_smart_todolist/presentation/features/profile/profile_page.dart';

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

      // Check Settings and AI Fuzzy (including XAI)
      expect(find.text('REMINDERS & SCHEDULE'), findsOneWidget);
      expect(find.text('Deadline Alerts'), findsOneWidget);
      expect(find.text('Daily Morning Briefing'), findsOneWidget);
      expect(find.text('Sound & Vibration'), findsOneWidget);
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
  });
}
