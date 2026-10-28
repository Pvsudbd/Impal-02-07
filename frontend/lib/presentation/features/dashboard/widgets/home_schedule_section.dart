import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../common_widgets/impal_schedule_card.dart';
import '../../jadwal/models/schedule_model.dart';
import '../../jadwal/models/schedule_repository.dart';
import '../models/dashboard_models.dart';

/// Today's schedule section on the dashboard with horizontal scroll support.
class HomeScheduleSection extends StatelessWidget {
  final List<ScheduleItem> fallbackSchedules;
  final VoidCallback onSeeAll;
  final void Function(ScheduleModel) onEditSchedule;
  final void Function(ScheduleModel) onDeleteSchedule;

  const HomeScheduleSection({
    super.key,
    required this.fallbackSchedules,
    required this.onSeeAll,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ScheduleModel>>(
      valueListenable: ScheduleRepository().schedulesNotifier,
      builder: (context, repoSchedules, _) {
        final List<ScheduleModel> rawItems;
        if (repoSchedules.isNotEmpty) {
          final now = DateTime.now();
          final todayList = repoSchedules.where((s) {
            return s.date.year == now.year &&
                s.date.month == now.month &&
                s.date.day == now.day;
          }).toList();

          rawItems = todayList.isNotEmpty ? todayList : repoSchedules;
        } else {
          rawItems = [];
        }

        // Sort items: Overdue (0) -> Ongoing (1) -> Upcoming (2)
        // Then chronologically by start time
        final sortedItems = List<ScheduleModel>.from(rawItems);
        sortedItems.sort((a, b) {
          int statusWeight(String s) {
            final st = s.toLowerCase();
            if (st == 'overdue' || st == 'completed') return 0;
            if (st == 'ongoing') return 1;
            return 2; // Upcoming
          }

          final wA = statusWeight(a.status);
          final wB = statusWeight(b.status);
          if (wA != wB) return wA.compareTo(wB);

          final dtA = a.startDateTime ?? DateTime(2000);
          final dtB = b.startDateTime ?? DateTime(2000);
          return dtA.compareTo(dtB);
        });

        Widget scheduleContent;
        if (sortedItems.isEmpty && fallbackSchedules.isNotEmpty) {
          final isHorizontal = fallbackSchedules.length > 1;
          final cardWidgets = <Widget>[];
          for (int i = 0; i < fallbackSchedules.length; i++) {
            final isLast = i == fallbackSchedules.length - 1;
            cardWidgets.add(_buildStaticScheduleCard(
              context,
              fallbackSchedules[i],
              isHorizontal: isHorizontal,
              isLast: isLast,
            ));
          }
          scheduleContent = isHorizontal
              ? ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: SingleChildScrollView(
                    key: const ValueKey('today_schedules_horizontal_scroll'),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    clipBehavior: Clip.none,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: cardWidgets,
                    ),
                  ),
                )
              : cardWidgets.first;
        } else if (sortedItems.isEmpty) {
          scheduleContent = Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text(
              'No schedules for today',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        } else if (sortedItems.length == 1) {
          scheduleContent = ImpalScheduleCard(
            schedule: sortedItems.first,
            isHorizontal: false,
            isLast: true,
            onTap: onSeeAll,
            onEdit: () => onEditSchedule(sortedItems.first),
            onDelete: () => onDeleteSchedule(sortedItems.first),
          );
        } else {
          scheduleContent = ImpalHorizontalScheduleList(
            key: const ValueKey('home_today_schedule_list'),
            scrollKey: const ValueKey('today_schedules_horizontal_scroll'),
            schedules: sortedItems,
            onCardTap: (s) => onSeeAll(),
            onEdit: (s) => onEditSchedule(s),
            onDelete: (s) => onDeleteSchedule(s),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Today's schedule",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(18, min: 16, max: 20),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.04,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onSeeAll,
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.rSpacing(10)),
            scheduleContent,
          ],
        );
      },
    );
  }

  Widget _buildStaticScheduleCard(
    BuildContext context,
    ScheduleItem schedule, {
    bool isHorizontal = false,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onSeeAll,
      child: Container(
        margin: EdgeInsets.only(
          right: isHorizontal ? (isLast ? 0 : 12) : 0,
          bottom: !isHorizontal ? (isLast ? 0 : 10) : 0,
        ),
        width: isHorizontal ? 285 : double.infinity,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left primary colored accent stripe
              Container(
                width: 5,
                color: AppColors.primaryLight,
              ),
              // Card Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              schedule.courseCode,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (schedule.status.toLowerCase() == 'ongoing')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
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
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryAccent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.access_time_filled_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            schedule.time,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
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
    );
  }
}
