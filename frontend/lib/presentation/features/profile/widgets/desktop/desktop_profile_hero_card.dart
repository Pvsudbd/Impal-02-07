import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../models/user_profile_model.dart';

/// Profile Hero Card (`FigCraft node 6041`) + Mobile Verified Badge & Status/Bio Box.
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
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 5,
            width: double.infinity,
            color: AppColors.primaryAccent,
          ),
          Padding(
            padding: EdgeInsets.all(context.rSpacing(22)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.bgPrimary,
                            border: Border.all(
                              color: AppColors.primaryAccent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _initials(profile.fullName),
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: context.rFont(20, min: 18, max: 24),
                                fontWeight: FontWeight.w800,
                              ),
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
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.bgSidebar,
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
                    SizedBox(width: context.rSpacing(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: context.rSpacing(10),
                            runSpacing: context.rSpacing(6),
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                profile.fullName,
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: context.rFont(18, min: 16, max: 21),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (profile.isActiveStudent)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.rSpacing(10),
                                    vertical: context.rSpacing(3),
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4EB089)
                                        .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0xFF4EB089)
                                          .withValues(alpha: 0.55),
                                    ),
                                  ),
                                  child: Text(
                                    'Active Student',
                                    style: TextStyle(
                                      color: const Color(0xFF4EB089),
                                      fontSize:
                                          context.rFont(11, min: 10, max: 12),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: context.rSpacing(5)),
                          Text(
                            'NIM: ${profile.studentId}',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: context.rFont(13, min: 12, max: 14),
                              fontWeight: FontWeight.w500,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: context.rSpacing(12)),
                    OutlinedButton.icon(
                      key: const Key('desktop_hero_edit_profile_button'),
                      onPressed: onEditProfileTap,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.bgPrimary,
                        foregroundColor: AppColors.textWhite,
                        side: const BorderSide(color: AppColors.borderSubtle),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.rSpacing(14),
                          vertical: context.rSpacing(12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: context.rIcon(16),
                        color: AppColors.primaryAccent,
                      ),
                      label: Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: context.rFont(12.5, min: 11.5, max: 14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.rSpacing(18)),
                const Divider(color: AppColors.borderSubtle, height: 1),
                SizedBox(height: context.rSpacing(16)),
                _HeroDetailRow(
                  icon: Icons.school_outlined,
                  iconColor: const Color(0xFF778BEB),
                  text: profile.majorCampus,
                  textColor: AppColors.textWhite,
                ),
                SizedBox(height: context.rSpacing(10)),
                _HeroDetailRow(
                  icon: Icons.mail_outline_rounded,
                  iconColor: const Color(0xFF63CDDA),
                  text: profile.email,
                  textColor: AppColors.textMuted,
                ),
                SizedBox(height: context.rSpacing(10)),
                _HeroDetailRow(
                  icon: Icons.groups_2_outlined,
                  iconColor: AppColors.primaryAccent,
                  text: profile.groupRole,
                  textColor: AppColors.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: context.rSpacing(14)),
                Container(
                  key: const Key('desktop_hero_bio_box'),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(14),
                    vertical: context.rSpacing(11),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        size: context.rIcon(16),
                        color: AppColors.textMuted,
                      ),
                      SizedBox(width: context.rSpacing(8)),
                      Expanded(
                        child: Text(
                          profile.bio.trim().isNotEmpty
                              ? profile.bio
                              : 'No academic status or bio set yet.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroDetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final Color textColor;
  final FontWeight fontWeight;

  const _HeroDetailRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.textColor,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: context.rIcon(16), color: iconColor),
        SizedBox(width: context.rSpacing(10)),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: context.rFont(13, min: 12, max: 14),
              fontWeight: fontWeight,
            ),
          ),
        ),
      ],
    );
  }
}

/// Academic Stats Bento Grid (`FigCraft node 6067`).
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
        final compact = constraints.maxWidth < 600;
        final cards = [
          _StatBentoCard(
            value: '$doneCount',
            valueColor: const Color(0xFF4EB089),
            badge: 'DONE',
            badgeBg: const Color(0xFF4EB089).withValues(alpha: 0.18),
            badgeText: const Color(0xFF4EB089),
            caption: '+4 selesai minggu ini',
          ),
          _StatBentoCard(
            value: '$pendingCount',
            valueColor: AppColors.primaryAccent,
            badge: 'PENDING',
            badgeBg: AppColors.primaryAccent.withValues(alpha: 0.2),
            badgeText: AppColors.primaryAccent,
            caption: '2 prioritas tinggi',
          ),
          _StatBentoCard(
            value: coursesLabel,
            valueColor: const Color(0xFF778BEB),
            badge: sksBadge,
            badgeBg: const Color(0xFF778BEB).withValues(alpha: 0.2),
            badgeText: const Color(0xFF778BEB),
            caption: 'Semester 5 Gasal',
          ),
          _StatBentoCard(
            value: onTimeRate,
            valueColor: AppColors.skyBadge,
            badge: 'ON-TIME',
            badgeBg: AppColors.skyBadge.withValues(alpha: 0.2),
            badgeText: AppColors.skyBadge,
            caption: 'Tingkat ketepatan',
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
              if (i < cards.length - 1) SizedBox(width: context.rSpacing(14)),
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
  final String badge;
  final Color badgeBg;
  final Color badgeText;
  final String caption;

  const _StatBentoCard({
    required this.value,
    required this.valueColor,
    required this.badge,
    required this.badgeBg,
    required this.badgeText,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.rSpacing(16)),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: context.rFont(22, min: 18, max: 26),
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.rSpacing(8),
                  vertical: context.rSpacing(3),
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeText,
                    fontSize: context.rFont(10, min: 9, max: 11),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.rSpacing(8)),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(11.5, min: 10.5, max: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Account & Integration Security Card (`FigCraft node 6092`) + Sign Out.
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
    return Container(
      padding: EdgeInsets.all(context.rSpacing(22)),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACCOUNT & INTEGRATION',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: context.rFont(13, min: 12, max: 14),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: context.rSpacing(4)),
          Text(
            'Pengaturan autentikasi Telkom SSO, privasi, dan keamanan kredensial',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(12, min: 11, max: 13),
            ),
          ),
          SizedBox(height: context.rSpacing(16)),
          _SecurityActionRow(
            icon: Icons.verified_outlined,
            iconColor: const Color(0xFF4EB089),
            title: 'Official Email',
            subtitle: profile.email,
            trailing: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.rSpacing(10),
                vertical: context.rSpacing(5),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF4EB089).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '✓ SSO Terverifikasi',
                style: TextStyle(
                  color: const Color(0xFF4EB089),
                  fontSize: context.rFont(11, min: 10, max: 12),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: context.rSpacing(10)),
          _SecurityActionRow(
            icon: Icons.lock_outline_rounded,
            iconColor: AppColors.primaryAccent,
            title: 'Change Password',
            subtitle:
                'Bcrypt hashed salt encrypted • Terakhir diubah 30 hari lalu',
            trailing: ElevatedButton(
              key: const Key('desktop_open_change_password_button'),
              onPressed: onChangePasswordTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: context.rSpacing(14),
                  vertical: context.rSpacing(9),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Change Password',
                style: TextStyle(
                  fontSize: context.rFont(11.5, min: 10.5, max: 12.5),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: context.rSpacing(10)),
          _SecurityActionRow(
            icon: Icons.policy_outlined,
            iconColor: const Color(0xFF778BEB),
            title: 'Terms & Privacy Policy',
            subtitle:
                'Academic agreement, XAI policy & Mamdani fuzzy disclaimer',
            trailing: ElevatedButton(
              key: const Key('desktop_open_terms_button'),
              onPressed: onTermsPrivacyTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF778BEB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: context.rSpacing(14),
                  vertical: context.rSpacing(9),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'View Document',
                style: TextStyle(
                  fontSize: context.rFont(11.5, min: 10.5, max: 12.5),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: context.rSpacing(16)),
          const Divider(color: AppColors.borderSubtle, height: 1),
          SizedBox(height: context.rSpacing(14)),
          Row(
            children: [
              OutlinedButton.icon(
                key: const Key('desktop_profile_logout_button'),
                onPressed: onLogoutTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryAccent,
                  side: const BorderSide(color: AppColors.primaryAccent),
                  minimumSize: const Size(0, 40),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(16),
                    vertical: context.rSpacing(10),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.logout_rounded, size: context.rIcon(16)),
                label: Text(
                  'Log Out Account',
                  style: TextStyle(
                    fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  'Todolist Sistem Cerdas v2.0 • Kelompok 7 IMPAL',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: context.rFont(11, min: 10, max: 12),
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

class _SecurityActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SecurityActionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(16),
        vertical: context.rSpacing(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.bgSidebar,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Icon(icon, size: context.rIcon(16), color: iconColor),
          ),
          SizedBox(width: context.rSpacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: context.rFont(13, min: 12, max: 14),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.rSpacing(2)),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: context.rFont(11.5, min: 10.5, max: 12.5),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.rSpacing(12)),
          trailing,
        ],
      ),
    );
  }
}
