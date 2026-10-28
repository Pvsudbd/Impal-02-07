import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Clean placeholder view displayed when no schedules match current filter.
class ScheduleEmptyState extends StatelessWidget {
  const ScheduleEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                color: AppColors.textMuted,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Schedules Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You have no scheduled activities for this filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

