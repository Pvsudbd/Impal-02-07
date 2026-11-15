import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../common_widgets/impal_schedule_card.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../../schedule/models/schedule_model.dart';
import '../../../schedule/models/schedule_repository.dart';
import '../../../smart_system/models/smart_priority_repository.dart';
import '../../models/dashboard_models.dart';

/// Right-hand desktop panel (`350 dp`) displaying `Today's Schedule` carousel,
/// live `AI Smart Priority` status banner, KPI summary cards (`Avg. Progress` &
/// `Task Pending`), `Task Load Distribution` donut chart, and `Weekly Productivity`.
class DesktopStatsPanel extends StatefulWidget {
  final ScheduleItem fallbackSchedule;
  final int avgProgressPercent;
  final int pendingCount;
  final int completedCount;
  final int urgentDeadlineCount;
  final int collegeTaskCount;
  final int personalTaskCount;
  final VoidCallback onScheduleSeeAllTap;
  final ValueChanged<ScheduleModel> onEditSchedule;
  final ValueChanged<ScheduleModel> onDeleteSchedule;
  final ValueChanged<ScheduleModel> onToggleScheduleAlert;
  final VoidCallback onSmartPriorityTap;

  const DesktopStatsPanel({
    super.key,
    required this.fallbackSchedule,
    required this.avgProgressPercent,
    required this.pendingCount,
    required this.completedCount,
    required this.urgentDeadlineCount,
    required this.collegeTaskCount,
    required this.personalTaskCount,
    required this.onScheduleSeeAllTap,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
    required this.onToggleScheduleAlert,
    required this.onSmartPriorityTap,
  });

  @override
  State<DesktopStatsPanel> createState() => _DesktopStatsPanelState();
}

class _DesktopStatsPanelState extends State<DesktopStatsPanel> {
  int _scheduleIndex = 0;

  static int _statusRank(String status) {
    switch (status.trim().toLowerCase()) {
      case 'overdue':
        return 0;
      case 'ongoing':
        return 1;
      default:
        return 2;
    }
  }

  static DateTime _parseStartDateTime(ScheduleModel s) {
    final parts = s.timeStart.trim().split(':');
    final h = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 0) : 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return DateTime(s.date.year, s.date.month, s.date.day, h, m);
  }

  List<ScheduleModel> _sortSchedules(List<ScheduleModel> raw) {
    final copy = List<ScheduleModel>.of(raw);
    copy.sort((a, b) {
      final rankCmp = _statusRank(a.status).compareTo(_statusRank(b.status));
      if (rankCmp != 0) return rankCmp;
      return _parseStartDateTime(a).compareTo(_parseStartDateTime(b));
    });
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Today's Schedule header + multi-schedule switcher + live card
        _buildTodayScheduleSection(context),
        const SizedBox(height: 20),

        // 2. Dashboard Statistics Header + AI Smart Priority shortcut
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Statistics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(17, min: 15.5, max: 19),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Real-time performance & progress summary',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Open AI Smart Priority',
              child: InkWell(
                key: const ValueKey('desktop_smart_priority_btn'),
                onTap: widget.onSmartPriorityTap,
                borderRadius: BorderRadius.circular(10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.borderSubtle,
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.radar_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Live AI Smart Priority Banner (Mobile Parity)
        _buildLiveAiSmartPriorityBanner(),
        const SizedBox(height: 16),

        // 3. KPI Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _KpiAvgProgressCard(percent: widget.avgProgressPercent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiTaskPendingCard(
                pendingCount: widget.pendingCount,
                completedCount: widget.completedCount,
                urgentDeadlineCount: widget.urgentDeadlineCount,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // 4. Task Load Distribution Donut Card
        _TaskLoadDistributionCard(
          collegeCount: widget.collegeTaskCount,
          personalCount: widget.personalTaskCount,
        ),
        const SizedBox(height: 18),

        // 5. Weekly Productivity Bar Chart Card
        const _WeeklyProductivityCard(),
      ],
    );
  }

  Widget _buildTodayScheduleSection(BuildContext context) {
    return ValueListenableBuilder<List<ScheduleModel>>(
      valueListenable: ScheduleRepository().schedulesNotifier,
      builder: (context, repoSchedules, _) {
        final sorted = repoSchedules.isNotEmpty
            ? _sortSchedules(repoSchedules)
            : <ScheduleModel>[];

        final int safeIndex = sorted.isEmpty
            ? 0
            : _scheduleIndex.clamp(0, sorted.length - 1);

        final ScheduleModel item;
        if (sorted.isNotEmpty) {
          item = sorted[safeIndex];
        } else {
          final timeTokens = widget.fallbackSchedule.time
              .replaceAll('WIB', '')
              .split('-')
              .map((s) => s.trim())
              .toList();
          item = ScheduleModel(
            id: 'desktop_fallback_schedule',
            title: widget.fallbackSchedule.courseCode,
            date: DateTime.now(),
            timeStart: timeTokens.isNotEmpty && timeTokens.first.isNotEmpty
                ? timeTokens.first
                : '09:30',
            timeEnd: timeTokens.length > 1 && timeTokens[1].isNotEmpty
                ? timeTokens[1]
                : '11:30',
            type: 'Lecture',
            location: widget.fallbackSchedule.location,
            isAlertEnabled: true,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Today's Schedule",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(18, min: 15.5, max: 20),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (sorted.length > 1) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          key: const ValueKey('desktop_stats_schedule_prev'),
                          onTap: () {
                            setState(() {
                              _scheduleIndex =
                                  (safeIndex - 1 + sorted.length) %
                                  sorted.length;
                            });
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.chevron_left_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Text(
                            '${safeIndex + 1}/${sorted.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        InkWell(
                          key: const ValueKey('desktop_stats_schedule_next'),
                          onTap: () {
                            setState(() {
                              _scheduleIndex =
                                  (safeIndex + 1) % sorted.length;
                            });
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                InkWell(
                  onTap: widget.onScheduleSeeAllTap,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 7, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'See all',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ImpalScheduleCard(
              schedule: item,
              isLast: true,
              onTap: () => widget.onEditSchedule(item),
              onEdit: () => widget.onEditSchedule(item),
              onDelete: () => widget.onDeleteSchedule(item),
              onToggleAlert: () => widget.onToggleScheduleAlert(item),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLiveAiSmartPriorityBanner() {
    return ListenableBuilder(
      listenable: SmartPriorityRepository.instance,
      builder: (context, _) {
        final repo = SmartPriorityRepository.instance;
        final isActive = repo.isEngineActive;
        final top = repo.topPriority;

        return Material(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            key: const ValueKey('desktop_ai_smart_priority_banner'),
            onTap: widget.onSmartPriorityTap,
            borderRadius: BorderRadius.circular(14),
            hoverColor: Colors.white.withValues(alpha: 0.03),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive
                      ? PopUpPemberitahuan.positiveColor.withValues(alpha: 0.35)
                      : AppColors.borderSubtle,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryAccent
                          : const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Flexible(
                              child: Text(
                                'AI Smart Priority',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: (isActive
                                        ? PopUpPemberitahuan.positiveColor
                                        : AppColors.textMuted)
                                    .withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                isActive ? 'Mamdani Active' : 'Paused',
                                style: TextStyle(
                                  color: isActive
                                      ? PopUpPemberitahuan.positiveColor
                                      : AppColors.textMuted,
                                  fontSize: 9.5,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isActive && top != null
                              ? '#1 ${top.title} • Score ${top.score.toStringAsFixed(1)}'
                              : 'Click to configure Mamdani Fuzzy rules',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10.5,
                            fontFamily: 'Inter',
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.primaryAccent,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _KpiAvgProgressCard extends StatelessWidget {
  final int percent;

  const _KpiAvgProgressCard({required this.percent});

  @override
  Widget build(BuildContext context) {
    final normalized = (percent / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Avg. Progress',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.trending_up_rounded,
                size: 15,
                color: AppColors.mintAccent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$percent%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              const Flexible(
                child: Text(
                  '+12% this wk',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.mintAccent,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 6,
              backgroundColor: AppColors.bgPrimary,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.mintAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiTaskPendingCard extends StatelessWidget {
  final int pendingCount;
  final int completedCount;
  final int urgentDeadlineCount;

  const _KpiTaskPendingCard({
    required this.pendingCount,
    required this.completedCount,
    required this.urgentDeadlineCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Task Pending',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.hourglass_bottom_rounded,
                size: 14,
                color: AppColors.primaryAccent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$pendingCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '$completedCount completed',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$urgentDeadlineCount due < 6 days',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primaryAccent,
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskLoadDistributionCard extends StatelessWidget {
  final int collegeCount;
  final int personalCount;

  const _TaskLoadDistributionCard({
    required this.collegeCount,
    required this.personalCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = collegeCount + personalCount;
    final collegeRatio = total == 0 ? 0.5 : collegeCount / total;
    final personalRatio = total == 0 ? 0.5 : personalCount / total;
    final collegePct = (collegeRatio * 100).round();
    final personalPct = (personalRatio * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Task Load Distribution',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'By Category',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              RepaintBoundary(
                child: SizedBox(
                  width: 86,
                  height: 86,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      primaryRatio: collegeRatio,
                      primaryColor: AppColors.primary,
                      secondaryColor: AppColors.mintAccent,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _LegendBar(
                      dotColor: AppColors.primary,
                      label: 'College',
                      valueText: '$collegeCount tasks ($collegePct%)',
                      ratio: collegeRatio,
                    ),
                    const SizedBox(height: 12),
                    _LegendBar(
                      dotColor: AppColors.mintAccent,
                      label: 'Personal',
                      valueText: '$personalCount tasks ($personalPct%)',
                      ratio: personalRatio,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendBar extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String valueText;
  final double ratio;

  const _LegendBar({
    required this.dotColor,
    required this.label,
    required this.valueText,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                valueText,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: AppColors.bgPrimary,
            valueColor: AlwaysStoppedAnimation<Color>(dotColor),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double primaryRatio;
  final Color primaryColor;
  final Color secondaryColor;

  const _DonutPainter({
    required this.primaryRatio,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final secondaryPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final primaryPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, secondaryPaint);
    final sweep = 2 * math.pi * primaryRatio.clamp(0.0, 1.0);
    if (sweep > 0) {
      canvas.drawArc(rect, -math.pi / 2, sweep, false, primaryPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.primaryRatio != primaryRatio ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}

class _WeeklyProductivityCard extends StatelessWidget {
  const _WeeklyProductivityCard();

  static const _days = <_DayBarData>[
    _DayBarData(label: 'Mon', ratio: 0.43, color: AppColors.chartSlate),
    _DayBarData(label: 'Tue', ratio: 0.69, color: AppColors.chartSlate),
    _DayBarData(
      label: 'Wed',
      ratio: 1.0,
      color: AppColors.primaryAccent,
      isHighlight: true,
      peakText: '6.5h',
    ),
    _DayBarData(label: 'Thu', ratio: 0.59, color: AppColors.mintAccent),
    _DayBarData(label: 'Fri', ratio: 0.51, color: AppColors.chartSlate),
    _DayBarData(label: 'Sat', ratio: 0.29, color: Color(0xFF786FA6)),
    _DayBarData(label: 'Sun', ratio: 0.0, color: Colors.transparent),
  ];

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSubtle, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Productivity',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Focus hours & subtask completion',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    '24.5 Hrs',
                    style: TextStyle(
                      color: AppColors.mintAccent,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final day in _days)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 16,
                            child: day.peakText != null
                                ? Text(
                                    day.peakText!,
                                    style: const TextStyle(
                                      color: AppColors.primaryAccent,
                                      fontSize: 11,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 75,
                            width: 32,
                            decoration: BoxDecoration(
                              color: AppColors.chartTrack,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.bottomCenter,
                            child: day.ratio > 0
                                ? FractionallySizedBox(
                                    heightFactor: day.ratio,
                                    widthFactor: 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: day.color,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            day.label,
                            style: TextStyle(
                              color: day.isHighlight
                                  ? AppColors.primaryAccent
                                  : AppColors.textMuted,
                              fontSize: 11,
                              fontFamily: 'Inter',
                              fontWeight: day.isHighlight
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayBarData {
  final String label;
  final double ratio;
  final Color color;
  final bool isHighlight;
  final String? peakText;

  const _DayBarData({
    required this.label,
    required this.ratio,
    required this.color,
    this.isHighlight = false,
    this.peakText,
  });
}

