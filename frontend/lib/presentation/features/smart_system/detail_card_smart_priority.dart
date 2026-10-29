import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_context.dart';
import 'models/smart_priority_model.dart';

class DetailCardSmartPriority extends StatelessWidget {
  final SmartPriorityModel item;

  const DetailCardSmartPriority({
    super.key,
    required this.item,
  });

  /// Static helper to display the modal bottom sheet
  static void show(
    BuildContext context, {
    required SmartPriorityModel item,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DetailCardSmartPriority(item: item),
    );
  }

  Widget _buildFuzzifiedParamRow(
    BuildContext context,
    FuzzifiedParameter param,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                param.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFFCBD5E1),
                  fontSize: context.rFont(12, min: 10.5, max: 13.5),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: context.rSpacing(8)),
            Text(
              param.degreeLabel,
              style: TextStyle(
                color: param.accentColor,
                fontSize: context.rFont(12, min: 10.5, max: 13.5),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        SizedBox(height: context.rSpacing(6)),

        // Progress bar indicator
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF232833),
            borderRadius: BorderRadius.circular(999),
          ),
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: constraints.maxWidth * param.degree.clamp(0.0, 1.0),
                  height: 6,
                  decoration: BoxDecoration(
                    color: param.accentColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: context.rSpacing(6)),

        // Membership values breakdown row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: param.membershipValues.entries.map((entry) {
            return Flexible(
              child: Text(
                '${entry.key} (${entry.value.toStringAsFixed(2)})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: context.rFont(10, min: 9, max: 11.5),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(
        context.rSpacing(16),
        context.rSpacing(12),
        context.rSpacing(16),
        context.rSpacing(24),
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF323846),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: Color(0xFF3E4656),
            width: 1.5,
          ),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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
            SizedBox(height: context.rSpacing(14)),

            // Top Header Card: Title, category, score
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: context.rSpacing(14),
                vertical: context.rSpacing(12),
              ),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderSubtle,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(15, min: 13.5, max: 17),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: context.rSpacing(3)),
                        Text(
                          item.categoryTag,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: context.rFont(12, min: 10.5, max: 13.5),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.rSpacing(12)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.score.toStringAsFixed(1),
                        style: TextStyle(
                          color: const Color(0xFFFF5E4D),
                          fontSize: context.rFont(24, min: 20, max: 28),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        item.levelLabel,
                        style: TextStyle(
                          color: const Color(0xFFFF5E4D),
                          fontSize: context.rFont(10.5, min: 9.5, max: 12),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: context.rSpacing(18)),

            // 1. INPUT PARAMETER FUZZIFICATION
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5E4D),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: context.rSpacing(8)),
                Expanded(
                  child: Text(
                    '1. INPUT PARAMETER FUZZIFICATION',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(12, min: 10.5, max: 13.5),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.rSpacing(10)),
            _buildFuzzifiedParamRow(context, item.deadlineParam),
            SizedBox(height: context.rSpacing(12)),
            _buildFuzzifiedParamRow(context, item.courseWeightParam),
            SizedBox(height: context.rSpacing(18)),

            // 2. CENTROID DEFUZZIFICATION
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: context.rSpacing(8)),
                Expanded(
                  child: Text(
                    '2. CENTROID DEFUZZIFICATION',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(12, min: 10.5, max: 13.5),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.rSpacing(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: context.rFont(12, min: 10.5, max: 13.5),
                            color: const Color(0xFFCBD5E1),
                          ),
                          children: const [
                            TextSpan(
                              text: 'Method: ',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                            TextSpan(
                              text: 'Center of Gravity (CoG)',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.rSpacing(2)),
                      Text(
                        'Aggregation Area: ${item.aggregationAreaText}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: context.rFont(11, min: 9.5, max: 12),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: context.rSpacing(8)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'z* = ${item.score.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: const Color(0xFF34D399),
                        fontSize: context.rFont(16, min: 14, max: 19),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      'Scale [0 - 100]',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: context.rFont(10.5, min: 9.5, max: 11.5),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: context.rSpacing(16)),

            // 3. Why is this task Priority #1?
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.rSpacing(12)),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderSubtle,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: const Color(0xFF38BDF8),
                        size: context.rIcon(16),
                      ),
                      SizedBox(width: context.rSpacing(6)),
                      Expanded(
                        child: Text(
                          'Why is this task Priority #${item.rank}?',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF38BDF8),
                            fontSize: context.rFont(12.5, min: 11, max: 14),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.rSpacing(6)),
                  Text(
                    item.reasonExplanation,
                    style: TextStyle(
                      color: const Color(0xFFCBD5E1),
                      fontSize: context.rFont(11.5, min: 10, max: 13),
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.rSpacing(18)),

            // Close Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(14.5, min: 13, max: 16),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
