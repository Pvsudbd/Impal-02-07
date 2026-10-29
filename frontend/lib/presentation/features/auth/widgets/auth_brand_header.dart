import 'package:flutter/material.dart';

/// Standard brand header for authentication pages.
/// Displays signature IMPAL glowing brand container, title, and descriptive subtitle.
class AuthBrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? iconWidget;
  final double bottomSpacing;

  const AuthBrandHeader({
    super.key,
    this.title = 'Smart Task Manager',
    this.subtitle = 'AI-Driven Academic Task & Schedule\nPrioritization System',
    this.iconWidget,
    this.bottomSpacing = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: ShapeDecoration(
            color: const Color(0xFFFA6144),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x59EF4444),
                blurRadius: 20,
                offset: Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: iconWidget ??
              const Text(
                '⚡',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            letterSpacing: -0.50,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.45,
          ),
        ),
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}

