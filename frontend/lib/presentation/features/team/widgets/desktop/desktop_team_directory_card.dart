import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../models/desktop_team_directory_models.dart';

/// Team directory card matching FigCraft `Card Kelompok - *` (nodes 5432, 5465, 5494, 5520).
/// Exact geometry: 210dp fixed height, #323846 fill, 1dp #3B4150 border, 16dp radius,
/// padding [16, 18, 16, 18], overlapping initial avatars, task progress bar, and footer actions.
class DesktopTeamDirectoryCard extends StatelessWidget {
  final DesktopTeamCardData team;
  final VoidCallback onOpenTap;

  const DesktopTeamDirectoryCard({
    super.key,
    required this.team,
    required this.onOpenTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('desktop_team_card_${team.id}'),
      height: 210,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Card Top: Title + Badge + Course Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      team.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(15, min: 14, max: 16.5),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: team.badgeBgColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      team.badgeLabel,
                      style: TextStyle(
                        color: team.badgeTextColor,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                team.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: context.rFont(11, min: 10, max: 12),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          // 2. Members Row: Count label + overlapping initial avatars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Team members (${team.members.length}):',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: context.rFont(11, min: 10, max: 12),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              _buildAvatarStack(team.members),
            ],
          ),

          // 3. Progress Column: Completed count + percentage + 6dp bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${team.completedTasks}/${team.totalTasks} Tasks Completed',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: context.rFont(11, min: 10, max: 12),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    '${team.progressPercent}%',
                    style: TextStyle(
                      color: team.percentTextColor,
                      fontSize: context.rFont(11, min: 10, max: 12),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: team.progressRatio,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: team.progressColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 4. Card Footer: Invite code chip + Action button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Code:',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      team.inviteCode,
                      style: const TextStyle(
                        color: AppColors.primaryAccent,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              _buildActionButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack(List<TeamMemberAvatar> members) {
    const double avatarSize = 26.0;
    const double step = 20.0; // -6dp overlap matching FigCraft
    final visibleMembers = members.take(5).toList();
    if (visibleMembers.isEmpty) return const SizedBox.shrink();

    final totalWidth = avatarSize + (visibleMembers.length - 1) * step;

    return SizedBox(
      width: totalWidth,
      height: avatarSize,
      child: Stack(
        children: [
          for (int i = 0; i < visibleMembers.length; i++)
            Positioned(
              left: i * step,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: visibleMembers[i].bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgCard, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  visibleMembers[i].initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (team.isPrimaryAction) {
      return Material(
        color: AppColors.primaryAccent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          key: ValueKey('desktop_team_open_${team.id}'),
          onTap: onOpenTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Open Workspace',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: AppColors.bgPrimary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        key: ValueKey('desktop_team_open_${team.id}'),
        onTap: onOpenTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          alignment: Alignment.center,
          child: const Text(
            'View Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
