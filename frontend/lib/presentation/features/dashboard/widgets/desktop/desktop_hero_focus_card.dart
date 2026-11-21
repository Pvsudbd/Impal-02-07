import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../models/dashboard_models.dart';

/// Featured Hero Focus Card matching FigCraft `Hero Focus Card - Clean` (node 1804).
/// Displays top priority badges, featured task title/subtitle, `Continue Task ↗` CTA,
/// overall progress bar, current milestone, and active team member stack.
class DesktopHeroFocusCard extends StatelessWidget {
  final TaskItem featuredTask;
  final String courseLabel;
  final String dueLabel;
  final String currentMilestone;
  final int onlineCount;
  final VoidCallback onContinueTap;

  const DesktopHeroFocusCard({
    super.key,
    required this.featuredTask,
    this.courseLabel = 'IMPAL • UI/UX Studio',
    this.dueLabel = 'Due in 2 days (Sat, 23:59 WIB)',
    this.currentMilestone = 'Payment Flow Prototyping',
    this.onlineCount = 3,
    required this.onContinueTap,
  });

  @override
  Widget build(BuildContext context) {
    final progressValue = (featuredTask.progress ?? 0.46).clamp(0.0, 1.0);
    final progressPercent = (progressValue * 100).round();
    final members = featuredTask.members ??
        const [Color(0xFFF3A683), Color(0xFF786FA6), Color(0xFF63CDDA)];
    final subtitleText = (featuredTask.subtitle != null &&
            featuredTask.subtitle!.trim().isNotEmpty)
        ? featuredTask.subtitle!
        : 'Interactive Prototype & Component Architecture';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top badges row
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _PriorityPill(),
                    _InfoPill(
                      text: courseLabel,
                      textColor: AppColors.textMuted,
                    ),
                  ],
                ),
                _InfoPill(
                  text: dueLabel,
                  textColor: AppColors.primaryAccent,
                  dotColor: AppColors.primaryAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Middle headline + CTA row (stacks cleanly on ultra-narrow split panes)
          LayoutBuilder(
            builder: (context, constraints) {
              final headline = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    featuredTask.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(20, min: 18, max: 22),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: context.rFont(13, min: 12, max: 14),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );

              final continueBtn = Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  key: const ValueKey('desktop_hero_continue_btn'),
                  onTap: onContinueTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: Text(
                      'Continue Task ↗',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(13, min: 12, max: 14),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );

              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headline,
                    const SizedBox(height: 12),
                    continueBtn,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: headline),
                  const SizedBox(width: 16),
                  continueBtn,
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Hairline divider
          const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 16),

          // Bottom 3-column summary row (wraps cleanly on narrower desktop panes)
          LayoutBuilder(
            builder: (context, constraints) {
              final progressCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Overall Progress',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$progressPercent%',
                        style: const TextStyle(
                          color: AppColors.mintAccent,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 6,
                      backgroundColor: AppColors.bgPrimary,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.mintAccent,
                      ),
                    ),
                  ),
                ],
              );

              final milestoneCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Milestone',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          currentMilestone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );

              final teamCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Team Members',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _MiniAvatarStack(colors: members),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$onlineCount Online',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.mintAccent,
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );

              if (constraints.maxWidth < 480) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    progressCol,
                    const SizedBox(height: 12),
                    milestoneCol,
                    const SizedBox(height: 12),
                    teamCol,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: progressCol),
                  const SizedBox(width: 24),
                  Expanded(child: milestoneCol),
                  const SizedBox(width: 24),
                  Expanded(child: teamCol),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'HIGH PRIORITY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color? dotColor;

  const _InfoPill({
    required this.text,
    required this.textColor,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAvatarStack extends StatelessWidget {
  final List<Color> colors;

  const _MiniAvatarStack({required this.colors});

  @override
  Widget build(BuildContext context) {
    final visible = colors.take(3).toList();
    const initialLabels = ['JS', 'AK', 'MR'];
    final stackWidth = visible.isEmpty ? 0.0 : 22.0 + (visible.length - 1) * 16.0;

    return SizedBox(
      width: stackWidth,
      height: 22,
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * 16.0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: visible[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgCard, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  initialLabels[i % initialLabels.length],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 7.5,
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
}

