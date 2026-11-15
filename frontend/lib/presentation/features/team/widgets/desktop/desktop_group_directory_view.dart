import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../../schedule/models/schedule_model.dart';
import '../../../schedule/models/schedule_repository.dart';
import '../../../schedule/pop_up_konfirmasi_delete.dart';
import '../../models/desktop_team_directory_models.dart';
import '../../models/team_model.dart';
import '../../models/team_task_model.dart';
import '../../models/team_task_repository.dart';
import '../../pop_up_create_meeting.dart';
import 'desktop_team_directory_card.dart';
import 'desktop_team_right_panel.dart';
import 'desktop_team_schedule_banner.dart';

/// Desktop 2-column Group Directory (List Kelompok) workspace matching FigCraft
/// `Desktop - Group Directory (List Kelompok)` (node 5340, 1440×980).
class DesktopGroupDirectoryView extends StatefulWidget {
  final String searchQuery;
  final List<DesktopTeamCardData> teams;
  final ValueChanged<TeamModel> onTeamSelected;
  final ValueChanged<String> onJoinByCode;
  final VoidCallback? onOpenScheduleTap;

  const DesktopGroupDirectoryView({
    super.key,
    this.searchQuery = '',
    required this.teams,
    required this.onTeamSelected,
    required this.onJoinByCode,
    this.onOpenScheduleTap,
  });

  @override
  State<DesktopGroupDirectoryView> createState() =>
      _DesktopGroupDirectoryViewState();
}

class _DesktopGroupDirectoryViewState extends State<DesktopGroupDirectoryView> {
  TeamDirectoryCategory _selectedCategory = TeamDirectoryCategory.all;
  final ScheduleRepository _scheduleRepo = ScheduleRepository();
  final TeamTaskRepository _teamTaskRepo = TeamTaskRepository();
  int _scheduleIndex = 0;

  List<DesktopTeamCardData> get _filteredTeams {
    var list = widget.teams;

    if (_selectedCategory != TeamDirectoryCategory.all) {
      list = list.where((t) => t.category == _selectedCategory).toList();
    }

    final query = widget.searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((t) {
        return t.name.toLowerCase().contains(query) ||
            t.subtitle.toLowerCase().contains(query) ||
            t.badgeLabel.toLowerCase().contains(query) ||
            t.inviteCode.toLowerCase().contains(query);
      }).toList();
    }

    return list;
  }

  Future<void> _handleJoinDiscordVoice() async {
    const discordUrl = 'https://discord.com/channels/@me';
    final uri = Uri.parse(discordUrl);
    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    await Clipboard.setData(const ClipboardData(text: discordUrl));
    if (!mounted) return;

    PopUpPemberitahuan.show(
      context,
      title: launched ? 'Joining Discord Voice' : 'Meeting Link Copied',
      message: launched
          ? 'Opening Discord Group IMPAL voice channel.'
          : 'Discord voice link copied to clipboard.',
      icon: Icons.headset_mic_rounded,
      iconBgColor: PopUpPemberitahuan.positiveColor,
    );
  }

  List<ScheduleModel> _teamMeetings(List<ScheduleModel> allSchedules) {
    return allSchedules.where((s) {
      final type = s.type.trim().toLowerCase();
      if (type == 'lecture') return false;
      if (type == 'team' ||
          type == 'team meeting' ||
          type == 'meeting' ||
          type == 'rapat' ||
          type == 'group') {
        return true;
      }
      final t = s.title.toLowerCase();
      final n = (s.notes ?? '').toLowerCase();
      final loc = (s.location ?? '').toLowerCase();
      if (t.contains('ujian') ||
          t.contains('uts') ||
          t.contains('uas') ||
          t.contains('kuis')) {
        return false;
      }
      return t.contains('meet') ||
          t.contains('rapat') ||
          t.contains('diskusi') ||
          t.contains('team') ||
          t.contains('tim') ||
          t.contains('kelompok') ||
          t.contains('mentoring') ||
          t.contains('briefing') ||
          t.contains('standup') ||
          t.contains('sync') ||
          t.contains('sprint') ||
          t.contains('evaluasi') ||
          t.contains('koordinasi') ||
          n.contains('meet') ||
          n.contains('rapat') ||
          n.contains('diskusi') ||
          n.contains('kelompok') ||
          n.contains('mentoring') ||
          n.contains('sprint') ||
          loc.contains('group') ||
          (s.teamName?.trim().isNotEmpty ?? false);
    }).toList();
  }

  Future<void> _handleCreateMeeting() async {
    final created = await PopUpCreateMeeting.show(
      context,
      teamName: 'Group IMPAL',
    );
    if (mounted) {
      final meetings = _teamMeetings(_scheduleRepo.schedulesNotifier.value);
      final idx = created == null
          ? -1
          : meetings.indexWhere((m) => m.id == created.id);
      setState(() {
        _scheduleIndex = idx >= 0 ? idx : 0;
      });
    }
  }

  Future<void> _handleEditMeeting(ScheduleModel meeting) async {
    final team = meeting.teamName?.trim() ?? '';
    await PopUpCreateMeeting.showEdit(
      context,
      existingSchedule: meeting,
      teamName: team.isNotEmpty ? team : 'Group IMPAL',
    );
  }

  Future<void> _handleDeleteMeeting(ScheduleModel meeting) async {
    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: 'Delete Meeting?',
      message:
          'Are you sure you want to delete "${meeting.title}"? This action cannot be undone.',
    );
    if (confirmed == true && mounted) {
      _scheduleRepo.deleteSchedule(meeting.id);
      setState(() {
        if (_scheduleIndex > 0) _scheduleIndex -= 1;
      });
      PopUpPemberitahuan.meetingDeleted(context);
    }
  }

  Future<void> _handleJoinMeeting(ScheduleModel? meeting) async {
    final urlText = meeting?.meetingUrl?.trim() ?? '';
    if (urlText.isEmpty) {
      await _handleJoinDiscordVoice();
      return;
    }
    final uri = Uri.tryParse(urlText);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    }
    await Clipboard.setData(ClipboardData(text: urlText));
    if (mounted) {
      PopUpPemberitahuan.codeCopied(context, code: urlText);
    }
  }

  List<DesktopTeamDeadlineItem> _buildLiveDeadlines() {
    final items = <DesktopTeamDeadlineItem>[
      ...DesktopTeamDirectoryFixtures.defaultDeadlines,
    ];
    final existingTitles = items.map((e) => e.title.toLowerCase()).toSet();
    final repoTasks = _teamTaskRepo
        .getTasks('7X29')
        .where((t) => !t.isDone)
        .toList();

    for (final task in repoTasks) {
      if (existingTitles.contains(task.title.toLowerCase())) continue;
      existingTitles.add(task.title.toLowerCase());
      late final Color bg;
      late final Color fg;
      switch (task.priority) {
        case TaskPriority.high:
          bg = const Color(0xFFFF5E4D);
          fg = Colors.white;
        case TaskPriority.medium:
          bg = const Color(0xFFFBBF24);
          fg = const Color(0xFF1F2937);
        case TaskPriority.low:
          bg = const Color(0xFF6EE7B7);
          fg = const Color(0xFF064E3B);
      }
      items.add(
        DesktopTeamDeadlineItem(
          title: task.title,
          timeText: task.timeRange.isNotEmpty
              ? task.timeRange
              : task.effectiveDueBadge,
          priorityLabel: task.priority.label,
          pillBgColor: bg,
          pillTextColor: fg,
        ),
      );
    }
    return items;
  }

  Widget _buildLiveScheduleBanner(List<ScheduleModel> meetings) {
    if (meetings.isEmpty) {
      return DesktopTeamScheduleBanner(
        title: 'No Team Meeting Scheduled',
        platformLabel: 'Team Schedule',
        agendaText: 'Tap Create Meeting to schedule your next team sync.',
        ctaLabel: 'Create Meeting',
        onJoinMeetingTap: _handleCreateMeeting,
        onCreateMeetingTap: _handleCreateMeeting,
        onSeeAllTap: widget.onOpenScheduleTap,
      );
    }

    final safeIndex = _scheduleIndex.clamp(0, meetings.length - 1);
    final current = meetings[safeIndex];
    final defaultSch = ScheduleRepository.defaultTeamSchedule;
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

    final platformLabel = isUnmodifiedDefault
        ? 'Discord • Group IMPAL'
        : '${loc.isNotEmpty ? loc : 'Online'} • ${team.isNotEmpty ? team : 'Team'}';
    final agendaText = isUnmodifiedDefault
        ? 'Tomorrow 19:00 WIB • Agenda: Sprint 1 Review & UI Demo Prototype'
        : (notes.isNotEmpty
              ? '${current.formattedTime} • Agenda: $notes'
              : current.formattedTime);
    final ctaLabel =
        isUnmodifiedDefault || loc.toLowerCase().contains('discord')
        ? 'Join Discord Voice'
        : 'Join Meeting';

    return DesktopTeamScheduleBanner(
      title: current.title,
      platformLabel: platformLabel,
      agendaText: agendaText,
      ctaLabel: ctaLabel,
      currentIndex: safeIndex,
      totalCount: meetings.length,
      onPrevTap: meetings.length > 1
          ? () {
              setState(() {
                _scheduleIndex =
                    (safeIndex - 1 + meetings.length) % meetings.length;
              });
            }
          : null,
      onNextTap: meetings.length > 1
          ? () {
              setState(() {
                _scheduleIndex = (safeIndex + 1) % meetings.length;
              });
            }
          : null,
      onJoinMeetingTap: () => _handleJoinMeeting(current),
      onCreateMeetingTap: _handleCreateMeeting,
      onSeeAllTap: widget.onOpenScheduleTap,
      onEditMeetingTap: () => _handleEditMeeting(current),
      onDeleteMeetingTap: () => _handleDeleteMeeting(current),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalTeams = widget.teams.length;
    final filtered = _filteredTeams;

    return ListenableBuilder(
      listenable: Listenable.merge([
        _scheduleRepo.schedulesNotifier,
        _teamTaskRepo,
      ]),
      builder: (context, _) {
        final meetings = _teamMeetings(_scheduleRepo.schedulesNotifier.value);
        final deadlines = _buildLiveDeadlines();

        return Padding(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey('desktop_group_directory_left_scroll'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLiveScheduleBanner(meetings),
                      const SizedBox(height: 22),
                      _buildTeamsHeaderRow(context, totalTeams),
                      const SizedBox(height: 14),
                      _buildTeamsGrid(context, filtered),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              SingleChildScrollView(
                key: const ValueKey('desktop_group_directory_right_scroll'),
                child: DesktopTeamRightPanel(
                  deadlines: deadlines,
                  activities: DesktopTeamDirectoryFixtures.defaultActivities,
                  onJoinByCode: widget.onJoinByCode,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamsHeaderRow(BuildContext context, int totalTeams) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          Text(
            'My Teams ($totalTeams Aktif)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(15, min: 14, max: 17),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildFilterPill(
                label: 'Semua Tim ($totalTeams)',
                category: TeamDirectoryCategory.all,
              ),
              _buildFilterPill(
                label: 'Mata Kuliah',
                category: TeamDirectoryCategory.mataKuliah,
              ),
              _buildFilterPill(
                label: 'Projek Mandiri',
                category: TeamDirectoryCategory.projekMandiri,
              ),
              _buildFilterPill(
                label: 'Kompetisi',
                category: TeamDirectoryCategory.kompetisi,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required TeamDirectoryCategory category,
  }) {
    final isActive = _selectedCategory == category;
    return Material(
      color: isActive ? AppColors.primaryAccent : AppColors.bgCard,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: ValueKey('desktop_team_filter_${category.name}'),
        onTap: () => setState(() => _selectedCategory = category),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            widthFactor: 1,
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

  Widget _buildTeamsGrid(
    BuildContext context,
    List<DesktopTeamCardData> teams,
  ) {
    if (teams.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.groups_outlined,
              size: 32,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 10),
            const Text(
              'No teams match your current filter',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try another category or clear your search query.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
            if (_selectedCategory != TeamDirectoryCategory.all) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() => _selectedCategory = TeamDirectoryCategory.all);
                },
                child: const Text(
                  'Show All Teams',
                  style: TextStyle(
                    color: AppColors.primaryAccent,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleColumn = constraints.maxWidth < 520;
        if (useSingleColumn) {
          return Column(
            children: [
              for (int i = 0; i < teams.length; i++) ...[
                DesktopTeamDirectoryCard(
                  team: teams[i],
                  onOpenTap: () => widget.onTeamSelected(teams[i].toTeamModel()),
                ),
                if (i < teams.length - 1) const SizedBox(height: 14),
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (int i = 0; i < teams.length; i += 2) {
          final first = teams[i];
          final second = (i + 1 < teams.length) ? teams[i + 1] : null;
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DesktopTeamDirectoryCard(
                    team: first,
                    onOpenTap: () => widget.onTeamSelected(first.toTeamModel()),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: second != null
                      ? DesktopTeamDirectoryCard(
                          team: second,
                          onOpenTap: () =>
                              widget.onTeamSelected(second.toTeamModel()),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
          if (i + 2 < teams.length) {
            rows.add(const SizedBox(height: 14));
          }
        }

        return Column(children: rows);
      },
    );
  }
}
