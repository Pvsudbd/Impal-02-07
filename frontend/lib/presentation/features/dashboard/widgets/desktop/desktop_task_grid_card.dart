import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../models/dashboard_models.dart';

/// Desktop task grid card matching FigCraft `Card_Task_Dashboard` (node 1848).
/// Pure UI component with top-right pinned due badge, team avatars or subtitle,
/// circular progress ring, deadline timestamp, and tag pills.
class DesktopTaskGridCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onTap;
  final String? priorityLabel;
  final Color? priorityBgColor;
  final Color? priorityTextColor;

  const DesktopTaskGridCard({
    super.key,
    required this.task,
    required this.onTap,
    this.priorityLabel,
    this.priorityBgColor,
    this.priorityTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final isGroup = task.isTeamTask;
    final hasMembers = task.members != null && task.members!.isNotEmpty;
    final progressValue = task.progress;
    final ringColor = (progressValue ?? 0) >= 0.65
        ? const Color(0xFF5B93FF)
        : AppColors.mintAccent;
    final hasPriorityBadge =
        priorityLabel != null && priorityLabel!.trim().isNotEmpty;

    return RepaintBoundary(
      child: Material(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          hoverColor: Colors.white.withValues(alpha: 0.03),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: context.rSpacing(18),
              vertical: context.rSpacing(16),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: task.isCompleted
                    ? AppColors.statusCompleted.withValues(alpha: 0.45)
                    : AppColors.borderSubtle,
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title + top-right pinned badges (anti-clustering stack)
                Stack(
                  children: [
                    const SizedBox(width: double.infinity),
                    Padding(
                      padding: EdgeInsets.only(
                        right: hasPriorityBadge ? 128 : 68,
                      ),
                      child: Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: task.isCompleted
                              ? AppColors.textMuted
                              : Colors.white,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppColors.textMuted,
                          fontSize: context.rFont(14.5, min: 13.5, max: 16),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasPriorityBadge) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: priorityBgColor ?? AppColors.priorityHighBg,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                priorityLabel!,
                                style: TextStyle(
                                  color: priorityTextColor ??
                                      AppColors.priorityHighText,
                                  fontSize: 10,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: task.dueColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              task.dueBadge,
                              style: TextStyle(
                                color: task.dueTextColor,
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Subtitle or Team members label
                Text(
                  isGroup
                      ? 'Team members'
                      : (task.subtitle ?? 'Personal task'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: context.rFont(11, min: 10, max: 12),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // Middle content + optional circular progress ring
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isGroup && hasMembers) ...[
                            _AvatarCluster(colors: task.members!),
                            const SizedBox(height: 10),
                          ] else
                            const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 15,
                                height: 15,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryAccent,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.access_time_filled_rounded,
                                  size: 9.5,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  task.deadline,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (progressValue != null) ...[
                      const SizedBox(width: 12),
                      _CircularProgressBadge(
                        progress: progressValue,
                        ringColor: ringColor,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Bottom tags
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final tag in task.tags)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tag.bg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tag.label,
                          style: TextStyle(
                            color: tag.text,
                            fontSize: 10,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarCluster extends StatelessWidget {
  final List<Color> colors;

  const _AvatarCluster({required this.colors});

  @override
  Widget build(BuildContext context) {
    final visible = colors.take(5).toList();
    final width = visible.isEmpty ? 0.0 : 25.0 + (visible.length - 1) * 18.0;

    return SizedBox(
      width: width,
      height: 25,
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * 18.0,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: visible[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgCard, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircularProgressBadge extends StatelessWidget {
  final double progress;
  final Color ringColor;

  const _CircularProgressBadge({
    required this.progress,
    required this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final pct = (clamped * 100).round();

    return SizedBox(
      width: 48,
      height: 48,
      child: CustomPaint(
        painter: _ProgressRingPainter(
          progress: clamped,
          trackColor: const Color(0xFF3C4354),
          progressColor: ringColor,
        ),
        child: Center(
          child: Text(
            '$pct%',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ringColor,
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  const _ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

