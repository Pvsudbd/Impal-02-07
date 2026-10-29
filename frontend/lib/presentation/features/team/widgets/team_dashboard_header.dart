import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../notifikasi/widgets/notification_bell_button.dart';
import '../../profile/profile_page.dart';

/// Top header and team info bar for the team dashboard screen.
class TeamDashboardHeader extends StatelessWidget {
  final String userName;
  final String teamName;
  final String teamCode;
  final List<Color> memberColors;
  final bool showBackButton;
  final VoidCallback? onBack;

  const TeamDashboardHeader({
    super.key,
    required this.userName,
    required this.teamName,
    required this.teamCode,
    required this.memberColors,
    this.showBackButton = true,
    this.onBack,
  });

  String _getUserInitials(String name) {
    if (name.trim().isEmpty) return 'JS';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Future<void> _copyTeamCode(BuildContext context) async {
    HapticFeedback.lightImpact();
    PopUpPemberitahuan.codeCopied(context, code: teamCode);
    try {
      await Clipboard.setData(ClipboardData(text: teamCode));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getUserInitials(userName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top greeting bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (showBackButton) ...[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onBack ?? () => Navigator.of(context).maybePop(),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderSubtle, width: 1),
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
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hi $userName',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Team Dashboard',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.primaryAccent,
                            fontSize: 12.5,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Notification Bell Button (placed to the left of the profile avatar)
            const NotificationBellButton(),
            const SizedBox(width: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(userName: userName),
                    ),
                  );
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderSubtle, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13.5,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 2. Team Info Bar (Name, Overlapping Avatars, Copy Code)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      teamName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.04,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Overlapping avatar circles with person silhouettes
                    SizedBox(
                      height: 28,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          for (int i = 0; i < memberColors.length; i++)
                            Positioned(
                              left: i * 20.0,
                              child: _buildAvatarCircle(memberColors[i], size: 28),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Team Code Button (Tap to copy + show notification)
              GestureDetector(
                key: const ValueKey('team_dashboard_copy_code_button'),
                behavior: HitTestBehavior.opaque,
                onTap: () => _copyTeamCode(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.copy_rounded,
                        color: AppColors.primary,
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        teamCode,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarCircle(Color bgColor, {double size = 28}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.bgPrimary,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: size * 0.60,
          color: Colors.white.withValues(alpha: 0.95),
        ),
      ),
    );
  }
}
