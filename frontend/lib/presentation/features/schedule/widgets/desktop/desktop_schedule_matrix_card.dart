import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../models/schedule_model.dart';

/// Tonal badge categories matching FigCraft `Master Component — Card Schedule Matrix` (node 5245)
/// and `Tonal Category Legend` (node 2613).
enum ScheduleMatrixCategory {
  kuliah,
  kelompok,
  studyLab,
  ongoing,
}

/// Immutable display specification for a single card inside the Desktop Weekly Schedule Matrix.
class ScheduleMatrixItem {
  final String id;
  final String title;
  final String subtitle;
  final String timeRange;
  final int dayIndex; // 0 = Senin .. 5 = Sabtu
  final int slotIndex; // 0 = 08:00 .. 5 = 19:00
  final String badgeLabel; // Code, Kuliah, Testing, Kelompok, Personal, Study, Figma, Ongoing
  final ScheduleMatrixCategory category;
  final bool isOngoing;
  final ScheduleModel? linkedSchedule;

  const ScheduleMatrixItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeRange,
    required this.dayIndex,
    required this.slotIndex,
    required this.badgeLabel,
    required this.category,
    this.isOngoing = false,
    this.linkedSchedule,
  });
}

/// Pure UI card matching FigCraft `Card_Schedule_Matrix` (node 5248, 162x91, r=10, 5px left strip).
class DesktopScheduleMatrixCard extends StatelessWidget {
  final ScheduleMatrixItem item;
  final VoidCallback? onTap;

  const DesktopScheduleMatrixCard({
    super.key,
    required this.item,
    this.onTap,
  });

  ({Color bg, Color text}) get _pillPalette {
    if (item.isOngoing || item.badgeLabel.toLowerCase() == 'ongoing') {
      return (bg: AppColors.primaryAccent, text: Colors.white);
    }
    switch (item.badgeLabel.toLowerCase()) {
      case 'code':
      case 'kuliah':
      case 'testing':
        return (bg: const Color(0xFF63CDDA), text: const Color(0xFF2A8F9C));
      case 'kelompok':
        return (bg: AppColors.purpleAccent, text: AppColors.purpleDeep);
      case 'personal':
      case 'study':
      case 'figma':
        return (bg: const Color(0xFF778BEB), text: const Color(0xFF4055C0));
      default:
        return switch (item.category) {
          ScheduleMatrixCategory.kuliah => (
              bg: const Color(0xFF63CDDA),
              text: const Color(0xFF2A8F9C),
            ),
          ScheduleMatrixCategory.kelompok => (
              bg: AppColors.purpleAccent,
              text: AppColors.purpleDeep,
            ),
          ScheduleMatrixCategory.studyLab => (
              bg: const Color(0xFF778BEB),
              text: const Color(0xFF4055C0),
            ),
          ScheduleMatrixCategory.ongoing => (
              bg: AppColors.primaryAccent,
              text: Colors.white,
            ),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final pill = _pillPalette;
    final isOngoing = item.isOngoing || item.category == ScheduleMatrixCategory.ongoing;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('desktop_schedule_card_${item.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 5px Coral Accent Strip (FigCraft node 5250)
              Container(
                width: 5,
                decoration: const BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Top Row: Title + Tonal Pill
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.rFont(10, min: 9.5, max: 10),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            height: 18,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: pill.bg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              item.badgeLabel,
                              style: TextStyle(
                                color: pill.text,
                                fontSize: context.rFont(9, min: 8.5, max: 9),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Subtitle
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: context.rFont(10, min: 9.5, max: 10),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Time Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isOngoing
                                  ? AppColors.primaryAccent
                                  : AppColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.timeRange,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isOngoing
                                    ? Colors.white
                                    : AppColors.textMuted,
                                fontSize: context.rFont(10, min: 9.5, max: 10),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
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

