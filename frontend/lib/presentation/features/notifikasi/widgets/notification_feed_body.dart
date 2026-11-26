import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../smart_system/detail_card_smart_priority.dart';
import '../../smart_system/models/smart_priority_model.dart';
import '../../smart_system/models/smart_priority_repository.dart';
import '../models/notification_model.dart';
import 'notification_banner.dart';
import 'notification_card.dart';
import 'notification_filter_bar.dart';

/// Shared scrollable notification feed (filter bar + scheduler banner +
/// date-grouped cards + empty state) reused across Mobile [NotifikasiPage]
/// and Desktop [DesktopNotificationPopover].
class NotificationFeedBody extends StatelessWidget {
  final NotificationCategory selectedCategory;
  final ValueChanged<NotificationCategory> onCategoryChanged;
  final List<NotificationModel> filtered;
  final ValueChanged<NotificationModel> onActionPressed;
  final EdgeInsetsGeometry filterPadding;
  final EdgeInsetsGeometry listPadding;
  final bool showScrollbar;

  const NotificationFeedBody({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.filtered,
    required this.onActionPressed,
    this.filterPadding = const EdgeInsets.fromLTRB(16, 0, 16, 12),
    this.listPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.showScrollbar = false,
  });

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<NotificationModel>>{};
    for (final item in filtered) {
      groups.putIfAbsent(item.dateGroup, () => []).add(item);
    }

    final listView = ListView(
      shrinkWrap: showScrollbar,
      physics: const BouncingScrollPhysics(),
      padding: listPadding,
      children: [
        const NotificationBanner(),
        SizedBox(height: context.rSpacing(16)),
        if (filtered.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.rSpacing(40)),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: context.rIcon(44),
                    color: AppColors.textMuted.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: context.rSpacing(10)),
                  Text(
                    'No Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(15, min: 13, max: 17),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: context.rSpacing(4)),
                  Text(
                    "You're all caught up in this category.",
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: context.rFont(12.5, min: 11, max: 14),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...groups.entries.map((entry) {
            final dateGroup = entry.key;
            final items = entry.value;
            final dateFormatted = items.first.dateFormatted;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: context.rSpacing(10),
                    top: context.rSpacing(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          dateGroup,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: context.rFont(11.5, min: 10, max: 13),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      SizedBox(width: context.rSpacing(8)),
                      Flexible(
                        child: Text(
                          dateFormatted,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textMuted.withValues(alpha: 0.8),
                            fontSize: context.rFont(11, min: 9.5, max: 12),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...items.map(
                  (notif) => NotificationCard(
                    key: ValueKey(notif.id),
                    notification: notif,
                    onActionPressed: onActionPressed,
                  ),
                ),
                SizedBox(height: context.rSpacing(10)),
              ],
            );
          }),
        SizedBox(height: context.rSpacing(16)),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: filterPadding,
          child: NotificationFilterBar(
            selectedCategory: selectedCategory,
            onCategoryChanged: onCategoryChanged,
          ),
        ),
        Flexible(
          child: showScrollbar ? Scrollbar(child: listView) : listView,
        ),
      ],
    );
  }
}

/// Shared action dispatcher for notification cards on both Mobile (bottom sheet)
/// and Desktop (centered dialog).
void handleNotificationAction(
  BuildContext context,
  NotificationModel notif, {
  required bool isDesktop,
}) {
  switch (notif.actionType) {
    case NotificationActionType.aiReason:
      if (!SmartPriorityRepository.instance.isScoreExplainabilityActive) {
        PopUpPemberitahuan.show(
          context,
          title: 'XAI Disabled',
          message:
              'Score Explainability (XAI) is disabled in Profile & Settings. Enable it to view mathematical calculations.',
          icon: Icons.lightbulb_outline_rounded,
          iconBgColor: PopUpPemberitahuan.negativeColor,
        );
        return;
      }
      final topItem = SmartPriorityRepository.instance.topPriority;
      if (isDesktop) {
        _showDesktopCenteredDialog(
          context,
          accentColor: const Color(0xFF10B981),
          child: _XaiExplainabilityContent(topItem: topItem),
        );
      } else if (topItem != null) {
        DetailCardSmartPriority.show(context, item: topItem);
      } else {
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (ctx) => const _MobileBottomSheetShell(
            accentColor: Color(0xFF10B981),
            child: _XaiExplainabilityContent(topItem: null),
          ),
        );
      }
      break;
    case NotificationActionType.sessionDetails:
      if (isDesktop) {
        _showDesktopCenteredDialog(
          context,
          accentColor: const Color(0xFF64748B),
          maxWidth: 460,
          child: const _SessionDetailsContent(),
        );
      } else {
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (ctx) => const _MobileBottomSheetShell(
            accentColor: Color(0xFF64748B),
            child: _SessionDetailsContent(),
          ),
        );
      }
      break;
    case NotificationActionType.viewTask:
    case NotificationActionType.classroom:
    case NotificationActionType.openTeam:
      PopUpPemberitahuan.show(
        context,
        title: notif.categoryLabel,
        message: 'Redirecting to ${notif.title}...',
        icon: notif.icon,
        iconBgColor: notif.accentColor,
      );
      break;
  }
}

void _showDesktopCenteredDialog(
  BuildContext context, {
  required Color accentColor,
  required Widget child,
  double maxWidth = 480,
}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
        ),
        child: Container(
          padding: EdgeInsets.all(ctx.rSpacing(22)),
          decoration: BoxDecoration(
            color: AppColors.bgDialog,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          child: SingleChildScrollView(child: child),
        ),
      ),
    ),
  );
}

class _MobileBottomSheetShell extends StatelessWidget {
  final Color accentColor;
  final Widget child;

  const _MobileBottomSheetShell({
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.rSpacing(20)),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: accentColor, width: 2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            SizedBox(height: context.rSpacing(16)),
            child,
          ],
        ),
      ),
    );
  }
}

class _XaiExplainabilityContent extends StatelessWidget {
  final SmartPriorityModel? topItem;

  const _XaiExplainabilityContent({required this.topItem});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Color(0xFF10B981),
                size: 22,
              ),
            ),
            SizedBox(width: context.rSpacing(12)),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Fuzzy Reason (XAI)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    'Mamdani Min-Max Centroid Model',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: context.rSpacing(16)),
        if (topItem != null)
          SmartPriorityExplainabilityDetails(item: topItem!)
        else
          Container(
            padding: EdgeInsets.all(context.rSpacing(14)),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Fired Rules & Defuzzification:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: context.rSpacing(8)),
                const Text(
                  '• Rule #4: IF Deadline is NEAR (μ=0.88) AND Syllabus Weight is HIGH (μ=0.75) THEN Priority is CRITICAL (μ=0.92).\n'
                  '• Center of Gravity (Centroid) Crisp Output: 87.5 / 100\n'
                  "• Automatic recommendation: Promoted to Rank #1 on today's focus schedule.",
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: context.rSpacing(18)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Understood',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SessionDetailsContent extends StatelessWidget {
  const _SessionDetailsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF64748B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.security_rounded,
                color: Color(0xFF94A3B8),
                size: 22,
              ),
            ),
            SizedBox(width: context.rSpacing(12)),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SSO Directory & Security Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    'Central Authentication Service (CAS TLS 1.3)',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: context.rSpacing(16)),
        Container(
          padding: EdgeInsets.all(context.rSpacing(14)),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: const Text(
            '• Protocol: TLS 1.3 Ephemeral Key Exchange\n'
            '• Sync Target: 6 Enrolled Subjects & 19 Credits\n'
            '• Status: Local timetable cache fully up to date\n'
            '• Issuer: Telkom University Central Auth Server',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 12,
              fontFamily: 'Inter',
              height: 1.45,
            ),
          ),
        ),
        SizedBox(height: context.rSpacing(18)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF323846),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
