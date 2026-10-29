import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../models/smart_priority_model.dart';

class SmartPriorityTaskCard extends StatelessWidget {
  final SmartPriorityModel item;
  final VoidCallback onTap;

  const SmartPriorityTaskCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: context.rSpacing(12)),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
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
          onTap: onTap,
          splashColor: item.levelColor.withValues(alpha: 0.1),
          highlightColor: item.levelColor.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.all(context.rSpacing(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Rank Category Label + Crisp Score & Level Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        item.rankLabel,
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: context.rFont(11.5, min: 10, max: 13),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    SizedBox(width: context.rSpacing(8)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          item.score.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(20, min: 18, max: 24),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        SizedBox(width: context.rSpacing(6)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.levelColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.levelLabel,
                            style: TextStyle(
                              color: item.levelTextColor,
                              fontSize: context.rFont(9.5, min: 8.5, max: 11),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: context.rSpacing(8)),

                // Task Title
                Text(
                  item.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(15, min: 13.5, max: 17),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: context.rSpacing(12)),

                // Sub-box: Parameters (Time Left & Course Weight)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(12),
                    vertical: context.rSpacing(10),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Time Left Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Time Left (Deadline)',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize:
                                    context.rFont(10.5, min: 9.5, max: 12),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: context.rSpacing(2)),
                            Text(
                              item.timeLeftText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.rFont(12, min: 10.5, max: 13.5),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 28,
                        color: AppColors.borderSubtle,
                      ),
                      SizedBox(width: context.rSpacing(12)),

                      // Course Weight Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Course Weight',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize:
                                    context.rFont(10.5, min: 9.5, max: 12),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: context.rSpacing(2)),
                            Text(
                              item.courseWeightText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.rFont(12, min: 10.5, max: 13.5),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
