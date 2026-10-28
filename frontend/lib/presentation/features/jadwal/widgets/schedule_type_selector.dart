import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 3-way segmented button selector for Lecture, Meeting, or External schedule types.
class ScheduleTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const ScheduleTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLecture = selectedType == 'Lecture';
    final isMeeting = selectedType == 'Meeting';
    final isExternal = !isLecture && !isMeeting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule Type',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                title: 'Lecture',
                icon: Icons.school_rounded,
                isSelected: isLecture,
                onTap: () => onTypeChanged('Lecture'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTypeButton(
                title: 'Meeting',
                icon: Icons.groups_rounded,
                isSelected: isMeeting,
                onTap: () => onTypeChanged('Meeting'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTypeButton(
                title: 'External',
                icon: Icons.event_rounded,
                isSelected: isExternal,
                onTap: () => onTypeChanged('External'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderSubtle,
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textMuted,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

