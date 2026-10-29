import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../models/user_profile_model.dart';

/// Top hero card displaying avatar, verified student badge, name, NIM, and academic affiliation.
class ProfileHeroCard extends StatelessWidget {
  final UserProfileModel profile;

  const ProfileHeroCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF434A59).withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Subtle top coral gradient highlight
          Positioned(
            top: 0,
            left: 20,
            right: 20,
            height: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.rSpacing(18),
              vertical: context.rSpacing(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Avatar with Coral Ring and Green Checkmark
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2E3440),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          profile.initials,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(26, min: 22, max: 30),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (profile.isActiveStudent)
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.bgCard,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: context.rSpacing(14)),

                // 2. Full Name
                Text(
                  profile.fullName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(20, min: 18, max: 24),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: context.rSpacing(6)),

                // 3. NIM + ACTIVE STUDENT Pill
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'NIM: ${profile.studentId}',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: context.rFont(12.5, min: 11, max: 14),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (profile.isActiveStudent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.6),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'ACTIVE STUDENT',
                          style: TextStyle(
                            color: const Color(0xFF34D399),
                            fontSize: context.rFont(9.5, min: 8.5, max: 11),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: context.rSpacing(14)),

                // Horizontal separator
                Container(
                  width: double.infinity,
                  height: 1,
                  color: const Color(0xFF434A59).withValues(alpha: 0.4),
                ),
                SizedBox(height: context.rSpacing(12)),

                // 4. Academic & Campus Info Row 1 (Major & Campus)
                _buildInfoRow(
                  context,
                  icon: Icons.school_outlined,
                  iconColor: const Color(0xFF8E95A5),
                  text: profile.majorCampus,
                  textColor: const Color(0xFFCBD5E1),
                ),
                SizedBox(height: context.rSpacing(8)),

                // 5. Academic & Campus Info Row 2 (Email)
                _buildInfoRow(
                  context,
                  icon: Icons.mail_outline_rounded,
                  iconColor: const Color(0xFF8E95A5),
                  text: profile.email,
                  textColor: const Color(0xFFCBD5E1),
                ),
                SizedBox(height: context.rSpacing(8)),

                // 6. Group Role Row (Amber Highlight)
                _buildInfoRow(
                  context,
                  icon: Icons.groups_outlined,
                  iconColor: const Color(0xFFFBBF24),
                  text: profile.groupRole,
                  textColor: const Color(0xFFFBBF24),
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String text,
    required Color textColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              color: textColor,
              fontSize: context.rFont(12, min: 10.5, max: 13.5),
              fontFamily: 'Inter',
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }
}

