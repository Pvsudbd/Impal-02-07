import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../models/notification_model.dart';
import '../models/notification_repository.dart';

class NotificationCard extends StatefulWidget {
  final NotificationModel notification;
  final ValueChanged<NotificationModel>? onActionPressed;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onActionPressed,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isExpanded = false;

  void _handleCardTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (!widget.notification.isRead) {
      NotificationRepository.instance.markAsRead(widget.notification.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notif = widget.notification;
    final accent = notif.accentColor;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: context.rSpacing(10)),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notif.isRead
              ? AppColors.borderSubtle
              : accent.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleCardTap,
          splashColor: accent.withValues(alpha: 0.08),
          highlightColor: accent.withValues(alpha: 0.04),
          child: Stack(
            children: [
              // Left accent vertical bar
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4.5,
                child: Container(color: accent),
              ),

              // Main card content
              Padding(
                padding: EdgeInsets.only(
                  left: context.rSpacing(16),
                  right: context.rSpacing(12),
                  top: context.rSpacing(12),
                  bottom: context.rSpacing(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: Leading icon + Tags + Unread blue indicator dot
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Leading Category Icon
                        Container(
                          width: context.rIcon(34),
                          height: context.rIcon(34),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              notif.icon,
                              size: context.rIcon(18),
                              color: accent,
                            ),
                          ),
                        ),
                        SizedBox(width: context.rSpacing(10)),

                        // Tags Row in Expanded
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7.5,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgPrimary,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.borderSubtle,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    notif.categoryLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: const Color(0xFF94A3B8),
                                      fontSize:
                                          context.rFont(10, min: 9, max: 11.5),
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: context.rSpacing(6)),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7.5,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        notif.statusTagColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: notif.statusTagColor
                                          .withValues(alpha: 0.4),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    notif.statusTag,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: notif.statusTagColor,
                                      fontSize:
                                          context.rFont(10, min: 9, max: 11.5),
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Unread Blue Glow Dot
                        if (!notif.isRead) ...[
                          SizedBox(width: context.rSpacing(8)),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8)
                                      .withValues(alpha: 0.6),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: context.rSpacing(9)),

                    // Title
                    Text(
                      notif.title,
                      maxLines: _isExpanded ? 4 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(13.5, min: 12, max: 15),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: context.rSpacing(8)),

                    // Animated detail description (Only in expanded state)
                    AnimatedCrossFade(
                      firstChild: const SizedBox(width: double.infinity),
                      secondChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(context.rSpacing(10)),
                            decoration: BoxDecoration(
                              color: AppColors.bgPrimary.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.borderSubtle
                                    .withValues(alpha: 0.6),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              notif.description,
                              style: TextStyle(
                                color: const Color(0xFFCBD5E1),
                                fontSize:
                                    context.rFont(12, min: 10.5, max: 13.5),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                              ),
                            ),
                          ),
                          SizedBox(height: context.rSpacing(10)),
                        ],
                      ),
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 220),
                    ),

                    // Bottom Row: Timestamp + Action Button / Expand Chevron
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Timestamp
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: context.rIcon(13),
                                color: AppColors.textMuted,
                              ),
                              SizedBox(width: context.rSpacing(4)),
                              Flexible(
                                child: Text(
                                  notif.timestamp,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textMuted,
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
                        SizedBox(width: context.rSpacing(8)),

                        // Right action button (shown when expanded) OR expand chevron hint
                        if (_isExpanded)
                          Flexible(
                            child: ElevatedButton(
                              onPressed: () {
                                if (widget.onActionPressed != null) {
                                  widget.onActionPressed!(notif);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF232833),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.rSpacing(10),
                                  vertical: context.rSpacing(5),
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: accent.withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                notif.actionLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      context.rFont(11.5, min: 10, max: 13),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Details',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: context.rFont(11, min: 9.5, max: 12),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: context.rSpacing(2)),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: context.rIcon(16),
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                      ],
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
