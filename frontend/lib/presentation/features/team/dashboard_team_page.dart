import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../dashboard/home_page.dart';
import '../jadwal/models/schedule_model.dart';
import '../jadwal/models/schedule_repository.dart';
import '../jadwal/schedule_form_page.dart';
import '../jadwal/schedule_page.dart';

/// Aliases for backward compatibility with Figma export & routes
typedef DashboardKelompok = DashboardTeamPage;
typedef DashboardTeamPageAlias = DashboardTeamPage;

/// Priority level for team tasks
enum TaskPriority { high, medium, low }

/// Model representing a task in the team dashboard
class TeamTaskModel {
  final String id;
  final String title;
  final TaskPriority priority;
  final String assignedTo;
  final Color assigneeColor;
  final String timeRange;
  final bool isDone;

  const TeamTaskModel({
    required this.id,
    required this.title,
    required this.priority,
    required this.assignedTo,
    required this.assigneeColor,
    required this.timeRange,
    this.isDone = false,
  });

  TeamTaskModel copyWith({
    String? id,
    String? title,
    TaskPriority? priority,
    String? assignedTo,
    Color? assigneeColor,
    String? timeRange,
    bool? isDone,
  }) {
    return TeamTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      assigneeColor: assigneeColor ?? this.assigneeColor,
      timeRange: timeRange ?? this.timeRange,
      isDone: isDone ?? this.isDone,
    );
  }
}

/// Standalone & embedded Team Dashboard Page
class DashboardTeamPage extends StatefulWidget {
  final String userName;
  final String teamName;
  final String teamCode;
  final List<Color> memberColors;
  final bool isStandalone;
  final VoidCallback? onBack;

  const DashboardTeamPage({
    super.key,
    this.userName = 'Jarvis',
    this.teamName = 'Kelompok IMPAL',
    this.teamCode = '7X29',
    this.memberColors = const [
      Color(0xFFF3A683),
      Color(0xFF786FA6),
      Color(0xFF63CDDA),
      Color(0xFFE77F67),
      Color(0xFF778BEB),
    ],
    this.isStandalone = true,
    this.onBack,
  });

  @override
  State<DashboardTeamPage> createState() => _DashboardTeamPageState();
}

class _DashboardTeamPageState extends State<DashboardTeamPage> {
  int _currentTab = 2; // Team tab active by default
  late List<TeamTaskModel> _tasks;

  @override
  void initState() {
    super.initState();
    ScheduleRepository().init();
    _tasks = [
      const TeamTaskModel(
        id: 'task_1',
        title: 'Membuat ui page kelompok',
        priority: TaskPriority.high,
        assignedTo: 'Yoga Perkasa Didik',
        assigneeColor: Color(0xFFF3A683),
        timeRange: '09:30 - 11:30 WIB',
      ),
      const TeamTaskModel(
        id: 'task_2',
        title: 'Membuat ui page home',
        priority: TaskPriority.medium,
        assignedTo: 'Yoga Perkasa Didik',
        assigneeColor: Color(0xFFF3A683),
        timeRange: '09:30 - 11:30 WIB',
      ),
      const TeamTaskModel(
        id: 'task_3',
        title: 'Membuat ui form tugas',
        priority: TaskPriority.low,
        assignedTo: 'Yoga Perkasa Didik',
        assigneeColor: Color(0xFFF3A683),
        timeRange: '09:30 - 11:30 WIB',
      ),
    ];
  }

  /// Copy team invite code and show notification pop-up
  Future<void> _copyTeamCode() async {
    HapticFeedback.lightImpact();
    PopUpPemberitahuan.codeCopied(context, code: widget.teamCode);
    try {
      await Clipboard.setData(ClipboardData(text: widget.teamCode));
    } catch (_) {}
  }

  void _openCreateMeeting() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ScheduleFormPage(
          initialType: 'External',
        ),
      ),
    );
  }

  void _openEditSchedule(ScheduleModel schedule) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScheduleFormPage(
          schedule: schedule,
        ),
      ),
    );
  }

  void _showCreateTaskDialog() {
    final titleController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF282D37),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF3B4150), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create Team Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF8E95A5), size: 18),
                          onPressed: () => Navigator.of(ctx).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Task Title (e.g. Slicing UI)',
                        hintStyle: const TextStyle(color: Color(0xFF8E95A5), fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF323846),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Priority',
                      style: TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final p in TaskPriority.values) ...[
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setDialogState(() => selectedPriority = p),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selectedPriority == p
                                      ? const Color(0xFFFA6144)
                                      : const Color(0xFF323846),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  p.name.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: selectedPriority == p
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (p != TaskPriority.values.last) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFA6144),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          final text = titleController.text.trim();
                          if (text.isNotEmpty) {
                            setState(() {
                              _tasks.insert(
                                0,
                                TeamTaskModel(
                                  id: 'task_${DateTime.now().millisecondsSinceEpoch}',
                                  title: text,
                                  priority: selectedPriority,
                                  assignedTo: widget.userName,
                                  assigneeColor: widget.memberColors.first,
                                  timeRange: 'Today',
                                ),
                              );
                            });
                            Navigator.of(ctx).pop();
                            PopUpPemberitahuan.success(
                              context,
                              title: 'Task Created',
                              message: 'Team task "$text" has been added.',
                            );
                          }
                        },
                        child: const Text(
                          'Add Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getUserInitials(String name) {
    if (name.trim().isEmpty) return 'JS';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final content = Stack(
      children: [
        CustomScrollView(
          key: const ValueKey('dashboard_team_scroll_view'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Header (Greeting + User Profile Initials)
                  _buildHeader(),
                  const SizedBox(height: 18),

                  // 2. Team Info (Name, Member Avatars, Copy Code)
                  _buildTeamInfoBar(),
                  const SizedBox(height: 22),

                  // 3. Team's Schedule Section
                  _buildTeamScheduleSection(),
                  const SizedBox(height: 22),

                  // 4. Team Task Section
                  _buildTeamTaskSection(),
                ]),
              ),
            ),
          ],
        ),
        // Floating Bottom Navigation Bar
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

  // --- UI Sections ---

  Widget _buildHeader() {
    final initials = _getUserInitials(widget.userName);
    final canPop = Navigator.of(context).canPop() || widget.onBack != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              if (canPop) ...[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF323846),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF3B4150), width: 1),
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
                      'Team Dashboard',
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
          width: 44,
          height: 44,
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
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamInfoBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Team name & Overlapping Avatars
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.teamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.04,
                  ),
                ),
                const SizedBox(height: 8),
                // Overlapping avatar circles
                SizedBox(
                  height: 26,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (int i = 0; i < widget.memberColors.length; i++)
                        Positioned(
                          left: i * 19.0,
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: widget.memberColors[i],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF323846),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Right: Team Code Button (Tap to copy + show notification)
          GestureDetector(
            key: const ValueKey('team_dashboard_copy_code_button'),
            behavior: HitTestBehavior.opaque,
            onTap: _copyTeamCode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF282D37),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFA6144),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.copy_rounded,
                    color: Color(0xFFFA6144),
                    size: 13,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.teamCode,
                    style: const TextStyle(
                      color: Color(0xFFFA6144),
                      fontSize: 14.5,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.03,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScheduleSection() {
    return ValueListenableBuilder<List<ScheduleModel>>(
      valueListenable: ScheduleRepository().schedulesNotifier,
      builder: (context, allSchedules, _) {
        // Filter strictly for team meetings (no lectures)
        final teamSchedules = allSchedules.where((s) {
          final type = s.type.trim().toLowerCase();
          if (type == 'lecture') return false;
          if (type == 'team' ||
              type == 'meeting' ||
              type == 'team meeting' ||
              type == 'rapat') {
            return true;
          }
          final t = s.title.toLowerCase();
          final n = (s.notes ?? '').toLowerCase();
          final loc = (s.location ?? '').toLowerCase();
          return t.contains('meet') ||
              t.contains('team') ||
              t.contains('tim') ||
              t.contains('kelompok') ||
              t.contains('mentoring') ||
              t.contains('rapat') ||
              n.contains('meet') ||
              n.contains('team') ||
              loc.contains('group') ||
              loc.contains('discord') ||
              type == 'external';
        }).toList();

        final displaySchedule = teamSchedules.isNotEmpty
            ? teamSchedules.first
            : ScheduleRepository.defaultTeamSchedule;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    "Team's Schedule",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.04,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // + Create Meeting Action
                GestureDetector(
                  key: const ValueKey('dashboard_create_meeting_button'),
                  onTap: _openCreateMeeting,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFA6144),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '+ Create Meeting',
                      style: TextStyle(
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
            const SizedBox(height: 12),
            // Schedule Card
            _buildScheduleCard(displaySchedule),
          ],
        );
      },
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF323846),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openEditSchedule(schedule),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent stripe
                Container(
                  width: 5,
                  color: schedule.accentColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                schedule.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Status Pill matching schedule_page style
                            if (schedule.status.toLowerCase() == 'completed')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 9.5,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.25,
                                  ),
                                ),
                              )
                            else if (schedule.status.toLowerCase() == 'ongoing')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF826E),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Ongoing',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.25,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8E95A5).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Upcoming',
                                  style: TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 9.5,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.25,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (schedule.location != null &&
                            schedule.location!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            schedule.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF8E95A5),
                              fontSize: 11,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8E95A5).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.access_time_filled_rounded,
                                size: 9,
                                color: Color(0xFF8E95A5),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              schedule.formattedTime,
                              style: const TextStyle(
                                color: Color(0xFF8E95A5),
                                fontSize: 10.8,
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
      ),
    );
  }

  Widget _buildTeamTaskSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'Team Task',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.04,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // + Create Task Action
            GestureDetector(
              key: const ValueKey('dashboard_create_task_button'),
              onTap: _showCreateTaskDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFA6144),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '+ Create Task',
                  style: TextStyle(
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
        const SizedBox(height: 12),
        // Task Cards List
        for (int i = 0; i < _tasks.length; i++) ...[
          _buildTaskCard(_tasks[i]),
          if (i < _tasks.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildTaskCard(TeamTaskModel task) {
    Color priorityColor;
    Color priorityTextColor;
    String priorityText;

    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = const Color(0xFFFA6144);
        priorityTextColor = Colors.white;
        priorityText = 'HIGH';
        break;
      case TaskPriority.medium:
        priorityColor = const Color(0xFFFBBF24);
        priorityTextColor = const Color(0xFF1F2937);
        priorityText = 'MEDIUM';
        break;
      case TaskPriority.low:
        priorityColor = const Color(0xFF6EE7B7);
        priorityTextColor = const Color(0xFF064E3B);
        priorityText = 'LOW';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          // Title + Priority Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.8,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  priorityText,
                  style: TextStyle(
                    color: priorityTextColor,
                    fontSize: 9.5,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // "Assign to:" label & Deadline/Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Assign to:',
                style: TextStyle(
                  color: Color(0xFF8E95A5),
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7D65).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.access_time_filled_rounded,
                      size: 9,
                      color: Color(0xFFFF7D65),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    task.timeRange,
                    style: const TextStyle(
                      color: Color(0xFF8E95A5),
                      fontSize: 10.8,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Assignee Profile
          Row(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: task.assigneeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF323846),
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                task.assignedTo,
                style: const TextStyle(
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
    );
  }

  // --- Bottom Navigation Bar ---

  Widget _buildBottomNavBar() {
    return Container(
      height: 94,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          final tabWidth = barWidth / 4;
          final activeCenterX = tabWidth * _currentTab + (tabWidth / 2);
          const circleDiameter = 54.0;
          const circleRadius = circleDiameter / 2;
          const barHeight = 64.0;
          const circleTop = 2.0;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF323846),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(4, (index) {
                      final isActive = _currentTab == index;
                      return Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onTabSelected(index),
                            borderRadius: BorderRadius.circular(24),
                            child: Center(
                              child: Opacity(
                                opacity: isActive ? 0.0 : 1.0,
                                child: Icon(
                                  _getInactiveIcon(index),
                                  color: const Color(0xFF8E95A5),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              // Floating Active Icon Indicator
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

  void _onTabSelected(int index) {
    if (index == _currentTab) return;
    setState(() => _currentTab = index);

    if (index == 0) {
      // Home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else if (index == 2) {
      // Team List / Kelompok
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else if (index == 3) {
      // Schedule
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
