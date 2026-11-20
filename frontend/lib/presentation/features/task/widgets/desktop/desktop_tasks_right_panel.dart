import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../smart_system/models/smart_priority_model.dart';

/// Collaborator summary displayed in the desktop Tasks right rail.
class DesktopCollaboratorSummary {
  final String initials;
  final String name;
  final String taskSubtitle;
  final String roleLabel;
  final Color avatarColor;
  final Color badgeBg;
  final Color badgeTextColor;

  const DesktopCollaboratorSummary({
    required this.initials,
    required this.name,
    required this.taskSubtitle,
    required this.roleLabel,
    required this.avatarColor,
    required this.badgeBg,
    required this.badgeTextColor,
  });
}

/// Right-hand column for Desktop Tasks Management (`310–350 dp`), matching
/// FigCraft node 2372: Monthly Calendar, Fuzzy Mamdani Weight, and Team Collaborators.
class DesktopTasksRightPanel extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final Set<DateTime> deadlineDates;
  final int todayDeadlineCount;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;
  final SmartPriorityModel? topPriority;
  final bool isFuzzyEngineActive;
  final VoidCallback onFuzzyCardTap;
  final List<DesktopCollaboratorSummary> collaborators;
  final ValueChanged<DesktopCollaboratorSummary> onCollaboratorTap;

  const DesktopTasksRightPanel({
    super.key,
    required this.focusedMonth,
    this.selectedDate,
    required this.deadlineDates,
    required this.todayDeadlineCount,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
    this.topPriority,
    required this.isFuzzyEngineActive,
    required this.onFuzzyCardTap,
    required this.collaborators,
    required this.onCollaboratorTap,
  });

  @override
  Widget build(BuildContext context) {
    final gap = context.rSpacing(20);
    final calendarCard = RepaintBoundary(
      child: _MonthlyCalendarCard(
        focusedMonth: focusedMonth,
        selectedDate: selectedDate,
        deadlineDates: deadlineDates,
        todayDeadlineCount: todayDeadlineCount,
        onPreviousMonth: onPreviousMonth,
        onNextMonth: onNextMonth,
        onDateSelected: onDateSelected,
      ),
    );
    final fuzzyCard = RepaintBoundary(
      child: _FuzzyMamdaniWeightCard(
        topPriority: topPriority,
        isEngineActive: isFuzzyEngineActive,
        onTap: onFuzzyCardTap,
      ),
    );
    final collaboratorsCard = RepaintBoundary(
      child: _ActiveCollaboratorsCard(
        collaborators: collaborators,
        onCollaboratorTap: onCollaboratorTap,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 520.0) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: calendarCard),
              SizedBox(width: gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    fuzzyCard,
                    SizedBox(height: gap),
                    collaboratorsCard,
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            calendarCard,
            SizedBox(height: gap),
            fuzzyCard,
            SizedBox(height: gap),
            collaboratorsCard,
          ],
        );
      },
    );
  }
}

class _MonthlyCalendarCard extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final Set<DateTime> deadlineDates;
  final int todayDeadlineCount;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;

  const _MonthlyCalendarCard({
    required this.focusedMonth,
    required this.selectedDate,
    required this.deadlineDates,
    required this.todayDeadlineCount,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final radius = context.rSpacing(20);
    final monthLabel = DateFormat('MMMM yyyy').format(focusedMonth);
    final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final startOffset = firstOfMonth.weekday - 1; // Monday = 0
    final gridStart = firstOfMonth.subtract(Duration(days: startOffset));
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final totalCells = ((startOffset + daysInMonth) > 35) ? 42 : 35;

    const weekdayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(20),
        vertical: context.rSpacing(18),
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.borderSubtle, width: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  monthLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(16, min: 14, max: 18),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              _CalendarNavButton(
                buttonKey: const ValueKey('desktop_cal_prev'),
                icon: Icons.chevron_left_rounded,
                tooltip: 'Previous month',
                onTap: onPreviousMonth,
              ),
              _CalendarNavButton(
                buttonKey: const ValueKey('desktop_cal_next'),
                icon: Icons.chevron_right_rounded,
                tooltip: 'Next month',
                onTap: onNextMonth,
              ),
            ],
          ),
          SizedBox(height: context.rSpacing(12)),
          Row(
            children: [
              for (int i = 0; i < weekdayHeaders.length; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      weekdayHeaders[i],
                      style: TextStyle(
                        color: i == 5 ? AppColors.primary : AppColors.textMuted,
                        fontSize: context.rFont(11, min: 10, max: 12),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.rSpacing(8)),
          for (int week = 0; week < totalCells ~/ 7; week++) ...[
            Row(
              children: [
                for (int dayCol = 0; dayCol < 7; dayCol++)
                  Expanded(
                    child: _buildDayCell(
                      context,
                      gridStart.add(Duration(days: week * 7 + dayCol)),
                    ),
                  ),
              ],
            ),
            if (week < (totalCells ~/ 7) - 1) const SizedBox(height: 4),
          ],
          SizedBox(height: context.rSpacing(12)),
          const Divider(height: 1, color: AppColors.borderSubtle),
          SizedBox(height: context.rSpacing(10)),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  todayDeadlineCount == 1
                      ? '1 deadline scheduled for today'
                      : '$todayDeadlineCount deadlines scheduled for today',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: context.rFont(11.5, min: 10.5, max: 12.5),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final isCurrentMonth = date.month == focusedMonth.month;
    final isSelected =
        selectedDate != null && _isSameDay(normalized, selectedDate!);
    final hasDeadline = deadlineDates.any((d) => _isSameDay(d, normalized));
    final isSaturday = date.weekday == DateTime.saturday;

    Color textColor;
    if (isSelected) {
      textColor = Colors.white;
    } else if (!isCurrentMonth) {
      textColor = const Color(0xFF64748B);
    } else if (hasDeadline || isSaturday) {
      textColor = AppColors.primaryAccent;
    } else {
      textColor = Colors.white;
    }

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey(
            'desktop_cal_day_${normalized.year}_${normalized.month}_${normalized.day}',
          ),
          onTap: () => onDateSelected(normalized),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 32,
            height: 28,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (hasDeadline
                      ? AppColors.primary.withValues(alpha: 0.16)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(14),
              border: hasDeadline && !isSelected
                  ? Border.all(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      width: 0.9,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: textColor,
                fontSize: context.rFont(11.5, min: 10.5, max: 12.5),
                fontFamily: 'Inter',
                fontWeight: (isSelected || hasDeadline)
                    ? FontWeight.w700
                    : FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarNavButton extends StatelessWidget {
  final Key buttonKey;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CalendarNavButton({
    required this.buttonKey,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: buttonKey,
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: context.rIcon(16),
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FuzzyMamdaniWeightCard extends StatelessWidget {
  final SmartPriorityModel? topPriority;
  final bool isEngineActive;
  final VoidCallback onTap;

  const _FuzzyMamdaniWeightCard({
    required this.topPriority,
    required this.isEngineActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = context.rSpacing(20);
    final weightDegree = topPriority?.courseWeightParam.degree ?? 0.70;
    final deadlineDegree = topPriority?.deadlineParam.degree ?? 0.85;
    final crispNormalized =
        ((topPriority?.score ?? 87.5) / 100.0).clamp(0.0, 1.0);
    final levelText = topPriority == null
        ? 'High'
        : switch (topPriority!.level) {
            SmartPriorityLevel.high => 'High',
            SmartPriorityLevel.medium => 'Medium',
            SmartPriorityLevel.low => 'Low',
          };

    final rows = [
      (
        'Course Grade Weight',
        topPriority?.courseWeightText ?? '35% (High)',
        weightDegree,
        AppColors.primary,
      ),
      (
        'Deadline Proximity',
        topPriority?.timeLeftText ?? '1 Day (Urgent)',
        deadlineDegree,
        AppColors.primaryAccent,
      ),
      (
        'Defuzzified Crisp CoG',
        topPriority?.aggregationAreaText ?? 'Critical Priority (0.70)',
        crispNormalized,
        AppColors.mintAccent,
      ),
    ];

    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        key: const ValueKey('desktop_fuzzy_mamdani_card'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        hoverColor: Colors.white.withValues(alpha: 0.03),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(20),
            vertical: context.rSpacing(18),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.borderSubtle, width: 0.9),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fuzzy Mamdani Priority Weight',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(14.5, min: 13.5, max: 16),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Automated Multi-Parameter Task Scoring',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: context.rFont(11, min: 10, max: 12),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: context.rIcon(13),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              SizedBox(height: context.rSpacing(14)),
              for (int i = 0; i < rows.length; i++) ...[
                _MamdaniMetricRow(
                  title: rows[i].$1,
                  subtitle: rows[i].$2,
                  degree: rows[i].$3,
                  barColor: rows[i].$4,
                ),
                if (i < rows.length - 1) SizedBox(height: context.rSpacing(10)),
              ],
              SizedBox(height: context.rSpacing(14)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: context.rSpacing(14),
                  vertical: context.rSpacing(10),
                ),
                decoration: BoxDecoration(
                  color: AppColors.purpleDeep,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Score: $levelText Priority (${crispNormalized.toStringAsFixed(2)})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(11.5, min: 10.5, max: 12.5),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isEngineActive
                            ? const Color(0xFF63CDDA)
                            : AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isEngineActive ? 'Auto-Scored' : 'Paused',
                        style: TextStyle(
                          color: isEngineActive
                              ? const Color(0xFF0E4D56)
                              : AppColors.textMuted,
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MamdaniMetricRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final double degree;
  final Color barColor;

  const _MamdaniMetricRow({
    required this.title,
    required this.subtitle,
    required this.degree,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = degree.clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(12, min: 11, max: 13),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: context.rFont(10.5, min: 9.5, max: 11.5),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(color: AppColors.bgPrimary),
                FractionallySizedBox(
                  widthFactor: clamped,
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text(
            clamped.toStringAsFixed(2),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(11, min: 10, max: 12),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveCollaboratorsCard extends StatelessWidget {
  final List<DesktopCollaboratorSummary> collaborators;
  final ValueChanged<DesktopCollaboratorSummary> onCollaboratorTap;

  const _ActiveCollaboratorsCard({
    required this.collaborators,
    required this.onCollaboratorTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = context.rSpacing(20);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(20),
        vertical: context.rSpacing(18),
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.borderSubtle, width: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Team Collaborators',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(14.5, min: 13.5, max: 16),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'IMPAL & AI Project Members',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(11, min: 10, max: 12),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.rSpacing(14)),
          if (collaborators.isEmpty)
            Text(
              'No active collaborators assigned yet.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: context.rFont(12, min: 11, max: 13),
                fontFamily: 'Inter',
              ),
            )
          else
            for (int i = 0; i < collaborators.length; i++) ...[
              _CollaboratorRow(
                collaborator: collaborators[i],
                onTap: () => onCollaboratorTap(collaborators[i]),
              ),
              if (i < collaborators.length - 1)
                SizedBox(height: context.rSpacing(10)),
            ],
        ],
      ),
    );
  }
}

class _CollaboratorRow extends StatelessWidget {
  final DesktopCollaboratorSummary collaborator;
  final VoidCallback onTap;

  const _CollaboratorRow({
    required this.collaborator,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: collaborator.avatarColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  collaborator.initials,
                  style: const TextStyle(
                    color: Color(0xFF1E222B),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collaborator.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      collaborator.taskSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: context.rFont(10.5, min: 9.5, max: 11.5),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: collaborator.badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  collaborator.roleLabel,
                  style: TextStyle(
                    color: collaborator.badgeTextColor,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
