import 'package:flutter/material.dart';
import '../../../core/utils/top_toast.dart';

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
  int _currentTab = 2; // Team / Kelompok tab index

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
        TeamListContentView(
          userName: widget.userName,
          showBackButton:
              Navigator.of(context).canPop() || widget.onBackToHome != null,
          onBack: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomNavBar(),
        ),
      ],
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: const Color(0xFF282D37),
        body: SafeArea(
          top: true,
          bottom: false,
          child: content,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E222B),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 410,
                maxHeight: 844,
              ),
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

  Widget _buildBottomNavBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const double barTop = 26.0;
    const double circleTop = 2.0;
    const double circleDiameter = 54.0;
    const double circleRadius = circleDiameter / 2;
    const double circleCenterY = circleTop + circleRadius;
    const double gap = 6.0;
    const double notchRadius = circleRadius + gap;
    final totalHeight = barTop + 68.0 + bottomPadding;

    return SizedBox(
      height: totalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final tabWidth = width / 4;
          final activeCenterX = (_currentTab + 0.5) * tabWidth;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(width, totalHeight),
                painter: _ScoopedNavBarPainter(
                  centerX: activeCenterX,
                  barTop: barTop,
                  circleCenterY: circleCenterY,
                  notchRadius: notchRadius,
                  barColor: const Color(0xFF323846),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: barTop,
                height: 68.0,
                child: Row(
                  children: List.generate(4, (index) {
                    final isCurrent = index == _currentTab;
                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          if (index == 0) {
                            if (widget.onBackToHome != null) {
                              widget.onBackToHome!();
                            } else if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          } else {
                            setState(() => _currentTab = index);
                          }
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Center(
                          child: Opacity(
                            opacity: isCurrent ? 0.0 : 1.0,
                            child: Icon(
                              _getInactiveIcon(index),
                              color: const Color(0xFF8E95A5),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Positioned(
                left: activeCenterX - circleRadius,
                top: circleTop,
                width: circleDiameter,
                height: circleDiameter,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFD7357), Color(0xFFFA6144)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x66FA6144),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _getActiveIcon(_currentTab),
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getActiveIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.checklist_rounded;
      case 2:
        return Icons.groups_rounded;
      case 3:
      default:
        return Icons.calendar_month_rounded;
    }
  }

  IconData _getInactiveIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_outlined;
      case 1:
        return Icons.checklist_outlined;
      case 2:
        return Icons.groups_outlined;
      case 3:
      default:
        return Icons.calendar_month_outlined;
    }
  }
}

/// Team Item Model
class TeamModel {
  final String id;
  final String name;
  final String membersLabel;
  final List<Color> memberColors;

  const TeamModel({
    required this.id,
    required this.name,
    this.membersLabel = 'Team members',
    required this.memberColors,
  });
}

/// Reusable scrollable Team list content view
class TeamListContentView extends StatefulWidget {
  final String userName;
  final bool showBackButton;
  final VoidCallback? onBack;

  const TeamListContentView({
    super.key,
    this.userName = 'Jarvis',
    this.showBackButton = false,
    this.onBack,
  });

  @override
  State<TeamListContentView> createState() => _TeamListContentViewState();
}

class _TeamListContentViewState extends State<TeamListContentView> {
  final List<TeamModel> _teams = [
    const TeamModel(
      id: '1',
      name: 'Kelompok - IMPAL',
      memberColors: [
        Color(0xFFF3A683),
        Color(0xFF786FA6),
        Color(0xFF63CDDA),
        Color(0xFFE77F67),
        Color(0xFF778BEB),
      ],
    ),
    const TeamModel(
      id: '2',
      name: 'Kelompok - IUM',
      memberColors: [
        Color(0xFFF3A683),
        Color(0xFF786FA6),
        Color(0xFF63CDDA),
      ],
    ),
    const TeamModel(
      id: '3',
      name: 'Kelompok - Projek TIK',
      memberColors: [
        Color(0xFFF3A683),
        Color(0xFF786FA6),
        Color(0xFF63CDDA),
        Color(0xFFE77F67),
      ],
    ),
    const TeamModel(
      id: '4',
      name: 'Kelompok - KA',
      memberColors: [
        Color(0xFFF3A683),
        Color(0xFF786FA6),
        Color(0xFF63CDDA),
        Color(0xFF778BEB),
      ],
    ),
  ];

  String _getUserInitials(String name) {
    if (name.trim().isEmpty) return 'JS';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  void _showJoinTeamDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF282D37),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Join Team',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter invite code or team link:',
              style: TextStyle(
                color: Color(0xFF8E95A5),
                fontSize: 12.5,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. IMPAL-2026',
                hintStyle: const TextStyle(color: Color(0xFF606775), fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF323846),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E95A5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFA6144),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              final code = controller.text.trim();
              Navigator.pop(ctx);
              if (code.isNotEmpty) {
                showTopToast(context, 'Joined team "$code" successfully!');
              }
            },
            child: const Text('Join', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateTeamDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF282D37),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Create Team',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your team or project name:',
              style: TextStyle(
                color: Color(0xFF8E95A5),
                fontSize: 12.5,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Kelompok - RPL',
                hintStyle: const TextStyle(color: Color(0xFF606775), fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF323846),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E95A5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFA6144),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              final name = controller.text.trim();
              Navigator.pop(ctx);
              if (name.isNotEmpty) {
                setState(() {
                  _teams.insert(
                    0,
                    TeamModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      memberColors: const [
                        Color(0xFFF3A683),
                        Color(0xFF786FA6),
                        Color(0xFF63CDDA),
                      ],
                    ),
                  );
                });
                showTopToast(context, 'Team "$name" created!');
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const ValueKey('team_list_scroll_view'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Header (Greeting + Subtitle + User Profile Initials)
              _buildHeader(),
              const SizedBox(height: 16),

              // 2. Team's Schedule Section
              _buildTeamScheduleSection(),
              const SizedBox(height: 22),

              // 3. Team List Section (with Join & Create actions)
              _buildTeamsSection(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final initials = _getUserInitials(widget.userName);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              if (widget.showBackButton) ...[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        widget.onBack ?? () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF323846),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: const Color(0xFF3B4150), width: 1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hi ${widget.userName}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Team List',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFFFF7D65),
                        fontSize: 12.5,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF323846),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF3B4150), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              color: Color(0xFF8E95A5),
              fontSize: 13.5,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Team's Schedule",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF323846),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left gray accent stripe from Figma
                Container(
                  width: 5,
                  color: const Color(0xFF8E95A5),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MEETING IMPAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Discord - Group IMPAL',
                          style: TextStyle(
                            color: Color(0xFF8E95A5),
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8E95A5).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.access_time_filled_rounded,
                                size: 10,
                                color: Color(0xFF8E95A5),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Tomorrow 19:00 WIB',
                              style: TextStyle(
                                color: Color(0xFF8E95A5),
                                fontSize: 11,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                const SizedBox(width: 8),

                // Create Team Button
                InkWell(
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
        const SizedBox(height: 14),

        // Team Cards List
        for (int i = 0; i < _teams.length; i++) ...[
          _buildTeamCard(_teams[i]),
          if (i < _teams.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildTeamCard(TeamModel team) {
    return InkWell(
      onTap: () {
        showTopToast(context, 'Selected ${team.name}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF323846),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              team.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              team.membersLabel,
              style: const TextStyle(
                color: Color(0xFF8E95A5),
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 7),
            _buildAvatarStack(team.memberColors),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack(List<Color> colors) {
    const double size = 24.0;
    const double overlap = 16.0;
    final displayColors = colors.take(5).toList();
    final extraCount = colors.length - displayColors.length;

    return SizedBox(
      height: size,
      width: size +
          (displayColors.length - 1 + (extraCount > 0 ? 1 : 0)) * overlap,
      child: Stack(
        children: [
          for (int i = 0; i < displayColors.length; i++)
            Positioned(
              left: i * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: displayColors[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF323846), width: 2),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: displayColors.length * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFF434A59),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF323846), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extraCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScoopedNavBarPainter extends CustomPainter {
  final double centerX;
  final double barTop;
  final double circleCenterY;
  final double notchRadius;
  final Color barColor;

  const _ScoopedNavBarPainter({
    required this.centerX,
    required this.barTop,
    required this.circleCenterY,
    required this.notchRadius,
    required this.barColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double left = 0;
    final double right = size.width;
    final double top = barTop;
    final double bottom = size.height;
    const double cr = 5.0;

    final double R = notchRadius;
    const double r = 10.0;
    final double h = top - circleCenterY;

    final double dSq = (R + r) * (R + r) - (h + r) * (h + r);
    final double d = dSq > 0 ? dSq : 0;
    final double actualD = d > 0 ? d.clamp(0.0, 10000.0) : 0.0;

    final double notchLeft = centerX - (actualD > 0 ? 33.0 : 33.0);
    final double notchRight = centerX + (actualD > 0 ? 33.0 : 33.0);

    final path = Path()
      ..moveTo(left, top + cr)
      ..arcToPoint(Offset(left + cr, top), radius: const Radius.circular(cr))
      ..lineTo(notchLeft - r, top)
      ..arcToPoint(
        Offset(notchLeft, top + 4),
        radius: const Radius.circular(r),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(notchRight, top + 4),
        radius: Radius.circular(R),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(notchRight + r, top),
        radius: const Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(right - cr, top)
      ..arcToPoint(Offset(right, top + cr), radius: const Radius.circular(cr))
      ..lineTo(right, bottom)
      ..lineTo(left, bottom)
      ..close();

    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScoopedNavBarPainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.barTop != barTop ||
        oldDelegate.circleCenterY != circleCenterY ||
        oldDelegate.notchRadius != notchRadius ||
        oldDelegate.barColor != barColor;
  }
}