import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../models/team_task_repository.dart';

class _WorkspaceMemberMeta {
  final String initials;
  final String name;
  final String subtitle;
  final String role;
  final Color color;
  final Color? pillBgColor;
  final Color pillTextColor;

  const _WorkspaceMemberMeta({
    required this.initials,
    required this.name,
    required this.subtitle,
    required this.role,
    required this.color,
    this.pillBgColor,
    required this.pillTextColor,
  });
}

class _WorkspaceResourceMeta {
  final String title;
  final String subtitle;
  final String url;
  final IconData icon;
  final Color accentColor;

  const _WorkspaceResourceMeta({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.icon,
    required this.accentColor,
  });
}

/// Right-hand desktop workspace panel rendered beside [DesktopGroupWorkspaceView]
/// matching FigCraft `Aside Right Panel` (node 5822, width 340dp).
class DesktopTeamWorkspacePanel extends StatelessWidget {
  final String teamCode;
  final String teamName;
  final VoidCallback onManageMembersTap;
  final VoidCallback? onMilestoneTap;

  const DesktopTeamWorkspacePanel({
    super.key,
    required this.teamCode,
    required this.teamName,
    required this.onManageMembersTap,
    this.onMilestoneTap,
  });

  static const List<_WorkspaceMemberMeta> _members = [
    _WorkspaceMemberMeta(
      initials: 'JS',
      name: 'Jarvis S.',
      subtitle: 'Product Owner / Lead',
      role: 'Lead',
      color: Color(0xFFFF7D65),
      pillTextColor: Colors.white,
    ),
    _WorkspaceMemberMeta(
      initials: 'AS',
      name: 'Ahmad Sahroni',
      subtitle: 'Fullstack Dev',
      role: 'Dev',
      color: Color(0xFF63CDDA),
      pillTextColor: Color(0xFF083344),
    ),
    _WorkspaceMemberMeta(
      initials: 'MK',
      name: 'Muhammad Kafi',
      subtitle: 'Backend Architect',
      role: 'Backend',
      color: Color(0xFF786FA6),
      pillTextColor: Colors.white,
    ),
    _WorkspaceMemberMeta(
      initials: 'YP',
      name: 'Yoga Perkasa',
      subtitle: 'UI/UX Designer',
      role: 'UI/UX',
      color: Color(0xFF778BEB),
      pillTextColor: Colors.white,
    ),
    _WorkspaceMemberMeta(
      initials: 'RD',
      name: 'Rizky Dwi',
      subtitle: 'QA & Testing',
      role: 'QA Tester',
      color: Color(0xFF778BEB),
      pillBgColor: Color(0xFF4EB089),
      pillTextColor: Color(0xFF064E3B),
    ),
  ];

  static const List<_WorkspaceResourceMeta> _resources = [
    _WorkspaceResourceMeta(
      title: 'GitHub Repository',
      subtitle: 'github.com/impal-45/jarvishub-ui',
      url: 'https://github.com/impal-45/jarvishub-ui',
      icon: Icons.code_rounded,
      accentColor: Color(0xFF63CDDA),
    ),
    _WorkspaceResourceMeta(
      title: 'Figma Spec Design',
      subtitle: 'figma.com/file/impal-sprint1',
      url: 'https://figma.com/file/impal-sprint1',
      icon: Icons.design_services_rounded,
      accentColor: Color(0xFF778BEB),
    ),
    _WorkspaceResourceMeta(
      title: 'Discord Voice & Chat',
      subtitle: 'discord.gg/impal-study-hub',
      url: 'https://discord.gg/impal-study-hub',
      icon: Icons.headset_mic_rounded,
      accentColor: Color(0xFF786FA6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final repo = TeamTaskRepository();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMembersCard(context),
        SizedBox(height: context.rSpacing(20)),
        ListenableBuilder(
          listenable: repo,
          builder: (context, _) => _buildSprintCard(context, repo),
        ),
        SizedBox(height: context.rSpacing(20)),
        _buildResourcesCard(context),
      ],
    );
  }

  Widget _buildMembersCard(BuildContext context) {
    return Container(
      key: const ValueKey('desktop_workspace_members_card'),
      padding: EdgeInsets.all(context.rSpacing(22)),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Anggota Tim (${_members.length})',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(14, min: 13, max: 16),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              InkWell(
                key: const ValueKey('desktop_workspace_manage_members_btn'),
                onTap: onManageMembersTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(8),
                    vertical: context.rSpacing(4),
                  ),
                  child: Text(
                    'Manage',
                    style: TextStyle(
                      color: AppColors.primaryAccent,
                      fontSize: context.rFont(12, min: 11, max: 13),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.rSpacing(12)),
          for (var i = 0; i < _members.length; i++) ...[
            if (i > 0) SizedBox(height: context.rSpacing(12)),
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _members[i].color,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _members[i].initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(10, min: 9, max: 11),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: context.rSpacing(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _members[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(12, min: 11, max: 13.5),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _members[i].subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: context.rFont(10, min: 9, max: 11.5),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: context.rSpacing(8)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(7),
                    vertical: context.rSpacing(3.5),
                  ),
                  decoration: BoxDecoration(
                    color: _members[i].pillBgColor ?? _members[i].color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _members[i].role,
                    style: TextStyle(
                      color: _members[i].pillTextColor,
                      fontSize: context.rFont(9, min: 8.5, max: 11),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSprintCard(BuildContext context, TeamTaskRepository repo) {
    final tasks = repo.getTasks(teamCode);
    final totalCount = tasks.length;
    final completedCount = tasks.where((t) => t.isDone).length;
    final ratio = totalCount == 0 ? 0.0 : completedCount / totalCount;
    final percent = (ratio * 100).round();
    final milestones = repo.getMilestones(teamCode);
    final activeMilestone = milestones.isNotEmpty ? milestones.first : null;

    final nextMilestoneText = activeMilestone != null
        ? '${activeMilestone.title} (${activeMilestone.effectiveDueBadge})'
        : 'Testing & Code Freeze (Besok, 18:00 WIB)';

    return Container(
      key: const ValueKey('desktop_workspace_sprint_card'),
      padding: EdgeInsets.all(context.rSpacing(22)),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sprint 1 Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(14, min: 13, max: 16),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.rSpacing(14)),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$completedCount dari $totalCount Task Selesai',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: context.rFont(12, min: 11, max: 13),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: AppColors.primaryAccent,
                  fontSize: context.rFont(14, min: 13, max: 16),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          SizedBox(height: context.rSpacing(14)),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.bgPrimary,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryAccent,
              ),
            ),
          ),
          SizedBox(height: context.rSpacing(14)),
          Material(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onMilestoneTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: context.rSpacing(12),
                  vertical: context.rSpacing(10),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Milestone Berikutnya:',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: context.rFont(10, min: 9.5, max: 11.5),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextMilestoneText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(11, min: 10.5, max: 12.5),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesCard(BuildContext context) {
    return Container(
      key: const ValueKey('desktop_workspace_resources_card'),
      padding: EdgeInsets.all(context.rSpacing(22)),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resource & Dokumen Tim',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(14, min: 13, max: 16),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.rSpacing(12)),
          for (var i = 0; i < _resources.length; i++) ...[
            if (i > 0) SizedBox(height: context.rSpacing(12)),
            Material(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                key: ValueKey('desktop_workspace_resource_$i'),
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(text: _resources[i].url),
                  );
                  if (context.mounted) {
                    PopUpPemberitahuan.codeCopied(
                      context,
                      code: _resources[i].url,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(12),
                    vertical: context.rSpacing(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _resources[i].icon,
                        size: context.rIcon(16),
                        color: _resources[i].accentColor,
                      ),
                      SizedBox(width: context.rSpacing(10)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _resources[i].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.rFont(11, min: 10.5, max: 13),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _resources[i].subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: context.rFont(9.5, min: 9, max: 11),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: context.rSpacing(6)),
                      Icon(
                        Icons.copy_rounded,
                        size: context.rIcon(14),
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
