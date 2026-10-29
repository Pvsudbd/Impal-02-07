import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';

class SmartEngineStatusCard extends StatelessWidget {
  const SmartEngineStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.rSpacing(14)),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: context.rIcon(40),
            height: context.rIcon(40),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: context.rIcon(22),
            ),
          ),
          SizedBox(width: context.rSpacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mamdani Inference Engine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(14, min: 12.5, max: 16),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.rSpacing(2)),
                Text(
                  'Verified Centroid Defuzzification',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: context.rFont(11.5, min: 10, max: 13),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.rSpacing(8)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFF10B981),
                width: 1,
              ),
            ),
            child: Text(
              'ACTIVE',
              style: TextStyle(
                color: const Color(0xFF10B981),
                fontSize: context.rFont(10, min: 9, max: 11.5),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

