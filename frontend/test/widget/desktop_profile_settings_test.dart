import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impal_smart_todolist/presentation/features/auth/forgot_password_page.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/home_page.dart';
import 'package:impal_smart_todolist/presentation/features/dashboard/widgets/desktop/desktop_sidebar.dart';
import 'package:impal_smart_todolist/presentation/features/profile/models/user_profile_model.dart';
import 'package:impal_smart_todolist/presentation/features/profile/profile_page.dart';
import 'package:impal_smart_todolist/presentation/features/profile/widgets/desktop/desktop_alert_settings_modal.dart';
import 'package:impal_smart_todolist/presentation/features/profile/widgets/desktop/desktop_daily_briefing_modal.dart';
import 'package:impal_smart_todolist/presentation/features/smart_system/smart_priority_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'is_logged_in': true});
    UserProfileRepository().init(userName: 'Yoga Perkasa Didik');
    UserProfileRepository().updateProfile(
      const UserProfileModel(
        fullName: 'Yoga Perkasa Didik',
        studentId: '103072400106',
        majorCampus: 'S1 Informatika • Telkom University Surabaya',
        email: 'yogaperkasa@student.telkomuniversity.ac.id',
        phoneNumber: '+62 812-3456-7890',
        groupRole: 'Kelompok 7 IMPAL (Lead Architect)',
        bio:
            'Informatics Engineering student focused on Flutter & AI systems.',
      ),
    );
  });

  Future<void> setDesktopViewport(
    WidgetTester tester, {
    Size size = const Size(1440, 980),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpDesktopHomeProfile(
    WidgetTester tester, {
    Size size = const Size(1440, 980),
  }) async {
    await setDesktopViewport(tester, size: size);
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(userName: 'Yoga Perkasa Didik'),
      ),
    );
    await tester.pumpAndSettle();

    final settingsNav = find.descendant(
      of: find.byType(DesktopSidebar),
      matching: find.text('Settings'),
    );
    expect(settingsNav, findsNothing);

    final profileBtn = find.byKey(const ValueKey('desktop_sidebar_profile_btn'));
    expect(profileBtn, findsOneWidget);
    await tester.tap(profileBtn);
    await tester.pumpAndSettle();
  }

  group('Desktop Profile & Settings (FigCraft + Mobile Features)', () {
    testWidgets(
      'Renders 1440x980 FigCraft layout via Sidebar Profile Card with zero overflow & no Settings nav',
      (tester) async {
        await pumpDesktopHomeProfile(tester);

        expect(find.byKey(const Key('desktop_profile_settings_view')),
            findsOneWidget);
        expect(find.text('Profile & Settings'), findsOneWidget);
        expect(
          find.text(
            'Manage your student identity, reminders, AI preferences, and account security',
          ),
          findsOneWidget,
        );
        expect(find.text('Search settings...'), findsOneWidget);
        expect(find.text('Edit Profile'), findsOneWidget);

        // Hero card + Verified badge + Bio box (FigCraft node 6285)
        expect(find.text('Yoga Perkasa Didik'), findsWidgets);
        expect(
          find.text('yogaperkasa@student.telkomuniversity.ac.id'),
          findsWidgets,
        );
        expect(find.byKey(const Key('desktop_hero_verified_badge')),
            findsOneWidget);
        expect(find.byKey(const Key('desktop_hero_bio_box')), findsOneWidget);

        // Academic stats bento
        expect(find.text('28'), findsOneWidget);
        expect(find.text('DONE'), findsOneWidget);
        expect(find.text('6 MK'), findsOneWidget);
        expect(find.text('19 SKS'), findsOneWidget);
        expect(find.text('94%'), findsOneWidget);

        // Left & right panel sections (FigCraft node 6285)
        expect(find.text('REMINDERS & SCHEDULE'), findsOneWidget);
        expect(find.text('Task Deadlines'), findsOneWidget);
        expect(find.text('Schedule Alerts'), findsOneWidget);
        expect(find.text('Team Alerts'), findsOneWidget);
        expect(find.text('Daily Morning Briefing'), findsOneWidget);
        expect(find.text('07:00 WIB • All topics • Detailed'), findsOneWidget);
        expect(find.text('INTELLIGENT SYSTEM (AI FUZZY)'), findsOneWidget);
        expect(find.text('Fuzzy Inference Model'), findsOneWidget);
        expect(find.text('Score Explainability (XAI)'), findsOneWidget);
        expect(find.text('ACCOUNT & INTEGRATION'), findsOneWidget);
        expect(
          find.text('Smart Task Manager v2.0 • Team 7 IMPAL Telkom University'),
          findsOneWidget,
        );
        expect(find.text('SYSTEM ENVIRONMENT'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Supports minimized 80dp sidebar and 1024x768 compact desktop without overflow',
      (tester) async {
        await pumpDesktopHomeProfile(tester, size: const Size(1024, 768));

        expect(find.byKey(const Key('desktop_profile_settings_view')),
            findsOneWidget);
        expect(tester.takeException(), isNull);

        // Collapse sidebar to 80dp
        await tester.tap(
          find.byKey(const ValueKey('desktop_sidebar_collapse_btn')),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('desktop_profile_settings_view')),
            findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Direct ProfilePage renders DesktopProfileSettingsView on >= 1024dp',
      (tester) async {
        await setDesktopViewport(tester);
        await tester.pumpWidget(
          const MaterialApp(
            home: ProfilePage(userName: 'Yoga Perkasa Didik'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('desktop_profile_settings_view')),
            findsOneWidget);
        expect(find.text('Profile & Settings'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Sidebar User Profile Card tap navigates directly to Profile & Settings tab',
      (tester) async {
        await setDesktopViewport(tester);
        await tester.pumpWidget(
          const MaterialApp(
            home: HomePage(userName: 'Yoga Perkasa Didik'),
          ),
        );
        await tester.pumpAndSettle();

        final sidebarProfile = find.descendant(
          of: find.byType(DesktopSidebar),
          matching: find.text('Hi Yoga Perkasa Didik'),
        );
        expect(sidebarProfile, findsOneWidget);
        await tester.tap(sidebarProfile);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('desktop_profile_settings_view')),
            findsOneWidget);
        expect(find.text('Profile & Settings'), findsOneWidget);
      },
    );

    testWidgets(
      'Header search filters visible sections and shows empty state cleanly',
      (tester) async {
        await pumpDesktopHomeProfile(tester);

        final searchField = find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.hintText == 'Search settings...',
        );
        expect(searchField, findsOneWidget);

        await tester.enterText(searchField, 'Mamdani');
        await tester.pumpAndSettle();

        expect(find.text('Fuzzy Inference Model'), findsOneWidget);
        expect(find.text('REMINDERS & SCHEDULE'), findsNothing);

        await tester.enterText(searchField, 'zzzz_no_match');
        await tester.pumpAndSettle();

        expect(find.text('No matching settings'), findsOneWidget);

        await tester.enterText(searchField, '');
        await tester.pumpAndSettle();
        expect(find.text('REMINDERS & SCHEDULE'), findsOneWidget);
      },
    );

    testWidgets(
      'Mobile Reminders, Briefing Modal, Sound Toggle, XAI Toast, & SmartPriority nav work',
      (tester) async {
        await pumpDesktopHomeProfile(tester);

        // Open Task Deadlines Desktop modal, add custom timing, choose Sound Only & save
        await tester.ensureVisible(
          find.byKey(const Key('desktop_alert_row_task')),
        );
        await tester.tap(find.byKey(const Key('desktop_alert_row_task')));
        await tester.pumpAndSettle();
        expect(find.byType(DesktopAlertSettingsModal), findsOneWidget);
        expect(find.text('Task Deadlines Settings'), findsOneWidget);
        await tester.tap(
          find.byKey(const ValueKey('desktop_alert_add_timing_btn')),
        );
        await tester.pumpAndSettle();
        expect(find.text('2 Hours'), findsOneWidget);
        final soundOnlyFinder = find.byKey(
          ValueKey(
            'desktop_alert_mode_${AlertSoundVibrationMode.soundOnly.name}',
          ),
        );
        await tester.ensureVisible(soundOnlyFinder);
        await tester.pumpAndSettle();
        await tester.tap(soundOnlyFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('desktop_alert_save_btn')));
        await tester.pumpAndSettle();
        expect(find.byType(DesktopAlertSettingsModal), findsNothing);
        expect(
          UserProfileRepository().profile.taskDeadlineAlerts.soundMode,
          AlertSoundVibrationMode.soundOnly,
        );
        expect(
          UserProfileRepository().profile.taskDeadlineAlerts.timings,
          contains('2 Hours'),
        );

        // Open Schedule Alerts Desktop modal & switch Lecture -> External tab
        await tester.ensureVisible(
          find.byKey(const Key('desktop_alert_row_schedule')),
        );
        await tester.tap(find.byKey(const Key('desktop_alert_row_schedule')));
        await tester.pumpAndSettle();
        expect(find.byType(DesktopAlertSettingsModal), findsOneWidget);
        expect(find.text('Schedule Alerts Settings'), findsOneWidget);
        expect(find.text('Lecture Schedule'), findsOneWidget);
        expect(find.text('External Schedule'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('desktop_alert_subtab_1')));
        await tester.pumpAndSettle();
        expect(find.text('Enable External Schedule Alerts'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('desktop_alert_close_btn')));
        await tester.pumpAndSettle();

        await tester.ensureVisible(
          find.byKey(const Key('desktop_alert_switch_schedule')),
        );
        await tester.tap(
          find.byKey(const Key('desktop_alert_switch_schedule')),
        );
        await tester.pumpAndSettle();

        // Open Team Alerts Desktop modal & switch Team Tasks -> Team Meetings tab
        await tester.ensureVisible(
          find.byKey(const Key('desktop_alert_row_team')),
        );
        await tester.tap(find.byKey(const Key('desktop_alert_row_team')));
        await tester.pumpAndSettle();
        expect(find.byType(DesktopAlertSettingsModal), findsOneWidget);
        expect(find.text('Team Alerts Settings'), findsOneWidget);
        expect(find.text('Team Tasks'), findsOneWidget);
        expect(find.text('Team Meetings'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('desktop_alert_subtab_1')));
        await tester.pumpAndSettle();
        expect(find.text('Enable Team Meetings Alerts'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('desktop_alert_close_btn')));
        await tester.pumpAndSettle();

        // Open Daily Briefing Desktop modal, verify wording, save Compact format & toggle switch
        await tester.ensureVisible(
          find.byKey(const Key('desktop_daily_briefing_row')),
        );
        await tester.tap(find.byKey(const Key('desktop_daily_briefing_row')));
        await tester.pumpAndSettle();
        expect(find.byType(DesktopDailyBriefingModal), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(DesktopDailyBriefingModal),
            matching: find.text('Daily Morning Briefing'),
          ),
          findsOneWidget,
        );
        expect(
          find.text('Customize delivery schedule and included agenda topics'),
          findsOneWidget,
        );
        expect(find.text('BRIEFING DELIVERY TIME'), findsOneWidget);
        expect(find.text('NOTIFICATION DISPLAY FORMAT'), findsOneWidget);
        expect(find.text('INCLUDED BRIEFING TOPICS'), findsOneWidget);

        await tester.tap(
          find.byKey(const ValueKey('desktop_briefing_format_compact')),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('desktop_briefing_save_btn')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DesktopDailyBriefingModal), findsNothing);
        expect(UserProfileRepository().profile.isDailyBriefingCompact, isTrue);

        final beforeBriefing =
            UserProfileRepository().profile.isDailyBriefingEnabled;
        await tester.tap(
          find.byKey(const Key('desktop_daily_briefing_switch')),
        );
        await tester.pumpAndSettle();
        expect(
          UserProfileRepository().profile.isDailyBriefingEnabled,
          !beforeBriefing,
        );

        // Toggle XAI switch + verify toast
        await tester.ensureVisible(find.byKey(const Key('desktop_xai_switch')));
        await tester.tap(find.byKey(const Key('desktop_xai_switch')));
        await tester.pump();
        expect(find.text('XAI Disabled'), findsOneWidget);
        await tester.pump(const Duration(seconds: 4));

        // Navigate to SmartPriorityPage via Fuzzy Inference Model row
        await tester.ensureVisible(
          find.byKey(const Key('desktop_fuzzy_model_row')),
        );
        await tester.tap(find.byKey(const Key('desktop_fuzzy_model_row')));
        await tester.pumpAndSettle();
        expect(find.byType(SmartPriorityPage), findsOneWidget);
      },
    );

    testWidgets(
      'DesktopEditProfileModal supports Camera/Gallery picker, notice banner, & saves to Hero Card',
      (tester) async {
        await pumpDesktopHomeProfile(tester);

        await tester.tap(find.text('Edit Profile'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('desktop_edit_camera_badge')), findsOneWidget);
        expect(
          find.byKey(const Key('desktop_edit_notice_banner')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('desktop_change_photo_button')));
        await tester.pumpAndSettle();

        expect(find.text('Take Photo with Camera'), findsOneWidget);
        expect(find.text('Choose from Gallery'), findsOneWidget);

        await tester.tap(find.text('Take Photo with Camera'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 4));

        await tester.enterText(
          find.byKey(const Key('desktop_edit_fullname_field')),
          'Bima Pratama',
        );
        await tester.enterText(
          find.byKey(const Key('desktop_edit_bio_field')),
          'Updated desktop bio for Smart Task Manager.',
        );

        await tester.tap(find.byKey(const Key('desktop_edit_save_button')));
        await tester.pump();
        await tester.pump(const Duration(seconds: 4));

        expect(find.text('Bima Pratama'), findsWidgets);
        expect(
          find.text('Updated desktop bio for Smart Task Manager.'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DesktopChangePasswordModal shows strength meter, match pill, Forgot? flow, & Terms & Sign Out work',
      (tester) async {
        await pumpDesktopHomeProfile(tester);

        // Open Terms & Privacy Policy Modal
        final termsBtn = find.byKey(const Key('desktop_open_terms_button'));
        await tester.ensureVisible(termsBtn);
        await tester.tap(termsBtn);
        await tester.pumpAndSettle();

        expect(find.text('1. Scope of Academic Productivity'), findsOneWidget);
        expect(find.text('v1.2 Active'), findsOneWidget);
        await tester.tap(find.byKey(const Key('desktop_terms_close_button')));
        await tester.pumpAndSettle();

        // Open Change Password Modal & test strength + match
        final passBtn =
            find.byKey(const Key('desktop_open_change_password_button'));
        await tester.ensureVisible(passBtn);
        await tester.tap(passBtn);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('desktop_password_strength_meter')),
          findsOneWidget,
        );

        await tester.enterText(
          find.byKey(const Key('desktop_current_password_field')),
          'OldPass123!',
        );
        await tester.enterText(
          find.byKey(const Key('desktop_new_password_field')),
          'NewPass123!',
        );
        await tester.enterText(
          find.byKey(const Key('desktop_confirm_password_field')),
          'NewPass123!',
        );
        await tester.pumpAndSettle();

        expect(find.text('Strong'), findsOneWidget);
        expect(find.text('✓ Match'), findsOneWidget);

        await tester.tap(
          find.byKey(const Key('desktop_update_password_button')),
        );
        await tester.pump();
        expect(find.text('Password Updated'), findsOneWidget);
        await tester.pump(const Duration(seconds: 4));

        // Re-open Change Password modal and click Forgot?
        await tester.ensureVisible(passBtn);
        await tester.tap(passBtn);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('desktop_forgot_password_link')));
        await tester.pumpAndSettle();
        expect(find.byType(ForgotPassword), findsOneWidget);
      },
    );

    testWidgets('Log Out Account opens Sign Out confirmation AlertDialog',
        (tester) async {
      await pumpDesktopHomeProfile(tester);

      final logoutBtn = find.byKey(const Key('desktop_profile_logout_button'));
      await tester.ensureVisible(logoutBtn);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      expect(find.text('Sign Out'), findsWidgets);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });
}
