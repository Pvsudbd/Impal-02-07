import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import 'desktop_schedule_matrix_card.dart';

/// Column descriptor for each of the 6 weekday headers (`Senin` .. `Sabtu`).
class ScheduleMatrixDayHeader {
  final String label;
  final bool isToday;

  const ScheduleMatrixDayHeader({
    required this.label,
    this.isToday = false,
  });
}

/// Time slot descriptor for the 6 matrix rows.
class ScheduleMatrixTimeSlot {
  final String startLabel;
  final String endLabel;

  const ScheduleMatrixTimeSlot({
    required this.startLabel,
    required this.endLabel,
  });
}

/// Weekly Schedule Matrix Table matching FigCraft `Weekly Schedule Matrix Table` (node 2643).
/// Renders the `WAKTU` + 6-day header (`44dp`) and 6 fixed `102dp` time rows inside a `#1F232B`
/// bordered container (`r=16`, border `#3B4150`).
class DesktopScheduleMatrixTable extends StatelessWidget {
  final List<ScheduleMatrixDayHeader> dayHeaders;
  final List<ScheduleMatrixTimeSlot> timeSlots;
  final List<ScheduleMatrixItem> items;
  final int? focusedDayIndex;
  final ValueChanged<ScheduleMatrixItem>? onCardTap;
  final ValueChanged<ScheduleMatrixItem>? onDeleteCard;
  final ValueChanged<ScheduleMatrixItem>? onToggleAlertCard;

  const DesktopScheduleMatrixTable({
    super.key,
    required this.dayHeaders,
    required this.timeSlots,
    required this.items,
    this.focusedDayIndex,
    this.onCardTap,
    this.onDeleteCard,
    this.onToggleAlertCard,
  });

  static const double _timeColWidth = 80.0;
  static const double _headerHeight = 44.0;
  static const double _rowHeight = 102.0;
  static const double _minTableWidth = 980.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minWidth = focusedDayIndex != null ? 360.0 : _minTableWidth;
          final tableWidth = constraints.maxWidth < minWidth
              ? minWidth
              : constraints.maxWidth;

          final tableWidget = SizedBox(
            width: tableWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeaderRow(context),
                for (int slotIdx = 0; slotIdx < timeSlots.length; slotIdx++)
                  _buildTimeRow(
                    context,
                    slotIndex: slotIdx,
                    slot: timeSlots[slotIdx],
                    isLastRow: slotIdx == timeSlots.length - 1,
                  ),
              ],
            ),
          );

          if (constraints.maxWidth < minWidth) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: tableWidget,
            );
          }

          return tableWidget;
        },
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Container(
      height: _headerHeight,
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _timeColWidth,
            child: Center(
              child: Text(
                'WAKTU',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: context.rFont(11, min: 10.5, max: 11),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          for (int dayIdx = 0; dayIdx < dayHeaders.length; dayIdx++)
            if (focusedDayIndex == null || focusedDayIndex == dayIdx)
              Expanded(
                child: _buildDayHeaderCell(context, dayHeaders[dayIdx]),
              ),
        ],
      ),
    );
  }

  Widget _buildDayHeaderCell(
    BuildContext context,
    ScheduleMatrixDayHeader header,
  ) {
    return Container(
      color: header.isToday ? AppColors.bgCard : Colors.transparent,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              header.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.rFont(12, min: 11, max: 12),
                fontFamily: 'Inter',
                fontWeight: header.isToday ? FontWeight.w700 : FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          if (header.isToday) ...[
            const SizedBox(width: 6),
            Container(
              height: 18,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(
                'Hari Ini',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(9, min: 8.5, max: 9),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRow(
    BuildContext context, {
    required int slotIndex,
    required ScheduleMatrixTimeSlot slot,
    required bool isLastRow,
  }) {
    return Container(
      height: _rowHeight,
      decoration: BoxDecoration(
        border: isLastRow
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.bgPrimary, width: 1),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time Col (80dp fixed)
          SizedBox(
            width: _timeColWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    slot.startLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(12, min: 11, max: 12),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    slot.endLabel,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: context.rFont(10, min: 9.5, max: 10),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 6 Day Cells
          for (int dayIdx = 0; dayIdx < dayHeaders.length; dayIdx++)
            if (focusedDayIndex == null || focusedDayIndex == dayIdx)
              Expanded(
                child: _buildDayCell(
                  dayIndex: dayIdx,
                  slotIndex: slotIndex,
                  isTodayColumn: dayHeaders[dayIdx].isToday,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildDayCell({
    required int dayIndex,
    required int slotIndex,
    required bool isTodayColumn,
  }) {
    final matches = items
        .where((item) => item.dayIndex == dayIndex && item.slotIndex == slotIndex)
        .toList();

    Widget buildCard(ScheduleMatrixItem item) {
      return DesktopScheduleMatrixCard(
        item: item,
        onTap: onCardTap == null ? null : () => onCardTap!(item),
        onDelete: onDeleteCard == null ? null : () => onDeleteCard!(item),
        onToggleAlert:
            onToggleAlertCard == null ? null : () => onToggleAlertCard!(item),
      );
    }

    return Container(
      color: isTodayColumn ? const Color(0xFF252B35) : Colors.transparent,
      padding: const EdgeInsets.all(5),
      child: matches.isEmpty
          ? const SizedBox.expand()
          : (matches.length == 1
              ? buildCard(matches.first)
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < matches.length; i++) ...[
                        if (i > 0) const SizedBox(height: 6),
                        SizedBox(height: 82, child: buildCard(matches[i])),
                      ],
                    ],
                  ),
                )),
    );
  }
}
