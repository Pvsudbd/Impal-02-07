import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../models/dashboard_models.dart';

/// Desktop task grid card matching FigCraft `Card_Task_Dashboard` (node 1848).
/// Pure UI component with top-right pinned due badge, expandable mobile-parity
/// detail rows, completion action & swipe-to-complete, circular progress ring,
/// deadline timestamp, and tag pills.
class DesktopTaskGridCard extends StatefulWidget {
  final TaskItem task;
  final VoidCallback onTap;
  final String? priorityLabel;
  final Color? priorityBgColor;
  final Color? priorityTextColor;
  final VoidCallback? onToggleComplete;
  final bool initiallyExpanded;

  const DesktopTaskGridCard({
    super.key,
    required this.task,
    required this.onTap,
    this.priorityLabel,
    this.priorityBgColor,
    this.priorityTextColor,
    this.onToggleComplete,
    this.initiallyExpanded = false,
  });

  @override
  State<DesktopTaskGridCard> createState() => _DesktopTaskGridCardState();
}

class _DesktopTaskGridCardState extends State<DesktopTaskGridCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  String get _stableId =>
      widget.task.id.isNotEmpty ? widget.task.id : widget.task.title;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isGroup = task.isTeamTask;
    final isParentTeamProject = isGroup && !task.id.startsWith('team_task_');
    final hasMembers = task.members != null && task.members!.isNotEmpty;
    final progressValue = task.progress;
    final ringColor = (progressValue ?? 0) >= 0.65
        ? const Color(0xFF5B93FF)
        : AppColors.mintAccent;
    final hasPriorityBadge =
        widget.priorityLabel != null && widget.priorityLabel!.trim().isNotEmpty;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final double titleRightPadding =
        (hasPriorityBadge ? 154.0 : 94.0) + (!task.isAlertEnabled ? 18.0 : 0.0);

    final cardContent = RepaintBoundary(
      child: Material(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: widget.onTap,
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
            child: AnimatedSize(
              duration: disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title + top-right pinned badges (anti-clustering stack)
                  Stack(
                    children: [
                      const SizedBox(width: double.infinity),
                      Padding(
                        padding: EdgeInsets.only(right: titleRightPadding),
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
                            if (!task.isAlertEnabled)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Tooltip(
                                  message: 'Notifications muted',
                                  child: Icon(
                                    Icons.notifications_off_outlined,
                                    size: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            if (hasPriorityBadge) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.priorityBgColor ??
                                      AppColors.priorityHighBg,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  widget.priorityLabel!,
                                  style: TextStyle(
                                    color: widget.priorityTextColor ??
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
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Tooltip(
                              message:
                                  _isExpanded ? 'Hide details' : 'Show details',
                              child: InkWell(
                                key: ValueKey('desktop_task_expand_$_stableId'),
                                onTap: () =>
                                    setState(() => _isExpanded = !_isExpanded),
                                borderRadius: BorderRadius.circular(999),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: AppColors.textMuted,
                                  ),
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

                  // Bottom tags + optional quick complete action
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Wrap(
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
                      ),
                      if (widget.onToggleComplete != null) ...[
                        const SizedBox(width: 8),
                        Tooltip(
                          message: task.isCompleted
                              ? 'Reopen task'
                              : (isParentTeamProject
                                  ? 'Complete in Team Workspace'
                                  : 'Mark as completed'),
                          child: InkWell(
                            key: ValueKey(
                              'desktop_task_quick_complete_$_stableId',
                            ),
                            onTap: () {
                              if (isParentTeamProject && !task.isCompleted) {
                                PopUpPemberitahuan.teamProjectWarning(context);
                                return;
                              }
                              widget.onToggleComplete!.call();
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (task.isCompleted
                                        ? const Color(0xFF5B93FF)
                                        : PopUpPemberitahuan.positiveColor)
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                task.isCompleted
                                    ? Icons.replay_rounded
                                    : Icons.task_alt_rounded,
                                size: 15,
                                color: task.isCompleted
                                    ? const Color(0xFF5B93FF)
                                    : PopUpPemberitahuan.positiveColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Expandable mobile-parity detail breakdown
                  if (_isExpanded) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFF282B36)),
                    const SizedBox(height: 10),
                    if (isGroup && task.groupMembers.isNotEmpty) ...[
                      const Text(
                        'Group Member :',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      for (final member in task.groupMembers)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 2),
                          child: Text(
                            '• $member',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                    if (task.isCollegeTask && task.course.isNotEmpty) ...[
                      Text(
                        'Course : ${task.course}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      'Date Created : ${task.dateCreated}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontFamily: 'Inter',
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        const Text(
                          'Centeroid Defuzzyfication :',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Text(
                          task.centroidDefuzzification,
                          style: const TextStyle(
                            color: Color(0xFF6EE7B7),
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          task.centroidScale,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10.5,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                    if (task.warningNotice.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        task.warningNotice,
                        style: const TextStyle(
                          color: Color(0xFFEB6161),
                          fontSize: 10.5,
                          fontFamily: 'Inter',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: ValueKey('desktop_task_edit_btn_$_stableId'),
                            onPressed: widget.onTap,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: AppColors.borderSubtle,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 14),
                            label: const Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (widget.onToggleComplete != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              key: ValueKey(
                                'desktop_task_complete_btn_$_stableId',
                              ),
                              onPressed: () {
                                if (isParentTeamProject && !task.isCompleted) {
                                  PopUpPemberitahuan.teamProjectWarning(context);
                                  return;
                                }
                                widget.onToggleComplete!.call();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: task.isCompleted
                                    ? const Color(0xFF5B93FF)
                                    : PopUpPemberitahuan.positiveColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: Icon(
                                task.isCompleted
                                    ? Icons.replay_rounded
                                    : Icons.task_alt_rounded,
                                size: 14,
                              ),
                              label: Text(
                                task.isCompleted ? 'Reopen' : 'Done',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.onToggleComplete == null) {
      return cardContent;
    }

    return Dismissible(
      key: ValueKey('desktop_task_dismiss_$_stableId'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        HapticFeedback.lightImpact();
        if (isParentTeamProject && !task.isCompleted) {
          PopUpPemberitahuan.teamProjectWarning(context);
          return false;
        }
        widget.onToggleComplete!.call();
        return false;
      },
      background: Container(
        decoration: BoxDecoration(
          color: isParentTeamProject && !task.isCompleted
              ? const Color(0xFF5B93FF).withValues(alpha: 0.25)
              : PopUpPemberitahuan.positiveColor.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isParentTeamProject && !task.isCompleted
                ? const Color(0xFF5B93FF)
                : PopUpPemberitahuan.positiveColor,
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              task.isCompleted
                  ? Icons.replay_rounded
                  : Icons.task_alt_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              task.isCompleted ? 'REOPEN' : 'DONE',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      child: cardContent,
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

