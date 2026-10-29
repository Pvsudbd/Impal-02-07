import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../models/task_item_model.dart';

/// Expandable Task Card based directly on the signature HomeTaskCard design.
///
/// Features:
/// - Exact visual styling of HomeTaskCard: 16dp radius, card shadow, Stack layout
///   with top-right due badge, avatar stack, circular/linear progress, and soft tags.
/// - Expandable Behavior ("card nya memanjang"): Tapping the card smoothly reveals
///   the full task details (Group Members, Course, Date Created, Centroid Defuzzification,
///   assignment notice, and Edit button).
/// - 60 FPS HP Kentang: RepaintBoundary, implicit smooth animations, and tabular numbers.
class TaskExpandableCard extends StatefulWidget {
  final TaskItemModel task;
  final VoidCallback? onEdit;
  final bool isInitiallyExpanded;
  final bool isLast;

  const TaskExpandableCard({
    super.key,
    required this.task,
    this.onEdit,
    this.isInitiallyExpanded = false,
    this.isLast = false,
  });

  @override
  State<TaskExpandableCard> createState() => _TaskExpandableCardState();
}

class _TaskExpandableCardState extends State<TaskExpandableCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final disableMotion = MediaQuery.disableAnimationsOf(context);

    final isGroup = task.memberAvatars.isNotEmpty ||
        task.tags.any((t) => t.label.toLowerCase() == 'kelompok');
    final double? effectiveProgress = task.progressPercent != null
        ? (task.progressPercent! / 100.0)
        : (isGroup ? 0.46 : null);

    final isUrgent = task.priority == TaskPriorityLevel.high;

    return RepaintBoundary(
      child: AnimatedContainer(
        width: double.infinity,
        duration: disableMotion ? Duration.zero : const Duration(milliseconds: 260),
        curve: Curves.easeInOutCubic,
        margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isExpanded ? AppColors.borderMedium : AppColors.borderSubtle,
            width: _isExpanded ? 1.0 : 0.6,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _toggleExpanded,
          splashColor: Colors.transparent,
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. COLLAPSED VIEW (Exact HomeTaskCard Structure)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Ensure the Stack spans the full width of the card container
                    const SizedBox(width: double.infinity),

                    // Left Column: Title, Subtitle, Team members, Deadline, Tags
                    Padding(
                      padding: EdgeInsets.only(
                        right: (isGroup && effectiveProgress != null) ? 120 : 108,
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

                          // Team members section (for group tasks)
                          if (isGroup && task.memberAvatars.isNotEmpty) ...[
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
                            _buildAvatarStack(task.memberAvatars),
                          ],

                          // Linear progress bar for non-group tasks (if specified)
                          if (!isGroup && effectiveProgress != null) ...[
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
                                  '${(effectiveProgress * 100).toInt()}%',
                                  style: TextStyle(
                                    color: isUrgent
                                        ? const Color(0xFFFF826E)
                                        : const Color(0xFF55E6C1),
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
                                value: effectiveProgress,
                                minHeight: 4,
                                backgroundColor: const Color(0xFF232834),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isUrgent
                                      ? const Color(0xFFFF826E)
                                      : const Color(0xFF55E6C1),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 6),

                          // Deadline info with circular clock icon
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF826E),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.access_time_filled_rounded,
                                  size: 9.5,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  task.formattedDeadline,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Tags Row
                          if (task.tags.isNotEmpty)
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: task.tags.map(_buildTag).toList(),
                            ),
                        ],
                      ),
                    ),

                    // Top-right Badges (Priority pill + Duration pill)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPriorityBadge(task.priority),
                          const SizedBox(width: 4),
                          _buildDurationBadge(task),
                        ],
                      ),
                    ),

                    // Center-right Circular Progress Indicator for group tasks
                    if (isGroup && effectiveProgress != null)
                      Positioned(
                        right: 0,
                        bottom: 8,
                        child: _buildCircularProgress(
                          effectiveProgress,
                          isUrgent: isUrgent,
                        ),
                      ),
                  ],
                ),

                // 2. EXPANDED DETAIL SECTION ("card nya memanjang")
                AnimatedCrossFade(
                  duration: disableMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 260),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity, height: 0),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Section 1: Group Member
                        Text(
                          'Group Member',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: context.rFont(12, min: 11, max: 14),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.20,
                          ),
                        ),
                        const SizedBox(height: 6),
                        for (final member in task.groupMembers)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '• $member',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: context.rFont(13, min: 11, max: 15),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.25,
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Section 2: Course (Only visible for college tasks)
                        if (task.isCollegeTask && task.course.trim().isNotEmpty) ...[
                          Text(
                            'Course',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: context.rFont(12, min: 11, max: 14),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.course,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: context.rFont(13, min: 11, max: 15),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Section 3: Date Created
                        Text(
                          'Date Created',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: context.rFont(12, min: 11, max: 14),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.dateCreated,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: context.rFont(13, min: 11, max: 15),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Section 4: Centeroid Defuzzyfication
                        Text(
                          'Centeroid Defuzzyfication',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: context.rFont(12, min: 11, max: 14),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              task.centroidDefuzzification,
                              style: TextStyle(
                                color: const Color(0xFF6EE7B7),
                                fontSize: context.rFont(14, min: 12, max: 16),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              task.centroidScale,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: context.rFont(12, min: 11, max: 14),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Section 5: Notice / Warning
                        Text(
                          task.warningNotice,
                          style: TextStyle(
                            color: const Color(0xFFEB6161),
                            fontSize: context.rFont(12.5, min: 11, max: 14),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Section 6: Action Button "Edit"
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            key: ValueKey('edit_task_button_${task.id}'),
                            onPressed: widget.onEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.rFont(15, min: 13, max: 17),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    final progressColor =
        isUrgent ? const Color(0xFFFF826E) : const Color(0xFF55E6C1);

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

  Widget _buildTag(TaskTagModel tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tag.backgroundColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tag.label,
        style: TextStyle(
          color: tag.backgroundColor,
          fontSize: 10.5,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(TaskPriorityLevel priority) {
    Color bg;
    Color textColor;
    String label;

    switch (priority) {
      case TaskPriorityLevel.high:
        bg = AppColors.primary;
        textColor = Colors.white;
        label = 'High';
        break;
      case TaskPriorityLevel.medium:
        bg = const Color(0xFFFBBF24);
        textColor = const Color(0xFF1F2937);
        label = 'Medium';
        break;
      case TaskPriorityLevel.low:
        bg = const Color(0xFF6EE7B7);
        textColor = const Color(0xFF064E3B);
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10.5,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildDurationBadge(TaskItemModel task) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: task.durationBadgeColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        task.durationBadge,
        style: TextStyle(
          color: task.durationTextColor,
          fontSize: 10.5,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
