import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../auth/forgot_password_page.dart';
import '../auth/login_page.dart';
import '../auth/terms_privacy_page.dart';
import '../dashboard/home_page.dart';
import '../smart_system/smart_priority_page.dart';
import 'edit_profile_page.dart';
import 'models/user_profile_model.dart';
import 'widgets/profile_account_integration_group.dart';
import 'widgets/profile_fuzzy_card.dart';
import 'widgets/profile_hero_card.dart';
import 'widgets/profile_settings_group.dart';
import 'widgets/profile_stats_row.dart';

// Aliases for backwards compatibility with Figma exports
typedef Profile = ProfilePage;
typedef ProfileSettingsPage = ProfilePage;

/// Full Profile & Settings screen.
///
/// Features:
/// - Academic Profile Hero Card (Avatar, Verified Badge, Name, NIM, Tel-U details)
/// - 4-Column Academic Statistics Row (Done, Pending, MK/SKS, On-Time rate)
/// - Reminders & Schedule grouped settings (Deadline alerts, briefing time, sound)
/// - Intelligent System (AI Fuzzy Inference status)
/// - Sign Out confirmation action
class ProfilePage extends StatefulWidget {
  final String userName;
  final bool isStandalone;
  final VoidCallback? onBack;

  const ProfilePage({
    super.key,
    this.userName = 'Yoga Perkasa Didik',
    this.isStandalone = true,
    this.onBack,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserProfileRepository _repo = UserProfileRepository();

  @override
  void initState() {
    super.initState();
    _repo.init(userName: widget.userName);
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.of(context).push<UserProfileModel>(
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          currentProfile: _repo.profile,
          onProfileSaved: (p) => _repo.updateProfile(p),
        ),
      ),
    );

    if (updated != null && mounted) {
      _repo.updateProfile(updated);
    }
  }

  void _showChangePasswordModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(20),
            vertical: context.rSpacing(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF38BDF8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(18, min: 16, max: 20),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'To change your password, you will be redirected to the secure verification and password reset flow for your registered account (${_repo.profile.email}).',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: context.rFont(13, min: 11.5, max: 14),
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ForgotPassword(
                          initialEmail: _repo.profile.email,
                        ),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Continue to Reset Password',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              await prefs.remove('auth_user');
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  AuthFadeRoute(page: const Login()),
                );
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _repo.profile;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final scrollContent = CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            context.rSpacing(20),
            context.rSpacing(14),
            context.rSpacing(20),
            context.rSpacing(96),
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Top Bar: Back button, Title, Edit action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Profile & Settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(18, min: 16, max: 22),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _openEditProfile,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.primaryAccent,
                          fontSize: context.rFont(14, min: 12.5, max: 16),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.rSpacing(16)),

              // 2. Profile Hero Card
              ProfileHeroCard(profile: profile),
              SizedBox(height: context.rSpacing(14)),

              // 3. Stats Row (Done, Pending, MK/SKS, On-time)
              ProfileStatsRow(profile: profile),
              SizedBox(height: context.rSpacing(20)),

              // 4. Reminders & Alerts Group (Unified Master Alert Setting)
              ProfileSettingsGroup(
                profile: profile,
                onToggleDeadlineAlerts: (val) =>
                    _repo.toggleDeadlineAlerts(val),
                onSaveAlertSettings: (
                    {required enabled, required timings, required mode}) {
                  _repo.updateDeadlineAlertSettings(
                    enabled: enabled,
                    timings: timings,
                    mode: mode,
                  );
                },
              ),
              SizedBox(height: context.rSpacing(18)),

              // 5. Intelligent System AI Fuzzy Card
              ProfileFuzzyCard(
                isActive: profile.isFuzzyModelActive,
                isScoreExplainabilityActive: profile.scoreExplainabilityEnabled,
                onToggleScoreExplainability: (val) {
                  _repo.toggleScoreExplainability(val);
                  if (val) {
                    PopUpPemberitahuan.show(
                      context,
                      title: 'XAI Enabled',
                      message:
                          'Score Explainability is active. You can now inspect mathematical calculations.',
                      icon: Icons.lightbulb_rounded,
                      iconBgColor: PopUpPemberitahuan.positiveColor,
                    );
                  } else {
                    PopUpPemberitahuan.show(
                      context,
                      title: 'XAI Disabled',
                      message:
                          'Score Explainability is disabled. Mathematical calculations are now hidden.',
                      icon: Icons.lightbulb_outline_rounded,
                      iconBgColor: PopUpPemberitahuan.negativeColor,
                    );
                  }
                },
                onFuzzyModelTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SmartPriorityPage(userName: profile.fullName),
                    ),
                  );
                },
              ),
              SizedBox(height: context.rSpacing(18)),

              // 6. Account & Integration Section
              ProfileAccountIntegrationGroup(
                email: profile.email,
                onChangePassword: () => _showChangePasswordModal(context),
                onTermsPrivacy: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TermsPrivacyPage(),
                    ),
                  );
                },
              ),
              SizedBox(height: context.rSpacing(22)),

              // 7. Log Out Account Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFFA6144),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor:
                        const Color(0xFFFA6144).withValues(alpha: 0.08),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        size: 19,
                        color: Color(0xFFFA6144),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Log Out Account',
                        style: TextStyle(
                          color: const Color(0xFFFA6144),
                          fontSize: context.rFont(14, min: 12.5, max: 15.5),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.rSpacing(14)),

              // 8. Footer Branding Text
              Text(
                'Todolist Sistem Cerdas v2.0 • Kelompok 7 IMPAL Telkom University',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: context.rFont(10.5, min: 9.5, max: 12),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: context.rSpacing(110)),
            ]),
          ),
        ),
      ],
    );

    final scaffoldContent = Stack(
      children: [
        scrollContent,
        if (widget.isStandalone)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ImpalBottomNavBar(
              currentTab: 0,
              onTabSelected: (index) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => HomePage(
                      userName: profile.fullName,
                      initialTab: index,
                    ),
                  ),
                  (route) => false,
                );
              },
            ),
          ),
      ],
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(top: true, bottom: false, child: scaffoldContent),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E222B),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 410, maxHeight: 844),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x8C000000),
                      blurRadius: 40,
                      offset: Offset(0, 20),
                    ),
                  ],
                ),
                child: scaffoldContent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
