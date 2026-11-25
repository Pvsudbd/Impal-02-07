import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/page_transitions.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../../core/widgets/desktop_slide_drawer_pane.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../../auth/login_page.dart';
import '../../../notifikasi/models/notification_repository.dart';
import '../../../smart_system/smart_priority_page.dart';
import '../../../task/models/task_repository.dart';
import '../../../team/models/team_repository.dart';
import '../../../team/models/team_task_repository.dart';
import '../../../../../core/services/reminder_notification_service.dart';
import '../../models/user_profile_model.dart';
import 'desktop_alert_settings_modal.dart';
import 'desktop_daily_briefing_modal.dart';
import 'desktop_profile_hero_card.dart';
import 'desktop_profile_modals.dart';
import 'desktop_profile_right_panel.dart';

enum _DesktopProfileDrawerKind {
  none,
  taskAlerts,
  scheduleAlerts,
  teamAlerts,
  dailyBriefing,
  termsPrivacy,
}

/// FigCraft `Desktop - Profile & Settings` (`node 5976`, `1440×980`) workspace enriched with mobile features.
class DesktopProfileSettingsView extends StatefulWidget {
  final String searchQuery;
  final String? fallbackUserName;
  final VoidCallback? onOpenSmartPriority;

  const DesktopProfileSettingsView({
    super.key,
    this.searchQuery = '',
    this.fallbackUserName,
    this.onOpenSmartPriority,
  });

  @override
  State<DesktopProfileSettingsView> createState() =>
      _DesktopProfileSettingsViewState();
}

class _DesktopProfileSettingsViewState
    extends State<DesktopProfileSettingsView> {
  final UserProfileRepository _repo = UserProfileRepository();
  _DesktopProfileDrawerKind _activeDrawer = _DesktopProfileDrawerKind.none;
  _DesktopProfileDrawerKind _lastDrawer = _DesktopProfileDrawerKind.none;

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

  void _toggleDrawer(_DesktopProfileDrawerKind kind) {
    setState(() {
      if (_activeDrawer == kind) {
        _activeDrawer = _DesktopProfileDrawerKind.none;
      } else {
        _activeDrawer = kind;
        _lastDrawer = kind;
      }
    });
  }

  void _closeDrawer() {
    if (mounted && _activeDrawer != _DesktopProfileDrawerKind.none) {
      setState(() => _activeDrawer = _DesktopProfileDrawerKind.none);
    }
  }

  void _openTermsModal() {
    _toggleDrawer(_DesktopProfileDrawerKind.termsPrivacy);
  }

  void _openCategoryAlertModal(
    UserProfileModel profile,
    AlertCategoryType category,
  ) {
    switch (category) {
      case AlertCategoryType.taskDeadline:
        _toggleDrawer(_DesktopProfileDrawerKind.taskAlerts);
      case AlertCategoryType.schedule:
      case AlertCategoryType.classSchedule:
        _toggleDrawer(_DesktopProfileDrawerKind.scheduleAlerts);
      case AlertCategoryType.team:
      case AlertCategoryType.teamMeeting:
        _toggleDrawer(_DesktopProfileDrawerKind.teamAlerts);
    }
  }

  void _openDailyBriefingModal(UserProfileModel profile) {
    _toggleDrawer(_DesktopProfileDrawerKind.dailyBriefing);
  }

  Widget _buildDrawerPanel(UserProfileModel profile) {
    final effectiveKind = _activeDrawer != _DesktopProfileDrawerKind.none
        ? _activeDrawer
        : _lastDrawer;

    switch (effectiveKind) {
      case _DesktopProfileDrawerKind.taskAlerts:
        return DesktopAlertSettingsModal(
          key: const ValueKey('desktop_profile_drawer_task_alerts'),
          profile: profile,
          category: AlertCategoryType.taskDeadline,
          embeddedPanel: true,
          onClose: _closeDrawer,
        );
      case _DesktopProfileDrawerKind.scheduleAlerts:
        return DesktopAlertSettingsModal(
          key: const ValueKey('desktop_profile_drawer_schedule_alerts'),
          profile: profile,
          category: AlertCategoryType.schedule,
          embeddedPanel: true,
          onClose: _closeDrawer,
        );
      case _DesktopProfileDrawerKind.teamAlerts:
        return DesktopAlertSettingsModal(
          key: const ValueKey('desktop_profile_drawer_team_alerts'),
          profile: profile,
          category: AlertCategoryType.team,
          embeddedPanel: true,
          onClose: _closeDrawer,
        );
      case _DesktopProfileDrawerKind.dailyBriefing:
        return DesktopDailyBriefingModal(
          key: const ValueKey('desktop_profile_drawer_daily_briefing'),
          profile: profile,
          embeddedPanel: true,
          onClose: _closeDrawer,
          onSaved: () {
            if (mounted) setState(() {});
          },
        );
      case _DesktopProfileDrawerKind.termsPrivacy:
      case _DesktopProfileDrawerKind.none:
        return DesktopTermsPrivacyModal(
          key: const ValueKey('desktop_profile_drawer_terms_privacy'),
          embeddedPanel: true,
          onClose: _closeDrawer,
        );
    }
  }

  void _openSmartPriority(UserProfileModel profile) {
    if (widget.onOpenSmartPriority != null) {
      widget.onOpenSmartPriority!();
      return;
    }
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
    await prefs.remove('auth_token');
    await prefs.remove('jwt_token');
    await prefs.remove('auth_user');
    TeamRepository().clear();
    TaskRepository().clear();
    TeamTaskRepository().clear();
    await UserProfileRepository().resetForLogout();
    await NotificationRepository.instance.clearForLogout();
    await ReminderNotificationService().stopAndReset();
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
      'profile hero avatar active student ${profile.fullName} ${profile.email} ${profile.bio} edit profile',
    );
    final showStats = _matchesQuery(
      'academic stats bento 28 done 5 pending 6 mk 19 sks 94% on-time',
    );
    final showIntelligent = _matchesQuery(
      'intelligent system fuzzy inference model mamdani min-max centroid defuzzification score explainability xai active',
    );
    final showReminders = _matchesQuery(
      'reminders schedule task deadlines schedule alerts lecture external team alerts meeting daily morning briefing 07:00 wib',
    );
    final showAccount = _matchesQuery(
      'account integration security email change password bcrypt terms privacy policy academic agreement mamdani disclaimer log out sign out smart task manager',
    );

    final hasAnyMatch = showHero ||
        showStats ||
        showIntelligent ||
        showReminders ||
        showAccount;

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
                'No settings found matching "${widget.searchQuery}".',
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
      if (showIntelligent)
        DesktopIntelligentSystemCard(
          profile: profile,
          onOpenSmartPriorityTap: () => _openSmartPriority(profile),
          onToggleXai: _handleXaiToggle,
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
        ),
      if (showAccount)
        DesktopAccountSecurityCard(
          profile: profile,
          onChangePasswordTap: () => _openChangePasswordModal(profile),
          onTermsPrivacyTap: _openTermsModal,
          onLogoutTap: _showLogoutDialog,
        ),
    ];

    return DesktopSlideDrawerPane(
      isOpen: _activeDrawer != _DesktopProfileDrawerKind.none,
      content: LayoutBuilder(
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
                          gap: context.rSpacing(16),
                          children: leftColumnWidgets,
                        ),
                      ),
                      SizedBox(width: context.rSpacing(24)),
                      Expanded(
                        child: _SeparatedColumn(
                          gap: context.rSpacing(16),
                          children: rightPanelWidgets,
                        ),
                      ),
                    ],
                  )
                : _SeparatedColumn(
                    gap: context.rSpacing(16),
                    children: [
                      ...leftColumnWidgets,
                      ...rightPanelWidgets,
                    ],
                  ),
          );
        },
      ),
      drawer: _buildDrawerPanel(profile),
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
