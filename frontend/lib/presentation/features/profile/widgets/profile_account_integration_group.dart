import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';

/// Grouped card displaying Account & Integration items:
/// 1. Email (Address preview)
/// 2. Change Password (Bcrypt encrypted action)
/// 3. Terms & Privacy Policy (Academic & Mamdani agreement)
class ProfileAccountIntegrationGroup extends StatelessWidget {
  final String email;
  final VoidCallback? onChangePassword;
  final VoidCallback? onTermsPrivacy;

  const ProfileAccountIntegrationGroup({
    super.key,
    required this.email,
    this.onChangePassword,
    this.onTermsPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'ACCOUNT & INTEGRATION',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: context.rFont(11.5, min: 10, max: 13),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: context.rSpacing(10)),

        // Card Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF434A59).withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Email Tile
              _buildTile(
                context,
                icon: Icons.mail_outline_rounded,
                iconColor: const Color(0xFFFA6144),
                iconBgColor: const Color(0xFFFA6144).withValues(alpha: 0.18),
                title: 'Email',
                subtitle: email,
                showChevron: false,
              ),

              // Divider
              Container(
                width: double.infinity,
                height: 1,
                color: const Color(0xFF434A59).withValues(alpha: 0.35),
              ),

              // 2. Change Password Tile
              _buildTile(
                context,
                icon: Icons.lock_outline_rounded,
                iconColor: const Color(0xFF38BDF8),
                iconBgColor: const Color(0xFF38BDF8).withValues(alpha: 0.18),
                title: 'Change Password',
                subtitle: 'Bcrypt hashed salt encrypted',
                showChevron: true,
                onTap: onChangePassword,
              ),

              // Divider
              Container(
                width: double.infinity,
                height: 1,
                color: const Color(0xFF434A59).withValues(alpha: 0.35),
              ),

              // 3. Terms & Privacy Policy Tile
              _buildTile(
                context,
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF94A3B8),
                iconBgColor: const Color(0xFF94A3B8).withValues(alpha: 0.18),
                title: 'Terms & Privacy Policy',
                subtitle: 'Academic agreement & Mamdani disclaimer',
                showChevron: true,
                onTap: onTermsPrivacy,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool showChevron,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(14),
            vertical: context.rSpacing(12),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: iconColor),
              ),
              SizedBox(width: context.rSpacing(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
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
                        color: AppColors.textMuted,
                        fontSize: context.rFont(11, min: 10, max: 12.5),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (showChevron) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8E95A5),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

