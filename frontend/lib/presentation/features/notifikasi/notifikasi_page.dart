import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_context.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../smart_system/detail_card_smart_priority.dart';
import '../smart_system/models/smart_priority_repository.dart';
import 'models/notification_model.dart';
import 'models/notification_repository.dart';
import 'widgets/notification_banner.dart';
import 'widgets/notification_card.dart';
import 'widgets/notification_filter_bar.dart';

typedef NotificationPage = NotifikasiPage;

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
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
    switch (notif.actionType) {
      case NotificationActionType.aiReason:
        final topItem = SmartPriorityRepository.instance.topPriority;
        if (topItem != null) {
          DetailCardSmartPriority.show(context, item: topItem);
        } else {
          _showXaiExplanationModal(notif);
        }
        break;
      case NotificationActionType.sessionDetails:
        _showSessionDetailsModal(notif);
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

  void _showXaiExplanationModal(NotificationModel notif) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(context.rSpacing(20)),
        decoration: const BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Color(0xFF10B981), width: 2),
          ),
        ),
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
                    '• Automatic recommendation: Promoted to Rank #1 on today\'s focus schedule.',
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
                onPressed: () => Navigator.pop(ctx),
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
        ),
      ),
    );
  }

  void _showSessionDetailsModal(NotificationModel notif) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(context.rSpacing(20)),
        decoration: const BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Color(0xFF64748B), width: 2),
          ),
        ),
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
                onPressed: () => Navigator.pop(ctx),
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _repo.getFiltered(_selectedCategory);
    final unreadCount = _repo.unreadCount;

    // Group filtered items by dateGroup
    final groups = <String, List<NotificationModel>>{};
    for (final item in filtered) {
      groups.putIfAbsent(item.dateGroup, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.rSpacing(16),
                vertical: context.rSpacing(12),
              ),
              child: Row(
                children: [
                  // Square Back Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
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
                  SizedBox(width: context.rSpacing(10)),

                  // Title and Unread Count in Expanded Row
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'Notifications',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.rFont(19, min: 17, max: 22),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          SizedBox(width: context.rSpacing(6)),
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
                              style: TextStyle(
                                color: const Color(0xFFFF7D65),
                                fontSize: context.rFont(10, min: 9, max: 11.5),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(width: context.rSpacing(8)),

                  // Mark All Read Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: unreadCount > 0 ? _markAllAsRead : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.done_all_rounded,
                              size: context.rIcon(14),
                              color: unreadCount > 0
                                  ? const Color(0xFFFF7D65)
                                  : AppColors.textMuted.withValues(alpha: 0.5),
                            ),
                            SizedBox(width: context.rSpacing(4)),
                            Text(
                              'Mark Read',
                              style: TextStyle(
                                color: unreadCount > 0
                                    ? const Color(0xFFFF7D65)
                                    : AppColors.textMuted.withValues(alpha: 0.5),
                                fontSize: context.rFont(11.5, min: 10, max: 13),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Filter Chips Bar
            Padding(
              padding: EdgeInsets.only(
                left: context.rSpacing(16),
                right: context.rSpacing(16),
                bottom: context.rSpacing(12),
              ),
              child: NotificationFilterBar(
                selectedCategory: _selectedCategory,
                onCategoryChanged: (cat) {
                  setState(() => _selectedCategory = cat);
                },
              ),
            ),

            // Main Scrollable Area
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: context.rSpacing(16)),
                children: [
                  // Background Scheduler Info Banner
                  const NotificationBanner(),
                  SizedBox(height: context.rSpacing(16)),

                  // Empty State if no notifications for current filter
                  if (filtered.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: context.rSpacing(48),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: context.rIcon(48),
                              color: AppColors.textMuted.withValues(alpha: 0.4),
                            ),
                            SizedBox(height: context.rSpacing(12)),
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
                              'You\'re all caught up in this category.',
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
                    // Render date groups
                    ...groups.entries.map((entry) {
                      final dateGroup = entry.key;
                      final items = entry.value;
                      final dateFormatted = items.first.dateFormatted;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group Section Header
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
                                      fontSize:
                                          context.rFont(11.5, min: 10, max: 13),
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
                                      color:
                                          AppColors.textMuted.withValues(alpha: 0.8),
                                      fontSize:
                                          context.rFont(11, min: 9.5, max: 12),
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Notification Cards in this group
                          ...items.map(
                            (notif) => NotificationCard(
                              key: ValueKey(notif.id),
                              notification: notif,
                              onActionPressed: _handleActionPressed,
                            ),
                          ),

                          SizedBox(height: context.rSpacing(10)),
                        ],
                      );
                    }),

                  SizedBox(height: context.rSpacing(24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
