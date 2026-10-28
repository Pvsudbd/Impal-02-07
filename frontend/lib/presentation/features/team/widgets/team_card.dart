import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/team_model.dart';

/// Card component representing a single team/kelompok in the list.
class TeamCard extends StatelessWidget {
  final TeamModel team;
  final VoidCallback onTap;

  const TeamCard({
    super.key,
    required this.team,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              Text(
                team.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                team.membersLabel,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildAvatarStack(team.memberColors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarStack(List<Color> colors) {
    const double size = 24.0;
    const double overlap = 16.0;
    final displayColors = colors.take(5).toList();
    final extraCount = colors.length - displayColors.length;

    return SizedBox(
      height: size,
      width: size +
          (displayColors.length - 1 + (extraCount > 0 ? 1 : 0)) * overlap,
      child: Stack(
        children: [
          for (int i = 0; i < displayColors.length; i++)
            Positioned(
              left: i * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: displayColors[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgCard, width: 2),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: displayColors.length * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFF434A59),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgCard, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extraCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

