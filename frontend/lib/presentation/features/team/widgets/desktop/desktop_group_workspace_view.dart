import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../../schedule/models/schedule_model.dart';
import '../../../schedule/models/schedule_repository.dart';
import '../../models/team_milestone_model.dart';
import '../../models/team_task_model.dart';
import 'desktop_team_workspace_panel.dart';

enum _WorkspacePriorityFilter { all, high, medium, low }

/// Shared interactive Discord Voice badge placed in the Desktop Top Header
/// when viewing a Group Workspace (`Desktop - Group Workspace` node `5656`).
class DesktopVoiceActiveBadge extends StatelessWidget {
  final int onlineCount;

  const DesktopVoiceActiveBadge({
    super.key,
    this.onlineCount = 3,
  });

  static Future<void> launchVoiceChannel(BuildContext context) async {
    const discordUrl = 'https://discord.com/channels/@me';
    final uri = Uri.parse(discordUrl);
    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    try {
      await Clipboard.setData(const ClipboardData(text: discordUrl));
    } catch (_) {}
    if (!context.mounted) return;
    PopUpPemberitahuan.show(
      context,
      title: launched ? 'Joining Discord Voice' : 'Voice Channel Link Copied',
      message: launched
          ? 'Opening Discord Group IMPAL voice channel.'
          : 'Discord voice channel link copied to clipboard.',
      icon: Icons.headset_mic_rounded,
      iconBgColor: PopUpPemberitahuan.positiveColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        key: const ValueKey('desktop_workspace_voice_active_badge'),
        onTap: () => launchVoiceChannel(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 36,
          padding: EdgeInsets.symmetric(horizontal: context.rSpacing(12)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mic_none_rounded,
                size: context.rIcon(15),
                color: const Color(0xFF4EB089),
              ),
              SizedBox(width: context.rSpacing(8)),
              Text(
                'Voice Active ($onlineCount Online)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(11, min: 10, max: 12),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full 2-column Desktop Group Workspace view matching FigCraft
/// `Desktop - Group Workspace (Kelompok IMPAL)` (node `5598`, `1440×980`).
class DesktopGroupWorkspaceView extends StatefulWidget {
  final String userName;
  final String teamName;
  final String teamCode;
  final String searchQuery;
  final List<Color> memberColors;
  final List<TeamMilestoneModel> milestones;
  final List<TeamTaskModel> allTasks;
  final String? selectedMilestoneId;
  final bool assignedToMeOnly;
  final ScrollController scrollController;
  final ScrollController milestonesScrollController;
  final GlobalKey firstActiveMilestoneKey;
  final ValueChanged<String> onMilestoneSelected;
  final VoidCallback onAddMilestone;
  final ValueChanged<TeamMilestoneModel> onEditMilestone;
  final ValueChanged<TeamMilestoneModel> onDeleteMilestone;
  final ValueChanged<bool> onAssignedToMeChanged;
  final VoidCallback onCreateMeeting;
  final VoidCallback onCreateTask;
  final ValueChanged<TeamTaskModel> onEditTask;
  final ValueChanged<TeamTaskModel> onToggleTaskCompletion;
  final ValueChanged<ScheduleModel> onEditSchedule;
  final ValueChanged<ScheduleModel> onDeleteSchedule;
  final VoidCallback onMembersTap;
  final bool Function(TeamTaskModel) isAssignedToCurrentUser;

  const DesktopGroupWorkspaceView({
    super.key,
    required this.userName,
    required this.teamName,
    required this.teamCode,
    this.searchQuery = '',
    required this.memberColors,
    required this.milestones,
    required this.allTasks,
    required this.selectedMilestoneId,
    required this.assignedToMeOnly,
    required this.scrollController,
    required this.milestonesScrollController,
    required this.firstActiveMilestoneKey,
    required this.onMilestoneSelected,
    required this.onAddMilestone,
    required this.onEditMilestone,
    required this.onDeleteMilestone,
    required this.onAssignedToMeChanged,
    required this.onCreateMeeting,
    required this.onCreateTask,
    required this.onEditTask,
    required this.onToggleTaskCompletion,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
    required this.onMembersTap,
    required this.isAssignedToCurrentUser,
  });

  @override
  State<DesktopGroupWorkspaceView> createState() =>
      _DesktopGroupWorkspaceViewState();
}

class _DesktopGroupWorkspaceViewState extends State<DesktopGroupWorkspaceView> {
  _WorkspacePriorityFilter _priorityFilter = _WorkspacePriorityFilter.all;
  int _meetingIndex = 0;

  static const List<({String initials, Color color})> _heroAvatars = [
    (initials: 'JS', color: Color(0xFFFF7D65)),
    (initials: 'AS', color: Color(0xFF63CDDA)),
    (initials: 'MK', color: Color(0xFF786FA6)),
    (initials: 'YP', color: Color(0xFFF3A683)),
    (initials: 'RD', color: Color(0xFF778BEB)),
  ];

  Future<void> _copyTeamCode() async {
    HapticFeedback.lightImpact();
    PopUpPemberitahuan.codeCopied(context, code: widget.teamCode);
    try {
      await Clipboard.setData(ClipboardData(text: widget.teamCode));
    } catch (_) {}
  }

  List<ScheduleModel> _teamMeetings(List<ScheduleModel> allSchedules) {
    return allSchedules.where((s) {
      final type = s.type.trim().toLowerCase();
      if (type == 'lecture') return false;
      if (s.id == 'sch_3') return true;
      if (type == 'team' ||
          type == 'team meeting' ||
          type == 'meeting' ||
          type == 'rapat' ||
          type == 'group') {
        return true;
      }
      final loc = (s.location ?? '').toLowerCase();
      return loc.contains('discord') ||
          loc.contains('group') ||
          (s.teamName?.trim().isNotEmpty ?? false);
    }).toList();
  }

  Future<void> _handleJoinMeeting(ScheduleModel? meeting) async {
    final urlText = meeting?.meetingUrl?.trim() ?? '';
    if (urlText.isEmpty) {
      await DesktopVoiceActiveBadge.launchVoiceChannel(context);
      return;
    }
    final uri = Uri.tryParse(urlText);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }
      if (launched) return;
    }
    try {
      await Clipboard.setData(ClipboardData(text: urlText));
    } catch (_) {}
    if (mounted) {
      PopUpPemberitahuan.codeCopied(context, code: urlText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rightPanelWidth = context.screenWidth < 1200 ? 310.0 : 340.0;
    final horizontalPad = context.screenWidth < 1200 ? 24.0 : 32.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPad,
        20,
        horizontalPad,
        24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              key: const ValueKey('team_dashboard_scroll_view'),
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroWorkspaceCard(context),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<List<ScheduleModel>>(
                    valueListenable: ScheduleRepository().schedulesNotifier,
                    builder: (context, allSchedules, _) {
                      return _buildMeetingCard(
                        context,
                        _teamMeetings(allSchedules),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTasksSection(context),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: rightPanelWidth,
            child: SingleChildScrollView(
              key: const ValueKey('desktop_workspace_right_scroll'),
              child: DesktopTeamWorkspacePanel(
                teamCode: widget.teamCode,
                teamName: widget.teamName,
                onManageMembersTap: widget.onMembersTap,
                onMilestoneTap: widget.milestones.isNotEmpty
                    ? () => widget.onMilestoneSelected(
                          widget.milestones.first.id,
                        )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroWorkspaceCard(BuildContext context) {
    final displayTeamName = widget.teamName.replaceAll(' - ', ' ');

    return Container(
      key: const ValueKey('desktop_workspace_hero_card'),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 570;

          final leftInfo = Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  displayTeamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(18, min: 16, max: 20),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF63CDDA),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Center(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Text(
                    'SIF-45',
                    style: TextStyle(
                      color: Color(0xFF2A8F9C),
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  key: const ValueKey('team_dashboard_copy_code_button'),
                  onTap: _copyTeamCode,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Code:',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.teamCode,
                          style: const TextStyle(
                            color: AppColors.primaryAccent,
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );

          final createMeetingBtn = Material(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              key: const ValueKey('dashboard_create_meeting_button'),
              onTap: widget.onCreateMeeting,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Center(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Text(
                    '+ Create Meeting',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );

          final createTaskBtn = Material(
            color: AppColors.primaryAccent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              key: const ValueKey('dashboard_create_task_button'),
              onTap: widget.onCreateTask,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Center(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Text(
                    '+ Create Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );

          final actionButtons = isCompact
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [createMeetingBtn, createTaskBtn],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    createMeetingBtn,
                    const SizedBox(width: 8),
                    createTaskBtn,
                  ],
                );

          final bottomLeftText = Text(
            'Sprint 1: Deliverable Wireframe UI, Architecture Diagram, & Test Plan',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(11, min: 10, max: 12),
              fontFamily: 'Inter',
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          );

          final avatarRow = InkWell(
            key: const ValueKey('desktop_workspace_hero_members_btn'),
            onTap: widget.onMembersTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 96,
                    height: 24,
                    child: Stack(
                      children: [
                        for (int i = 0; i < _heroAvatars.length; i++)
                          Positioned(
                            left: i * 18.0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _heroAvatars[i].color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.bgSidebar,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _heroAvatars[i].initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '5 Anggota Tim',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leftInfo,
                    const SizedBox(height: 12),
                    actionButtons,
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(child: leftInfo),
                    const SizedBox(width: 12),
                    actionButtons,
                  ],
                ),
              const SizedBox(height: 14),
              if (isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bottomLeftText,
                    const SizedBox(height: 10),
                    avatarRow,
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(child: bottomLeftText),
                    const SizedBox(width: 12),
                    avatarRow,
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMeetingCard(
    BuildContext context,
    List<ScheduleModel> meetings,
  ) {
    final defaultSch = ScheduleRepository.defaultTeamSchedule;
    final hasCustomList = meetings.isNotEmpty;
    final safeIndex = hasCustomList
        ? _meetingIndex.clamp(0, meetings.length - 1)
        : 0;
    final current = hasCustomList ? meetings[safeIndex] : defaultSch;

    final isUnmodifiedDefault =
        current.id == defaultSch.id &&
        current.title == defaultSch.title &&
        current.location == defaultSch.location &&
        current.teamName == defaultSch.teamName &&
        current.notes == defaultSch.notes &&
        current.date.year == defaultSch.date.year &&
        current.date.month == defaultSch.date.month &&
        current.date.day == defaultSch.date.day &&
        current.timeStart == defaultSch.timeStart;

    final loc = current.location?.trim() ?? '';
    final team = current.teamName?.trim() ?? '';
    final notes = current.notes?.trim() ?? '';

    final displayTitle = isUnmodifiedDefault ? 'MEETING IMPAL' : current.title;
    final platformLabel = isUnmodifiedDefault
        ? 'Discord • Group IMPAL'
        : '${loc.isNotEmpty ? loc : 'Online'} • ${team.isNotEmpty ? team : widget.teamName}';
    final agendaText = isUnmodifiedDefault
        ? 'Besok 19:00 WIB • Agenda: Sprint 1 Review & Demo Prototype'
        : (notes.isNotEmpty
              ? '${current.formattedTime} • Agenda: $notes'
              : current.formattedTime);
    final ctaLabel =
        isUnmodifiedDefault || loc.toLowerCase().contains('discord')
            ? 'Join Discord Voice'
            : 'Join Meeting';

    return Container(
      key: const ValueKey('desktop_workspace_meeting_card'),
      constraints: const BoxConstraints(minHeight: 82),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.primaryAccent,
              width: 5,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 18, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
                    final compact = constraints.maxWidth < 460;

                    final infoBlock = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                displayTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.rFont(14, min: 13, max: 15),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              height: 18,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF63CDDA),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Center(
                                widthFactor: 1.0,
                                heightFactor: 1.0,
                                child: Text(
                                  platformLabel,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Color(0xFF2A8F9C),
                                    fontSize: 9,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryAccent,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.access_time_rounded,
                                size: 9,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                agendaText,
                                maxLines: compact ? 2 : 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: context.rFont(11, min: 10, max: 12),
                                  fontFamily: 'Inter',
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    final rightActions = Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (hasCustomList && meetings.length > 1) ...[
                          Container(
                            height: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: AppColors.bgPrimary,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => setState(() {
                                    _meetingIndex =
                                        (safeIndex - 1 + meetings.length) %
                                        meetings.length;
                                  }),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.chevron_left_rounded,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${safeIndex + 1}/${meetings.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => setState(() {
                                    _meetingIndex =
                                        (safeIndex + 1) % meetings.length;
                                  }),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (hasCustomList && !isUnmodifiedDefault) ...[
                          Tooltip(
                            message: 'Edit Meeting',
                            child: Material(
                              color: AppColors.bgPrimary,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                key: const ValueKey(
                                  'desktop_workspace_edit_meeting_btn',
                                ),
                                onTap: () => widget.onEditSchedule(current),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.borderSubtle,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    size: 15,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'Delete Meeting',
                            child: Material(
                              color: AppColors.bgPrimary,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                key: const ValueKey(
                                  'desktop_workspace_delete_meeting_btn',
                                ),
                                onTap: () => widget.onDeleteSchedule(current),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.error.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 15,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Material(
                          color: AppColors.primaryAccent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            key: const ValueKey(
                              'desktop_workspace_join_meeting_btn',
                            ),
                            onTap: () => _handleJoinMeeting(current),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 34,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Center(
                                widthFactor: 1.0,
                                heightFactor: 1.0,
                                child: Text(
                                  ctaLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          infoBlock,
                          const SizedBox(height: 10),
                          rightActions,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: infoBlock),
                        const SizedBox(width: 14),
                        rightActions,
                      ],
                    );
          },
        ),
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context) {
    final selectedMilestone = widget.selectedMilestoneId != null
        ? widget.milestones
              .where((m) => m.id == widget.selectedMilestoneId)
              .firstOrNull
        : null;

    final targetTasks = selectedMilestone != null
        ? selectedMilestone.getMemberTasks(widget.allTasks)
        : widget.allTasks;

    final assigneeScoped = widget.assignedToMeOnly
        ? targetTasks.where(widget.isAssignedToCurrentUser).toList()
        : targetTasks;

    final query = widget.searchQuery.trim().toLowerCase();
    final searchedTasks = query.isEmpty
        ? assigneeScoped
        : assigneeScoped.where((t) {
            return t.title.toLowerCase().contains(query) ||
                t.assignedTo.toLowerCase().contains(query) ||
                t.priority.label.toLowerCase().contains(query) ||
                (t.description?.toLowerCase().contains(query) ?? false);
          }).toList();

    final highCount = searchedTasks
        .where((t) => t.priority == TaskPriority.high)
        .length;
    final mediumCount = searchedTasks
        .where((t) => t.priority == TaskPriority.medium)
        .length;
    final lowCount = searchedTasks
        .where((t) => t.priority == TaskPriority.low)
        .length;

    final priorityScoped = switch (_priorityFilter) {
      _WorkspacePriorityFilter.all => searchedTasks,
      _WorkspacePriorityFilter.high =>
        searchedTasks.where((t) => t.priority == TaskPriority.high).toList(),
      _WorkspacePriorityFilter.medium =>
        searchedTasks.where((t) => t.priority == TaskPriority.medium).toList(),
      _WorkspacePriorityFilter.low =>
        searchedTasks.where((t) => t.priority == TaskPriority.low).toList(),
    };

    final completed = priorityScoped.where((t) => t.isDone).toList();
    final active = priorityScoped.where((t) => !t.isDone).toList();
    active.sort(TeamTaskModel.compareTeamTaskDeadlines);
    final displayedTasks = [...completed, ...active];
    final activeCount = searchedTasks.where((t) => !t.isDone).length;

    final filterPills = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FilterPill(
          pillKey: const ValueKey('desktop_workspace_filter_all'),
          label: 'Semua (${searchedTasks.length})',
          isActive: _priorityFilter == _WorkspacePriorityFilter.all,
          onTap: () => setState(
            () => _priorityFilter = _WorkspacePriorityFilter.all,
          ),
        ),
        const SizedBox(width: 6),
        _FilterPill(
          pillKey: const ValueKey('desktop_workspace_filter_high'),
          label: 'High ($highCount)',
          isActive: _priorityFilter == _WorkspacePriorityFilter.high,
          onTap: () => setState(
            () => _priorityFilter = _WorkspacePriorityFilter.high,
          ),
        ),
        const SizedBox(width: 6),
        _FilterPill(
          pillKey: const ValueKey('desktop_workspace_filter_medium'),
          label: 'Medium ($mediumCount)',
          isActive: _priorityFilter == _WorkspacePriorityFilter.medium,
          onTap: () => setState(
            () => _priorityFilter = _WorkspacePriorityFilter.medium,
          ),
        ),
        const SizedBox(width: 6),
        _FilterPill(
          pillKey: const ValueKey('desktop_workspace_filter_low'),
          label: 'Low ($lowCount)',
          isActive: _priorityFilter == _WorkspacePriorityFilter.low,
          onTap: () => setState(
            () => _priorityFilter = _WorkspacePriorityFilter.low,
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final headerTitle = Text(
              'Team Tasks ($activeCount Active)',
              style: TextStyle(
                color: Colors.white,
                fontSize: context.rFont(15, min: 14, max: 17),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            );
            if (constraints.maxWidth < 480) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerTitle,
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: filterPills,
                  ),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(child: headerTitle),
                const SizedBox(width: 12),
                filterPills,
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        if (displayedTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  color: AppColors.textMuted,
                  size: 32,
                ),
                const SizedBox(height: 10),
                Text(
                  selectedMilestone != null
                      ? 'No matching tasks in "${selectedMilestone.title}".'
                      : 'No team tasks match your active filter.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
                if (_priorityFilter != _WorkspacePriorityFilter.all ||
                    widget.assignedToMeOnly) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(
                        () => _priorityFilter = _WorkspacePriorityFilter.all,
                      );
                      if (widget.assignedToMeOnly) {
                        widget.onAssignedToMeChanged(false);
                      }
                    },
                    child: const Text(
                      'Show All Tasks',
                      style: TextStyle(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoColumn = constraints.maxWidth >= 580;
              if (!isTwoColumn) {
                return Column(
                  children: [
                    for (int i = 0; i < displayedTasks.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      _DesktopWorkspaceTaskCard(
                        key: ValueKey(
                          'desktop_team_task_${displayedTasks[i].id}',
                        ),
                        task: displayedTasks[i],
                        onTap: () => widget.onEditTask(displayedTasks[i]),
                        onEdit: () => widget.onEditTask(displayedTasks[i]),
                        onToggleCompletion: () =>
                            widget.onToggleTaskCompletion(displayedTasks[i]),
                      ),
                    ],
                  ],
                );
              }

              final rows = <Widget>[];
              for (int i = 0; i < displayedTasks.length; i += 2) {
                final leftTask = displayedTasks[i];
                final rightTask = i + 1 < displayedTasks.length
                    ? displayedTasks[i + 1]
                    : null;
                rows.add(
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _DesktopWorkspaceTaskCard(
                          key: ValueKey('desktop_team_task_${leftTask.id}'),
                          task: leftTask,
                          onTap: () => widget.onEditTask(leftTask),
                          onEdit: () => widget.onEditTask(leftTask),
                          onToggleCompletion: () =>
                              widget.onToggleTaskCompletion(leftTask),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: rightTask == null
                            ? const SizedBox()
                            : _DesktopWorkspaceTaskCard(
                                key: ValueKey(
                                  'desktop_team_task_${rightTask.id}',
                                ),
                                task: rightTask,
                                onTap: () => widget.onEditTask(rightTask),
                                onEdit: () => widget.onEditTask(rightTask),
                                onToggleCompletion: () =>
                                    widget.onToggleTaskCompletion(rightTask),
                              ),
                      ),
                    ],
                  ),
                );
                if (i + 2 < displayedTasks.length) {
                  rows.add(const SizedBox(height: 12));
                }
              }
              return Column(children: rows);
            },
          ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final Key pillKey;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterPill({
    required this.pillKey,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.primaryAccent : AppColors.bgCard,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: pillKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textMuted,
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopWorkspaceTaskCard extends StatelessWidget {
  final TeamTaskModel task;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleCompletion;

  const _DesktopWorkspaceTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onEdit,
    required this.onToggleCompletion,
  });

  (Color bg, Color fg) _priorityColors() {
    if (task.isDone) {
      return (const Color(0xFF363C48), AppColors.textMuted);
    }
    switch (task.priority) {
      case TaskPriority.high:
        return (AppColors.priorityHighBg, AppColors.priorityHighText);
      case TaskPriority.medium:
        return (AppColors.priorityMediumBg, AppColors.priorityMediumText);
      case TaskPriority.low:
        return (AppColors.priorityLowBg, AppColors.priorityLowText);
    }
  }

  (double progress, String label, Color ringColor) _progressVisual() {
    if (task.isDone) {
      return (1.0, '100%', AppColors.statusCompleted);
    }
    switch (task.priority) {
      case TaskPriority.high:
        return (0.75, '75%', AppColors.primaryAccent);
      case TaskPriority.medium:
        return (0.50, '50%', const Color(0xFF63CDDA));
      case TaskPriority.low:
        return (0.30, '30%', AppColors.purpleAccent);
    }
  }

  List<({String initials, Color color})> _resolveAvatars() {
    final names = task.assignedTo
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (names.isEmpty) {
      return [(initials: 'TM', color: task.assigneeColor)];
    }
    final colors = task.colors;
    return [
      for (int i = 0; i < names.length; i++)
        (
          initials: _initialsFor(names[i]),
          color: i < colors.length
              ? colors[i]
              : (i == 0 ? task.assigneeColor : const Color(0xFF63CDDA)),
        ),
    ];
  }

  String _initialsFor(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final clean = fullName.trim();
    if (clean.length >= 2) return clean.substring(0, 2).toUpperCase();
    return clean.isNotEmpty ? clean.toUpperCase() : 'TM';
  }

  @override
  Widget build(BuildContext context) {
    final (prioBg, prioFg) = _priorityColors();
    final (progressRatio, progressLabel, ringColor) = _progressVisual();
    final avatars = _resolveAvatars();
    final double titleRightPad = 114.0 + (!task.isAlertEnabled ? 18.0 : 0.0);

    final dueBg = task.isDone
        ? const Color(0xFF363C48)
        : (task.isUrgent ? const Color(0xFFFF7D65) : const Color(0xFF5B93FF));
    final dueFg = task.isDone ? AppColors.textMuted : Colors.white;

    final categoryTag = task.title.toLowerCase().contains('report') ||
            task.title.toLowerCase().contains('laporan')
        ? 'Laporan'
        : (task.title.toLowerCase().contains('ui') ||
                task.title.toLowerCase().contains('figma')
            ? 'UI/UX'
            : 'Code');

    return Material(
      color: task.isDone ? const Color(0xFF252932) : AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        hoverColor: Colors.white.withValues(alpha: 0.03),
        child: Container(
          constraints: const BoxConstraints(minHeight: 196),
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(18),
            vertical: context.rSpacing(16),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: task.isDone
                  ? const Color(0xFF383E4C)
                  : AppColors.borderSubtle,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Bar: Pinned anti-clustering stack
              Stack(
                children: [
                  const SizedBox(width: double.infinity),
                  Padding(
                    padding: EdgeInsets.only(right: titleRightPad),
                    child: Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: task.isDone
                            ? const Color(0xFF7E8696)
                            : Colors.white,
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                        decorationColor: const Color(0xFF7E8696),
                        fontSize: context.rFont(14, min: 13, max: 15),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
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
                            child: Icon(
                              Icons.notifications_off_outlined,
                              size: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: prioBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            task.priority.label,
                            style: TextStyle(
                              color: prioFg,
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: dueBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            task.effectiveDueBadge,
                            style: TextStyle(
                              color: dueFg,
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Team members',
                style: TextStyle(
                  color: task.isDone
                      ? const Color(0xFF6B7280)
                      : AppColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              // Middle Section: Left avatars + deadline, Right progress ring toggle
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: avatars.length == 1
                                  ? 24.0
                                  : 24.0 + (avatars.length - 1) * 18.0,
                              height: 24,
                              child: Stack(
                                children: [
                                  for (int i = 0; i < avatars.length; i++)
                                    Positioned(
                                      left: i * 18.0,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: avatars[i].color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: task.isDone
                                                ? const Color(0xFF252932)
                                                : AppColors.bgCard,
                                            width: 2,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          avatars[i].initials,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8.5,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task.assignedTo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: task.isDone
                                      ? const Color(0xFF6B7280)
                                      : AppColors.textBody,
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: task.isDone
                                    ? const Color(0xFF363C48)
                                    : AppColors.primaryAccent,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.access_time_rounded,
                                size: 9,
                                color: task.isDone
                                    ? AppColors.textMuted
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                task.timeRange,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: task.isDone
                                      ? const Color(0xFF6B7280)
                                      : AppColors.textMuted,
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                  fontFeatures: const [
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
                  const SizedBox(width: 12),
                  Tooltip(
                    message: task.isDone ? 'Reopen task' : 'Mark as completed',
                    child: InkWell(
                      key: ValueKey('desktop_team_task_toggle_${task.id}'),
                      onTap: onToggleCompletion,
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: CustomPaint(
                          painter: _RingPainter(
                            progress: progressRatio,
                            trackColor: AppColors.bgPrimary,
                            activeColor: ringColor,
                          ),
                          child: Center(
                            child: task.isDone
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: AppColors.statusCompleted,
                                  )
                                : Text(
                                    progressLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Bottom Bar: Left tags + Right pure gray pencil icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          height: 22,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: task.isDone
                                ? const Color(0xFF363C48)
                                : AppColors.purpleAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            widthFactor: 1.0,
                            heightFactor: 1.0,
                            child: Text(
                              'Kelompok',
                              style: TextStyle(
                                color: task.isDone
                                    ? AppColors.textMuted
                                    : const Color(0xFF4A3C8C),
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 22,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: task.isDone
                                ? const Color(0xFF363C48)
                                : const Color(0xFF63CDDA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            widthFactor: 1.0,
                            heightFactor: 1.0,
                            child: Text(
                              categoryTag,
                              style: TextStyle(
                                color: task.isDone
                                    ? AppColors.textMuted
                                    : const Color(0xFF2A8F9C),
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: 'Edit task',
                    child: InkWell(
                      key: ValueKey('desktop_team_task_edit_${task.id}'),
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.edit_rounded,
                          size: context.rIcon(16),
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color activeColor;

  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 3.0;
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.activeColor != activeColor;
  }
}
