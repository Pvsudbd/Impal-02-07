import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../models/team_milestone_model.dart';
import '../models/team_task_model.dart';
import 'team_milestone_card.dart';

/// Milestones section in Team Dashboard modeled after Homepage Categories,
/// featuring circular progress indicators, horizontal drag/wheel scrolling,
/// and completed milestones placed on the left.
class TeamMilestonesSection extends StatelessWidget {
  final List<TeamMilestoneModel> milestones;
  final List<TeamTaskModel> allTasks;
  final String? selectedMilestoneId;
  final ValueChanged<String> onMilestoneSelected;
  final VoidCallback onAddMilestone;
  final ValueChanged<TeamMilestoneModel> onEditMilestone;
  final ValueChanged<TeamMilestoneModel> onDeleteMilestone;
  final ScrollController? scrollController;
  final GlobalKey? firstActiveMilestoneKey;

  const TeamMilestonesSection({
    super.key,
    required this.milestones,
    required this.allTasks,
    required this.selectedMilestoneId,
    required this.onMilestoneSelected,
    required this.onAddMilestone,
    required this.onEditMilestone,
    required this.onDeleteMilestone,
    this.scrollController,
    this.firstActiveMilestoneKey,
  });

  @override
  Widget build(BuildContext context) {
    // Completed milestones on the left (index 0..), active milestones on the right
    final completedMilestones =
        milestones.where((m) => m.isAllCompleted(allTasks)).toList();
    final activeMilestones =
        milestones.where((m) => !m.isAllCompleted(allTasks)).toList();

    // Active milestones sorted by closest deadline
    activeMilestones.sort((a, b) => a.deadline.compareTo(b.deadline));

    final sortedMilestones = [...completedMilestones, ...activeMilestones];
    final firstActiveId =
        activeMilestones.isNotEmpty ? activeMilestones.first.id : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Header
        Text(
          'Milestones',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.rFont(18, min: 16, max: 20),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: context.rSpacing(10)),

        LayoutBuilder(
          builder: (context, constraints) {
            // Exactly matching Categories on Home: (availableWidth - 48 - 24) / 2
            final availableWidth = constraints.maxWidth;
            final cardWidth = (availableWidth - 48 - 24) / 2;

            return ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                },
              ),
              child: Listener(
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent &&
                      scrollController != null &&
                      scrollController!.hasClients) {
                    final newOffset =
                        scrollController!.offset + pointerSignal.scrollDelta.dy;
                    final maxExtent =
                        scrollController!.position.maxScrollExtent;
                    if (newOffset >= 0 && newOffset <= maxExtent) {
                      scrollController!.jumpTo(newOffset);
                    } else if (newOffset < 0) {
                      scrollController!.jumpTo(0);
                    } else if (newOffset > maxExtent) {
                      scrollController!.jumpTo(maxExtent);
                    }
                  }
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      for (final milestone in sortedMilestones) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            key: (firstActiveMilestoneKey != null &&
                                    milestone.id == firstActiveId)
                                ? firstActiveMilestoneKey
                                : null,
                            child: TeamMilestoneCard(
                              milestone: milestone,
                              allTasks: allTasks,
                              isSelected: selectedMilestoneId == milestone.id,
                              cardWidth: cardWidth,
                              onTap: () => onMilestoneSelected(milestone.id),
                              onEdit: () => onEditMilestone(milestone),
                              onDelete: () => onDeleteMilestone(milestone),
                            ),
                          ),
                        ),
                      ],

                      // Add Milestone Button (matching Home Categories '+' button)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: const ValueKey('add_milestone_button'),
                          borderRadius: BorderRadius.circular(16),
                          onTap: onAddMilestone,
                          child: Container(
                            width: 48,
                            height: 58,
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFF434A59), width: 1),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.add_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

