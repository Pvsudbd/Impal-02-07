import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../models/user_profile_model.dart';

/// Centered Desktop Profile Hero Card (`FigCraft node 6285`).
class DesktopProfileHeroCard extends StatelessWidget {
  final UserProfileModel profile;
  final VoidCallback onEditProfileTap;

  const DesktopProfileHeroCard({
    super.key,
    required this.profile,
    required this.onEditProfileTap,
  });

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'ST';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final displayBio = profile.bio.trim().isNotEmpty
        ? profile.bio.trim()
        : 'Informatics Engineering student focused on Flutter & AI systems.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.rSpacing(24)),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3E4554)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgPrimary,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(profile.fullName),
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: context.rFont(24, min: 20, max: 26),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (profile.isActiveStudent)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    key: const Key('desktop_hero_verified_badge'),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.statusCompleted,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.bgCard,
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.rSpacing(12)),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: context.rFont(19, min: 17, max: 21),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.rSpacing(6)),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mail_rounded,
                size: context.rIcon(14),
                color: AppColors.primary,
              ),
              SizedBox(width: context.rSpacing(8)),
              Flexible(
                child: Text(
                  profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textBody,
                    fontSize: context.rFont(12, min: 11, max: 13.5),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.rSpacing(14)),
          Container(
            key: const Key('desktop_hero_bio_box'),
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: context.rSpacing(16),
              vertical: context.rSpacing(12),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF242934),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              displayBio,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textBody,
                fontSize: context.rFont(12, min: 11, max: 13),
                fontFamily: 'Inter',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 4-column Academic Stats Bento Row (`FigCraft node 6285`).
class DesktopAcademicStatsGrid extends StatelessWidget {
  final int doneCount;
  final int pendingCount;
  final String coursesLabel;
  final String sksBadge;
  final String onTimeRate;

  const DesktopAcademicStatsGrid({
    super.key,
    this.doneCount = 28,
    this.pendingCount = 5,
    this.coursesLabel = '6 MK',
    this.sksBadge = '19 SKS',
    this.onTimeRate = '94%',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 460;
        final cards = [
          _StatBentoCard(
            value: '$doneCount',
            valueColor: AppColors.statusCompleted,
            label: 'DONE',
          ),
          _StatBentoCard(
            value: '$pendingCount',
            valueColor: AppColors.primary,
            label: 'PENDING',
          ),
          _StatBentoCard(
            value: coursesLabel,
            valueColor: const Color(0xFF3B82F6),
            label: sksBadge,
          ),
          _StatBentoCard(
            value: onTimeRate,
            valueColor: const Color(0xFFFBBF24),
            label: 'ON-TIME',
          ),
        ];

        if (compact) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  SizedBox(width: context.rSpacing(12)),
                  Expanded(child: cards[1]),
                ],
              ),
              SizedBox(height: context.rSpacing(12)),
              Row(
                children: [
                  Expanded(child: cards[2]),
                  SizedBox(width: context.rSpacing(12)),
                  Expanded(child: cards[3]),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i < cards.length - 1) SizedBox(width: context.rSpacing(12)),
            ],
          ],
        );
      },
    );
  }
}

class _StatBentoCard extends StatelessWidget {
  final String value;
  final Color valueColor;
  final String label;

  const _StatBentoCard({
    required this.value,
    required this.valueColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(10),
        vertical: context.rSpacing(16),
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3E4554)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontSize: context.rFont(20, min: 17, max: 22),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: context.rFont(10, min: 9, max: 11),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Account & Integration Section + Outlined Log Out & Footer (`FigCraft node 6285`).
class DesktopAccountSecurityCard extends StatelessWidget {
  final UserProfileModel profile;
  final VoidCallback onChangePasswordTap;
  final VoidCallback onTermsPrivacyTap;
  final VoidCallback onLogoutTap;

  const DesktopAccountSecurityCard({
    super.key,
    required this.profile,
    required this.onChangePasswordTap,
    required this.onTermsPrivacyTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT & INTEGRATION',
          style: TextStyle(
            color: const Color(0xFF9CA3AF),
            fontSize: context.rFont(11, min: 10, max: 12),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(height: context.rSpacing(8)),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF3E4554)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _SecurityRow(
                icon: Icons.mail_rounded,
                iconColor: AppColors.primary,
                title: 'Email',
                subtitle: profile.email,
                showChevron: false,
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFF3E4554),
              ),
              _SecurityRow(
                key: const Key('desktop_open_change_password_button'),
                icon: Icons.lock_rounded,
                iconColor: const Color(0xFF06B6D4),
                title: 'Change Password',
                subtitle: 'Bcrypt hashed salt encrypted',
                onTap: onChangePasswordTap,
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFF3E4554),
              ),
              _SecurityRow(
                key: const Key('desktop_open_terms_button'),
                icon: Icons.description_rounded,
                iconColor: const Color(0xFF9CA3AF),
                title: 'Terms & Privacy Policy',
                subtitle: 'Academic agreement & Mamdani disclaimer',
                onTap: onTermsPrivacyTap,
              ),
            ],
          ),
        ),
        SizedBox(height: context.rSpacing(16)),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            key: const Key('desktop_profile_logout_button'),
            onPressed: onLogoutTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.logout_rounded, size: context.rIcon(16)),
            label: Text(
              'Log Out Account',
              style: TextStyle(
                fontSize: context.rFont(13, min: 12, max: 14.5),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(height: context.rSpacing(12)),
        Center(
          child: Text(
            'Smart Task Manager v2.0 • Team 7 IMPAL Telkom University',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSubtle,
              fontSize: context.rFont(11, min: 10, max: 12),
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showChevron;

  const _SecurityRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(16),
        vertical: context.rSpacing(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: context.rIcon(18), color: iconColor),
          ),
          SizedBox(width: context.rSpacing(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: context.rFont(13.5, min: 12, max: 15),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF9CA3AF),
                    fontSize: context.rFont(11.5, min: 10.5, max: 13),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          if (showChevron) ...[
            SizedBox(width: context.rSpacing(10)),
            Icon(
              Icons.chevron_right_rounded,
              size: context.rIcon(18),
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: content,
      ),
    );
  }
}
