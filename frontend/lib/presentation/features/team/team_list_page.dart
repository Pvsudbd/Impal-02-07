import 'package:flutter/material.dart';
import '../../common_widgets/impal_bottom_nav_bar.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../schedule/models/schedule_model.dart';
import '../schedule/models/schedule_repository.dart';
import '../schedule/pop_up_konfirmasi_delete.dart';
import '../schedule/schedule_page.dart';
import '../dashboard/home_page.dart';
import '../task/task_page.dart';
import 'dashboard_team_page.dart';
import 'models/team_model.dart';
import 'models/team_repository.dart';
import 'pop_up_create_meeting.dart';
import 'pop_up_create_team.dart';
import 'pop_up_join_team.dart';
import 'widgets/team_card.dart';
import 'widgets/team_header.dart';
import 'widgets/team_schedule_section.dart';

export 'models/team_model.dart';
export 'models/team_repository.dart';

/// Aliases for backwards compatibility with Figma export & routes
typedef ListKelompok = TeamListPage;
typedef TeamPage = TeamListPage;

/// Full standalone Team/Kelompok List Page
class TeamListPage extends StatefulWidget {
  final String userName;
  final bool isStandalone;
  final VoidCallback? onBackToHome;

  const TeamListPage({
    super.key,
    this.userName = 'Jarvis',
    this.isStandalone = true,
    this.onBackToHome,
  });

  @override
  State<TeamListPage> createState() => _TeamListPageState();
}

class _TeamListPageState extends State<TeamListPage> {
  int _currentTab = 2;

  @override
  void initState() {
    super.initState();
    ScheduleRepository().init();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isStandalone) {
      return TeamListContentView(
        userName: widget.userName,
        showBackButton: false,
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final content = Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _currentTab == 3
              ? ScheduleContentView(
                  key: const ValueKey('team_page_schedule_tab_content'),
                  userName: widget.userName,
                  showBackButton: false,
                )
              : (_currentTab == 1
                  ? TaskContentView(
                      key: const ValueKey('team_page_task_tab_content'),
                      userName: widget.userName,
                      showBackButton: false,
                    )
                  : TeamListContentView(
                      key: const ValueKey('team_page_list_content'),
                      userName: widget.userName,
                      showBackButton: false,
                      onOpenSchedule: () => setState(() => _currentTab = 3),
                    )),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ImpalBottomNavBar(
            currentTab: _currentTab,
            onTabSelected: (index) {
              if (index == 0) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => HomePage(
                      userName: widget.userName,
                      initialTab: 0,
                    ),
                  ),
                  (route) => false,
                );
              } else {
                setState(() => _currentTab = index);
              }
            },
          ),
        ),
      ],
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: const Color(0xFF282D37),
        body: SafeArea(top: true, bottom: false, child: content),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E222B),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 410, maxHeight: 844),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF282D37),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x8C000000),
                      blurRadius: 50,
                      offset: Offset(0, 25),
                      spreadRadius: -12,
                    ),
                  ],
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable scrollable Team list content view
class TeamListContentView extends StatefulWidget {
  final String userName;
  final bool showBackButton;
  final VoidCallback? onBack;
  final VoidCallback? onOpenSchedule;
  final ValueChanged<TeamModel>? onTeamSelected;

  const TeamListContentView({
    super.key,
    this.userName = 'Jarvis',
    this.showBackButton = false,
    this.onBack,
    this.onOpenSchedule,
    this.onTeamSelected,
  });

  @override
  State<TeamListContentView> createState() => _TeamListContentViewState();
}

class _TeamListContentViewState extends State<TeamListContentView> {
  @override
  void initState() {
    super.initState();
    ScheduleRepository().init();
  }

  void _openSchedulePage() {
    if (widget.onOpenSchedule != null) {
      widget.onOpenSchedule!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SchedulePage(
            userName: widget.userName,
            isStandalone: true,
          ),
        ),
      );
    }
  }

  void _openEditSchedule(ScheduleModel schedule) async {
    final result = await PopUpCreateMeeting.showEdit(
      context,
      schedule: schedule,
    );
    if (result != null && mounted) {
      PopUpPemberitahuan.meetingUpdated(context);
    }
  }

  void _deleteSchedule(ScheduleModel item) async {
    final isMeeting = item.type.toLowerCase() == 'meeting';
    final confirmed = await PopUpKonfirmasiDelete.show(
      context,
      title: isMeeting ? 'Delete Meeting?' : 'Delete Schedule?',
      message: isMeeting
          ? 'Are you sure you want to delete this meeting? This action cannot be undone.'
          : 'Are you sure you want to delete this schedule? This action cannot be undone.',
    );
    if (confirmed == true) {
      await ScheduleRepository().deleteSchedule(item.id);
      if (mounted) {
        if (isMeeting) {
          PopUpPemberitahuan.meetingDeleted(context);
        } else {
          PopUpPemberitahuan.scheduleDeleted(context);
        }
      }
    }
  }

  void _openAddTeamSchedule() async {
    final result = await PopUpCreateMeeting.show(context);
    if (result != null && mounted) {
      PopUpPemberitahuan.meetingCreated(context);
    }
  }

  List<TeamModel> get _teams => TeamRepository().teams;

  void _showJoinTeamDialog() async {
    final code = await PopUpJoinTeam.show(context);
    if (!mounted || code == null || code.trim().isEmpty) return;
    PopUpPemberitahuan.teamJoined(context, inviteCode: code);
  }

  void _showCreateTeamDialog() async {
    final result = await PopUpCreateTeam.show(context);
    if (!mounted || result == null || result.name.trim().isEmpty) return;
    final newTeam = TeamModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: result.name,
      memberColors: const [
        Color(0xFFF3A683),
        Color(0xFF786FA6),
        Color(0xFF63CDDA),
      ],
    );
    TeamRepository().addTeam(newTeam);
    setState(() {});
    PopUpPemberitahuan.teamCreated(
      context,
      teamName: result.name,
      inviteCode: result.inviteCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const ValueKey('team_list_scroll_view'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 96),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              TeamHeader(
                userName: widget.userName,
                subtitle: 'Team List',
                showBackButton: widget.showBackButton,
                onBack: widget.onBack,
              ),
              const SizedBox(height: 16),
              TeamScheduleSection(
                isDashboard: false,
                onActionTap: _openSchedulePage,
                onAddScheduleTap: _openAddTeamSchedule,
                onEditSchedule: _openEditSchedule,
                onDeleteSchedule: _deleteSchedule,
              ),
              const SizedBox(height: 16),
              _buildTeamsSection(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Team',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Join Team Button
                InkWell(
                  key: const ValueKey('team_list_join_team_button'),
                  onTap: _showJoinTeamDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF323846),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.login_rounded,
                          color: Color(0xFF8E95A5),
                          size: 13,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Join Team',
                          style: TextStyle(
                            color: Color(0xFF8E95A5),
                            fontSize: 10,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Create Team Button
                InkWell(
                  key: const ValueKey('team_list_create_team_button'),
                  onTap: _showCreateTeamDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFA6144),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '+ Create Team',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        for (int i = 0; i < _teams.length; i++) ...[
          TeamCard(
            team: _teams[i],
            onTap: () {
              if (widget.onTeamSelected != null) {
                widget.onTeamSelected!(_teams[i]);
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DashboardTeamPage(
                      userName: widget.userName,
                      teamName: _teams[i].name,
                      teamCode: '7X29',
                      memberColors: _teams[i].memberColors,
                    ),
                  ),
                );
              }
            },
          ),
          if (i < _teams.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
