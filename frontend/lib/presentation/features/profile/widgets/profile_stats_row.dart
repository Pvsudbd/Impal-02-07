import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../models/user_profile_model.dart';

/// 4-column responsive stats summary cards for academic productivity metrics.
class ProfileStatsRow extends StatelessWidget {
  final UserProfileModel profile;

  const ProfileStatsRow({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. DONE
        Expanded(
          child: _buildStatCard(
            context,
            value: '${profile.tasksDoneCount}',
            label: 'DONE',
            valueColor: const Color(0xFF6EE7B7),
          ),
        ),
        const SizedBox(width: 8),

        // 2. PENDING
        Expanded(
          child: _buildStatCard(
            context,
            value: '${profile.tasksPendingCount}',
            label: 'PENDING',
            valueColor: const Color(0xFFFF7D65),
          ),
        ),
        const SizedBox(width: 8),

        // 3. 6 MK / 19 SKS
        Expanded(
          child: _buildStatCard(
            context,
            value: '${profile.courseCount} MK',
            label: '${profile.sksCount} SKS',
            valueColor: const Color(0xFF5B93FF),
          ),
        ),
        const SizedBox(width: 8),

        // 4. ON-TIME RATE
        Expanded(
          child: _buildStatCard(
            context,
            value: '${profile.onTimeRatePercent}%',
            label: 'ON-TIME',
            valueColor: const Color(0xFFFBBF24),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.rSpacing(12),
        horizontal: context.rSpacing(6),
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF434A59).withValues(alpha: 0.5),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: valueColor,
              fontSize: context.rFont(17, min: 14, max: 20),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: context.rSpacing(4)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(9.5, min: 8.5, max: 11),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

