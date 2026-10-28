import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/team_task_model.dart';

/// Card component representing a single team task on the team dashboard.
class TeamTaskCard extends StatelessWidget {
  final TeamTaskModel task;

  const TeamTaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    Color priorityTextColor;
    String priorityText;

    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = AppColors.primary;
        priorityTextColor = Colors.white;
        priorityText = 'HIGH';
        break;
      case TaskPriority.medium:
        priorityColor = const Color(0xFFFBBF24);
        priorityTextColor = const Color(0xFF1F2937);
        priorityText = 'MEDIUM';
        break;
      case TaskPriority.low:
        priorityColor = const Color(0xFF6EE7B7);
        priorityTextColor = const Color(0xFF064E3B);
        priorityText = 'LOW';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Priority Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.8,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  priorityText,
                  style: TextStyle(
                    color: priorityTextColor,
                    fontSize: 9.5,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // "Assign to:" label & Deadline/Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Assign to:',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.access_time_filled_rounded,
                      size: 9,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    task.timeRange,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10.8,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Assignee Profile
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: task.assigneeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF434A59),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.assignedTo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

