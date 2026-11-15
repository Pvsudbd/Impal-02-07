import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../models/team_task_repository.dart';

class _WorkspaceMemberMeta {
  final String initials;
  final String name;
  final String role;
  final Color color;

  const _WorkspaceMemberMeta({
    required this.initials,
    required this.name,
    required this.role,
    required this.color,
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

/// Right-hand desktop workspace panel rendered beside [DashboardTeamPage] on
/// desktop viewports (`width >= 1024`).
class DesktopTeamWorkspacePanel extends StatelessWidget {
  final String teamCode;
  final String teamName;
  final VoidCallback onManageMembersTap;

  const DesktopTeamWorkspacePanel({
    super.key,
    required this.teamCode,
    required this.teamName,
    required this.onManageMembersTap,
  });

  static const List<_WorkspaceMemberMeta> _members = [
    _WorkspaceMemberMeta(
      initials: 'JS',
      name: 'Jehan Shafa',
      role: 'Lead',
      color: Color(0xFFFF7D65),
    ),
    _WorkspaceMemberMeta(
      initials: 'AS',
      name: 'Ahmad Sahroni',
      role: 'Backend',
      color: Color(0xFF63CDDA),
    ),
    _WorkspaceMemberMeta(
      initials: 'MK',
      name: 'Muhammad Kafi',
      role: 'Frontend',
      color: Color(0xFF786FA6),
    ),
    _WorkspaceMemberMeta(
      initials: 'YP',
      name: 'Yoga Perkasa',
      role: 'UI/UX',
      color: Color(0xFFF3A683),
    ),
    _WorkspaceMemberMeta(
      initials: 'RD',
      name: 'Raka Darma',
      role: 'QA',
      color: Color(0xFF778BEB),
    ),
  ];

  static const List<_WorkspaceResourceMeta> _resources = [
    _WorkspaceResourceMeta(
      title: 'Figma Prototype IMPAL',
      subtitle: 'Design System & Flows',
      url: 'https://figma.com/file/impal-prototype',
      icon: Icons.design_services_rounded,
      accentColor: Color(0xFFFF7D65),
    ),
    _WorkspaceResourceMeta(
      title: 'GitHub Repository App',
      subtitle: 'Flutter + Dart Frog Repo',
      url: 'https://github.com/impal-02-07/app',
      icon: Icons.code_rounded,
      accentColor: Color(0xFF63CDDA),
    ),
    _WorkspaceResourceMeta(
      title: 'SRS & API Spec v2',
      subtitle: 'Documentation & Contracts',
      url: 'https://docs.impal-team.id/srs-v2',
      icon: Icons.description_rounded,
      accentColor: Color(0xFF778BEB),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final repo = TeamTaskRepository();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMembersCard(context),
        SizedBox(height: context.rSpacing(16)),
        ListenableBuilder(
          listenable: repo,
          builder: (context, _) => _buildSprintCard(context, repo),
        ),
        SizedBox(height: context.rSpacing(16)),
        _buildResourcesCard(context),
      ],
    );
  }

  Widget _buildMembersCard(BuildContext context) {
    return Container(
      key: const ValueKey('desktop_workspace_members_card'),
      padding: EdgeInsets.all(context.rSpacing(18)),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
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
                    vertical: context.rSpacing(6),
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
            if (i > 0) SizedBox(height: context.rSpacing(10)),
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: _members[i].color,
                  child: Text(
                    _members[i].initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(10, min: 9, max: 12),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: context.rSpacing(10)),
                Expanded(
                  child: Text(
                    _members[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(12.5, min: 11.5, max: 14),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(8),
                    vertical: context.rSpacing(3),
                  ),
                  decoration: BoxDecoration(
                    color: _members[i].color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _members[i].role,
                    style: TextStyle(
                      color: _members[i].color,
                      fontSize: context.rFont(10.5, min: 10, max: 12),
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

    return Container(
      key: const ValueKey('desktop_workspace_sprint_card'),
      padding: EdgeInsets.all(context.rSpacing(18)),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
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
                  'Sprint & Milestone Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(14, min: 13, max: 16),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
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
          SizedBox(height: context.rSpacing(6)),
          Text(
            '$completedCount of $totalCount tasks completed • $teamName',
            style: TextStyle(
              color: Colors.white70,
              fontSize: context.rFont(11.5, min: 11, max: 13),
              fontFamily: 'Inter',
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: context.rSpacing(10)),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: AppColors.bgPrimary,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryAccent,
              ),
            ),
          ),
          if (activeMilestone != null) ...[
            SizedBox(height: context.rSpacing(14)),
            Container(
              padding: EdgeInsets.all(context.rSpacing(12)),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.flag_rounded,
                    size: context.rIcon(16),
                    color: AppColors.primaryAccent,
                  ),
                  SizedBox(width: context.rSpacing(8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeMilestone.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(12, min: 11, max: 13),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: context.rSpacing(2)),
                        Text(
                          activeMilestone.effectiveFormattedDeadline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: context.rFont(10.5, min: 10, max: 12),
                            fontFamily: 'Inter',
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.rSpacing(8)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rSpacing(8),
                      vertical: context.rSpacing(3),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B93FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      activeMilestone.effectiveDueBadge,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(10.5, min: 10, max: 11.5),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResourcesCard(BuildContext context) {
    return Container(
      key: const ValueKey('desktop_workspace_resources_card'),
      padding: EdgeInsets.all(context.rSpacing(18)),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
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
            if (i > 0) SizedBox(height: context.rSpacing(8)),
            Material(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(10),
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
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(12),
                    vertical: context.rSpacing(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _resources[i].accentColor.withValues(
                            alpha: 0.16,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _resources[i].icon,
                          size: context.rIcon(16),
                          color: _resources[i].accentColor,
                        ),
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
                                fontSize: context.rFont(12, min: 11, max: 13.5),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _resources[i].subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: context.rFont(10.5, min: 10, max: 12),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.copy_rounded,
                        size: context.rIcon(15),
                        color: Colors.white54,
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

