import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../team/models/team_repository.dart';

/// Autocomplete and suggestion chip section for selecting a joined team during meeting creation.
class TeamMeetingAutocomplete extends StatelessWidget {
  final bool isTeamMeeting;
  final TextEditingController teamController;
  final ValueChanged<bool> onToggleTeamMeeting;
  final VoidCallback onTeamChanged;

  const TeamMeetingAutocomplete({
    super.key,
    required this.isTeamMeeting,
    required this.teamController,
    required this.onToggleTeamMeeting,
    required this.onTeamChanged,
  });

  @override
  Widget build(BuildContext context) {
    final joinedTeams = TeamRepository().joinedTeamNames;
    final currentQuery = teamController.text.trim().toLowerCase();
    final teamSuggestions = joinedTeams.where((t) {
      if (currentQuery.isEmpty) return true;
      return t.toLowerCase().contains(currentQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        InkWell(
          onTap: () => onToggleTeamMeeting(!isTeamMeeting),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: isTeamMeeting,
                    activeColor: AppColors.primary,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(
                      color: AppColors.textMuted,
                      width: 1.5,
                    ),
                    onChanged: (val) => onToggleTeamMeeting(val ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Team Meeting',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isTeamMeeting) ...[
          const SizedBox(height: 12),
          const Text(
            'Team Name',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: teamController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Type team name (e.g. Kelompok - IMPAL)',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.group_work_rounded, color: AppColors.textMuted, size: 20),
              filled: true,
              fillColor: AppColors.bgCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onChanged: (_) => onTeamChanged(),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter or select a team name';
              }
              return null;
            },
          ),
          if (teamSuggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF232832),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.touch_app_rounded, color: AppColors.primary, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Joined Teams (Tap to select):',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: teamSuggestions.map((tName) {
                      final isChosen =
                          teamController.text.trim().toLowerCase() == tName.toLowerCase();
                      return InkWell(
                        onTap: () {
                          teamController.text = tName;
                          onTeamChanged();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isChosen ? AppColors.primary : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isChosen ? AppColors.primary : AppColors.borderSubtle,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.group_rounded,
                                color: isChosen ? Colors.white : AppColors.textMuted,
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                tName,
                                style: TextStyle(
                                  color: isChosen ? Colors.white : const Color(0xFFE5E7EB),
                                  fontSize: 12,
                                  fontWeight: isChosen ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

