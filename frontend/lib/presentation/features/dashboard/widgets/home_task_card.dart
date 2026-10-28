import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/dashboard_models.dart';

/// Task card component for ongoing tasks on dashboard.
class HomeTaskCard extends StatelessWidget {
  final TaskItem task;
  final bool isLast;

  const HomeTaskCard({
    super.key,
    required this.task,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isGroup = (task.members != null && task.members!.isNotEmpty) ||
        task.tags.any((t) => t.label.toLowerCase() == 'kelompok');
    final effectiveProgress = task.progress ?? (isGroup ? 0.46 : null);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Left Column: Title, Subtitle, Team members, Deadline, Tags
            Padding(
              padding: EdgeInsets.only(
                right: (isGroup && effectiveProgress != null) ? 56 : 46,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),

                  // Subtitle if available
                  if (task.subtitle != null && task.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.5,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  // Team members section (only for group tasks)
                  if (isGroup && task.members != null && task.members!.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    const Text(
                      'Team members',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildAvatarStack(task.members!),
                  ],

                  // Linear progress bar for non-group tasks (if specified)
                  if (!isGroup && task.progress != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progress',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(task.progress! * 100).toInt()}%',
                          style: TextStyle(
                            color: task.isUrgent ? const Color(0xFFFF826E) : const Color(0xFF55E6C1),
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: task.progress,
                        minHeight: 4,
                        backgroundColor: const Color(0xFF232834),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          task.isUrgent ? const Color(0xFFFF826E) : const Color(0xFF55E6C1),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 6),

                  // Deadline info
                  Text(
                    task.deadline,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tags Row
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: task.tags.map(_buildTag).toList(),
                  ),
                ],
              ),
            ),

            // Top-right Due Badge
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: task.dueColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task.dueBadge,
                  style: TextStyle(
                    color: task.dueTextColor,
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),

            // Center-right Circular Progress Indicator for group tasks
            if (isGroup && effectiveProgress != null)
              Positioned(
                right: 0,
                bottom: 8,
                child: _buildCircularProgress(
                  effectiveProgress,
                  isUrgent: task.isUrgent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack(List<Color> colors) {
    const double size = 22.0;
    const double overlap = 14.0;
    final displayColors = colors.take(4).toList();
    final extraCount = colors.length - displayColors.length;

    return SizedBox(
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < displayColors.length; i++)
            Positioned(
              left: i * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: displayColors[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgCard, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_rounded,
                  size: 11.5,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: displayColors.length * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFF434A59),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgCard, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extraCount',
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

  Widget _buildCircularProgress(double progress, {bool isUrgent = false}) {
    final percent = (progress * 100).toInt();
    final progressColor = isUrgent
        ? const Color(0xFFFF826E)
        : const Color(0xFF55E6C1);

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3.6,
              strokeCap: StrokeCap.round,
              backgroundColor: const Color(0xFF232834),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              semanticsLabel: 'Task progress: $percent%',
            ),
          ),
          Text(
            '$percent%',
            style: TextStyle(
              color: progressColor,
              fontSize: 11.5,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(TaskTag tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tag.bg.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tag.label,
        style: TextStyle(
          color: tag.bg,
          fontSize: 10.5,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
