import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../common_widgets/pop_up_pemberitahuan.dart';
import '../models/notification_model.dart';
import '../models/notification_repository.dart';
import 'notification_feed_body.dart';

/// Top-right Desktop Notification Popover anchored directly below the
/// header [NotificationBellButton]. Supports scrolling through full notifications,
/// category filtering, `Mark Read`, and clean outside-click / `Esc` dismissal.
class DesktopNotificationPopover extends StatefulWidget {
  final BuildContext hostContext;

  const DesktopNotificationPopover({
    super.key,
    required this.hostContext,
  });

  static Future<void> show(
    BuildContext context, {
    required Rect anchorRect,
  }) {
    final disableMotion = MediaQuery.disableAnimationsOf(context);
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss notifications',
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration:
          disableMotion ? Duration.zero : const Duration(milliseconds: 180),
      pageBuilder: (dialogCtx, _, __) {
        final screen = MediaQuery.sizeOf(dialogCtx);
        const double popoverWidth = 416.0;
        final double effectiveWidth = math.min(popoverWidth, screen.width - 32);
        final double top = (anchorRect.bottom + 10).clamp(
          16.0,
          math.max(16.0, screen.height - 300.0),
        );
        final double right = (screen.width - anchorRect.right).clamp(
          16.0,
          math.max(16.0, screen.width - effectiveWidth - 16.0),
        );
        final double maxHeight = math.min(
          560.0,
          (screen.height - top - 24).clamp(280.0, 560.0),
        );

        return Stack(
          children: [
            Positioned(
              top: top,
              right: right,
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: effectiveWidth,
                    minWidth: math.min(340.0, effectiveWidth),
                    maxHeight: maxHeight,
                  ),
                  child: DesktopNotificationPopover(
                    key: const ValueKey('desktop_notification_popover'),
                    hostContext: context,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (_, animation, __, child) {
        if (disableMotion) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<DesktopNotificationPopover> createState() =>
      _DesktopNotificationPopoverState();
}

class _DesktopNotificationPopoverState
    extends State<DesktopNotificationPopover> {
  final NotificationRepository _repo = NotificationRepository.instance;
  NotificationCategory _selectedCategory = NotificationCategory.all;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  void _markAllAsRead() {
    _repo.markAllAsRead();
    PopUpPemberitahuan.success(
      context,
      title: 'Notifications',
      message: 'All notifications marked as read',
      icon: Icons.done_all_rounded,
    );
  }

  void _handleActionPressed(NotificationModel notif) {
    Navigator.of(context).pop();
    if (!widget.hostContext.mounted) return;
    handleNotificationAction(
      widget.hostContext,
      notif,
      isDesktop: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _repo.getFiltered(_selectedCategory);
    final unreadCount = _repo.unreadCount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Notifications',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(17, min: 15, max: 19),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF472428),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFF6B2D33),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '$unreadCount New',
                            style: const TextStyle(
                              color: Color(0xFFFF7D65),
                              fontSize: 10.5,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const ValueKey('desktop_notif_mark_read_btn'),
                    borderRadius: BorderRadius.circular(8),
                    onTap: unreadCount > 0 ? _markAllAsRead : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.done_all_rounded,
                            size: 14,
                            color: unreadCount > 0
                                ? const Color(0xFFFF7D65)
                                : AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Mark Read',
                            style: TextStyle(
                              color: unreadCount > 0
                                  ? const Color(0xFFFF7D65)
                                  : AppColors.textMuted.withValues(alpha: 0.5),
                              fontSize: 11.5,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const ValueKey('desktop_notif_close_btn'),
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 34,
                      height: 34,
                      child: Center(
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 10),
          Flexible(
            child: NotificationFeedBody(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (cat) {
                setState(() => _selectedCategory = cat);
              },
              filtered: filtered,
              onActionPressed: _handleActionPressed,
              showScrollbar: true,
              filterPadding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              listPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }
}
