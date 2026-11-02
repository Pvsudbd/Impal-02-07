import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../models/team_milestone_model.dart';
import '../models/team_task_model.dart';

/// Homepage Category-style Milestone Card with a Circular Progression Ring on the right.
///
/// Features:
/// - Category-like compact card matching Home Categories styling & dimensions
/// - Circular progress ring on the right displaying real-time completion percentage
/// - Tap to toggle filtering team tasks under this milestone (tap again to show all tasks)
/// - Long-press or 3-dots menu for Editing and Deleting the milestone
/// - Follows 100% English UI Mandate, ResponsiveContext, and HP Kentang standards.
class TeamMilestoneCard extends StatelessWidget {
  final TeamMilestoneModel milestone;
  final List<TeamTaskModel> allTasks;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final double? cardWidth;

  const TeamMilestoneCard({
    super.key,
    required this.milestone,
    required this.allTasks,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    // If cardWidth is not passed, calculate width matching Home Categories (2 cards + 48dp add button + 2x12dp gaps)
    final effectiveWidth = cardWidth ??
        ((MediaQuery.of(context).size.width - 40 - 48 - 24) / 2);

    final totalCount = milestone.getTotalCount(allTasks);
    final completedCount = milestone.getCompletedCount(allTasks);
    final progressFraction = milestone.getProgressFraction(allTasks);
    final progressPercent = milestone.getProgressPercent(allTasks);
    final isAllDone = milestone.isAllCompleted(allTasks);

    final progressColor = isAllDone
        ? const Color(0xFF10B981)
        : milestone.isUrgent
            ? const Color(0xFFFF826E)
            : const Color(0xFF55E6C1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: () => _showOptionsBottomSheet(context),
        child: Container(
          width: effectiveWidth,
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF323846),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFA6144)
                  : isAllDone
                      ? const Color(0xFF10B981).withValues(alpha: 0.5)
                      : const Color(0xFF3B4150),
              width: isSelected ? 1.5 : 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left: Title and Subtitle Info (matching Home Category typography)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      milestone.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(14.5, min: 13, max: 15),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      totalCount == 0
                          ? '0 Tasks • ${milestone.effectiveDueBadge}'
                          : '${completedCount.toString().padLeft(2, '0')}/$totalCount Tasks • ${milestone.effectiveDueBadge}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : AppColors.textMuted,
                        fontSize: context.rFont(11.5, min: 10, max: 12),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right: Compact Circular Progression Ring (matching 58dp category height)
              SizedBox(
                width: 34,
                height: 34,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        value: progressFraction,
                        strokeWidth: 3.2,
                        strokeCap: StrokeCap.round,
                        backgroundColor: const Color(0xFF232834),
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                    ),
                    Text(
                      '$progressPercent%',
                      style: TextStyle(
                        color: progressColor,
                        fontSize: context.rFont(9.5, min: 8.5, max: 10),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF282D37),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF434A59),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              milestone.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Deadline: ${milestone.effectiveFormattedDeadline}',
              style: const TextStyle(color: Color(0xFF8E95A5), fontSize: 12),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.white),
              title: const Text('Edit Milestone', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(ctx).pop();
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF5E4D)),
              title: const Text('Delete Milestone', style: TextStyle(color: Color(0xFFFF5E4D))),
              onTap: () {
                Navigator.of(ctx).pop();
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
