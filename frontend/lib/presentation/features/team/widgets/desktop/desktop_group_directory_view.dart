import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../models/desktop_team_directory_models.dart';
import '../../models/team_model.dart';
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

  const DesktopGroupDirectoryView({
    super.key,
    this.searchQuery = '',
    required this.teams,
    required this.onTeamSelected,
    required this.onJoinByCode,
  });

  @override
  State<DesktopGroupDirectoryView> createState() =>
      _DesktopGroupDirectoryViewState();
}

class _DesktopGroupDirectoryViewState extends State<DesktopGroupDirectoryView> {
  TeamDirectoryCategory _selectedCategory = TeamDirectoryCategory.all;

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

  @override
  Widget build(BuildContext context) {
    final totalTeams = widget.teams.length;
    final filtered = _filteredTeams;

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
                  DesktopTeamScheduleBanner(
                    onJoinMeetingTap: _handleJoinDiscordVoice,
                  ),
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
              deadlines: DesktopTeamDirectoryFixtures.defaultDeadlines,
              activities: DesktopTeamDirectoryFixtures.defaultActivities,
              onJoinByCode: widget.onJoinByCode,
            ),
          ),
        ],
      ),
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
