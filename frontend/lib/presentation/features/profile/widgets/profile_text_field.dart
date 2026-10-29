import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';

/// Reusable input field with labeled title, leading icon, and dark container.
class ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData leadingIcon;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? trailing;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.leadingIcon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.trailing,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: context.rFont(10.5, min: 9.5, max: 12),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(height: context.rSpacing(7)),

        // Input Field Box
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF434A59).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(14),
            vertical: maxLines > 1 ? context.rSpacing(10) : 0,
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: maxLines > 1 ? 4 : 0),
                child: Icon(
                  leadingIcon,
                  size: 18,
                  color: const Color(0xFF8E95A5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  onChanged: onChanged,
                  enableInteractiveSelection: true, // No paste blocking
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(13.5, min: 12, max: 15),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

