import 'dart:ui' show PointerDeviceKind, FontFeature;
import 'package:flutter/material.dart';
import '../../core/utils/responsive_context.dart';
import '../features/schedule/models/schedule_model.dart';

/// Reusable Schedule Card matching the sleek IMPAL Design System.
/// Supports both vertical list layouts and horizontal carousels.
/// Features left status accent strip, title, status pill (Ongoing, Overdue, Upcoming),
/// location info, time details, and quick action icons (Edit & Delete).
class ImpalScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final bool isHorizontal;
  final bool isLast;
  final double? width;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleAlert;
  final Key? targetKey;
  final String? customTimeText;

  const ImpalScheduleCard({
    super.key,
    required this.schedule,
    this.isHorizontal = false,
    this.isLast = false,
    this.width,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleAlert,
    this.targetKey,
    this.customTimeText,
  });

  @override
  Widget build(BuildContext context) {
    final statusLower = schedule.status.toLowerCase();
    final isOngoing = statusLower == 'ongoing';
    final isOverdue = statusLower == 'overdue' || statusLower == 'completed';
    final stripeColor = isOngoing ? const Color(0xFFFF826E) : const Color(0xFF8E95A5);
    final clockCircleColor = isOngoing ? const Color(0xFFFF7D65) : const Color(0xFF8E95A5);
    final bellColor = schedule.isAlertEnabled
        ? (isOngoing ? const Color(0xFFFF7D65) : const Color(0xFF8E95A5))
        : const Color(0xFF8E95A5);

    final cardWidth = isHorizontal ? (width ?? 285.0) : double.infinity;

    return Container(
      key: targetKey,
      width: cardWidth,
      margin: EdgeInsets.only(
        right: isHorizontal ? (isLast ? 0 : 12) : 0,
        bottom: !isHorizontal ? (isLast ? 0 : 10) : 0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF323846),
        borderRadius: BorderRadius.circular(12),
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
          onTap: onTap ?? onEdit,
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Left Indicator Stripe (5.0dp exact FigCraft spec)
                Container(
                  width: 5.0,
                  color: stripeColor,
                ),
                const SizedBox(width: 9.0),
                // 2. Card Content (Padding top:16, bottom:16, right:18, gap:9.0)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Row 1: Title & Right Group (Bell + Status Pill)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                schedule.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.rFont(14.5, min: 13, max: 16),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Bell Icon Button (accessible touch target)
                            InkWell(
                              onTap: onToggleAlert,
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Icon(
                                  schedule.isAlertEnabled
                                      ? Icons.notifications_active_rounded
                                      : Icons.notifications_off_outlined,
                                  size: 14,
                                  color: bellColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            _buildStatusPill(isOngoing, isOverdue),
                          ],
                        ),

                        // Row 2: Location & Class info (9.0dp gap)
                        if (schedule.location != null &&
                            schedule.location!.trim().isNotEmpty) ...[
                          const SizedBox(height: 9.0),
                          Text(
                            schedule.location!.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF8E95A5),
                              fontSize: context.rFont(11.0, min: 10, max: 12.5),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ],

                        const SizedBox(height: 9.0),

                        // Row 3: Time Info & Quick Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Time Info (15x15 solid clock circle + time text)
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 15.0,
                                    height: 15.0,
                                    decoration: BoxDecoration(
                                      color: clockCircleColor,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.access_time_filled_rounded,
                                      color: Colors.white,
                                      size: 9.0,
                                    ),
                                  ),
                                  const SizedBox(width: 6.0),
                                  Flexible(
                                    child: Text(
                                      customTimeText ?? schedule.formattedTime,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(0xFF8E95A5),
                                        fontSize: context.rFont(10.8, min: 10, max: 12.0),
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.0,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quick Actions if provided (Edit & Delete)
                            if (onEdit != null || onDelete != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (onEdit != null)
                                    InkWell(
                                      onTap: onEdit,
                                      borderRadius: BorderRadius.circular(6),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        child: Icon(
                                          Icons.edit_outlined,
                                          color: Color(0xFF8E95A5),
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  if (onDelete != null) ...[
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: onDelete,
                                      borderRadius: BorderRadius.circular(6),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        child: Icon(
                                          Icons.delete_outline_rounded,
                                          color: Color(0xFFFA6144),
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
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

  Widget _buildStatusPill(bool isOngoing, bool isOverdue) {
    final String label;
    final Color pillColor;

    if (isOngoing) {
      label = 'Ongoing';
      pillColor = const Color(0xFFFF826E);
    } else if (isOverdue) {
      label = 'Overdue';
      pillColor = const Color(0xFF8E95A5);
    } else {
      label = 'Upcoming';
      pillColor = const Color(0xFF8E95A5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: pillColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

/// Reusable horizontal schedule carousel with smart auto-centering / auto-focus on Ongoing schedule.
/// Schedules are laid out: [Overdue ...] (left) -> [Ongoing ...] (main focus) -> [Upcoming ...] (right).
/// Scrolling to the left reveals Overdue items, while scrolling to the right reveals Upcoming items.
class ImpalHorizontalScheduleList extends StatefulWidget {
  final List<ScheduleModel> schedules;
  final void Function(ScheduleModel schedule)? onCardTap;
  final void Function(ScheduleModel schedule)? onEdit;
  final void Function(ScheduleModel schedule)? onDelete;
  final double cardWidth;
  final double cardSpacing;
  final Key? scrollKey;
  final String Function(ScheduleModel schedule)? customTimeFormatter;

  const ImpalHorizontalScheduleList({
    super.key,
    required this.schedules,
    this.onCardTap,
    this.onEdit,
    this.onDelete,
    this.cardWidth = 285.0,
    this.cardSpacing = 12.0,
    this.scrollKey,
    this.customTimeFormatter,
  });

  @override
  State<ImpalHorizontalScheduleList> createState() =>
      _ImpalHorizontalScheduleListState();
}

class _ImpalHorizontalScheduleListState
    extends State<ImpalHorizontalScheduleList> {
  late final ScrollController _scrollController;
  bool _didAutoScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToPrimaryCard());
  }

  @override
  void didUpdateWidget(covariant ImpalHorizontalScheduleList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schedules.length != widget.schedules.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToPrimaryCard());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToPrimaryCard() {
    if (!mounted || !_scrollController.hasClients || widget.schedules.isEmpty) {
      return;
    }

    // Find the first Ongoing schedule
    int targetIndex = widget.schedules.indexWhere(
      (s) => s.status.toLowerCase() == 'ongoing',
    );

    // If no Ongoing schedule exists, target the first Upcoming schedule
    if (targetIndex < 0) {
      targetIndex = widget.schedules.indexWhere(
        (s) =>
            s.status.toLowerCase() != 'overdue' &&
            s.status.toLowerCase() != 'completed',
      );
    }

    if (targetIndex > 0) {
      final targetOffset = targetIndex * (widget.cardWidth + widget.cardSpacing);
      final maxExtent = _scrollController.position.maxScrollExtent;
      final clampedOffset = targetOffset.clamp(0.0, maxExtent);

      if (!_didAutoScroll) {
        _scrollController.jumpTo(clampedOffset);
        _didAutoScroll = true;
      } else {
        _scrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      child: SingleChildScrollView(
        key: widget.scrollKey,
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < widget.schedules.length; i++)
              ImpalScheduleCard(
                schedule: widget.schedules[i],
                isHorizontal: true,
                isLast: i == widget.schedules.length - 1,
                width: widget.cardWidth,
                customTimeText: widget.customTimeFormatter != null
                    ? widget.customTimeFormatter!(widget.schedules[i])
                    : null,
                onTap: widget.onCardTap != null
                    ? () => widget.onCardTap!(widget.schedules[i])
                    : (widget.onEdit != null
                        ? () => widget.onEdit!(widget.schedules[i])
                        : null),
                onEdit: widget.onEdit != null
                    ? () => widget.onEdit!(widget.schedules[i])
                    : null,
                onDelete: widget.onDelete != null
                    ? () => widget.onDelete!(widget.schedules[i])
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
