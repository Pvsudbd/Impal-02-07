import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../models/task_item_model.dart';

/// Interactive expandable Task Card that smoothly animates open/close ("memanjang").
///
/// Features:
/// - Collapsed View: Header title, High/12h badges, team avatars, due date/time, progress ring, tags
/// - Expanded View: Reveals Group Members, Course, Date Created, Centroid Defuzzification, Notice, and Edit Button
/// - 60 FPS HP Kentang: Uses RepaintBoundary, implicit smooth animation, and tabular numbers
class TaskExpandableCard extends StatefulWidget {
  final TaskItemModel task;
  final VoidCallback? onEdit;
  final bool isInitiallyExpanded;

  const TaskExpandableCard({
    super.key,
    required this.task,
    this.onEdit,
    this.isInitiallyExpanded = false,
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

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: disableMotion ? Duration.zero : const Duration(milliseconds: 260),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isExpanded ? AppColors.borderMedium : AppColors.borderSubtle,
            width: _isExpanded ? 1.0 : 0.6,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _toggleExpanded,
          splashColor: Colors.transparent,
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.rSpacing(18),
              vertical: context.rSpacing(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. TOP HEADER: Title & Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: context.rFont(14.5, min: 13, max: 17),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Priority Badge (e.g. High)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: task.priority.badgeBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            task.priority.label,
                            style: TextStyle(
                              color: task.priority.badgeText,
                              fontSize: context.rFont(9.5, min: 8.5, max: 11),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Duration Badge (e.g. 12h)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: task.durationBadgeColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            task.durationBadge,
                            style: TextStyle(
                              color: task.durationTextColor,
                              fontSize: context.rFont(9.5, min: 8.5, max: 11),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // 2. SUBTITLE: Team members or notes
                Text(
                  task.subtitle ?? 'Team members',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: context.rFont(11, min: 10, max: 13),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                // 3. MIDDLE ROW: Avatars, Due Time, and Circular Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Avatars (if present)
                          if (task.memberAvatars.isNotEmpty) ...[
                            _buildAvatarStack(task.memberAvatars),
                            const SizedBox(height: 8),
                          ],

                          // Deadline with Clock Icon
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF7D65),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.access_time_filled_rounded,
                                  size: 11,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  task.formattedDeadline,
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: context.rFont(11, min: 10, max: 13),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Progress Ring
                    if (task.progressPercent != null)
                      _buildProgressRing(context, task.progressPercent!),
                  ],
                ),

                const SizedBox(height: 12),

                // 4. BOTTOM TAGS (e.g. 'Kelompok', 'Code')
                if (task.tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: task.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: tag.backgroundColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tag.label,
                          style: TextStyle(
                            color: tag.textColor,
                            fontSize: context.rFont(9.5, min: 8.5, max: 11),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                // 5. EXPANDED DETAIL SECTION ("card nya memanjang")
                AnimatedCrossFade(
                  duration: disableMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 260),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity, height: 0),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(
                          color: AppColors.borderSubtle,
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 14),

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

                        // Section 2: Course
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
    return SizedBox(
      height: 25,
      width: (25.0 + ((colors.length - 1) * 19.0)).clamp(25.0, 160.0),
      child: Stack(
        children: [
          for (int i = 0; i < colors.length; i++)
            Positioned(
              left: i * 19.0,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.bgCard,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(BuildContext context, int percentage) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF61D2B4),
          width: 3.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$percentage%',
        style: TextStyle(
          color: const Color(0xFF61D2B4),
          fontSize: context.rFont(10, min: 9, max: 12),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
