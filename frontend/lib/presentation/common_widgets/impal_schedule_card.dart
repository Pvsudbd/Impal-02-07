import 'dart:ui' show PointerDeviceKind, FontFeature;
import 'package:flutter/material.dart';
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
    final accentColor = schedule.accentColor;

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
                // Left Accent Stripe
                Container(
                  width: 4.5,
                  color: accentColor,
                ),
                // Card Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row: Title & Status Pill
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                schedule.title,
                                maxLines: isHorizontal ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Alert Bell Indicator & Toggle Button
                            GestureDetector(
                              onTap: onToggleAlert,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Icon(
                                  schedule.isAlertEnabled
                                      ? Icons.notifications_active_rounded
                                      : Icons.notifications_off_outlined,
                                  size: 15,
                                  color: schedule.isAlertEnabled
                                      ? const Color(0xFFFF7D65)
                                      : const Color(0xFF8E95A5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            _buildStatusPill(isOngoing, isOverdue),
                          ],
                        ),

                        // Location info (if provided)
                        if (schedule.location != null &&
                            schedule.location!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  schedule.location!.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 11.5,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.05,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 6),

                        // Footer Row: Time and Quick Actions (Edit & Delete)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Time Info
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.access_time_filled_rounded,
                                      color: accentColor,
                                      size: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      customTimeText ?? schedule.formattedTime,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF8E95A5),
                                        fontSize: 11.5,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.05,
                                        fontFeatures: [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quick Actions with accessible touch targets (min 44-48 dp)
                            if (onEdit != null || onDelete != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (onEdit != null)
                                    InkWell(
                                      onTap: onEdit,
                                      borderRadius: BorderRadius.circular(8),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                        child: const Center(
                                          child: Icon(
                                            Icons.edit_outlined,
                                            color: Color(0xFF8E95A5),
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (onDelete != null)
                                    InkWell(
                                      onTap: onDelete,
                                      borderRadius: BorderRadius.circular(8),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                        child: const Center(
                                          child: Icon(
                                            Icons.delete_outline_rounded,
                                            color: Color(0xFFFA6144),
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
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
    if (isOngoing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
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
      );
    }

    final label = isOverdue ? 'Overdue' : 'Upcoming';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFF8E95A5).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF8E95A5).withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8E95A5),
          fontSize: 9.5,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
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
