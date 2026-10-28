import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';

/// Top header for the Task Page.
///
/// Displays greeting "Hi [userName]", task pending counter, and user initials avatar.
/// Complies with AGENTS.md ResponsiveContext and typography tokens.
class TaskHeader extends StatelessWidget {
  final String userName;
  final int pendingCount;
  final String userInitials;

  const TaskHeader({
    super.key,
    this.userName = 'Jarvis',
    this.pendingCount = 10,
    this.userInitials = 'JS',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hi $userName',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: context.rFont(22, min: 18, max: 26),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.30,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$pendingCount task pending',
              style: TextStyle(
                color: AppColors.primaryAccent,
                fontSize: context.rFont(12, min: 11, max: 14),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          width: context.rIcon(44),
          height: context.rIcon(44),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.borderSubtle,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            userInitials,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(14, min: 12, max: 16),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

