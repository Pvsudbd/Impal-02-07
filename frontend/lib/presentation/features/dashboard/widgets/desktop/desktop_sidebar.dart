import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';

/// Destination identifiers for the desktop left navigation rail.
enum DesktopNavDestination {
  dashboard,
  schedule,
  tasks,
  teamMembers,
}

/// Collapsible left navigation sidebar matching FigCraft
/// `Desktop - Homepage Dashboard` (260dp) and `Desktop - Minimized Sidebar` (80dp).
class DesktopSidebar extends StatelessWidget {
  final DesktopNavDestination? activeDestination;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final ValueChanged<DesktopNavDestination> onDestinationSelected;
  final String userName;
  final int scheduleCount;
  final int pendingTaskCount;
  final int teamCount;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  const DesktopSidebar({
    super.key,
    this.activeDestination,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.onDestinationSelected,
    required this.userName,
    this.scheduleCount = 1,
    this.pendingTaskCount = 10,
    this.teamCount = 4,
    required this.onProfileTap,
    required this.onLogoutTap,
  });

  String get _initials {
    final trimmed = userName.trim();
    if (trimmed.length >= 2) {
      return trimmed.substring(0, 2).toUpperCase();
    }
    return trimmed.isNotEmpty ? trimmed.toUpperCase() : 'JS';
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion = context.animationsDisabled;
    final targetWidth = isCollapsed ? 80.0 : 260.0;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: disableMotion
            ? Duration.zero
            : const Duration(milliseconds: 220),
        curve: Curves.easeInOutCubic,
        width: targetWidth,
        decoration: const BoxDecoration(
          color: AppColors.bgSidebar,
          border: Border(
            right: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Switch internal layout based on actual animated width to avoid mid-transition overflow.
            final showCompact = constraints.maxWidth < 180.0;

            return SafeArea(
              right: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: showCompact ? 16 : 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: showCompact
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.stretch,
                  children: [
                    _buildBrandSection(context, showCompact),
                    SizedBox(height: context.rSpacing(22)),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: showCompact
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.stretch,
                          children: [
                            _NavItem(
                              icon: Icons.dashboard_rounded,
                              label: 'Dashboard',
                              isActive: activeDestination ==
                                  DesktopNavDestination.dashboard,
                              isCompact: showCompact,
                              onTap: () => onDestinationSelected(
                                DesktopNavDestination.dashboard,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _NavItem(
                              icon: Icons.calendar_today_outlined,
                              label: 'Schedule',
                              badgeText: '$scheduleCount',
                              badgeBg: AppColors.primary,
                              badgeTextColor: Colors.white,
                              isActive: activeDestination ==
                                  DesktopNavDestination.schedule,
                              isCompact: showCompact,
                              onTap: () => onDestinationSelected(
                                DesktopNavDestination.schedule,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _NavItem(
                              icon: Icons.check_box_outlined,
                              label: 'Tasks',
                              badgeText: '$pendingTaskCount',
                              badgeBg: AppColors.skyBadge,
                              badgeTextColor: AppColors.skyBadgeText,
                              isActive: activeDestination ==
                                  DesktopNavDestination.tasks,
                              isCompact: showCompact,
                              onTap: () => onDestinationSelected(
                                DesktopNavDestination.tasks,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _NavItem(
                              icon: Icons.people_outline_rounded,
                              label: 'Team Members',
                              badgeText: '$teamCount',
                              badgeBg: AppColors.primary,
                              badgeTextColor: Colors.white,
                              isActive: activeDestination ==
                                  DesktopNavDestination.teamMembers,
                              isCompact: showCompact,
                              onTap: () => onDestinationSelected(
                                DesktopNavDestination.teamMembers,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildUserProfileFooter(context, showCompact),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context, bool showCompact) {
    final logoBox = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: context.rFont(14, min: 13, max: 16),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
    );

    final collapseButton = Tooltip(
      message: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
      child: InkWell(
        key: const ValueKey('desktop_sidebar_collapse_btn'),
        onTap: onToggleCollapse,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
              ),
              alignment: Alignment.center,
              child: Icon(
                isCollapsed
                    ? Icons.keyboard_double_arrow_right_rounded
                    : Icons.keyboard_double_arrow_left_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );

    if (showCompact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoBox,
          const SizedBox(height: 16),
          collapseButton,
        ],
      );
    }

    return Row(
      children: [
        logoBox,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${userName}Hub',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(15, min: 14, max: 17),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Task & Study Hub',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: context.rFont(11, min: 10, max: 12),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        collapseButton,
      ],
    );
  }

  Widget _buildUserProfileFooter(BuildContext context, bool showCompact) {
    final avatar = Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: context.rFont(13, min: 12, max: 15),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final isProfileActive = activeDestination == null;

    if (showCompact) {
      return Tooltip(
        message: 'Hi $userName ($pendingTaskCount tasks pending)',
        child: InkWell(
          key: const ValueKey('desktop_sidebar_profile_btn'),
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Container(
              decoration: isProfileActive
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryAccent,
                        width: 2,
                      ),
                    )
                  : null,
              child: Center(child: avatar),
            ),
          ),
        ),
      );
    }

    return Material(
      color: isProfileActive
          ? AppColors.primary.withValues(alpha: 0.12)
          : AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: const ValueKey('desktop_sidebar_profile_btn'),
        onTap: onProfileTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isProfileActive
                  ? AppColors.primaryAccent
                  : AppColors.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              avatar,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hi $userName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(13, min: 12, max: 14.5),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$pendingTaskCount tasks pending',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryAccent,
                        fontSize: context.rFont(11, min: 10, max: 12),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: 'Sign Out',
                child: InkWell(
                  onTap: onLogoutTap,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.logout_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badgeText;
  final Color? badgeBg;
  final Color? badgeTextColor;
  final bool isActive;
  final bool isCompact;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.badgeText,
    this.badgeBg,
    this.badgeTextColor,
    required this.isActive,
    required this.isCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = isActive ? AppColors.primary : AppColors.textMuted;

    final content = Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: isCompact
          ? const EdgeInsets.all(12)
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isActive ? AppColors.bgCard : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.borderSubtle : Colors.transparent,
          width: 1,
        ),
      ),
      child: isCompact
          ? Center(
              child: Icon(icon, size: 18, color: fgColor),
            )
          : Row(
              children: [
                Icon(icon, size: 18, color: fgColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fgColor,
                      fontSize: context.rFont(13, min: 12, max: 14.5),
                      fontFamily: 'Inter',
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (badgeText != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg ?? AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badgeText!,
                      style: TextStyle(
                        color: badgeTextColor ?? Colors.white,
                        fontSize: 11,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );

    final wrapped = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: AppColors.bgCard.withValues(alpha: 0.55),
        child: content,
      ),
    );

    return isCompact ? Tooltip(message: label, child: wrapped) : wrapped;
  }
}

