import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/profile/edit_profile_page.dart';
import 'package:impal_smart_todolist/presentation/features/profile/models/user_profile_model.dart';
import 'package:impal_smart_todolist/presentation/features/profile/profile_page.dart';

void main() {
  group('ProfilePage Widget Tests', () {
    testWidgets('renders Profile & Settings with all sections and stats',
        (tester) async {
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

      // Check Profile details
      expect(find.text('Yoga Perkasa Didik'), findsOneWidget);
      expect(find.text('NIM: 103072400106'), findsOneWidget);
      expect(find.text('ACTIVE STUDENT'), findsOneWidget);

      // Check 4-column Stats Row
      expect(find.text('28'), findsOneWidget);
      expect(find.text('DONE'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('6 MK'), findsOneWidget);
      expect(find.text('19 SKS'), findsOneWidget);
      expect(find.text('94%'), findsOneWidget);
      expect(find.text('ON-TIME'), findsOneWidget);

      // Check Settings and AI Fuzzy
      expect(find.text('REMINDERS & SCHEDULE'), findsOneWidget);
      expect(find.text('Deadline Alerts'), findsOneWidget);
      expect(find.text('Daily Morning Briefing'), findsOneWidget);
      expect(find.text('Sound & Vibration'), findsOneWidget);
      expect(find.text('INTELLIGENT SYSTEM (AI FUZZY)'), findsOneWidget);
      expect(find.text('Fuzzy Inference Model'), findsOneWidget);
    });

    testWidgets('EditProfilePage renders form with pre-populated fields and save action',
        (tester) async {
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
      expect(find.text('STUDENT ID (NIM)'), findsOneWidget);
      expect(find.text('MAJOR & CAMPUS'), findsOneWidget);
      expect(find.text('OFFICIAL CAMPUS EMAIL'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('WHATSAPP / MOBILE NUMBER'), findsOneWidget);
      expect(find.text('GROUP ROLE (COURSE PROJECT)'), findsOneWidget);
      expect(find.text('STATUS / BIO'), findsOneWidget);

      expect(find.byKey(const ValueKey('save_profile_button')), findsOneWidget);
    });
  });
}
