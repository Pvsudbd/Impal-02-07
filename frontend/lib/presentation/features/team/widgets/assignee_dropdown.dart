import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../models/team_member_model.dart';

/// Expandable multi-select dropdown for assigning team tasks to one or more members.
///
/// Complies with AGENTS.md Section 1, Section 2 & Section 3.
class AssigneeDropdown extends StatefulWidget {
  final List<TeamMemberModel> members;
  final List<TeamMemberModel> selectedMembers;
  final ValueChanged<List<TeamMemberModel>> onMembersChanged;

  const AssigneeDropdown({
    super.key,
    required this.members,
    required this.selectedMembers,
    required this.onMembersChanged,
  });

  @override
  State<AssigneeDropdown> createState() => _AssigneeDropdownState();
}

class _AssigneeDropdownState extends State<AssigneeDropdown> {
  bool _isExpanded = true; // Expanded by default matching Figma screenshot

  void _toggleMember(TeamMemberModel member) {
    final isAlreadySelected = widget.selectedMembers.any((m) => m.id == member.id);
    final updatedList = List<TeamMemberModel>.from(widget.selectedMembers);

    if (isAlreadySelected) {
      updatedList.removeWhere((m) => m.id == member.id);
    } else {
      updatedList.add(member);
    }

    widget.onMembersChanged(updatedList);
  }

  String _getHeaderTitle() {
    if (widget.selectedMembers.isEmpty) {
      return 'Select Person';
    } else if (widget.selectedMembers.length == 1) {
      return widget.selectedMembers.first.name;
    } else if (widget.selectedMembers.length == 2) {
      final first = widget.selectedMembers[0].name.split(' ').first;
      final second = widget.selectedMembers[1].name.split(' ').first;
      return '$first, $second';
    } else {
      return '${widget.selectedMembers.length} People Selected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableMotion = context.animationsDisabled;
    final hasSelection = widget.selectedMembers.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Asign To',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: context.rFont(14.5, min: 13, max: 17),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            if (widget.selectedMembers.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${widget.selectedMembers.length} assigned',
                  style: TextStyle(
                    color: AppColors.primaryAccent,
                    fontSize: context.rFont(11, min: 10, max: 12),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: context.rSpacing(8)),
        // Outer Container with Nested Rounded Borders
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Toggle Tile
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _isExpanded = !_isExpanded);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rSpacing(14),
                      vertical: context.rSpacing(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            _getHeaderTitle(),
                            style: TextStyle(
                              color: hasSelection
                                  ? AppColors.textWhite
                                  : AppColors.textMuted,
                              fontSize: context.rFont(14, min: 12, max: 16),
                              fontFamily: 'Inter',
                              fontWeight: hasSelection
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0.0,
                          duration: disableMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textMuted,
                            size: context.rIcon(22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Expandable Member List (Multi-Select)
              if (_isExpanded) ...[
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderSubtle,
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: widget.members.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderSubtle,
                  ),
                  itemBuilder: (context, index) {
                    final member = widget.members[index];
                    final isSelected =
                        widget.selectedMembers.any((m) => m.id == member.id);

                    return Material(
                      color: isSelected
                          ? AppColors.bgCard.withValues(alpha: 0.35)
                          : Colors.transparent,
                      child: InkWell(
                        onTap: () => _toggleMember(member),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.rSpacing(14),
                            vertical: context.rSpacing(12),
                          ),
                          child: Row(
                            children: [
                              // Avatar Circle with Badge
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: member.avatarColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.bgCard,
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: context.rSpacing(12)),
                              // Member Name
                              Expanded(
                                child: Text(
                                  member.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.textWhite
                                        : AppColors.textMuted,
                                    fontSize: context.rFont(14, min: 12, max: 16),
                                    fontFamily: 'Inter',
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              // Multi-select Checkbox Indicator
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.borderMedium,
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 13,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
