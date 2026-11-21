import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_context.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import 'models/notification_model.dart';
import 'models/notification_repository.dart';
import 'widgets/notification_feed_body.dart';

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
    handleNotificationAction(context, notif, isDesktop: false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _repo.getFiltered(_selectedCategory);
    final unreadCount = _repo.unreadCount;

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

            // Shared Filter Chips + Grouped Scrollable Notification Feed
            Expanded(
              child: NotificationFeedBody(
                selectedCategory: _selectedCategory,
                onCategoryChanged: (cat) {
                  setState(() => _selectedCategory = cat);
                },
                filtered: filtered,
                onActionPressed: _handleActionPressed,
                filterPadding: EdgeInsets.only(
                  left: context.rSpacing(16),
                  right: context.rSpacing(16),
                  bottom: context.rSpacing(12),
                ),
                listPadding:
                    EdgeInsets.symmetric(horizontal: context.rSpacing(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
