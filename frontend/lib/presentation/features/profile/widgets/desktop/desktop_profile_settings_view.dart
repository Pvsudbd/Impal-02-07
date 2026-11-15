import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/page_transitions.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../../auth/login_page.dart';
import '../../../smart_system/smart_priority_page.dart';
import '../../models/user_profile_model.dart';
import '../daily_briefing_settings_modal.dart';
import '../deadline_alert_settings_modal.dart';
import 'desktop_profile_hero_card.dart';
import 'desktop_profile_modals.dart';
import 'desktop_profile_right_panel.dart';

/// FigCraft `Desktop - Profile & Settings` (`node 5976`, `1440×980`) workspace enriched with mobile features.
class DesktopProfileSettingsView extends StatefulWidget {
  final String searchQuery;
  final String? fallbackUserName;

  const DesktopProfileSettingsView({
    super.key,
    this.searchQuery = '',
    this.fallbackUserName,
  });

  @override
  State<DesktopProfileSettingsView> createState() =>
      _DesktopProfileSettingsViewState();
}

class _DesktopProfileSettingsViewState
    extends State<DesktopProfileSettingsView> {
  final UserProfileRepository _repo = UserProfileRepository();

  @override
  void initState() {
    super.initState();
    if (widget.fallbackUserName != null &&
        widget.fallbackUserName!.trim().isNotEmpty) {
      _repo.init(userName: widget.fallbackUserName);
    }
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

  bool _matchesQuery(String searchableText) {
    final q = widget.searchQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    return searchableText.toLowerCase().contains(q);
  }

  void _openEditProfileModal(UserProfileModel profile) {
    DesktopEditProfileModal.show(
      context,
      profile: profile,
    );
  }

  void _openChangePasswordModal(UserProfileModel profile) {
    DesktopChangePasswordModal.show(
      context,
      email: profile.email,
    );
  }

  void _openTermsModal() {
    DesktopTermsPrivacyModal.show(context);
  }

  void _openCategoryAlertModal(
    UserProfileModel profile,
    AlertCategoryType category,
  ) {
    DeadlineAlertSettingsModal.show(
      context,
      profile: profile,
      category: category,
      onSave: ({
        required bool enabled,
        required List<String> timings,
        required AlertSoundVibrationMode mode,
      }) {
        if (category == AlertCategoryType.taskDeadline) {
          _repo.updateCategoryAlertSettings(
            category: AlertCategoryType.taskDeadline,
            enabled: enabled,
            timings: timings,
            mode: mode,
          );
        }
      },
    );
  }

  void _openDailyBriefingModal(UserProfileModel profile) {
    DailyBriefingSettingsModal.show(
      context,
      profile: profile,
      onSaved: () {
        if (mounted) setState(() {});
      },
    );
  }

  void _openSmartPriority(UserProfileModel profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SmartPriorityPage(userName: profile.fullName),
      ),
    );
  }

  void _handleXaiToggle(bool value) {
    _repo.toggleScoreExplainability(value);
    PopUpPemberitahuan.show(
      context,
      title: value ? 'XAI Enabled' : 'XAI Disabled',
      message: value
          ? 'Explainable AI scoring reasons are now shown across priority cards.'
          : 'Explainable AI pop-up explanations have been turned off.',
      icon: Icons.auto_awesome_rounded,
      iconBgColor: value
          ? PopUpPemberitahuan.positiveColor
          : PopUpPemberitahuan.negativeColor,
    );
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgSidebar,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderSubtle),
          ),
          title: const Text(
            'Sign Out',
            style: TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out from your IMPAL student session?',
            style: TextStyle(color: AppColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
            ElevatedButton(
              key: const Key('desktop_confirm_signout_button'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('auth_user');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      AuthFadeRoute(page: const Login()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _repo.profile;

    final showHero = _matchesQuery(
      'profile hero avatar active student nim ${profile.fullName} ${profile.studentId} ${profile.majorCampus} ${profile.email} ${profile.groupRole} ${profile.bio} edit profile',
    );
    final showStats = _matchesQuery(
      'academic stats bento 28 done 5 pending 6 mk 19 sks 94% on-time semester',
    );
    final showAccount = _matchesQuery(
      'account integration security official email sso terverifikasi change password bcrypt terms privacy policy log out sign out',
    );
    final showReminders = _matchesQuery(
      'reminders schedule task deadlines schedule alerts lecture external team alerts meeting daily briefing time 07:00 wib sound vibration',
    );
    final showIntelligent = _matchesQuery(
      'intelligent system fuzzy inference model mamdani max-min core explainable ai xai pop-up weights deadline proximity bobot sks kompleksitas',
    );
    final showSystemEnv = _matchesQuery(
      'system environment tel-u sso session cas active database sync live postgresql',
    );

    final hasAnyMatch = showHero ||
        showStats ||
        showAccount ||
        showReminders ||
        showIntelligent ||
        showSystemEnv;

    if (!hasAnyMatch) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: EdgeInsets.all(context.rSpacing(24)),
          decoration: BoxDecoration(
            color: AppColors.bgSidebar,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.manage_search_rounded,
                size: context.rIcon(40),
                color: AppColors.textMuted,
              ),
              SizedBox(height: context.rSpacing(12)),
              Text(
                'No matching settings',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: context.rFont(16, min: 14, max: 18),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: context.rSpacing(6)),
              Text(
                'Tidak ditemukan pengaturan untuk kata kunci "${widget.searchQuery}".',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: context.rFont(13, min: 12, max: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final leftColumnWidgets = <Widget>[
      if (showHero)
        DesktopProfileHeroCard(
          profile: profile,
          onEditProfileTap: () => _openEditProfileModal(profile),
        ),
      if (showStats) const DesktopAcademicStatsGrid(),
      if (showAccount)
        DesktopAccountSecurityCard(
          profile: profile,
          onChangePasswordTap: () => _openChangePasswordModal(profile),
          onTermsPrivacyTap: _openTermsModal,
          onLogoutTap: _showLogoutDialog,
        ),
    ];

    final rightPanelWidgets = <Widget>[
      if (showReminders)
        DesktopRemindersScheduleCard(
          profile: profile,
          onOpenCategoryModal: (category) =>
              _openCategoryAlertModal(profile, category),
          onToggleCategory: (category, value) =>
              _repo.toggleCategoryAlert(category, value),
          onOpenDailyBriefingModal: () => _openDailyBriefingModal(profile),
          onToggleDailyBriefing: _repo.toggleDailyBriefing,
          onToggleSoundVibration: _repo.toggleSoundVibration,
        ),
      if (showIntelligent)
        DesktopIntelligentSystemCard(
          profile: profile,
          onOpenSmartPriorityTap: () => _openSmartPriority(profile),
          onToggleXai: _handleXaiToggle,
        ),
      if (showSystemEnv) const DesktopSystemEnvironmentCard(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoColumn = constraints.maxWidth >= 860 &&
            leftColumnWidgets.isNotEmpty &&
            rightPanelWidgets.isNotEmpty;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            context.rSpacing(32),
            context.rSpacing(20),
            context.rSpacing(32),
            context.rSpacing(24),
          ),
          child: isTwoColumn
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SeparatedColumn(
                        gap: context.rSpacing(18),
                        children: leftColumnWidgets,
                      ),
                    ),
                    SizedBox(width: context.rSpacing(24)),
                    SizedBox(
                      width: constraints.maxWidth >= 980 ? 360 : 340,
                      child: _SeparatedColumn(
                        gap: context.rSpacing(18),
                        children: rightPanelWidgets,
                      ),
                    ),
                  ],
                )
              : _SeparatedColumn(
                  gap: context.rSpacing(18),
                  children: [
                    ...leftColumnWidgets,
                    ...rightPanelWidgets,
                  ],
                ),
        );
      },
    );
  }
}

class _SeparatedColumn extends StatelessWidget {
  final double gap;
  final List<Widget> children;

  const _SeparatedColumn({
    required this.gap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}
